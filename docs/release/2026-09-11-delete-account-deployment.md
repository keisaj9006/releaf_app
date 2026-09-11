# Account-deletion deployment evidence — 2026-09-11

Repository: `C:\Users\joann\Releaf-Codex`, branch `releaf-development`.
Reviewed source HEAD: `c5156e6277e2ba528d4d52698ff5d47d5c4da3ed`.
Initial working tree clean; `git diff --check` passed. No application or function
source changed in this deployment batch. No other branch was modified.

## Secret and security review

The authenticated Supabase Edge Function Secrets page for project
`mgajdbdzflspypxhgmaw` listed `REVENUECAT_SECRET_API_KEY`. Only presence was
verified; its value was never revealed, retrieved, downloaded or committed.
The owner reports an API v1 key; actual provider authorization remains an E2E check.

Reviewed `supabase/functions/delete-account/index.ts`:

- `auth.getUser()` authenticates the requesting user before any deletion.
- The authenticated UUID, not request-body input, selects the customer.
  Flutter's RevenueCat identity coordinator uses the Supabase user ID.
- The server-only environment credential authorizes an encoded
  `DELETE https://api.revenuecat.com/v1/subscribers/{app_user_id}` request.
- 200 and 404 are accepted as retry-safe outcomes. Missing configuration,
  other provider statuses and network errors prevent Supabase deletion.
- Supabase admin deletion occurs only after RevenueCat accepts the erasure
  request. Supabase failure can be retried after provider cleanup.
- No secret is returned to Flutter or directly logged; provider response bodies
  and authorization headers are not logged.

[RevenueCat API v1](https://www.revenuecat.com/docs/api-v1/customers) documents
asynchronous erasure and retry-safe 200/404 handling. Acceptance is not proof
of eventual erasure. Cross-provider deletion is not an atomic transaction.

## Automated checks before deployment

From the repository, using `C:/development/flutter/bin/flutter.bat`:

```powershell
flutter test --no-pub --reporter expanded test/account_deletion_provider_erasure_contract_test.dart test/account_deletion_web_resource_test.dart test/device_release_qa_contract_test.dart test/google_play_store_listing_contract_test.dart test/google_play_data_safety_contract_test.dart test/health_compliance_contract_test.dart test/revenuecat_release_key_policy_test.dart test/account_screen_test.dart test/revenuecat_auth_identity_coordinator_test.dart
flutter analyze --no-pub
git diff --check
```

Results: **25 tests passed, exit 0**; analyzer **No issues found, exit 0**;
diff check **exit 0**. The provider-erasure test is a source contract, not a live
RevenueCat deletion test. Full Flutter suite and Android/web builds were not
repeated because this batch deploys unchanged server source and updates evidence.

After evidence updates, the affected contracts were rerun:

```powershell
flutter test --no-pub --reporter expanded test/device_release_qa_contract_test.dart test/account_deletion_provider_erasure_contract_test.dart test/account_deletion_web_resource_test.dart
```

Result: **4 tests passed, exit 0**; final `git diff --check` passed.

## Deployment and live smoke

Supabase connector `deploy_edge_function` deployed only `delete-account` to
`mgajdbdzflspypxhgmaw`, entrypoint `index.ts`, one file containing the reviewed
repository source, `verify_jwt: true`. No migrations or other functions deployed.

Result: **ACTIVE, version 4**, replacing version 3 (which still lacked provider
cleanup). `get_edge_function` independently returned version 4 with JWT verification
enabled; deployed source matched repository source after newline normalization.

Commands executed against the new deployment:

```powershell
curl.exe --silent --show-error --max-time 30 --request POST --header 'Content-Type: application/json' --data '{}' --write-out '\nHTTP %{http_code}\n' 'https://mgajdbdzflspypxhgmaw.supabase.co/functions/v1/delete-account'
curl.exe --silent --show-error --max-time 30 --request POST --header 'Content-Type: application/json' --header 'Authorization: malformed' --data '{}' --write-out '\nHTTP %{http_code}\n' 'https://mgajdbdzflspypxhgmaw.supabase.co/functions/v1/delete-account'
curl.exe --silent --show-error --max-time 30 --request POST --header 'Content-Type: application/json' --header 'Authorization: Bearer invalid-smoke-test-token' --data '{}' --write-out '\nHTTP %{http_code}\n' 'https://mgajdbdzflspypxhgmaw.supabase.co/functions/v1/delete-account'
```

| Request | Result |
| --- | --- |
| No authorization | 401, `UNAUTHORIZED_NO_AUTH_HEADER` |
| Malformed authorization | 401, `UNAUTHORIZED_INVALID_JWT_FORMAT` |
| Invalid bearer token | 401, `UNAUTHORIZED_INVALID_JWT_FORMAT` |

Curl completed with exit 0. These are gateway rejection checks, not authenticated
handler execution. No valid user token was used, no real account was deleted and
no subscription was created.

## Disposable-account E2E — completed

On Samsung SM-S928B, a dedicated confirmed disposable account was signed into
the Test Store debug APK. Safe diagnostics showed `Purchases.logIn` using the
same UUID as Supabase. The owner then authorized and completed the in-app
account-deletion flow. No purchase was performed.

Pre-deletion inventory: one `auth.users` row, one email identity, one active
session, one `profiles` row, zero `progress_events` rows and zero Storage
objects. The protected primary QA account was explicitly excluded.

Post-deletion SQL checks returned zero for the disposable account's Auth user,
identity, session, profile, progress-event and Storage-object counts; the
protected primary QA Auth user and profile both remained present. The RevenueCat
dashboard direct customer page reported **Customer not found** for the disposable
UUID. The verification did not call a get-or-create RevenueCat endpoint.

Account deletion is **DONE / E2E VERIFIED** for the deployed Test Store path.
Repeat DQA-18 on the final production-equivalent RC as part of the complete
device matrix.

This deployment does not close device QA, public deletion URL, signing, Play,
privacy or content gates. Releaf 1.0 is not yet release-ready.
