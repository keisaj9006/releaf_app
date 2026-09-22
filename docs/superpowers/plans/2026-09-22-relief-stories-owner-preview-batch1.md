# Relief Stories Owner Preview Batch 1 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add an owner-only Stories preview entry, typed story catalogue and TS01/TS02 preview library without changing the public Sleep narration-free release surface.

**Architecture:** A compile-time feature flag controls discovery and direct-route access. Stories get a dedicated domain model and catalogue, while this first batch intentionally stops before implementing story playback. The preview library renders real TS01/TS02 metadata and a deterministic missing-audio state so UI/product testing can begin before delivery audio is imported.

**Tech Stack:** Flutter 3.47.2, Dart 3.8+, Riverpod, go_router, flutter_test.

**Spec:** `docs/superpowers/specs/2026-09-22-relief-stories-owner-preview-design.md`

## Global Constraints

- Work only on branch `feature/relief-stories-owner-preview-batch1`; never modify `main`.
- Public Sleep remains narration-free when `RELIEF_STORIES_PREVIEW` is false.
- Preview flag is `RELIEF_STORIES_PREVIEW=true`; default is false.
- No Story audio asset is imported in this batch.
- No public Store Listing/release-gate scope change.
- No remote backend or cloud progress.
- No rights-pack files are bundled as Flutter runtime assets.
- TS01 script version is `2.0`; TS02 script version is `2.0`.
- TS01 and TS02 require content warnings.
- Missing audio must render intentionally and never crash.
- Do not replace stable Sleep/Sound functionality.

## Review Focus

- A build without the preview define must still show the existing narration-free Sleep experience and no Stories entry.
- A direct Stories preview route with the flag off must redirect to Sleep rather than expose hidden preview UI.
- Duplicate story IDs must be impossible in the canonical catalogue and covered by a test.
- TS01/TS02 missing audio must be represented as an explicit unavailable-for-playback state, not an invalid empty path.
- The preview library must remain usable at 320x640 and 200% text without a critical overflow.

---

### Task 1: Feature flag, story domain model and canonical catalogue

**Files:**
- Create: `lib/features/stories/story_preview_config.dart`
- Create: `lib/features/stories/domain/relief_story.dart`
- Create: `lib/features/stories/data/story_catalog.dart`
- Create: `test/story_catalog_test.dart`

**Interfaces:**
- Produces: `StoryPreviewConfig.enabled`
- Produces: `ReliefStory`, `ReliefStoryChapter`, `StoryCategory`
- Produces: `StoryCatalog.all`, `StoryCatalog.getById(String)`

- [ ] **Step 1: Write failing catalogue tests**

Create `test/story_catalog_test.dart` with tests that:
1. expect exactly TS01 and TS02 in the initial catalogue;
2. require unique IDs;
3. require scriptVersion `2.0`;
4. require non-empty warnings and the labels `TRUE STORY`, `WORLD WAR II`, `NON-GRAPHIC`;
5. require `audioAssetPath == null` and `isAudioAvailable == false`;
6. verify `getById` returns null for unknown IDs.

Use production API exactly as follows:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:releaf_app/features/stories/data/story_catalog.dart';

void main() {
  test('initial story catalogue contains TS01 and TS02 only', () {
    expect(
      StoryCatalog.all.map((story) => story.id).toList(),
      const ['TS01_BEYOND_THE_GATE', 'TS02_KRYSTYNA_SKARBEK'],
    );
  });

  test('story catalogue IDs are unique', () {
    final ids = StoryCatalog.all.map((story) => story.id).toList();
    expect(ids.toSet().length, ids.length);
  });

  test('true-history preview stories carry required release metadata', () {
    for (final story in StoryCatalog.all) {
      expect(story.scriptVersion, '2.0');
      expect(story.contentWarning, isNotEmpty);
      expect(
        story.labels,
        containsAll(const ['TRUE STORY', 'WORLD WAR II', 'NON-GRAPHIC']),
      );
      expect(story.audioAssetPath, isNull);
      expect(story.isAudioAvailable, isFalse);
    }
  });

  test('unknown story IDs are not fabricated', () {
    expect(StoryCatalog.getById('missing'), isNull);
  });
}
```

- [ ] **Step 2: Run test to verify RED**

Run:
```bash
flutter test test/story_catalog_test.dart
```

Expected: FAIL because the Stories feature files do not exist.

- [ ] **Step 3: Implement minimal feature flag and model**

Create `story_preview_config.dart`:

```dart
abstract final class StoryPreviewConfig {
  static const enabled = bool.fromEnvironment(
    'RELIEF_STORIES_PREVIEW',
    defaultValue: false,
  );
}
```

Create `relief_story.dart` with immutable const models:
- enum `StoryCategory { trueStoriesOfCourage, meaningStories, storiesThatTeach }`
- `ReliefStoryChapter({required id, required title, required start})`
- `ReliefStory` fields from the spec needed by Batch 1
- `bool get isAudioAvailable => audioAssetPath?.trim().isNotEmpty == true`

- [ ] **Step 4: Implement canonical TS01/TS02 catalogue**

Create `StoryCatalog` as an `abstract final class` with:
- const `all` list in TS01 then TS02 order
- exact IDs and titles from the approved v2 packs
- `series: 'True Stories of Courage'`
- approximate durations of 28 minutes until final masters exist
- `audioAssetPath: null`
- `artworkAssetPath: null`
- warnings:
  - TS01: `This true story discusses imprisonment at Auschwitz and escape during the Second World War. It contains no graphic descriptions.`
  - TS02: `This true story discusses wartime imprisonment, Gestapo arrest, stalking and a post-war murder. It contains no graphic descriptions.`
- chapter titles from v2 scripts, with `Duration.zero` placeholders only for chapter starts until final master timings exist
- `getById` using an explicit loop and returning null for unknown IDs.

Do not infer chapter timestamps before final delivery masters exist.

- [ ] **Step 5: Run test to verify GREEN**

Run:
```bash
flutter test test/story_catalog_test.dart
```

Expected: PASS.

- [ ] **Step 6: Run full suite and analyzer**

Run:
```bash
flutter analyze
flutter test
```

Expected: both PASS.

- [ ] **Step 7: Commit**

```bash
git add lib/features/stories test/story_catalog_test.dart
git commit -m "feat: add Stories preview catalogue"
```

---

### Task 2: Owner Preview library with intentional missing-audio state

**Files:**
- Create: `lib/features/stories/presentation/stories_preview_screen.dart`
- Create: `test/stories_preview_test.dart`

**Interfaces:**
- Consumes: `StoryCatalog.all`
- Produces: `StoriesPreviewScreen`
- Card keys: `story-preview-TS01_BEYOND_THE_GATE`, `story-preview-TS02_KRYSTYNA_SKARBEK`

- [ ] **Step 1: Write failing widget tests**

Create tests that mount `StoriesPreviewScreen` and assert:
- heading `Stories Preview`;
- owner-preview marker;
- both titles visible after scrolling;
- labels render;
- unavailable narration copy renders for each missing-audio story;
- no Play button is exposed for a missing-audio card;
- 320x640 has no exception;
- 320x640 at textScaler 2.0 has no exception.

Use a `MediaQuery` wrapper for the 200% text case.

- [ ] **Step 2: Run test to verify RED**

Run:
```bash
flutter test test/stories_preview_test.dart
```

Expected: FAIL because `StoriesPreviewScreen` does not exist.

- [ ] **Step 3: Implement minimal preview library**

Create a premium-dark `StoriesPreviewScreen` following current design tokens:
- clear `OWNER PREVIEW` eyebrow;
- title `Stories Preview`;
- short copy: `Narrated Stories are being prepared and tested here before any public release.`;
- section `TRUE STORIES OF COURAGE`;
- cards generated from `StoryCatalog.all`;
- each missing-audio card shows `Narration not imported yet`;
- do not create a fake Play action;
- use an intentional icon/gradient placeholder when artwork is null;
- use `SingleChildScrollView`/responsive layout and current spacing/typography tokens.

- [ ] **Step 4: Run widget tests to verify GREEN**

Run:
```bash
flutter test test/stories_preview_test.dart
```

Expected: PASS.

- [ ] **Step 5: Run full suite and analyzer**

Run:
```bash
flutter analyze
flutter test
```

Expected: both PASS.

- [ ] **Step 6: Commit**

```bash
git add lib/features/stories/presentation/stories_preview_screen.dart test/stories_preview_test.dart
git commit -m "feat: add Stories owner preview library"
```

---

### Task 3: Route guard and Sleep discovery entry

**Files:**
- Modify: `lib/routing/app_routes.dart`
- Modify: `lib/routing/app_router.dart`
- Modify: `lib/features/sleep/presentation/sleep_screen.dart`
- Modify: `test/sleep_experience_test.dart`
- Create: `test/story_player_route_test.dart`

**Interfaces:**
- Consumes: `StoryPreviewConfig.enabled`
- Consumes: `StoriesPreviewScreen`
- Produces route: `AppRoutes.storiesPreview = '/sleep/stories-preview'`

- [ ] **Step 1: Add RED regression assertion for normal Sleep**

Extend the existing default-environment Sleep test to assert:
```dart
expect(find.text('Stories Preview'), findsNothing);
expect(find.byKey(const Key('sleep-stories-preview')), findsNothing);
```

Run:
```bash
flutter test test/sleep_experience_test.dart
```

Expected: PASS because no preview entry exists yet; this is a characterization guard, not the RED test.

- [ ] **Step 2: Write RED route/preview-enabled tests**

Because `bool.fromEnvironment` is compile-time, keep route-guard logic testable through a pure helper in `story_preview_config.dart`:

```dart
static String? redirectWhenDisabled({
  required bool enabled,
  required String sleepRoute,
}) => enabled ? null : sleepRoute;
```

Write `test/story_player_route_test.dart` to assert:
- disabled returns `/sleep`;
- enabled returns null.

Also add a preview-enabled Sleep widget test compiled/run with:
```bash
flutter test --dart-define=RELIEF_STORIES_PREVIEW=true test/sleep_experience_test.dart
```
that expects key `sleep-stories-preview`.

Expected RED: route helper and preview entry are missing.

- [ ] **Step 3: Implement route**

Add:
```dart
static const storiesPreview = '/sleep/stories-preview';
```

Register a top-level `GoRoute` for `storiesPreview` whose redirect calls the pure guard and whose page renders `StoriesPreviewScreen`.

- [ ] **Step 4: Implement conditional Sleep entry**

When `StoryPreviewConfig.enabled` is true, render a separated owner-preview section after the existing primary destination actions and before normal sound content.

Requirements:
- key `sleep-stories-preview`;
- eyebrow `OWNER PREVIEW`;
- title `Stories`;
- CTA opens `AppRoutes.storiesPreview`;
- no narrated Story cards are mixed into existing sound rails;
- when flag false, widget tree remains unchanged apart from unreachable const code.

- [ ] **Step 5: Run route and Sleep tests GREEN**

Run:
```bash
flutter test test/story_player_route_test.dart
flutter test test/sleep_experience_test.dart
flutter test --dart-define=RELIEF_STORIES_PREVIEW=true test/sleep_experience_test.dart
```

Expected: PASS.

- [ ] **Step 6: Run full regression and analyzer**

Run:
```bash
flutter analyze
flutter test
```

Expected: PASS.

- [ ] **Step 7: Commit**

```bash
git add lib/routing lib/features/sleep lib/features/stories test
git commit -m "feat: expose Stories owner preview behind flag"
```

---

### Task 4: Batch-1 verification and PR evidence

**Files:**
- Modify if needed only for test fixes: files from Tasks 1-3
- No release-gate/store-listing changes.

**Interfaces:**
- Verifies the Batch-1 contract; produces no new runtime API.

- [ ] **Step 1: Run focused tests**

```bash
flutter test test/story_catalog_test.dart
flutter test test/stories_preview_test.dart
flutter test test/story_player_route_test.dart
flutter test test/sleep_experience_test.dart
flutter test --dart-define=RELIEF_STORIES_PREVIEW=true test/sleep_experience_test.dart
```

Expected: PASS.

- [ ] **Step 2: Run full verification**

```bash
flutter analyze
flutter test
```

Expected: PASS with no analyzer errors.

- [ ] **Step 3: Open PR to `releaf-development`**

PR title:
`feat: add Relief Stories owner preview batch 1`

PR body must state:
- owner preview only;
- public Sleep remains narration-free by default;
- TS01/TS02 metadata are imported, not audio;
- real delivery audio and Story Player are Batch 2;
- testing performed and CI status.

- [ ] **Step 4: Confirm GitHub Actions P0 validation**

Expected: Flutter P0 Validation PASS on the PR.

- [ ] **Step 5: Stop before merge**

Do not merge without explicit owner approval.
