# Accessible sensory skip controls — 12 September 2026

Branch `releaf-development`, parent `f449cf4`.

Back to the Room now exposes ready, skip-sense and finish actions using the
existing step progression. Both full and simplified programmes have labels.
In no-words mode the arrow remains accessible with a screen-reader label but
without visible instruction text. Tests also reproduced unreachable controls
and vertical overflow at 320px/2x text; the sensory session now scrolls when
needed. Other session visual layouts are unchanged.

Catalogue timings, phase order, IDs, breathing methods, access and reward logic
are unchanged. Formatter-only catalogue changes outside Back to the Room have
been reviewed separately. No audio assets, narrator, credentials or backend
configuration changed.

## Verification

- RED: both presentation modes lacked the action; subsequent narrow-layout test
  reproduced vertical overflow and an off-screen button.
- `flutter test --no-pub test/reset_sensory_skip_test.dart
  test/relief_access_test.dart test/reset_catalog_test.dart`: 47 passed, exit 0.
- `dart format` changed Dart files: completed.
- `flutter analyze`: No issues found, exit 0.
- `flutter test --no-pub`: 498 passed, exit 0.
- `flutter build apk --debug --dart-define-from-file=tool/local/revenuecat-test-store.json`:
  PASS, exit 0; ignored configuration, no key values printed. Existing Kotlin warning remains.
- Catalogue comparison after removing only the added action labels and whitespace:
  identical to parent. No other content or timing change.
- Independent scoped review: no actionable findings.
- `adb devices -l`: no connected device. No install, uninstall or physical
  verification was attempted for this checkpoint.

Owner listening, long-duration hardware checks, physical accessibility review,
licensed breathing recordings and production release gates remain open.
Next: remaining Reset blueprints and interrupted sensory progression coverage.
