# Releaf Project Context

## Product

Releaf is a Flutter-based consumer mental-fitness and general-wellbeing application.

It is not positioned as a medical diagnosis/treatment product. Its strongest product opportunity is to help a user go from “I do not feel good / focused / settled right now” to a useful low-friction action quickly.

The guiding product idea is:

> **Make the next useful choice smaller.**

And the practical competitive principle is:

> **Compete on time-to-useful-action, not content volume.**

## Conceptual modes

### RESET
Immediate state regulation and short interventions.

Purpose: help the user pause, settle, orient, breathe comfortably, release tension or regain direction in seconds/minutes.

Target interaction lengths from research:
- 30 seconds
- 2 minutes
- 5 minutes
- 10 minutes

RESET should feel like an action, not a huge content catalog.

### BRAIN
Short cognitive training and game-based practice.

Purpose:
- memory,
- attention/inhibition,
- flexibility,
- visuospatial skill,
- processing/reasoning,
- planning/problem solving.

Progress should describe performance **inside Releaf**, never pretend to diagnose intelligence or cognitive health.

### MEDITATE
Guided meditation and attention/self-regulation practice.

Key product direction:
- structured curriculum over content quantity,
- recorded narrator,
- dedicated background ambience,
- separate narration and ambience controls,
- local resume/reliable playback,
- progressively less guidance is a potential differentiator.

### SLEEP
Low-stimulation wind-down through sound.

Key direction:
- soundscape-first,
- no narrator as the core experience,
- reliable background playback,
- timer/fade/replay routines,
- no pseudoscientific frequency claims,
- no promise to treat insomnia or improve REM/deep sleep.

## Supporting systems

- **Sound** — reusable audio/sound library and playback infrastructure.
- **Leaves / Progress** — accumulated practice history and feedback.
- **Account/Auth** — Supabase-backed account flows.
- **Subscription** — RevenueCat / Google Play Billing.
- **Privacy/Safety/Legal** — general-wellness boundaries, account deletion, data disclosures.
- **Release infrastructure** — Android/Google Play release gate and QA documentation.

## Current technical stack

Verified from `pubspec.yaml` on `releaf-development`:

- Flutter / Dart SDK `^3.8.0`
- Riverpod
- GoRouter
- SharedPreferences
- Supabase Flutter
- RevenueCat (`purchases_flutter`)
- `audioplayers`
- `audio_session`
- `audio_service`
- `sensors_plus`
- `fl_chart`
- `wakelock_plus`
- Lottie
- URL launcher

Current pre-release app version in `pubspec.yaml`: `0.1.0+1`.

Do not set final `1.0.0+<build>` until the release-candidate stage defined by the release gate.

## Current architecture

Notable current modules:

- `lib/core/audio`
- `lib/core/paywall`
- `lib/core/session`
- `lib/core/subscription`
- `lib/core/sync`
- `lib/features/account`
- `lib/features/brain`
- `lib/features/home`
- `lib/features/legal`
- `lib/features/meditation`
- `lib/features/progress`
- `lib/features/relief`
- `lib/features/sleep`
- `lib/features/sound`
- `lib/games`
- `lib/routing`
- `lib/theme`
- `supabase/functions`
- `supabase/migrations`
- `test`
- `docs/release`

The repo also contains legacy/archive material. Prefer canonical feature modules over `legacy/`, `lib_backup/`, `_archive/` and stale tree-dump files.

## Current navigation

Current bottom navigation in code:

**Home | Reset | Brain | Sound**

Separate routes exist for:
- Meditation
- Sleep
- Account
- Privacy
- Daily Loop
- game/session/player routes.

Deep Research proposes a five-tab `Home | Reset | Brain | Meditate | Sleep` model. That is not automatically authoritative; see `docs/DECISION_CONFLICTS.md`.

## UX / visual direction

The app should feel premium, calm, legible and distinctive without becoming visually noisy.

Use a **living Releaf system**:
- Reset: organic settling motion
- Meditation: spacious/slower motion
- Sleep: barely perceptible motion
- Brain: crisper, more responsive, higher contrast

Motion should communicate state, not decorate it.

Reduced-motion mode must remain intentionally designed.

Avoid:
- casino-like reward feedback,
- confetti after meditation,
- noisy content feeds,
- overloaded home carousels,
- ultra-thin low-legibility type,
- generic “green gradient wellness clone” styling.

## Audio direction

### Meditation narrator

Canonical code contract:
- `Releaf Guide`
- selected female British-English meditation narrator
- natural, warm, calm, intimate, premium
- no whisper / ASMR
- speed reference **0.82×**
- no system TTS fallback
- exact provider voice ID was not preserved; do not guess it.

### Meditation mixing

Narration and background ambience are separate layers. User controls/preferences must not collapse them into one baked audio file.

### Sleep

No narration in the core Sleep experience.

## Business model direction

RevenueCat/paywall infrastructure exists.

Research recommendation (not locked pricing):
- prove value before aggressive paywall exposure,
- core urgent Reset/basic breathing should remain meaningfully free,
- premium should primarily unlock depth, personalization, library breadth, detailed trends and advanced capabilities.

Any exact monthly/annual price remains a business decision unless the product owner explicitly locks it.

## Safety positioning

Good copy examples:
- “Take two minutes to pause and reset.”
- “Practice attention, memory and problem-solving games.”
- “Sounds for winding down.”
- “Build a meditation habit.”

Avoid claims such as:
- treat anxiety/depression/ADHD,
- stop panic attacks,
- cure insomnia,
- boost IQ,
- prevent cognitive decline,
- activate the vagus nerve,
- lower cortisol,
- trigger deep sleep / increase REM,
- clinically/scientifically proven unless Releaf-specific evidence supports the exact claim.
