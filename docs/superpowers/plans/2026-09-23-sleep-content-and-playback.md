# Sleep Content and Playback Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build the reusable Sleep catalog and long-form playback foundation for Stories, Nature, sleep-specific Meditations and Sleep Music.

**Architecture:** Add a Sleep-owned editorial registry that references the existing Sound and Meditation catalogs, then extend the existing background playback boundary for finite Stories and persistent progress. Build discovery and Story UI on those verified interfaces without duplicating players.

**Tech Stack:** Flutter, Dart, Riverpod, SharedPreferences, audioplayers, audio_service, audio_session, go_router.

**Spec:** `docs/superpowers/specs/2026-09-23-sleep-content-and-playback-design.md`

## Global Constraints

- Work only on `releaf-development`; do not modify `main`.
- Categories are exactly Stories, Nature, Meditations and Sleep Music; `All` is a filter.
- Story collections are exactly Dream Classics, Night Mysteries, Fiction Escapes, Wonder Journeys and Drift Through History.
- Do not add an ElevenLabs runtime dependency or store a provider secret.
- Nature and Sleep Music stay narration-free; Stories and guided Sleep Meditations may use approved narration.
- Do not fabricate missing assets, durations, artwork, approval or Premium decisions.
- Preserve current Sound, Meditation, RevenueCat, auth, Emergency and legacy route behavior.

## Review Focus

- A catalog item referencing a removed Sound/Meditation ID must fail validation and remain unplayable.
- A Story without mastered audio must never expose a working play action or fallback voice.
- A `+10 s` seek near the end must clamp to duration, not jump by an accumulated interval.
- Restarted playback must restore only valid progress for the same content and clamp stale positions.
- A finite Story completion must not inherit the looping behavior used by Nature/Music.

---

### Task 1: Canonical Sleep domain and registry

**Files:**
- Create: `lib/features/sleep/domain/sleep_content.dart`
- Create: `lib/features/sleep/data/sleep_catalog.dart`
- Create: `test/sleep_catalog_test.dart`

**Interfaces:**
- Consumes: `SoundCatalog.getById(String)`, `MeditationCatalog.getById(String)` and `MeditationCatalog.getSeries(String)`.
- Produces: `SleepContent`, `SleepChapter`, `SleepCategory`, `SleepStoryCollection`, `SleepPlaybackSource`, and `SleepCatalog` query/validation methods.

- [x] Write tests asserting the exact four categories, exact five collections, unique IDs, valid canonical references and chapter lookup/clamping rules.
- [x] Run `flutter test --no-pub test/sleep_catalog_test.dart --reporter expanded` and confirm it fails because the Sleep domain is absent.
- [x] Implement the minimum immutable domain types and registry.
- [x] Register `ST-DC-004` as Dream Classics with Theo Silk and an explicit asset-pending state; do not invent duration, source, artwork or access assignment.
- [x] Reference existing nature/music sounds and the existing sleep meditation series without copying their source data.
- [x] Run the focused test, format changed Dart files and run `flutter analyze --no-pub`.

### Task 2: Persistent long-form progress

**Files:**
- Create: `lib/features/sleep/application/sleep_progress_store.dart`
- Create: `test/sleep_progress_store_test.dart`

**Interfaces:**
- Consumes: stable Sleep content IDs and optional chapter IDs.
- Produces: `SleepProgressRecord`, `SleepProgressStore.state`, `updatePosition`, `markCompleted`, `toggleFavourite`, `clear`, and ordered continue-listening records.

- [ ] Write failing tests for process restart, corrupt data, per-account local isolation where identity is available, clamping, completion and no cross-content overwrite.
- [ ] Implement queued SharedPreferences persistence with versioned keys and fail-closed decoding.
- [ ] Verify the focused tests and analyzer.

### Task 3: Playback mode and exact seeking

**Files:**
- Modify: `lib/features/sound/application/sound_player_controller.dart`
- Modify: `lib/features/sound/application/releaf_background_sound_driver.dart`
- Add or modify: `test/sound_experience_test.dart`
- Create: `test/sleep_long_form_playback_test.dart`

**Interfaces:**
- Consumes: `SleepPlaybackSource` plus an explicit `looping` or `finite` playback mode.
- Produces: one background playback path with exact clamped `seekRelative`, finite completion events and correct media repeat metadata.

- [ ] Add failing driver/controller tests proving looped sounds repeat and finite Stories stop once.
- [ ] Add boundary tests for `-10 s`, `+10 s`, zero, unknown duration and duration end.
- [ ] Extend the current driver/controller rather than creating another audio service.
- [ ] Verify focused Sound/Sleep tests and analyzer.

### Task 4: Story player and resume

**Files:**
- Create: `lib/features/sleep/presentation/sleep_story_player_screen.dart`
- Modify: `lib/routing/app_routes.dart`
- Modify: the existing router configuration file that registers Sleep/Sound routes.
- Create: `test/sleep_story_player_test.dart`

**Interfaces:**
- Consumes: `SleepCatalog`, the finite playback boundary and `SleepProgressStore`.
- Produces: one parameterized Story player route with artwork fallback, title, narrator, elapsed/remaining, play/pause, exact seek, scrubber, timer, progress and chapter capability.

- [ ] Write failing widget tests for asset-pending, free/Premium access, responsive layout, exact seek controls, loading/error/retry and progress restore.
- [ ] Implement the parameterized player and route; missing audio shows an honest unavailable state.
- [ ] Persist progress on meaningful position changes, pause, lifecycle transition and completion.
- [ ] Verify focused tests, analyzer and an Android debug build.

### Task 5: Sleep discovery

**Files:**
- Refactor: `lib/features/sleep/presentation/sleep_screen.dart`
- Create focused widgets under `lib/features/sleep/presentation/widgets/` only when they have independent behavior.
- Modify: `test/sleep_experience_test.dart`

**Interfaces:**
- Consumes: Sleep catalog queries and continue-listening progress.
- Produces: All/Stories/Nature/Meditations/Sleep Music filters, Featured/Tonight, Continue Listening, Popular and five Story collection rails with See All navigation.

- [ ] Write failing widget tests for taxonomy, ordering, asset-pending cards, subtle Premium state, narrow/large-text layout and legacy Sound access.
- [ ] Implement the registry-driven discovery surface in the existing Releaf design language.
- [ ] Route Sound references to the existing Sound player, Meditation references to the existing Meditation gate/player and Stories to the Story player.
- [ ] Verify focused tests, analyzer, full suite and Android build.

### Task 6: Release evidence and device checkpoint

**Files:**
- Modify: `docs/CURRENT_STATE.md`
- Modify: `docs/ROADMAP.md`
- Modify: `docs/release/releaf_1_0_release_gate.md`
- Create: a dated Sleep milestone under `docs/release/`.

**Interfaces:**
- Consumes: verified command output and actual hardware observations.
- Produces: honest release-gate evidence separating automation from owner/audio/device dependencies.

- [ ] Update older broad “Sleep has no narration” language to the precise approved rule: Nature/Music have no narration; Stories and guided Sleep Meditations may narrate.
- [ ] Record missing approved production audio/artwork and physical Bluetooth/background/lock-screen checks as open dependencies.
- [ ] Run `dart format`, `flutter analyze --no-pub`, focused tests, full tests and the ignored-config Android build.
- [ ] Inspect `git diff --check`, confirm no secrets/generated artifacts, commit and push only `origin/releaf-development`.
