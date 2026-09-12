# Single SDK initialization — 12 September 2026

Branch `releaf-development`, parent `abb98f7`.

The service's initialized flag was only set after native configuration completed.
Two overlapping `init` calls therefore invoked native Purchases configuration
twice. The ordinary startup currently calls once, but the service did not uphold
the required single-configuration guarantee while a call was in flight.

Callers now share the pending initialization Future. The first configuration
retains ownership of key, logging mode and initial user ID. Later account changes
continue through the identity coordinator, not reconfiguration. The pending
Future is cleared after settlement so a failed initialization can be retried;
successful initialization remains idempotent.

## Verification

- RED: mocked native channel observed two `setupPurchases` calls, expected one.
- `flutter test --no-pub test/revenuecat_initialization_test.dart test/widget_test.dart test/subscription_preview_test.dart test/revenuecat_auth_identity_coordinator_test.dart`:
  38 passed, exit 0. Covers delayed concurrent configuration, repeated successful
  initialization, failure then retry, and zero native calls for missing/secret-
  shaped configuration. All keys and identities in these tests are synthetic.
- `flutter analyze`: no issues found, exit 0 (39.7 seconds).
- `flutter test --no-pub`: 517 tests passed, exit 0.
- `flutter build apk --debug --dart-define-from-file=tool/local/revenuecat-test-store.json`:
  built `build/app/outputs/flutter-apk/app-debug.apk`, exit 0 (108.6 seconds).
- Final `dart format --output=none --set-exit-if-changed` on both Dart files:
  0 changed, exit 0. `git diff --check` passed.
- Independent read-only review: no actionable findings.
- No new device installation for this internal concurrency-only change. Last
  installed Samsung milestone remains `abb98f7`; batch installation with the next
  visible/audio/hardware milestone. No new physical-device verification claimed.

No credentials or provider configuration changed. No real purchase, account
switch or deletion was performed. This closes a service concurrency defect, not
production billing verification, owner audio approval or full release readiness.
