# Five primary destinations — 12 September 2026

Branch: `releaf-development`; parent `f3a8795`.

## Implemented

- Exact approved order: Home / Reset / Meditate / Sleep / Brain.
- Existing Meditation and Sleep screens now participate in the stateful shell.
  Sound remains a secondary library in Sleep's branch, including favourites and
  recents. `/sound`, player URLs, resume extras and legacy aliases are preserved.
- Meditate and Sleep expose direct Emergency and account actions. No entitlement
  checks, emergency privacy rules, breathing patterns or rewards changed.
- Narrow large-text tests exposed fixed-height/row overflows in existing Sleep,
  Brain and Reset cards. Labels now wrap and layouts reserve/adapt their height.
  Readability overlays remain sized even on content-driven cards.

## Automated verification

- Red: five new route/order tests failed before navigation changes. Two further
  failures reproduced missing Emergency/account shortcuts. Large-text tests then
  reproduced Sleep/Brain/Reset overflows.
- `flutter test --no-pub test/primary_wellbeing_tabs_test.dart
  test/five_primary_destinations_test.dart`: **38 passed** at the first combined
  checkpoint; subsequent coverage is included in the complete suite below.
- Independent review found disappearing gradient overlays and a Sleep reserve
  based on the wrong font size for nonlinear scaling. Both were reproduced by
  added tests and fixed. Final focused `five_primary_destinations_test.dart`:
  **8 passed**. Covers branch restoration/reselection, Emergency/account entry,
  320px linear 2x and nonlinear scaling, scroll retention and overlay dimensions.
- `dart format` on changed Dart files: completed.
- Final `flutter analyze`: **No issues found**, exit 0.
- Final `flutter test --no-pub`: **482 passed**, exit 0.
- `flutter build apk --debug
  --dart-define-from-file=tool/local/revenuecat-test-store.json`: **PASS**, exit 0.
  Existing ignored public SDK configuration used; no credentials exposed/added.
  Existing Kotlin 2.2.20 future-support warning remains; no validation bypass.
- `git diff --check`: PASS. Added tracked lines had zero matches in the bounded
  credential-pattern check; explicit changed-file review found no credentials.

## Android device evidence

APK: `build/app/outputs/flutter-apk/app-debug.apk`, 223,816,896 bytes.
SHA256: `09CDB63777B352BF7A624E56F2E6769BB9EEA3B1B9DE1B4FF880B143892CA60E`.

`adb -s R5CX11J26SD install -r build/app/outputs/flutter-apk/app-debug.apk`:
**Performing Streamed Install / Success**, exit 0. No uninstall or app-data clear.
`adb shell am start -n app.releaf.mobile/.MainActivity`: succeeded.

Samsung SM-S928B bounded UI smoke: Home, Reset, Meditate, Sleep and Brain opened
with the five-tab bar. Sleep's library action opened the existing Sound screen.
Meditate disclosed Captions only for the unrecorded featured practice; Sleep
displayed its no-voice entry. Screenshots are local ignored review artefacts in
`build/quality/five-tabs/` (home, meditate, sleep, brain, reset).

Safe boolean-only log inspection confirmed Purchases.configure completion,
current Offering present, and the protected primary QA internal ID present.
No fatal exception was observed in the inspected app-process logs. No key was
printed. No purchase, restore, account deletion or production mutation occurred.

This is navigation smoke, not owner listening, long-duration audio, physical
accessibility, transaction or production-equivalent release QA. New audio was
neither generated nor approved. All existing breathing methods remain unchanged.

## Next

Continue the remediation plan's Meditation content contracts and Reset blueprints.
Approved narrator/source recordings, candidate provenance/owner listening, long
playback review and the canonical external production gates remain open.
