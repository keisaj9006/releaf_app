# Releaf 1.0 Release Gate

This file is the canonical engineering/product gate for the first public Google
Play release. Do not expand scope with optional features while a P0 release
gate remains open.

## Release-ready definition

Releaf 1.0 is **release-ready** only when every P0 gate below is CLOSED, the
production Android App Bundle passes CI/release QA, and no known issue can
cause data loss, broken account access, broken purchases, unsafe Emergency
behaviour, or a Google Play policy rejection.

When that state is reached, explicitly report:

> Releaf 1.0 is release-ready.

## Current gates

| Gate | Status | Notes |
| --- | --- | --- |
| RESET core | DONE | Canonical Reset model, completion history, lifecycle and access tests are in CI. |
| BRAIN core | DONE / QA | Canonical Brain flow, progression hardening, Labyrinth 50-stage architecture and lifecycle protections are implemented. Continue release QA; do not add games merely to increase scope. |
| Sleep player/timer | DONE / CONTENT | Player/timer behaviour is tested. Final Sleep sound selection is owner-provided; engineering remains responsible for asset QA, looping, metadata and integration. Sleep must not contain narration. |
| Meditation player | DONE / CONTENT | Player and scripted content exist. Final approved Releaf Guide recordings remain a content dependency; do not silently substitute a new narrator identity. |
| Account auth | DONE / QA | Sign-up, sign-in, confirmation resend, password recovery, profile update and sign-out are implemented. |
| Account deletion | CODE READY / EDGE DEPLOY + SECRET REQUIRED | In-app deletion calls authenticated Supabase `delete-account`. The hardened function first requests erasure of the matching RevenueCat customer, then deletes the Supabase auth user so dependent `profiles` / `progress_events` records cascade. RevenueCat erasure uses a server-only `REVENUECAT_SECRET_API_KEY`; no secret belongs in the app or repo. Closure requires configuring that Edge secret, deploying the updated function and verifying deletion end-to-end, including an identified RevenueCat customer. |
| Emergency privacy/access | DONE | No Premium gate; excluded from standard progress sync and DB-enforced exclusion is present. |
| Progress sync | DEFERRED / HARDENED | Local progress remains the user-facing truth for 1.0. Upload/download/reconciliation primitives remain inactive until materialization + multi-device conflict tests are complete. Do not claim cloud backup. |
| Supabase security | DONE / MONITOR | RLS is enabled on product tables and current Supabase security advisor reports no lints. |
| Android API level | DONE | Release baseline explicitly targets Android 16 / API 36 and has passed signed release-AAB CI smoke validation. |
| Android release signing | PREPARED / SECRET REQUIRED | Debug signing is forbidden for release. Production upload keystore must remain private and be configured before store upload. |
| Release AAB | CI DONE / PROD SIGNING REQUIRED | CI builds and validates a signed release AAB, including 16 KB compatibility. Final Play artifact still requires the private production upload key. |
| RevenueCat / Google Play Billing | CODE READY / EXTERNAL CONFIG REQUIRED | Runtime billing hardening covers entitlement refresh, account-switch isolation, normalized store failures, annual/monthly package gating, restore and subscription management. Release tooling rejects missing, Test Store, secret, Apple, wrong-prefix, whitespace and implausibly short RevenueCat keys. Final closure requires the real `goog_` SDK key, active Play products/current RevenueCat Offering and purchase + restore verification from a Play-distributed test build. |
| Privacy policy | BLOCKED | In-app data disclosures and the health-safety notice are present. Final controller/contact details, retention, final legal review and a public HTTPS privacy-policy URL are still required. |
| Web account-deletion URL | CODE READY / PUBLIC DEPLOY REQUIRED | `web/delete-account.html` provides a Releaf-branded external deletion resource and routes users into the secure browser account flow, which uses the existing authenticated deletion path. CI protects the resource contract. Final closure requires deployment at a stable public HTTPS URL, live end-to-end verification and entry of that URL in the Play Console Data safety form. |
| Google Play health declaration | CONTENT READY / PLAY CONSOLE SUBMISSION REQUIRED | Release mapping is documented in `docs/release/google_play_health_declaration.md`: Sleep Management; Stress Management, Relaxation, Mental Acuity; and Mental and Behavioral Health. In-app health-safety copy is protected by tests. Closure still requires completing and submitting the declaration in Play Console and keeping the final Store Listing aligned. |
| Store listing | COPY READY / ASSETS + PLAY ENTRY REQUIRED | Canonical UK-English title, short/full description, Health & Fitness category, compliance lock and screenshot/graphic specification are documented and contract-tested in `docs/release/google_play_store_listing.md`. Final closure requires real support/contact fields, current release screenshots, app icon/feature graphic and entry/preview in Play Console. |
| Google Play Data safety | CONTENT READY / VERIFY + PLAY SUBMISSION REQUIRED | Canonical release mapping is documented and contract-tested in `docs/release/google_play_data_safety.md`. Local-only progress/Emergency/sensor data are excluded from collection; Supabase account data and RevenueCat user ID/purchase history are mapped. Before submission, verify RevenueCat dashboard integrations/provider terms, production transport behaviour and final deletion/public-policy URLs, then enter the answers in Play Console. |
| Versioning | OPEN | Keep pre-release version during development; set final `1.0.0+<build>` only for release candidate. |
| Device release QA | AUTOMATION READY / PHYSICAL DEVICE RUN REQUIRED | CI already protects core lifecycle, audio, auth/deep-link, billing identity, deletion and policy contracts. The production-equivalent physical-device matrix is defined in `docs/release/android_device_release_qa.md`; closure requires the exact RC build to pass every mandatory row with evidence, including Play-distributed purchase/restore and deployed account-deletion flows. |
| Play closed testing | PLAN READY / ACCOUNT CHECK + PLAY RUN REQUIRED | Account-specific requirements and the test/feedback/Production-access process are defined in `docs/release/google_play_closed_testing.md`. Verify the Play Console account type/creation date and Dashboard requirement; if the current Google rule applies, satisfy its continuous tester/duration criterion before applying for Production access. The final run must use a production-equivalent candidate and feed the Device Release QA evidence. |

Latest audit evidence: [11 September 2026 repository audit](2026-09-11-repository-audit.md).
The live `delete-account` version 1 was confirmed to lack the repository's
RevenueCat erasure step; its existing secret/deployment gate remains open.
The same read-only audit returned zero Supabase security-advisor lints.
Automated results do not close production-signing, content, external or device gates.

## Non-blocking after 1.0

These must not delay public release unless a new defect makes them P0:

- runtime bidirectional cloud progress sync;
- additional Brain games beyond the current validated set;
- Leaves cloud sync (requires an immutable reward ledger first);
- optional product expansion not required by the store submission.

## Release discipline

1. Work only on `releaf-development` until the release process is intentionally changed.
2. Never use the debug key for a production artifact.
3. Never commit a private keystore, `key.properties`, service-role secret, or store credential.
4. Do not enable runtime progress sync until materialization and two-device
   conflict tests are green.
5. Do not claim cloud backup while progress is local-only.
6. Do not put narration in Sleep.
7. Do not replace the approved Releaf Guide voice with a guessed substitute.
8. Emergency remains available without Premium and outside normal sync/history.
9. Keep health/store claims aligned with the declared release surface and do not
   make unsupported diagnosis, treatment, cure or prevention claims.
10. A P0 regression reopens the corresponding gate even if it was previously DONE.
