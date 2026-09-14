# Releaf 1.0 Android Device Release QA

This document is the mandatory production-equivalent device checklist for the first public Google Play release. Automated tests reduce risk, but they do not replace a real Play-distributed Android run for billing, deep links, background audio, lifecycle behaviour, sensors, destructive account deletion, and offline behaviour.

Last policy/release-scope alignment: **2026-09-14**.

## Gate rule

The Device release QA gate may close only when:

1. the candidate under test uses the frozen Releaf 1.0 app build candidate or an explicitly superseding candidate with fresh release evidence;
2. the production-equivalent build is installed through Google Play testing where a Play-distributed build is required (especially billing);
3. every mandatory check below is PASS with evidence, or a failure has been fixed and retested;
4. purchase and restore use the real Google Play products/current RevenueCat Offering but designated **license-tester test transactions** where Play test instruments are sufficient;
5. account deletion is tested after the production-equivalent Supabase Edge Function and RevenueCat erasure secret are deployed;
6. no test result relies on the inactive cloud progress-sync path; Releaf 1.0 remains local-first and must not claim cloud backup;
7. parked Meditate remains outside the active primary navigation/marketing surface and unfinished meditation narration is not silently converted back into a P0 content gate.

Do not mark this gate DONE from unit/widget tests alone.

## Release candidate record

Complete this block for every candidate that is eligible to close the gate.

| Field | Value |
| --- | --- |
| Date | `TBD` |
| App build-candidate Git SHA | `ecd3e977b55a9f247459f79e2c4ede92303db323` |
| App version / build | `1.0.0+20260913` |
| Production-signed AAB SHA-256 | `TBD` |
| Play test track / release | `TBD` |
| Install source | `TBD` |
| Tester | `TBD` |
| Device model | `TBD` |
| Android version / API | `TBD` |
| Billing license-tester Google account recorded | `TBD` |
| Network conditions tested | `TBD` |
| Evidence location | `TBD` |

Evidence-only documentation commits after the frozen app candidate do not redefine the app build candidate. If app source/build inputs change, record the superseding candidate and fresh automated release evidence before using this matrix.

If multiple devices are used, add one row set per device. At least one real supported Android device must complete the full mandatory matrix. Use additional devices to cover materially different Android/OEM behaviour where available.

## Automated release evidence already present

The frozen `ecd3e97` build candidate has immutable CI evidence in `docs/release/2026-09-14-ci-ecd3e97.md`:

- `flutter analyze`: clean;
- full Flutter suite: **583/583 PASS**;
- Android release AAB smoke build and 16 KB ZIP/ELF compatibility: PASS;
- Releaf Web Release Smoke run `34834895129` on the same SHA: PASS;
- Flutter P0 Validation run `34834895182`: PASS;
- production manifests exported;
- both debug APK variants built;
- legacy Android API 24–25 launcher PNGs are protected by a regression test and were verified directly inside the built standard APK artifact as Releaf-branded across all five density buckets;
- Reset lifecycle/session tests;
- Brain flow and Labyrinth lifecycle/progression tests;
- Sleep/Sound behaviour and background-audio/interruption contracts;
- account screen, password recovery and Android recovery deep-link contract tests;
- RevenueCat key policy, auth identity isolation, paywall/subscription preview tests;
- account-deletion provider-erasure contracts;
- Emergency/Relief access tests;
- privacy, health, Data Safety and Store Listing contract tests.

These checks are prerequisites, not substitutes for the physical-device matrix below.

## Mandatory physical-device matrix

For each row record `PASS`, `FAIL`, or `BLOCKED`, plus concise evidence (screen recording, screenshot, log, test transaction/order evidence, or reproducible notes).

| ID | Scenario | Mandatory acceptance criteria | Result | Evidence / notes |
| --- | --- | --- | --- | --- |
| DQA-01 | Cold start online | App launches cleanly from a force-stopped state; primary navigation is usable and no release-only initialization error is shown. Confirm the installed launcher uses Releaf branding rather than a framework/template icon. | `TBD` | `TBD` |
| DQA-02 | Cold start offline | With network unavailable, local-first areas that do not require network still launch and remain usable; the app does not claim cloud backup or silently discard local progress. Network-only actions fail clearly rather than hanging/crashing. | `TBD` | `TBD` |
| DQA-03 | Background / foreground | Move app to background and return repeatedly during active Reset, Brain and player flows. State follows the intended lifecycle policy with no duplicate timers, runaway input, crash or corrupted progress. | `TBD` | `TBD` |
| DQA-04 | Sleep background audio + timer | Start a Sleep sound, background/lock the device, resume, change timer and allow timer expiry. Rapidly change tracks during loading; use notification pause/stop during loading and expiry, then Play. The latest choice wins and resumed audio uses the selected volume. Audio/timer behaviour matches the UI, no narration appears in Sleep, and playback does not continue incorrectly after expiry. | `TBD` | `TBD` |
| DQA-05 | Parked Meditate route / resume safety | Confirm Meditate is not present as an active primary destination and is not auto-discovered from Home/Premium/Store-facing flows. If the preserved direct route or an already-active saved meditation is exercised, it must open/exit/resume safely without crashing or creating duplicate audio. Missing final narration for parked content does **not** fail active Releaf 1.0 by itself. | `TBD` | `TBD` |
| DQA-06 | Audio interruption | During active audio, trigger a real interruption available on the test device (for example another audio app or system interruption). Releaf follows its interruption policy and recovers predictably. | `TBD` | `TBD` |
| DQA-07 | Reset interruption / resume | Start a timed Reset session, background/lock and return. Session timing, step state and completion are not duplicated or incorrectly advanced. | `TBD` | `TBD` |
| DQA-08 | Brain / Labyrinth lifecycle + sensors | Play Labyrinth using physical tilt input; background/foreground and manually pause/resume. Ball input stops when required, resumes once, collisions remain stable and level state is not corrupted. | `TBD` | `TBD` |
| DQA-09 | Brain progression persistence | Complete representative Brain sessions, force-stop/relaunch, and confirm expected local level/stat/progress persistence without duplicate rewards. | `TBD` | `TBD` |
| DQA-10 | Sign-up / confirmation / sign-in | Create a fresh test account, complete email confirmation/deep-link flow, sign in and sign out. Session state and navigation are correct after relaunch. | `TBD` | `TBD` |
| DQA-11 | Password recovery deep link | Request password reset, open the real recovery link on Android, set a new password and sign in with it. Link routing must land in the intended recovery flow rather than a dead/default route. | `TBD` | `TBD` |
| DQA-12 | Profile update | Change the supported profile/display-name field, relaunch and verify the server-backed value remains correct for the signed-in account. | `TBD` | `TBD` |
| DQA-13 | Monthly Play Billing test purchase | From the Play-distributed production-equivalent build, use a designated **license tester** and Play-provided test payment method to purchase the configured monthly base plan. Confirm the purchase dialog uses the intended Google account, correct package/localized price is shown, Premium entitlement refreshes exactly once and survives relaunch. | `TBD` | `TBD` |
| DQA-14 | Annual Play Billing test purchase | From the same Play-distributed build, use an authorized license-tester scenario that permits purchase of the configured annual base plan. Correct package/localized price is shown and `premium` becomes active. Do not incur a real charge merely to satisfy this gate when Play test instruments are sufficient. | `TBD` | `TBD` |
| DQA-15 | Restore purchases | On a clean/reinstalled or otherwise valid restore scenario for the designated billing tester, use Restore Purchases. Existing entitlement must return without creating a new purchase. | `TBD` | `TBD` |
| DQA-16 | Account switch / RevenueCat identity isolation | Sign out from one account and sign into another test account with a different entitlement state. Premium state must not leak between identities. | `TBD` | `TBD` |
| DQA-17 | Emergency without Premium | Verify Emergency/Relief entry remains accessible without an active Premium entitlement and does not require a purchase flow. | `TBD` | `TBD` |
| DQA-18 | In-app account deletion | On a disposable signed-in account that has an identified RevenueCat customer, confirm deletion. Supabase account deletion and RevenueCat customer erasure must complete through the deployed server-side path; app returns to a safe signed-out state. | `PASS — Test Store debug` | Samsung SM-S928B, 2026-09-11: disposable UUID was identified in RevenueCat, deleted through the in-app flow, then absent from Auth/profiles/progress/Storage and RevenueCat. Protected primary QA account remained present. Repeat on final production-equivalent RC. |
| DQA-19 | External web account deletion | From a normal browser without relying on the Android app being installed, open `https://releaf-account-deletion-89juqm.v2.appdeploy.ai/`, confirm it clearly references Releaf, authenticate with a disposable account and reach/complete the supported deletion path. | `TBD` | Public availability already verified; final exact-RC deletion evidence still required. |
| DQA-20 | Reinstall / local-data expectation | Verify behaviour after uninstall/reinstall matches the 1.0 local-first disclosure. Do not represent locally removed progress as cloud-restorable. | `TBD` | `TBD` |
| DQA-21 | Navigation stress pass | Repeatedly move across primary tabs and core screens in both directions, including rapid but reasonable navigation. No blank screens, severe jank, duplicated routes or stale modal overlays. | `TBD` | `TBD` |
| DQA-22 | Destructive/exit paths | Exercise cancel/back/confirm behaviour around purchase, sign-out and account deletion. Destructive actions require the intended confirmation and cannot be triggered accidentally by navigation. | `TBD` | `TBD` |
| DQA-23 | Reset visual pilot | Run one V01 paced-breathing session, Shoulder Drop and the full eight-minute Full Body Scan. V01 must use the dedicated lung visual while preserving that method's real timing; Shoulder Drop must clearly show the intended lift/release movement without confusing arrows; Full Body Scan must progress through Face → Shoulders → Arms → Chest → Center → Legs → Feet → Whole Body with the matching `1 OF 8`…`8 OF 8` state. Repeat the visual check with Android reduced motion enabled and with enlarged system text; guidance must remain understandable, static where expected, and free of clipped/overflowing controls. | `TBD` | `TBD` |

## Billing-test safety lock

Google's current Billing guidance recommends license testers and Play Billing Lab for integration testing. License testers have test payment instruments and accelerated subscription scenarios; normal users on Play testing tracks can still be charged real money.

For DQA-13–DQA-15:

- register the designated Google account as a Play license tester;
- ensure that account is present on the Android device;
- confirm the intended account in the Play purchase dialog before confirming;
- use Play's test payment instrument unless a separately authorized real-payment scenario is specifically required;
- record the Play test order/transaction evidence without exposing personal data or credentials;
- if multiple Google accounts are on the device, remember that the purchase account can depend on which account downloaded the app.

## Failure policy

- Any crash, data-loss path, broken account access, Premium leakage between accounts, failed authorized Play Billing test purchase/restore, inaccessible Emergency flow, broken deletion flow, repeatable severe navigation/audio defect, or shipped launcher regression is P0 and blocks release.
- A failed mandatory row must be linked to a fix and retested on the release candidate.
- `BLOCKED` is not equivalent to PASS. If a row depends on external production configuration, keep the corresponding release gate open until that dependency is available and the row is rerun.
- Parked Meditate content incompleteness by itself is not a P0 for the active Reset / Brain / Sleep 1.0 surface. A crash, broken exit/resume path or accidental reintroduction into active discovery can still be release-blocking.
- Cosmetic issues may be triaged separately only when they do not impair comprehension, accessibility, navigation, purchase disclosure, privacy, safety or core brand identity.

## Sign-off

When all mandatory rows are PASS, record:

- final app build-candidate SHA and version/build;
- production-signed AAB SHA-256;
- devices and Android versions tested;
- Play test track/build used for billing checks;
- designated licence-tester evidence for billing scenarios;
- evidence location;
- remaining non-blocking known issues, if any;
- explicit QA sign-off.

Only then may `Device release QA` move to `DONE`, subject to the other P0 release gates remaining closed.
