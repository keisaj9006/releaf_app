# Subscription result isolation — 12 September 2026

Continues Memory checkpoint `13f6ada` on `releaf-development`.

An old refresh could capture user A's Premium CustomerInfo, wait for offerings,
then restore that entitlement after `beginIdentityChange()` cleared account-bound
state. The regression reproduced false expected / true actual with an in-memory
RevenueCat service.

The identity boundary now invalidates pending async results. Refresh, purchase
and restore success/error handlers check the captured identity version and
controller lifetime before committing state. Disposal invalidates pending work.
Current-account transient-failure behaviour, missing-key reporting, package
ordering, preview mode and stable UUID identity are preserved.

## Verification

- Regression failed before implementation and passed after the guard.
- Focused `subscription_preview_test.dart` and
  `revenuecat_auth_identity_coordinator_test.dart`: 23/23 passed.
- Tests cover stale Premium refresh, old refresh failure, disposed controller
  and fake purchase/restore result callbacks. All services are in-memory fakes;
  no SDK transaction, purchase, restore or account mutation was performed.
- Independent read-only review found no additional scoped issue.
- Both changed Dart files formatted. `flutter analyze --no-pub`: no issues (45.7s).
- `flutter test --no-pub`: 467/467 passed (5:08).
- `flutter build apk --debug --dart-define-from-file=tool/local/revenuecat-test-store.json`: success (assembleDebug 220.1s). APK: `build/app/outputs/flutter-apk/app-debug.apk`.
- ADB recheck: no devices attached; no installation or new device QA performed.

This strengthens account isolation and subscription release reliability. It does
not replace Play-distributed billing QA or approve any production configuration.
Primary Joanna QA data remains untouched. Physical-device availability, owner
listening, long-duration playback and other external release gates remain open.
