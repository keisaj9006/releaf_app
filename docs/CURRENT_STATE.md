# Releaf Current State

Snapshot: **2026-09-12**

Latest internal verification: **518/518 tests**, clean analysis, Android debug
build for [breathing visual lifecycle](release/2026-09-12-breathing-visual-lifecycle.md).
The animation now stops synchronously before background frames are suppressed,
preserving its cycle on return. No breathing patterns or timings changed.
ADB reported no connected device; installation and physical review remain pending.
Botanical lungs and Grounding visual-direction candidates remain unfinished.

[Approved Basics source measurements](release/2026-09-12-approved-narration-measurements.md)
now record its four narration files: 24 kHz, -24.4 to -24.9 LUFS, -5.7 to -7.8
dBTP. Separate Deep Drift measures -29.2 LUFS / -21.4 dBTP. Five scans exited 0
and all source hashes remained unchanged. This does not approve a new mix, voice,
candidate or device-listening result; no assets/runtime changed.

The [shared audio production standard](audio_asset_standard.md) now covers the
owner's Reset/Guide requirements alongside Sound/Sleep. Canonical master points
to this existing file. Twelve manifest tests passed and analysis was clean
(28.5 seconds); no audio, breathing method,
timing or approval status changed. New measurements and owner auditions remain
pending; the existing exporters do not certify licensing or listening acceptance.

Current [local release artifact checks](release/2026-09-12-local-release-artifact-checks.md)
on code `6610634`: web release built, all six workflow artifact assertions passed,
11 release/privacy contract tests passed, Android source checks passed and current
debug APK hash recorded. No deployment or new device installation; production
packaging/distribution and owner/hardware gates remain open.

Previous verification: **517/517 tests passed**, clean analysis and Android debug
build for [single SDK initialization](release/2026-09-12-sdk-single-initialization.md).
Overlapping configuration calls share one operation; failed configuration can be
retried. Last installed Samsung checkpoint remains `abb98f7`; this internal change
will be included with the next device review batch.

Previous checkpoint verification: **514/514 tests passed**, clean analysis and
Android debug build for [unresolved billing identity isolation](release/2026-09-12-unresolved-billing-identity.md).
Failed identity transitions cannot refresh old-account access; pending callbacks
and billing are blocked until the latest identity succeeds. Resume retries the
coordinator; password recovery no longer races a separate SDK login. Samsung
replacement installation passed. Production-equivalent billing QA remains open.

Subsequent verification: **510/510 tests passed**, clean analysis and Android
debug build for [runtime SDK key validation](release/2026-09-12-runtime-sdk-key-validation.md).
Runtime rejects secret/unknown key shapes while preserving public Test Store,
Google and Apple SDK configuration. The subsequent unresolved-identity gap is
corrected in the checkpoint above.

Earlier verification: **509/509 tests passed**, clean analysis and Android debug
build for [daily progress rollover](release/2026-09-12-daily-progress-rollover.md).
Samsung replacement installation succeeded. Home refreshes daily flags across
date changes; accumulated Leaves and existing reward/bonus semantics are preserved.
Overnight hardware QA remains pending.

Repo: `keisaj9006/releaf_app`  
Branch: **`releaf-development`**  
Owner device-review checkpoint: **`16a0f2c`**;
Sound recovery and Samsung review are recorded in
[checkpoint evidence](release/2026-09-12-device-review-checkpoint.md).
Owner resumed development after `16a0f2c`. Listening and long-duration device review remain pending and do not block independent work.

Subsequent internal quality work is tracked in
[batch evidence](release/2026-09-11-internal-quality-batches.md), including
recorded-audio cancellation during configuration and source loading, Sleep timer
boundaries/ordering, all 30 browsable Daily Insights, large-text Home layouts and
consistent difficulty controls across all 15 Brain games. Historical device-review suite:
**447 tests passed** for the review checkpoint; analyzer clean and Android debug
build passed. `adb install -r` succeeded on Samsung SM-S928B. Bounded physical UI
smoke passed; owner visual/listening review and the production device gate remain open.

Latest internal programme checkpoint: **482/482 tests passed**, analyzer clean and Android debug APK built and installed with `adb install -r` on Samsung SM-S928B. Five primary destinations, legacy Sound library access and narrow large-text layout fixes are implemented. All five screens passed bounded UI smoke; RevenueCat configuration, QA identity and current Offering were confirmed through boolean-only logs. See [five-tab evidence](release/2026-09-12-five-primary-destinations.md). Premium refresh continuity was committed as `f3a8795`; owner listening and production-equivalent QA remain pending. Next: Meditation contracts and Reset blueprints in the [remediation plan](plans/2026-09-12-meditate-reset-remediation.md).
This file is a working snapshot. The code and canonical release gate remain authoritative if the branch moves.

Subsequent tooling checkpoint: Meditation production export now validates timings,
IDs and source assets; tests verify actual Flutter bundle inclusion. Full suite
489/489 passed, followed by 13/13 focused tests including two additional review
checks; final analysis and Android build passed. Runtime remains the installed
five-tab checkpoint. See [manifest evidence](release/2026-09-12-meditation-production-manifest.md)
and the [22-session matrix](product/meditation-session-matrix.md). Unguided silence
by default is now implemented in the subsequent checkpoint below; missing approved recordings remain pending.

Unguided silence checkpoint: **495/495 tests passed**, analyzer clean, Android
debug build and Samsung `adb install -r` succeeded. Unguided 5 UI showed
`Ambience off` on entry and `Ambience` only after explicit opt-in. Both timers and
guided preference restoration are covered automatically. See
[evidence](release/2026-09-12-unguided-silent-default.md). No owner listening gate
is closed. Next: Reset blueprints and grounding progression.

Reset sensory progression now advances immediately after the target count,
without a delayed callback. **496/496 tests passed**, analysis and Android debug
build passed; independent review found no actionable issues. Samsung installation
could not run because the device was disconnected. See [evidence](release/2026-09-12-reset-immediate-progression.md)
and [Back to the Room blueprint](product/reset-back-to-room-blueprint.md).
Next confirmed gap: explicit labelled skip/ready controls in that session.

Subsequent sensory-control work adds ready/skip/finish actions to Back to the
Room, including an accessible arrow in no-words mode. Its large-text layout now
scrolls so controls remain reachable. See [verification](release/2026-09-12-reset-sensory-skip.md).
No breathing phases, catalogue durations or reward logic changed. Device review
is pending while Samsung is disconnected. Continue remaining Reset blueprints
and interruption coverage.

Sensory interruption coverage now verifies both paths preserve notices/time
through inactive/hidden/paused and resume. All 30 focused Reset contracts passed,
including two new tests; analysis is clean. Runtime is unchanged from `0a43fdf`.
The [ten-method timing matrix](product/breathing-method-evidence-matrix.md) matches
the fresh manifest, explicitly preserving actual 4–6 rather than inventing 6–4.
See [evidence](release/2026-09-12-reset-contract-coverage.md). Per-session production
blueprints and owner/hardware/content dependencies remain open.

The Reset exporter now supplies metadata and contiguous timelines for all 50
sessions. [Working production blueprints](product/reset-session-production-blueprints.md)
record the actual scripts and open approval/measurement fields; zero recorded
narration steps are declared and 217 guided steps await the approved voice.
See [evidence](release/2026-09-12-reset-production-blueprints.md). This does not
close content approval. Continue independent audio handoff/reliability checks.

Latest runtime checkpoint: Meditation entry cancels both playing and still-loading
Sound requests, closing a reproduced delayed-start race. **502/502 tests passed**,
analysis clean, Android build and Samsung `adb install -r` succeeded. Home startup
and boolean SDK configuration/Offering logs passed; no owner listening approval
is implied. See [handoff evidence](release/2026-09-12-meditation-sound-handoff.md).
Continue Progress/personalisation and remaining backend/release-quality work.

Home now refreshes time-dependent greetings/recommendations and Daily Insight
once per minute while foregrounded and immediately on resume. Its first-frame
startup respects background state. Sleep recommendation copy matches the actual
sound-first destination. See [evidence](release/2026-09-12-home-continuity.md).
Saved focus, recommendation priority, routes and reward logic are unchanged.
Next: separately verify daily progress date rollover and account-local state.

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
readiness distinguishes asset presence from approval. Runtime now excludes both
rejected tones, and cue switches disclose unavailable audio without rewriting
saved preferences. Silent/reduced-motion phase labels remain visible and
semantic; the active audio sheet now has readable dark-theme text.

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
promise a voice. See [Meditation evidence](release/2026-09-11-meditation-guidance-quality.md).

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

Delayed starts now preserve the latest track/pause/stop choice in the controller
and both native drivers, including media-notification cancellation. Source
readiness controls resume, and ordered output writes preserve the latest volume.
Timer expiry cannot override a newer transport choice or leave the next Play
muted. Full player and mini-player now show loading/cancel and failure/retry;
system interruption recovery preserves later user and notification decisions.

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
- Meditate
- Sleep
- Brain

The owner approved this exact order on 12 September. Existing screens now use the
stateful shell. Sound remains a secondary library inside the Sleep branch; its
URL, favourites, recents and player routes are preserved. Meditate and Sleep have
direct Emergency/account shortcuts. See `docs/DECISION_CONFLICTS.md`.

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

Latest resumed milestone: [Reset audio handoff](release/2026-09-12-reset-audio-handoff.md), 449 full tests passed, analyzer clean and new debug APK built. Device unavailable; subsequent ambience cancellation is complete below.

Reset ambience lifecycle is now protected against delayed start after mute/background/exit; rapid return is tested. [Evidence](release/2026-09-12-reset-ambience-lifecycle.md): 453 full tests passed, analyzer clean, new APK built. Physical checks pending. Subsequent Memory milestone is complete below.

Memory Mirror now has 50 tested profiles, hosted/standalone progression and browsable charts. [Evidence](release/2026-09-12-memory-fifty-levels.md): 462 full tests, clean analyzer, Android debug build passed. Subscription isolation was subsequently implemented. No physical verification added.

[Consolidated resumed-programme evidence](release/2026-09-12-programme-verification.md): code checkpoint b4ca786, 467 tests, Android and web builds, web resource assertions, exact APK hash and remaining dependencies. No release-readiness claim.
