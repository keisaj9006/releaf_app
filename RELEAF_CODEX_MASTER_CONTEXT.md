# Releaf Codex Master Context

This file is the quick index. The detailed rules live in `AGENTS.md` and `docs/`.

## Mission
Finish Releaf 1.0 from the existing `releaf-development` branch. Do not restart the app or rewrite working systems for aesthetic architecture reasons.

## Canonical engineering truth
`docs/release/releaf_1_0_release_gate.md`

## Current snapshot
- repo: `keisaj9006/releaf_app`
- branch: `releaf-development`
- snapshot HEAD: `7a422a753f2a048ed254aa1db008fcb2c30d0cbb`
- latest snapshot change: guided Reset movement visuals
- Flutter/Dart app with Riverpod, GoRouter, Supabase, RevenueCat, audio stack, sensors and local persistence
- RESET core: done
- BRAIN core: done/QA, 15 registered games
- Sleep player/timer: done/content
- Meditation player: done/content
- Auth: done/QA
- biggest remaining 1.0 gates are release configuration, external deployment/policy/content/device validation rather than a wholesale core rebuild

## Product rules
- mental fitness/general wellbeing, not medical treatment
- RESET / BRAIN / MEDITATE / SLEEP conceptual modes
- compete on time-to-useful-action, not content volume
- Sleep: no narration
- Meditation: approved recorded Releaf Guide, 0.82× direction, separate narration + ambience
- do not guess narrator ID or use system TTS fallback
- basic urgent Reset stays accessible
- preserve internal Emergency privacy/access semantics
- no Brain Age/IQ/medical transfer claims
- no AI therapist/social leaderboards/complex economy for 1.0
- accumulated progress must not be destroyed by missed days
- manual device QA is batched near RC, not requested after every small engineering change

## Research rule
The Deep Research is strategically important, but it is not allowed to overwrite a mature codebase automatically.

Read:
- `docs/RESEARCH_INSIGHTS.md`
- `docs/DECISION_CONFLICTS.md`

Most important research direction:
**make the next useful choice smaller.**

## Execution
Read `CODEX_START_PROMPT.md` and follow `docs/plans/2026-09-11-releaf-1.0-completion-plan.md`.
