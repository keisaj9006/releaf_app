# Google Play Store Listing — Releaf 1.0

Status: **copy + legal contact fields + app icon ready; feature graphic,
screenshots, website and Play Console entry required**.

Last policy verification: **2026-09-14**.

This document is the canonical English (UK) store-listing pack for Releaf 1.0.
It describes only functionality present in the `releaf-development` release
surface and keeps health claims aligned with the Health apps declaration.

## Main listing copy

### App name

<!-- APP_NAME_START -->
Releaf
<!-- APP_NAME_END -->

Character limit: 30. Current length: 6.

### Short description

<!-- SHORT_DESCRIPTION_START -->
Reset stress, train your brain and unwind for sleep with Releaf.
<!-- SHORT_DESCRIPTION_END -->

Character limit: 80. Current length: 64.

### Full description

<!-- FULL_DESCRIPTION_START -->
Releaf brings practical wellbeing tools into one calm, focused space.

Reset
Use short guided regulation exercises for moments of stress, mental overload, rumination, tension and strong emotions. Sessions are designed to be simple to start when you want to settle and refocus.

Brain
Train attention, memory, focus and flexible thinking with cognitive games including Memory Mirror, Labyrinth, Rule Shift, Sequence Echo, Color Conflict, Pattern Logic and Signal Scan.

Sleep
Unwind with sleep-oriented soundscapes, nature sounds and noise, with a timer for bedtime listening. Sleep content does not use narration.

Emergency Calm
Open grounding and calming tools without a Premium gate or account requirement. Emergency Calm is wellbeing support only and is not an emergency-response service. If you are in immediate danger or need urgent medical help, contact your local emergency service.

Progress, your way
Track lightweight progress on your device. For Releaf 1.0, local progress remains the primary source of truth and Releaf does not claim automatic cloud backup.

Premium
Some deeper Reset protocols, advanced Brain training and expanded Sound & Sleep content may require a Releaf Premium subscription. Subscription availability and pricing are shown through Google Play where applicable.

Releaf is a wellness app, not a medical device. It does not diagnose, treat, cure, or prevent any medical condition. For medical advice, diagnosis, or treatment, consult a qualified healthcare professional.
<!-- FULL_DESCRIPTION_END -->

Character limit: 4,000. Keep the final Play Console copy semantically identical to
this approved version unless the Health apps declaration is re-reviewed.

## Category and tags

- Application type: **App**.
- Recommended Google Play category: **Health & Fitness**.
- Tags: choose only tags suggested by Play Console that clearly match the shipped
  experience. Prioritise sleep, stress-management/relaxation and
  cognitive/brain-training concepts when those exact tags are offered. Do not add
  unrelated tags for search reach.

## Required contact and legal fields

Owner-supplied/public values approved on 14 September 2026:

- support / privacy email: **`canius.uk@gmail.com`**;
- public Privacy Policy URL: **`https://releaf-account-deletion-89juqm.v2.appdeploy.ai/privacy-policy.html`**;
- public Account Deletion URL: **`https://releaf-account-deletion-89juqm.v2.appdeploy.ai/`**;
- data-controller name shown in the public policy: **`Relief`**.

Still open:

- website — strongly recommended and should use a stable public HTTPS destination. Do not invent a marketing site solely to fill the field.

The controller/contact values used in Play must match the production Android legal config and public Privacy Policy. If legal review determines that `Relief` is only a product/trading label rather than the true legal controller identity, replace it consistently before release rather than silently diverging between surfaces.

## Graphic asset pack

### Repository contract and automated gate

Final Google Play assets belong at these canonical repository paths:

- `store/google-play/app-icon.png`;
- exactly one of `store/google-play/feature-graphic.png`, `.jpg` or `.jpeg`;
- `store/google-play/screenshots/phone/` for current phone screenshots.

Validate the final pack locally with:

```bash
dart run tool/release/play_store_asset_policy.dart --root . --strong-listing
```

`tool/build_play_release.ps1` runs the same `--strong-listing` policy before a
production Play build proceeds. The release script therefore fails closed when
required store assets are absent or structurally invalid; normal development and
P0 CI do not require the real store pack to exist.

The automated policy verifies file presence, supported formats, dimensions,
required icon alpha and the strong-listing screenshot count/orientation. It does
**not** certify creative quality, owner approval, rights/provenance, screenshot
freshness, truthful visual content or successful Play Console entry. The
canonical app icon is now present as a measured derivative of the existing
Releaf launcher mark. The feature graphic and current RC screenshots remain
absent, so the Store listing release gate remains open. Do not add placeholder
graphics merely to make the validator pass.

### App icon

Required Play asset:
- 512 × 512 px;
- 32-bit PNG with alpha;
- maximum 1,024 KB;
- no ranking, price, Play-category or misleading badges/text.

Use the final Releaf brand mark as a high-resolution Play icon. Do not substitute
an old concept asset if it no longer matches the release app.

### Feature graphic

Required Play asset:
- 1,024 × 500 px;
- JPEG or 24-bit PNG without alpha.

Creative direction: use the Releaf visual language/living-form identity and a calm,
recognisable composition that extends the app icon rather than repeating it at
large scale. Keep the focal visual near the centre. Do not use `#1`, `Best`, price,
discount, medical-treatment claims or Google Play badges.

### Phone screenshots

Google requires at least two screenshots across supported device types. For a
strong phone listing, prepare at least **four portrait screenshots at 1080 × 1920
or higher**. Capture the real release candidate; do not use stale mock-ups.

Recommended first-pass order:
1. **Reset** — Reset Hub / a representative regulation-session entry point.
2. **Brain** — Brain Hub plus a clearly recognisable cognitive-game experience.
3. **Sleep** — the Sleep sound/player surface and timer.
4. **Progress** — only if the captured screen accurately reflects local-first 1.0.
5. **Emergency Calm** — optional; if used, describe it as grounding/wellbeing
   support and never as emergency response or medical treatment.

Screenshot rules for this release:
- show actual in-app experience;
- remove personal notifications/provider information from the status bar;
- no obsolete device frames or third-party trademarks;
- no pricing/ranking claims;
- localise any added overlay text;
- add meaningful alt text in Play Console.

## Suggested screenshot captions

Use captions only if we create stylised screenshot assets. Keep them short and
truthful:

1. `Reset when your mind feels overloaded`
2. `Train focus, memory and flexible thinking`
3. `Unwind with sleep sounds and a timer`
4. `Track lightweight progress on your device`

Do not put the medical-device disclaimer into image graphics; keep it in the full
description and legal surfaces where it remains legible and maintainable.

## Store compliance lock

Before entering this copy in Play Console:

- Health declaration selections must remain aligned with
  `docs/release/google_play_health_declaration.md`.
- Do not describe Releaf as diagnosing, treating, curing or preventing addiction,
  anxiety, depression, insomnia or any other medical condition.
- Do not claim "brain regeneration", clinically proven outcomes, medical monitoring
  or automatic cloud backup unless the shipped product and evidence genuinely
  support those claims and the release gates are re-reviewed.
- Do not use `Best`, `#1`, awards, install/download calls to action, temporary price
  promotions or unrelated competitor names in listing metadata.
- Emergency Calm must not be presented as a replacement for emergency services.
- Sleep must not be described as containing narration.

## Play Console closure checklist

1. Run the strong asset policy against the final `store/google-play/` pack and fix
   every reported structural error.
2. Enter the approved app name, short description and full description.
3. Set category to Health & Fitness and select only clearly relevant available tags.
4. Enter support email `canius.uk@gmail.com` and add a website if/when a suitable stable HTTPS destination exists.
5. Enter the live Privacy Policy URL and Account Deletion URL recorded above.
6. Upload final 512 × 512 app icon and 1,024 × 500 feature graphic.
7. Upload at least four current portrait phone screenshots for the strongest listing
   (minimum two are required to publish the store listing).
8. Add accurate alt text to graphics/screenshots where Play Console offers it.
9. Cross-check the final text against the submitted Health apps declaration.
10. Preview the listing on phone form factor before release.

## Current Google Play sources

- Create and set up your app:
  https://support.google.com/googleplay/android-developer/answer/9859152?hl=en-GB
- Best practices for your store listing:
  https://support.google.com/googleplay/android-developer/answer/13393723?hl=en-GB
- Add preview assets to showcase your app:
  https://support.google.com/googleplay/android-developer/answer/9866151?hl=en-GB
- Choose a category and tags:
  https://support.google.com/googleplay/android-developer/answer/9859673?hl=en
- Health apps declaration:
  https://support.google.com/googleplay/android-developer/answer/14738291?hl=en-GB
- Health Content and Services:
  https://support.google.com/googleplay/android-developer/answer/16679511?hl=en-GB

The approved full description already includes the current Google-required
non-medical-device disclaimer and healthcare-professional reminder for health
apps that are not regulated medical devices.

Google Play requirements can change. Re-verify these sources immediately before
final Play submission.
