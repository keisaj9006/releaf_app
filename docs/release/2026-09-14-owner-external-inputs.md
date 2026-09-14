# Releaf 1.0 — minimal owner/external input handoff — 14 September 2026

Status: **PRIVACY + PRICING + PLAY ACCOUNT TYPE RESOLVED / PROVIDER + SIGNING INPUTS REMAIN**

Current app build candidate: `ecd3e977b55a9f247459f79e2c4ede92303db323`  
Version: `1.0.0+20260913`  
Automated evidence: `docs/release/2026-09-14-ci-ecd3e97.md`

This file intentionally contains only values/actions that engineering cannot truthfully invent or perform without the owner/provider account. Do not send passwords, private keystores, service-account JSON or secret API keys through chat.

## 1. Privacy Policy — RESOLVED / LIVE

Owner supplied on 14 September 2026:

- data controller name: `Relief`;
- public privacy/support email: `canius.uk@gmail.com`.

Public resource deployed:

`https://releaf-account-deletion-89juqm.v2.appdeploy.ai/privacy-policy.html`

Production legal metadata:

- `RELEAF_DATA_CONTROLLER_NAME=Relief`
- `RELEAF_PRIVACY_CONTACT_EMAIL=canius.uk@gmail.com`
- `RELEAF_PRIVACY_POLICY_URL=https://releaf-account-deletion-89juqm.v2.appdeploy.ai/privacy-policy.html`
- `RELEAF_ACCOUNT_DELETION_URL=https://releaf-account-deletion-89juqm.v2.appdeploy.ai/`
- `RELEAF_PRIVACY_LAST_UPDATED=2026-09-14`

AppDeploy status after publication: `ready`, no frontend/network/backend errors. Deployment evidence is recorded in `docs/release/2026-09-14-privacy-policy-deployment.md`.

Legal guard: engineering records `Relief` exactly as supplied. If later legal review determines this is only a product/trading label rather than the true legal controller identity, replace the controller consistently before launch rather than guessing silently.

## 2. Premium pricing — RESOLVED / APPROVED

Owner-approved Releaf 1.0 targets:

- monthly: **£5.99**;
- annual: **£39.99**;
- no trial/intro offer by default for 1.0.

Google Play localized store metadata remains the runtime source; do not hardcode displayed prices in the app.

## 3. Google Play developer account — PERSONAL LOCKED

Owner decision on 14 September 2026:

- account type: **Personal**;
- full public Google Play distribution is intended;
- Releaf Android package/application ID: `app.releaf.mobile`;
- no existing Play app, Play App Signing state, upload certificate or production upload key has been identified yet.

For a new Personal developer account created after 13 November 2023, current Google policy requires a closed test with at least 12 testers continuously opted in for at least 14 days before applying for Production access. Because this is a new account flow, plan the release assuming this testing requirement applies unless Play Console explicitly shows otherwise.

Account creation requires the owner to use the intended Google account, accept the developer agreements, pay the one-off registration fee, link/create the personal Google Payments profile, verify identity/contact details, and complete any device/identity verification requested by Google.

Do not create a second Play developer account if the intended Google account unexpectedly reveals an existing developer account during signup; stop and inspect that state first.

## 4. Android production upload signing — PRIVATE OWNER/PROVIDER ACTION

Follow `docs/release/2026-09-14-production-signing-runbook.md`.

Because no existing Releaf Play app/upload certificate has been identified, first create the Play app and inspect the Play App Signing surface before generating the private upload key.

- Existing certificate unexpectedly present + matching private keystore available → use it.
- Existing certificate but private key lost/compromised → request upload-key reset; do not silently create an unrelated key.
- Genuine new setup/reset instruction → generate a new private upload key locally on the owner's trusted machine.

Private values are then stored directly as GitHub Actions secrets, never pasted into chat:

- `ANDROID_UPLOAD_KEYSTORE_BASE64`
- `ANDROID_UPLOAD_STORE_PASSWORD`
- `ANDROID_UPLOAD_KEY_PASSWORD`
- `ANDROID_UPLOAD_KEY_ALIAS`

## 5. RevenueCat / Google Play Billing — PROVIDER-PANEL ACTIONS

Google Play target configuration:

- subscription `releaf_premium_v1`;
- base plan `monthly-autorenewing` at UK target **£5.99**;
- base plan `annual-autorenewing` at UK target **£39.99**;
- no trial/intro offer by default for 1.0;
- app/package `app.releaf.mobile`.

RevenueCat:

- connect the real Google Play app with service credentials;
- allow for Google credential propagation/validation time when newly created or changed;
- import both active base-plan products;
- attach them to entitlement `premium`;
- put them in the intended **current Offering** as the standard Monthly and Annual packages;
- obtain the Android **public SDK key** beginning `goog_`;
- store that key directly as GitHub Actions secret `REVENUECAT_ANDROID_API_KEY`.

Do not put RevenueCat secret/server keys or Google service-account JSON into the mobile SDK-key secret.

## 6. Production legal metadata — EMBEDDED / NO MANUAL GITHUB VARIABLES

The five approved public legal values are now embedded as the production workflow baseline and protected by `production_android_release_workflow_contract_test.dart`.

No manual GitHub Actions variables are required for:

- controller: `Relief`;
- privacy contact: `canius.uk@gmail.com`;
- privacy URL: `https://releaf-account-deletion-89juqm.v2.appdeploy.ai/privacy-policy.html`;
- account deletion URL: `https://releaf-account-deletion-89juqm.v2.appdeploy.ai/`;
- privacy last updated: `2026-09-14`.

Private signing and RevenueCat values remain secrets and are not embedded.

## 7. What engineering does immediately after Play/RevenueCat/signing configuration exists

1. create/verify the Releaf app in Play Console using package `app.releaf.mobile`;
2. inspect Play App Signing/upload-key state;
3. configure the private upload key and GitHub signing secrets;
4. create/activate Play subscription/base plans and connect RevenueCat;
5. verify entitlement/current Offering/public `goog_` key;
6. run the manual production-signed AAB workflow;
7. record signed AAB SHA-256;
8. upload the same production-equivalent candidate to the authorized Play test track;
9. complete Store assets from the actual RC (existing Releaf mark for store icon; real RC screenshots; feature graphic);
10. complete Data Safety / Health / Store Listing entries using the live legal URLs and support email;
11. run the one consolidated final Samsung/Play-distributed device matrix, including license-tester purchase/restore and disposable-account deletion;
12. complete the 12-testers / 14-days closed-testing requirement for the Personal account and apply for Production access;
13. close the canonical release gate only from observed evidence.

## Release guard

Until all P0 external/device rows close, do **not** state that Releaf 1.0 is release-ready. Do not add optional product features merely because provider/account gates require owner action.