# Relief 1.0 Release Gate

This file is the canonical engineering/product gate for the first public Google
Play release. Do not expand scope with optional features while a P0 release
gate remains open.

## Release-ready definition

Relief 1.0 is **release-ready** only when every P0 gate below is CLOSED, the
production Android App Bundle passes CI/release QA, and no known issue can
cause data loss, broken account access, broken purchases, unsafe Emergency
behaviour, broken core branding, or a Google Play policy rejection.

When that state is reached, explicitly report:

> Relief 1.0 is release-ready.

## Current gates

Latest complete automated artifact evidence:
[11 October 2026 RC automated checkpoint for `bf53e274`](2026-10-11-rc-automated-checkpoint.md).
Flutter P0 Validation run `38157339295` completed **SUCCESS** with clean analysis,
focused Brain/Reset validation, the full Flutter suite, three production manifests,
standard and Premium Preview debug APKs, release AAB smoke artifact and Android
16 KB compatibility. Relief Web Release Smoke run `38157339291` also completed
**SUCCESS** on the exact same SHA.

`bf53e274136eef2d70c89cc0134be15b7cd7e4dc` supersedes the earlier
`ecd3e977b55a9f247459f79e2c4ede92303db323` pre-Play-upload candidate after
subsequent app-source changes, including the Relief branding correction, approved
editorial-art integration, dedicated per-game Brain artwork for the eight available
approved illustrations, completion of level-50 progression across all 15 registered
Brain games, and attachment of the existing Sleep Stories artwork to the pending
Sleep intake candidate. The September candidate remains historical evidence.
Documentation-only commits after `bf53e274` do not redefine the app build
candidate.

The [14 September external-gates checkpoint](2026-09-14-rc-external-gates.md)
remains the companion record for external configuration state. These automated
results do not close production signing, owner-listening, RevenueCat/Play
configuration, Play Console/store assets or physical-device gates. The public
Privacy Policy and account-deletion resources are now independently live.

RC hardening has frozen the release version at `1.0.0+20260913`, parked Meditate
outside the active 1.0 discovery/marketing surface, aligned Home/Account/Premium
copy with the active Reset / Brain / Sleep pillars, and aligned the canonical
Google Play listing to the same scope. Production release hardening also includes
a fail-closed manual signed-AAB workflow, locked RevenueCat/Google Play contract,
fail-closed Privacy Policy rendering, verified live external account-deletion and
Privacy Policy resources, a production upload-signing runbook and a regression
contract preventing the legacy Flutter launcher from returning. The Meditate module
and direct route are preserved; this scope decision does not certify unfinished
meditation recordings.

| Gate | Status | Notes |
| --- | --- | --- |
| RESET core | DONE / CONTENT + DEVICE QA | Canonical Reset model, completion history, lifecycle and access tests are in CI. V01 dedicated lungs are protected across all ten preserved paced-breathing methods while each canonical BreathPattern remains intact. Shoulder Drop and the eight-stage Full Body Scan are implemented with reduced-motion and narrow/large-text coverage. Rejected breathing tones are excluded from runtime playback; cue controls disclose unavailable audio while silent/reduced-motion phase guidance remains usable. Purpose-first discovery now separates Breathing methods, situational calm and body/mind practices while retaining free Emergency access ([evidence](2026-09-30-reset-purpose-discovery.md)). Manual session pause/resume now holds the existing clock and audio across app lifecycle, with 320 dp/200% text coverage ([evidence](2026-09-30-reset-manual-pause.md)). Final human audio/content approval and DQA-23 remain open. |
| BRAIN core | DONE / AUTOMATED + DEVICE QA OPEN | Canonical Brain flow is implemented and all 15 registered games now support persistent progression through level 50. The final legacy profiles for Pattern Logic, Symbol Code, Broken Mirror, Mental Rotation, Math Race, Trail Switch and Tower Plan were completed on 11 October 2026 while preserving existing levels 1–12, stored completion counts, rewards and result flow. Eight existing approved illustrations are now bundled and mapped one-to-one to Memory, Labyrinth, Broken Mirror, Pattern Logic, Sequence Echo, Signal Scan, Trail Switch and Tower Plan; games without a dedicated approved bitmap keep distinct procedural artwork rather than reusing another game's image. Current automated evidence is candidate `bf53e274136eef2d70c89cc0134be15b7cd7e4dc`: Flutter P0 Validation run `38157339295` and Relief Web Release Smoke run `38157339291` both completed **SUCCESS**, including focused Brain tests, the full Flutter suite, standard/Premium Preview APKs, release AAB smoke and 16 KB compatibility ([Brain evidence](2026-10-11-brain-fifty-levels.md), [RC checkpoint](2026-10-11-rc-automated-checkpoint.md)). Final physical accelerometer and production-equivalent device QA remain open; do not add games merely to increase scope. |
| Sleep player/timer | IN PROGRESS / CONTENT + PHYSICAL QA | Existing looping Sound playback/timer behaviour remains tested, including delayed-start cancellation, media-notification intent and volume restoration after interrupted expiry. The canonical Stories / Nature / Meditations / Sleep Music registry, local long-form progress, finite playback and parameterized Story player are implemented on the existing AudioService path. Discovery now leads with one Continue/Tonight action and four category gateways ([UI evidence](2026-09-29-sleep-discovery-simplification.md)). Candidate content now has a fail-closed local intake gate; `ST-DC-004` remains unpromoted; the existing Sleep Stories artwork is attached, while audio, measured duration/access decision, narrator provenance, rights/licence evidence and owner approval remain pending ([intake evidence](2026-09-29-sleep-content-intake.md)). Approved production Story assets and physical background/interruption/long-duration QA remain open. Nature and Sleep Music stay narration-free; Stories and guided Sleep Meditations may use approved narration. |
| Meditate module | PARKED / NON-BLOCKING FOR ACTIVE 1.0 SURFACE | Player, route and scripted content remain in the codebase, but Meditate is not an active Relief 1.0 pillar and must not be auto-discovered from Home or promoted through Premium/Store Listing while its content remains incomplete. An explicitly started/active session may still resume. Final narration/content work is deferred from the critical 1.0 release path unless this scope decision is intentionally reopened. |
| Account auth | DONE / QA | Sign-up, sign-in, confirmation resend, password recovery, profile update and sign-out are implemented. Final production-equivalent device QA remains open. |
| Account deletion | DONE / E2E VERIFIED | Hardened `delete-account` version 4 is ACTIVE with JWT verification. A Samsung SM-S928B Test Store debug run authenticated a dedicated disposable account, identified the same UUID in RevenueCat, completed in-app deletion, then verified zero target Auth/profile/progress/Storage records and `Customer not found` in RevenueCat. A protected primary QA account was explicitly excluded. See [deployment evidence](2026-09-11-delete-account-deployment.md). Repeat DQA-18 on the production-equivalent RC as part of the full device matrix. |
| Emergency privacy/access | DONE | No Premium gate; excluded from standard progress sync and DB-enforced exclusion is present. |
| Progress sync | DEFERRED / HARDENED | Local progress remains the user-facing truth for 1.0. Upload/download/reconciliation primitives remain inactive until materialization + multi-device conflict tests are complete. Do not claim cloud backup. |
| Supabase security | DONE / MONITOR | RLS is enabled on product tables and current Supabase security advisor reports no lints. |
| Android API level | DONE | Release baseline explicitly targets Android 16 / API 36 and candidate `bf53e274` passes release-AAB smoke plus the Android 16 KB ZIP/ELF compatibility gate in Flutter P0 Validation run `38157339295`. Supported legacy launcher resources for API 24–25 remain Relief-branded and regression-tested. |
| Android release signing | WORKFLOW READY / PRIVATE SECRETS REQUIRED | Debug signing is forbidden for release. `.github/workflows/android_production_release.yml` is a manual fail-closed path requiring the private upload keystore/password/alias, a real `goog_` RevenueCat Android public key and validated production legal metadata. It verifies the signed AAB with `jarsigner`, records SHA-256 and removes runner signing material. The five public legal metadata values are already pinned in the production workflow environment and validated by the legal metadata policy; no separate GitHub Actions variable setup is currently required for them. `docs/release/2026-09-14-production-signing-runbook.md` requires checking the existing Play App Signing/upload certificate before generating a new upload key. Final closure requires the real private production upload key/secrets and successful production-signed AAB evidence. |
| Release AAB | CI SMOKE DONE / PROD SIGNING REQUIRED | Candidate `bf53e274` builds/uploads the release AAB smoke artifact and passes the 16 KB compatibility gate in run `38157339295`. The current smoke AAB GitHub artifact is `11709032113`. The local and GitHub production paths remain fail-closed against the measured release size budgets; see [size-budget evidence](2026-09-24-release-size-budgets.md). The smoke artifact uses CI signing and is not the Play upload artifact. Final Play artifact still requires the production signing workflow and private upload key. |
| RevenueCat / Google Play Billing | ENGINEERING + PRICING LOCKED / EXTERNAL CONFIG REQUIRED | Runtime billing hardening covers entitlement refresh, account-switch isolation, normalized store failures, annual/monthly package gating, restore and subscription management. `docs/release/revenuecat_google_play_production_setup.md` locks entitlement `premium`, current Offering, standard Annual/Monthly packages and real Android `goog_` key. Recommended Play structure is `releaf_premium_v1` with `monthly-autorenewing` and `annual-autorenewing` base plans. Owner-approved UK launch targets are **£5.99 monthly / £39.99 annual**, with no trial/intro offer by default for 1.0. Final closure requires Play products/base plans, RevenueCat Play credentials/import/entitlement/current Offering, the real `goog_` SDK key and license-tester purchase + restore verification from a Play-distributed test build. |
| Privacy policy | LIVE / PLAY ENTRY + FINAL LEGAL REVIEW REQUIRED | Public policy remains live at `https://releaf-account-deletion-89juqm.v2.appdeploy.ai/privacy-policy.html`. On 11 October 2026 the legal host was redeployed with all visible product branding corrected to **Relief**; AppDeploy status is `ready`, source audit reports zero `Releaf`/`RELEAF` matches, and QA reports zero frontend/network/backend errors with fresh web/mobile screenshots ([evidence](2026-10-11-public-legal-branding.md)). Controller name remains `Relief`, privacy contact `canius.uk@gmail.com`, and the established policy date remains `2026-09-14` because the update was branding-only rather than a change to processing practices. Final Play Console entry and legal review remain required. |
| Web account-deletion URL | LIVE / FINAL RC QA REQUIRED | The public deletion portal remains live at `https://releaf-account-deletion-89juqm.v2.appdeploy.ai/`. On 11 October 2026 the same existing URL was redeployed without changing Supabase authentication or the `delete-account` function; all visible branding now says **Relief**. AppDeploy status is `ready`, the published source contains zero stale `Releaf`/`RELEAF` references, and fresh QA reports no frontend/network/backend errors ([evidence](2026-10-11-public-legal-branding.md)). Final DQA-18/DQA-19 on the production-equivalent RC and Play Console entry remain required. |
| Google Play health declaration | CONTENT READY / PLAY CONSOLE SUBMISSION REQUIRED | Release mapping is documented in `docs/release/google_play_health_declaration.md`: Sleep Management; Stress Management, Relaxation, Mental Acuity; and Mental and Behavioral Health. In-app health-safety copy is protected by tests. Closure still requires completing and submitting the declaration in Play Console and keeping the final Store Listing aligned. |
| Store listing | COPY + LEGAL CONTACTS + APP ICON READY / REMAINING ASSETS + PLAY ENTRY REQUIRED | Canonical UK-English copy markets only the active Reset / Brain / Sleep 1.0 surface, with Emergency Calm and local-first progress described accurately. Support/privacy email `canius.uk@gmail.com`, public Privacy URL and public Account Deletion URL are known. The 512 × 512 RGBA Play icon is a measured derivative of the existing Relief launcher mark with pinned source/output hashes; see [icon evidence](2026-09-24-play-store-icon.md). `tool/release/play_store_asset_policy.dart` is contract-tested, and `tool/build_play_release.ps1` enforces the `--strong-listing` asset gate before a production Play build can continue. Final closure requires current RC screenshots, the feature graphic, optional/stable website if used, owner review and Play Console entry/preview. |
| Google Play Data safety | CONTENT + PUBLIC LEGAL URLS READY / VERIFY + PLAY SUBMISSION REQUIRED | Canonical release mapping is documented and contract-tested in `docs/release/google_play_data_safety.md`. Local-only progress/Emergency/sensor data are excluded from collection; Supabase account data and RevenueCat user ID/purchase history are mapped. Both public Privacy and Delete Account URLs are live. Before submission, verify RevenueCat dashboard integrations/provider terms and production transport behaviour, then enter the answers in Play Console. |
| Versioning | FROZEN / RC | Relief 1.0 remains frozen at `1.0.0+20260913` for the current pre-Play-upload candidate. `bf53e274136eef2d70c89cc0134be15b7cd7e4dc` is the current app build candidate and supersedes `ecd3e97`; no production-signed/Play-used artifact has been recorded for the superseded SHA. Any artifact-affecting fix after a production-signed or Play-used build must use a unique higher versionCode/build number while keeping marketing version `1.0.0`, unless an intentional product-version decision is made. |
| Device release QA | AUTOMATION READY / FINAL PHYSICAL RUN REQUIRED | CI protects core lifecycle, audio, auth/deep-link, billing identity, deletion, policy, Brain personal-best, Reset pilot and legacy launcher branding contracts. The production-equivalent physical-device matrix is defined in `docs/release/android_device_release_qa.md`; DQA-01 includes installed launcher sanity, and DQA-23 consolidates V01 lungs, Shoulder Drop, eight-stage Full Body Scan, reduced motion and enlarged-text verification into the final device pass. By release-plan decision, this is one consolidated final phone run after signing, billing, public legal URLs and the production-equivalent candidate are ready; do not fragment it into earlier ad-hoc device passes. Closure requires the exact RC build to pass every mandatory row with evidence, including Play-distributed purchase/restore and deployed account-deletion flows. |
| Play closed testing | PLAN READY / ACCOUNT CHECK + PLAY RUN REQUIRED | Account-specific requirements and the test/feedback/Production-access process are defined in `docs/release/google_play_closed_testing.md`. Current Google Help documentation requires a personal developer account created after 13 November 2023 to run a closed test with at least 12 testers opted in continuously for 14 days before applying for Production access. Gmail searches did not provide reliable Play Console registration evidence, so first verify the actual account type and creation date / Dashboard requirement; apply the 12/14 rule only if those conditions match. The final run must use a production-equivalent candidate and feed the Device Release QA evidence. |

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
content approvals, credentials, production signing, store actions or
production-equivalent physical-device gates. See the batch evidence for the
internal completion record. Subsequent account-deletion deployment replaced the
outdated live version 3 with reviewed version 4; secret presence and
unauthorized-request rejection are verified. Disposable-account E2E has since
passed; the final production-equivalent device matrix remains open.
The same read-only audit returned zero Supabase security-advisor lints.
Automated results do not close production-signing, content, external or device gates.

Owner-approved [five-destination navigation](2026-09-12-five-primary-destinations.md)
passed 482 tests, clean analysis, Android debug build and non-destructive Samsung
installation with bounded UI smoke. Premium refresh continuity and large-text
layout fixes improve reliability; production transaction QA, owner listening and
the full release-device matrix remain open.

The latest complete automated release evidence is now
[the 11 October `bf53e274` RC automated checkpoint](2026-10-11-rc-automated-checkpoint.md).
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
6. Do not put narration in Nature or Sleep Music. Stories and guided Sleep
   Meditations may use only their approved narration; never substitute a voice.
7. Do not replace the approved Relief Guide voice with a guessed substitute.
8. Emergency remains available without Premium and outside normal sync/history.
9. Keep health/store claims aligned with the declared release surface and do not
   make unsupported diagnosis, treatment, cure or prevention claims.
10. Do not reintroduce parked Meditate into Home, Premium or Store Listing for 1.0
    unless the release scope is intentionally reopened and its content gate is closed.
11. A P0 regression reopens the corresponding gate even if it was previously DONE.
12. A framework/template launcher or store icon is a release-blocking branding regression.
