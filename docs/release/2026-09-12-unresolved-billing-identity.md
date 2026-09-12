# Unresolved billing identity isolation — 12 September 2026

Branch `releaf-development`, parent `57428cc`.

## Confirmed defect and correction

After Supabase changed from A to B, failed RevenueCat identification could leave
the SDK on A. The old coordinator refreshed that identity on failure. Existing
request epochs rejected pre-transition results, but fresh reads and listener
updates could restore A's Premium while the application displayed B.

The controller now keeps an explicit unresolved-identity gate. Fresh reads,
listener updates, purchase and restore calls cannot grant access or execute
billing while that gate is closed. Only the coordinator's latest successful
identity transition resolves it. Auth requests close access synchronously; queued
or in-flight intermediate successes cannot reopen it for an obsolete target.
Failed identification/logout remains retryable without refreshing old access.

The application retains its coordinator and retries current auth identity before
subscription refresh on resume. Failure presents an account-sync message and
ends loading; reopening/returning to Releaf retries. Password recovery relies on
app-scoped auth synchronization rather than issuing a competing direct SDK login.
Callbacks check mounted before accessing widget ref after asynchronous settlement.

Normal same-account cached entitlement behavior is preserved. This does not
change Premium rules, RevenueCat configuration, purchases, reward semantics,
Emergency access, cloud data or any account. All identity scenarios use fakes.

## Verification

- RED: real controller with fake Premium service regained Premium after the
  identity boundary through a fresh read/listener; expected false, actual true.
- Focused `flutter test --no-pub test/subscription_preview_test.dart test/revenuecat_auth_identity_coordinator_test.dart test/password_recovery_test.dart test/widget_test.dart`:
  38 passed, exit 0. Covers failed switch/retry, blocked billing, latest target,
  failed logout, existing epoch protection, password recovery and app boot.
- An initial command used nonexistent `test/account_recovery_test.dart`; corrected
  to the actual password-recovery test above. No loaded test failed in that run.
- `flutter analyze`: no issues found, exit 0 (10.8 seconds), after correcting the
  new lifecycle conditional's braces.
- Independent review confirmed isolation and requested mounted callback guards;
  follow-up confirmed the fix, with no remaining findings.
- `flutter test --no-pub`: 514 tests passed, exit 0.
- `flutter build apk --debug --dart-define-from-file=tool/local/revenuecat-test-store.json`:
  APK built, exit 0 (Gradle 124.2 seconds).
- Final `dart format --output=none --set-exit-if-changed` on all six changed Dart
  files: 0 changed, exit 0. `git diff --check` passed. Formatting also normalized
  existing layout in the touched files; no password form/visual behavior changed.
- Samsung SM-S928B: `adb -s R5CX11J26SD install -r build/app/outputs/flutter-apk/app-debug.apk`
  returned Success, exit 0. No uninstall.
- Launcher event succeeded; process running. Boolean-only log check confirmed
  Purchases.configure completed and no fatal exception. Current Offering was not
  observed in the bounded sample; no new offering or account-switch device PASS
  is claimed. The failed-account scenarios above were tested with fakes.

Production-equivalent billing QA remains open. No real account was switched,
deleted or purchased against for this verification. Content approval, full
physical-device QA and external release prerequisites remain open.
