# Breathing visual lifecycle — 12 September 2026

Branch `releaf-development`, parent `cd57f8b`.

The Reset countdown paused in the background, but the living-form animation
kept an independent repeating clock. Flutter suppressed frames while hidden;
the first resumed frame then caught up background time, losing visual continuity
with the paused session. The regression observed scale 0.9964 before pause and
1.159532 immediately on return despite an unchanged session countdown.

The form now stops its controller synchronously on lifecycle notification,
preserves the cycle value and resumes from it. An explicit paused property also
follows the parent session state. Initialization respects the current lifecycle,
and disposal removes the observer. No breathing method, phase duration, stable
ID, audio cue, reward or access rule changes.

This fixes lifecycle continuity of the current visual. It does not implement or
approve the proposed botanical lungs directions, replace the form, or claim
sample-accurate cue synchronization. Those visual-production requirements remain
open, including the three-direction owner review and physical motion assessment.

## Verification

- RED: first resumed frame jumped after a three-second background interval.
- Independent review identified that relying on a rebuild to apply pause can
  miss hidden frames. A stronger no-background-frame test also reproduced the
  same jump. An initial test-binding API type error was corrected before this
  behavioral reproduction; it is not counted as regression evidence.
- Final focused command: `flutter test --no-pub test/reset_lifecycle_test.dart test/reset_ambience_lifecycle_test.dart test/reset_breathing_cue_availability_test.dart`:
  **10 passed**, exit 0. Uses `elapseBlocking` on the automated test binding to
  avoid forcing a background frame, and checks the first resumed frame.
- Follow-up independent review: synchronous stop and revised regression address
  the finding; no further actionable findings.
- Final `flutter analyze`: no issues, exit 0 (20.8 seconds).
- Final `flutter test --no-pub`: **518 passed**, exit 0 (5:14).
- Final `flutter build apk --debug --dart-define-from-file=tool/local/revenuecat-test-store.json`:
  exit 0; Gradle 40.7 seconds. Configuration remains ignored and was not printed.
- Formatting verification: zero changes; `git diff --check` passed.
- `adb devices -l`: exit 0, empty device list. Installation and physical
  lifecycle observation were not performed. Last installed checkpoint remains
  `abb98f7`; the new APK is `build/app/outputs/flutter-apk/app-debug.apk`.

No owner audio approval, purchase, account operation or production action occurred.
Record actual Samsung installation/observations separately from automated tests.
