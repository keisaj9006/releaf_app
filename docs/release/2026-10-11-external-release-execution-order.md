# Relief 1.0 external release execution order — 11 October 2026

## Purpose

Repo-side P0 engineering is now at the external-gate boundary. App build candidate
`bf53e274136eef2d70c89cc0134be15b7cd7e4dc` has successful automated release
evidence. This checklist defines the order for the remaining external work so that
signing, Play Billing, RevenueCat, store submission and final device QA are not
performed against mismatched builds or incomplete configuration.

## 1. Establish Play account eligibility

In Play Console, record:

- developer account type: personal or organisation;
- account creation date / Dashboard production-access requirement;
- whether Play currently requires the closed-test production-access gate.

Current Google policy (re-verified 11 October 2026) requires personal developer
accounts created after 13 November 2023 to run a closed test with at least 12
testers continuously opted in for 14 days before applying for Production access.
Do not apply this rule to Relief until the actual account state confirms it applies.

## 2. Verify Play App Signing before creating any key

Open the app's Play App Signing management surface and inspect the upload-key
certificate state.

- If a matching upload private key already exists, reuse it.
- If an upload certificate exists but the private key is lost, use Play's upload-key
  reset path; do not silently generate a conflicting key.
- Generate a new upload key only for a genuinely new setup or an explicit reset.

The private keystore and passwords must remain outside Git/source control.

## 3. Configure production signing secrets

The manual workflow requires:

- `ANDROID_UPLOAD_KEYSTORE_BASE64`
- `ANDROID_UPLOAD_STORE_PASSWORD`
- `ANDROID_UPLOAD_KEY_PASSWORD`
- `ANDROID_UPLOAD_KEY_ALIAS`
- `REVENUECAT_ANDROID_API_KEY`

The five public legal metadata fields are already pinned in the production workflow
and validated by the repository legal-metadata policy.

Do not run the production workflow until the RevenueCat Android key is the real
Google public SDK key beginning with `goog_`.

## 4. Configure Google Play subscription products

For Relief Premium, verify/create:

- subscription product: `releaf_premium_v1`
- monthly base plan: `monthly-autorenewing`
- annual base plan: `annual-autorenewing`
- UK monthly launch target: **£5.99**
- UK annual launch target: **£39.99**
- no free trial / introductory offer by default for 1.0.

Activate the intended plans and configure required regions/prices.

## 5. Configure RevenueCat production Google app

For package `app.releaf.mobile`:

1. configure Google Play service credentials;
2. grant only the required Play permissions;
3. upload the service-account credential JSON to RevenueCat;
4. wait for / verify successful credential validation;
5. import the two active Google base-plan products;
6. verify entitlement exactly `premium`;
7. attach monthly and annual products to `premium`;
8. make the intended Offering current;
9. use standard Monthly and Annual package types;
10. obtain the Android public SDK key beginning `goog_`.

RevenueCat documentation re-verified 11 October 2026 still warns that new/changed
Play service credentials can take up to 36 hours to validate.

## 6. Build the production-signed AAB

After steps 2–5 are complete:

- dispatch `.github/workflows/android_production_release.yml` from
  `releaf-development`;
- require analyzer and full tests to pass;
- require legal metadata validation;
- require `jarsigner -verify -strict`;
- require the release size policy;
- record the production AAB SHA-256 and artifact evidence.

The CI smoke AAB is not a substitute for this production-signed artifact.

## 7. Configure Play testing distribution

Upload/use the production-equivalent AAB on the appropriate Play test track.
Configure designated license testers before billing QA so test purchases use
Google Play test instruments rather than unintended real charges.

If the account is subject to the 12-testers/14-days rule, start the qualifying
closed-test clock only after the release/tester setup is correct.

## 8. Complete Play Console declarations and listing

Using the existing canonical repo documents:

- Store Listing copy;
- Privacy Policy URL;
- Account Deletion URL;
- Data Safety mapping;
- Health declaration;
- app icon;
- current-RC screenshots;
- feature graphic.

The icon/copy/legal URLs are prepared. Exact-RC screenshots, feature graphic,
owner review and Play Console entry remain open.

## 9. Run the single consolidated physical-device matrix

Run `docs/release/android_device_release_qa.md` against the production-equivalent
Play-distributed candidate. This includes:

- startup/offline/lifecycle;
- Reset visual/accessibility pilot;
- Sleep background/timer/interruption;
- all critical Brain persistence checks, Labyrinth accelerometer and per-game
  artwork sanity;
- auth/recovery/profile;
- Monthly/Annual test purchase and restore;
- account-switch RevenueCat isolation;
- free Emergency access;
- in-app and public-web account deletion using disposable accounts;
- navigation/destructive-path stress.

Do not fragment these into unrelated early device passes.

## Release-ready condition

Relief 1.0 may be declared release-ready only when the canonical release gate has
all mandatory P0 external/device rows closed. Repository automation alone does not
close production signing, billing/provider configuration, Play submission or
physical QA.
