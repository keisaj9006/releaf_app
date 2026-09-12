# Runtime RevenueCat SDK key validation — 12 September 2026

Branch `releaf-development`, parent `9c8854e`.

The runtime predicate previously accepted nearly every nonempty string, including
the shape of a server secret, despite describing itself as a public SDK guard.
Production Android tooling already had a stricter gate. Runtime now accepts only
the supported `test_`, `goog_` and `appl_` prefixes, rejects internal whitespace,
and uses the existing release policy's minimum suffix length. Harmless surrounding
whitespace is normalized. This checks shape, not authenticity or store readiness.

No real credential was read, printed, changed or committed. Tests use synthetic
fixtures. Invalid input follows the existing unconfigured state before native SDK
configuration. Test Store remains allowed for development; production Android
continues to require its existing Google-only release validation. Identity,
entitlement, rewards and purchase behavior are unchanged.

## Verification

- RED: the new runtime predicate regression failed (expected false, actual true).
- Focused command: `flutter test --no-pub test/widget_test.dart test/revenuecat_key_policy_test.dart test/revenuecat_release_key_policy_test.dart test/revenuecat_auth_identity_coordinator_test.dart test/subscription_preview_test.dart`:
  38 passed, exit 0.
- Independent read-only review: no actionable findings.
- `flutter analyze`: no issues found, exit 0 (13.7 seconds).
- `flutter test --no-pub`: 510 tests passed, exit 0.
- `flutter build apk --debug --dart-define-from-file=tool/local/revenuecat-test-store.json`:
  Android debug APK built, exit 0 (Gradle 121.3 seconds).
- `dart format --output=none --set-exit-if-changed` on both changed Dart files:
  0 changed, exit 0. `git diff --check` passed.
- Samsung SM-S928B: `adb -s R5CX11J26SD install -r build/app/outputs/flutter-apk/app-debug.apk`
  returned Success, exit 0. Launcher event succeeded. Boolean-only process log
  check confirmed Purchases.configure completed and no fatal exception; current
  Offering was not observed in this bounded sample. No purchase/account operation.

This does not remove a wrongly embedded credential from an existing APK, certify
key validity, grant an entitlement or close Play-distributed purchase/restore QA.
Production signing/configuration, owner audio approval and physical QA remain open.
