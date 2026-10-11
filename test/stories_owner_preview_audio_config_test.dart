import 'package:flutter_test/flutter_test.dart';
import 'package:releaf_app/features/stories/data/story_catalog.dart';

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
      }
    },
    skip: _audioBundled
        ? false
        : 'Run with --dart-define=RELIEF_STORIES_AUDIO_BUNDLED=true.',
  );
}
