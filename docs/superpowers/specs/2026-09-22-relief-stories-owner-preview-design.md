# Relief Stories Owner Preview — Design

Date: 2026-09-22
Repository: `keisaj9006/releaf_app`
Branch: `releaf-development`
Current branch HEAD reviewed: `8bf84e01396703c10ceba09fe5d75ce55a9be334`

## Purpose

Add narrated long-form Stories to the existing Flutter app as an **Owner Preview/Test** feature without changing the public Relief 1.0 release scope.

The preview must let the owner test real story UX, player behaviour, content warnings, artwork and delivery audio before Stories are promoted into the public Sleep experience.

This work must reuse stable existing audio infrastructure where that lowers risk, but must not force narrated content into the current public Sleep audio-only contract.

## Current product constraints

The current canonical release gate keeps the public Sleep experience audio-only and explicitly says "Sleep must not contain narration." The current Sleep screen and tests enforce this contract.

Therefore Stories will be integrated behind an explicit compile-time owner-preview flag. When the flag is off, the public release surface remains unchanged.

The existing Sound system already provides:
- audio-session handling,
- interruption handling,
- background audio service integration,
- seek support,
- sleep timer behaviour,
- persistence patterns,
- release/device QA coverage.

The existing Meditation system provides:
- speech-mode audio-session behaviour,
- separate narration/ambience concepts,
- resilient controller/driver patterns.

Stories will reuse these proven patterns rather than rebuild unrelated audio infrastructure.

## Preview activation

Use one compile-time flag:

`RELIEF_STORIES_PREVIEW=true`

Default: `false`.

When false:
- no Stories entry is visible in Sleep,
- public Sleep continues to satisfy its existing no-narration tests,
- store/release scope does not change.

When true:
- Sleep shows an internal **Stories Preview** entry,
- the preview library and story player routes are available,
- preview UI is clearly marked as owner/testing content.

No account entitlement or Premium logic should be used to hide the preview. It is an internal build-time capability, not a consumer feature gate.

## Content model

Create a dedicated Stories feature instead of treating narration as ordinary SoundContent.

Proposed domain objects:

### ReliefStory
- `id`
- `title`
- `subtitle`
- `series`
- `category`
- `description`
- `estimatedDuration`
- `audioAssetPath` (nullable until delivery audio exists)
- `artworkAssetPath` (nullable)
- `contentWarning` (nullable)
- `labels` such as TRUE STORY / WORLD WAR II / NON-GRAPHIC
- `isPremium`
- `chapters`
- `rightsStatus` for preview/internal QA only
- `scriptVersion`
- `audioVersion`

### ReliefStoryChapter
- `id`
- `title`
- `start`
- optional `end`

Chapter timing belongs to the final delivery master, not to draft ElevenLabs chapter exports.

## Initial preview catalogue

Start with the two fully structured true-history stories already prepared:

1. `TS01_BEYOND_THE_GATE`
   - title: Beyond the Gate
   - subtitle: The True Story of Four Prisoners and an Impossible Plan at Auschwitz
   - script: v2.0
   - warning required
   - final delivery audio: pending

2. `TS02_KRYSTYNA_SKARBEK`
   - title: The Woman Who Crossed Every Border
   - subtitle: The True Story of Krystyna Skarbek and the Impossible Choices She Refused to Accept
   - script: v2.0
   - warning required
   - final delivery audio: pending

The catalogue must support metadata-only entries. If audio is missing, the card remains testable but the player shows a clear "Narration not imported yet" state instead of failing.

After the player and integration are stable, add one Meaning Story and one Stories That Teach story as the next batch.

## Production audio format

ElevenLabs chapter exports are production sources, not final app delivery files.

Workflow:
1. Generate/approve final chapters using Theo.
2. Preserve original ElevenLabs WAV/MP3 files in the rights/archive pack.
3. Assemble and master one continuous story file.
4. Export a delivery copy for the app.
5. Record chapter start timestamps against that final delivery file.
6. Import only the delivery copy into runtime assets.

Preferred delivery target for preview:
- AAC/M4A if supported reliably by the current Android/iOS asset path and playback stack,
- otherwise high-quality MP3.

Do not bundle full WAV masters in the app.

The exact codec/bitrate should be chosen after one real story is encoded and compared on:
- audible quality,
- file size,
- Android playback,
- background playback,
- seek accuracy.

## Story Player

Create a dedicated Story Player because the existing Sound Player is optimized for loopable soundscapes and coloured noise.

Required preview capabilities:
- play / pause,
- scrub timeline,
- -10 seconds,
- +10 seconds,
- chapter list and chapter jump,
- persistent playback position,
- resume from previous position,
- playback speed,
- background playback/media controls,
- interruption handling,
- headphone-disconnect safety,
- sleep timer,
- graceful missing-audio/error state.

### Playback speed

Initial supported rates:
- 0.65x
- 0.75x
- 0.85x
- 0.90x
- 1.00x
- 1.10x
- 1.20x
- 1.35x
- 1.50x

Persist the owner's last selected rate.

Do not modify the source master when speed changes; speed is runtime playback behaviour.

### Background audio

Story narration should use speech-mode audio-session semantics, matching guided narration rather than looping Sleep sound semantics.

Reuse the existing audio-service approach where practical so lock-screen/media notification controls remain consistent with the app.

The player must use `ReleaseMode.stop`, never loop.

## Persistence

Use SharedPreferences for preview/local playback state.

Suggested keys:
- `stories.position.<storyId>`
- `stories.completed.<storyId>`
- `stories.last_played_id`
- `stories.playback_rate`
- `stories.warning_ack.<storyId>.<scriptVersion>`

Persist position periodically and on pause/dispose/lifecycle transitions.

Completion threshold: treat a story as completed when playback reaches the final few seconds / >= 95% after duration is known.

No cloud sync for Stories in this preview.

## Content warning

For TS01 and TS02, show warning before the first playback of the current script version.

The user can:
- Play story
- Choose another story

Acknowledgement can be remembered for that story + script version, with an accessible way to view the warning again from story details.

Never surprise-autoplay these true-history stories after unrelated Sleep content.

## UI structure

### Sleep screen when preview OFF
No change.

### Sleep screen when preview ON
Add one clearly separated internal section:
- eyebrow: `OWNER PREVIEW`
- title: `Stories`
- short copy explaining narration is being tested
- CTA: `Open Stories Preview`

Do not merge narrated Stories into the existing sound rails during preview.

### Stories Preview Library
Sections:
- Continue listening, when applicable
- True Stories of Courage
- later: Meaning Stories
- later: Stories That Teach

Each card should show:
- artwork or intentional placeholder,
- title,
- subtitle/short descriptor,
- approximate duration,
- labels,
- availability state.

### Story details / warning
The warning can be a pre-play modal or dedicated detail step. It must not appear as sensational marketing.

### Story Player
Dark premium Relief visual language.
Artwork is supportive, not visually dominant.
Player controls remain usable at 320 px width and enlarged text.

## Routing

Add dedicated routes:
- `/sleep/stories-preview`
- `/sleep/story/:storyId`

Routes exist in the app router but the preview library is only discoverable when `RELIEF_STORIES_PREVIEW=true`.

If a preview route is opened directly while the flag is false, redirect to `/sleep`.

## Artwork

Do not block player integration on finished artwork.

For the first implementation:
- use an intentional neutral Relief placeholder generated from existing design primitives,
- do not reuse arbitrary archival photos,
- add final original/licensed artwork after the audio/player pipeline is stable.

TS01/TS02 rights packs remain the source of truth for final artwork restrictions.

## Rights and provenance

Do not bundle legal packs into runtime application assets.

Keep rights packs outside runtime packaging.

Runtime metadata may store only:
- story ID,
- script version,
- audio version,
- content labels,
- content warning,
- optional internal rights status in preview builds.

A story must not be promoted from preview to public release until its separate commercial-clearance checklist is complete.

## Test strategy

TDD/verification should cover at minimum:

### Feature-flag contract
- preview OFF: existing Sleep no-narration behaviour unchanged
- preview ON: Stories Preview entry appears
- direct preview route redirects when flag is off

### Catalogue
- TS01 and TS02 metadata present
- IDs unique
- warnings present for both
- missing audio handled intentionally

### Player
- missing asset does not crash
- play/pause state
- seek -10/+10 clamps correctly
- persisted position restore
- playback-rate persistence
- chapter selection maps to correct timestamp
- completion persistence
- warning acknowledgement versioning

### Accessibility/layout
- 320x640 no overflow
- 200% text no critical control loss
- reduced motion respected for decorative animation

### Regression
Run:
- existing Sleep tests
- Sound tests
- audio interruption/background tests
- new Stories tests
- full `flutter analyze`
- full `flutter test`

Final physical-device checks are batched, not requested after each code change.

## Rollout order

1. Implement feature flag + data model + TS01/TS02 metadata.
2. Implement preview library with explicit missing-audio state.
3. Implement Story Player controller/driver under tests.
4. Add persistence, speed, seek and chapters.
5. Add content-warning acknowledgement.
6. Integrate background/media controls and interruption handling.
7. Run automated regression suite.
8. Import one final mastered story delivery file.
9. Verify seek, speed, resume, background audio and timer on a real device.
10. Tune mastering/UI.
11. Import remaining approved stories serially.
12. Only after content QA and rights clearance: make a separate decision about public Sleep/Stories scope.

## Expected new/changed files

New feature area:
- `lib/features/stories/domain/relief_story.dart`
- `lib/features/stories/data/story_catalog.dart`
- `lib/features/stories/application/story_player_controller.dart`
- `lib/features/stories/application/relief_background_story_driver.dart`
- `lib/features/stories/presentation/stories_preview_screen.dart`
- `lib/features/stories/presentation/story_player_screen.dart`
- `lib/features/stories/presentation/story_player_gate.dart`
- `lib/features/stories/story_preview_config.dart`

Existing files touched:
- `lib/features/sleep/presentation/sleep_screen.dart`
- `lib/routing/app_routes.dart`
- `lib/routing/app_router.dart`
- `lib/core/audio/releaf_audio_session.dart`
- `pubspec.yaml` only when actual story delivery assets are imported.

Tests:
- `test/stories_preview_test.dart`
- `test/story_catalog_test.dart`
- `test/story_player_controller_test.dart`
- `test/story_player_route_test.dart`

## Non-goals for this batch

- no public Stories launch,
- no public Store Listing change,
- no release-gate scope expansion,
- no remote streaming backend,
- no cloud story progress,
- no mass import of every prepared script,
- no final artwork dependency,
- no regeneration of already approved scripts,
- no replacement of stable Sound/Sleep functionality.

## Success criteria

This design is successful when:
1. a normal build with no preview flag behaves exactly like the current public Sleep experience;
2. an owner-preview build can browse TS01/TS02 and open a production-shaped Story Player;
3. missing audio is handled cleanly;
4. after one delivery audio file is imported, play/pause, seek, speed, chapters, resume, background playback and sleep timer work;
5. no current P0 release gate is weakened;
6. remaining Stories can be added primarily as content/catalog work rather than new player engineering.
