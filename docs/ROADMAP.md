# Releaf Completion Roadmap

This roadmap converts the current repo + release gate + latest project decisions + Deep Research into execution order.

The canonical release gate remains:
`docs/release/releaf_1_0_release_gate.md`

The owner-approved [quality programme](plans/2026-09-11-product-quality-programme.md)
continues the completed internal pass. Its first milestone (Meditation guidance
disclosure, captions and large text) passed 383 tests, clean analysis and a debug
Android build. The following [Reset milestone](release/2026-09-11-reset-cue-eligibility.md)
excludes rejected tones and fixes audio-sheet readability, with 386 passing tests.
The following Sound milestone protects delayed track starts, notification
cancellation and timer/volume ordering. Its exact verification is in
[Sound playback evidence](release/2026-09-11-sound-playback-intent.md).
Sound loading, retry and interruption fixes have passed 447 full-suite tests and
clean analysis. Development resumed after `16a0f2c`, the owner-requested
[Samsung checkpoint](release/2026-09-12-device-review-checkpoint.md); the debug APK
was installed non-destructively and bounded physical UI smoke passed. Owner
visual/listening review and the full production-equivalent matrix remain open.
Content approvals and production-equivalent device/release gates remain open.

## Phase 0 — Re-establish verified baseline

Current owner-approved execution order is recorded in the
[Meditate / Reset remediation plan](plans/2026-09-12-meditate-reset-remediation.md).
Premium refresh continuity passed 474 tests, clean analysis and Android debug
build; see [evidence](release/2026-09-12-premium-refresh-continuity.md).
Home / Reset / Meditate / Sleep / Brain navigation with legacy route compatibility
is now implemented: 482 tests, clean analysis, Android build and non-destructive
Samsung installation passed; see [five-tab evidence](release/2026-09-12-five-primary-destinations.md).
The [Meditation matrix and production-manifest checks](release/2026-09-12-meditation-production-manifest.md)
are implemented. Unguided silence by default is also implemented: 495 tests,
clean analysis, Android build and non-destructive Samsung update passed; see
[evidence](release/2026-09-12-unguided-silent-default.md). Next: remaining Meditation
contracts and Reset blueprints. Approved human breathing recordings and owner listening remain
dependencies, not permission to substitute synthetic cues or change protocols.

Reset sensory count completion now advances immediately (496 tests, clean
analysis, Android build; [evidence](release/2026-09-12-reset-immediate-progression.md)).
Device check remains pending after disconnection. Continue with labelled
skip/ready controls from the [session blueprint](product/reset-back-to-room-blueprint.md).

Those controls are now implemented, including no-words accessibility and a
scrollable large-text sensory layout; see [evidence](release/2026-09-12-reset-sensory-skip.md).
Next: remaining Reset session blueprints and interrupted progression coverage.

Full/simplified sensory interruption is now covered without a runtime change.
The [breathing matrix](product/breathing-method-evidence-matrix.md) lists all ten
unchanged methods; see [contract evidence](release/2026-09-12-reset-contract-coverage.md).
Continue the remaining per-session production blueprints and unblocked tracks.

**Priority: immediate**

1. Confirm `releaf-development`, clean/known working tree and HEAD.
2. Read the canonical release gate and this context pack.
3. Run:
   - `flutter pub get`
   - `flutter analyze`
   - `flutter test`
   - existing non-secret CI/release contract checks.
4. Baseline audit is completed and preserved as `efbcf58`. Subsequent internal
   batches through `3ddffee` passed 375 tests and clean analysis; use
   `docs/release/2026-09-11-internal-quality-batches.md` instead of repeating a general audit.
5. Do not require repetitive manual phone testing yet.

Exit condition:
- analyzer/tests green or failures understood,
- current state docs aligned with repo,
- no unknown P0 regression.

## Phase 1 — Close code-side 1.0 release blockers

Work from `docs/release/releaf_1_0_release_gate.md`.

### 1A Account deletion
- verify `supabase/functions` account-deletion implementation,
- verify RevenueCat erasure ordering and Supabase deletion behavior,
- keep secret server-only,
- prepare/deploy/verify when the external secret/environment is available,
- never embed secret in Flutter/repo.

### 1B RevenueCat / Google Play Billing
- verify real production key requirements,
- verify product/package/offering assumptions,
- preserve account-switch isolation, restore and error handling,
- prepare exact Play-distributed purchase/restore QA,
- stop only when real external Play/RevenueCat configuration is required.

### 1C Privacy/legal public resources
- finalize technical pieces that can be done in repo,
- identify missing controller/contact/retention fields rather than inventing them,
- verify public deletion page contract,
- prepare public deployment checks.

### 1D Signing/version/release artifact
- keep private upload key outside repo,
- preserve release tooling safeguards,
- do not set `1.0.0+<build>` until actual RC,
- verify AAB pipeline without claiming final production signing until private key is used.

## Phase 2 — Content readiness and product polish without scope explosion

### RESET
- verify latest guided movement visuals and quality tests,
- verify breathing cue quality/interaction,
- keep basic urgent Reset frictionless/free,
- preserve reduced-motion accessibility,
- do not convert medical/copy research suggestions into internal safety regressions.

### Meditation
- audit catalog against actual approved recordings,
- never substitute system TTS,
- keep 0.82× Releaf Guide contract,
- preserve separate voice/ambience controls,
- identify exactly which sessions are blocked by missing approved narration,
- recover exact narrator provider ID if possible through project/provider records; otherwise require deliberate owner voice decision.

### Sleep/Sound
- asset QA for every bundled track,
- verify seamless looping, timers, interruption/background behavior and metadata,
- keep Sleep narration-free,
- do not add unlicensed/fake assets,
- treat a full multi-layer mixer as a deliberate scope item, not hidden P0.

### Brain
- focus on QA/polish of current 15 games,
- do not add games for count,
- verify difficulty/progression and resume/lifecycle behavior,
- preserve Labyrinth 50-stage architecture,
- verify Memory and stats behavior against historical requirements,
- curate daily training so quality is visible.

## Phase 3 — Release-candidate preparation

1. Re-run full automated suite.
2. Close every code-side P0 gate.
3. Set final RC version when appropriate.
4. Produce production-equivalent artifact with proper signing.
5. Supply final Store listing screenshots/icon/feature graphic.
6. Publish stable Privacy Policy and deletion URLs.
7. Complete Play Data safety/Health declaration.
8. Complete Play closed-testing steps that apply to the account.
9. Run the full physical-device matrix.
10. Verify Play-distributed RevenueCat purchase + restore.
11. Re-test account deletion end-to-end in production-equivalent environment.

Exit condition:
Every canonical P0 gate is CLOSED.

## Phase 4 — Research-informed differentiation

Task 8's scoped proposal is recorded in
`docs/plans/2026-09-11-research-scope-triage.md`. Optional expansions remain deferred
under the existing locked decisions; they are not unclosed 1.0 coding tasks.

Do this before release only when low-risk and explicitly accepted as part of scope; otherwise target 1.1+.

### High-value / relatively compatible
- shorten Home → useful action time,
- surface one-tap Reset more strongly,
- improve intent/time recommendations using current Home personalization,
- consumer-facing safer Emergency copy while preserving internal semantics,
- calm/non-punitive Leaves presentation,
- clearer continue/replay shortcuts,
- stronger cross-pillar recommendation logic.

### Medium/large scope
- five-tab navigation rebaseline,
- full Sleep mixer/saved mixes,
- offline audio downloads,
- expanded launch content to research quantity targets,
- onboarding redesign,
- privacy-minimal product analytics.

Before any item in this phase:
- read `docs/DECISION_CONFLICTS.md`,
- use Superpowers brainstorming,
- compare value against release risk.

## Post-release / 1.1–1.5

Potential bets:
- adaptive Reset recommendations,
- guidance intensity progression,
- richer Sleep routine replay/mixes,
- gentle reminders,
- Brain skill paths,
- weekly behavioral reflection,
- short multi-day programs,
- lock-screen/widget Reset,
- product efficacy research.

Avoid building large speculative systems before retention data supports them.

Resumed milestone: [Reset audio handoff](release/2026-09-12-reset-audio-handoff.md) cancels pending Sound on entry/return. Subsequent ambience cancellation is complete.

Reset ambience cancellation milestone passed 453 tests, clean analysis and Android build. Subsequent Memory Mirror 50-level progression is complete; bounded Sleep/Sound recheck found no additional demonstrable defect.

Memory 50-level milestone implemented and verified: 462 full tests, clean analysis and Android APK. The subsequently identified subscription identity race is fixed; 467 full tests, clean analysis and Android build passed. Local web release build and all six resource assertions also passed; see release/2026-09-12-programme-verification.md. Owner/content and production-equivalent device/store gates remain open.
