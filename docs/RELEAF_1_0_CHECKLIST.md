# Releaf 1.0 Working Checklist

**Canonical authority:** `docs/release/releaf_1_0_release_gate.md`

This checklist is an execution view, not a replacement gate.

**Latest complete automated code/build checkpoint:** `ecd3e977b55a9f247459f79e2c4ede92303db323` — see `docs/release/2026-09-14-ci-ecd3e97.md`. Evidence-only documentation commits after this checkpoint do not redefine the frozen build candidate.

## A. Engineering baseline

- [x] Confirm `releaf-development`.
- [ ] Confirm local working tree state immediately before the final production-signed RC build.
- [x] Run `flutter pub get`.
- [x] Run `flutter analyze`.
- [x] Run full `flutter test` — **583/583 PASS** on `ecd3e97`.
- [x] Run relevant existing release/tooling checks.
- [x] Verify latest Reset movement/visual changes have not introduced regression.
- [x] Verify legacy Android launcher resources are Releaf-branded across mdpi/hdpi/xhdpi/xxhdpi/xxxhdpi and inspect the built APK artifact.
- [x] Record exact baseline results and artifact digests for the frozen build candidate.

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
- [x] Keep Meditate parked outside active 1.0 discovery/marketing until its content gate is deliberately reopened.

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
- [x] Deploy stable external account-deletion URL on Releaf-specific hosting.
- [x] Verify the public deletion URL availability and web deployment health.
- [ ] Repeat deletion end-to-end against the final production-equivalent RC as part of DQA-18.

## D. Subscription / Google Play

- [x] RevenueCat client/paywall code prepared.
- [ ] Configure real Google Play RevenueCat SDK key (`goog_...`) outside source control.
- [ ] Verify active Play subscription products.
- [ ] Verify current RevenueCat Offering/packages.
- [ ] Purchase verification from Play-distributed build using designated license tester/test payment method.
- [ ] Restore verification from Play-distributed build.
- [ ] Subscription management flow verification on the final candidate.

## E. Android release

- [x] Android API target/release tooling prepared per gate.
- [x] Legacy API 24–25 launcher resources corrected to the existing Releaf brand and verified inside the built APK.
- [ ] Configure private production upload keystore outside repo.
- [ ] Produce final production-signed candidate.
- [x] Verify automated release AAB and 16 KB compatibility checks on `ecd3e97`.
- [x] Freeze RC marketing/build version at `1.0.0+20260913`.
- [ ] Execute physical-device release matrix DQA-01…DQA-23.
- [x] Capture automated release evidence and artifact digests for `ecd3e97` in `docs/release/2026-09-14-ci-ecd3e97.md`.
- [ ] Capture final production-equivalent device/store evidence after external gates are available.

## F. Google Play Console

- [ ] Verify account-specific closed-testing requirement.
- [ ] Complete required closed-test run if applicable.
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
