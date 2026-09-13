# Releaf 1.0 Working Checklist

**Canonical authority:** `docs/release/releaf_1_0_release_gate.md`

This checklist is an execution view, not a replacement gate.

**Latest complete automated code/build checkpoint:** `7fb186a9551c2fbb8fd6149fba540a9d23519c47` — see `docs/release/2026-09-13-ci-7fb186a.md`.

## A. Engineering baseline

- [x] Confirm `releaf-development`.
- [ ] Confirm local working tree state immediately before the final RC build.
- [x] Run `flutter pub get`.
- [x] Run `flutter analyze`.
- [x] Run full `flutter test`.
- [x] Run relevant existing release/tooling checks.
- [x] Verify latest Reset movement/visual changes have not introduced regression.
- [x] Record exact baseline results and artifact digests.

## B. Core product — preserve / QA

### RESET
- [x] Canonical Reset core implemented per release gate.
- [x] Verify latest movement visuals: V01 lungs, Shoulder Drop and eight-stage Full Body Scan.
- [ ] Final owner approval of natural breath guidance/audio assets.
- [x] Verify reduced-motion behavior in automated coverage.
- [x] Verify basic urgent content remains unblocked before Premium.
- [x] Keep internal Emergency access/privacy semantics intact.
- [ ] Complete DQA-23 on the final production-equivalent Android candidate.

### BRAIN
- [x] Canonical Brain core implemented.
- [x] 15 registered games present.
- [ ] Complete production-equivalent physical release QA of the game set.
- [x] Verify Labyrinth lifecycle/difficulty and level-50 training path.
- [x] Verify Memory level-50 progression/stats behavior.
- [x] Verify daily training/results/personal-best flow.
- [x] Keep 1.0 scope frozen rather than adding games only to increase count.

### MEDITATE
- [x] Player engineering path exists.
- [x] Separate voice and ambience controls exist.
- [x] Releaf Guide contract is 0.82×.
- [ ] Audit which sessions have final approved narration.
- [ ] Resolve missing approved narrator provider ID / production rendering dependency without guessing.
- [x] Verify pause/resume/seek/back/background behavior in automated coverage.
- [ ] Final content/audio owner QA.

### SLEEP / SOUND
- [x] Player/timer engineering release gate marked DONE/CONTENT.
- [x] Core Sleep policy = no narration.
- [x] 10 canonical real sound tracks currently registered.
- [x] Automated asset decode/duration/metadata and engineering loop/loudness measurements captured for the current catalog.
- [ ] Final owner listening, perceptual loop check and approved sound selection/content.
- [ ] Background/interruption physical-device QA.
- [x] Treat full mixer as separate deliberate post-1.0 scope unless release gate changes.

## C. Account / backend / privacy

- [x] Account auth code implemented.
- [ ] Final auth/device QA on the production-equivalent RC.
- [x] Account deletion code path implemented.
- [x] Server-only RevenueCat erasure secret configured in the tested Supabase deletion environment.
- [x] Hardened `delete-account` Edge Function version 4 deployed and verified.
- [x] Disposable-account in-app deletion E2E verified against Supabase and RevenueCat.
- [ ] Repeat DQA-18 on the final production-equivalent RC.
- [x] RLS/security release gate currently DONE/MONITOR.
- [ ] Final privacy controller/contact/retention details.
- [ ] Final legal review as required.
- [ ] Publish stable HTTPS privacy-policy URL.
- [ ] Deploy stable external account-deletion URL on Releaf-specific hosting.
- [ ] Verify the public deletion URL end-to-end in a normal browser.

## D. Subscription / Google Play

- [x] RevenueCat client/paywall code prepared.
- [ ] Configure real Google Play RevenueCat SDK key (`goog_...`) outside source control.
- [ ] Verify active Play subscription products.
- [ ] Verify current RevenueCat Offering/packages.
- [ ] Purchase verification from Play-distributed build.
- [ ] Restore verification from Play-distributed build.
- [ ] Subscription management flow verification on the final candidate.

## E. Android release

- [x] Android API target/release tooling prepared per gate.
- [ ] Configure private production upload keystore outside repo.
- [ ] Produce final production-signed candidate.
- [x] Verify automated release AAB and 16 KB compatibility checks.
- [ ] Set final `1.0.0+<build>` only at RC.
- [ ] Execute physical-device release matrix DQA-01…DQA-23.
- [x] Capture current automated release evidence and artifact digests for `7fb186a`.
- [ ] Capture final production-equivalent device/store evidence after external gates are available.

## F. Google Play Console

- [ ] Verify account-specific closed-testing requirement.
- [ ] Complete required closed-test run.
- [ ] Submit Health declaration.
- [ ] Submit Data safety answers after final verification.
- [ ] Enter Store listing.
- [ ] Provide support/contact fields.
- [ ] Provide current screenshots.
- [ ] Provide app icon / feature graphic.
- [ ] Enter public privacy URL.
- [ ] Enter public account-deletion URL.
- [ ] Apply for Production access when eligible.

## G. Release truth

Do not check this until the canonical gate agrees:

- [ ] **Releaf 1.0 is release-ready.**

## H. Research-informed polish — NOT automatically P0

These are valuable but require deliberate scope handling:

- [ ] Stronger one-tap Reset / Releaf Now concept.
- [ ] Intent/time-first Home.
- [ ] Consumer-facing safer Emergency naming.
- [ ] Leaves multiplier/third-pillar bonus simplification.
- [ ] Five-tab IA evaluation.
- [ ] Sleep multi-layer mixer + saved mixes.
- [ ] Expanded Sleep catalog toward research target.
- [ ] Expanded structured meditation curriculum.
- [ ] Privacy-minimal analytics.
- [ ] Onboarding <2 min / value-before-account audit.
- [ ] Offline audio downloads.
- [ ] Rule-based cross-pillar personalization.

See `docs/DECISION_CONFLICTS.md` before implementing any item that changes release scope.
