# Reset immediate sensory progression — 12 September 2026

Branch `releaf-development`, parent `c5ba530`.

`Back to the Room` previously queued a 420 ms delayed advance when a sensory count
completed. The callback checked running state but not the step/path it belonged
to. Completion now advances synchronously through the existing progression method.
This removes the arbitrary wait and stale callback without changing programme
durations, breathing patterns, access, narration, audio assets or rewards.

The new regression test first failed because FEEL was absent after the last SEE
notice. It now verifies immediate SEE-to-FEEL and FEEL-to-HEAR transitions and
that no additional transition occurs 500 ms later. Existing simplified-path,
Emergency and completion tests remain in the focused suite. Formatting also
normalized the existing test file; unrelated assertions were not changed.

## Verification

- `flutter test --no-pub test/relief_access_test.dart --plain-name
  'Sensory completion advances immediately'`: expected RED before the fix.
- `flutter test --no-pub test/relief_access_test.dart test/reset_catalog_test.dart`:
  45 passed, exit 0.
- `dart format` on the changed Dart files: completed.
- `flutter analyze`: No issues found, exit 0.
- `flutter test --no-pub`: 496 passed, exit 0.
- Independent scoped code review: no actionable findings.
- `flutter build apk --debug --dart-define-from-file=tool/local/revenuecat-test-store.json`:
  PASS, exit 0. Existing ignored config; no values printed. Existing Kotlin warning remains.
- Samsung update attempt using `adb -s R5CX11J26SD install -r
  build/app/outputs/flutter-apk/app-debug.apk` failed, exit 1:
  `adb.exe: device 'R5CX11J26SD' not found`.
  No uninstall or device UI verification occurred for this build.

## Remaining gates

The [session blueprint](../product/reset-back-to-room-blueprint.md) records exact
existing timings and the next confirmed gap: labelled skip/ready controls are
absent from this session. Device interaction, comfort/listening, licensed human
breathing candidates and production-equivalent release gates remain open.
