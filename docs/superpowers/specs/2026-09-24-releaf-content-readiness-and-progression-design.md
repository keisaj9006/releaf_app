# Releaf Content Readiness and Progression Design

**Date:** 2026-09-24

**Status:** Owner-approved direction; written specification awaiting owner review

**Branch:** `releaf-development`

## Intent

Evolve the existing Releaf application into a clearer, content-ready 1.0 experience without replacing working architecture. The work prepares Sleep for approved production materials, makes Reset easier to understand by user intent, adds a versioned introduction to meaningful changes, and extends every existing Brain game to a persistent 50-level progression.

Success means:

- users reach the right practice with less browsing and less visual density;
- the app can accept approved Sleep assets through a controlled local manifest;
- existing routes, public IDs, stored progress, reward rules, access rules and playback systems remain compatible;
- all 15 registered Brain games have meaningful progression through level 50;
- the first 12 Brain levels retain their existing behavior;
- safety, accessibility, offline use and release-size limits remain enforceable.

This is an evolution of the current architecture. It is not a redesign from scratch.

## Locked constraints

- Work remains on `releaf-development`; `main` is not modified.
- Existing routes, content IDs, persistence keys, progress records, reward semantics and player contracts remain stable unless this specification explicitly adds a versioned key or optional metadata.
- The current primary navigation remains unchanged during this programme. “Breath” in product discussion refers to the existing Reset destination, not a new primary route.
- Reset and Brain remain the main product pillars.
- Emergency-class Reset content remains free, subscription-independent, immediately accessible and outside ordinary progress behavior.
- Every implemented breathing method and its exact phase timing remains unchanged, including 5–5, 6–4 and all other current patterns.
- Breath-hold and rest phases remain silent. No synthetic hold cue is introduced.
- Missing approved human breathing recordings remain silent. Unapproved candidates are never activated in the runtime catalog.
- Meditation keeps the approved recorded Releaf Guide contract at 0.82× with separate narration and ambience layers. No device TTS or substitute narrator is allowed.
- Sleep remains sound-first. Nature and music content receive no narration. Narrated Sleep stories or guided Sleep meditation can ship only with approved, traceable recordings.
- Local progress remains the source of truth for Releaf 1.0. Cloud backup is not enabled or advertised.
- Leaves do not become a currency, shop, lives system or paid progression mechanic.
- No medical, diagnostic, treatment, “healing frequency,” IQ or brain-age claims are introduced.
- The rejected low-fidelity Reset direction board is not production artwork and is not implemented as such.

## Architectural approach

The implementation adds small, testable layers around existing catalogs and controllers:

1. a versioned “What’s New” presentation controller in front of normal Home entry;
2. a validated Sleep content intake manifest that promotes only approved local assets into the existing runtime catalog;
3. explicit Reset discovery metadata that groups the existing catalog into three user-facing purposes;
4. deterministic 50-level profile resolvers for each Brain game, while retaining current level 1–12 profiles.

Existing playback controllers, game screens, route names, access checks and persistence services remain the integration points. Targeted extraction is allowed where a current screen or function is too large to test safely, but unrelated refactoring is out of scope.

## 1. Versioned “What’s New” entry

### User experience

On a normal root launch after an app update, Releaf shows one calm, scrollable full-screen “What’s New” presentation before Home. It summarizes only meaningful changes in that release and has one clear continuation action. Once dismissed or continued, it does not appear again for that release.

The screen must:

- fit a 320 dp-wide device and remain usable at 200% text scale;
- support screen readers, logical focus order and a clearly named continue action;
- avoid time-based auto-dismissal;
- avoid subscription marketing as the primary message;
- continue to Home without changing authentication or navigation state.

Emergency access, authentication recovery and explicit deep links must not be delayed by this screen. A launch that targets a non-Home route goes directly to its destination. Emergency access remains available through its established path.

### Data and persistence

Introduce a small immutable release-content record containing:

- `releaseId`, an explicit stable identifier for the shipped release content;
- heading and short introduction;
- a bounded list of change items;
- accessibility labels where visible copy alone is insufficient.

Persist the last acknowledged `releaseId`, rather than one permanent Boolean. A new release appears only when its release ID differs. Reinstalling or clearing local data naturally resets this local acknowledgement.

The current Home welcome/personalization flow must not create a second competing introduction. Its useful personalization action may remain available from Home, but the generic welcome card is retired or reduced once the versioned entry is active.

### Failure behavior

Failure to read or write acknowledgement state must never block app entry. The safe fallback is Home. A failed write may cause the screen to appear on a later launch; it must not corrupt other preferences.

## 2. Sleep content readiness and simpler discovery

### Intake manifest

Add a repository-owned, machine-validated manifest for every candidate Sleep item. Each entry contains:

- stable public content ID;
- category: Story, Nature, Sleep Meditation or Sleep Music;
- title and concise, non-medical description;
- local audio asset path;
- local artwork asset path;
- measured duration;
- Free or Premium access decision;
- creator/source and licence or ownership record;
- content approval state;
- rights clearance state;
- optional narration identity/provenance for narrated content;
- optional ambience or secondary-layer asset;
- release notes for editorial review.

The manifest is the intake boundary, not an alternate player. Only entries whose required files exist, whose access decision is explicit, whose rights are cleared and whose content is owner-approved can become runtime-ready. Draft or incomplete entries remain visible in repository QA reports but are excluded from runtime discovery and cannot open an empty player.

Runtime-ready local assets are bundled with the application and work offline. Releaf 1.0 does not add remote content downloads, streaming dependencies or cloud content synchronization.

### Validation and release budgets

A deterministic validation command reports:

- duplicate or malformed IDs;
- missing audio or artwork;
- unsupported formats;
- missing duration/access/provenance fields;
- approval or rights state that prevents release;
- references absent from the existing runtime catalog;
- aggregate source-asset size and expected release-budget impact.

Promotion into the runtime catalog is explicit and reviewable. The existing release-size budgets remain authoritative: source assets and built artifacts must stay within the checked thresholds. Asset compression must preserve listening quality and provenance.

### Sleep discovery hierarchy

The Sleep destination keeps existing routes and players but presents a clearer hierarchy:

1. **Continue Listening** when valid progress exists; otherwise one **Tonight** recommendation;
2. four stable category gateways: Stories, Nature, Sleep Meditations and Sleep Music;
3. a small, curated set of ready items for the selected category;
4. access to the existing broader Sound library where applicable.

The screen removes duplicated rails that present the same item repeatedly. Unavailable or pending content is not shown as if playable. Premium items may be previewed through the existing Premium access flow, without weakening entitlement checks.

### Playback contract

Existing exact seeking, progress recovery, play/pause, timer, fade-out, interruption and completion semantics remain in their current controllers. New manifest entries use those players rather than creating parallel playback logic.

Nature and music remain narration-free. Where a story or Sleep meditation has narration, narration and ambience stay on separate controllable layers. Missing approved narration results in silence or a non-runtime-ready item, never TTS or a substitute voice.

## 3. Reset discovery by purpose

### User-facing information architecture

The Reset destination is reorganized into three clear discovery groups:

1. **Breathing Methods** — the preserved breathing exercises and their exact existing timings;
2. **Calm for a Situation** — practices for moments such as an interview, presentation, conflict, overload or acute stress;
3. **Body & Mind Reset** — grounding, jaw/shoulder release, movement, thought-unhooking and other non-breath practices.

Emergency Calm remains visibly separate and immediately accessible. It is not placed behind Premium marketing, a long questionnaire or a discovery carousel.

Deep Reset practices appear inside the appropriate purpose group with a clear duration/access marker instead of forming another large competing rail. Existing Free/Premium access remains unchanged.

### Data model

Add a non-breaking discovery field for non-Emergency Reset content:

- `breathingMethods`;
- `situationalCalm`;
- `bodyMindReset`.

Existing `QuickResetCategory`, modality, level and access fields remain intact for compatibility. The new field controls presentation only. Every current catalog entry receives an explicit group in the catalog, so grouping does not depend on title parsing or fragile ID lists.

Emergency content retains its existing internal `isEmergency` semantics and bypasses ordinary grouping where required by safety and privacy rules.

### Session behavior

This milestone does not change breathing phase programs, player routes, reward idempotency or progress persistence. It improves guidance and presentation around them.

All sessions must continue to support:

- clear pause/resume behavior and safe application lifecycle handling;
- voice, silent and “no words” behavior where the current content supports it;
- independent optional ambience and cue controls;
- reduced-motion alternatives that still communicate the phase or action;
- large text without clipped primary controls;
- gentle dizziness/discomfort guidance that tells the user to stop or return to normal breathing without medical claims.

Production breathing audio remains a separate owner-review milestone. The audition mechanism must expose A/B/C candidates, separate inhale/exhale previews, representative preserved timings, volume control, speaker/headphone instructions and provenance. No candidate becomes the default without explicit listening approval.

## 4. Fifty-level progression for all Brain games

### Shared progression contract

All 15 registered games expose persistent levels 1–50. Existing Memory Mirror and Labyrinth 50-level contracts remain authoritative. The other games extend beyond their current level-12 cap.

The shared rules are:

- two completed sessions continue to advance one level;
- existing completion counts and stored progress remain valid;
- the effective level is derived from accumulated progress and clamped to 1–50;
- players at level 50 replay level 50 and improve personal-best metrics;
- difficulty choice adjusts the challenge within safe bounds but does not replace persistent progression;
- current reward timing and idempotency remain unchanged;
- no lives, energy, paid boosts, wait timers or score-based clinical claims are introduced.

Raising the cap may reveal a level above 12 for an existing user whose retained completion count already earned it. This is intentional: accumulated play is respected rather than discarded or rewritten.

### Compatibility for levels 1–12

For every game, level profiles 1–12 retain their current parameter values and gameplay behavior. The new resolver adds profiles 13–50. Tests snapshot or explicitly assert the legacy profiles before extension, preventing accidental rebalancing of already-earned levels.

Difficulty offsets are applied after selecting the persistent level and clamped within 1–50. Existing labels remain understandable and do not imply intelligence or health measurement.

### Progression bands

Levels are organized internally into five ten-level bands. The bands are neutral product structure, not a wellness rating:

- 1–10: establish the mechanic;
- 11–20: add one source of complexity;
- 21–30: combine complexity dimensions;
- 31–40: increase planning, interference or working load;
- 41–50: varied mastery profiles with controlled challenge.

Within each band, parameters advance deterministically. Level 50 must remain playable and repeatable; it is not tuned as an impossible terminal test.

### Game-specific challenge dimensions

Each resolver changes mechanics suited to its game instead of relying only on shorter timers:

| Game | Primary progression dimensions |
| --- | --- |
| Memory Mirror | Grid size, pair count, preview time and recall load, preserving its existing 50-level design |
| Labyrinth | Maze topology, path length, hazards/time budget and control tolerance, preserving its existing 50-stage architecture |
| Math Race | Operand range, operation mix, missing-value position, round count and response budget |
| Broken Mirror | Fragment count, rotation/placement precision, distractor similarity and assembly complexity |
| Rule Shift | Rule set size, switch cadence, conflicting cues and trial length |
| Sequence Echo | Sequence length, grid/choice space, presentation time and interference |
| N-Back | Bounded N value, stimulus pool, sequence length, lure density and response pace |
| Spatial Span | Board size, span length, presentation timing and spatial interference |
| Mental Rotation | Shape complexity, rotation angles, mirrored distractors and choice count |
| Trail Switch | Node count, alternating-rule complexity, distractors and route-planning load |
| Tower Plan | Disk/constraint complexity, target variation, move budget and planning depth |
| Symbol Code | Mapping size, trial length, option similarity and controlled remapping |
| Color Conflict | Palette/rule complexity, congruence ratio, response budget and sequence length |
| Pattern Logic | Rule combinations, missing-cell complexity, distractor quality and optional hint reduction |
| Signal Scan | Field size, target similarity, target count, distractor density and scan budget |

Hard safety caps apply to values that can become unusable on a phone, such as N-back depth, tiny touch targets, excessive grid density and response times. More advanced levels gain variety through combinations, not endless numerical escalation.

### Presentation and statistics

Each game shows the persistent level and enough context to understand the current challenge. Level completion flows into existing statistics and personal-best systems. A reset action, where already supported, remains explicit and scoped to that game’s progress.

No UI claims that progress measures IQ, brain age, diagnosis, school/work ability or protection from illness.

## Data migration and compatibility

- No existing public ID is renamed or recycled.
- New Reset grouping metadata is added to current catalog records without rewriting stored sessions.
- Brain level calculation continues to use existing completion data and storage keys; only the maximum and profile resolver expand.
- The “What’s New” acknowledgement uses its own namespaced, versioned preference and does not reuse progress or auth storage.
- Sleep intake metadata is repository and build-time data. It does not migrate user playback progress.
- Missing or corrupt new optional metadata fails closed: unavailable content is excluded, unsafe access is not granted, and existing stored data is not deleted.

## Accessibility, lifecycle and error handling

Every new or materially changed screen is verified for:

- 320 dp width and 200% text scale;
- screen-reader names, roles, values and traversal order;
- minimum practical touch targets;
- reduced-motion behavior;
- Android back behavior and pause/resume lifecycle;
- offline startup and local content playback;
- clear recoverable errors without exposing internal paths, secrets or account data.

Audio focus, interruption and long-duration timer behavior continue to require physical-device verification near the release candidate. Automated tests must cover state transitions even where hardware confirmation remains pending.

## Verification strategy

Implementation proceeds in small vertical milestones using test-driven development:

1. characterize current behavior with focused tests;
2. add failing tests for the next contract;
3. implement the smallest complete change;
4. run focused tests and `flutter analyze`;
5. run the full Flutter suite at each coherent checkpoint;
6. inspect the complete diff, update release evidence, commit and push only `releaf-development`;
7. build and install a fresh Android debug APK for milestones that materially change visible, audio or hardware behavior.

Required automated coverage includes:

- once-per-release “What’s New” persistence, direct-route bypass and preference failure fallback;
- Sleep manifest validation, approval gating, missing-asset behavior, access mapping and runtime catalog integrity;
- Reset group completeness, Emergency exclusion/free access, stable IDs and unchanged breathing programs;
- all 15 Brain level boundaries, preserved 1–12 profiles, levels 13–50, difficulty clamping, persisted progress and level-50 replay;
- widget coverage for compact/large-text layouts and meaningful accessibility semantics;
- existing playback, reward, entitlement and route contract suites.

## Delivery sequence

The approved implementation order is:

1. **Sleep content intake and discovery simplification** — enables material preparation and verifies offline/release-size constraints early.
2. **Versioned “What’s New” entry** — introduces the changed product clearly without delaying deep links or Emergency.
3. **Reset discovery restructuring** — maps all existing Reset content into the three approved user purposes while preserving session behavior.
4. **Brain 50-level expansion** — first shared progression infrastructure, then game families in recoverable batches, then cross-game consistency.
5. **Integrated device checkpoint** — visible flow review, playback checks and hardware-dependent evidence without purchase, deletion or production operations.

Each milestone receives its own focused conventional commit and release-evidence update. A milestone with pending owner audio/art review may be committed as engineering-complete while the corresponding release gate remains explicitly open.

## External and owner-review dependencies

The following remain outside automatic code completion:

- approved final Sleep audio, artwork, narration and documented rights;
- owner listening approval for Releaf Atmosphere II and any breathing A/B/C candidates;
- recovery or deliberate replacement approval for the exact Releaf Guide narrator identity where production recordings are missing;
- Samsung SM-S928B speaker/headphone review of audio balance and naturalness;
- long-duration timer, background playback, audio focus, accelerometer and production-equivalent billing checks;
- final store assets, store-console actions and production signing/publication.

These dependencies remain visible in release evidence and do not block independent engineering work.

## Acceptance criteria

This programme increment is complete when:

- the once-per-version entry behaves correctly without blocking direct or Emergency access;
- Sleep accepts only validated, rights-cleared, owner-approved local materials and presents a simpler discovery hierarchy;
- every non-Emergency Reset item has one explicit approved discovery group and Emergency remains free and immediate;
- all current breathing timings and session contracts are proven unchanged;
- every registered Brain game has tested, persistent and playable progression through level 50, with levels 1–12 preserved;
- analyzer and the complete automated suite pass;
- relevant Android builds and device checks are recorded honestly;
- release documentation distinguishes engineering completion from pending owner, hardware, store and production approvals.
