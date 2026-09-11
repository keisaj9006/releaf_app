import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:releaf_app/features/meditation/application/meditation_voice_controller.dart';
import 'package:releaf_app/features/meditation/application/meditation_audio_controller.dart';
import 'package:releaf_app/features/relief/application/reset_voice_playback.dart';
import 'package:releaf_app/features/relief/domain/reset_voice_guidance.dart';

class _DelayedPlayer implements AudioPlayer {
  _DelayedPlayer({this.delaySource = false});
  final bool delaySource;
  final sourceLoading = Completer<void>();
  final sourceReady = Completer<void>();
  String? sourcePath;
  final preparing = Completer<void>();
  final prepared = Completer<void>();
  final List<String> played = [];
  bool disposed = false;

  @override
  Future<void> setReleaseMode(ReleaseMode mode) async {
    if (!preparing.isCompleted) preparing.complete();
    await prepared.future;
  }

  @override
  Future<void> stop() async {}
  @override
  Future<void> pause() async {}
  @override
  Future<void> setVolume(double volume) async {}
  @override
  Future<void> dispose() async {
    disposed = true;
  }

  @override
  Future<void> play(
    Source source, {
    double? volume,
    double? balance,
    AudioContext? ctx,
    Duration? position,
    PlayerMode? mode,
  }) async {
    await setSource(source);
    await resume();
  }

  @override
  Future<void> setSource(Source source) async {
    sourcePath = (source as AssetSource).path;
    if (!sourceLoading.isCompleted) sourceLoading.complete();
    if (delaySource) await sourceReady.future;
  }

  @override
  Future<void> resume() async {
    played.add(sourcePath!);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  test('ambience resume cannot revive a cancelled source load', () async {
    final player = _DelayedPlayer(delaySource: true);
    player.prepared.complete();
    final driver = AudioplayersMeditationAudioDriver(player: player);
    final first = driver.playAsset('ambience/cancelled.mp3', volume: 0);
    await player.sourceLoading.future;
    final stopped = driver.stop();
    final resumed = driver.resume();
    player.sourceReady.complete();
    await Future.wait([first, stopped, resumed]);
    expect(player.played, isEmpty);
  });

  test('ambience resume does not cancel pending preparation', () async {
    final player = _DelayedPlayer();
    final driver = AudioplayersMeditationAudioDriver(player: player);
    final first = driver.playAsset('ambience/current.mp3', volume: 0);
    await player.preparing.future;
    final resumed = driver.resume();
    player.prepared.complete();
    await Future.wait([first, resumed]);
    expect(player.played, ['ambience/current.mp3']);
  });
  for (final action in ['pause', 'stop', 'dispose', 'replace']) {
    test('Ambience $action cancels source loading', () async {
      final player = _DelayedPlayer(delaySource: true);
      player.prepared.complete();
      final driver = AudioplayersMeditationAudioDriver(player: player);
      final first = driver.playAsset('ambience/first.mp3', volume: 0);
      await player.sourceLoading.future;
      final next = switch (action) {
        'pause' => driver.pause(),
        'stop' => driver.stop(),
        'dispose' => driver.dispose(),
        _ => driver.playAsset('ambience/latest.mp3', volume: 0),
      };
      player.sourceReady.complete();
      await Future.wait([first, next]);
      expect(
        player.played,
        action == 'replace' ? ['ambience/latest.mp3'] : isEmpty,
      );
    });
  }
  for (final silent in [false, true]) {
    test(
      'Reset supersedes source loading with ${silent ? 'silence' : 'new cue'}',
      () async {
        final player = _DelayedPlayer(delaySource: true);
        player.prepared.complete();
        final playback = ResetVoicePlayback(
          FlutterMeditationVoiceDriver(player: player),
        );
        final first = playback.playCue(
          const ResetVoiceGuidanceCue(
            key: 'first',
            spokenText: '',
            narrationAssetPath: 'approved/first.mp3',
          ),
        );
        await player.sourceLoading.future;
        final next = playback.playCue(
          ResetVoiceGuidanceCue(
            key: 'next',
            spokenText: '',
            narrationAssetPath: silent ? null : 'approved/latest.mp3',
          ),
          volume: 0.72,
        );
        player.sourceReady.complete();
        await Future.wait([first, next]);
        expect(player.played, silent ? isEmpty : ['approved/latest.mp3']);
      },
    );
  }
  for (final action in ['stop', 'dispose', 'replace']) {
    test('$action cancels a clip during source loading', () async {
      final player = _DelayedPlayer(delaySource: true);
      player.prepared.complete();
      final driver = FlutterMeditationVoiceDriver(player: player);
      final first = driver.playAsset('approved/first.mp3');
      await player.sourceLoading.future;
      final next = switch (action) {
        'stop' => driver.stop(),
        'dispose' => driver.dispose(),
        _ => driver.playAsset('approved/latest.mp3'),
      };
      player.sourceReady.complete();
      await Future.wait([first, next]);
      expect(
        player.played,
        action == 'replace' ? ['approved/latest.mp3'] : isEmpty,
      );
    });
  }
  for (final dispose in [false, true]) {
    test(
      '${dispose ? 'dispose' : 'stop'} cancels a prepared but unstarted clip',
      () async {
        final player = _DelayedPlayer();
        final driver = FlutterMeditationVoiceDriver(player: player);
        final playing = driver.playAsset('approved/first.mp3');
        await player.preparing.future;
        final cancelled = dispose ? driver.dispose() : driver.stop();
        player.prepared.complete();
        await Future.wait([playing, cancelled]);
        expect(player.played, isEmpty);
        if (dispose) expect(player.disposed, isTrue);
      },
    );
  }

  test('newer cue supersedes a clip still preparing', () async {
    final player = _DelayedPlayer();
    final driver = FlutterMeditationVoiceDriver(player: player);
    final first = driver.playAsset('approved/first.mp3');
    await player.preparing.future;
    final latest = driver.playAsset('approved/latest.mp3');
    player.prepared.complete();
    await Future.wait([first, latest]);
    expect(player.played, ['approved/latest.mp3']);
  });
}
