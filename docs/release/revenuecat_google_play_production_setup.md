# RevenueCat + Google Play Production Setup — Releaf 1.0

Status: **ENGINEERING CONTRACT LOCKED / EXTERNAL CONFIGURATION OPEN**

Branch: `releaf-development`
Package: `app.releaf.mobile`
Release: `1.0.0+20260913`

Last policy verification: **2026-09-14**.

This document is the production billing source of truth for Releaf 1.0. It does not certify that Google Play Console or RevenueCat has been configured. It defines exactly what the external configuration must provide to the existing app.

## 1. Contract already fixed by the app

Releaf 1.0 expects:

- Android application ID: `app.releaf.mobile`
- RevenueCat Android public SDK key: production Google key beginning with `goog_`
- RevenueCat entitlement identifier: `premium`
- one current RevenueCat Offering
- exactly the supported duration packages exposed to the app:
  - Annual package (`Offering.annual`)
  - Monthly package (`Offering.monthly`)
- no custom/legacy package is allowed to silently replace annual/monthly
- purchase success grants `premium`
- restore success grants `premium`
- account changes must resolve RevenueCat identity before billing can continue

The app intentionally does **not** hardcode a Google Play Product ID or Offering identifier. Store merchandise can therefore be corrected in RevenueCat without another app release, provided the contract above remains intact.

## 2. Recommended Google Play structure

Use one auto-renewing Google Play subscription product for Releaf Premium with two active base plans.

Recommended permanent identifiers:

- Subscription Product ID: `releaf_premium_v1`
- Monthly base plan ID: `monthly-autorenewing`
- Annual base plan ID: `annual-autorenewing`

Expected RevenueCat Google product identifiers after import:

- `releaf_premium_v1:monthly-autorenewing`
- `releaf_premium_v1:annual-autorenewing`

These identifiers are a release recommendation, not evidence that the products already exist in Play Console. Do not create alternate duplicate production SKUs merely to work around an import/configuration error.

Google Play subscription products are containers; the purchasable billing terms live in their base plans. RevenueCat maps newly configured Google subscription products using the `<subscription_id>:<base-plan-id>` form. This structure is therefore intentionally compatible with the current Google Play / RevenueCat model.

## 3. Google Play Console configuration

Before final billing QA:

1. Releaf must exist in Google Play Console with package `app.releaf.mobile`.
2. A valid signed Android artifact must have been uploaded to an appropriate Play track so subscription products and billing testing can be exercised against the real package.
3. Create the `releaf_premium_v1` subscription if it does not already exist.
4. Add the monthly auto-renewing base plan.
5. Add the annual auto-renewing base plan.
6. Set supported countries/regions and prices.
7. Activate both base plans and the subscription.
8. Do not add a free trial or introductory offer to the 1.0 production contract unless it is intentionally approved and separately QA-tested.
9. Prepare the Google accounts used for billing QA as Play **license testers** where test payment methods are required.

### Price decision still required

The repository contains no approved production GBP price. Therefore prices must remain an explicit owner/business decision rather than being invented by engineering.

Record before release:

- Monthly GBP price: `OPEN`
- Annual GBP price: `OPEN`
- Annual saving/positioning: `OPEN`

## 4. RevenueCat production configuration

In the existing Releaf RevenueCat project:

1. Add/verify the Android app for package `app.releaf.mobile`.
2. Create or verify the Google Play service credentials RevenueCat requires to communicate with Google Play on Releaf's behalf.
3. Grant only the store/API permissions required by the current RevenueCat setup guidance and confirm the credential status in RevenueCat rather than assuming that an uploaded JSON key is already usable.
4. Upload the service-account credential JSON to the Releaf Google Play app settings in RevenueCat and save it.
5. Allow for Google propagation: newly created/changed Play service credentials can take **up to 36 hours** to validate. During that propagation window RevenueCat may report invalid Play credentials (including 503/521-class failures). Do not treat that propagation delay as an app-code defect without first re-validating the credentials.
6. When RevenueCat reports the Play credentials as valid, import the two active Google base-plan products.
7. Create or verify entitlement exactly named `premium`.
8. Attach both monthly and annual Google products to `premium`.
9. Create or reuse one Offering intended for Releaf 1.0 and mark it **current**.
10. Add the annual product as the standard **Annual** package type.
11. Add the monthly product as the standard **Monthly** package type.
12. Do not use Custom package types for these two 1.0 subscriptions; the app reads `current.annual` and `current.monthly`.
13. Copy the Android **public SDK key** beginning with `goog_`; never use a RevenueCat secret key in the app or GitHub build.

The Offering identifier itself is intentionally not hardcoded by Releaf. The requirement is that the intended production Offering is the current Offering.

### Credential closure evidence

Before treating RevenueCat Play credentials as CLOSED, record all of:

- RevenueCat dashboard reports the Google Play service credentials as valid;
- required permission checks are green;
- the intended Google products are visible/importable;
- the products are attached to `premium`;
- the intended Offering is current;
- the public Android SDK key used by the RC begins with `goog_`;
- no secret RevenueCat API key appears in the mobile artifact, source or GitHub build definitions.

## 5. GitHub production-build secrets

The manual workflow `.github/workflows/android_production_release.yml` requires these GitHub Actions secrets:

- `ANDROID_UPLOAD_KEYSTORE_BASE64`
- `ANDROID_UPLOAD_STORE_PASSWORD`
- `ANDROID_UPLOAD_KEY_PASSWORD`
- `ANDROID_UPLOAD_KEY_ALIAS`
- `REVENUECAT_ANDROID_API_KEY`

`REVENUECAT_ANDROID_API_KEY` must be the production Google public SDK key and must start with `goog_`.

No keystore, password, `key.properties`, RevenueCat secret key, service-account JSON, or service-role credential may be committed to the repository.

## 6. Required production-equivalent verification

Billing is not CLOSED until a Play-distributed production-equivalent candidate demonstrates all of the following:

- RevenueCat initializes using the real `goog_` key.
- The current Offering loads.
- Exactly the intended Annual and Monthly packages are presented.
- Localized Play prices are displayed from store metadata, not hardcoded copy.
- Monthly purchase succeeds using an authorized Google Play **test purchase** with a license-tester account and Play-provided test payment method.
- Annual purchase succeeds or is separately verified with an appropriate controlled Play test scenario.
- `premium` becomes active after purchase.
- Premium access remains correct after app restart.
- Restore Purchases restores `premium` where applicable.
- Account A → Account B transition does not leak Premium access.
- Cancelled/failed purchase does not grant Premium.
- A declined/test-failure scenario does not grant Premium.
- No real financial purchase is made merely to prove the release gate when an authorized Play test instrument is sufficient.

Google's current Billing guidance recommends license testers and Play Billing Lab for development/QA. License testers receive test payment methods and can exercise accelerated subscription scenarios without real charges. A normal user on a Play testing track may still make a real purchase, so simply being on a closed/internal track is **not** sufficient protection against charges.

When multiple Google accounts are present on the test device, confirm the account shown in the Play purchase dialog. The purchasing account can depend on which account downloaded the app. Record the intended tester account in the QA evidence.

These checks belong in the consolidated final Play/device QA pass; do not fragment them into ad-hoc phone testing before the production-equivalent candidate exists.

## 7. Release blockers that remain external

The following are not satisfied by this document:

- Play Console app/product/base-plan creation and activation
- approved GBP monthly/annual pricing
- RevenueCat Google Play service credentials creation/permissions/upload and successful validation
- import/attachment of the real products
- real production `goog_` public SDK key stored as a GitHub secret
- private Android upload keystore stored as GitHub secrets
- Play-distributed license-tester purchase + restore verification

Until those items are evidenced, the canonical release gate remains `ENGINEERING CONTRACT LOCKED / EXTERNAL CONFIG REQUIRED` for RevenueCat / Google Play Billing.

## References checked for the 2026 release contract

Verified against current official documentation on **14 September 2026**:

- RevenueCat — Google Play Product Setup: subscription products require active base plans and newly configured Google subscription products map using `<subscription_id>:<base-plan-id>`.
- RevenueCat — Google Play Store service credentials: RevenueCat needs Play service credentials; new/changed credentials may take up to 36 hours to become valid and should be confirmed as valid in the dashboard before billing closure.
- RevenueCat — Product Configuration: products attach to entitlements; Offerings group packages; Google subscription imports use subscription + base-plan identifiers.
- RevenueCat — Offerings: standard Annual/Monthly package types are required for the convenience properties used by Releaf.
- Android Developers — Test your Google Play Billing Library integration: use license testers and Play Billing Lab; license testers have Play test payment methods that avoid real charges, while ordinary test-track users can still be charged.

Re-verify these sources immediately before final Play submission because Google Play and RevenueCat configuration requirements can change independently of the app code.
