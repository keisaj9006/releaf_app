import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:audio_session/audio_session.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:releaf_app/features/sound/data/sound_catalog.dart';
import 'package:releaf_app/features/sound/application/releaf_background_sound_driver.dart';
import 'package:releaf_app/features/sound/application/sound_player_controller.dart';

class _DelayedPlayer implements AudioPlayer {
  Completer<void>? nextSourceGate;
  final sourceStarted = Completer<void>();
  Completer<void>? nextVolumeGate;
  final volumeStarted = Completer<void>();
  Completer<void>? nextPauseGate;
  final pauseStarted = Completer<void>();
  final played = <String>[];
  final loaded = <String>[];
  final volumes = <double>[];
  final failingAssets = <String>{};
  String? sourcePath;
  bool disposed = false;

  @override
  Stream<Duration> get onDurationChanged => const Stream.empty();
  @override
  Stream<Duration> get onPositionChanged => const Stream.empty();
  @override
  Stream<PlayerState> get onPlayerStateChanged => const Stream.empty();
  @override
  Future<void> setReleaseMode(ReleaseMode mode) async {}
  @override
  Future<void> stop() async {}
  @override
  Future<void> pause() async {
    final gate = nextPauseGate;
    nextPauseGate = null;
    if (gate != null) {
      pauseStarted.complete();
      await gate.future;
    }
  }

  @override
  Future<void> seek(Duration position) async {}
  @override
  Future<void> dispose() async {
    disposed = true;
  }

  @override
  Future<void> setVolume(double volume) async {
    final gate = nextVolumeGate;
    nextVolumeGate = null;
    if (gate != null) {
      volumeStarted.complete();
      await gate.future;
    }
    volumes.add(volume);
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
    final path = (source as AssetSource).path;
    final gate = nextSourceGate;
    nextSourceGate = null;
    if (!sourceStarted.isCompleted) sourceStarted.complete();
    if (gate != null) await gate.future;
    if (failingAssets.contains(path)) throw StateError('test load failed');
    sourcePath = path;
    loaded.add(path);
  }

  @override
  Future<void> resume() async {
    played.add(sourcePath!);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _StatefulDelayedPlayer extends _DelayedPlayer {
  final events = StreamController<PlayerState>.broadcast(sync: true);
  @override
  Stream<PlayerState> get onPlayerStateChanged => events.stream;
  @override
  Future<void> resume() async {
    await super.resume();
    events.add(PlayerState.playing);
  }

  @override
  Future<void> pause() async {
    await super.pause();
    events.add(PlayerState.paused);
  }

  @override
  Future<void> stop() async {
    await super.stop();
    events.add(PlayerState.stopped);
  }

  @override
  Future<void> dispose() async {
    await super.dispose();
    await events.close();
  }
}

void main() {
  for (final action in [
    'none',
    'manual pause',
    'notification pause',
    'notification stop',
  ]) {
    test(
      'interruption end waits for native pause and respects $action',
      () async {
        SharedPreferences.setMockInitialValues({});
        final player = _StatefulDelayedPlayer();
        final driver = ReleafBackgroundSoundDriver(player: player);
        final controller = SoundPlayerController(
          const SoundCatalog(),
          await SharedPreferences.getInstance(),
          driver: driver,
        );
        addTearDown(controller.dispose);
        await controller.playById('deep-drift');
        final gate = Completer<void>();
        player.nextPauseGate = gate;
        final beginning = controller.handleAudioInterruption(
          AudioInterruptionEvent(true, AudioInterruptionType.pause),
        );
        await player.pauseStarted.future;
        final ending = controller.handleAudioInterruption(
          AudioInterruptionEvent(false, AudioInterruptionType.pause),
        );
        await Future<void>.delayed(Duration.zero);
        final newer = switch (action) {
          'manual pause' => controller.pause(),
          'notification pause' => driver.pause(),
          'notification stop' => driver.stop(),
          _ => Future<void>.value(),
        };
        gate.complete();
        await Future.wait([beginning, ending, newer]);
        expect(controller.state.isPlaying, action == 'none');
        expect(player.played.length, action == 'none' ? 2 : 1);
      },
    );
  }
  for (final stage in ['volume', 'pause']) {
    for (final action in ['pause', 'stop', 'play']) {
      test(
        'notification $action during expiry $stage leaves the next play audible',
        () async {
          SharedPreferences.setMockInitialValues({});
          var now = DateTime(2026, 9, 11, 22);
          final player = _StatefulDelayedPlayer();
          final driver = ReleafBackgroundSoundDriver(player: player);
          final controller = SoundPlayerController(
            const SoundCatalog(),
            await SharedPreferences.getInstance(),
            driver: driver,
            now: () => now,
          );
          addTearDown(controller.dispose);
          await controller.playById('deep-drift');
          await controller.setSleepTimer(1);
          final gate = Completer<void>();
          if (stage == 'volume') player.nextVolumeGate = gate;
          if (stage == 'pause') player.nextPauseGate = gate;
          now = now.add(const Duration(seconds: 61));
          final expiring = controller.syncSleepTimerNow();
          await (stage == 'volume'
              ? player.volumeStarted.future
              : player.pauseStarted.future);
          final manual = switch (action) {
            'pause' => driver.pause(),
            'stop' => driver.stop(),
            _ => driver.play(),
          };
          gate.complete();
          await Future.wait([expiring, manual]);
          if (action != 'play') await driver.play();
          expect(controller.state.isPlaying, isTrue);
          expect(controller.state.sleepTimerMinutes, isNull);
          expect(player.volumes.last, controller.state.volume);
        },
      );
    }
  }
  for (final action in ['pause', 'stop']) {
    test(
      'replacing a Sleep timer respects notification $action during expiry',
      () async {
        SharedPreferences.setMockInitialValues({});
        var now = DateTime(2026, 9, 11, 22);
        final player = _StatefulDelayedPlayer();
        final driver = ReleafBackgroundSoundDriver(player: player);
        final controller = SoundPlayerController(
          const SoundCatalog(),
          await SharedPreferences.getInstance(),
          driver: driver,
          now: () => now,
        );
        addTearDown(controller.dispose);
        await controller.playById('deep-drift');
        await controller.setSleepTimer(1);
        final gate = Completer<void>();
        player.nextPauseGate = gate;
        now = now.add(const Duration(seconds: 61));
        final expiring = controller.syncSleepTimerNow();
        await player.pauseStarted.future;
        final replacement = controller.setSleepTimer(30);
        final manual = action == 'pause' ? driver.pause() : driver.stop();
        gate.complete();
        await Future.wait([expiring, replacement, manual]);
        expect(player.played, ['sounds/deep_drift.mp3']);
        expect(controller.state.isPlaying, isFalse);
        expect(controller.state.sleepTimerMinutes, 30);
      },
    );
  }
  for (final action in ['pause', 'stop']) {
    for (final loading in [false, true]) {
      test(
        'notification $action during ${loading ? 'source load' : 'configuration'} cancels controller startup',
        () async {
          SharedPreferences.setMockInitialValues({});
          final preferences = await SharedPreferences.getInstance();
          final player = _DelayedPlayer();
          final driver = ReleafBackgroundSoundDriver(player: player);
          final controller = SoundPlayerController(
            const SoundCatalog(),
            preferences,
            driver: driver,
          );
          addTearDown(controller.dispose);
          final gate = Completer<void>();
          if (loading) {
            player.nextSourceGate = gate;
          } else {
            await controller.playById('soft-rain');
            player.nextVolumeGate = gate;
          }
          final starting = controller.playById('deep-drift');
          await (loading
              ? player.sourceStarted.future
              : player.volumeStarted.future);
          final cancelled = action == 'pause' ? driver.pause() : driver.stop();
          gate.complete();
          await Future.wait([starting, cancelled]);
          expect(controller.state.recentIds, loading ? isEmpty : ['soft-rain']);
          expect(player.played, loading ? isEmpty : ['sounds/soft_rain.mp3']);
          await controller.playById('deep-drift');
          expect(controller.state.recentIds.first, 'deep-drift');
          expect(player.played.last, 'sounds/deep_drift.mp3');
        },
      );
    }
  }

  for (final background in [false, true]) {
    SoundPlaybackDriver makeDriver(_DelayedPlayer player) => background
        ? ReleafBackgroundSoundDriver(player: player)
        : AudioplayersSoundPlaybackDriver(player: player);

    for (final action in ['pause', 'stop', 'dispose', 'replace']) {
      test(
        'Sound background=$background $action cancels delayed source loading',
        () async {
          final gate = Completer<void>();
          final player = _DelayedPlayer()..nextSourceGate = gate;
          final driver = makeDriver(player);
          if (action != 'dispose') addTearDown(driver.dispose);
          final first = driver.playAsset(
            'sounds/first.mp3',
            trackId: 'first',
            title: 'First',
          );
          await player.sourceStarted.future;
          final next = switch (action) {
            'pause' => driver.pause(),
            'stop' => driver.stop(),
            'dispose' => driver.dispose(),
            _ => driver.playAsset(
              'sounds/latest.mp3',
              trackId: 'latest',
              title: 'Latest',
            ),
          };
          gate.complete();
          await Future.wait([first, next]);
          expect(
            player.played,
            action == 'replace' ? ['sounds/latest.mp3'] : isEmpty,
          );
          if (action == 'dispose') expect(player.disposed, isTrue);
          if (background && action == 'replace') {
            expect(
              (driver as ReleafBackgroundSoundDriver).mediaItem.value?.id,
              'latest',
            );
          }
        },
      );
    }

    test(
      'Sound background=$background cannot resume a cancelled load as ready',
      () async {
        final gate = Completer<void>();
        final player = _DelayedPlayer()..nextSourceGate = gate;
        final driver = makeDriver(player);
        addTearDown(driver.dispose);
        final first = driver.playAsset('sounds/cancelled.mp3');
        await player.sourceStarted.future;
        final stopped = driver.stop();
        final resumed = driver.resume();
        gate.complete();
        await Future.wait([first, stopped, resumed]);
        expect(player.played, isEmpty);
      },
    );

    for (final action in ['pause', 'stop']) {
      test(
        'Sound background=$background resumes a successfully loaded source after $action',
        () async {
          final player = _DelayedPlayer();
          final driver = makeDriver(player);
          addTearDown(driver.dispose);
          await driver.playAsset('sounds/ready.mp3');
          if (action == 'pause') await driver.pause();
          if (action == 'stop') await driver.stop();
          await driver.resume();
          expect(player.loaded, ['sounds/ready.mp3']);
          expect(player.played, ['sounds/ready.mp3', 'sounds/ready.mp3']);
        },
      );
    }

    test('Sound background=$background retains latest native volume', () async {
      final gate = Completer<void>();
      final player = _DelayedPlayer()..nextVolumeGate = gate;
      final driver = makeDriver(player);
      addTearDown(driver.dispose);
      final first = driver.setVolume(0.8);
      await player.volumeStarted.future;
      final second = driver.setVolume(0.1);
      gate.complete();
      await Future.wait([first, second]);
      expect(player.volumes.last, 0.1);
    });

    test(
      'Sound background=$background can load after a source failure',
      () async {
        final player = _DelayedPlayer()..failingAssets.add('sounds/broken.mp3');
        final driver = makeDriver(player);
        addTearDown(driver.dispose);
        await expectLater(
          driver.playAsset('sounds/broken.mp3'),
          throwsStateError,
        );
        await driver.playAsset('sounds/good.mp3');
        expect(player.played, ['sounds/good.mp3']);
      },
    );
  }
}
