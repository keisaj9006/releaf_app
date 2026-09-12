# Reset lifecycle and timing inventory — 12 September 2026

Branch `releaf-development`, parent `0a43fdf`. Tests and documentation only;
runtime, audio assets, access, timings and rewards unchanged.

Two additional widget tests exercise full and simplified sensory paths across
inactive/hidden/paused states, 90 seconds in the background, resume and completing
the remaining notices. Both preserve the active step, count and remaining time,
then resume and advance correctly. Existing implementation passed immediately;
no lifecycle fix was necessary or claimed.

The [breathing-method matrix](../product/breathing-method-evidence-matrix.md)
records all ten actual methods with phase seconds and calculated cycles/minute.
The owner's 6–4 mention is explicitly distinguished from implemented 4–6; no
method is reversed, added or relabelled. Audio approval and scientific evidence
are not inferred from a timing inventory.

## Verification

- `flutter test --no-pub test/reset_lifecycle_test.dart
  test/reset_ambience_lifecycle_test.dart test/reset_catalog_test.dart
  test/reset_narration_manifest_export_test.dart`: 30 passed, exit 0.
- The exporter regenerated `build/qa-manifests/reset-releaf-guide-manifest.json`.
- PowerShell comparison: all ten markdown timing rows match the fresh manifest;
  all cycle rates equal rounded 60/cycleSeconds.
- `dart format test/reset_lifecycle_test.dart`: completed.
- `flutter analyze`: No issues found, exit 0.
- Full suite remains the preceding 498-test checkpoint; the two new cases passed
  in this focused run. Do not describe this as a fresh 500-test full-suite run.
- No rebuild/reinstall of the unchanged runtime. The last built APK remains the
  sensory skip checkpoint; Samsung physical review is still pending.

Next: finish per-session Reset production blueprints, then the remaining approved
programme tracks. Missing licensed breathing recordings, approved narrator assets,
owner listening and production-equivalent release requirements remain open.
