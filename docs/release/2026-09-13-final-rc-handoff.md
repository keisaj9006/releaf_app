# Releaf 1.0 — final RC handoff

Status: **automated RC evidence complete; external/production execution pending**.

This checklist continues from the frozen build candidate after repo-side RC
hardening. It does not change the current release-gate status and must not be
used to claim that Releaf 1.0 is release-ready.

## Why this is the next boundary

The repo-side automated P0 programme is complete for the frozen build candidate
`dd20fb5a3f0f00c9cf4760c22f2ba0d8c034e22e`. Flutter P0 Validation run
`34822680105` passed clean analysis, **582/582 Flutter tests**, production
manifests, both debug APK variants, release-AAB smoke and Android 16 KB ZIP/ELF
compatibility. Releaf Web Release Smoke run `34822680100` also passed on the
exact same SHA. Immutable evidence is recorded in
`docs/release/2026-09-14-ci-dd20fb5.md`.

The release version is already frozen at `1.0.0+20260913`. Evidence-only
documentation commits after `dd20fb5` do not redefine the build candidate.

What remains is primarily owner/account configuration, production credentials,
public Privacy Policy publication, Play Console state, store assets and the
exact-RC physical/distributed verification. Do not create optional product scope
merely to avoid these external gates.

## Inputs still required before production RC execution

Collect these without committing secrets to the repository:

- final data-controller identity;
- privacy contact/support email;
- agreed retention wording and final legal review;
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
  `https://releaf-account-deletion-89juqm.v2.appdeploy.ai/`; final DQA-18 on the
  exact production-equivalent RC remains required.

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
   - any artifact-affecting code/configuration change creates a new candidate and
     requires fresh automated release evidence.

2. **Finalize public legal resources**
   - provide the real controller/contact/retention metadata;
   - render and deploy the Privacy Policy to the approved stable HTTPS Releaf host;
   - keep the existing live Releaf account-deletion portal;
   - verify both live URLs and the authenticated deletion route end to end;
   - keep secrets server-side only.

3. **Finalize production billing configuration**
   - activate/verify Google Play subscription and monthly/annual base plans;
   - connect/import the products in RevenueCat;
   - attach them to entitlement `premium` and the current Offering using the
     expected Annual/Monthly packages;
   - configure and verify the real Android `goog_` SDK key;
   - do not perform a real-money purchase outside the authorized Play test flow.

4. **Finalize the Google Play asset pack from the actual RC**
   - `store/google-play/app-icon.png` — 512 × 512 RGBA PNG;
   - exactly one 1,024 × 500 feature graphic;
   - at least four current portrait phone screenshots at 1,080 × 1,920 or higher;
   - use the actual release candidate rather than stale mock-ups;
   - run:

     ```text
     dart run tool/release/play_store_asset_policy.dart --root . --strong-listing
     ```

   - owner-review creative quality and factual accuracy; the validator checks
     structure, not visual quality or rights.

5. **Confirm frozen version**
   - keep `pubspec.yaml` at `1.0.0+20260913` for this candidate;
   - do not change the marketing version;
   - if an artifact-affecting fix forces another RC, increment only the build
     number/versionCode and rerun release evidence.

6. **Build the production-signed candidate**
   - configure the private upload keystore through the prepared secret path;
   - configure production legal metadata and the real RevenueCat public Google
     SDK key outside source control;
   - execute `.github/workflows/android_production_release.yml` or the controlled
     production build gate as documented by the canonical release gate;
   - verify the signed AAB and retain its exact SHA-256/build identifier;
   - never substitute the CI smoke-signing key for the real upload key.

7. **Run the one consolidated physical-device matrix on the exact signed RC**
   - use `docs/release/android_device_release_qa.md` as the authority;
   - include Reset V01 lungs, Shoulder Drop, eight-stage Full Body Scan, reduced
     motion and enlarged text;
   - verify Brain game quality/progression including Memory and Labyrinth L50;
   - verify Sleep timer, background/interruption, looping and owner listening;
   - verify auth/recovery, Premium state boundaries and Emergency access/privacy;
   - do not replace this matrix with earlier debug-device smoke evidence.

8. **Run Play-distributed billing verification**
   - distribute the same production-equivalent candidate through the authorized
     Play testing track;
   - verify monthly/annual package display as configured;
   - verify purchase entitlement refresh;
   - verify restore;
   - verify subscription-management route;
   - capture provider + UI evidence without exposing keys or personal data.

9. **Repeat destructive account deletion only with a disposable test account**
   - never use the protected primary QA account;
   - confirm RevenueCat customer erasure and Supabase Auth/profile/progress/storage
     deletion for the same disposable identity;
   - verify the deployed public deletion resource routes correctly.

10. **Complete Play Console declarations/listing**
    - enter the canonical UK-English Store Listing copy;
    - enter support/legal URLs;
    - submit Data safety answers after final provider verification;
    - submit Health apps declaration using the existing release mapping;
    - upload the validated graphics/screenshots;
    - preview the phone listing and correct only factual/compliance issues.

11. **Complete closed testing / Production-access requirement**
    - confirm the account-specific Play requirement first;
    - use `docs/release/google_play_closed_testing.md` as the authority;
    - satisfy the required tester/duration/feedback process if applicable;
    - keep evidence tied to the same candidate family.

12. **Final gate review**
    - update `docs/release/releaf_1_0_release_gate.md` only from observed evidence;
    - every P0 row must be CLOSED;
    - no unresolved issue may threaten data, auth, purchases, Emergency behavior
      or Play policy acceptance;
    - only then may the project state: **Releaf 1.0 is release-ready.**

## Deliberately not done now

- no fragmented final phone test before signing/billing/legal prerequisites are ready;
- no production release artifact signed with a temporary CI key;
- no private signing key or secret committed;
- no fake Store screenshots/feature graphic merely to satisfy the validator;
- no guessed meditation narrator;
- no optional Brain/Cloud/analytics expansion to manufacture more pre-1.0 work.
