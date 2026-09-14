# Releaf 1.0 RC external-gates checkpoint — 14 September 2026

## Scope

This is the current external-gates register for the frozen Releaf 1.0 app build candidate. It does **not** declare the app release-ready. Repo-side automated hardening is complete; owner/account configuration, production signing, Play Billing setup, public Privacy Policy, store assets, Play Console submission and the final production-equivalent physical-device matrix remain separate gates.

Frozen app build candidate: `dd20fb5a3f0f00c9cf4760c22f2ba0d8c034e22e` on `releaf-development`.
Frozen release version: `1.0.0+20260913`.
Android package: `app.releaf.mobile`.

Evidence-only documentation commits after `dd20fb5` do not redefine the app build candidate.

## Automated evidence

The immutable automated record is:

`docs/release/2026-09-14-ci-dd20fb5.md`

Verified on the exact frozen SHA:

- Flutter P0 Validation run `34822680105`: **SUCCESS**;
- `flutter analyze`: clean;
- full Flutter suite: **582/582 PASS**;
- targeted Brain/Memory, Reset and Relief gates: PASS;
- production manifests: exported/uploaded;
- standard and Premium Preview debug APKs: built/uploaded;
- release AAB smoke: built/uploaded;
- Android 16 KB ZIP/ELF compatibility: PASS;
- Releaf Web Release Smoke run `34822680100`: **SUCCESS** on the same SHA.

Release AAB smoke artifact `10338829531` has SHA-256:
`0a788c6376901466e318d060eb2efcd85bb6d7d35c81de976194fc0f29618808`.

That smoke artifact uses the short-lived CI signing key. It is not the final Play upload artifact.

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
- `docs/release/android_device_release_qa.md`.

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

No private upload key, password or production RevenueCat key is committed to the repository.

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

External closure requires:

1. approved GBP monthly/annual price;
2. Play subscription/base-plan creation, prices/regions and activation;
3. RevenueCat Google Play service credentials with required permissions;
4. RevenueCat credential validation — allow for up to 36 hours of Google propagation after credential creation/change;
5. import both active base-plan products;
6. attach both to entitlement `premium`;
7. configure the intended Offering as current with standard Annual/Monthly packages;
8. obtain/store the real Android `goog_...` public SDK key outside source control;
9. complete Play-distributed license-tester purchase/restore/account-isolation QA.

No approved production GBP price was found in the repository or prior Releaf decisions. Pricing remains an owner/business decision rather than something engineering may invent silently.

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
- disposable-account in-app deletion E2E already passed against Supabase and RevenueCat.

This closes public availability of the external Delete Account resource. Final DQA-18/DQA-19 must still be repeated/recorded against the production-equivalent RC using disposable accounts only.

## Privacy Policy

The Privacy Policy engineering path is **READY / TWO OWNER VALUES + PUBLIC DEPLOY REQUIRED**.

The release validator requires exactly:

- `RELEAF_DATA_CONTROLLER_NAME` — **OPEN: real legal controller identity required**;
- `RELEAF_PRIVACY_CONTACT_EMAIL` — **OPEN: real public privacy contact email required**;
- `RELEAF_PRIVACY_POLICY_URL` — will be set to the final public route after deployment;
- `RELEAF_ACCOUNT_DELETION_URL` — known live value: `https://releaf-account-deletion-89juqm.v2.appdeploy.ai/`;
- `RELEAF_PRIVACY_LAST_UPDATED` — use the actual publication date.

No earlier Releaf decision supplied the controller identity or privacy/support email, so they must not be guessed.

`tool/release/render_privacy_policy.dart` already covers the current data inventory, purposes/lawful basis, recipients, international processing, retention criteria, deletion, rights and Information Commissioner complaint route. Current ICO guidance allows retention to be described by criteria where a single fixed period is not available, provided the controller can justify and review retention.

Preferred final hosting remains a single Releaf legal host: extend the existing AppDeploy deletion portal with a public Privacy Policy route after the two real owner values are available. Do not publish a placeholder policy.

## Health / Data Safety / Store Listing

Current status after policy re-verification:

- **Health declaration:** mapping ready; Play Console submission still required. Releaf maps to Sleep Management; Stress Management, Relaxation, Mental Acuity; and Mental and Behavioral Health. Required non-medical-device disclaimer is present in canonical Store Listing copy.
- **Data Safety:** mapping ready; the live account-deletion resource is now recorded as implemented rather than an unresolved dependency. Final RevenueCat integration check, Privacy URL and Play submission remain required.
- **Store Listing:** canonical UK-English copy is aligned with active Reset / Brain / Sleep scope and Emergency Calm. Real Google Play graphic pack is still absent by deliberate sequencing; screenshots must come from the actual release candidate rather than stale mock-ups.

## Play account eligibility

The exact Releaf Play developer-account type and creation date have **not** been supplied in prior project context.

Therefore:

- do not assume the 12-testers/14-days eligibility rule applies;
- check Play Console account type and creation date before scheduling the Production-access clock;
- if it is a personal account created after 13 November 2023, follow the 12/14 closed-testing requirement and apply for Production access after Play reports eligibility.

## Final device QA

`docs/release/android_device_release_qa.md` is aligned with the frozen active 1.0 scope.

Key corrections now locked:

- Meditate is PARKED and its unfinished narration does not become a hidden P0 again; DQA-05 verifies parked-route/resume safety rather than requiring final meditation content;
- DQA-13/DQA-14 use authorized Play license-tester test transactions and test payment methods;
- DQA-18/DQA-19 require disposable account deletion evidence;
- DQA-23 retains the V01 lungs / Shoulder Drop / eight-stage Full Body Scan / reduced-motion / enlarged-text final visual pass.

The agreed discipline remains one consolidated final physical-device run after production signing, billing configuration and public legal URLs are ready.

## External inputs/actions still blocking release

The remaining blockers are now intentionally narrow:

- real data-controller legal identity;
- real privacy/support contact email;
- public Privacy Policy deployment after those values are supplied;
- private Android upload keystore and signing secrets;
- approved monthly/annual GBP Premium pricing;
- Play subscription/base-plan creation and activation;
- RevenueCat Google Play credentials/products/current Offering/real `goog_` key;
- Releaf Play developer-account type and creation date;
- final app icon, feature graphic and current-RC screenshots;
- Play Console Data Safety / Health / Store Listing entry;
- applicable closed testing / Production-access process;
- final production-equivalent physical-device matrix;
- final owner listening/content approval where still called out by the canonical release gate.

No optional feature work should be added merely to avoid these external gates. Overall release authority remains `docs/release/releaf_1_0_release_gate.md`.