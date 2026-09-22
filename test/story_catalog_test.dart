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
