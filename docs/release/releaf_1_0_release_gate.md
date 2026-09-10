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
| Account deletion | DONE | In-app deletion calls authenticated Supabase `delete-account`; server function is active and dependent `profiles` / `progress_events` records cascade on auth-user deletion. |
| Emergency privacy/access | DONE | No Premium gate; excluded from standard progress sync and DB-enforced exclusion is present. |
| Progress sync | DEFERRED / HARDENED | Local progress remains the user-facing truth for 1.0. Upload/download/reconciliation primitives remain inactive until materialization + multi-device conflict tests are complete. Do not claim cloud backup. |
| Supabase security | DONE / MONITOR | RLS is enabled on product tables and current Supabase security advisor reports no lints. |
| Android API level | DONE | Release baseline explicitly targets Android 16 / API 36 and has passed signed release-AAB CI smoke validation. |
| Android release signing | PREPARED / SECRET REQUIRED | Debug signing is forbidden for release. Production upload keystore must remain private and be configured before store upload. |
| Release AAB | CI DONE / PROD SIGNING REQUIRED | CI builds and validates a signed release AAB, including 16 KB compatibility. Final Play artifact still requires the private production upload key. |
| RevenueCat / Google Play Billing | CODE READY / EXTERNAL CONFIG REQUIRED | Runtime billing hardening covers entitlement refresh, account-switch isolation, normalized store failures, annual/monthly package gating, restore and subscription management. Release tooling rejects missing, Test Store, secret, Apple, wrong-prefix, whitespace and implausibly short RevenueCat keys. Final closure requires the real `goog_` SDK key, active Play products/current RevenueCat Offering and purchase + restore verification from a Play-distributed test build. |
| Privacy policy | BLOCKED | In-app screen is still explicitly development copy. Final controller/contact details, retention and public HTTPS privacy-policy URL are required. |
| Web account-deletion URL | CODE READY / PUBLIC DEPLOY REQUIRED | `web/delete-account.html` provides a Releaf-branded external deletion resource and routes users into the secure browser account flow, which uses the existing authenticated deletion path. CI protects the resource contract. Final closure requires deployment at a stable public HTTPS URL, live end-to-end verification and entry of that URL in the Play Console Data safety form. |
| Google Play health declaration | OPEN | Complete declaration and keep store claims wellness/recovery-support appropriate; avoid unsupported medical/clinical claims. |
| Store listing | OPEN | Final title/short/full description, screenshots, feature graphic, category, contact details and content declarations. |
| Versioning | OPEN | Keep pre-release version during development; set final `1.0.0+<build>` only for release candidate. |
| Device release QA | OPEN | Test production-equivalent build on supported Android devices, including background/foreground, audio, auth/deep links, purchases, offline behaviour and destructive flows. |
| Play closed testing | OPEN | Complete any tester-duration requirement applicable to the developer account before Production access. |

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
9. A P0 regression reopens the corresponding gate even if it was previously DONE.
