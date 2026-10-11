import 'package:flutter_test/flutter_test.dart';
import 'package:releaf_app/features/stories/data/story_catalog.dart';
import 'package:releaf_app/features/stories/domain/relief_story.dart';

void main() {
  test('prepared Stories catalogue contains all three review titles', () {
    expect(StoryCatalog.ownerPreview.map((story) => story.id).toList(), const [
      'TS01_BEYOND_THE_GATE',
      'TS02_KRYSTYNA_SKARBEK',
      'ST_L05_COMPUTER',
    ]);
  });

  test('story catalogue IDs are unique', () {
    final ids = StoryCatalog.all.map((story) => story.id).toList();
    expect(ids.toSet().length, ids.length);
  });

  test('true-history titles retain their release metadata', () {
    final trueHistory = StoryCatalog.ownerPreview.where(
      (story) => story.category == StoryCategory.trueStoriesOfCourage,
    );

    expect(trueHistory, hasLength(2));
    for (final story in trueHistory) {
      expect(story.scriptVersion, '2.0');
      expect(story.contentWarning, isNotEmpty);
      expect(
        story.labels,
        containsAll(const ['TRUE STORY', 'WORLD WAR II', 'NON-GRAPHIC']),
      );
      expect(story.audioAssetPath, isNull);
      expect(story.isAudioAvailable, isFalse);
      expect(story.artworkAssetPath, 'assets/art/relief/sleep_stories.webp');
    }
  });

  test('Computer retains the prepared master metadata without faking audio', () {
    final story = StoryCatalog.getById('ST_L05_COMPUTER');

    expect(story, isNotNull);
    expect(story!.title, 'Computer');
    expect(story.estimatedDuration, const Duration(minutes: 21));
    expect(story.category, StoryCategory.meaningStories);
    expect(story.audioAssetPath, isNull);
    expect(story.audioVersion, 'preview master prepared off-repo');
    expect(story.isAudioAvailable, isFalse);
  });

  test('canonical catalogue registers ST-DC-004 without invented audio', () {
    final story = StoryCatalog.getById('ST-DC-004');

    expect(story, isNotNull);
    expect(
      story!.title,
      'The Princess and the Pea — A Rainy Night at the Palace',
    );
    expect(story.sleepCollection, SleepStoryCollection.dreamClassics);
    expect(story.narrator, 'Theo Silk');
    expect(story.estimatedDuration, isNull);
    expect(story.audioAssetPath, isNull);
    expect(story.artworkAssetPath, 'assets/art/relief/sleep_stories.webp');
    expect(story.isPremium, isNull);
    expect(story.isAudioAvailable, isFalse);
  });

  test('unknown story IDs are not fabricated', () {
    expect(StoryCatalog.getById('missing'), isNull);
  });
}
