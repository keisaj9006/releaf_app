import 'dart:io';

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

  test('local builder pins the verified final v2 delivery pack', () {
    final script = File(
      'tool/stories/build_owner_preview_with_local_audio.sh',
    ).readAsStringSync();

    const verified = <String, ({String sha256, String duration})>{
      'ST_TS01_BEYOND_THE_GATE_v01_128k.m4a': (
        sha256:
            '67009b29d10f04cd8461ea9a130812c8d38fd770ff070b8a8da20df027274786',
        duration: '1971.960000',
      ),
      'ST_TS02_KRYSTYNA_SKARBEK_v01_128k.m4a': (
        sha256:
            '5f6d8e1686777c40a3049c561ce275eb21759436842a73a116bd8c6764db324c',
        duration: '2198.667000',
      ),
      'ST_L05_COMPUTER_v01_128k.m4a': (
        sha256:
            '74102b5fd0c5b0fb99a420c4d8413c739b7d75ae43808792ecbceb7af7cfbf01',
        duration: '1245.260000',
      ),
    };

    for (final entry in verified.entries) {
      expect(script, contains(entry.key), reason: entry.key);
      expect(script, contains(entry.value.sha256), reason: entry.key);
      expect(script, contains(entry.value.duration), reason: entry.key);
    }
    expect(script, contains(r'''[[ "$sample_rate" == '44100' && "$channels" == '2' ]]'''));
    expect(script, isNot(contains(r'''[[ "$sample_rate" == '48000' ''')));
  });
}
