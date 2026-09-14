# Releaf 1.0 — final RC handoff

Status: **automated RC evidence complete; external/production execution pending**.

This checklist continues from the current frozen app build candidate after repo-side RC
hardening. It does not change the current release-gate status and must not be
used to claim that Releaf 1.0 is release-ready.

## Why this is the next boundary

The repo-side automated P0 programme is complete for the current build candidate
`ecd3e977b55a9f247459f79e2c4ede92303db323`. Flutter P0 Validation run
`34834895182` passed clean analysis, **583/583 Flutter tests**, production
manifests, both debug APK variants, release-AAB smoke and Android 16 KB ZIP/ELF
compatibility. Releaf Web Release Smoke run `34834895129` also passed on the
exact same SHA. Immutable evidence is recorded in
`docs/release/2026-09-14-ci-ecd3e97.md`.

`ecd3e97` supersedes the earlier `dd20fb5` candidate after artifact inspection
found that supported Android API 24–25 would use legacy Flutter-template launcher
PNGs instead of the Releaf adaptive brand. The current candidate contains the
existing Releaf launcher artwork in all five legacy density buckets, and the
actual built APK was inspected to verify those packed resources.

The release version remains frozen at `1.0.0+20260913`. No Releaf 1.0 bundle with
this versionCode has yet been accepted as the production Play upload artifact, so
the pre-upload branding correction does not require an artificial version bump.
Evidence-only documentation commits after `ecd3e97` do not redefine the app build
candidate.

What remains is primarily owner/account configuration, production credentials,
public Privacy Policy publication, Play Console state, store assets and the
exact-RC physical/distributed verification. Do not create optional product scope
merely to avoid these external gates.

## Inputs still required before production RC execution

Collect these without committing secrets to the repository:

- final data-controller identity;
- privacy contact/support email;
- final legal review where required;
- stable public HTTPS Privacy Policy URL after publication;
- private Android upload keystore and its passwords/alias;
- real public RevenueCat Google SDK key (`goog_...`), kept outside source control;
- active Google Play subscription products/base plans and the matching current
  RevenueCat Offering/packages;
- approved GBP monthly/annual Premium pricing;
- final owner-approved Sleep/Reset audio selection;
- Play Console access/account information needed to confirm closed-testing rules.

Already satisfied external resource:

- public Releaf account-deletion portal is live at
  `https://releaf-account-deletion-89juqm.v2.appdeploy.ai/`; final DQA-18/DQA-19
  on the exact production-equivalent RC remain required.

Meditate remains parked outside the active 1.0 discovery/marketing surface, so
unfinished meditation narration does not reopen the active 1.0 release path
unless that scope decision is deliberately reversed.

## Final RC sequence

Execute in this order so screenshots, testing and store metadata all refer to the
same candidate family.

1. **Preserve frozen candidate scope**
   - no optional features;
   - keep active primary destinations Home / Reset / Sleep / Brain, with Emergency
     available and Meditate parked/direct-access only;
   - keep Sleep narration-free and Emergency outside Premium;
   - any artifact-affecting code/configuration change after `ecd3e97` creates a
     superseding candidate and requires fresh automated release evidence.

2. **Finalize public legal resources**
   - provide the real controller identity and privacy contact email;
   - render and deploy the Privacy Policy to the approved stable HTTPS Releaf host;
   - use retention wording already grounded in the audited policy unless legal
     review requires a factual change;
   - keep the existing live Releaf account-deletion portal;
   - verify both live URLs and the authenticated deletion route end to end;
   - keep secrets server-side only.

3. **Finalize production billing configuration**
   - approve the monthly/annual GBP launch price or supply replacement values;
   - activate/verify Google Play subscription and monthly/annual base plans;
   - connect/import the products in RevenueCat;
   - attach them to entitlement `premium` and the current Offering using the
     expected Annual/Monthly packages;
   - configure and verify the real Android `goog_` SDK key;
   - do not perform a real-money purchase outside an intentionally authorized
     scenario; use Play license-tester test instruments for the release-gate flow.

4. **Finalize the Google Play asset pack from the actual RC**
   - `store/google-play/app-icon.png` — 512 × 512 RGBA PNG;
   - exactly one 1,024 × 500 feature graphic;
   - at least four current portrait phone screenshots at 1,080 × 1,920 or higher;
   - derive the store icon from the existing Releaf launcher mark rather than a
     framework placeholder or unrelated redesign;
   - use the actual release candidate rather than stale mock-ups;
   - run:

     ```text
     dart run tool/release/play_store_asset_policy.dart --root . --strong-listing
     ```

   - owner-review creative quality and factual accuracy; the validator checks
     structure, not visual quality or rights.

5. **Preserve the frozen release version**
   - keep `pubspec.yaml` at `1.0.0+20260913` for the current pre-Play-upload candidate;
   - do not change the marketing version;
   - if a later artifact-affecting fix supersedes the production-signed/Play-used
     build, use a unique higher versionCode/build number and rerun release evidence.

6. **Build the production-signed candidate**
   - first verify the Play App Signing/upload-key state; do not generate a second
     upload key blindly if Play already has one;
   - follow `docs/release/2026-09-14-production-signing-runbook.md`;
   - configure the private upload keystore through the prepared secret path;
   - configure production legal metadata and the real RevenueCat public Google
     SDK key outside source control;
   - execute `.github/workflows/android_production_release.yml` or the controlled
     production build gate as documented by the canonical release gate;
   - verify the signed AAB and retain its exact SHA-256/build identifier;
   - never substitute the CI smoke-signing key for the real upload key.

7. **Distribute through the authorized Play testing path**
   - upload the production-signed AAB to the appropriate internal/closed testing
     track;
   - confirm the Play developer-account type/creation date and whether the 12/14
     Production-access rule applies;
   - ensure designated billing QA accounts are license testers before purchase QA.

8. **Run the one consolidated physical-device matrix on the exact Play-distributed RC**
   - use `docs/release/android_device_release_qa.md` as the authority;
   - confirm installed Releaf launcher branding as part of cold-start QA;
   - include Reset V01 lungs, Shoulder Drop, eight-stage Full Body Scan, reduced
     motion and enlarged text;
   - verify Brain game quality/progression including Memory and Labyrinth;
   - verify Sleep timer, background/interruption, looping and owner listening;
   - verify auth/recovery, Premium state boundaries and Emergency access/privacy;
   - do not replace this matrix with earlier debug-device smoke evidence.

9. **Run Play-distributed billing verification**
   - verify monthly/annual package display from real localized Play metadata;
   - use designated license-tester test payment methods;
   - verify purchase entitlement refresh;
   - verify restore;
   - verify subscription-management route;
   - verify account-switch entitlement isolation;
   - capture provider + UI evidence without exposing keys or personal data.

10. **Repeat destructive account deletion only with a disposable test account**
    - never use the protected primary QA account;
    - confirm RevenueCat customer erasure and Supabase Auth/profile/progress/storage
      deletion for the same disposable identity;
    - verify the deployed public deletion resource routes correctly.

11. **Complete Play Console declarations/listing**
    - enter the canonical UK-English Store Listing copy;
    - enter support/legal URLs;
    - submit Data safety answers after final provider verification;
    - submit Health apps declaration using the existing release mapping;
    - upload the validated graphics/screenshots;
    - preview the phone listing and correct only factual/compliance issues.

12. **Complete closed testing / Production-access requirement**
    - use `docs/release/google_play_closed_testing.md` as the authority;
    - satisfy the required tester/duration/feedback process if the account is
      subject to it;
    - keep evidence tied to the same candidate family;
    - do not fabricate tester engagement or feedback.

13. **Final gate review**
    - update `docs/release/releaf_1_0_release_gate.md` only from observed evidence;
    - every P0 row must be CLOSED;
    - no unresolved issue may threaten data, auth, purchases, Emergency behavior,
      core branding or Play policy acceptance;
    - only then may the project state: **Releaf 1.0 is release-ready.**

## Deliberately not done now

- no fragmented final phone test before signing/billing/legal prerequisites are ready;
- no production release artifact signed with a temporary CI key;
- no private signing key or secret committed or sent through chat;
- no fake Store screenshots/feature graphic merely to satisfy the validator;
- no guessed meditation narrator;
- no optional Brain/Cloud/analytics expansion to manufacture more pre-1.0 work.
