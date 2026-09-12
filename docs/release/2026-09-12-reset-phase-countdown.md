# Canonical breathing phase countdown

Parent `e007121`, branch `releaf-development`.

The active guided Reset screen now displays seconds remaining in the current
breathing phase, directly from the existing BreathPatternFrame. It respects
no-words mode and does not add an independent timer, change a pattern, or change
audio/hold behavior. This closes the visible phase-time gap only.

The living-form animation still uses an independent repeating controller. This
change does not claim complete phase/audio/visual synchronization or implement
the pending owner-selected botanical lungs. A shared precise session clock and
physical continuity checks remain open work, not an owner approval dependency.

RED: phase-countdown expectation failed before the UI addition. Initial focused
suite passed 9 tests and analyzer was clean (14.5 seconds). An explicit no-words
regression was then added. Final focused tests: 10 passed, exit 0. Final analysis:
no issues, exit 0 (15.8 seconds). `flutter test --no-pub`: 526 passed, exit 0
(4:07). `flutter build apk --debug --dart-define-from-file=tool/local/revenuecat-test-store.json`:
exit 0, Gradle 52.6 seconds. Output: `build/app/outputs/flutter-apk/app-debug.apk`.
Local configuration was not printed. `adb devices -l` showed no connected device;
no installation or physical observation performed. Formatting/diff checks passed.

Next: the [shared-clock plan](../plans/2026-09-12-shared-breathing-clock.md)
records the confirmed independent-clock architecture and required regression
scope. It does not claim the timing migration is implemented.
