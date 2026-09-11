# Releaf 1.0 Working Checklist

**Canonical authority:** `docs/release/releaf_1_0_release_gate.md`

This checklist is an execution view, not a replacement gate.

## A. Engineering baseline

- [ ] Confirm `releaf-development`.
- [ ] Confirm working tree state.
- [ ] Run `flutter pub get`.
- [ ] Run `flutter analyze`.
- [ ] Run full `flutter test`.
- [ ] Run relevant existing release/tooling checks.
- [ ] Verify latest Reset movement commit has not introduced regression.
- [ ] Record exact baseline results.

## B. Core product — preserve / QA

### RESET
- [x] Canonical Reset core implemented per release gate.
- [ ] Verify latest movement visuals.
- [ ] Verify natural breath guidance/audio assets.
- [ ] Verify reduced-motion behavior.
- [ ] Verify basic urgent content remains unblocked.
- [ ] Keep internal Emergency access/privacy semantics intact.

### BRAIN
- [x] Canonical Brain core implemented.
- [x] 15 registered games present.
- [ ] Complete release QA of game set.
- [ ] Verify Labyrinth lifecycle/difficulty/50-stage path.
- [ ] Verify Memory progression/stats behavior.
- [ ] Verify daily training/results/personal-best flow.
- [ ] Do not add games only to increase count.

### MEDITATE
- [x] Player engineering path exists.
- [x] Separate voice and ambience controls exist.
- [x] Releaf Guide contract is 0.82×.
- [ ] Audit which sessions have final approved narration.
- [ ] Resolve missing approved narrator provider ID / production rendering dependency without guessing.
- [ ] Verify pause/resume/seek/back/background behavior.
- [ ] Final content/audio QA.

### SLEEP / SOUND
- [x] Player/timer engineering release gate marked DONE/CONTENT.
- [x] Core Sleep policy = no narration.
- [x] 10 canonical real sound tracks currently registered.
- [ ] Asset/loop/metadata QA.
- [ ] Final owner-approved sound selection/content.
- [ ] Background/interruption/device QA.
- [ ] Treat full mixer as separate deliberate scope unless release gate changes.

## C. Account / backend / privacy

- [x] Account auth code implemented.
- [ ] Final auth/device QA.
- [x] Account deletion code path prepared.
- [ ] Configure server-only RevenueCat secret in Supabase environment.
- [ ] Deploy hardened delete-account Edge function.
- [ ] Verify deletion end-to-end.
- [x] RLS/security release gate currently DONE/MONITOR.
- [ ] Final privacy controller/contact/retention details.
- [ ] Final legal review as required.
- [ ] Publish stable HTTPS privacy-policy URL.
- [ ] Deploy stable external account-deletion URL.
- [ ] Verify public deletion URL.

## D. Subscription / Google Play

- [x] RevenueCat client/paywall code prepared.
- [ ] Configure real Google Play RevenueCat SDK key (`goog_...`) outside source control.
- [ ] Verify active Play subscription products.
- [ ] Verify current RevenueCat Offering/packages.
- [ ] Purchase verification from Play-distributed build.
- [ ] Restore verification from Play-distributed build.
- [ ] Subscription management flow verification.

## E. Android release

- [x] Android API target/release tooling prepared per gate.
- [ ] Configure private production upload keystore outside repo.
- [ ] Produce final production-signed candidate.
- [ ] Verify 16 KB compatibility/release checks.
- [ ] Set final `1.0.0+<build>` only at RC.
- [ ] Execute physical-device release matrix.
- [ ] Capture release evidence.

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
