import 'dart:async';

import 'package:audioplayers/audioplayers.dart' as audio;
import 'package:flutter_test/flutter_test.dart';
import 'package:releaf_app/features/sound/application/sound_player_controller.dart';
import 'package:releaf_app/features/sound/data/sound_catalog.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _PlaybackDriver implements SoundPlaybackDriver {
  final durations = StreamController<Duration>.broadcast(sync: true);
  final positions = StreamController<Duration>.broadcast(sync: true);
  final states = StreamController<audio.PlayerState>.broadcast(sync: true);
  final releaseModes = <audio.ReleaseMode>[];
  final seeks = <Duration>[];
  final playedAssets = <String>[];

  @override
  Stream<Duration> get onDurationChanged => durations.stream;

  @override
  Stream<Duration> get onPositionChanged => positions.stream;

  @override
  Stream<audio.PlayerState> get onPlayerStateChanged => states.stream;

  @override
  Future<void> setReleaseMode(audio.ReleaseMode mode) async {
    releaseModes.add(mode);
  }

  @override
  Future<void> setVolume(double volume) async {}

  @override
  Future<void> playAsset(
    String assetPath, {
    String? trackId,
    String? title,
  }) async {
    playedAssets.add(assetPath);
    states.add(audio.PlayerState.playing);
  }

  @override
  Future<void> resume() async {
    states.add(audio.PlayerState.playing);
  }

  @override
  Future<void> pause() async {
    states.add(audio.PlayerState.paused);
  }

  @override
  Future<void> stop() async {
    states.add(audio.PlayerState.stopped);
  }

  @override
  Future<void> seek(Duration position) async {
    seeks.add(position);
    positions.add(position);
  }

  @override
  Future<void> dispose() async {
    await durations.close();
    await positions.close();
    await states.close();
  }
}

Future<SoundPlayerController> _controller(_PlaybackDriver driver) async {
  SharedPreferences.setMockInitialValues({});
  return SoundPlayerController(
    const SoundCatalog(),
    await SharedPreferences.getInstance(),
    driver: driver,
  );
}

void main() {
  test('existing Sound content remains looped', () async {
    final driver = _PlaybackDriver();
    final controller = await _controller(driver);
    addTearDown(controller.dispose);

    await controller.playById('soft-rain');

    expect(driver.releaseModes.last, audio.ReleaseMode.loop);
    expect(controller.state.playbackMode, ReleafPlaybackMode.looping);
  });

  test('long-form content plays once and reports finite completion', () async {
    final driver = _PlaybackDriver();
    final controller = await _controller(driver);
    addTearDown(controller.dispose);

    await controller.playAsset(
      id: 'story',
      title: 'Story',
      assetPath: 'sounds/story.mp3',
      mode: ReleafPlaybackMode.finite,
    );
    driver.durations.add(const Duration(minutes: 20));
    driver.positions.add(const Duration(minutes: 20));
    driver.states.add(audio.PlayerState.completed);
    driver.states.add(audio.PlayerState.stopped);

    expect(driver.releaseModes.last, audio.ReleaseMode.stop);
    expect(driver.playedAssets, ['sounds/story.mp3']);
    expect(controller.state.isPlaying, isFalse);
    expect(controller.state.isCompleted, isTrue);
    expect(controller.state.playbackMode, ReleafPlaybackMode.finite);
  });

  test('relative seek clamps exactly at zero and known duration', () async {
    final driver = _PlaybackDriver();
    final controller = await _controller(driver);
    addTearDown(controller.dispose);
    await controller.playAsset(
      id: 'story',
      title: 'Story',
      assetPath: 'sounds/story.mp3',
      mode: ReleafPlaybackMode.finite,
    );
    driver.durations.add(const Duration(seconds: 100));

    driver.positions.add(const Duration(seconds: 5));
    await controller.seekRelative(const Duration(seconds: -10));
    driver.positions.add(const Duration(seconds: 95));
    await controller.seekRelative(const Duration(seconds: 10));

    expect(driver.seeks, [Duration.zero, const Duration(seconds: 100)]);
  });

  test(
    'unknown duration clamps negative seeks but permits forward seek',
    () async {
      final driver = _PlaybackDriver();
      final controller = await _controller(driver);
      addTearDown(controller.dispose);
      await controller.playAsset(
        id: 'story',
        title: 'Story',
        assetPath: 'sounds/story.mp3',
        mode: ReleafPlaybackMode.finite,
      );

      await controller.seekTo(const Duration(seconds: -1));
      await controller.seekRelative(const Duration(seconds: 10));

      expect(driver.seeks, [Duration.zero, const Duration(seconds: 10)]);
    },
  );

  test('absolute seek clamps at a known duration end', () async {
    final driver = _PlaybackDriver();
    final controller = await _controller(driver);
    addTearDown(controller.dispose);
    await controller.playAsset(
      id: 'story',
      title: 'Story',
      assetPath: 'sounds/story.mp3',
      mode: ReleafPlaybackMode.finite,
    );
    driver.durations.add(const Duration(minutes: 10));

    await controller.seekTo(const Duration(minutes: 40));

    expect(driver.seeks.single, const Duration(minutes: 10));
  });

  test('replaying completed finite content restarts from zero', () async {
    final driver = _PlaybackDriver();
    final controller = await _controller(driver);
    addTearDown(controller.dispose);
    await controller.playAsset(
      id: 'story',
      title: 'Story',
      assetPath: 'sounds/story.mp3',
      mode: ReleafPlaybackMode.finite,
    );
    driver.durations.add(const Duration(minutes: 10));
    driver.positions.add(const Duration(minutes: 10));
    driver.states.add(audio.PlayerState.completed);

    await controller.resume();

    expect(driver.seeks.last, Duration.zero);
    expect(controller.state.isCompleted, isFalse);
  });
}
