# Reset reduced-motion transitions

Branch `releaf-development`, parent `4dfaef2`.

System reduced motion already reached the central Reset artwork, but the shell
and guidance AnimatedSwitchers still used fixed transition durations. They now
use zero duration when the system disables animations. Default-mode durations,
breathing methods, phase times, access and audio remain unchanged.

Verification:

- RED: the new accessibility regression expected zero duration but observed
  420 ms in the active shell.
- `flutter test --no-pub test/reset_breathing_cue_availability_test.dart test/reset_lifecycle_test.dart test/reset_sensory_skip_test.dart`:
  9 passed, exit 0. Includes continued inhale/exhale guidance in reduced motion.
- Dart formatter completed; `git diff --check` passed.
- `flutter analyze`: no issues, exit 0 (14.9 seconds).
- `flutter test --no-pub`: 519 passed, exit 0 (4:58).
- `flutter build apk --debug --dart-define-from-file=tool/local/revenuecat-test-store.json`:
  exit 0, Gradle 59.7 seconds. Ignored configuration was not printed.
  Output: `build/app/outputs/flutter-apk/app-debug.apk`.
- `adb devices -l`: exit 0 with no connected devices. No installation or
  physical accessibility observation performed.

This is a targeted transition fix, not full reduced-motion accessibility
certification. Owner-selected lungs/Grounding visuals, Samsung assessment,
approved recordings and the other release gates remain open.
