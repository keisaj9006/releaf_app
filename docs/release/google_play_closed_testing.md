# Releaf 1.0 Google Play Closed Testing Plan

This is the canonical Play Console testing plan for Releaf 1.0. It converts the store requirement into an auditable release process; it does not claim that testing has already happened.

## 1. First determine whether the 12 / 14 rule applies

Before scheduling the production-access date, verify in the Play Console developer account:

- account type: personal or organisation;
- account creation date;
- whether the Dashboard currently requires testing before Production access.

As of the current Google Play policy, personal developer accounts created after 13 November 2023 must run a closed test with at least 12 testers opted in continuously for at least 14 days before applying for Production access. Do not assume this applies to Releaf until the actual account state is checked in Play Console.

If the Dashboard does not impose that eligibility requirement, closed testing is still required by the Releaf release process for production-equivalent billing/device QA, but the 12-testers/14-days rule must not be reported as an account blocker unless Play Console actually applies it.

## 2. Preconditions before the release-candidate closed test

The build used for final Releaf 1.0 closed testing should be production-equivalent. Before calling a run the release-candidate test, confirm:

- the candidate commit is green in Flutter P0 Validation and Releaf Web Release Smoke;
- the production upload keystore is configured privately and the uploaded AAB is not debug-signed;
- the real Android RevenueCat public SDK key is supplied at build time;
- monthly and annual Google Play subscription products are active and mapped into the current RevenueCat Offering;
- the updated Supabase `delete-account` Edge Function is deployed with the server-only RevenueCat erasure secret;
- the public HTTPS privacy-policy and external account-deletion URLs are live and match Play Console entries;
- Health apps declaration, Data safety answers and Store Listing are aligned with the candidate;
- the candidate version/build code is unique and recorded;
- test accounts and, where required, Play licence testers are prepared.

A preliminary closed/internal build may be used earlier, but it does not close the production-equivalent QA gates above.

## 3. Create the closed test

In Play Console:

1. Open Releaf.
2. Go to **Test and release > Testing > Closed testing**.
3. Create or select the release track.
4. Add testers using the supported email-list or Google Group mechanism.
5. Upload the production-equivalent Releaf AAB.
6. Add concise release notes identifying the candidate/build.
7. Review warnings/errors and resolve release-blocking items.
8. Roll out the closed-test release.
9. Send testers the official opt-in link and the Releaf test brief.

If the account is subject to the 12 / 14 production-access rule, recruit more than the bare minimum where practical so one accidental opt-out does not reset eligibility below 12. The official requirement is based on testers remaining opted in continuously; an opt-out breaks that tester's continuous period.

## 4. Tester brief

Testers should not merely install the app. Ask them to use the main release surface and report reproducible issues. The brief should cover:

- first launch and primary navigation;
- RESET start, interruption/resume and completion;
- BRAIN including at least one normal game and Labyrinth on a physical device;
- Sleep sound playback, timer, lock/background/resume;
- Meditation playback, pause/resume and background/foreground;
- sign-up/sign-in/sign-out and email confirmation;
- password reset/recovery deep link;
- Premium paywall presentation;
- real Google Play purchase on designated licence-test accounts where assigned;
- Restore Purchases on the designated purchase test path;
- Emergency access without Premium;
- offline/local-first behaviour;
- any crash, frozen state, severe jank, broken navigation or misleading copy.

Destructive account deletion should be performed only by designated QA testers using disposable accounts, according to `docs/release/android_device_release_qa.md`.

## 5. Feedback record

Keep a lightweight evidence table throughout the run.

| Field | Record |
| --- | --- |
| Track / release name | `TBD` |
| Version / build | `TBD` |
| Candidate SHA | `TBD` |
| Closed test start | `TBD` |
| Eligibility rule shown by Play Console | `TBD` |
| Tester count opted in | `TBD` |
| Continuous eligibility date, if applicable | `TBD` |
| Feedback channel | `TBD` |
| Issues found | `TBD` |
| P0/P1 fixes shipped during test | `TBD` |
| Final device QA evidence | `TBD` |

For each material issue record: reporter/test device, reproduction steps, severity, fix commit/build and retest result.

## 6. Changes during the closed-test period

Updates may be shipped to the closed track while testing continues. Keep each build traceable to a Git SHA and release notes. A code change that affects a P0 gate must pass CI again and the affected physical-device QA rows must be rerun.

Do not turn on runtime cloud progress sync during the 1.0 closed test. Local progress remains the user-facing truth for this release.

## 7. Production-access application when the account requires it

For a personal account subject to Google's testing eligibility requirement, apply from the Play Console Dashboard only after the Dashboard indicates the criterion is met.

Prepare factual answers for the production-access questions, including:

- how testers were recruited;
- what testers actually exercised;
- how feedback was collected;
- what issues or usability problems were discovered;
- what was changed because of testing;
- why the current build is ready for production.

Do not fabricate tester engagement or feedback. Google may require additional testing if the test is insufficient.

If Releaf requires authentication for review, ensure Play Console App access contains valid review instructions/credentials as required so Google can access the relevant functionality.

## 8. Exit criteria

`Play closed testing` may move to DONE only when all applicable conditions are true:

- Play Console account-specific testing requirement has been checked and satisfied;
- a production-equivalent candidate has been distributed through the appropriate Play testing track;
- applicable minimum tester/duration requirement is complete;
- meaningful tester feedback has been reviewed and release-blocking defects are fixed/retested;
- Android Device Release QA mandatory rows are PASS on the final candidate or a later equivalent candidate;
- real purchase/restore checks have passed on the Play-distributed build;
- Production access has been granted when the account requires an application.

Until then the gate remains open, even if CI is fully green.

## Source lock

The account-specific 12-tester/14-day rule must always be rechecked against the current official Google Play Console Help guidance immediately before starting the eligibility clock or applying for Production access; store requirements can change independently of the Releaf codebase.
