import copy
import hashlib
import json
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path

from validate_intake import validate


class IntakeTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        (self.root / 'sample.wav').write_bytes(b'fixture-not-production-audio')
        data = (self.root / 'sample.wav').read_bytes()
        self.record = {
            'id': 'fixture', 'status': 'candidate', 'layer': 'breathing',
            'creator': 'fixture', 'recordedOn': '2026-09-12',
            'rightsEvidence': 'private-evidence-reference',
            'sourceKind': 'human-recording', 'methodId': 'equal-rhythm',
            'phase': 'inhale', 'phaseDurationSeconds': 5,
            'processing': 'No processing',
            'files': {kind: {'path': 'sample.wav', 'sha256': hashlib.sha256(data).hexdigest(),
                             'bytes': len(data)} for kind in ['source', 'master', 'deliverable']},
            'measurements': {'durationSeconds': 5, 'sampleRateHz': 48000,
                             'deliverableSha256': hashlib.sha256(data).hexdigest(),
                             'channels': 1, 'integratedLufs': -24, 'truePeakDbtp': -2,
                             'tool': 'fixture', 'commandEvidence': 'fixture-reference'},
        }

    def test_consistent_candidate_is_not_owner_approved(self):
        self.assertEqual(validate(self.record, self.root), [])
        self.assertEqual(self.record['status'], 'candidate')

    def test_missing_rights_is_reported(self):
        del self.record['rightsEvidence']
        self.assertIn('rightsEvidence:required', validate(self.record, self.root))

    def test_changed_bytes_invalidate_all_three_hashes(self):
        (self.root / 'sample.wav').write_bytes(b'changed')
        errors = validate(self.record, self.root)
        for kind in ['source', 'master', 'deliverable']:
            self.assertIn(f'files.{kind}:hash-mismatch', errors)

    def test_escape_is_rejected_before_file_read(self):
        self.record['files']['source']['path'] = '../outside.wav'
        self.assertIn('files.source:path-outside-root', validate(self.record, self.root))

    def test_approval_requires_both_device_observations_and_exact_hash(self):
        self.record['status'] = 'owner-approved'
        self.assertIn('approval:required', validate(self.record, self.root))
        self.record['approval'] = {'date': '2026-09-12', 'evidence': 'owner-reference',
                                  'deliverableSha256': '0' * 64,
                                  'device': 'Samsung SM-S928B', 'speaker': 'reviewed'}
        errors = validate(self.record, self.root)
        self.assertIn('approval.headphones:required', errors)
        self.assertIn('approval:hash-mismatch', errors)

    def test_nonfinite_measurement_is_not_valid(self):
        self.record['measurements']['integratedLufs'] = float('nan')
        self.assertIn('measurements.integratedLufs:invalid', validate(self.record, self.root))

    def test_measurements_are_bound_to_deliverable(self):
        self.record['measurements']['deliverableSha256'] = '0' * 64
        self.assertIn('measurements:hash-mismatch', validate(self.record, self.root))

    def test_complete_submitted_approval_is_consistent_but_not_granted(self):
        self.record['status'] = 'owner-approved'
        self.record['approval'] = {
            'date': '2026-09-12', 'evidence': 'fixture-owner-reference',
            'deliverableSha256': self.record['files']['deliverable']['sha256'],
            'device': 'Samsung SM-S928B', 'speaker': 'fixture-observation',
            'headphones': 'fixture-observation',
        }
        self.assertEqual(validate(self.record, self.root), [])

    def test_synthetic_breathing_and_hold_cues_are_rejected(self):
        self.record['sourceKind'] = 'synthetic'
        self.record['phase'] = 'hold'
        errors = validate(self.record, self.root)
        self.assertIn('sourceKind:human-recording-required', errors)
        self.assertIn('phase:inhale-or-exhale-required', errors)

    def test_duration_mismatch_is_reported_without_stretching(self):
        self.record['measurements']['durationSeconds'] = 4
        original = copy.deepcopy(self.record)
        self.assertIn('phaseDurationSeconds:duration-mismatch', validate(self.record, self.root))
        self.assertEqual(self.record, original)

    def test_malformed_input_fails_closed(self):
        for value in [None, [], 'text', 3]:
            self.assertEqual(validate(value, self.root), ['record:object-required'])

    def test_oversized_numbers_return_field_errors_without_traceback(self):
        self.record['measurements']['durationSeconds'] = 10 ** 400
        self.record['phaseDurationSeconds'] = 10 ** 400
        record_path = self.root / 'record.json'
        record_path.write_text(json.dumps(self.record), encoding='utf-8')
        result = subprocess.run(
            [sys.executable, str(Path(__file__).with_name('validate_intake.py')),
             str(record_path), '--root', str(self.root)],
            capture_output=True, text=True,
        )
        self.assertEqual(result.returncode, 1)
        self.assertEqual(result.stderr, '')
        report = json.loads(result.stdout)
        self.assertIn('measurements.durationSeconds:invalid', report['errors'])
        self.assertIn('phaseDurationSeconds:invalid', report['errors'])
        self.assertFalse(report['approvalGranted'])
        self.assertNotIn('private-evidence-reference', result.stdout)


if __name__ == '__main__':
    unittest.main()
