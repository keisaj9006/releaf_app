# Releaf 1.0 RC external-gates checkpoint — 14 September 2026

## Scope

This checkpoint records the verified Releaf 1.0 release-candidate state after RC hardening, public legal-resource preparation and production-release workflow hardening. It does **not** declare the app release-ready. External owner/account configuration, production signing, Play Billing setup, store assets, Play Console submission and the final production-equivalent physical-device matrix remain separate gates.

Verified code checkpoint: `2f3c8d2b5869faf4577790205d880c972551bcfd` on `releaf-development`.
Frozen release version: `1.0.0+20260913`.
Android package: `app.releaf.mobile`.

## Automated evidence on `2f3c8d2`

Flutter P0 Validation run `34820595815`: **SUCCESS**.

The run completed all mandatory steps:

- dependency lockfile verification: PASS;
- bundled sound audit/full decode: PASS;
- Android API/signing/release configuration audit: PASS;
- analyzer: PASS;
- targeted Brain gate: PASS;
- targeted Reset model/hub/access gates: PASS;
- full Flutter suite: **581 tests PASS**;
- Releaf Guide production manifest: exported/uploaded;
- Reset Releaf Guide production manifest: exported/uploaded;
- Reset demo production manifest: exported/uploaded;
- RevenueCat configuration check: completed;
- standard debug APK: built/uploaded;
- Premium Preview debug APK: built/uploaded;
- release AAB smoke artifact: built/uploaded;
- Android 16 KB ZIP/ELF compatibility: PASS.

Artifact evidence from run `34820595815`:

- `releaf-android-debug-standard` — artifact `10338506135`, SHA-256 digest `86cd82495bbd4f5a503a172e6d809ad15c9f74c85b88d046defb5d31055832c5`;
- `releaf-android-debug-premium-preview` — artifact `10338346625`, SHA-256 digest `ab16445135063473730440c525c0a2f9ece002633ebb97f766847970ede332d7`;
- `releaf-android-release-aab-smoke` — artifact `10338232487`, SHA-256 digest `ac14f986a3e99e8a058b3c6078063361a86f1ecb4ed66b00ef972a2d9089bb87`;
- `releaf-guide-production-manifest` — artifact `10337714077`, SHA-256 digest `6f7fef1f55c917bd67b0ce72b1f4c3c1e41ce8b97b6277c31c0e904c07c08866`;
- `releaf-reset-guide-production-manifest` — artifact `10337724067`, SHA-256 digest `cb38fa1792a0e24f39fc0a2cc888b646efe0f27c94accf6d0acdd5b3f49f0a81`;
- `releaf-reset-demo-production-manifest` — artifact `10337579911`, SHA-256 digest `45a15b2d10bf4bf9744bac85953519335f5a03ce233df5b98897ed63cebd46f2`.

Releaf Web Release Smoke run `34820595840`: **SUCCESS**. The Flutter web release and external deletion resource contract build cleanly on the same checkpoint.

## Production Android signing

Production signing is **workflow-ready, not yet release-closed**.

`.github/workflows/android_production_release.yml` is a manual `workflow_dispatch` path that:

- requires `releaf-development` and frozen `1.0.0+20260913`;
- rejects a missing/non-Google RevenueCat Android key and requires a `goog_` public SDK key;
- requires the private Android upload keystore/password/alias through GitHub Actions secrets;
- validates all five production legal metadata values before building;
- materialises signing files only inside the runner;
- builds the production AAB;
- verifies its signature with `jarsigner -verify -strict`;
- records SHA-256;
- uploads the resulting AAB/checksum artifact;
- removes private signing material in the cleanup step.

Required secrets remain external:

- `ANDROID_UPLOAD_KEYSTORE_BASE64`;
- `ANDROID_UPLOAD_STORE_PASSWORD`;
- `ANDROID_UPLOAD_KEY_PASSWORD`;
- `ANDROID_UPLOAD_KEY_ALIAS`;
- `REVENUECAT_ANDROID_API_KEY`.

No private upload key, password or production RevenueCat key is committed to the repository.

## RevenueCat / Google Play Billing

The app-side contract is now locked and documented in `docs/release/revenuecat_google_play_production_setup.md`.

Releaf 1.0 expects:

- entitlement: `premium`;
- the RevenueCat **current** Offering;
- standard Annual and Monthly packages (`current.annual` / `current.monthly`);
- a real Android public SDK key beginning `goog_`;
- Google Play package `app.releaf.mobile`.

Recommended permanent Play structure:

- subscription: `releaf_premium_v1`;
- base plan: `monthly-autorenewing`;
- base plan: `annual-autorenewing`.

The repository does not contain an approved production GBP monthly or annual price. Pricing remains an explicit owner/business decision and must not be invented by engineering.

External closure still requires Play subscription/base-plan activation, RevenueCat Play credentials, product import/entitlement attachment/current Offering, real `goog_` key, and Play-distributed purchase/restore verification.

## Public account deletion

The external account-deletion resource is **LIVE / READY** independently of the Android app.

Verified public resource:

`https://releaf-account-deletion-89juqm.v2.appdeploy.ai/`

AppDeploy application: `releaf-account-deletion-89juqm`.

Verified state on 14 September 2026:

- deployment status: `ready`;
- public HTTPS available;
- frontend errors: none reported;
- network errors: none reported;
- backend errors: none reported;
- QA screenshots available for desktop/web and mobile;
- existing flow signs the user into Releaf Supabase in the browser and invokes the existing authenticated `delete-account` Edge Function;
- no Android app installation is required;
- deletion warns separately about Google Play subscription cancellation.

This closes the **public availability** part of the external Delete Account URL gate. It does **not** replace final DQA-18 on the exact production-equivalent RC.

## Privacy Policy

The code path is **READY / OWNER METADATA + PUBLIC DEPLOY REQUIRED**.

Implemented and contract-tested:

- `tool/release/render_privacy_policy.dart`;
- fail-closed validation through `ReleafLegalConfig.productionProblems`;
- policy coverage for controller/contact, account data, Supabase, RevenueCat/Google Play, local progress, local/transient accelerometer input, lawful basis, recipients, international processing, retention, deletion, rights and Information Commissioner complaint route;
- HTML escaping of injected metadata;
- no placeholder controller/email and no server-only credentials in generated HTML.

The Pages publication path was intentionally tested with missing production metadata. It passed analyzer and **581/581 tests** and then failed exactly at `Validate production legal metadata`; no incomplete Privacy Policy was published.

Required release metadata:

- `RELEAF_DATA_CONTROLLER_NAME` — **OPEN: owner input required**;
- `RELEAF_PRIVACY_CONTACT_EMAIL` — **OPEN: owner input required**;
- `RELEAF_PRIVACY_POLICY_URL` — set after final public Privacy route is deployed;
- `RELEAF_ACCOUNT_DELETION_URL` — known approved live value: `https://releaf-account-deletion-89juqm.v2.appdeploy.ai/`;
- `RELEAF_PRIVACY_LAST_UPDATED` — use the actual publication date.

Preferred final hosting direction is a single Releaf legal host: extend the existing AppDeploy deletion portal with a static public Privacy Policy route after the real controller name/contact email are supplied. This avoids maintaining two competing production legal hosts. GitHub Pages remains a prepared fallback, not evidence of the final production Privacy URL.

## Google Play production-access rule to verify against the account

Google's current Help documentation states that **personal developer accounts created after 13 November 2023** must run a closed test with at least **12 testers opted in continuously for 14 days** before applying for Production access. This requirement is conditional on the actual Play Console account type and creation date; verify those account facts before treating the 12/14 requirement as applicable to Releaf.

## Deliberately still open

This checkpoint does not close:

- real production upload key/secrets and production-signed AAB evidence;
- controller name and privacy contact email;
- live public Privacy Policy;
- approved GBP monthly/annual Premium pricing;
- Play subscription/base-plan activation;
- RevenueCat Google Play connection/product import/current Offering;
- Play-distributed purchase and restore;
- final app icon, feature graphic and current-RC screenshots;
- Google Play Data safety/Health declaration/store listing submission;
- account-specific closed-testing/Production-access requirement;
- final consolidated production-equivalent physical-device matrix;
- final owner listening/content approval where still called out by the canonical gate.

No phone QA was added at this checkpoint; the agreed release discipline remains one consolidated final physical-device run after signing, billing, public legal URLs and the production-equivalent candidate are ready.
