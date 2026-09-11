# Releaf Current State

Snapshot: **2026-09-11**  
Repo: `keisaj9006/releaf_app`  
Branch: **`releaf-development`**  
Latest committed baseline: **`1b24990`** (account-deletion E2E evidence); subsequent
Meditation quality work is recorded in [milestone evidence](release/2026-09-11-meditation-guidance-quality.md).

Subsequent internal quality work is tracked in
[batch evidence](release/2026-09-11-internal-quality-batches.md), including
recorded-audio cancellation during configuration and source loading, Sleep timer
boundaries/ordering, all 30 browsable Daily Insights, large-text Home layouts and
consistent difficulty controls across all 15 Brain games. Latest full suite:
**383 tests passed** after the Meditation milestone; analyzer clean and Android
debug build passed. No production/device verification is implied.

This file is a working snapshot. The code and canonical release gate remain authoritative if the branch moves.

## Key release status

The current canonical source is:

`docs/release/releaf_1_0_release_gate.md`

Its current high-level state:

| Area | Current release-gate status |
|---|---|
| RESET core | DONE / CONTENT |
| BRAIN core | DONE / QA |
| Sleep player/timer | DONE / CONTENT |
| Meditation player | DONE / CONTENT |
| Account auth | DONE / QA |
| Account deletion | DONE / E2E VERIFIED |
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

Guided Reset movement visuals and associated quality tests are implemented.
Recorded-audio cancellation has since been hardened. Existing breathing tones
were rejected by the owner; replacement content approval remains open. Manifest
readiness distinguishes asset presence from approval.

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
- shared Easy/Medium/Hard controls across all 15 canonical game flows.

Current controller uses progressive levels up to 12 for registered progressive games.

### Recent branch/project progress

Recent project work immediately before this snapshot reported:
- Labyrinth: selectable Easy/Medium/Hard, 50-board/stage architecture, progression/lifecycle protections.
- Math Race: Easy/Medium/Hard, difficulty selection locked after start, restart allows reselection.
- Brain total: 15 games already present.
- prior automated verification at commit `1fd44b7` was reported green, including analyzer/tests/build checks.

The historical audit started from the Reset movement change `7a422a7` plus its
context pack. That checkpoint passed **333 tests**, clean analysis, **9 focused
Reset guidance/lifecycle tests**, and a web release build/resource contract.
See `docs/release/2026-09-11-repository-audit.md` for its scope. Subsequent
implementation has moved beyond that snapshot; current evidence is linked above.

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

Library, Premium preview and player now disclose recorded, partial, captions-only
or unguided availability. Incomplete narration starts with usable on-screen
guidance without changing the saved caption preference on entry. Caption controls
and large-text layouts have regression coverage; silent partial steps do not
promise a voice. See the Meditation milestone evidence above.

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

The canonical release gate says the meditation player is engineering-done/content-dependent. Final approved Releaf Guide recordings remain a content dependency. The freshly exported production manifest has **20 guided sessions / 103 steps**, with **4 recorded steps** (all in `mindfulness-basics-2`) and **99 steps still to render**. Recorded-path metadata does not replace decoding, listening or approval QA.

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

The initial read-only audit found outdated account-deletion code and **0 security-advisor lints**. Subsequent deployment on 2026-09-11 replaced outdated live version 3 with **version 4**, ACTIVE with JWT verification. Secret name presence was verified without reading its value; deployed source matches the repository. Three unauthenticated/invalid-auth POST checks returned **401**. A later Samsung SM-S928B Test Store debug E2E run deleted only a dedicated disposable account after it was identified in RevenueCat. Post-checks found zero target Auth/profile/progress/Storage records and `Customer not found` in RevenueCat; the protected primary QA account remained present. See [deployment evidence](release/2026-09-11-delete-account-deployment.md). Repeat this flow on the production-equivalent RC as part of final device QA.

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

Approved content also remains open: the existing breathing tones were rejected,
natural-breath generation is blocked by Fal account balance, only
`mindfulness-basics-2` has approved recorded narration, and the exact Releaf Guide
provider identity is still missing. The separate Atmosphere II headroom candidate
is available under `audio-candidates/2026-09-11` for later listening approval;
the active source has not been replaced.

1. Complete real RevenueCat + Google Play product/offering configuration and Play-distributed purchase/restore verification.
2. Configure production upload signing/private key outside repo.
3. Publish/finalize privacy policy details + stable HTTPS URL.
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
