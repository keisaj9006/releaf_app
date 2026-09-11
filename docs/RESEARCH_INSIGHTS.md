# Releaf 2026 Deep Research — Codex Distillation

Source: owner-provided report, **“Releaf: Global Mental-Fitness and Wellbeing Product Strategy for 2026”**, supplied 2026-09-11.

Full source is preserved at:
`docs/research/DEEP_RESEARCH_2026-09-11.md`

This document translates research into product/engineering implications. It does **not** override the current release gate.

## Executive thesis

The market is mature in meditation, crowded in sleep audio and well-developed in standalone cognitive training.

The gap is not “more content”. The gap is helping the user move from:

> “I do not feel good / focused / settled right now”

to a useful action in seconds.

Core principle:

> **Compete on time-to-useful-action, not content volume.**

Related rule:

> **Do not make the user browse when the product can make a good recommendation.**

## Four-mode behavioral model

- RESET = regulate the present moment.
- BRAIN = deliberate short mental practice.
- MEDITATE = develop attentional/self-regulation skills over time.
- SLEEP = create a low-stimulation wind-down/sound environment.

Useful lifecycle:

**Need help now → practice a skill → train deliberately → wind down.**

## RESET

Research treats Reset as Releaf’s strongest strategic opportunity.

Recommended time pathways:
- 30 sec
- 2 min
- 5 min
- 10 min

Recommended design:
- immediate primary action,
- optional current-state/need choice,
- slow comfortable breathing,
- sensory orientation/grounding,
- short body release where appropriate,
- visual + optional haptic + restrained audio,
- eyes-closed usability after setup,
- designed reduced-motion mode.

Avoid:
- precision-game breathing,
- aggressive rapid breathing,
- default breath holds,
- medical physiology promises.

Research recommends moving away from consumer-facing “Emergency” wording unless Releaf truly provides crisis functionality.

## Retention

Research ranking:
1. immediate perceived usefulness,
2. low-friction routine,
3. personalization,
4. meaningful progress,
5. user-selected goals,
then gentle reminders/challenges.

Streaks/rewards are conditional, not the core retention mechanism.

Key principle:

> **Useful experience → confidence that opening Releaf is worth it → repetition → habit → progress identity.**

## Leaves

Research recommendation:
- Leaves = visible history of meaningful practice,
- missing a day removes nothing,
- no store,
- no consumable currency,
- no energy,
- no loot boxes,
- no competitive totals,
- no guilt-driven lost-streak mechanic.

Principle:

> **Accumulate progress; never punish absence.**

## Meditation

Do not compete on hundreds of sessions.

Research launch hypothesis:
- roughly 36–45 strong guided sessions,
- Foundations course,
- 5/10/15–20 minute options,
- narrow useful themes,
- guided / less-guidance / unguided options.

Player priorities:
- reliable playback,
- separate narration/ambience volume,
- pause/resume,
- subtle timeline,
- favorite,
- download later/where justified,
- 15-sec rewind,
- background/lock-screen behavior,
- recommended next session.

The current repo already implements separate narration and ambience; preserve that.

## Sleep

The no-narration core direction is strategically defensible.

Research recommends:
- high-quality nature/noise/ambient/environment sounds,
- simple mixability rather than giant catalogs,
- approximately 3 simultaneous environmental layers + optional ambient/music,
- saved mix,
- timer,
- fade,
- replay last mix,
- no “frequency healing” positioning.

Responsible framing:
- winding down,
- preference,
- masking distracting noise,
not guaranteed deeper sleep, REM improvement or insomnia treatment.

## Brain

The proven engagement loop across cognitive apps is:

**short challenge → immediate result → slightly harder challenge → visible personal improvement → daily variation**

Avoid:
- Brain Age,
- IQ-like composite score,
- pseudo-clinical cognitive score,
- disease prevention claims,
- lives/energy/paid boosts,
- premium pressure before value.

Research proposed six launch skill categories:
- attention/inhibition,
- working memory,
- cognitive flexibility,
- visuospatial memory,
- pattern/processing speed,
- planning/problem solving.

The current repo already has 15 games. Map/polish existing games before considering new ones.

Potential current analogues:
- Signal Scan ↔ research Signal Sweep
- Sequence Echo ↔ Sequence Garden
- Rule Shift ↔ Switchback
- Spatial Span/Labyrinth ↔ Route Recall
- Pattern Logic ↔ Pattern Pulse
- Tower Plan ↔ Plan Ahead

These mappings are conceptual; audit gameplay before renaming.

## Home / information architecture

Research Home principle:

> **What do you need right now?**

Suggested flow:
- immediate intent,
- short recommended action,
- Continue,
- small current routine modules.

Avoid:
- five carousels,
- giant content feed,
- promo-heavy Home.

Research-proposed persistent nav:
`Home | Reset | Brain | Meditate | Sleep`

Current repo differs. Treat that as a deliberate future/rebaseline choice.

## Personalization

Research recommends simple transparent rules before AI.

Signal categories:
- current context (need/time),
- stable preference,
- behavior (completion/replay/favorite/early exit),
- Brain performance.

Conceptual recommendation weighting:
- 35% intent
- 25% time
- 20% past positive response
- 10% stated preference
- 10% novelty/avoid repetition.

Do not market it as AI.

Do not collect sensitive health history merely to personalize recommendations.

## Onboarding

Research target:
- under 2 minutes,
- first meaningful Releaf experience before forced account/paywall,
- goal/time preference can be skipped,
- request notification permission after value,
- premium offer after the user understands the product.

Audit the existing bootstrap/auth/paywall flow before changing it.

## Visual system

Use the leaf/living form as a material language rather than a logo stamped everywhere.

State-specific behavior:
- Reset — organic settling,
- Meditation — slow/spacious,
- Sleep — barely perceptible,
- Brain — crisp/responsive.

Accessibility must include a designed reduced-motion alternative.

## Responsible claims

Use language such as:
- quick breathing practice,
- pause/reset,
- practice attention/memory/problem solving,
- track in-app game performance,
- sound environment for winding down.

Reject:
- treatment/cure/prevention,
- panic-stop promises,
- ADHD claims,
- insomnia cure,
- IQ improvement,
- cognitive-decline prevention,
- vagus/cortisol marketing,
- REM/deep-sleep guarantees,
- “clinically proven” without exact product-specific evidence.

## Research 1.0 capability target

Research recommends:
- Reset 30 sec / 2 / 5 / 10 min,
- excellent multimodal breathing engine,
- six polished adaptive Brain games,
- three-game daily Brain workout,
- ~36–45 meditation sessions,
- ~24–30 sleep audio assets,
- simple Sleep mixer,
- robust background player/mini-player/lock controls,
- lightweight personalization,
- progress + Leaves,
- sub-2-minute onboarding,
- accessibility,
- selective offline downloads,
- safety/privacy boundaries,
- analytics.

Because the actual repo is further along in some areas and differently scoped in others, use `docs/DECISION_CONFLICTS.md` and the release gate rather than blindly implementing this list.

## Instrumentation recommended by research

Useful outcome/product metrics:
- app-open → session-start time,
- session completion,
- abandonment in first 30 sec,
- replay,
- favorite,
- recommendation acceptance,
- Reset “better / same / not for me”,
- Brain voluntary replay,
- Sleep same-mix replay,
- content-search depth before playback,
- subscription conversion after meaningful use.

Do not optimize session duration as a vanity metric.

## Research-informed priority improvements

1. One-tap signature Reset / shorter time-to-action.
2. Intent/time-first Home.
3. Non-punitive, quieter Leaves.
4. Reliable reusable audio architecture.
5. Quality/curation over Brain game count.
6. Safer consumer wording around Emergency.
7. Sleep built around repeatable sound routines/mixing.
8. Small structured meditation curriculum.
9. Rule-based personalization before AI.
10. Privacy/reliability as product features.

## Do not build yet

- AI therapist
- open social community
- leaderboards
- complex virtual economy
- sleep-diagnosis tracking
- brain age
- IQ tests
- personality engagement-bait
- hundreds of meditations for volume
- sleep stories as a major strategy
- healing frequencies
- “vagus hacks”.

## Long-term / 1.1+ bets

Only after core release/retention:
- adaptive Reset recommendations,
- guidance intensity that fades with skill,
- smarter saved Sleep routines,
- gentle context-aware reminders,
- Brain skill paths,
- weekly behavioral reflection,
- short programs,
- widgets/lock-screen Reset,
- optional wearable context,
- product-specific efficacy research.
