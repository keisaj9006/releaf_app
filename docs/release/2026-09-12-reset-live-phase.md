# Reset accessible phase updates

Parent `55c271b`, branch `releaf-development`.

Paced breathing exposed its phase label to accessibility but did not mark phase
changes as live updates. Its decorative child text also repeated the phase in
the same semantic node. The living form now exposes one phase label and marks
it live only for active paced breathing with guidance text enabled. Lifecycle
pause and no-words mode disable that live flag. Countdown seconds are outside
the live node, so its label is unchanged within a phase.

This is accessibility metadata for the user's screen reader, not device TTS
narration or a replacement Releaf Guide voice. No audio assets/providers,
breathing timings, rewards or access rules change. Decorative descendants have
no interactive controls; their duplicate semantics are excluded.

## Verification

- RED: guided breathing semantic node lacked `isLiveRegion`; new regression
  failed before implementation.
- `flutter test --no-pub test/reset_breathing_cue_availability_test.dart test/reset_lifecycle_test.dart test/reset_guidance_quality_test.dart`:
  33 passed, exit 0. Tests verify one exact phase label, no label change during
  the same phase, exhale transition and no-words live flag disabled, alongside
  existing timing/reduced-motion/guidance regressions.
- Formatting completed on all three changed Dart files.
- Initial analysis rejected three deprecated `hasFlag` test assertions. Replaced
  with `flagsCollection.isLiveRegion`; final `flutter analyze` passed, exit 0,
  32.4 seconds.
- `flutter test --no-pub`: 543 passed, exit 0, 4:54.
- `flutter build apk --debug --dart-define-from-file=tool/local/revenuecat-test-store.json`:
  success, exit 0, assembleDebug 99.2 seconds. APK:
  `build/app/outputs/flutter-apk/app-debug.apk`. Local configuration remains ignored.
- `git diff --check`: passed; scoped code, test and evidence diff reviewed.
- Independent read-only review found no actionable issue: only phase text is
  live, controls are outside the excluded subtree and no narration fallback exists.
- `adb devices -l`: no connected device; no installation or TalkBack run.

Physical TalkBack announcement timing, interruption behavior and owner comfort
are not proven by semantic-tree tests. Keep Samsung accessibility QA open.
