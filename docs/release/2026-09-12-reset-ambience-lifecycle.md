# Reset ambience lifecycle — 12 September 2026

Continuation of `1333340` on `releaf-development`.

Delayed Reset ambience could begin after backgrounding, exit or master mute:
the widget combined loading and autoplay, and skipped pause while loading.
Three native-player regression tests reproduced audible starts in these cases.

Reset now reuses the existing guarded Meditation ambience driver. Native
cancellation happens before waiting for voice shutdown or preference writes.
Session request checks protect delayed Sound handoff and distinguish obsolete
loads from current playback. Interrupted preparation reloads on return; already
prepared ambience resumes. Master mute cancels both layers concurrently.

The same ambience file and volume preferences are retained. Narration approval,
silent breathing, Emergency access/privacy, completion and reward rules are
unchanged. The provider seam allows delayed native operations in widget tests;
each session still owns and disposes its player.

## Verification record

- Before fix: all three background/exit/mute regressions failed because
  `sounds/deep_drift.mp3` resumed after cancellation.
- Focused lifecycle, Sound handoff/recovery and Relief access: 46/46 passed.
- Added rapid background/foreground coverage: 4/4 native-delay tests passed;
  only the latest playback starts on return.
- Independent read-only review: no actionable regressions.
- Initial analyzer found two missing-brace style issues; both were corrected.
- Full-suite regression exposed lazy provider access during muted-session disposal; driver initialization moved into initState. Focused rerun: 6/6 passed.
- Final `flutter analyze --no-pub`: no issues (15.0s); Dart formatting clean.
- Final `flutter test --no-pub`: 453/453 passed (3:03).
- Final `flutter build apk --debug --dart-define-from-file=tool/local/revenuecat-test-store.json`: success (assembleDebug 157.0s). Artifact: `build/app/outputs/flutter-apk/app-debug.apk`.

Hardware remains unavailable (`adb devices -l` returned no device in this
continuation). No new installation or physical verification is claimed.
Owner listening, approved audio content and long-duration playback remain open.
This strengthens RESET core lifecycle reliability without closing content or
production-equivalent device gates.
