import 'package:flutter_test/flutter_test.dart';

import 'package:releaf_app/features/meditation/application/meditation_voice_controller.dart';
import 'package:releaf_app/features/relief/application/reset_voice_playback.dart';
import 'package:releaf_app/features/relief/domain/reset_voice_guidance.dart';

class _FakeVoiceDriver implements MeditationVoiceDriver {
  final List<String> calls = <String>[];
  final Set<String> failingAssets = <String>{};

  @override
  Future<void> configure({required double volume}) async {
    calls.add('configure:$volume');
  }

  @override
  Future<void> dispose() async {
    calls.add('dispose');
  }

  @override
  Future<void> playAsset(String assetPath) async {
    calls.add('asset:$assetPath');
    if (failingAssets.contains(assetPath)) {
      throw StateError('missing asset');
    }
  }

  @override
  Future<void> setVolume(double volume) async {
    calls.add('volume:$volume');
  }

  @override
  Future<void> speak(String text) async {
    calls.add('speak:$text');
  }

  @override
  Future<void> stop() async {
    calls.add('stop');
  }
}

void main() {
  group('ResetVoicePlayback', () {
    test('prefers a recorded Releaf Guide asset when it can be played', () async {
      final driver = _FakeVoiceDriver();
      final playback = ResetVoicePlayback(driver);

      await playback.playCue(
        const ResetVoiceGuidanceCue(
          key: 'step:main:0',
          spokenText: 'Settle in.',
          narrationAssetPath: 'narration/reset/settle.mp3',
        ),
      );

      expect(
        driver.calls,
        <String>['asset:narration/reset/settle.mp3'],
      );
      expect(playback.unavailableRecordedAssets, isEmpty);
    });

    test('falls back to TTS when a recorded asset is unavailable', () async {
      final driver = _FakeVoiceDriver()
        ..failingAssets.add('narration/reset/missing.mp3');
      final playback = ResetVoicePlayback(driver);

      await playback.playCue(
        const ResetVoiceGuidanceCue(
          key: 'step:main:1',
          spokenText: 'Follow the rhythm.',
          narrationAssetPath: 'narration/reset/missing.mp3',
        ),
      );

      expect(
        driver.calls,
        <String>[
          'asset:narration/reset/missing.mp3',
          'speak:Follow the rhythm.',
        ],
      );
      expect(
        playback.unavailableRecordedAssets,
        contains('narration/reset/missing.mp3'),
      );
    });

    test('does not retry the same missing asset every breathing cycle', () async {
      final driver = _FakeVoiceDriver()
        ..failingAssets.add(
          'narration/releaf-guide/reset/breath-cues/breathe-in.mp3',
        );
      final playback = ResetVoicePlayback(driver);

      const cue = ResetVoiceGuidanceCue(
        key: 'breath:inhale',
        spokenText: 'Breathe in.',
        narrationAssetPath:
            'narration/releaf-guide/reset/breath-cues/breathe-in.mp3',
      );

      await playback.playCue(cue);
      await playback.playCue(cue);

      expect(
        driver.calls,
        <String>[
          'asset:narration/releaf-guide/reset/breath-cues/breathe-in.mp3',
          'speak:Breathe in.',
          'speak:Breathe in.',
        ],
      );
    });

    test('speaks directly when a cue has no recorded asset target', () async {
      final driver = _FakeVoiceDriver();
      final playback = ResetVoicePlayback(driver);

      await playback.playCue(
        const ResetVoiceGuidanceCue(
          key: 'step:main:2',
          spokenText: 'Return gently.',
        ),
      );

      expect(driver.calls, <String>['speak:Return gently.']);
    });
  });
}
