import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:releaf_app/features/stories/application/story_playback_policy.dart';
import 'package:releaf_app/features/stories/data/story_catalog.dart';
import 'package:releaf_app/features/stories/data/story_playback_store.dart';
import 'package:releaf_app/features/stories/domain/relief_story.dart';

ReliefStory _story({
  String id = 'pilot',
  String script = '2.0',
  String audio = 'mix-1',
  String? path = 'stories/test-only-pilot.mp3',
  String warning = 'This story discusses wartime imprisonment.',
  List<ReliefStoryChapter> chapters = const [
    ReliefStoryChapter(id: 'one', title: 'One', start: Duration.zero),
    ReliefStoryChapter(id: 'two', title: 'Two', start: Duration(seconds: 40)),
  ],
}) => ReliefStory(
  id: id,
  title: 'Test-only story',
  subtitle: 'Not a runtime audio asset',
  series: 'True Stories of Courage',
  category: StoryCategory.trueStoriesOfCourage,
  description: 'Fixture',
  estimatedDuration: const Duration(minutes: 28),
  audioAssetPath: path,
  artworkAssetPath: null,
  contentWarning: warning,
  labels: const ['TRUE STORY'],
  isPremium: false,
  chapters: chapters,
  rightsStatus: 'NOT YET CLEARED FOR COMMERCIAL RELEASE',
  scriptVersion: script,
  audioVersion: audio,
);

const _duration = Duration(seconds: 100);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Story playback policy', () {
    test('unfinished catalogue chapters have no invented timestamps', () {
      for (final story in StoryCatalog.all) {
        for (final chapter in story.chapters) {
          expect(chapter.start, isNull, reason: chapter.id);
        }
        expect(StoryPlaybackPolicy.hasDeliveryMetadata(story), isFalse);
        expect(StoryPlaybackPolicy.hasChapterTimings(story, _duration), isFalse);
      }
    });

    test('rates preserve four slower and four faster choices', () {
      expect(StoryPlaybackPolicy.supportedRates, const [
        0.65, 0.75, 0.85, 0.90, 1.00, 1.10, 1.20, 1.35, 1.50,
      ]);
      expect(StoryPlaybackPolicy.supportedRates.where((r) => r < 1), hasLength(4));
      expect(StoryPlaybackPolicy.supportedRates.where((r) => r > 1), hasLength(4));
    });

    test('runtime defaults to recorded speed rather than applying 0.90 twice', () {
      for (final value in <Object?>[null, '0.90', double.nan, double.infinity, -1, 9]) {
        expect(StoryPlaybackPolicy.normaliseRate(value), 1.0);
      }
      expect(StoryPlaybackPolicy.normaliseRate(0.90), 0.90);
      expect(StoryPlaybackPolicy.normaliseRate(1), 1.0);
    });

    test('seek offsets clamp to measured duration including unknown length', () {
      expect(StoryPlaybackPolicy.clampPosition(const Duration(seconds: -1), _duration), Duration.zero);
      expect(StoryPlaybackPolicy.clampPosition(const Duration(seconds: 120), _duration), _duration);
      expect(StoryPlaybackPolicy.clampPosition(const Duration(seconds: 12), Duration.zero), Duration.zero);
      expect(StoryPlaybackPolicy.clampPosition(const Duration(seconds: 12), const Duration(seconds: -1)), Duration.zero);
    });

    test('relative seek changes by exactly ten media seconds, not rate-scaled seconds', () {
      expect(StoryPlaybackPolicy.seekRelative(position: const Duration(seconds: 50), delta: const Duration(seconds: 10), duration: _duration), const Duration(seconds: 60));
      expect(StoryPlaybackPolicy.seekRelative(position: const Duration(seconds: 5), delta: const Duration(seconds: -10), duration: _duration), Duration.zero);
      expect(StoryPlaybackPolicy.seekRelative(position: const Duration(seconds: 95), delta: const Duration(seconds: 10), duration: _duration), _duration);
    });

    test('valid chapter map uses measured media offsets', () {
      final story = _story();
      expect(StoryPlaybackPolicy.hasChapterTimings(story, _duration), isTrue);
      expect(StoryPlaybackPolicy.chapterStart(story, 'one', _duration), Duration.zero);
      expect(StoryPlaybackPolicy.chapterStart(story, 'two', _duration), const Duration(seconds: 40));
      expect(StoryPlaybackPolicy.chapterStart(story, 'missing', _duration), isNull);
      expect(StoryPlaybackPolicy.chapterStart(story, 'two', Duration.zero), isNull);
    });

    test('duplicate, negative, unordered, late or non-zero first chapters cannot seek', () {
      final maps = <List<ReliefStoryChapter>>[
        [],
        const [ReliefStoryChapter(id: 'one', title: 'One', start: Duration(seconds: 1))],
        const [ReliefStoryChapter(id: 'one', title: 'One', start: Duration(seconds: -1))],
        const [ReliefStoryChapter(id: 'one', title: 'One', start: Duration.zero), ReliefStoryChapter(id: 'two', title: 'Two', start: Duration.zero)],
        const [ReliefStoryChapter(id: 'one', title: 'One', start: Duration.zero), ReliefStoryChapter(id: 'one', title: 'Two', start: Duration(seconds: 40))],
        const [ReliefStoryChapter(id: 'one', title: 'One', start: Duration.zero), ReliefStoryChapter(id: 'two', title: 'Two', start: Duration(seconds: 100))],
        const [ReliefStoryChapter(id: 'one', title: 'One', start: Duration.zero), ReliefStoryChapter(id: 'two', title: 'Two', start: Duration(seconds: 70)), ReliefStoryChapter(id: 'three', title: 'Three', start: Duration(seconds: 40))],
      ];
      for (final chapters in maps) {
        final story = _story(chapters: chapters);
        expect(StoryPlaybackPolicy.hasChapterTimings(story, _duration), isFalse);
        expect(StoryPlaybackPolicy.chapterStart(story, 'one', _duration), isNull);
      }
    });

    test('path alone does not mean a versioned delivery exists', () {
      for (final story in [_story(path: null), _story(path: '  '), _story(audio: 'pending'), _story(audio: ' '), _story(script: '')]) {
        expect(StoryPlaybackPolicy.hasDeliveryMetadata(story), isFalse);
        expect(StoryPlaybackPolicy.hasChapterTimings(story, _duration), isFalse);
      }
    });
  });

  group('Story local preferences', () {
    late SharedPreferences prefs;
    late StoryPlaybackStore store;

    setUp(() async {
      SharedPreferences.setMockInitialValues({'unrelated.progress': 73});
      prefs = await SharedPreferences.getInstance();
      store = StoryPlaybackStore(prefs);
    });

    test('new listener starts at zero with no completion or last-played record', () {
      final progress = store.readProgress(_story(), duration: _duration);
      expect(progress.position, Duration.zero);
      expect(progress.completed, isFalse);
      expect(store.lastPlayedId, isNull);
      expect(store.playbackRate, 1.0);
      expect(store.isWarningAcknowledged(_story()), isFalse);
    });

    test('position and completion survive rebuilding the store', () async {
      expect(await store.saveProgress(_story(), position: const Duration(seconds: 96), duration: _duration, completed: true), isTrue);
      final restored = StoryPlaybackStore(prefs);
      final progress = restored.readProgress(_story(), duration: _duration);
      expect(progress.position, const Duration(seconds: 96));
      expect(progress.completed, isTrue);
      expect(restored.lastPlayedId, 'pilot');
    });

    test('saved positions clamp to the actual file length, not estimated duration', () async {
      await store.saveProgress(_story(), position: const Duration(seconds: 500), duration: _duration);
      expect(store.readProgress(_story(), duration: _duration).position, _duration);
      expect(store.readProgress(_story(), duration: const Duration(seconds: 70)).position, const Duration(seconds: 70));
      await store.saveProgress(_story(), position: const Duration(seconds: -3), duration: _duration);
      expect(store.readProgress(_story(), duration: _duration).position, Duration.zero);
    });

    test('seeking near the end alone does not invent a listening completion', () async {
      await store.saveProgress(_story(), position: const Duration(seconds: 96), duration: _duration);
      expect(store.readProgress(_story(), duration: _duration).completed, isFalse);
      await store.saveProgress(_story(), position: const Duration(seconds: 10), duration: _duration, completed: true);
      expect(store.readProgress(_story(), duration: _duration).completed, isFalse);
    });

    test('genuine completion persists on rewind until explicitly reset', () async {
      await store.saveProgress(_story(), position: const Duration(seconds: 96), duration: _duration, completed: true);
      await store.saveProgress(_story(), position: const Duration(seconds: 5), duration: _duration);
      expect(store.readProgress(_story(), duration: _duration).completed, isTrue);
      await store.resetProgress(_story());
      expect(store.readProgress(_story(), duration: _duration).completed, isFalse);
      expect(store.readProgress(_story(), duration: _duration).position, Duration.zero);
    });

    test('new script or new edit cannot reuse an older recording position', () async {
      await store.saveProgress(_story(), position: const Duration(seconds: 60), duration: _duration);
      expect(store.readProgress(_story(audio: 'mix-2'), duration: _duration).position, Duration.zero);
      expect(store.readProgress(_story(script: '3.0'), duration: _duration).position, Duration.zero);
      expect(store.readProgress(_story(id: 'other'), duration: _duration).position, Duration.zero);
      expect(store.readProgress(_story(), duration: _duration).position, const Duration(seconds: 60));
    });

    test('unknown duration and unfinished audio never create fake progress', () async {
      expect(await store.saveProgress(_story(), position: const Duration(seconds: 5), duration: Duration.zero), isFalse);
      for (final story in StoryCatalog.all) {
        expect(await store.saveProgress(story, position: const Duration(seconds: 5), duration: _duration), isFalse);
      }
      expect(store.lastPlayedId, isNull);
      expect(prefs.getKeys(), {'unrelated.progress'});
    });

    test('queued backward seek wins over older higher position writes', () async {
      final first = store.saveProgress(_story(), position: const Duration(seconds: 90), duration: _duration);
      final second = store.saveProgress(_story(), position: const Duration(seconds: 10), duration: _duration);
      final third = store.saveProgress(_story(), position: const Duration(seconds: 5), duration: _duration);
      expect(await Future.wait([first, second, third]), [true, true, true]);
      expect(StoryPlaybackStore(prefs).readProgress(_story(), duration: _duration).position, const Duration(seconds: 5));
    });

    test('corrupt JSON, types and unsupported schemas fall back without throwing', () async {
      await store.saveProgress(_story(), position: const Duration(seconds: 25), duration: _duration);
      final key = prefs.getKeys().singleWhere((key) => key.startsWith('stories.v1.progress|'));
      for (final value in [
        'broken json', '[]', 'null',
        jsonEncode({'schema': 2, 'positionMs': 12000, 'completed': true}),
        jsonEncode({'schema': 1, 'positionMs': -1, 'completed': false}),
        jsonEncode({'schema': 1, 'positionMs': '12000', 'completed': true}),
        jsonEncode({'schema': 1, 'positionMs': 12000, 'completed': 'yes'}),
      ]) {
        await prefs.setString(key, value);
        final progress = store.readProgress(_story(), duration: _duration);
        expect(progress.position, Duration.zero);
        expect(progress.completed, isFalse);
      }
      await prefs.setInt(key, 123);
      expect(store.readProgress(_story(), duration: _duration).position, Duration.zero);
    });

    test('reset only clears one version and preserves warnings, rate and unrelated data', () async {
      await store.setPlaybackRate(1.20);
      await store.acknowledgeWarning(_story());
      await store.saveProgress(_story(), position: const Duration(seconds: 20), duration: _duration);
      await store.saveProgress(_story(audio: 'mix-2'), position: const Duration(seconds: 30), duration: _duration);
      await store.resetProgress(_story());
      expect(store.readProgress(_story(), duration: _duration).position, Duration.zero);
      expect(store.readProgress(_story(audio: 'mix-2'), duration: _duration).position, const Duration(seconds: 30));
      expect(store.isWarningAcknowledged(_story()), isTrue);
      expect(store.playbackRate, 1.20);
      expect(prefs.getInt('unrelated.progress'), 73);
    });

    test('warning acknowledgement survives restart but not changed warning or script', () async {
      expect(await store.acknowledgeWarning(_story()), isTrue);
      final restored = StoryPlaybackStore(prefs);
      expect(restored.isWarningAcknowledged(_story()), isTrue);
      expect(restored.isWarningAcknowledged(_story(audio: 'mix-2')), isTrue);
      expect(restored.isWarningAcknowledged(_story(script: '3.0')), isFalse);
      expect(restored.isWarningAcknowledged(_story(warning: 'Additional content warning.')), isFalse);
      expect(restored.isWarningAcknowledged(_story(id: 'other')), isFalse);
      expect(restored.lastPlayedId, isNull);
    });

    test('no-warning story is acknowledged without writing an acknowledgement', () async {
      final story = _story(warning: '  ');
      expect(store.isWarningAcknowledged(story), isTrue);
      expect(await store.acknowledgeWarning(story), isTrue);
      expect(prefs.getKeys(), {'unrelated.progress'});
    });

    test('corrupt warning preference fails closed', () async {
      await store.acknowledgeWarning(_story());
      final key = prefs.getKeys().singleWhere((key) => key.startsWith('stories.v1.warning|'));
      await prefs.setBool(key, true);
      expect(store.isWarningAcknowledged(_story()), isFalse);
    });

    test('playback rate roundtrips and invalid requests preserve last valid rate', () async {
      for (final rate in StoryPlaybackPolicy.supportedRates) {
        expect(await store.setPlaybackRate(rate), isTrue);
        expect(StoryPlaybackStore(prefs).playbackRate, rate);
      }
      for (final rate in [double.nan, double.infinity, 0.0, -1.0, 7.0]) {
        expect(await store.setPlaybackRate(rate), isFalse);
        expect(store.playbackRate, 1.50);
      }
    });

    test('corrupt playback rate and last-played types use safe defaults', () async {
      await store.setPlaybackRate(1.20);
      final key = prefs.getKeys().singleWhere((key) => key.startsWith('stories.v1.rate'));
      await prefs.setString(key, 'fast');
      expect(store.playbackRate, 1.0);
      await prefs.setDouble(key, double.nan);
      expect(store.playbackRate, 1.0);
    });

    test('encoded identifiers cannot alias another story/version record', () async {
      final first = _story(id: 'a|b', script: 'c');
      final second = _story(id: 'a', script: 'b|c');
      await store.saveProgress(first, position: const Duration(seconds: 10), duration: _duration);
      await store.saveProgress(second, position: const Duration(seconds: 20), duration: _duration);
      expect(store.readProgress(first, duration: _duration).position, const Duration(seconds: 10));
      expect(store.readProgress(second, duration: _duration).position, const Duration(seconds: 20));
    });
  });
}
