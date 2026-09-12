# Audio intake binding to Reset catalog

Parent `a1fb75e`, branch `releaf-development`. Extends the read-only intake tool
with `--reset-manifest`, mandatory in the CLI for human breathing records.
Checks unique matching ID, breathing modality, phase and exact phase duration.
No new ratios, reversals, timing changes, audio generation or asset promotion.

Verification:

- Python unittest discovery: 17 passed, exit 0.
- `flutter test --no-pub test/reset_narration_manifest_export_test.dart`:
  2 passed, exit 0; regenerated the current catalog manifest.
- Current export: 10 breathing methods, 40 assertions passed (each of 20 phases
  accepts the catalog duration and rejects duration + 1). The first helper read
  failed on the Windows default encoding; explicit UTF-8 passed. Production CLI
  already uses UTF-8.
- `flutter analyze`: no issues, exit 0 (11.3 seconds).
- `git diff --check`: passed. No runtime changes, full-suite/APK repetition or
  device installation for this tooling-only change.

Initial tests could not import the new validator before implementation; this
was a missing API result, not a reproduced runtime app defect.

The manifest must be freshly exported from the reviewed branch. This tool does
not authenticate an externally edited manifest, measure acoustic duration or
approve the recordings. Real source/licensing evidence and device listening
remain necessary; all existing runtime audio and approvals remain unchanged.
