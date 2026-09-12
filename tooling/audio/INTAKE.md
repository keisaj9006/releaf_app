# Audio evidence intake

Run locally with Python 3.10+:

```powershell
python tooling/audio/validate_intake.py <local-record.json> --root <audio-review-directory>
python -m unittest discover -s tooling/audio -p test_validate_intake.py
```

Breathing records additionally require a current Reset catalog export:

```powershell
flutter test --no-pub test/reset_narration_manifest_export_test.dart
python tooling/audio/validate_intake.py <local-record.json> --root <audio-review-directory> --reset-manifest build/qa-manifests/reset-releaf-guide-manifest.json
```

The CLI fails closed if a breathing record has no manifest. It requires exactly
one matching session ID, breathing modality, and the duration of the specific
inhale/exhale phase. Holds cannot be registered as breathing sounds. The manifest
is supplied evidence; regenerate it on the branch being reviewed rather than
trusting an old or edited file. No methods or durations are written by this tool.

Use an ignored local record for private references. Never put private licences,
credentials or correspondence in git. No real candidate records are supplied:
the test fixtures contain dummy bytes, not usable or approved audio.

The command reads one JSON object. Exit 0 means submitted evidence is internally
consistent; exit 1 reports field/error codes. Output always says
`approvalGranted: false`. It does not authenticate evidence, decode or listen to
audio, verify a licence, infer human origin, certify measurements, or promote
files. An owner-approved status is a claim being checked for required supporting
fields, not approval issued by this program. Existing runtime approvals are
unaffected. Reviewers must inspect the actual referenced evidence separately.

| Fields | Required content |
| --- | --- |
| `id`, `creator`, `rightsEvidence`, `processing` | Nonempty safe references/history |
| `recordedOn` | ISO calendar date |
| `status` | `candidate`, `rejected`, or `owner-approved` |
| `layer` | `breathing`, `narration`, or `ambience` |
| `files.source`, `files.master`, `files.deliverable` | Each contains `path`, lowercase `sha256`, positive integer `bytes`; checked against actual bytes inside root |
| `measurements` | `durationSeconds`, integer `sampleRateHz`, integer `channels`, finite `integratedLufs`, finite `truePeakDbtp`, `tool`, `commandEvidence`, `deliverableSha256` |
| Breathing only | `sourceKind: human-recording`, `methodId`, `phase: inhale` or `exhale`, positive `phaseDurationSeconds` equal to submitted measured duration |
| Narration only | `scriptStep`, `approvedNarratorEvidence` |
| Owner-approved only | `approval` containing `date`, `evidence`, `deliverableSha256`, `device: Samsung SM-S928B`, `speaker` and `headphones` observation references |

Measurement and approval hashes must match the submitted deliverable hash, whose
bytes are independently checked. Changing a file invalidates the corresponding
hash. The CLI compares breathing duration to the supplied Reset manifest;
the low-level `validate` function checks the record alone and callers must also
invoke `validate_catalog` for that comparison. It never changes a
phase or time-stretches an asset. Codec padding should be investigated rather
than hidden with automatic tolerance or cropping. No minimum loudness, sample
rate normalization or retrospective rejection of approved sources is imposed.

For three human breathing candidate sets, validate each proposed duration variant
separately, then conduct the required Samsung auditions. A clean individual
report does not establish the required candidate count or owner selection.
No synthetic hold sound is accepted by this breathing-cue schema.

## Verification — 12 September 2026

12 unittest cases passed, including real byte/hash changes, path containment,
missing rights, approval/device fields, measurement-to-file binding, prohibited
cue metadata and malformed/oversized numeric input via the actual CLI. The
measurement-binding and oversized-number regressions were observed failing
before their fixes. Initial new-module test collection failed before the module
existed; this is separate from the behavioral regression evidence.

Independent review identified the numeric overflow; it was reproduced and fixed.
`flutter analyze` passed (35.0 seconds). `git diff --check` passed. No Flutter
runtime/assets/dependencies changed, so the existing 519-test/APK checkpoint was
not rebuilt or reinstalled for this tooling-only batch.
