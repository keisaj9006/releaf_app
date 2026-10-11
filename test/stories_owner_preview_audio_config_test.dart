import 'package:flutter_test/flutter_test.dart';
import 'package:releaf_app/features/stories/data/story_catalog.dart';
import 'package:releaf_app/features/stories/story_preview_config.dart';

const _audioBundled = bool.fromEnvironment(
  'RELIEF_STORIES_AUDIO_BUNDLED',
  defaultValue: false,
);

void main() {
  test(
    'owner preview maps all three verified M4A masters when audio is bundled',
    () {
      const expected = <String, String>{
        'TS01_BEYOND_THE_GATE':
            'audio/stories/ST_TS01_BEYOND_THE_GATE_v01_128k.m4a',
        'TS02_KRYSTYNA_SKARBEK':
            'audio/stories/ST_TS02_KRYSTYNA_SKARBEK_v01_128k.m4a',
        'ST_L05_COMPUTER':
            'audio/stories/ST_L05_COMPUTER_v01_128k.m4a',
      };

      expect(StoryCatalog.ownerPreview, hasLength(expected.length));
      for (final story in StoryCatalog.ownerPreview) {
        expect(story.audioAssetPath, expected[story.id], reason: story.id);
        expect(story.isAudioAvailable, isTrue, reason: story.id);
        expect(
          story.chapters,
          isEmpty,
          reason: '${story.id} has no approved chapter timecodes yet',
        );
      }
      expect(StoryPreviewConfig.audioBundled, isTrue);
    },
    skip: _audioBundled
        ? false
        : 'Run with owner-preview audio and Premium preview defines.',
  );

  test(
    'ordinary builds never reference private owner-preview masters',
    () {
      for (final story in StoryCatalog.ownerPreview) {
        expect(story.audioAssetPath, isNull, reason: story.id);
        expect(story.isAudioAvailable, isFalse, reason: story.id);
      }
      expect(StoryPreviewConfig.audioBundled, isFalse);
      expect(StoryPreviewConfig.enabled, isFalse);
    },
    skip: _audioBundled ? 'Audio-enabled contract is tested separately.' : false,
  );
}
