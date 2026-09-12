# Unguided silent default — 12 September 2026

Branch `releaf-development`, parent `36b3112`.

Both unguided timers now start with ambience disabled. Explicit opt-in remains
available. Pause/resume preserves silence until opt-in, and session-local toggles
do not overwrite the stored guided-session ambience preference. Guided startup
restores that preference. No scripts, breath patterns, timing, audio assets,
narrator, access or rewards changed.

## Verification

- Both player tests reproduced automatic ambience before the fix (RED).
- `dart format` on the three changed Dart files: completed.
- `flutter test --no-pub test/primary_wellbeing_tabs_test.dart`: 37 passed.
- `flutter analyze`: No issues found, exit 0.
- `flutter test --no-pub`: 495 passed, exit 0.
- Independent code review: no actionable findings.
- `flutter build apk --debug --dart-define-from-file=tool/local/revenuecat-test-store.json`:
  PASS, exit 0. Ignored configuration; no key printed. Existing Kotlin warning remains.
- `adb -s R5CX11J26SD install -r build/app/outputs/flutter-apk/app-debug.apk`:
  Success; no uninstall.
- Samsung SM-S928B: launched Home, opened Meditate, started Unguided 5;
  advancing timer displayed `Ambience off`. Explicit toggle displayed `Ambience`.
  Exited the short session. This was UI observation, not human listening approval.
- Boolean-only logs confirmed Purchases.configure completion and no fatal exception.
  The current-offering success marker was not observed in this bounded log sample;
  no new offering verification is claimed.

## Gate impact and next work

Closes the confirmed unguided default-silence implementation gap. Owner listening,
long-duration playback, approved narration and production-equivalent QA remain
open. Next: Reset session blueprints and genuine grounding progression gaps,
preserving every implemented breathing phase and duration.
