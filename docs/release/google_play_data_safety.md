# Google Play Data Safety — Releaf 1.0

Status: **content mapping prepared; vendor/dashboard verification and Play Console submission required**.

Last reviewed: **2026-09-10**.

This document maps the actual `releaf-development` release surface to Google
Play's Data safety form. It is a release-control worksheet, not evidence that
the form has already been submitted or approved.

The final Play Console answers must describe the sum of the app, its SDKs and
its enabled production integrations. Re-run this audit if telemetry, advertising,
health-data sync, social features, cloud progress sync or a new SDK is enabled.

## Current data-flow inventory

### 1. Supabase account/authentication

When a user chooses to create or use a Releaf account, the app sends account
data to Supabase over the network. The current account implementation uses:

- email address;
- display name;
- Supabase user UUID / account identifier;
- authentication credentials required to perform sign-up/sign-in and recovery.

The app also writes the display name to the authenticated user's `profiles`
record. Account deletion is implemented through an authenticated Supabase Edge
Function.

For the Play taxonomy, the directly applicable selectable data types are:

- **Personal info → Name**;
- **Personal info → Email address**;
- **Personal info → User IDs**.

Purpose: **App functionality** and **Account management** where those options
are offered by Play Console.

These account data types are user-dependent because Releaf has an account path
rather than requiring every user to create an account merely to open the app.
Verify the exact required/optional wording against the final release UX when
completing the live form.

### 2. RevenueCat / Google Play Billing

Releaf uses RevenueCat to resolve Premium entitlements and Google Play Billing
to complete Android purchases. The app identifies a signed-in RevenueCat
customer using the same Supabase user UUID as a custom RevenueCat App User ID.
RevenueCat may otherwise create its own anonymous App User ID.

Declare:

- **Financial info → Purchase history — COLLECTED**.
  - RevenueCat documents this as required when using RevenueCat.
  - Processing is not ephemeral.
  - Purpose: **App functionality** and **Analytics**, matching RevenueCat's
    current Google Play Data Safety guidance.
- **Personal info → User IDs — COLLECTED** because Releaf supplies the signed-in
  Supabase UUID to RevenueCat with `Purchases.logIn(...)` / SDK configuration.

Do **not** currently select **Device or other IDs** solely because RevenueCat is
present. RevenueCat's current guidance makes that selection conditional on
integrations that use advertising/device identifiers (for example advertising
ID integrations). The current Releaf code does not intentionally call a device
identifier collection API. Immediately before submission, verify the production
RevenueCat dashboard has no attribution/advertising integration that changes
this answer.

Do not declare payment-card details as collected by Releaf merely because a
Google Play purchase exists; Releaf/RevenueCat's documented required Financial
Info item for this integration is purchase history.

### 3. Local progress / Leaves

The current Releaf 1.0 release model is local-first. Leaves totals and daily
completion flags are persisted with `SharedPreferences` on the device.
Runtime cloud progress sync remains disabled for 1.0.

Therefore these local progress values are **not declared as collected** while
they remain on-device and are not transmitted off-device. Do not claim cloud
backup.

### 4. Brain / Labyrinth motion input

Labyrinth reads accelerometer events through `sensors_plus` to control the ball.
The current implementation uses those samples in memory for calibration,
movement and collision handling; the motion stream is not sent to Supabase,
RevenueCat or another remote service by that game path.

Therefore raw accelerometer/motion input is **not declared as collected** for
the current release.

### 5. Health and wellness content

Releaf must make a Health apps declaration because the product includes Sleep,
meditation, Reset/mental-wellbeing support and cognitive training. That product
classification does **not** by itself mean that Releaf collects Google Play
**Health and fitness** user data.

The current audited release surface does not transmit sleep measurements,
heart rate, medical records, diagnoses, exercise measurements or other measured
health data off-device. Do not select a Health and fitness data type unless the
release implementation changes.

### 6. Emergency Calm

Emergency Calm is intentionally outside normal progress sync/history and is not
Premium-gated. Do not declare an Emergency state/history data type that the app
does not transmit.

## Proposed Play Console Data Safety answers

These answers are the release worksheet for the current code. Re-check the
exact labels presented by Play Console at submission time.

### Data collection and security

- **Does the app collect or share any required user data types? — YES.**
  Releaf account data and RevenueCat purchase history are transmitted off-device.
- **Is all collected user data encrypted in transit? — YES, subject to final
  production verification.** Supabase/RevenueCat communication is HTTPS and
  RevenueCat states its collected data is encrypted in transit. Do not submit
  this answer until the final production endpoints/SDK configuration have been
  smoke-tested.
- **Can users request deletion of collected data? — YES only after the release
  deletion infrastructure is live and verified.** Code exists for in-app
  deletion, RevenueCat customer erasure and an external web deletion resource;
  the Edge Function secret/deploy and public HTTPS deletion page are still
  release dependencies.

### Data types to declare

| Play data type | Collected | Shared | Required / optional | Main purpose | Release evidence / condition |
| --- | --- | --- | --- | --- | --- |
| Personal info → Name | Yes when account is used | No, assuming Supabase is acting only as Releaf's service provider | Verify against final account UX | App functionality; account management | Supabase auth metadata / `profiles.display_name` |
| Personal info → Email address | Yes when account is used | No, assuming Supabase is acting only as Releaf's service provider | Verify against final account UX | App functionality; account management | Supabase Auth sign-up/sign-in/recovery |
| Personal info → User IDs | Yes | No, assuming Supabase and RevenueCat remain service providers and no non-service-provider integration is enabled | Verify against final account/Premium UX | App functionality; account management | Supabase UUID; custom RevenueCat App User ID |
| Financial info → Purchase history | Yes | No under the current direct RevenueCat service-provider setup; re-check integrations | RevenueCat guidance: required for purchase handling | App functionality; analytics | RevenueCat / Google Play entitlement and purchase history |

### Do not select for the current audited release unless implementation changes

- Location;
- Health and fitness user data;
- Messages;
- Photos or videos;
- Audio files supplied by the user;
- Files and documents;
- Calendar;
- Contacts;
- Web browsing history;
- Search history;
- App activity solely on the basis of RevenueCat;
- Crash logs / diagnostics solely on the basis of RevenueCat;
- Device or other IDs solely on the basis of RevenueCat;
- raw Labyrinth accelerometer readings;
- local-only Leaves/progress values.

This is not a blanket declaration for all future Releaf builds. A new analytics,
crash-reporting, attribution, advertising, social, health-sync or cloud-progress
SDK can change multiple answers.

## Collected vs shared

Google's Data safety definition treats data sent off-device by the app or an SDK
as **collected**. A transfer to a service provider processing data on the
developer's behalf may qualify for Google's exception from **shared**.

For the current architecture, the intended release classification is therefore
**collected but not shared** for the rows above, provided:

1. Supabase is used as Releaf's backend/service provider under the applicable
   agreement and not for an independent third-party purpose;
2. RevenueCat is used to provide Releaf purchase/entitlement functionality;
3. no RevenueCat attribution/advertising or other third-party integration is
   enabled that causes data to be transferred to a non-service-provider;
4. no un-audited SDK is enabled in the production build.

If any of these assumptions is false at submission time, update the form and
this document rather than relying on the current `Shared = No` worksheet.

## Account deletion / retention closure

Current engineering path:

1. user authenticates;
2. Releaf invokes the authenticated `delete-account` Edge Function;
3. the function requests deletion of the matching RevenueCat customer using a
   server-only `REVENUECAT_SECRET_API_KEY`;
4. the function deletes the Supabase auth user so dependent account records can
   be removed according to the database relationships/policies;
5. the app signs out locally.

Before answering the Play deletion question as production-ready, verify all of:

- the updated Edge Function is deployed;
- `REVENUECAT_SECRET_API_KEY` is configured only as an Edge secret;
- deleting an identified RevenueCat customer succeeds end-to-end;
- the public `https://...` account-deletion resource is deployed and usable in
  a normal browser without requiring the Android app to be installed;
- the final Privacy Policy explains retention/deletion accurately;
- any data that must legally be retained is described with the applicable
  retention rationale rather than silently promised as immediate deletion.

## Final submission checklist

1. Build the production-equivalent Android release candidate.
2. Re-audit `pubspec.yaml`, Android manifest and native transitive SDKs for any
   new analytics, advertising, crash, social, health or identifier collection.
3. Verify production RevenueCat integrations and customer attributes; confirm no
   advertising/device-ID integration has been enabled unexpectedly.
4. Verify Supabase production project, Edge Function and deletion secret.
5. Deploy and test the public Privacy Policy and Account Deletion URLs.
6. Confirm local progress still does not upload in Releaf 1.0.
7. Complete Play Console **App content → Data safety** using this worksheet and
   the exact current Play wording.
8. Preview the resulting Data safety section and cross-check it against the
   public Privacy Policy and Store Listing.
9. Record any Play wording/category change back into this file before release.

## Current primary sources

- Google Play — Provide information for the Data safety section:
  https://support.google.com/googleplay/android-developer/answer/10787469?hl=en-GB
- RevenueCat — Google Play's Data Safety:
  https://www.revenuecat.com/docs/platform-resources/google-platform-resources/google-plays-data-safety
- RevenueCat — Customers / App User IDs:
  https://www.revenuecat.com/docs/customers/user-ids

Re-verify these sources immediately before final Play submission because Google
Play and SDK disclosure requirements can change.
