import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:releaf_app/features/meditation/data/meditation_catalog.dart';
import 'package:releaf_app/features/meditation/domain/meditation_content.dart';
import 'package:releaf_app/features/sleep/data/sleep_catalog.dart';
import 'package:releaf_app/features/sleep/domain/sleep_content_manifest.dart';
import 'package:releaf_app/features/sleep/domain/sleep_content.dart';
import 'package:releaf_app/features/sound/data/sound_catalog.dart';
import 'package:releaf_app/features/sound/domain/sound_content.dart';
import 'package:releaf_app/features/stories/data/story_catalog.dart';
import 'package:releaf_app/features/stories/domain/relief_story.dart';

void main() {
  group('Sleep taxonomy', () {
    test('contains exactly the four owner-approved content categories', () {
      expect(SleepCategory.values.map((category) => category.label), [
        'Stories',
        'Nature',
        'Meditations',
        'Sleep Music',
      ]);
    });

    test('contains exactly the five owner-approved Story collections', () {
      expect(
        SleepStoryCollection.values.map((collection) => collection.label),
        [
          'Dream Classics',
          'Night Mysteries',
          'Fiction Escapes',
          'Wonder Journeys',
          'Drift Through History',
        ],
      );
    });
  });

  group('Sleep catalog', () {
    const catalog = SleepCatalog();

    test('a newly submitted candidate cannot activate an existing sound', () {
      const pending = SleepManifestEntry(
        id: 'soft-rain',
        title: 'Soft Rain',
        description: 'Rain for winding down.',
        category: SleepCategory.nature,
        audioAsset: '',
        artworkAsset: '',
        duration: null,
        accessTier: SleepAccessTier.free,
        source: SleepPlaybackSource.sound('soft-rain'),
        creatorSource: 'Releaf',
        licenceRecord: '',
        approval: SleepApprovalState.pending,
        rights: SleepRightsState.pending,
        releaseNotes: 'Pending review.',
      );
      const withCandidate = SleepCatalog(manifestEntries: [pending]);

      expect(withCandidate.getById('soft-rain')?.isPlayable, isFalse);
      expect(catalog.getById('soft-rain')?.isPlayable, isTrue);
    });

    test('registers the first Story without fabricating production assets', () {
      final story = catalog.getById('ST-DC-004');

      expect(story, isNotNull);
      expect(
        story!.title,
        'The Princess and the Pea — A Rainy Night at the Palace',
      );
      expect(story.category, SleepCategory.stories);
      expect(story.releaseStatus, SleepReleaseStatus.assetPending);
      expect(story.accessTier, SleepAccessTier.undecided);
      expect(story.duration, isNull);
      expect(story.playbackSource?.type, SleepPlaybackSourceType.story);
      expect(story.isPlayable, isFalse);

      final canonicalStory = StoryCatalog.getById(story.id);
      expect(
        canonicalStory?.sleepCollection,
        SleepStoryCollection.dreamClassics,
      );
      expect(canonicalStory?.narrator, 'Theo Silk');
    });

    test('references canonical Sound and Meditation content', () {
      expect(catalog.validateReferences(), isEmpty);

      final nature = catalog.getByCategory(SleepCategory.nature);
      expect(nature.map((item) => item.id), [
        'soft-rain',
        'night-air',
        'ocean-wash',
        'forest-canopy',
      ]);
      expect(
        nature.every(
          (item) => item.playbackSource?.type == SleepPlaybackSourceType.sound,
        ),
        isTrue,
      );

      final music = catalog.getByCategory(SleepCategory.sleepMusic);
      expect(music.map((item) => item.id), [
        'deep-drift',
        'releaf-atmosphere-01',
        'releaf-atmosphere-02',
      ]);

      final meditations = catalog.getByCategory(SleepCategory.meditations);
      expect(meditations.map((item) => item.id), [
        'let-the-day-go-6',
        'body-into-stillness-8',
        'quiet-night-10',
      ]);
      expect(
        meditations.every(
          (item) =>
              item.playbackSource?.type == SleepPlaybackSourceType.meditation,
        ),
        isTrue,
      );
    });

    test('reports a canonical reference that no longer resolves', () {
      const missingSound = SleepCatalog(
        soundCatalog: _MissingSoundCatalog('soft-rain'),
      );
      const missingMeditation = SleepCatalog(
        meditationCatalog: _MissingMeditationCatalog('quiet-night-10'),
      );

      expect(
        missingSound.validateReferences(),
        contains('soft-rain references unknown Sound soft-rain'),
      );
      expect(
        missingMeditation.validateReferences(),
        contains('quiet-night-10 references unknown Meditation quiet-night-10'),
      );
    });

    test('keeps IDs unique and All as a query rather than a category', () {
      final items = catalog.getAll();
      expect(items.map((item) => item.id).toSet(), hasLength(items.length));
      expect(
        SleepCategory.values.map((value) => value.name),
        isNot(contains('all')),
      );
    });

    test(
      'editorial ranks are deterministic and only reference ready content',
      () {
        final featured = catalog.getFeatured();
        final popular = catalog.getPopular();

        expect(featured, isNotEmpty);
        expect(popular, isNotEmpty);
        expect(featured.every((item) => item.isPlayable), isTrue);
        expect(popular.every((item) => item.isPlayable), isTrue);
        expect(
          featured.map((item) => item.featuredRank),
          orderedEquals([1, 2]),
        );
        expect(
          popular.map((item) => item.popularRank),
          orderedEquals([1, 2, 3, 4]),
        );
      },
    );

    test('does not add an ElevenLabs runtime dependency', () {
      final domain = File(
        'lib/features/sleep/domain/sleep_content.dart',
      ).readAsStringSync().toLowerCase();
      final registry = File(
        'lib/features/sleep/data/sleep_catalog.dart',
      ).readAsStringSync().toLowerCase();

      expect(domain, isNot(contains('elevenlabs')));
      expect(registry, isNot(contains('elevenlabs')));
    });
  });

  group('Story chapters', () {
    test('resolve the current chapter from ordered start positions', () {
      const content = ReliefStory(
        id: 'story-test',
        title: 'Test Story',
        subtitle: 'A test',
        series: 'Fiction Escapes',
        category: null,
        description: 'Used to verify chapter resolution.',
        estimatedDuration: Duration(minutes: 30),
        audioAssetPath: 'sounds/story-test.mp3',
        artworkAssetPath: null,
        contentWarning: '',
        labels: [],
        isPremium: false,
        sleepCollection: SleepStoryCollection.fictionEscapes,
        narrator: 'Test Narrator',
        chapters: [
          ReliefStoryChapter(
            id: 'arrival',
            title: 'Arrival',
            start: Duration.zero,
          ),
          ReliefStoryChapter(
            id: 'garden',
            title: 'The Garden',
            start: Duration(minutes: 10),
          ),
          ReliefStoryChapter(
            id: 'home',
            title: 'Home',
            start: Duration(minutes: 20),
          ),
        ],
        rightsStatus: 'TEST ONLY',
        scriptVersion: 'test',
        audioVersion: 'test',
      );

      expect(content.chapterAt(Duration.zero)?.id, 'arrival');
      expect(
        content.chapterAt(const Duration(minutes: 19, seconds: 59))?.id,
        'garden',
      );
      expect(content.chapterAt(const Duration(minutes: 30))?.id, 'home');
      expect(content.chapterAt(const Duration(seconds: -1)), isNull);
    });
  });
}

class _MissingSoundCatalog extends SoundCatalog {
  const _MissingSoundCatalog(this.missingId);

  final String missingId;

  @override
  SoundContent? getById(String id) =>
      id == missingId ? null : super.getById(id);
}

class _MissingMeditationCatalog extends MeditationCatalog {
  const _MissingMeditationCatalog(this.missingId);

  final String missingId;

  @override
  MeditationContent? getById(String id) =>
      id == missingId ? null : super.getById(id);
}
