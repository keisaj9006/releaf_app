import 'dart:async';

import 'package:flutter_test/flutter_test.dart';

import 'package:releaf_app/features/meditation/application/meditation_voice_controller.dart';
import 'package:releaf_app/features/relief/application/reset_voice_playback.dart';
import 'package:releaf_app/features/relief/data/reset_catalog.dart';
import 'package:releaf_app/features/relief/domain/reset_voice_guidance.dart';

class _FakeVoiceDriver implements MeditationVoiceDriver {
  final List<String> calls = <String>[];
  final Set<String> failingAssets = <String>{};
  Completer<void>? configureGate;
  final configureStarted = Completer<void>();

  @override
  Future<void> configure({required double volume}) async {
    calls.add('configure:$volume');
    if (!configureStarted.isCompleted) configureStarted.complete();
    if (configureGate != null) await configureGate!.future;
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
  Future<void> stop() async {
    calls.add('stop');
  }
}

void main() {
  group('ResetVoicePlayback', () {
    test('rejected breathing assets never reach the audio driver', () async {
      final driver = _FakeVoiceDriver();
      final playback = ResetVoicePlayback(driver);
      final program = const ResetCatalog().getById('equal-rhythm')!.program!;

      for (final second in [0, 5, 10, 15]) {
        await playback.playCue(
          resetVoiceGuidanceCue(
            program: program,
            elapsedSeconds: second,
            simplified: false,
          ),
          volume: 0.72,
        );
      }

      expect(driver.calls, ['stop', 'stop', 'stop', 'stop']);
      expect(playback.unavailableRecordedAssets, isEmpty);
    });
    test('cancelled configuration cannot start a Reset cue', () async {
      final driver = _FakeVoiceDriver()..configureGate = Completer<void>();
      final playback = ResetVoicePlayback(driver);
      final playing = playback.playCue(
        const ResetVoiceGuidanceCue(
          key: 'inhale',
          spokenText: '',
          narrationAssetPath: 'approved/inhale.mp3',
        ),
        volume: 0.72,
      );
      await driver.configureStarted.future;
      playback.cancelPending();
      driver.configureGate!.complete();
      await playing;
      expect(driver.calls, ['stop', 'configure:0.72']);
    });
    test(
      'prefers a recorded Releaf Guide asset when it can be played',
      () async {
        final driver = _FakeVoiceDriver();
        final playback = ResetVoicePlayback(driver);

        await playback.playCue(
          const ResetVoiceGuidanceCue(
            key: 'step:main:0',
            spokenText: 'Settle in.',
            narrationAssetPath: 'narration/reset/settle.mp3',
          ),
        );

        expect(driver.calls, <String>[
          'stop',
          'asset:narration/reset/settle.mp3',
        ]);
        expect(playback.unavailableRecordedAssets, isEmpty);
      },
    );

    test('stays silent when a recorded asset is unavailable', () async {
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

      expect(driver.calls, <String>[
        'stop',
        'asset:narration/reset/missing.mp3',
      ]);
      expect(
        playback.unavailableRecordedAssets,
        contains('narration/reset/missing.mp3'),
      );
    });

    test(
      'does not retry the same missing asset every breathing cycle',
      () async {
        final driver = _FakeVoiceDriver()
          ..failingAssets.add('sounds/reset/breath-cues/inhale.mp3');
        final playback = ResetVoicePlayback(driver);

        const cue = ResetVoiceGuidanceCue(
          key: 'breath:inhale',
          spokenText: '',
          narrationAssetPath: 'sounds/reset/breath-cues/inhale.mp3',
        );

        await playback.playCue(cue);
        await playback.playCue(cue);

        expect(driver.calls, <String>[
          'stop',
          'asset:sounds/reset/breath-cues/inhale.mp3',
          'stop',
        ]);
      },
    );

    test('stays silent when a cue has no approved asset target', () async {
      final driver = _FakeVoiceDriver();
      final playback = ResetVoicePlayback(driver);

      await playback.playCue(
        const ResetVoiceGuidanceCue(
          key: 'step:main:2',
          spokenText: 'Return gently.',
        ),
      );

      expect(driver.calls, ['stop']);
    });
  });
}
