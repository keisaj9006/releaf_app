# Releaf 1.0 — minimal owner/external input handoff — 14 September 2026

Status: **PRIVACY + PRICING RESOLVED / PROVIDER + SIGNING INPUTS REMAIN**

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

## 3. Google Play developer-account eligibility — ONE FACTUAL CHECK REMAINS

Gmail searches did not provide reliable evidence of the Play developer-account registration date/type. Consumer Google Play receipts are not evidence of a Play Console developer account.

In Play Console, record only:

- account type: **Personal** or **Organisation**;
- developer account creation date / whether Dashboard shows the production-access testing requirement.

If the account is Personal and was created after 13 November 2023, current policy requires the applicable 12-testers / 14-days closed-test eligibility process before applying for Production access. Otherwise do not manufacture that blocker.

## 4. Android production upload signing — PRIVATE OWNER/PROVIDER ACTION

Follow `docs/release/2026-09-14-production-signing-runbook.md`.

First inspect Play Console > Play app signing and determine whether an Upload key certificate already exists.

- Existing certificate + matching private keystore available → use it.
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

## 6. GitHub Actions legal variables — VALUES KNOWN, ENTRY REMAINS

The current production workflow reads these public values from repository Actions variables. Enter exactly:

- `RELEAF_DATA_CONTROLLER_NAME` → `Relief`
- `RELEAF_PRIVACY_CONTACT_EMAIL` → `canius.uk@gmail.com`
- `RELEAF_PRIVACY_POLICY_URL` → `https://releaf-account-deletion-89juqm.v2.appdeploy.ai/privacy-policy.html`
- `RELEAF_ACCOUNT_DELETION_URL` → `https://releaf-account-deletion-89juqm.v2.appdeploy.ai/`
- `RELEAF_PRIVACY_LAST_UPDATED` → `2026-09-14`

These are public metadata, not secrets. No placeholder may be used to force the production AAB workflow through.

## 7. What engineering does immediately after provider/signing configuration exists

1. verify Play account requirement and Play App Signing/upload-key state;
2. verify Play products / RevenueCat entitlement/current Offering/public `goog_` key;
3. verify the known GitHub legal variables are entered;
4. run the manual production-signed AAB workflow;
5. record signed AAB SHA-256;
6. upload the same production-equivalent candidate to the authorized Play test track;
7. complete Store assets from the actual RC (existing Releaf mark for store icon; real RC screenshots; feature graphic);
8. complete Data Safety / Health / Store Listing entries using the live legal URLs and support email;
9. run the one consolidated final Samsung/Play-distributed device matrix, including license-tester purchase/restore and disposable-account deletion;
10. complete applicable closed testing / Production-access process;
11. close the canonical release gate only from observed evidence.

## Release guard

Until all P0 external/device rows close, do **not** state that Releaf 1.0 is release-ready. Do not add optional product features merely because provider/account gates require owner action.