# Releaf Product Decisions

Status labels:

- **LOCKED** — treat as current product rule unless the owner explicitly changes it.
- **CURRENT** — describes present implementation; can evolve through deliberate design work.
- **RESEARCH TARGET** — strategically recommended but not automatically approved as a release-scope rewrite.
- **DEFERRED** — intentionally not part of current 1.0 execution.
- **FORBIDDEN FOR 1.0** — do not build.

## Positioning

### LOCKED
Releaf is a **mental-fitness / general-wellbeing** consumer app, not a diagnosis or treatment product.

### LOCKED
Core conceptual areas are:
- RESET
- BRAIN
- MEDITATE
- SLEEP

Sound, Leaves/progress, account/subscription and safety infrastructure support those experiences.

### LOCKED
The app should feel premium, calm and distinctive, while reducing cognitive load.

## RESET

### LOCKED
RESET is a core signature experience and should get the user into something useful quickly.

### LOCKED
Basic/urgent relief must remain meaningfully accessible. Internal Emergency-class content is not Premium gated.

### LOCKED
The user should not need to infer how to perform an exercise. Use clear visual guidance, natural sound, haptics where appropriate and concise instructions.

### LOCKED
Reduced-motion behavior must remain designed and usable.

### RESEARCH TARGET
Make Reset a one-tap signature action (“Releaf Now” is the research working name), with 30 sec / 2 min / 5 min / 10 min pathways and optional current-need chips.

The name **Releaf Now** is not locked merely because research proposed it.

### RESEARCH TARGET
Rename consumer-facing “Emergency” terminology to a less medical/crisis-implying term such as Reset Now / Quick Reset / Need a Moment, while preserving internal safety/access semantics.

## Breathing

### LOCKED — owner correction, 12 September 2026
Preserve all implemented method names, IDs, order and phase durations. Use authentic,
professionally recorded nasal inhale/slow exhale cues, never synthetic airflow or
nature sounds as substitutes. Prepare at least three licensed/original candidates
outside runtime assets for owner listening on Samsung speaker and headphones.
No cue may ship without explicit listening approval. Breathing cues, narration and
optional ambience have independent controls; fully silent use remains available.
Hold/rest phases have no breathing cue; synthetic hold sounds require separate
owner approval. See the exact [canonical master audio contract](plans/2026-09-12-releaf-master-prompt.md).

### LOCKED
Use comfortable, slow-paced breathing as the mainstream relaxation direction.

### LOCKED
Do not build claims around “vagus activation”, cortisol reduction or guaranteed fight-or-flight shutdown.

### LOCKED
Do not make aggressive rapid breathing or default breath holds central to Reset.

### CURRENT
Reset has custom breathing/visual infrastructure and dedicated breath-cue assets.

## Meditation

### LOCKED
Meditation has a consistent Releaf narrator identity plus dedicated relaxing background ambience.

### LOCKED
Narration and ambience are separate layers.

### LOCKED
Current approved narration speed reference is **0.82×**.

### LOCKED
Voice direction:
- female,
- British-English feel,
- natural,
- warm,
- calm,
- intimate,
- premium,
- no whisper/ASMR.

### LOCKED
Do not use a device/system TTS voice as a silent replacement for missing approved recordings.

### LOCKED
Do not guess the missing exact provider voice ID.

### RESEARCH TARGET
Structured curriculum > giant “Netflix of meditations”.
Research launch target: roughly 36–45 strong sessions, narrow themes, duration and guidance filters.

Content quantity is a strategic target, not permission to block an otherwise valid release gate without a deliberate scope rebaseline.

## Sleep

### LOCKED
**No narration in the core Sleep experience.**

### LOCKED
Primary Sleep value is soundscape/ambient/noise/nature playback and a low-stimulation wind-down environment.

### LOCKED
Avoid “432/528 Hz”, healing-frequency, “deep sleep frequency”, guaranteed REM/deep-sleep and similar claims.

### RESEARCH TARGET
Sleep mixer:
- roughly 3 environmental layers + optional ambient/music layer,
- save/name mix,
- timer,
- fade,
- replay last mix,
- downloads later/when justified.

This is not currently a canonical 1.0 release blocker unless the release gate is deliberately rebaselined.

## Brain

### CURRENT / PRESERVE
There are already **15 registered games**. Do not replace them with six newly named research games.

### LOCKED
Quality, adaptive challenge and useful feedback matter more than game count.

### LOCKED
Do not use:
- Brain Age
- IQ score
- disease-prevention claims
- ADHD treatment/focus claims
- global cognitive-health score
- lives/energy/wait timers/paid boosts.

### LOCKED
Prefer:
- level,
- accuracy,
- response speed,
- personal best,
- game/category trend,
- consistency.

### RESEARCH TARGET
Curate a polished visible/daily subset representing:
- attention/inhibition,
- working memory,
- flexibility,
- spatial memory,
- processing/pattern reasoning,
- planning/problem solving.

Closest existing games should be evaluated before building anything new.

## Leaves / progress

### LOCKED
Earned progress must accumulate. A missed day must not delete/reset the user’s total earned progress.

### LOCKED
Leaves are not a spendable virtual currency.

### LOCKED
Do not build:
- Leaves shop,
- loot boxes,
- energy,
- paid boosts,
- competitive leaf totals.

### CURRENT
Current code awards a daily third-pillar bonus.

### RESEARCH TARGET
Simplify Leaves to quiet accumulated progress and remove pressure/multipliers if this can be done without destabilizing the current 1.0 path.

## Home / personalization

### CURRENT
Existing Home focus preferences:
- Feel steadier
- Focus better
- Build mindfulness
- Sleep easier

### RESEARCH TARGET
Home should become more intent-first and recommendation-first:
- what do you need right now,
- available time,
- continue/replay,
- one useful recommendation rather than a large content feed.

### RESEARCH TARGET
Launch personalization can remain transparent and rule-based rather than “AI”.

Research conceptual weighting:
- 35% current intent
- 25% available time
- 20% past positive response
- 10% stated preference
- 10% novelty / repetition avoidance

Do not market this as AI.

## Navigation

### CURRENT
Persistent nav is:
**Home | Reset | Brain | Sound**

### LOCKED — owner approval, 12 September 2026; implementation pending
The approved destination order is **Home / Reset / Meditate / Sleep / Brain**.
This supersedes the previous four-tab target, not existing route compatibility.
Emergency remains global, free and outside the tab destinations; Account stays
behind the avatar. This documentation update does not claim the new tabs are live.
See the [canonical master prompt](plans/2026-09-12-releaf-master-prompt.md).

## Monetization

### LOCKED
Do not put the highest-urgency basic Reset behind a paywall.

### LOCKED
Do not use deceptive or high-friction subscription/cancellation patterns.

### RESEARCH TARGET
Prove meaningful value before the strongest premium prompt.

### RESEARCH TARGET
Research pricing hypothesis:
- $8.99 monthly
- $59.99 annual
- 7-day premium trial

This exact pricing is **not locked** and must not be hard-coded without current RevenueCat/market decision.

## Safety / claims

### LOCKED
Never claim Releaf:
- treats/cures/prevents anxiety, depression, ADHD, insomnia or cognitive decline,
- stops panic attacks,
- boosts IQ,
- rewires the brain,
- activates the vagus nerve,
- lowers cortisol,
- increases REM/deep sleep,
- is clinically proven unless the exact Releaf intervention/claim has suitable evidence.

### LOCKED
If true crisis/emergency content is surfaced, Releaf must not imply that it replaces an emergency/crisis service.

## Privacy

### LOCKED
Minimize data collection.

### LOCKED
Do not collect detailed health/diagnostic data merely to make personalization sound sophisticated.

### LOCKED
Account deletion and privacy disclosures are release-critical.

## Scope exclusions

### FORBIDDEN FOR 1.0
- AI therapist/emotional companion
- open social community
- global leaderboards
- complex virtual economy
- brain age / IQ tests
- personality engagement-bait quizzes
- sleep diagnosis/risk scoring
- healing-frequency catalog
- huge sleep-story program
- hundreds of meditations simply for quantity.

## Testing cadence

### LOCKED
Do not repeatedly stop the engineering pass for manual phone testing. Maintain automated verification and batch physical-device QA at release-candidate stage, except when a hardware-only issue cannot be verified any other way.
