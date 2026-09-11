# Releaf — Codex Agent Instructions

## Mission

Finish and release **Releaf 1.0** from the existing Flutter application. Do not restart, replatform, or rebuild working features simply because a cleaner architecture is imaginable.

Repository: `keisaj9006/releaf_app`  
Working branch: **`releaf-development`**  
Default/main branch: `main` — **do not modify it unless the owner explicitly changes this rule**.

Snapshot used to prepare this context pack: 2026-09-11, `releaf-development` at commit `7a422a753f2a048ed254aa1db008fcb2c30d0cbb` (`feat: add guided Reset movement visuals`).

## Authority order

When information conflicts, use this order:

1. **Current code on `releaf-development` and the canonical release gate**
   - `docs/release/releaf_1_0_release_gate.md`
2. **Explicit locked decisions**
   - `docs/PRODUCT_DECISIONS.md`
3. **Verified repository state**
   - `docs/CURRENT_STATE.md`
4. **Completion roadmap**
   - `docs/ROADMAP.md`
   - `docs/plans/2026-09-11-releaf-1.0-completion-plan.md`
5. **Existing specialist repo documentation**
   - audio, Reset evidence, Releaf Guide, progress sync, release documentation
6. **Deep Research**
   - `docs/RESEARCH_INSIGHTS.md`
   - `docs/research/DEEP_RESEARCH_2026-09-11.md`

Deep Research is evidence and strategy, **not an automatic migration instruction**. When it conflicts with the current release gate or an implemented/approved flow, flag the conflict and follow `docs/DECISION_CONFLICTS.md`.

## Working method — use Superpowers

Use the installed Superpowers workflows as appropriate.

- Before a material product/UX/architecture change: use the **brainstorming** workflow.
- For a multi-step implementation: write/follow an implementation plan.
- For every feature or bug fix: use **test-driven development** where practical.
- For unexpected behavior or failed tests: use **systematic debugging** before proposing a fix.
- Before claiming a task is complete: use **verification-before-completion**.
- Request/review code changes rigorously before integration when the change is substantial.
- Prefer small verified batches over a giant rewrite.

Do not perform ceremonial planning for a trivial change, but never make broad architectural changes without first understanding the existing implementation.

## Start every work session like this

1. Confirm:
   - repository root,
   - `git status`,
   - current branch is `releaf-development`,
   - current HEAD.
2. Read:
   - this file,
   - `docs/release/releaf_1_0_release_gate.md`,
   - `docs/CURRENT_STATE.md`,
   - `docs/PRODUCT_DECISIONS.md`,
   - `docs/ROADMAP.md`,
   - `docs/DECISION_CONFLICTS.md`.
3. Inspect the relevant code/tests before editing.
4. Run the smallest useful baseline verification.
5. Work from the highest-priority open release gate or agreed roadmap item.

## Non-negotiable engineering rules

- Never work on or push directly to `main`.
- Never commit secrets, private signing keys, service-role keys, RevenueCat secret keys, Play credentials, or `key.properties`.
- Never fabricate a secret, production endpoint, privacy-policy URL, provider voice ID, billing product ID, or store configuration.
- Do not enable runtime cloud progress sync until its materialization and multi-device conflict requirements are actually complete.
- Do not claim cloud backup while local progress remains the release truth.
- Do not replace the approved Releaf Guide narrator with a guessed voice.
- Do not put narration into the core Sleep experience.
- Do not turn medical/wellness copy into diagnosis, treatment, cure, prevention, or guaranteed physiological claims.
- Do not add an AI therapist, open social feed, leaderboards, brain-age/IQ score, complex virtual economy, sleep-diagnosis score, or “healing frequency” claims for 1.0.
- Do not delete or replace working Brain games merely to match names proposed by research.
- Preserve user data and migration behavior unless a deliberate migration is part of the task.
- Do not weaken account deletion, privacy, RLS, premium access, Emergency access, or billing guards to make a test pass.

## Product model

Releaf is a consumer **mental-fitness and general-wellbeing** app.

Conceptual modes:

- **RESET** — regulate the present moment with fast, low-friction interventions.
- **BRAIN** — short cognitive games and deliberate mental practice.
- **MEDITATE** — guided attention/self-regulation practice with recorded narration plus dedicated ambience.
- **SLEEP** — low-stimulation sound environments; narration is not the core experience.

Supporting systems include Sound, Leaves/progress, account/auth, subscriptions, privacy/safety, and release infrastructure.

The product should optimize **time-to-useful-action**, not content volume or time spent browsing.

## Audio contract

### Meditation / Releaf Guide

The current code is authoritative:

- speed reference: **0.82×**
- narrator direction: selected female British-English meditation narrator
- delivery: natural, warm, calm, intimate, premium
- no whisper / ASMR
- recorded Releaf Guide voice only; no system TTS substitution
- narration and ambience are separate layers with independent control
- the exact provider voice ID is currently not preserved; production re-rendering remains blocked until it is recovered or the owner deliberately approves a replacement after auditioning.

Relevant files:

- `lib/core/audio/releaf_guide_contract.dart`
- `lib/features/meditation/application/meditation_voice_controller.dart`
- `lib/features/meditation/application/meditation_audio_controller.dart`
- `docs/meditation_audio_voice_quality_bar.md`
- `docs/releaf_guide_production*.md`

### Sleep

- No narrator in the core Sleep experience.
- Treat sounds as relaxation/wind-down/masking preferences, not a proven treatment for insomnia or a guarantee of deeper/REM sleep.
- Preserve reliable background playback, timer behavior, interruption handling and screen-off use.

## RESET safety/access contract

- Fast/basic relief must remain frictionless.
- Existing internal `isEmergency` semantics have safety/access/privacy meaning; do not remove those semantics casually.
- Emergency-class content is not Premium-gated and remains outside ordinary progress/sync behavior as defined by the release gate.
- Consumer-facing naming may be revisited, but internal safety semantics must survive a copy/IA change.
- Use gentle slow-paced breathing. Do not make aggressive hyperventilation or breath-hold patterns the default relaxation experience.
- Reduced-motion users must receive a designed alternative, not simply a blank/disabled animation.

## BRAIN contract

The current registry contains 15 games. Treat them as existing product assets.

Research recommends a polished six-game launch portfolio; interpret that as a **quality/curation principle**, not permission to delete current games.

- No “Brain Age”, IQ score, diagnosis or claim that game gains automatically transfer to intelligence, ADHD, dementia prevention, school/work performance, etc.
- Prefer in-app metrics: game performance, personal best, current level, accuracy, response speed, consistency, category trends.
- Difficulty should feel adaptive/challenging but achievable.
- No lives, energy meter, paid boosts, or wait timers.

Specific historical product requirements that remain important during QA:
- Memory/Memory Mirror: persistent progression, timed levels, visible level/time, disappearing matches, scalable centered grid, statistics/trends, reset option, clear success/failure behavior.
- Labyrinth: accelerometer control, robust collisions, logical maze, 50-stage progression, timer, persistent level, clear win/lose flow, accessibility/pausing/lifecycle safety.

Do not assume an old chat requirement is still missing; inspect the current implementation and tests first.

## Leaves/progress

- Progress must accumulate; missing a day must not remove earned progress.
- Do not turn Leaves into a shop/currency economy.
- Current code still contains a third-pillar daily bonus. Research recommends simplifying Leaves further; see `docs/DECISION_CONFLICTS.md` before changing it.
- Do not generate mental-health, stress, brain-age, wellness-age, disorder-risk or pseudo-clinical scores from consumer usage data.

## Manual testing cadence

The owner intentionally deferred repetitive manual phone testing while the engineering pass continues.

Therefore:

- keep automated verification strong during development,
- do not stop after every small change to ask for phone testing,
- batch physical-device verification near the release candidate,
- still flag changes that **cannot** be credibly validated without hardware (accelerometer, haptics, Android back gesture, background audio behavior, Play-distributed billing, performance).

The release gate still requires the final production-equivalent physical-device QA pass.

## Verification

Use the repo’s existing CI/release contracts first. At minimum for relevant changes:

```bash
flutter pub get
flutter analyze
flutter test
```

For Android/release changes, use the existing release docs/workflows rather than inventing new signing or billing procedures.

A task is not complete because code “looks right”. Completion requires:
- appropriate tests,
- analyzer clean,
- affected flows verified,
- no release-gate regression,
- clear report of what was verified and what remains external/manual.

## Definition of Releaf 1.0 complete

`docs/release/releaf_1_0_release_gate.md` is canonical.

Do not say “Releaf 1.0 is release-ready” until **every P0 gate is closed**, a production-equivalent Android release artifact passes required QA, and required external Play/Supabase/RevenueCat/privacy steps are complete.
