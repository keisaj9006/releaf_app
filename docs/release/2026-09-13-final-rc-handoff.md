# Releaf 1.0 — final RC handoff

Status: **prepared, not executed**.

This checklist starts only after the remaining owner/external prerequisites are
available. It does not change the current release-gate status and must not be
used to claim that Releaf 1.0 is release-ready.

## Why this is the next boundary

The local code-side P0 programme is controlled through the automated release
suite. At the `3186cb1` checkpoint, clean analysis, 572 Flutter tests, production
manifests, both debug APK variants, release-AAB smoke, Android 16 KB compatibility
and web release smoke passed. The Google Play asset policy is also enforced by
the production build path.

What remains is primarily owner approval, production credentials/resources,
Play Console state and the exact-RC physical/distributed verification. Do not
create optional product scope merely to avoid these external gates.

## Inputs required before RC execution

Collect these without committing secrets to the repository:

- final data-controller identity;
- privacy contact/support email;
- agreed retention wording and final legal review;
- stable public HTTPS Privacy Policy URL;
- stable public HTTPS Account Deletion URL using the Releaf project, never the
  unrelated SecondPart deployment;
- private Android upload keystore and local `android/key.properties`;
- real public RevenueCat Google SDK key (`goog_...`), kept outside source control;
- active Google Play subscription products and the matching current RevenueCat
  Offering/packages;
- final owner-approved Sleep/Reset audio selection and, where required by the
  shipped Meditation surface, approved Releaf Guide recordings. Never substitute
  an unidentified narrator;
- Play Console access/account information needed to confirm closed-testing rules.

## Final RC sequence

Execute in this order so screenshots, testing and store metadata all refer to the
same candidate.

1. **Freeze candidate scope**
   - no optional features;
   - confirm the active four primary destinations remain Home / Reset / Sleep /
     Brain, with Emergency available and Meditate parked/direct-access only;
   - confirm Sleep remains narration-free and Emergency remains outside Premium.

2. **Finalize public legal resources**
   - inject the real controller/contact/retention metadata;
   - deploy Privacy Policy and Account Deletion resources to stable HTTPS URLs;
   - verify both live URLs and the authenticated deletion route end to end;
   - keep secrets server-side only.

3. **Finalize production billing configuration**
   - verify the real `goog_` SDK key;
   - verify active Play products;
   - verify RevenueCat Offering/package mapping;
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

5. **Set final version only now**
   - change `pubspec.yaml` to `1.0.0+<build>`;
   - do not consume the final build number earlier in development.

6. **Build the production-equivalent signed candidate**
   - configure the private upload keystore locally;
   - configure production legal metadata and the real RevenueCat public Google
     SDK key outside source control;
   - run the existing production build gate `tool/build_play_release.ps1`;
   - retain the exact AAB hash/build identifier used for the remaining evidence.

7. **Run the one consolidated physical-device matrix on the exact RC**
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

- no final phone test before the programme reaches this RC boundary;
- no production deployment without explicit production intent;
- no private signing key or secret committed;
- no fake Store screenshots/feature graphic merely to satisfy the validator;
- no guessed meditation narrator;
- no optional Brain/Cloud/analytics expansion to manufacture more pre-1.0 work.
