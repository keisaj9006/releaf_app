# Sound playback intent — 11 September 2026

Milestone 3 of the owner-approved quality programme, based on `cb64fcd` on
`releaf-development`. Scope: existing Sound/Sleep playback, no asset, access,
account, reward, dependency or provider change.

## Reproduced defects and fix

Controller starts did not validate their request after awaited configuration.
Both native drivers combined source loading with autoplay, allowing a late load
to resume after pause/stop or replace a newer track. A selected track was also
treated as resumable before its source was ready. Competing native volume writes
could restore an obsolete volume or fade after a newer choice.

Starts now validate controller and native transport versions after awaits.
Native operations share an ordered driver; source loading and resume are
separate and cancellation invalidates pending starts immediately. Loaded sources
can still resume after pause/stop; cancelled or failed sources must reload.
Native queues recover after a failed load. Delayed controller writes repair to
the latest desired output without creating a new volume intent.

Review-driven composed regressions also reproduced media-notification commands
that bypass the controller, obsolete timer expiry pausing a newer track, and
notification cancellation leaving output at zero. Version checks preserve the
new transport choice, and expired-timer cleanup restores volume without changing
transport or overriding a replacement timer. No timer-duration rule changed.

Files: the Sound controller and background driver; `sound_experience_test.dart`
and new `sound_driver_cancellation_test.dart`; programme, current-state, roadmap,
canonical gate, DQA-04 and this evidence. No UI redesign in this milestone.

## Verification

TDD runs reproduced delayed controller/native cancellation and volume races.
The final six regressions failed with actual volume 0 instead of 0.62 before the
expiry cleanup fix. An intermediate full run included those new red tests and
failed as expected; the final full run below includes the fix. One focused
invocation also referenced a nonexistent `sound_interruption_policy_test.dart`;
the corrected command uses `audio_interruption_policy_test.dart`.

| Exact command | Final result |
| --- | --- |
| `flutter pub get` | Dependencies resolved; exit 0; no lockfile change. |
| `dart format --output=none --set-exit-if-changed lib/features/sound/application/sound_player_controller.dart lib/features/sound/application/releaf_background_sound_driver.dart test/sound_experience_test.dart test/sound_driver_cancellation_test.dart` | 4 files, 0 changes; exit 0. |
| `flutter test --no-pub test/sound_driver_cancellation_test.dart test/sound_experience_test.dart test/sleep_experience_test.dart test/audio_interruption_policy_test.dart test/background_audio_contract_test.dart --reporter expanded` | 70/70 passed; exit 0. |
| `flutter analyze --no-pub` | No issues found, 36.1 seconds; exit 0. |
| `flutter test --no-pub --reporter expanded` | 425/425 passed, 3:05; exit 0. |
| `flutter build apk --debug --dart-define-from-file=tool/local/revenuecat-test-store.json` | APK built; assembleDebug 122.6 seconds; exit 0. |
| `git diff --check` | Passed. |
| `adb devices -l` | No connected device. No install, purchase or physical QA. |

APK: `build/app/outputs/flutter-apk/app-debug.apk`, **223,802,596 bytes**.
SHA-256: `E0DD70F85812FAB36E23DB3A6E1222E95532A636491830801670C5E743921B11`.
The ignored local Test Store configuration was reused without printing values.
The debug APK is not a production-equivalent release artifact. Existing Flutter
future-support warnings for Android build tooling remain; no bypass used.

Independent final read-only review found no remaining blocker after expiry
volume repair. Tests exercise both real driver classes with an injected fake
native player, plus composed controller/notification behaviour. They do not
establish audible looping, platform latency, notification rendering or screen-off
behaviour on Samsung. Existing player route/widget tests pass.

## Release impact and next task

Sleep remains **DONE / CONTENT**. DQA-04 explicitly includes rapid track changes
and notification actions around loading/expiry; its status remains `TBD`.
Content approval, physical-device QA and external release prerequisites stay
open. Releaf is not release-ready.

Next: show loading and safe retry in the existing Sound player, handle current
startup errors without unhandled futures, and cancel pending starts during
system interruptions. Then continue the approved Brain progression work.
