# Reset Discovery Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Reorganize the existing Reset catalog into Breathing Methods, Calm for a Situation and Body & Mind Reset while keeping Emergency and every session contract unchanged.

**Architecture:** Add explicit discovery metadata to `ResetContent` and populate it in the canonical catalog. Replace the dense quick/deep rail composition with a purpose selector and one focused list, while reusing the existing preview, access gate and player.

**Tech Stack:** Flutter, Dart, Riverpod, go_router, existing Reset domain/player code, `flutter_test`.

**Spec:** `docs/superpowers/specs/2026-09-24-releaf-content-readiness-and-progression-design.md`

## Global Constraints

- All current Reset IDs, programs, breathing timings, routes, access tiers, rewards and progress stay unchanged.
- Emergency content remains free, immediate and outside ordinary progress/privacy behavior.
- Hold/rest phases remain silent; missing approved breathing or narration assets stay silent.
- Reduced motion receives a meaningful static/low-motion phase representation.
- No rejected low-fidelity artwork becomes a production asset.
- Safety copy remains general-wellbeing guidance and avoids medical claims.

## Review Focus

- Every non-Emergency catalog entry must have exactly one discovery group.
- Emergency entries must never be mixed into Premium lists or gated by entitlement.
- Grouping must not depend on title text or a UI-maintained ID list.
- Changing the discovery group must not restart or mutate an active session.
- At 320 dp/200% text scale, selectors and start actions remain reachable without overflow.

---

### Task 1: Explicit Reset discovery metadata

**Files:**
- Modify: `lib/features/relief/domain/models/reset_content.dart`
- Modify: `lib/features/relief/data/reset_catalog.dart`
- Modify: `test/reset_catalog_test.dart`
- Modify: `test/relief_access_test.dart`

**Interfaces:**
- Produces: `enum ResetDiscoveryGroup { breathingMethods, situationalCalm, bodyMindReset }` and nullable `ResetContent.discoveryGroup` required by assertion for non-Emergency content.
- Consumes: existing `ResetLevel`, `QuickResetCategory`, `ResetModality`, `ResetAccessTier` and catalog entries.

- [ ] **Step 1: Snapshot protected behavior before editing**

Add a test that serializes every catalog item’s ID, duration, level, quick category, modality, access tier and complete program phase labels/durations. Store the expected digest/list in the test so grouping edits cannot alter session behavior unnoticed.

- [ ] **Step 2: Add failing group-completeness and Emergency tests**

```dart
for (final item in ResetCatalog.all) {
  if (item.level == ResetLevel.emergency) {
    expect(item.discoveryGroup, isNull, reason: item.id);
    expect(item.accessTier, ResetAccessTier.free, reason: item.id);
  } else {
    expect(item.discoveryGroup, isNotNull, reason: item.id);
  }
}
```

Also assert all three groups contain content, breathing content is in `breathingMethods`, and Emergency IDs remain unchanged.

- [ ] **Step 3: Run tests and confirm the missing field**

Run: `flutter test test/reset_catalog_test.dart test/relief_access_test.dart`

- [ ] **Step 4: Add metadata and classify every current entry**

Add the enum/field/assertion. Assign an explicit group in `reset_catalog.dart`: breathing modalities to Breathing Methods; situational practices to Calm for a Situation; grounding, movement, release, object/sound focus and thought-unhooking practices to Body & Mind Reset. Classify deep practices by purpose; do not change `level` or access.

```dart
enum ResetDiscoveryGroup { breathingMethods, situationalCalm, bodyMindReset }

const ResetContent({
  // Existing required fields remain unchanged.
  this.discoveryGroup,
}) : assert(
       level == ResetLevel.emergency
           ? discoveryGroup == null
           : discoveryGroup != null,
     );
```

- [ ] **Step 5: Verify unchanged programs and commit**

Run: `dart format lib/features/relief/domain/models/reset_content.dart lib/features/relief/data/reset_catalog.dart test/reset_catalog_test.dart test/relief_access_test.dart`

Run: `flutter test test/reset_catalog_test.dart test/reset_session_engine_test.dart test/reset_completion_store_test.dart test/relief_access_test.dart`

Commit: `feat(reset): classify practices by purpose`

### Task 2: Purpose-first Reset hub

**Files:**
- Create: `lib/features/relief/presentation/reset_discovery_selector.dart`
- Modify: `lib/features/relief/presentation/relief_screen.dart`
- Modify: `test/reset_hub_test.dart`
- Modify: `test/reset_guidance_quality_test.dart`

**Interfaces:**
- Consumes: `ResetContent.discoveryGroup`, existing catalog provider, preview sheet and launch callbacks.
- Produces: `ResetDiscoverySelector(selected, onChanged)`, keys `reset-group-<name>`, `reset-emergency-entry` and `reset-content-<id>`.

- [ ] **Step 1: Write failing hub hierarchy tests**

Assert Emergency is present before discovery groups and opens without a Premium gate. Assert the three group controls exist; selecting each shows only matching non-Emergency entries. Assert deep sessions appear with a duration/access badge inside their group and the old separate Deep Reset rail is absent.

- [ ] **Step 2: Add compact, large-text and semantics tests**

Pump at 320×640 with 200% text, scroll to the final result and verify no overflow. Assert the selector announces its selected group and cards announce title, duration and access state.

- [ ] **Step 3: Run focused tests and observe current layout failures**

Run: `flutter test test/reset_hub_test.dart test/reset_guidance_quality_test.dart`

- [ ] **Step 4: Implement the selector and focused result list**

Use a horizontally scrollable segmented control or wrap that meets touch-target requirements. In `ReliefScreen`, render: concise header, separate Emergency entry, group selector, one result list and the existing supporting Sound link. Reuse existing card/preview components and entitlement hooks.

- [ ] **Step 5: Verify player and access regressions**

Run: `dart format lib/features/relief/presentation/reset_discovery_selector.dart lib/features/relief/presentation/relief_screen.dart test/reset_hub_test.dart`

Run: `flutter test test/reset_hub_test.dart test/relief_access_test.dart test/reset_session_engine_test.dart test/reset_lifecycle_test.dart test/reset_voice_playback_test.dart test/reset_audio_preferences_test.dart test/reset_ambience_lifecycle_test.dart`

Run: `flutter analyze`

- [ ] **Step 6: Run complete suite, update evidence and commit**

Run: `flutter test`

Update `docs/CURRENT_STATE.md`, `docs/ROADMAP.md` and Reset evidence. Keep natural breathing candidate listening, final artwork and physical audio approval explicitly pending.

Commit: `feat(reset): simplify discovery by user need`

### Task 3: Session safety and accessibility regression closure

**Files:**
- Inspect and modify for a reproduced lifecycle/control failure: `lib/features/relief/presentation/player/relief_player_screen.dart`
- Inspect and modify for a reproduced reduced-motion/phase failure: `lib/features/relief/presentation/breath_pacer.dart`
- Inspect and modify for a reproduced silence/cancellation failure: `lib/features/relief/application/reset_voice_playback.dart`
- Test: `test/reset_lifecycle_test.dart`
- Test: `test/reset_sensory_skip_test.dart`
- Test: `test/reset_breathing_visual_coverage_test.dart`

**Interfaces:**
- Consumes: unchanged `ResetSessionProgram` and audio preference state.
- Produces: no new public API; only proven lifecycle, silence and accessibility behavior.

- [ ] **Step 1: Add regression tests for every specified boundary**

Test app pause/resume during inhale, hold and guided steps; voice-off/no-words; missing narration; reduced-motion hold rendering; stopping on dizziness/discomfort; and 200% text access to Pause/Resume/Exit.

- [ ] **Step 2: Run tests before modifying behavior**

Run: `flutter test test/reset_lifecycle_test.dart test/reset_sensory_skip_test.dart test/reset_breathing_visual_coverage_test.dart test/reset_voice_playback_test.dart`

Expected: record which cases already pass. Change production code only for reproduced failures.

- [ ] **Step 3: Fix each reproduced defect minimally**

Preserve phase timing and the silence contract. Do not add audio, artwork or fallback narration. Use existing lifecycle/audio controllers rather than a second timer.

- [ ] **Step 4: Verify and checkpoint**

Run focused Reset tests, `flutter analyze`, then `flutter test` if production code changed.

Commit only if behavior changed: `fix(reset): harden session lifecycle and accessibility`
