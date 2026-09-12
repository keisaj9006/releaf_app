# Reset production blueprint export — 12 September 2026

Branch `releaf-development`, parent `b1b7034`.

The existing narration exporter now includes source card metadata and contiguous
start/end seconds for each main and simplified step. The test compares all 50
entries with the actual catalogue and checks each path total. Existing schema
fields, scripts, voice identity, cue rejection, source paths and access remain
unchanged. No runtime code or audio assets changed.

The [50-session working blueprints](../product/reset-session-production-blueprints.md)
capture exact programmes, scripts, immediate actions, safety metadata and recording
availability. They explicitly mark missing production measurements/approval and
distinguish catalogue metadata from dedicated player overrides. Current export:
10 breathing sessions, zero declared recorded narration steps, 217 guided steps
awaiting approved recordings. This does not authorize a substitute narrator.

## Verification

- RED: new test failed because source instructions were absent from the export.
- `flutter test --no-pub test/reset_narration_manifest_export_test.dart`:
  2 passed, exit 0; all 50 sessions and both path types checked.
- `dart format tooling/reset/export_narration_manifest.dart
  test/reset_narration_manifest_export_test.dart`: completed.
- `flutter analyze`: No issues found, exit 0.
- `flutter test --no-pub`: 501 passed, exit 0.
- Independent review found no material issues. Aggregate missing-recording count
  was added explicitly after review noted it was only represented per step.
- No runtime changes; no repeated APK build or disconnected-device installation.

## Remaining work

These are technical working blueprints, not fully accepted production content.
Per-card research appraisal, audio provenance and measurements, delivery prosody,
unique visual acceptance and physical comfort review remain open. Exact approved
narrator identity and human breathing candidates are external content dependencies.
Continue independent playback/handoff reliability in the approved programme;
do not label any listening or release gate closed by this export.
