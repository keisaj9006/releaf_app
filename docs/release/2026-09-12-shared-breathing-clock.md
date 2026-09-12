# Shared paced-breathing clock

Parent `e1a783b`, branch `releaf-development`.

Paced breathing now uses one parent elapsed-seconds AnimationController for
session duration, phase text/countdown, cue dispatch and Living Form cycle.
The child stops its independent animation when supplied this source. The parent
rebuilds session text only when remaining whole seconds change; the central form
listens directly for smooth frames. Guided non-breathing session timing is unchanged.

The session clock uses AnimationBehavior.preserve so reduced motion cannot shorten
the exercise. Lifecycle, abort, completion and disposal stop the clock; resume
preserves fractional elapsed time. Existing method ratios, holds, IDs, rewards
and rejected cue eligibility remain unchanged. No new artwork or audio approved.

## Verification

- RED: after pausing at 4.5 seconds and resuming for 0.6 seconds, equal-rhythm
  still displayed inhale. Reproduced in normal and reduced-motion modes.
- Focused 26 tests passed after implementation: all ten methods, stable inhale
  holds, fractional lifecycle pause, no-background-frame preservation,
  exact-duration completion/one history record and existing audio cancellation.
- Independent review found no code defect; requested broader visual/completion
  coverage, now included. Added visible contraction assertions during exhale.
- Final focused command: `flutter test --no-pub test/reset_lifecycle_test.dart test/reset_breathing_cue_availability_test.dart test/reset_ambience_lifecycle_test.dart`: 26 passed, exit 0.
- `dart format` on the three changed Dart files completed. Initial analysis
  identified one missing-braces lint; corrected before final verification.
- `flutter analyze`: no issues, 15.4 seconds, exit 0.
- `flutter test --no-pub`: 540 passed, 3:33, exit 0.
- `flutter build apk --debug --dart-define-from-file=tool/local/revenuecat-test-store.json`:
  success, assembleDebug 49.5 seconds, exit 0. Configuration remains ignored.
- APK: `build/app/outputs/flutter-apk/app-debug.apk`.
- Follow-up independent source review found no remaining blocker. Reviewer did
  not independently rerun tests or assess device performance.
- `adb devices -l`: no connected device. No installation or device smoke check
  performed. Last installed checkpoint remains `abb98f7`.
- Canonical master wording now explicitly records the existing 4–6 versus
  requested 6–4 discrepancy; no catalogue or timing changed.

This unifies the active session/visual clock; it is not sample-accurate native
audio scheduling. Delayed-frame/device observations and Samsung listening remain
required. Owner selection of botanical lungs/Grounding directions and licensed
human breathing candidates remain separate. No new device result claimed.

Release impact: strengthens RESET core lifecycle/phase agreement evidence;
content approval and production-equivalent physical-device gates remain open.
