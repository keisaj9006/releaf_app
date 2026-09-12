# Sleep expiry pause fallback

Parent `5942726`, branch `releaf-development`.

Native pause failure previously escaped expiry. A current expiry now attempts
stop, retains the mute and invalidates source readiness. Failed stop preserves
the last observed transport state and generic error rather than claiming success.
The error-state primary action retries playback even if the last state is playing.

Independent review found a newer timer could be stranded by a delayed fallback
stop. After successful stop, a superseding timer can recover the original track
only when playback generation, driver intent and track are still unchanged.
Recovery reloads the invalidated source. Newer playback decisions remain guarded.

Observed RED tests: pause failure with stop succeeding/failing; retry after both
operations fail; delayed fallback stop superseded by 30-minute timer or Off.
Initial focused suite passed 91 tests before the review/retry additions.
Final focused suite: 93 passed, exit 0. Analysis: no issues, exit 0 (29.3 seconds).
Follow-up independent review confirms the finding is addressed, with no further
actionable findings in the scoped diff.

- `flutter test --no-pub`: 525 passed, exit 0 (3:38).
- `flutter build apk --debug --dart-define-from-file=tool/local/revenuecat-test-store.json`:
  exit 0; Gradle 50.9 seconds. Output
  `build/app/outputs/flutter-apk/app-debug.apk`. Ignored configuration not printed.
- Final formatting: zero changes; `git diff --check` passed.
- `adb devices -l`: no connected device. Installation/physical checks pending.

No breathing methods, audio assets, chosen timer duration, billing or account
data changed. Hardware background/long-duration QA remains open.
