# Home time and recommendation continuity — 12 September 2026

Branch `releaf-development`, parent `e7181c0`.

Home cached its first time value for the lifetime of the provider, so greetings,
time-based recommendations and today's insight could remain stale. The mounted
Home screen now refreshes that value once per minute and on resume. Its timer
is cancelled in background states and on disposal. A lifecycle guard prevents
the initial post-frame callback from restarting refresh after an earlier pause.

Premium Sleep recommendation copy now describes the existing sound-first screen,
volume and timer instead of promising guided wind-down or an eight-minute
protocol. Recommendation priority, routes, access, saved focus, mascot identity,
Leaves and reward logic are unchanged. Daily progress rollover is a separate
contract and is not claimed fixed by refreshing the Home clock.

## Verification

- RED: recommendations lacked sound/timer metadata at 18:00 and 21:00;
  long-running and resumed Home retained afternoon content at 21:00.
- Independent review identified a first-frame/background timer ordering issue.
  A direct provider-read test reproduced it; the lifecycle guard fixes it.
- Initial implementation invalidated the provider too early in initState;
  widget tests exposed this and initialization was moved after the first frame.
- `flutter test --no-pub test/home_hub_test.dart test/sleep_experience_test.dart`:
  final 20 passed, exit 0.
- Final `flutter analyze`: No issues found, exit 0.
- `dart format` changed Dart files: completed.
- Final `flutter build apk --debug --dart-define-from-file=tool/local/revenuecat-test-store.json`:
  PASS, exit 0; existing ignored config, no key values printed. Existing Kotlin warning remains.
- Final `flutter test --no-pub`: 507 passed, exit 0, including review regression.
- `adb -s R5CX11J26SD install -r build/app/outputs/flutter-apk/app-debug.apk`:
  Success, no uninstall. Samsung launch smoke showed Home greeting and all five
  tab labels after waking the screen. Boolean logs confirmed RevenueCat configure
  and no fatal exception. Offering success was not observed in this bounded sample;
  no new offering verification is claimed.
- Clock-boundary and background-ordering behavior was verified automatically;
  no device wall-clock modification or overnight observation was performed.

Owner listening, production-equivalent device/release gates and approved content
dependencies remain open. Next: verify daily date rollover/account-local state
without changing accumulated progress or reward semantics.
