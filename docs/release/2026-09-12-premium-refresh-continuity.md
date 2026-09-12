# Premium refresh continuity — 12 September 2026

Branch: `releaf-development`; parent checkpoint `503edb8`.

## Verified defects and changes

CustomerInfo previously waited for offerings before updating access. A delayed
offerings response could also reapply older CustomerInfo after a newer SDK event.
Refresh now applies the current entitlement immediately and rejects superseded
responses. Purchase/restore results invalidate older CustomerInfo snapshots.

Meditation, Reset and Sound gates previously replaced an already entitled player
with a loading screen during refresh, disposing its state. They now preserve the
same player instance while Premium is known. Identity changes still immediately
clear access. No billing entitlement, content policy or breathing method changed.

## Verification

- Original five regressions reproduced before the implementation: two controller
  ordering failures and three real gate/player retention failures.
- `flutter test --no-pub test/subscription_preview_test.dart
  test/premium_gate_refresh_test.dart test/relief_access_test.dart
  test/meditation_premium_preview_test.dart`: **49 passed**, exit 0.
- Added two further regressions for delayed CustomerInfo after a newer listener
  event, covering both grant and revocation.
- `dart format` on the six changed Dart files: completed. Analysis initially
  reported five missing-brace lints; these were corrected.
- `flutter analyze`: **No issues found**, exit 0; dependency resolution completed.
- `flutter test --no-pub`: **474 passed**, exit 0.
- `flutter build apk --debug
  --dart-define-from-file=tool/local/revenuecat-test-store.json`: **PASS**, exit 0.
  APK: `build/app/outputs/flutter-apk/app-debug.apk`. Existing ignored configuration
  used; no key printed or added to Git. Build reports a future Kotlin support
  warning for 2.2.20; dependency validation was not bypassed.
- Independent read-only review: no actionable findings; suggested delayed
  CustomerInfo regression coverage was added.

Samsung SM-S928B is connected. Device interaction was deferred when an active
phone call was observed. This checkpoint has no new installation or physical
playback claim. No purchase, restore, account deletion or configuration mutation
was performed. Device installation remains `adb install -r` only.

## Remaining Premium diagnosis and release impact

Package buttons already invoke purchase directly; the active entitlement ID is
`premium`. These code defects are independently reproduced, but do not prove the
cause of the owner's reported purchase issue or verify the live product-to-
entitlement mapping. Transaction QA and production Play billing remain open.
This checkpoint strengthens access/lifecycle reliability without closing any
external release gate. Five-tab navigation is the next approved milestone.
