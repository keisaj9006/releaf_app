# Reset reduced-motion breathing path

Parent `fc83257`, branch `releaf-development`.

The shared session clock correctly kept breathing time active under reduced
motion, but the unequal/held-method orbit marker still followed that clock.
The form itself was stationary. This left an unintended moving element in
the reduced-motion experience.

Reduced motion now retains the static oval, central form and current phase
caption, without the moving orbit marker. Session progress updates immediately
rather than interpolating for 720 ms, and phase opacity transitions are disabled.
Default-motion behavior and all method timings remain unchanged.

## Verification

- RED: the 4–6 session orbit requested repaint after 400 ms under reduced motion;
  the new stationary-path test failed with expected false / actual true.
- GREEN: `flutter test --no-pub test/reset_breathing_cue_availability_test.dart test/reset_lifecycle_test.dart`:
  23 passed, exit 0, 8 seconds. Coverage includes actual canvas calls (one oval,
  no marker circles), no phase/progress interpolation, phase advance, all ten
  method clock regressions and normal/reduced-motion completion.
- Formatting completed for both changed Dart files.
- `flutter analyze`: no issues, exit 0, 30.7 seconds.
- `flutter build apk --debug --dart-define-from-file=tool/local/revenuecat-test-store.json`:
  built `build/app/outputs/flutter-apk/app-debug.apk`, exit 0, assembleDebug 49.4 seconds.
- `adb devices -l`: no connected device; no installation or hardware claim.
- `git diff --check`: passed. Complete scoped diff reviewed before checkpoint.
- Last complete suite: 540 passed on parent `fc83257`; not repeated for this
  focused presentation-only follow-up.

No recordings, access/rewards, method definitions or owner artwork approvals
changed. This strengthens RESET accessibility evidence; Samsung rendering,
TalkBack and owner listening remain separate physical verification requirements.
