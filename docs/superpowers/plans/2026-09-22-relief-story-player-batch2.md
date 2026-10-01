# Relief Story Player — Batch 2 execution plan

**Goal:** Implement the already approved Story Player without replacing working Sleep/Sound infrastructure.
**Spec:** `docs/superpowers/specs/2026-09-22-relief-stories-owner-preview-design.md`
**Base:** `977f095f8b38e9e044eabadad1d226403ebf1b72` (owner-approved PR #2 merge).
**Workspace:** isolated remote branch `feature/relief-stories-player-batch2`. No local checkout of the owner's PC is available in this session. Verification runs through the repository's GitHub Actions, not invented local Flutter results.

## Constraints carried forward
- Public Stories preview flag remains OFF; no store/release scope expansion.
- Never modify main, credentials, billing or Emergency semantics.
- No audio generation, renaming, mastering or asset import in this engineering batch.
- TS01 and TS02 use script version 2.0. Rights clearance is not inferred from generated paperwork.
- Reuse SharedPreferences and existing audio-session/background patterns. Do not initialize a second AudioService or run two competing notification handlers.
- Playback rates: 0.65, 0.75, 0.85, 0.90, 1.00, 1.10, 1.20, 1.35, 1.50. Default runtime rate is 1.00 of the delivered recording, not another application of the ElevenLabs generation speed.
- Chapter offsets are measured against final delivery audio, never estimated from word counts or chapter count.
- Local progress is not cloud backup. Warning acknowledgement is a UX preference, not rights clearance or legal consent.

## Execution rulings
- Ruling: implement Batch 2 in independently verified sub-batches. 2A establishes playback rules and local state; 2B integrates the controller/shared transport; 2C integrates the screen and owner APK. This follows the owner's request for small reliable batches and avoids destabilizing the proven sound player.
- Ruling: use nullable chapter start offsets instead of the Batch 1 `Duration.zero` placeholders. Zero is a real timestamp and twelve zero offsets must never masquerade as measured chapter boundaries.
- Ruling: version progress by story ID, script version and audio version. A re-edited delivery recording must not resume at a stale time from an older edit.
- Ruling: this session uses remote branch isolation and CI because the container has no Flutter SDK or direct network checkout. Do not claim local tests, physical-device playback or access to Desktop/Relief/Stories.

## Review focus
1. Unknown duration or unfinished audio: no fake seek target or saved progress.
2. Negative/out-of-range offsets and duplicate/unordered chapters: reject or clamp safely.
3. Corrupt preference types/JSON: default safely without affecting other app preferences.
4. Changed script, changed warning text or changed audio edit: no stale acknowledgement/progress reuse.
5. Concurrent writes and backward seeking: newest requested position wins; do not use max(position).

## 2A — Playback policy and local state
Files:
- Modify `lib/features/stories/domain/relief_story.dart`: `Duration? start`, default null.
- Modify `lib/features/stories/data/story_catalog.dart`: replace unknown start offsets with null; preserve titles, warning text, rights and audio availability.
- Create `lib/features/stories/application/story_playback_policy.dart`: rates, safe duration/seek rules, complete measured chapter-map validation and chapter lookup.
- Create `lib/features/stories/data/story_playback_store.dart`: local versioned progress, rate preference, warning-text acknowledgement, scoped reset.
- Create `test/story_playback_foundation_test.dart`: real domain/policy tests and SharedPreferences in-memory implementation, including the five review-focus classes above.

Public interfaces for the next sub-batch:
```dart
StoryPlaybackPolicy.supportedRates;
StoryPlaybackPolicy.normaliseRate(Object? value);
StoryPlaybackPolicy.clampPosition(Duration position, Duration duration);
StoryPlaybackPolicy.seekRelative({required Duration position, required Duration delta, required Duration duration});
StoryPlaybackPolicy.hasChapterTimings(ReliefStory story, Duration duration);
StoryPlaybackPolicy.chapterStart(ReliefStory story, String chapterId, Duration duration);
StoryPlaybackStore(SharedPreferences preferences);
store.readProgress(story, duration: measuredDuration); // StoryProgress(position, completed)
store.saveProgress(story, position: position, duration: measuredDuration, completed: false);
store.playbackRate;
store.setPlaybackRate(rate);
store.isWarningAcknowledged(story);
store.acknowledgeWarning(story);
store.resetProgress(story);
```

- [ ] Commit failing behavioral contracts; run CI and inspect the failure.
- [ ] Implement minimal policy/store/domain correction; run focused contracts plus full analyzer/tests.
- [ ] Review the complete diff, record exact passing SHA and unresolved native/UI work.

Verification:
```sh
flutter test test/story_playback_foundation_test.dart --reporter expanded
flutter analyze
flutter test --reporter expanded
```
No new dependency or audio-service code is required for 2A.

## 2B — Controller and shared transport integration
Consumes the 2A interfaces. Implement a serialized cancellation-safe controller with play/pause, -10/+10, chapter jumps, durable pause checkpoints and wall-clock sleep timer. First inspect `SoundPlaybackDriver`, `ReleafBackgroundSoundDriver`, speech audio-session policy and existing cancellation tests. Extend/reuse one initialized media service, restoring sound loop/rate state when ownership changes. Loading a Story must restore position/rate before it can emit narration. Warning decline must not start audio. Test delayed load → pause/stop/switch, notification intent, headphone disconnect and timer expiry. Document exact transport changes before making them; no parallel competing handlers.

## 2C — UI, preview build and pilot import
Integrate the controller into a guarded story route; provide visible back, warning flow, disabled unknown chapter jumps, no surprise autoplay, 320 px / 200% text tests and an explicitly flagged Owner Preview APK. Import one real owner-supplied mastered delivery file only after file availability, source version and permission are verified. Native playback, screen-off timer, speed/pitch and interruption quality remain hardware QA; CI is not listening approval.

## Current ledger
- PR #2 merged with owner consent; main unchanged.
- Batch 2A: tests/implementation not yet verified at plan creation.
- Batch 2B/2C: not implemented. No Story playback is exposed yet.
