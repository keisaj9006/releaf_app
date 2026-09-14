# Releaf 1.0 RC external-gates checkpoint — 14 September 2026

## Scope

This is the current external-gates register for the frozen Releaf 1.0 app build candidate. It does **not** declare the app release-ready. Repo-side automated hardening is complete; production signing, Play Billing/RevenueCat provider configuration, store assets, Play Console submission and the final production-equivalent physical-device matrix remain separate gates. The public Privacy Policy and account-deletion resources are now live.

Frozen app build candidate: `ecd3e977b55a9f247459f79e2c4ede92303db323` on `releaf-development`.
Frozen release version: `1.0.0+20260913`.
Android package: `app.releaf.mobile`.

`ecd3e97` supersedes `dd20fb5` after a supported-range launcher regression was found in the earlier built APK: API 24–25 would use legacy Flutter-template launcher PNGs while API 26+ used the Releaf adaptive icon. The current candidate fixes the legacy path using the existing Releaf artwork. Evidence-only documentation commits after `ecd3e97` do not redefine the app build candidate.

## Automated evidence

The automated record is:

`docs/release/2026-09-14-ci-ecd3e97.md`

Verified on the exact frozen SHA:

- Flutter P0 Validation run `34834895182`: **SUCCESS**;
- `flutter analyze`: clean;
- full Flutter suite: **583/583 PASS**;
- targeted Brain/Memory, Reset and Relief gates: PASS;
- production manifests: exported/uploaded;
- standard and Premium Preview debug APKs: built/uploaded;
- release AAB smoke: built/uploaded;
- Android 16 KB ZIP/ELF compatibility: PASS;
- Releaf Web Release Smoke run `34834895129`: **SUCCESS** on the same SHA.

Fresh GitHub Actions artifact evidence for the release AAB smoke:

- artifact ID `10343214232`;
- GitHub artifact-ZIP SHA-256 `da6b90145ade640edd78d82a640d159abdbf6dde1f24667f80eef31e803dcb87`.

That smoke artifact uses the short-lived CI signing key. It is not the final Play upload artifact.

The standard debug APK from the same run was inspected directly after build. All five packed legacy `mipmap-*` launcher resources match the approved Releaf raster fingerprints; the xxxhdpi resource is 192×192 with SHA-256 `309fcfcb8515a89ba116fbaa1472ddea189af85410020214deef0bf1dbc52ca9`. This closes the identified automated launcher-branding regression without replacing final physical-device QA.

## Current Google Play policy verification

Policy/runbook guidance was rechecked against current official Google/RevenueCat documentation on **14 September 2026**.

Current release assumptions remain valid:

- new Android mobile apps and updates submitted after 31 August 2026 must target Android 16 / API 36; Releaf does;
- personal Play developer accounts created after 13 November 2023 require at least 12 testers continuously opted in for at least 14 days before applying for Production access; this remains conditional on Releaf's actual account type/creation date;
- apps that allow account creation need both an in-app account-deletion path and an external web deletion resource;
- all published Play apps must complete the Health apps declaration, including closed/open testing and Production tracks;
- current RevenueCat Google Play setup requires Play service credentials and those credentials can take up to 36 hours to validate;
- final billing QA should use designated Play license testers/test payment methods where appropriate, because ordinary users on a testing track can still incur real charges.

Updated release runbooks:

- `docs/release/revenuecat_google_play_production_setup.md`;
- `docs/release/google_play_closed_testing.md`;
- `docs/release/google_play_data_safety.md`;
- `docs/release/google_play_health_declaration.md`;
- `docs/release/google_play_store_listing.md`;
- `docs/release/android_device_release_qa.md`;
- `docs/release/2026-09-14-production-signing-runbook.md`;
- `docs/release/2026-09-14-privacy-policy-deployment.md`.

## Production Android signing

Production signing is **workflow-ready, not release-closed**.

`.github/workflows/android_production_release.yml` remains a manual fail-closed production path that:

- requires `releaf-development` and frozen `1.0.0+20260913`;
- requires the private Android upload keystore/password/alias via GitHub Actions secrets;
- requires a Google RevenueCat public SDK key beginning `goog_`;
- validates all five production legal metadata values;
- materialises signing files only inside the runner;
- builds the release AAB;
- verifies its signature with `jarsigner -verify -strict`;
- records SHA-256;
- uploads the AAB/checksum artifact;
- removes private signing material in cleanup.

Required secrets remain external:

- `ANDROID_UPLOAD_KEYSTORE_BASE64`;
- `ANDROID_UPLOAD_STORE_PASSWORD`;
- `ANDROID_UPLOAD_KEY_PASSWORD`;
- `ANDROID_UPLOAD_KEY_ALIAS`;
- `REVENUECAT_ANDROID_API_KEY`.

The legal metadata values are now known and public, but the current workflow still reads them from GitHub Actions repository variables. Those variables still need to be entered before the production workflow can run:

- `RELEAF_DATA_CONTROLLER_NAME=Relief`
- `RELEAF_PRIVACY_CONTACT_EMAIL=canius.uk@gmail.com`
- `RELEAF_PRIVACY_POLICY_URL=https://releaf-account-deletion-89juqm.v2.appdeploy.ai/privacy-policy.html`
- `RELEAF_ACCOUNT_DELETION_URL=https://releaf-account-deletion-89juqm.v2.appdeploy.ai/`
- `RELEAF_PRIVACY_LAST_UPDATED=2026-09-14`

No private upload key, password or production RevenueCat key is committed to the repository. Follow `docs/release/2026-09-14-production-signing-runbook.md`: check Play App Signing/upload certificate state before generating any new upload key.

## RevenueCat / Google Play Billing

The app-side contract remains locked:

- entitlement: `premium`;
- RevenueCat **current** Offering;
- standard Annual and Monthly packages (`current.annual` / `current.monthly`);
- Android public SDK key beginning `goog_`;
- Google Play package `app.releaf.mobile`.

Recommended permanent Play structure remains:

- subscription: `releaf_premium_v1`;
- base plan: `monthly-autorenewing`;
- base plan: `annual-autorenewing`.

Owner-approved Releaf 1.0 launch pricing:

- monthly UK target price: **£5.99**;
- annual UK target price: **£39.99**;
- free trial / introductory offer: **none for 1.0 by default**.

External closure requires:

1. Play subscription/base-plan creation, prices/regions and activation using the approved UK targets;
2. RevenueCat Google Play service credentials with required permissions;
3. RevenueCat credential validation — allow for up to 36 hours of Google propagation after credential creation/change;
4. import both active base-plan products;
5. attach both to entitlement `premium`;
6. configure the intended Offering as current with standard Annual/Monthly packages;
7. obtain/store the real Android `goog_...` public SDK key outside source control;
8. complete Play-distributed license-tester purchase/restore/account-isolation QA.

See `docs/release/2026-09-14-premium-pricing-recommendation.md` and `docs/release/revenuecat_google_play_production_setup.md`.

## Public account deletion

The external account-deletion resource is **LIVE / READY** independently of the Android app:

`https://releaf-account-deletion-89juqm.v2.appdeploy.ai/`

AppDeploy application: `releaf-account-deletion-89juqm`.

Verified state:

- public HTTPS deployment is live;
- browser flow signs a user into Releaf Supabase directly and invokes the authenticated `delete-account` Edge Function;
- Android installation is not required;
- the page warns separately that deleting the Releaf account does not automatically cancel a Google Play subscription;
- the hardened `delete-account` Edge Function version 4 and server-only RevenueCat erasure secret were previously verified;
- disposable-account in-app deletion E2E already passed against Supabase and RevenueCat;
- the public page now exposes a visible link to the Releaf Privacy Policy.

This closes public availability of the external Delete Account resource. Final DQA-18/DQA-19 must still be repeated/recorded against the production-equivalent RC using disposable accounts only.

## Privacy Policy

The Privacy Policy public-resource gate is **LIVE / METADATA SUPPLIED**.

Public URL:

`https://releaf-account-deletion-89juqm.v2.appdeploy.ai/privacy-policy.html`

Owner-supplied production metadata:

- `RELEAF_DATA_CONTROLLER_NAME=Relief`
- `RELEAF_PRIVACY_CONTACT_EMAIL=canius.uk@gmail.com`
- `RELEAF_PRIVACY_POLICY_URL=https://releaf-account-deletion-89juqm.v2.appdeploy.ai/privacy-policy.html`
- `RELEAF_ACCOUNT_DELETION_URL=https://releaf-account-deletion-89juqm.v2.appdeploy.ai/`
- `RELEAF_PRIVACY_LAST_UPDATED=2026-09-14`

AppDeploy applied source snapshot `1789387063562` and reported deployment status `ready` with no frontend, network or backend errors and fresh desktop/mobile QA screenshots.

The policy covers the current data inventory, purposes/lawful basis, recipients, international processing, retention criteria, deletion, rights and Information Commissioner complaint route. Current ICO guidance requires controller identity/contact information and the other transparency elements reflected in the policy.

Engineering records `Relief` exactly as supplied by the owner. If legal review determines that this is only a product/trading label rather than the true legal controller identity, replace it consistently before release. Engineering must not guess the legal person/entity.

Deployment evidence: `docs/release/2026-09-14-privacy-policy-deployment.md`.

## Health / Data Safety / Store Listing

Current status after policy re-verification:

- **Health declaration:** mapping ready; Play Console submission still required. Releaf maps to Sleep Management; Stress Management, Relaxation, Mental Acuity; and Mental and Behavioral Health. Required non-medical-device disclaimer is present in canonical Store Listing copy.
- **Data Safety:** mapping ready; both the Privacy Policy URL and account-deletion resource are now public. Final RevenueCat integration/provider verification and Play submission remain required.
- **Store Listing:** canonical UK-English copy is aligned with active Reset / Brain / Sleep scope and Emergency Calm. Support/privacy email `canius.uk@gmail.com`, Privacy URL and Account Deletion URL are now known. A separate marketing website remains optional/open. Real Google Play graphic assets are still absent by deliberate sequencing; screenshots must come from the actual release candidate. The store icon should be derived from the existing Releaf launcher mark, not stale Flutter/template artwork.

## Play account eligibility

The exact Releaf Play developer-account type and creation date have **not** been established from reliable evidence. Gmail searches surfaced consumer Google Play receipts only, which are not Play Console registration evidence.

Therefore:

- do not assume the 12-testers/14-days eligibility rule applies;
- check Play Console account type and creation date / Dashboard production-access requirement before scheduling the Production-access clock;
- if it is a personal account created after 13 November 2023, follow the applicable 12/14 closed-testing requirement and apply for Production access after Play reports eligibility.

## Final device QA

`docs/release/android_device_release_qa.md` is aligned with the frozen active 1.0 scope and `ecd3e97` candidate.

Key corrections locked:

- DQA-01 includes installed launcher-brand sanity verification;
- Meditate is PARKED and its unfinished narration does not become a hidden P0 again; DQA-05 verifies parked-route/resume safety rather than requiring final meditation content;
- DQA-13/DQA-14 use authorized Play license-tester test transactions and test payment methods;
- DQA-18/DQA-19 require disposable account deletion evidence;
- DQA-23 retains the V01 lungs / Shoulder Drop / eight-stage Full Body Scan / reduced-motion / enlarged-text final visual pass.

The agreed discipline remains one consolidated final physical-device run after production signing, billing configuration and public legal URLs are ready.

## External inputs/actions still blocking release

The remaining blockers are intentionally narrow:

- enter the five known public legal metadata values as GitHub Actions repository variables;
- private Android upload keystore and signing secrets;
- Play subscription/base-plan creation and activation using approved £5.99 / £39.99 UK pricing;
- RevenueCat Google Play credentials/products/current Offering/real `goog_` key;
- Releaf Play developer-account type and creation date / Dashboard production-access requirement;
- final Play store icon, feature graphic and current-RC screenshots;
- Play Console Data Safety / Health / Store Listing entry;
- applicable closed testing / Production-access process;
- final production-equivalent physical-device matrix;
- final owner listening/content approval where still called out by the canonical release gate;
- legal review of the supplied controller identity if required before public launch.

No optional feature work should be added merely to avoid these external gates. Overall release authority remains `docs/release/releaf_1_0_release_gate.md`.