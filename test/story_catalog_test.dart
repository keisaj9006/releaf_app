import 'package:flutter_test/flutter_test.dart';
import 'package:releaf_app/features/stories/data/story_catalog.dart';
import 'package:releaf_app/features/stories/domain/relief_story.dart';

void main() {
  test('owner preview catalogue contains TS01 and TS02 only', () {
    expect(StoryCatalog.ownerPreview.map((story) => story.id).toList(), const [
      'TS01_BEYOND_THE_GATE',
      'TS02_KRYSTYNA_SKARBEK',
    ]);
  });

  test('story catalogue IDs are unique', () {
    final ids = StoryCatalog.all.map((story) => story.id).toList();
    expect(ids.toSet().length, ids.length);
  });

  test('true-history preview stories carry required release metadata', () {
    for (final story in StoryCatalog.ownerPreview) {
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

  test('canonical catalogue registers ST-DC-004 without invented assets', () {
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
    expect(story.artworkAssetPath, isNull);
    expect(story.isPremium, isNull);
    expect(story.isAudioAvailable, isFalse);
  });

  test('unknown story IDs are not fabricated', () {
    expect(StoryCatalog.getById('missing'), isNull);
  });
}
