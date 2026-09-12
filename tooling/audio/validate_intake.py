"""Read-only evidence consistency checks; never approves or promotes audio."""

import argparse
import datetime
import hashlib
import json
import math
from pathlib import Path


def finite_number(value):
    try:
        return type(value) in [int, float] and math.isfinite(value)
    except OverflowError:
        return False


def validate(record, root):
    if not isinstance(record, dict):
        return ['record:object-required']
    errors = []

    def required(obj, key, prefix=''):
        if not isinstance(obj.get(key), str) or not obj[key].strip():
            errors.append(f'{prefix}{key}:required')

    def date(obj, key, prefix=''):
        try:
            datetime.date.fromisoformat(obj[key])
        except (KeyError, ValueError, TypeError):
            errors.append(f'{prefix}{key}:invalid-date')

    for key in ['id', 'creator', 'rightsEvidence', 'processing']:
        required(record, key)
    date(record, 'recordedOn')
    if record.get('status') not in ['candidate', 'rejected', 'owner-approved']:
        errors.append('status:invalid')
    layer = record.get('layer')
    if layer not in ['breathing', 'narration', 'ambience']:
        errors.append('layer:invalid')

    files = record.get('files')
    files = files if isinstance(files, dict) else {}
    root = Path(root).resolve()
    for kind in ['source', 'master', 'deliverable']:
        entry = files.get(kind)
        prefix = f'files.{kind}'
        if not isinstance(entry, dict):
            errors.append(f'{prefix}:required')
            continue
        path = entry.get('path')
        if not isinstance(path, str) or not path.strip():
            errors.append(f'{prefix}:path-required')
            continue
        try:
            target = (root / path).resolve()
            if not target.is_relative_to(root):
                errors.append(f'{prefix}:path-outside-root')
                continue
            digest = hashlib.sha256()
            size = 0
            with target.open('rb') as audio:
                for chunk in iter(lambda: audio.read(65536), b''):
                    size += len(chunk)
                    digest.update(chunk)
            if entry.get('sha256') != digest.hexdigest():
                errors.append(f'{prefix}:hash-mismatch')
            if type(entry.get('bytes')) is not int or entry['bytes'] != size or size == 0:
                errors.append(f'{prefix}:size-mismatch')
        except (OSError, ValueError, RuntimeError):
            errors.append(f'{prefix}:unreadable')

    measurements = record.get('measurements')
    measurements = measurements if isinstance(measurements, dict) else {}
    deliverable = files.get('deliverable')
    expected = deliverable.get('sha256') if isinstance(deliverable, dict) else None
    if not expected or measurements.get('deliverableSha256') != expected:
        errors.append('measurements:hash-mismatch')
    for key in ['durationSeconds', 'sampleRateHz', 'channels', 'integratedLufs', 'truePeakDbtp']:
        value = measurements.get(key)
        valid = finite_number(value)
        if key in ['durationSeconds', 'sampleRateHz', 'channels']:
            valid = valid and value > 0
        if key in ['sampleRateHz', 'channels']:
            valid = valid and type(value) is int
        if not valid:
            errors.append(f'measurements.{key}:invalid')
    for key in ['tool', 'commandEvidence']:
        required(measurements, key, 'measurements.')

    if layer == 'breathing':
        if record.get('sourceKind') != 'human-recording':
            errors.append('sourceKind:human-recording-required')
        if record.get('phase') not in ['inhale', 'exhale']:
            errors.append('phase:inhale-or-exhale-required')
        required(record, 'methodId')
        duration = record.get('phaseDurationSeconds')
        if not finite_number(duration) or duration <= 0:
            errors.append('phaseDurationSeconds:invalid')
        elif duration != measurements.get('durationSeconds'):
            errors.append('phaseDurationSeconds:duration-mismatch')
    if layer == 'narration':
        for key in ['scriptStep', 'approvedNarratorEvidence']:
            required(record, key)

    if record.get('status') == 'owner-approved':
        approval = record.get('approval')
        if not isinstance(approval, dict):
            errors.append('approval:required')
        else:
            for key in ['evidence', 'speaker', 'headphones']:
                required(approval, key, 'approval.')
            date(approval, 'date', 'approval.')
            if approval.get('device') != 'Samsung SM-S928B':
                errors.append('approval.device:Samsung-SM-S928B-required')
            if not expected or approval.get('deliverableSha256') != expected:
                errors.append('approval:hash-mismatch')
    return errors


def validate_catalog(record, manifest):
    """Check a breathing variant against a freshly exported Reset manifest."""
    if not isinstance(record, dict) or record.get('layer') != 'breathing':
        return []
    if not isinstance(manifest, dict) or not isinstance(manifest.get('sessions'), list):
        return ['catalog:manifest-required']
    rows = manifest['sessions']
    if any(not isinstance(row, dict) for row in rows):
        return ['catalog:invalid-sessions']
    matching = [row for row in rows if row.get('id') == record.get('methodId')]
    if len(matching) != 1:
        return ['catalog:method-not-unique']
    session = matching[0]
    pattern = session.get('breathPattern')
    if session.get('modality') != 'breathing' or not isinstance(pattern, dict):
        return ['catalog:not-breathing']
    phase = record.get('phase')
    if phase not in ['inhale', 'exhale']:
        return ['catalog:inhale-or-exhale-required']
    expected = pattern.get(phase + 'Seconds')
    if type(expected) is not int or expected <= 0:
        return ['catalog:invalid-phase-duration']
    if record.get('phaseDurationSeconds') != expected:
        return ['catalog:phase-duration-mismatch']
    return []


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('record', type=Path)
    parser.add_argument('--root', type=Path, required=True)
    parser.add_argument('--reset-manifest', type=Path)
    args = parser.parse_args()
    try:
        record = json.loads(args.record.read_text(encoding='utf-8'))
        errors = validate(record, args.root)
        if isinstance(record, dict) and record.get('layer') == 'breathing':
            try:
                manifest = (json.loads(args.reset_manifest.read_text(encoding='utf-8'))
                            if args.reset_manifest else None)
                errors.extend(validate_catalog(record, manifest))
            except (OSError, UnicodeError, ValueError):
                errors.append('catalog:unreadable-or-invalid-json')
    except (OSError, UnicodeError, ValueError):
        errors = ['record:unreadable-or-invalid-json']
    print(json.dumps({'errors': errors, 'approvalGranted': False,
                      'scope': 'submitted-evidence-consistency-only'}))
    return 1 if errors else 0


if __name__ == '__main__':
    raise SystemExit(main())
