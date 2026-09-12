# Local daily progress rollover — 12 September 2026

Branch `releaf-development`, parent `fca3287`.

The date provider cached its first string. A running application could retain
yesterday's completion flags and deny the next day's reward despite the existing
new-day reset logic. The notifier now refreshes the date at every day check.
Home's existing foreground/resume refresh also requests a day check through
the same serialized queue as reward writes, after initialization completes.

Only daily flags reset on a new date. Accumulated Leaves, reward amounts,
third-pillar bonus, preference keys, migration behavior, local-first policy and
Emergency exclusion are unchanged. No user account/data was deleted or manually
modified. Tests use mock preferences and injected dates, not the phone clock.

## Verification

- RED: five next-day completion requests returned no reward because yesterday's
  date remained cached. A separate Home test retained yesterday's flags.
- `flutter test --no-pub test/rewards_test.dart test/home_hub_test.dart`:
  25 passed, exit 0, before the final overlap assertion was added.
- Final reward coverage also overlaps refresh with five completion requests,
  verifies one award, preserves 10 starting Leaves through several dates and
  checks persisted total/date. Existing bonus and same-day idempotency tests remain.
- `dart format` changed Dart files: completed. Formatting normalized existing
  notifier layout; reward formulas and flags were not changed.
- `flutter analyze`: no issues found (42.2 seconds).
- `flutter test --no-pub`: 509 tests passed, including the final overlap assertion.
- `flutter build apk --debug --dart-define-from-file=tool/local/revenuecat-test-store.json`:
  built `build/app/outputs/flutter-apk/app-debug.apk` (Gradle 133.9 seconds).
- Final `dart format --output=none --set-exit-if-changed` on all four changed
  Dart files: 0 changed, exit 0.
- `adb -s R5CX11J26SD install -r build/app/outputs/flutter-apk/app-debug.apk`:
  Success, exit 0, Samsung SM-S928B. No uninstall or device-clock change.
- Launcher event succeeded; app process running. Boolean-only log sampling:
  Purchases.configure completed=true, fatal exception=false. Current Offering
  was not observed in this bounded sample; no new offering verification claimed.
- Independent review: no actionable findings; refresh and rewards share the queue.

This closes the confirmed cached-day failure. It does not establish overnight
hardware QA, time-zone/clock-tampering policy or cloud synchronization. Do not
change the device clock or reward semantics to manufacture a device PASS.
Continue the remaining backend/offline and release-quality track.
