# Sleep Content Readiness Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a fail-closed local Sleep asset intake contract and simplify Sleep discovery around Continue/Tonight plus four category gateways.

**Architecture:** Keep `SleepCatalog`, the story/sound/meditation catalogs, routes and players. Add a repository manifest model and validator beside `SleepCatalog`; runtime catalog entries remain playable only when the existing source exists and the manifest marks the asset, rights and owner approval ready. Refactor only the discovery composition in `SleepScreen`.

**Tech Stack:** Flutter, Dart, Riverpod, `flutter_test`, existing local asset catalogs and release-size policy.

**Spec:** `docs/superpowers/specs/2026-09-24-releaf-content-readiness-and-progression-design.md`

## Global Constraints

- Content is bundled locally and works offline; no downloads or streaming are added.
- Nature and Sleep Music remain narration-free.
- Narrated content uses approved recordings only; no TTS or substitute voice.
- Existing routes, content IDs, progress, access checks and player behavior stay stable.
- Only content with an explicit access tier, present assets, cleared rights and owner approval is runtime-ready.
- Source assets remain below 63,000,000 bytes and the Android AAB below 105,000,000 bytes.

## Review Focus

- A manifest item with an approved flag but a missing source reference must remain unavailable and report a validation error.
- Duplicate content IDs across categories must fail validation rather than shadow one item.
- An undecided access tier must never become playable.
- Corrupt Continue Listening progress must fall back to Tonight without breaking Sleep.
- At 320 dp and 200% text scale, all four category gateways and the primary action remain reachable.

---

### Task 1: Sleep intake contract and validation

**Files:**
- Create: `lib/features/sleep/domain/sleep_content_manifest.dart`
- Create: `lib/features/sleep/data/sleep_content_manifest.dart`
- Modify: `lib/features/sleep/data/sleep_catalog.dart`
- Test: `test/sleep_content_manifest_test.dart`
- Test: `test/sleep_catalog_test.dart`

**Interfaces:**
- Consumes: existing `SleepCategory`, `SleepAccessTier`, `SleepPlaybackSource` and source catalogs.
- Produces: `SleepManifestEntry`, `SleepApprovalState`, `SleepRightsState`, `SleepManifestValidation`, `SleepContentManifest.validate(...)`, and `SleepContentManifest.runtimeReadyIds`.

- [ ] **Step 1: Pin fail-closed readiness with failing tests**

Add cases constructing entries with duplicate IDs, missing paths, `undecided` access, pending rights, pending approval and an unknown playback source. Assert each produces a stable error and is absent from `runtimeReadyIds`. Add a valid local item and assert it is included.

```dart
final result = SleepContentManifest.validate(
  entries: entries,
  assetExists: existingAssets.contains,
  sourceExists: knownSources.contains,
);
expect(result.errors, contains('sleep-test: audio asset is missing'));
expect(result.runtimeReadyIds, isNot(contains('sleep-test')));
```

- [ ] **Step 2: Run the focused tests and observe the missing contract**

Run: `flutter test test/sleep_content_manifest_test.dart test/sleep_catalog_test.dart`

Expected: FAIL because the manifest types do not exist.

- [ ] **Step 3: Implement immutable manifest types and validator**

Use explicit independent readiness fields and dependency-injected checks so unit tests do not depend on the Flutter asset bundle.

```dart
enum SleepApprovalState { pending, approved }
enum SleepRightsState { pending, cleared }

class SleepManifestEntry {
  const SleepManifestEntry({
    required this.id,
    required this.category,
    required this.audioAsset,
    required this.artworkAsset,
    required this.duration,
    required this.accessTier,
    required this.source,
    required this.creatorSource,
    required this.approval,
    required this.rights,
    this.narratorProvenance,
    this.ambienceAsset,
  });
  final String id;
  final SleepCategory category;
  final String audioAsset;
  final String artworkAsset;
  final Duration duration;
  final SleepAccessTier accessTier;
  final SleepPlaybackSource source;
  final String creatorSource;
  final SleepApprovalState approval;
  final SleepRightsState rights;
  final String? narratorProvenance;
  final String? ambienceAsset;
}
```

`SleepManifestValidation` returns immutable `errors` and `runtimeReadyIds`. Readiness requires non-empty local paths, positive duration, decided access, approved content, cleared rights, present files and a known source.

- [ ] **Step 4: Declare current entries honestly and connect catalog readiness**

Populate the repository manifest only with metadata supported by current evidence. Keep pending or absent items excluded. Update `SleepCatalog.isPlayable` mapping so a manifest-backed entry cannot become ready unless its ID is in `runtimeReadyIds`; retain current source-catalog validation.

- [ ] **Step 5: Verify and commit**

Run: `dart format lib/features/sleep test/sleep_content_manifest_test.dart test/sleep_catalog_test.dart`

Run: `flutter test test/sleep_content_manifest_test.dart test/sleep_catalog_test.dart test/story_catalog_test.dart test/sound_experience_test.dart`

Run: `flutter analyze`

Commit: `feat(sleep): add approved content intake contract`

### Task 2: Repository QA exporter and size evidence

**Files:**
- Create: `tool/release/sleep_content_manifest_policy.dart`
- Create: `test/sleep_content_manifest_policy_test.dart`
- Modify: `docs/release/releaf_1_0_release_gate.md`
- Create: `docs/release/2026-09-24-sleep-content-intake.md`

**Interfaces:**
- Consumes: repository root and canonical manifest data.
- Produces: exit code `0` only when runtime-ready entries pass; human-readable errors for pending/invalid candidates; total candidate and runtime-ready bytes.

- [ ] **Step 1: Write policy contract tests**

Assert the tool rejects duplicate IDs, missing files, unsupported extensions, non-positive duration, undecided access and false approval/rights claims for runtime-ready items. Assert pending candidates are reported without being promoted.

- [ ] **Step 2: Run the policy tests and observe failure**

Run: `flutter test test/sleep_content_manifest_policy_test.dart`

Expected: FAIL because the policy tool is absent.

- [ ] **Step 3: Implement the CLI around shared validation rules**

Accept `--root <repository>` and print only paths/metadata, never credentials. Support `.mp3`, `.m4a`, `.wav`, `.png`, `.jpg` and `.webp`; reject other runtime formats. Calculate byte totals with `File.lengthSync()` and compare the full asset tree through the existing release-size command.

- [ ] **Step 4: Record evidence without approving pending media**

Document the current ready/pending counts, validation command and size result. Explicitly keep owner listening/artwork approval open.

- [ ] **Step 5: Verify and commit**

Run: `dart format tool/release/sleep_content_manifest_policy.dart test/sleep_content_manifest_policy_test.dart`

Run: `flutter test test/sleep_content_manifest_policy_test.dart test/release_size_budget_policy_test.dart`

Run: `dart run tool/release/sleep_content_manifest_policy.dart --root .`

Commit: `build(sleep): validate local content intake`

### Task 3: Simplified Sleep discovery

**Files:**
- Modify: `lib/features/sleep/presentation/sleep_screen.dart`
- Test: `test/sleep_experience_test.dart`
- Test: `test/sleep_catalog_test.dart`

**Interfaces:**
- Consumes: `SleepCatalog.getFeatured()`, `getByCategory(...)`, valid local progress and existing open callbacks.
- Produces: keys `sleep-primary-continue`, `sleep-primary-tonight`, and `sleep-category-<category.name>` for stable widget tests.

- [ ] **Step 1: Replace old rail expectations with failing hierarchy tests**

Assert one primary Continue card when valid progress exists, otherwise one Tonight card; exactly four category gateways; selected-category results contain only that category; pending content has no open action; the broader Sound library link remains.

- [ ] **Step 2: Add compact and large-text failing tests**

Pump at `Size(320, 640)` with `textScaler: const TextScaler.linear(2)` and scroll through the page. Assert no exception and that every category gateway can be reached and tapped.

- [ ] **Step 3: Run tests and confirm the current duplicated layout fails**

Run: `flutter test test/sleep_experience_test.dart test/sleep_catalog_test.dart`

- [ ] **Step 4: Recompose `SleepScreen` using existing cards and routing**

Remove the `All` filter and duplicated Popular/Nature/Meditation/Music rails from the root view. Render the primary card, a two-column wrapping category gateway grid and the selected category’s ready items. Keep story collection presentation only within Stories and keep existing `_openContent` access behavior.

- [ ] **Step 5: Verify screen and playback regressions**

Run: `dart format lib/features/sleep/presentation/sleep_screen.dart test/sleep_experience_test.dart`

Run: `flutter test test/sleep_experience_test.dart test/sleep_story_player_test.dart test/sleep_long_form_playback_test.dart test/sound_loading_recovery_test.dart test/story_player_route_test.dart`

Run: `flutter analyze`

Run: `flutter test`

- [ ] **Step 6: Update evidence and commit**

Update `docs/CURRENT_STATE.md`, `docs/ROADMAP.md` and the Sleep release evidence with exact results and outstanding media/device review.

Commit: `feat(sleep): simplify offline content discovery`
