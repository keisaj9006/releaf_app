import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:releaf_app/features/meditation/application/meditation_audio_controller.dart';
import 'package:releaf_app/features/sound/data/sound_catalog.dart';

class _DelayedAmbience implements MeditationAudioDriver {
  final started = Completer<void>();
  final ready = Completer<void>();
  final volumes = <double>[];
  final firstAudibleVolume = Completer<void>();
  bool failStop = false;
  int pauses = 0;
  int stops = 0;
  @override
  Future<void> playAsset(String path, {required double volume}) async {
    volumes.add(volume);
    if (!started.isCompleted) started.complete();
    await ready.future;
  }

  @override
  Future<void> setVolume(double volume) async {
    volumes.add(volume);
    if (volume > 0 && !firstAudibleVolume.isCompleted) {
      firstAudibleVolume.complete();
    }
  }

  @override
  Future<void> pause() async {
    pauses++;
  }

  @override
  Future<void> stop() async {
    stops++;
    if (failStop) throw StateError('platform stop failed');
  }

  @override
  Future<void> resume() async {}
  @override
  Future<void> dispose() async {}
}

void main() {
  test('failed initial stop does not break the meditation session', () async {
    SharedPreferences.setMockInitialValues({});
    final driver = _DelayedAmbience()..failStop = true;
    driver.ready.complete();
    final controller = MeditationAudioController(
      const SoundCatalog(),
      await SharedPreferences.getInstance(),
      driver,
    );
    addTearDown(controller.dispose);
    await controller.start(soundId: 'deep-drift', volume: 0.16);
    expect(controller.state.isPlaying, isTrue);
  });

  test('stop supersedes an in-progress ambience fade', () async {
    SharedPreferences.setMockInitialValues({});
    final driver = _DelayedAmbience();
    driver.ready.complete();
    final controller = MeditationAudioController(
      const SoundCatalog(),
      await SharedPreferences.getInstance(),
      driver,
    );
    addTearDown(controller.dispose);
    final playing = controller.start(soundId: 'deep-drift', volume: 0.16);
    await driver.firstAudibleVolume.future;
    await controller.stop();
    await playing;
    expect(driver.volumes.last, 0);
    expect(controller.state.isPlaying, isFalse);
  });
  for (final action in ['pause', 'stop', 'mute', 'dispose']) {
    test('$action prevents delayed ambience startup from fading in', () async {
      SharedPreferences.setMockInitialValues({});
      final driver = _DelayedAmbience();
      final controller = MeditationAudioController(
        const SoundCatalog(),
        await SharedPreferences.getInstance(),
        driver,
      );
      final playing = controller.start(soundId: 'deep-drift', volume: 0.16);
      await driver.started.future;
      switch (action) {
        case 'pause':
          await controller.pauseForSession();
        case 'stop':
          await controller.stop();
        case 'mute':
          await controller.toggleEnabled();
        case 'dispose':
          controller.dispose();
      }
      driver.ready.complete();
      await playing;
      expect(driver.volumes.where((volume) => volume > 0), isEmpty);
      if (action != 'dispose') {
        expect(controller.state.isPlaying, isFalse);
        controller.dispose();
      }
      if (action == 'stop') expect(driver.stops, greaterThan(0));
      if (action == 'pause' || action == 'mute') {
        expect(driver.pauses, greaterThan(0));
      }
    });
  }
}
