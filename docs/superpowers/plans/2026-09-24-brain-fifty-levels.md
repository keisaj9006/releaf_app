# Brain Fifty-Level Progression Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Extend all 15 registered Brain games to persistent, meaningful and playable level-50 progression while preserving levels 1–12 and all reward semantics.

**Architecture:** Raise the shared cap to 50, centralize safe level/band calculations, and move each legacy game’s challenge parameters into a deterministic profile resolver. Implement games in families so each commit is independently testable; Memory Mirror and Labyrinth retain their existing 50-level implementations.

**Tech Stack:** Flutter, Dart, Riverpod, SharedPreferences, deterministic Dart game logic, `flutter_test`.

**Spec:** `docs/superpowers/specs/2026-09-24-releaf-content-readiness-and-progression-design.md`

## Global Constraints

- All 15 registry IDs, routes, stored completion keys, two-sessions-per-level rule, rewards and result flow remain unchanged.
- Existing profile values and gameplay at levels 1–12 remain byte-for-byte or value-for-value compatible.
- Difficulty uses a -2/0/+2 effective-level offset and clamps to 1–50 without writing the saved level.
- Level 50 repeats and records personal best; no level 51 is exposed.
- Touch targets, grids, N-back depth and response windows receive playable safety caps.
- No IQ, brain-age, diagnosis or real-world performance claims.

## Review Focus

- A stored cumulative count above the old cap must reveal the earned level without data migration or reset.
- Difficulty offsets at levels 1, 2, 49 and 50 must remain inside 1–50.
- Every legacy level 1–12 profile must match the pre-change snapshot exactly.
- Every profile from 13–50 must have valid dimensions, positive time and phone-usable touch targets.
- At level 50, completion and replay must preserve level 50 while updating history/personal best once.

---

### Task 1: Shared 50-level contract

**Files:**
- Create: `lib/features/brain/domain/brain_level.dart`
- Modify: `lib/features/brain/application/brain_training_controller.dart`
- Modify: `lib/features/brain/presentation/widgets/brain_difficulty_selector.dart`
- Modify: `test/brain_flow_test.dart`
- Modify: `test/legacy_brain_difficulty_test.dart`

**Interfaces:**
- Produces: `const maxBrainTrainingLevel = 50`, `BrainLevelContext`, `BrainLevelBand`, and `brainPracticeLevelForDifficulty(..., {int maxLevel = 50})`.
- Consumes: existing completion counts and `BrainDifficulty`.

- [ ] **Step 1: Write failing boundary and persistence tests**

Assert counts 0, 2, 24, 98 and 500 map to levels 1, 2, 13, 50 and 50 for every progressive game. Assert sessions-to-next is zero at 50 and existing counts survive controller reload.

- [ ] **Step 2: Snapshot legacy difficulty mapping**

For levels 1–12 and all three difficulties, store the current effective values as expected fixtures. Add new expectations for 13, 25, 49 and 50.

- [ ] **Step 3: Run tests and confirm old cap failures**

Run: `flutter test test/brain_flow_test.dart test/legacy_brain_difficulty_test.dart`

- [ ] **Step 4: Implement shared level primitives**

```dart
enum BrainLevelBand { foundation, build, challenge, advanced, mastery }

class BrainLevelContext {
  const BrainLevelContext(this.level)
      : assert(level >= 1 && level <= maxBrainTrainingLevel);
  final int level;
  int get bandIndex => (level - 1) ~/ 10;
  int get stepInBand => (level - 1) % 10;
}
```

Set all registered games’ max to 50 while leaving Memory/Labyrinth special gameplay APIs intact. Change difficulty clamping to 50, with a compatibility rule that levels 1–12 retain their existing offset outcomes.

- [ ] **Step 5: Verify and commit**

Run: `dart format lib/features/brain test/brain_flow_test.dart test/legacy_brain_difficulty_test.dart`

Run: `flutter test test/brain_flow_test.dart test/legacy_brain_difficulty_test.dart test/memory_level_profiles_test.dart test/labyrinth_level_50_progression_test.dart`

Commit: `feat(brain): extend shared progression to level 50`

### Task 2: Recall and attention game profiles

**Files:**
- Create: `lib/games/sequence_echo/sequence_echo_level_profile.dart`
- Create: `lib/games/n_back/n_back_level_profile.dart`
- Create: `lib/games/spatial_span/spatial_span_level_profile.dart`
- Create: `lib/games/signal_scan/signal_scan_level_profile.dart`
- Modify: corresponding four `*_screen.dart` files
- Create: `test/brain_recall_attention_level_profiles_test.dart`

**Interfaces:**
- Each file produces `<Game>LevelProfile profileFor<Game>Level(int effectiveLevel)` with immutable game-specific fields.
- Screens consume a profile and stop indexing fixed 12-element arrays directly.

- [ ] **Step 1: Capture exact level 1–12 profiles in tests**

Extract current computed values for sequence length, board/stimulus size, display interval, trials, lure/target density and time budget. Assert those fixtures before editing screens.

- [ ] **Step 2: Add levels 13–50 validity and progression tests**

Generate all 50 profiles. Assert bounded N-back depth, unique selectable cells, non-negative intervals, usable grid/touch sizes, deterministic output and meaningful changes in every ten-level band.

- [ ] **Step 3: Run and observe absent resolvers**

Run: `flutter test test/brain_recall_attention_level_profiles_test.dart`

- [ ] **Step 4: Implement resolvers and wire screens**

Copy levels 1–12 from current logic exactly. For 13–50, use `BrainLevelContext` and capped combinations of load, distractors and pacing. Keep deterministic seeds based on effective level and difficulty.

```dart
SequenceEchoLevelProfile sequenceEchoProfileForLevel(int rawLevel) {
  final level = rawLevel.clamp(1, maxBrainTrainingLevel).toInt();
  if (level <= 12) return legacySequenceEchoProfiles[level - 1];
  final context = BrainLevelContext(level);
  return SequenceEchoLevelProfile(
    level: level,
    sequenceLength: (6 + context.bandIndex + context.stepInBand ~/ 3)
        .clamp(6, 14),
    presentation: Duration(
      milliseconds: (620 - context.bandIndex * 45 - context.stepInBand * 8)
          .clamp(320, 620),
    ),
  );
}
```

Use the same legacy-table-first shape for the other three typed resolvers, with their own named fields and safety caps asserted by the tests.

- [ ] **Step 5: Verify family and commit**

Run: `dart format lib/games/sequence_echo lib/games/n_back lib/games/spatial_span lib/games/signal_scan test/brain_recall_attention_level_profiles_test.dart`

Run: `flutter test test/brain_recall_attention_level_profiles_test.dart test/brain_flow_test.dart`

Run: `flutter analyze`

Commit: `feat(brain): add fifty-level recall progression`

### Task 3: Logic and inhibition game profiles

**Files:**
- Create: `lib/games/rule_shift/rule_shift_level_profile.dart`
- Create: `lib/games/color_conflict/color_conflict_level_profile.dart`
- Create: `lib/games/pattern_logic/pattern_logic_level_profile.dart`
- Create: `lib/games/symbol_code/symbol_code_level_profile.dart`
- Modify: corresponding four `*_screen.dart` files
- Create: `test/brain_logic_inhibition_level_profiles_test.dart`

**Interfaces:**
- Produces deterministic profile functions for rule count/switch cadence, palette/congruence, pattern-rule combinations and symbol mapping/remapping.

- [ ] **Step 1: Snapshot levels 1–12 and write failing 13–50 tests**

Assert exact legacy values, determinism, bounded response windows, valid answer generation, distractor uniqueness and a non-empty challenge change in every band.

- [ ] **Step 2: Implement profile files and remove 12-level clamps**

Screens read only their typed profile. Keep user-visible saved level separate from difficulty-adjusted profile level.

```dart
RuleShiftLevelProfile ruleShiftProfileForLevel(int rawLevel) {
  final level = rawLevel.clamp(1, maxBrainTrainingLevel).toInt();
  if (level <= 12) return legacyRuleShiftProfiles[level - 1];
  final context = BrainLevelContext(level);
  return RuleShiftLevelProfile(
    level: level,
    ruleCount: (3 + context.bandIndex).clamp(3, 6),
    trialCount: (18 + context.bandIndex * 2 + context.stepInBand ~/ 2)
        .clamp(18, 30),
    switchEvery: (5 - context.bandIndex).clamp(2, 5),
  );
}
```

Apply the same explicit legacy-table-first resolver pattern to Color Conflict, Pattern Logic and Symbol Code.

- [ ] **Step 3: Verify family behavior**

Run: `dart format lib/games/rule_shift lib/games/color_conflict lib/games/pattern_logic lib/games/symbol_code test/brain_logic_inhibition_level_profiles_test.dart`

Run: `flutter test test/brain_logic_inhibition_level_profiles_test.dart test/legacy_brain_difficulty_test.dart test/brain_flow_test.dart`

Run: `flutter analyze`

- [ ] **Step 4: Commit**

Commit: `feat(brain): add fifty-level logic progression`

### Task 4: Planning and spatial game profiles

**Files:**
- Create: `lib/games/math_race/math_race_level_profile.dart`
- Create: `lib/games/broken_mirror/broken_mirror_level_profile.dart`
- Create: `lib/games/mental_rotation/mental_rotation_level_profile.dart`
- Create: `lib/games/trail_switch/trail_switch_level_profile.dart`
- Create: `lib/games/tower_plan/tower_plan_level_profile.dart`
- Modify: corresponding five `*_screen.dart` files and `lib/games/math_race/math_puzzle_generator.dart`
- Create: `test/brain_planning_spatial_level_profiles_test.dart`

**Interfaces:**
- Produces typed profiles for operation/operand rules, fragments/placement, rotations/choices, trail nodes/switching and Tower constraints/move budgets.

- [ ] **Step 1: Snapshot exact levels 1–12**

Assert every current parameter and seeded generation outcome required to prove compatibility.

- [ ] **Step 2: Add 13–50 invariants**

Assert Math Race answers remain integral and unambiguous, Broken Mirror placements remain achievable, rotation choices contain one answer, trails are completable, and Tower targets are solvable within the generated budget.

- [ ] **Step 3: Implement deterministic profiles and safety caps**

Increase challenge through rule/layout combinations. Cap board density, fragment size, disk count and response pressure before touch or solvability degrades.

```dart
TowerPlanLevelProfile towerPlanProfileForLevel(int rawLevel) {
  final level = rawLevel.clamp(1, maxBrainTrainingLevel).toInt();
  if (level <= 12) return legacyTowerPlanProfiles[level - 1];
  final context = BrainLevelContext(level);
  final disks = (3 + context.bandIndex ~/ 2).clamp(3, 5);
  return TowerPlanLevelProfile(
    level: level,
    diskCount: disks,
    targetPeg: level.isEven ? 2 : 1,
    moveBudget: ((1 << disks) - 1) + (context.stepInBand < 5 ? 2 : 0),
  );
}
```

Use equivalent typed, solvability-tested resolvers for Math Race, Broken Mirror, Mental Rotation and Trail Switch.

- [ ] **Step 4: Verify family and commit**

Run: `dart format lib/games/math_race lib/games/broken_mirror lib/games/mental_rotation lib/games/trail_switch lib/games/tower_plan test/brain_planning_spatial_level_profiles_test.dart`

Run: `flutter test test/brain_planning_spatial_level_profiles_test.dart test/brain_flow_test.dart`

Run: `flutter analyze`

Commit: `feat(brain): add fifty-level planning progression`

### Task 5: Cross-game level-50 experience and checkpoint

**Files:**
- Modify: `test/brain_flow_test.dart`
- Modify: `test/brain_level_badge_test.dart`
- Modify: `test/brain_personal_best_release_qa_test.dart`
- Inspect and modify if level 50 is not passed through unchanged: `lib/features/brain/presentation/game_host_screen.dart`
- Inspect and modify if replay/personal-best state is incorrect at the cap: `lib/features/brain/presentation/game_result_screen.dart`
- Modify: `docs/CURRENT_STATE.md`
- Modify: `docs/ROADMAP.md`
- Create: `docs/release/2026-09-24-brain-fifty-levels.md`

**Interfaces:**
- Consumes: all 15 profile/progression implementations.
- Produces: cross-game proof that every registered ID reaches/replays level 50 and reports the correct saved level.

- [ ] **Step 1: Add registry-wide contract tests**

Iterate `progressiveBrainGameIds`. At 98 completions assert level 50, zero sessions to next, host injection of 50 and no level 51 after another completion. Assert one completion record/reward event per finished session.

- [ ] **Step 2: Add level-50 widget smoke cases**

Pump every game at level 50 on a 320×720 surface. Assert no exception, visible level 50, accessible controls and no touch target smaller than the project’s minimum.

- [ ] **Step 3: Run focused and full verification**

Run: `dart format lib/features/brain lib/games test/brain_* test/legacy_brain_difficulty_test.dart`

Run: `flutter test test/brain_flow_test.dart test/brain_level_badge_test.dart test/brain_personal_best_release_qa_test.dart test/legacy_brain_difficulty_test.dart test/memory_level_profiles_test.dart test/labyrinth_level_50_progression_test.dart test/brain_recall_attention_level_profiles_test.dart test/brain_logic_inhibition_level_profiles_test.dart test/brain_planning_spatial_level_profiles_test.dart`

Run: `flutter analyze`

Run: `flutter test`

- [ ] **Step 4: Record evidence and build device artifact**

Update docs with exact automated results and keep physical Labyrinth/accelerometer review open. Build with the ignored local Dart-define file, install only with `adb install -r`, and smoke-test representative level 1, 13, 25 and 50 games without purchase or data deletion.

- [ ] **Step 5: Commit checkpoint**

Commit: `feat(brain): complete fifty-level game progression`
