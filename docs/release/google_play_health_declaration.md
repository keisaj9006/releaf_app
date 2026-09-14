# Google Play Health Apps Declaration — Releaf 1.0

Status: **content mapping ready; Play Console submission required**.

Last policy verification: **2026-09-14**.

This document maps the actual `releaf-development` release surface to Google
Play's Health apps declaration. It is a release-control document, not evidence
that the declaration has already been submitted or approved.

Google currently requires every app published on Google Play to complete the
Health apps declaration, including apps on closed testing, open testing or
production tracks. Releaf also has genuine health/wellness functionality, so the
form must describe those functions rather than selecting the no-health-features
option.

## Declare for Releaf 1.0

### Sleep Management

Releaf has a dedicated Sleep surface with sleep-oriented soundscapes/noise and
a timer. Google defines Sleep Management as apps dedicated to improving/tracking
sleep and explicitly notes that this may include relaxation sounds or guided
exercises to aid sleep.

### Stress Management, Relaxation, Mental Acuity

This is a direct fit for the active Releaf 1.0 surface. Reset provides stress
regulation, grounding, breathing and relaxation practices; Brain provides
cognitive/focus training and brain-training games. The preserved Meditate module
and direct route also remain in the shipped app even though Meditate is parked
outside the active 1.0 discovery/marketing surface.

Google's current category definition explicitly includes stress management,
mindfulness, meditation, cognitive health, brain-training games, relaxation
techniques and wellness coaching programmes.

### Mental and Behavioral Health

Reset contains explicit mental-health-support content for states such as
rumination, panic-like activation, nervous-system activation/shutdown, body
tension and strong emotions. Google defines this category as tools for mental
health support, counselling services and addiction recovery programmes. Releaf
is not a counselling service and does not provide addiction treatment, but the
mental-health-support portion of the category is relevant to the current Reset
content and should be declared transparently.

The current release does **not** contain a dedicated substance-use tracker,
cannabis/THC treatment programme or addiction-recovery protocol. Do not imply
that such functionality exists merely because Google's category examples also
mention addiction recovery programmes.

## Do not declare for the current release unless functionality changes

- **Emergency and First Aid** — Releaf's Emergency Calm access is grounding and
  calming support; it is not first-aid instruction, disaster preparedness or an
  emergency-response service.
- **Activity and Fitness** — the current release surface does not provide an
  active workout/activity-tracking product that warrants this declaration.
- **Medical Device Apps** — Releaf is a wellness app and is not being released
  as a regulated medical device.
- **Diseases and Conditions Management** — Releaf does not diagnose or manage a
  specific acute/chronic disease as a clinical product.
- **Clinical Decision Support / Medication and Treatment Management / Medical
  Reference and Education** — these are not Releaf 1.0 functions.

If product scope changes before submission, repeat the mapping rather than
reusing these answers automatically.

## Required health-safety wording

Google's current Health Content and Services policy requires health/medical apps
that are not regulated medical devices to include a clear disclaimer in the app
description that the app is not a medical device and does not diagnose, treat,
cure or prevent medical conditions, and to remind users to consult a healthcare
professional for medical advice, diagnosis or treatment.

Use this wording in the Google Play app description and keep the equivalent
notice accessible inside Releaf:

> Releaf is a wellness app, not a medical device. It does not diagnose, treat,
> cure, or prevent any medical condition. For medical advice, diagnosis, or
> treatment, consult a qualified healthcare professional.

Do not market Releaf as diagnosing, treating, curing or preventing a medical
condition. Do not make unsupported clinical efficacy claims. Do not let copy in
screenshots, feature graphics or later Store Listing edits contradict the
Health declaration or this disclaimer.

## Play Console closure steps

1. Open Play Console and go to **Policy > App content**, then open **Health apps**
   (follow the exact current Console navigation if Google changes the label).
2. Select the three release categories above.
3. Complete any follow-up questions using the app's actual behaviour and data
   handling; do not infer functionality that is not present.
4. Save and submit the declaration.
5. Confirm the final Store Listing includes the required health-safety wording.
6. Confirm the in-app privacy/safety copy remains consistent with the listing.
7. Re-open this gate if the product gains health-data permissions, clinical
   functionality, activity tracking, external medical hardware, substance-use
   treatment functionality or new medical claims.

## Policy sources

Verified against current official Google Play guidance on **14 September 2026**:

- Google Play — Health apps declaration:
  https://support.google.com/googleplay/android-developer/answer/14738291?hl=en-GB
- Google Play — Health app categories and additional information:
  https://support.google.com/googleplay/android-developer/answer/13996367?hl=en-GB
- Google Play — Health Content and Services:
  https://support.google.com/googleplay/android-developer/answer/16679511?hl=en-GB

Current official guidance confirms that all published apps must complete the
Health apps declaration, and its category examples directly support Releaf's
Sleep Management and Stress Management / Relaxation / Mental Acuity mapping.
The Health Content and Services policy also requires the non-medical-device
health disclaimer and healthcare-professional reminder used above.

Google Play policy can change. Re-verify these sources immediately before the
final Play submission.
