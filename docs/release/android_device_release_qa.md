# Releaf 1.0 Android Device Release QA

This document is the mandatory production-equivalent device checklist for the first public Google Play release. Automated tests reduce risk, but they do not replace a real Play-distributed Android run for billing, deep links, background audio, lifecycle behaviour, sensors, destructive account deletion, and offline behaviour.

## Gate rule

The Device release QA gate may close only when:

1. the candidate under test is built from the exact release-candidate commit;
2. the production-equivalent build is installed through Google Play testing where a Play-distributed build is required (especially billing);
3. every mandatory check below is PASS with evidence, or a failure has been fixed and retested;
4. purchase and restore use the real Google Play products/current RevenueCat Offering;
5. account deletion is tested after the production-equivalent Supabase Edge Function and RevenueCat erasure secret are deployed;
6. no test result relies on the inactive cloud progress-sync path; Releaf 1.0 remains local-first and must not claim cloud backup.

Do not mark this gate DONE from unit/widget tests alone.

## Release candidate record

Complete this block for every candidate that is eligible to close the gate.

| Field | Value |
| --- | --- |
| Date | `TBD` |
| Git commit SHA | `TBD` |
| App version / build | `TBD` |
| Install source | `TBD` |
| Tester | `TBD` |
| Device model | `TBD` |
| Android version / API | `TBD` |
| Network conditions tested | `TBD` |
| Evidence location | `TBD` |

If multiple devices are used, add one row set per device. At least one real supported Android device must complete the full mandatory matrix. Use additional devices to cover materially different Android/OEM behaviour where available.

## Automated release evidence already present

The repository already protects important parts of the matrix in CI, including:

- full Flutter test suite and `flutter analyze`;
- Android release AAB smoke build and 16 KB compatibility verification;
- web release smoke and external account-deletion resource contract;
- Reset lifecycle/session tests;
- Brain flow and Labyrinth lifecycle tests;
- Sleep/Sound behaviour and background-audio/interruption contracts;
- account screen, password recovery and Android recovery deep-link contract tests;
- RevenueCat key policy, auth identity isolation, paywall/subscription preview tests;
- account-deletion provider-erasure contracts;
- Emergency/Relief access tests;
- privacy, health, Data Safety and Store Listing contract tests.

These checks are prerequisites, not substitutes for the physical-device matrix below.

## Mandatory physical-device matrix

For each row record `PASS`, `FAIL`, or `BLOCKED`, plus concise evidence (screen recording, screenshot, log, transaction/order evidence, or reproducible notes).

| ID | Scenario | Mandatory acceptance criteria | Result | Evidence / notes |
| --- | --- | --- | --- | --- |
| DQA-01 | Cold start online | App launches cleanly from a force-stopped state; primary navigation is usable and no release-only initialization error is shown. | `TBD` | `TBD` |
| DQA-02 | Cold start offline | With network unavailable, local-first areas that do not require network still launch and remain usable; the app does not claim cloud backup or silently discard local progress. Network-only actions fail clearly rather than hanging/crashing. | `TBD` | `TBD` |
| DQA-03 | Background / foreground | Move app to background and return repeatedly during active Reset, Brain and player flows. State follows the intended lifecycle policy with no duplicate timers, runaway input, crash or corrupted progress. | `TBD` | `TBD` |
| DQA-04 | Sleep background audio + timer | Start a Sleep sound, background/lock the device, resume, change timer and allow timer expiry. Audio/timer behaviour matches the UI, no narration appears in Sleep, and playback does not continue incorrectly after expiry. | `TBD` | `TBD` |
| DQA-05 | Meditation playback | Start a recorded Releaf Guide meditation, verify narration + ambience behaviour, pause/resume, background/foreground and seek controls. Position changes must match the control intent and playback must recover without duplicate layers. | `TBD` | `TBD` |
| DQA-06 | Audio interruption | During active audio, trigger a real interruption available on the test device (for example another audio app or system interruption). Releaf follows its interruption policy and recovers predictably. | `TBD` | `TBD` |
| DQA-07 | Reset interruption / resume | Start a timed Reset session, background/lock and return. Session timing, step state and completion are not duplicated or incorrectly advanced. | `TBD` | `TBD` |
| DQA-08 | Brain / Labyrinth lifecycle + sensors | Play Labyrinth using physical tilt input; background/foreground and manually pause/resume. Ball input stops when required, resumes once, collisions remain stable and level state is not corrupted. | `TBD` | `TBD` |
| DQA-09 | Brain progression persistence | Complete representative Brain sessions, force-stop/relaunch, and confirm expected local level/stat/progress persistence without duplicate rewards. | `TBD` | `TBD` |
| DQA-10 | Sign-up / confirmation / sign-in | Create a fresh test account, complete email confirmation/deep-link flow, sign in and sign out. Session state and navigation are correct after relaunch. | `TBD` | `TBD` |
| DQA-11 | Password recovery deep link | Request password reset, open the real recovery link on Android, set a new password and sign in with it. Link routing must land in the intended recovery flow rather than a dead/default route. | `TBD` | `TBD` |
| DQA-12 | Profile update | Change the supported profile/display-name field, relaunch and verify the server-backed value remains correct for the signed-in account. | `TBD` | `TBD` |
| DQA-13 | Monthly purchase | From a Play-distributed test build, purchase the configured monthly product with a Google Play test account. Premium entitlement must refresh exactly once and survive relaunch. | `TBD` | `TBD` |
| DQA-14 | Annual purchase | From a Play-distributed test build, purchase the configured annual product (using an account/state that permits the transaction). Correct package/price is shown and entitlement becomes active. | `TBD` | `TBD` |
| DQA-15 | Restore purchases | On a clean/reinstalled or otherwise valid restore scenario, use Restore Purchases. Existing entitlement must return without creating a new purchase. | `TBD` | `TBD` |
| DQA-16 | Account switch / RevenueCat identity isolation | Sign out from one account and sign into another test account with a different entitlement state. Premium state must not leak between identities. | `TBD` | `TBD` |
| DQA-17 | Emergency without Premium | Verify Emergency/Relief entry remains accessible without an active Premium entitlement and does not require a purchase flow. | `TBD` | `TBD` |
| DQA-18 | In-app account deletion | On a disposable signed-in account that has an identified RevenueCat customer, confirm deletion. Supabase account deletion and RevenueCat customer erasure must complete through the deployed server-side path; app returns to a safe signed-out state. | `TBD` | `TBD` |
| DQA-19 | External web account deletion | From a normal browser without relying on the Android app being installed, open the public HTTPS deletion resource, authenticate, and reach/complete the supported deletion path. | `TBD` | `TBD` |
| DQA-20 | Reinstall / local-data expectation | Verify behaviour after uninstall/reinstall matches the 1.0 local-first disclosure. Do not represent locally removed progress as cloud-restorable. | `TBD` | `TBD` |
| DQA-21 | Navigation stress pass | Repeatedly move across primary tabs and core screens in both directions, including rapid but reasonable navigation. No blank screens, severe jank, duplicated routes or stale modal overlays. | `TBD` | `TBD` |
| DQA-22 | Destructive/exit paths | Exercise cancel/back/confirm behaviour around purchase, sign-out and account deletion. Destructive actions require the intended confirmation and cannot be triggered accidentally by navigation. | `TBD` | `TBD` |

## Failure policy

- Any crash, data-loss path, broken account access, Premium leakage between accounts, failed real purchase/restore, inaccessible Emergency flow, broken deletion flow, or repeatable severe navigation/audio defect is P0 and blocks release.
- A failed row must be linked to a fix and retested on the release candidate.
- `BLOCKED` is not equivalent to PASS. If a row depends on external production configuration, keep the corresponding release gate open until that dependency is available and the row is rerun.
- Cosmetic issues may be triaged separately only when they do not impair comprehension, accessibility, navigation, purchase disclosure, privacy, or safety.

## Sign-off

When all mandatory rows are PASS, record:

- final candidate SHA and version/build;
- devices and Android versions tested;
- Play test track/build used for billing checks;
- evidence location;
- remaining non-blocking known issues, if any;
- explicit QA sign-off.

Only then may `Device release QA` move to `DONE`, subject to the other P0 release gates remaining closed.