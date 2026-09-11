# Releaf Current State

Snapshot: **2026-09-11**  
Repo: `keisaj9006/releaf_app`  
Branch: **`releaf-development`**  
Snapshot HEAD: **`7a422a753f2a048ed254aa1db008fcb2c30d0cbb`**  
HEAD message: `feat: add guided Reset movement visuals`

This file is a working snapshot. The code and canonical release gate remain authoritative if the branch moves.

## Key release status

The current canonical source is:

`docs/release/releaf_1_0_release_gate.md`

Its current high-level state:

| Area | Current release-gate status |
|---|---|
| RESET core | DONE |
| BRAIN core | DONE / QA |
| Sleep player/timer | DONE / CONTENT |
| Meditation player | DONE / CONTENT |
| Account auth | DONE / QA |
| Account deletion | CODE READY / EDGE DEPLOY + SECRET REQUIRED |
| Emergency privacy/access | DONE |
| Progress sync | DEFERRED / HARDENED |
| Supabase security | DONE / MONITOR |
| Android API level | DONE |
| Android release signing | PREPARED / SECRET REQUIRED |
| Release AAB | CI DONE / PROD SIGNING REQUIRED |
| RevenueCat / Google Play Billing | CODE READY / EXTERNAL CONFIG REQUIRED |
| Privacy policy | BLOCKED |
| Web account-deletion URL | CODE READY / PUBLIC DEPLOY REQUIRED |
| Google Play health declaration | CONTENT READY / PLAY CONSOLE SUBMISSION REQUIRED |
| Store listing | COPY READY / ASSETS + PLAY ENTRY REQUIRED |
| Google Play Data safety | CONTENT READY / VERIFY + PLAY SUBMISSION REQUIRED |
| Versioning | OPEN |
| Device release QA | AUTOMATION READY / PHYSICAL DEVICE RUN REQUIRED |
| Play closed testing | PLAN READY / ACCOUNT CHECK + PLAY RUN REQUIRED |

Do not duplicate this table as a new authority; update the release gate itself when a gate actually changes.

## RESET / Relief

Current architecture contains:
- canonical Reset catalog/model,
- access policy,
- session programs,
- breath patterns,
- completion history,
- audio preferences,
- voice playback,
- progress summary,
- preview/session gates,
- breathing/Reset player,
- multiple first-party visual treatments,
- reduced-motion support paths,
- latest guided movement-demo visual integration.

Current access policy deliberately keeps internal Emergency content outside Premium entitlement.

The latest branch commit adds guided Reset movement visuals and associated quality tests.

### Historical user direction still relevant

Reset should be one of Releaf’s strongest experiences:
- immediate,
- easy to understand,
- strong audio/visual guidance,
- no requirement to “figure out” what to do,
- natural breathing cues,
- same premium narrator identity where recorded guidance is used,
- no overcomplicated ratios or aggressive breathwork.

## BRAIN

Current game registry contains **15 registered games**:

1. Memory
2. Labyrinth
3. Math Race
4. Broken Mirror
5. Rule Shift
6. Sequence Echo
7. N-Back
8. Spatial Span
9. Mental Rotation
10. Trail Switch
11. Tower Plan
12. Symbol Code
13. Color Conflict
14. Pattern Logic
15. Signal Scan

Current Brain infrastructure also contains:
- canonical registry,
- canonical host/result flow,
- training controller,
- progression/history,
- personal best/history data,
- sync-event preparation,
- Brain UI,
- difficulty support for many games.

Current controller uses progressive levels up to 12 for registered progressive games.

### Recent branch/project progress

Recent project work immediately before this snapshot reported:
- Labyrinth: selectable Easy/Medium/Hard, 50-board/stage architecture, progression/lifecycle protections.
- Math Race: Easy/Medium/Hard, difficulty selection locked after start, restart allows reselection.
- Brain total: 15 games already present.
- prior automated verification at commit `1fd44b7` was reported green, including analyzer/tests/build checks.

Current HEAD is one commit ahead of `1fd44b7`, adding Reset movement visuals/tests. Therefore **rerun the full automated baseline before carrying forward any “all green” claim**.

### Historical specific game contracts

Memory/Memory Mirror target discussed in project work:
- 50-level progression concept,
- time remaining + current level,
- matched cards disappear,
- centered/scaled grid,
- saved progress,
- stats including mistakes/time/trends,
- progress/stat reset,
- difficulty scaling,
- success increments,
- friendly failure copy.

Labyrinth target discussed in project work:
- ball/maze interaction using accelerometer,
- real collision logic,
- level visual/map,
- 50 levels/stages,
- timer,
- saved progression,
- win/lose handling,
- central goal,
- progressively harder geometry/ball tuning.

Inspect current code/tests before changing either; much of this has already been implemented/hardened.

## Meditation

Current architecture includes:
- meditation catalog/domain model,
- meditation library controller,
- meditation player,
- session gate,
- separate ambience controller,
- separate recorded voice controller,
- resume state,
- production/voice documentation.

### Releaf Guide contract

Current code states:
- speed: **0.82×**
- voice: selected female British-English meditation narrator
- natural, warm, calm, intimate, premium
- no whisper/ASMR
- no system/device TTS substitution
- exact provider voice ID not preserved
- production rendering remains blocked until the exact ID is recovered or a deliberate approved replacement is chosen.

### Mixing

Current meditation audio architecture already separates:
- ambience enable/mix,
- recorded voice enable/volume/captions.

Do not collapse these layers.

### Remaining content dependency

The canonical release gate says the meditation player is engineering-done/content-dependent. Final approved Releaf Guide recordings remain a content dependency.

## Sound / Sleep

Current bundled canonical sound catalog contains 10 real tracks:

- Releaf Atmosphere I — free
- Releaf Atmosphere II — premium
- Brown Noise — free
- Soft Rain — free
- Night Air — free
- Ocean Wash — premium
- Forest Canopy — premium
- White Noise — premium
- Pink Noise — premium
- Deep Drift — free

Current player/timer is release-gated as DONE/CONTENT.

Sleep must not contain narration.

The user previously reported timer/seek/audio UX defects during development; later project work reported the ±10-second seek fix and the current release gate marks player/timer behavior as tested. Treat those earlier bug reports as historical unless reproduced.

## Home / personalization

Current `HomeFocus` preferences are:
- Feel steadier
- Focus better
- Build mindfulness
- Sleep easier

This is a useful base for personalization but it is not yet the complete research concept of current-intent + available-time + behavioral recommendation logic.

## Navigation

Current bottom nav:
- Home
- Reset
- Brain
- Sound

Meditation and Sleep have routes but are not both persistent bottom tabs.

This differs from the Deep Research five-tab recommendation. Do not silently change it; see `docs/DECISION_CONFLICTS.md`.

## Leaves / progress

Current Leaves implementation:
- persists total leaves,
- resets only daily completion flags, not total earned leaves,
- awards per-pillar daily rewards,
- currently includes a bonus for completing the third daily pillar.

This already avoids destroying accumulated total progress on a missed day.

Research recommends simplifying Leaves further and avoiding multipliers/“perfect day” pressure. This is a known product conflict, not a release-gate blocker.

## Auth / backend / subscription

Current code contains:
- Supabase auth services,
- recovery and account UI,
- Supabase progress-sync transports/primitives,
- RevenueCat identity/service/controller,
- paywall triggers and UI,
- account deletion code paths,
- Supabase functions/migrations.

Progress sync remains intentionally **inactive/deferred for 1.0** as a user-facing cloud-backup claim.

## Tests / release infrastructure

The repo has broad automated coverage including:
- Brain flow,
- Reset access/catalog/session engine/audio/voice/lifecycle,
- meditation recorded narration/player controls/script readiness,
- audio interruption/background contracts,
- account/auth/recovery/deletion,
- RevenueCat/paywall,
- privacy/data safety/health compliance,
- progress sync primitives,
- Labyrinth lifecycle,
- release/Play contracts.

There are existing release docs for:
- Android device QA,
- Play closed testing,
- Data safety,
- health declaration,
- Store listing,
- Releaf 1.0 release gate.

Use and update them rather than starting a second release process.

## Current biggest blockers to actual public release

These are more important than adding optional features:

1. Deploy/verify account-deletion Edge function with required server secret.
2. Complete real RevenueCat + Google Play product/offering configuration and Play-distributed purchase/restore verification.
3. Configure production upload signing/private key outside repo.
4. Publish/finalize privacy policy details + stable HTTPS URL.
5. Deploy stable public account-deletion URL and verify it.
6. Complete Play Console health declaration.
7. Complete Data safety submission/verification.
8. Supply current Store listing assets/support/contact information and enter them in Play Console.
9. Set final version only at RC.
10. Run final production-equivalent physical-device QA.
11. Complete applicable Play closed-testing requirement and evidence.

## Manual testing

The owner has deliberately deferred repetitive manual phone testing during the engineering build phase.

Continue automated engineering and batch device QA at RC. Hardware-only behavior must still be included in the final device matrix.
