# Sleep timer expiry with native volume failure

Parent `7298fb7`, branch `releaf-development`.

The expiry path awaited a native mute before pausing. A rejected volume write
escaped and prevented the pause, leaving playback running after the deadline.
Timer volume writes now report a generic playback error and allow expiry to
continue. Fade ticks and expiry restoration use the same contained error path.
No selected duration, fade length, exact seek, audio asset or narration change.

Verification so far:

- RED: injected volume failure escaped at `syncSleepTimerNow` before pause.
- Initial focused Sound loading/cancellation/experience suite: 88 passed, exit 0.
- Independent review found a delayed obsolete volume error could mark newer
  playback failed. A second test reproduced it. Error publication now checks
  timer/playback/driver intent and superseding volume writes.
- Dart formatting and `git diff --check` passed.
- Final focused loading/cancellation/experience tests: 89 passed, exit 0.
- `flutter analyze`: no issues, exit 0 (23.9 seconds).
- Follow-up independent review: stale-error finding addressed, no further
  actionable findings in the scoped diff.
- `flutter test --no-pub`: 521 passed, exit 0 (3:23).
- `flutter build apk --debug --dart-define-from-file=tool/local/revenuecat-test-store.json`:
  exit 0; Gradle 51.1 seconds. Output
  `build/app/outputs/flutter-apk/app-debug.apk`; local configuration not printed.
- Final formatter verification: zero changes. `adb devices -l` reports no
  connected device; no installation or physical observations performed.

This test proves pause is requested when volume fails. A native pause failure,
physical background delivery and long-duration listening need separate evidence.
No device observation, owner audio approval or release readiness is claimed.
