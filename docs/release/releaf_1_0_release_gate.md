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

Latest complete automated artifact evidence:
[14 September 2026 final RC automated evidence for `dd20fb5`](2026-09-14-ci-dd20fb5.md).
Flutter P0 Validation run `34822680105` completed **SUCCESS** with clean analysis,
**582/582 full-suite tests**, all targeted Brain/Reset gates, three production
manifests, standard and Premium Preview debug APKs, release AAB smoke artifact and
Android 16 KB compatibility. Releaf Web Release Smoke run `34822680100` also
completed **SUCCESS** on the exact same SHA. The earlier
[14 September external-gates checkpoint](2026-09-14-rc-external-gates.md) remains
the companion record for external configuration state. Evidence-only documentation
commits after `dd20fb5a3f0f00c9cf4760c22f2ba0d8c034e22e` do not redefine the frozen
build candidate. These automated results do not close production signing,
owner-listening, RevenueCat/Play configuration, public Privacy Policy, Play
Console/store assets or physical-device gates.

RC hardening has frozen the release version at `1.0.0+20260913`, parked Meditate
outside the active 1.0 discovery/marketing surface, aligned Home/Account/Premium
copy with the active Reset / Brain / Sleep pillars, and aligned the canonical
Google Play listing to the same scope. Production release hardening now also
includes a fail-closed manual signed-AAB workflow, locked RevenueCat/Google Play
contract, fail-closed Privacy Policy rendering, and a verified live external
account-deletion portal. The Meditate module and direct route are preserved; this
scope decision does not certify unfinished meditation recordings.

| Gate | Status | Notes |
| --- | --- | --- |
| RESET core | DONE / CONTENT + DEVICE QA | Canonical Reset model, completion history, lifecycle and access tests are in CI. V01 dedicated lungs are protected across all ten preserved paced-breathing methods while each canonical BreathPattern remains intact. Shoulder Drop and the eight-stage Full Body Scan are implemented with reduced-motion and narrow/large-text coverage. Rejected breathing tones are excluded from runtime playback; cue controls disclose unavailable audio while silent/reduced-motion phase guidance remains usable. Final human audio/content approval and DQA-23 remain open. |
| BRAIN core | DONE / QA | Canonical Brain flow is implemented. Memory and Labyrinth both support progression through level 50; Labyrinth higher levels increase maze complexity/precision rather than raw movement speed. Current/max level labels and personal-best persistence/label behaviour are protected by tests. Continue release/device QA; do not add games merely to increase scope. |
| Sleep player/timer | DONE / CONTENT | Player/timer behaviour is tested, including delayed-start cancellation, media-notification intent and volume restoration after interrupted expiry. The ten bundled sound assets are covered by the repository audio audit and documented engineering measurements. Final owner listening/sound selection and physical background/interruption QA remain open. Sleep must not contain narration. |
| Meditate module | PARKED / NON-BLOCKING FOR ACTIVE 1.0 SURFACE | Player, route and scripted content remain in the codebase, but Meditate is not an active Releaf 1.0 pillar and must not be auto-discovered from Home or promoted through Premium/Store Listing while its content remains incomplete. An explicitly started/active session may still resume. Final narration/content work is deferred from the critical 1.0 release path unless this scope decision is intentionally reopened. |
| Account auth | DONE / QA | Sign-up, sign-in, confirmation resend, password recovery, profile update and sign-out are implemented. Final production-equivalent device QA remains open. |
| Account deletion | DONE / E2E VERIFIED | Hardened `delete-account` version 4 is ACTIVE with JWT verification. A Samsung SM-S928B Test Store debug run authenticated a dedicated disposable account, identified the same UUID in RevenueCat, completed in-app deletion, then verified zero target Auth/profile/progress/Storage records and `Customer not found` in RevenueCat. A protected primary QA account was explicitly excluded. See [deployment evidence](2026-09-11-delete-account-deployment.md). Repeat DQA-18 on the production-equivalent RC as part of the full device matrix. |
| Emergency privacy/access | DONE | No Premium gate; excluded from standard progress sync and DB-enforced exclusion is present. |
| Progress sync | DEFERRED / HARDENED | Local progress remains the user-facing truth for 1.0. Upload/download/reconciliation primitives remain inactive until materialization + multi-device conflict tests are complete. Do not claim cloud backup. |
| Supabase security | DONE / MONITOR | RLS is enabled on product tables and current Supabase security advisor reports no lints. |
| Android API level | DONE | Release baseline explicitly targets Android 16 / API 36 and the frozen `dd20fb5` build candidate passes release-AAB smoke plus the Android 16 KB ZIP/ELF compatibility gate. |
| Android release signing | WORKFLOW READY / SECRETS REQUIRED | Debug signing is forbidden for release. `.github/workflows/android_production_release.yml` is a manual fail-closed path requiring the private upload keystore/password/alias, a real `goog_` RevenueCat Android public key and validated production legal metadata. It verifies the signed AAB with `jarsigner`, records SHA-256 and removes runner signing material. Final closure requires the real private production upload key/secrets and successful production-signed AAB evidence. |
| Release AAB | CI SMOKE DONE / PROD SIGNING REQUIRED | `dd20fb5` builds/uploads the release AAB smoke artifact and passes the 16 KB compatibility gate in run `34822680105`. The smoke AAB artifact is `10338829531` with SHA-256 `0a788c6376901466e318d060eb2efcd85bb6d7d35c81de976194fc0f29618808`. This artifact uses the short-lived CI signing key and is not the Play upload artifact. Final Play artifact still requires the production signing workflow and private upload key. |
| RevenueCat / Google Play Billing | ENGINEERING CONTRACT LOCKED / EXTERNAL CONFIG REQUIRED | Runtime billing hardening covers entitlement refresh, account-switch isolation, normalized store failures, annual/monthly package gating, restore and subscription management. `docs/release/revenuecat_google_play_production_setup.md` locks entitlement `premium`, current Offering, standard Annual/Monthly packages and real Android `goog_` key. Recommended Play structure is `releaf_premium_v1` with `monthly-autorenewing` and `annual-autorenewing` base plans. Approved GBP prices remain an owner/business decision. Final closure requires Play products/base plans, RevenueCat Play credentials/import/entitlement/current Offering, the real `goog_` SDK key and purchase + restore verification from a Play-distributed test build. |
| Privacy policy | CODE READY / OWNER METADATA + PUBLIC DEPLOY REQUIRED | In-app disclosures are present and `tool/release/render_privacy_policy.dart` now generates a public policy only after fail-closed validation of controller name, privacy email, Privacy URL, Delete Account URL and last-updated date. The policy covers controller/contact, purposes/lawful basis, Supabase, RevenueCat/Google Play, local progress, local accelerometer use, recipients, international processing, retention, deletion, data-subject rights and Information Commissioner complaints. The current missing owner inputs are the real data-controller name and privacy contact email. Preferred final deployment is a Privacy route on the existing Releaf AppDeploy legal host; no placeholder policy may be published. |
| Web account-deletion URL | LIVE / FINAL RC QA REQUIRED | The public deletion portal is live at `https://releaf-account-deletion-89juqm.v2.appdeploy.ai/` under AppDeploy app `releaf-account-deletion-89juqm`. On 14 September 2026 AppDeploy reports status `ready`, public HTTPS, no frontend/network/backend errors and QA screenshots for web/mobile. The portal authenticates directly against Releaf Supabase and invokes the existing authenticated deletion function without requiring Android installation. Public availability is closed; final DQA-18 on the exact production-equivalent RC and Play Console entry remain required. |
| Google Play health declaration | CONTENT READY / PLAY CONSOLE SUBMISSION REQUIRED | Release mapping is documented in `docs/release/google_play_health_declaration.md`: Sleep Management; Stress Management, Relaxation, Mental Acuity; and Mental and Behavioral Health. In-app health-safety copy is protected by tests. Closure still requires completing and submitting the declaration in Play Console and keeping the final Store Listing aligned. |
| Store listing | COPY ALIGNED / ASSETS + PLAY ENTRY REQUIRED | Canonical UK-English copy markets only the active Reset / Brain / Sleep 1.0 surface, with Emergency Calm and local-first progress described accurately. `tool/release/play_store_asset_policy.dart` is contract-tested, and `tool/build_play_release.ps1` enforces the `--strong-listing` asset gate before a production Play build can continue. The real `store/google-play/` pack is still absent by deliberate release sequencing. Final closure requires real support/contact fields, current release screenshots, final app icon/feature graphic, owner review and Play Console entry/preview. |
| Google Play Data safety | CONTENT READY / VERIFY + PLAY SUBMISSION REQUIRED | Canonical release mapping is documented and contract-tested in `docs/release/google_play_data_safety.md`. Local-only progress/Emergency/sensor data are excluded from collection; Supabase account data and RevenueCat user ID/purchase history are mapped. The external Delete Account URL is now live. Before submission, verify RevenueCat dashboard integrations/provider terms, production transport behaviour and final public Privacy URL, then enter the answers in Play Console. |
| Versioning | FROZEN / RC | Releaf 1.0 is frozen at `1.0.0+20260913` for the current release candidate. If another RC is required, increase only the build number/versionCode while keeping marketing version `1.0.0`, unless an intentional product-version decision is made. |
| Device release QA | AUTOMATION READY / FINAL PHYSICAL RUN REQUIRED | CI protects core lifecycle, audio, auth/deep-link, billing identity, deletion, policy, Brain personal-best and Reset pilot contracts. The production-equivalent physical-device matrix is defined in `docs/release/android_device_release_qa.md`; DQA-23 consolidates V01 lungs, Shoulder Drop, eight-stage Full Body Scan, reduced motion and enlarged-text verification into the final device pass. By release-plan decision, this is one consolidated final phone run after signing, billing, public legal URLs and the production-equivalent candidate are ready; do not fragment it into earlier ad-hoc device passes. Closure requires the exact RC build to pass every mandatory row with evidence, including Play-distributed purchase/restore and deployed account-deletion flows. |
| Play closed testing | PLAN READY / ACCOUNT CHECK + PLAY RUN REQUIRED | Account-specific requirements and the test/feedback/Production-access process are defined in `docs/release/google_play_closed_testing.md`. Current Google Help documentation requires a personal developer account created after 13 November 2023 to run a closed test with at least 12 testers opted in continuously for 14 days before applying for Production access. First verify the actual Play Console account type and creation date; apply the 12/14 rule only if those conditions match. The final run must use a production-equivalent candidate and feed the Device Release QA evidence. |

Latest audit evidence: [11 September 2026 repository audit](2026-09-11-repository-audit.md).
Subsequent implementation: [internal quality batches](2026-09-11-internal-quality-batches.md).
Owner-approved quality programme: [Meditation guidance milestone](2026-09-11-meditation-guidance-quality.md),
383 tests passed, analyzer clean and Android debug APK built. Physical-device QA
was not performed for this milestone.
The following [Reset cue eligibility milestone](2026-09-11-reset-cue-eligibility.md)
passed 386 tests and clean analysis; no recording approval or physical QA is implied.
The [Sound playback milestone](2026-09-11-sound-playback-intent.md) covers delayed
loads and timer/notification races. DQA-04 still requires physical verification.
The [12 September device-review checkpoint](2026-09-12-device-review-checkpoint.md)
passed 447 tests and clean analysis; the debug/Test Store APK was installed with
`adb install -r` on Samsung. Bounded UI smoke passed; this is not the
production-equivalent release QA matrix or owner listening approval.
The internal continuation through `3ddffee` passed 375 tests and clean analysis.
It closes the identified player/collection/difficulty defects, not the remaining
content approvals, credentials, production signing, public resources, store
actions or production-equivalent physical-device gates. See the batch evidence
for the internal completion record. Subsequent account-deletion deployment
replaced the outdated live version 3 with reviewed version 4; secret presence
and unauthorized-request rejection are verified. Disposable-account E2E has since
passed; the final production-equivalent device matrix remains open.
The same read-only audit returned zero Supabase security-advisor lints.
Automated results do not close production-signing, content, external or device gates.

Owner-approved [five-destination navigation](2026-09-12-five-primary-destinations.md)
passed 482 tests, clean analysis, Android debug build and non-destructive Samsung
installation with bounded UI smoke. Premium refresh continuity and large-text
layout fixes improve reliability; production transaction QA, owner listening and
the full release-device matrix remain open.

The latest complete automated release evidence is now
[the 14 September final RC automated checkpoint](2026-09-14-ci-dd20fb5.md).
The [14 September RC external-gates checkpoint](2026-09-14-rc-external-gates.md)
remains the external-state companion record. Together they supersede older CI
artifact checkpoints for the current release decision while preserving the
historical milestones above.

## Non-blocking after 1.0

These must not delay public release unless a new defect makes them P0:

- activating Meditate as a first-class navigation/marketing pillar and completing
  its final narration/content production;
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
10. Do not reintroduce parked Meditate into Home, Premium or Store Listing for 1.0
    unless the release scope is intentionally reopened and its content gate is closed.
11. A P0 regression reopens the corresponding gate even if it was previously DONE.
