# Emergency large-text layout

Parent `6c4370d`, branch `releaf-development`.

The existing narrow-phone test covered default text only. Extending it to
200% text at 320x640 reproduced a 1450-pixel bottom overflow. The header title
was squeezed between exit/audio/timer controls and the content could not scroll.

At enlarged text (scaled 17px exceeds 22px), the header controls remain pinned
while the full-width title, illustration and guidance/actions scroll below.
The normal layout is retained. Text is not scaled down or truncated. Emergency
access, session timing, content, completion/reward and privacy behavior are unchanged.

## Verification

- RED: 320x640 normal text passed; 200% text failed with RenderFlex overflow.
- GREEN: both layout cases passed after implementation.
- `flutter test --no-pub test/relief_access_test.dart`: 24 passed, exit 0,
  including advance and pinned exit hit-testing at both text sizes, no
  RevenueCat dependency and no Leaves for Emergency completion.
- `flutter analyze`: no issues, exit 0, 16.1 seconds. Both Dart files formatted.
- `flutter test --no-pub`: 544 passed, exit 0, 4:15.
- `flutter build apk --debug --dart-define-from-file=tool/local/revenuecat-test-store.json`:
  success, exit 0, assembleDebug 80.0 seconds. APK:
  `build/app/outputs/flutter-apk/app-debug.apk`. Configuration remains ignored.
- `git diff --check`: passed. Complete scoped code/test/evidence diff reviewed.
- `adb devices -l`: no connected device; installation and hardware review pending.
- Independent read-only review found no actionable issue: pinned controls,
  scrollable guidance/actions and normal-size behavior are preserved, without
  changes to access, privacy, rewards, timing or audio. Reviewer did not rerun tests.

This is automated layout evidence, not Samsung/TalkBack device approval.
