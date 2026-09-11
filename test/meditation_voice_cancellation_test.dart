import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:releaf_app/features/meditation/application/meditation_voice_controller.dart';

class _DelayedVoiceDriver implements MeditationVoiceDriver {
  final configuring = Completer<void>();
  final configured = Completer<void>();
  final List<String> played = [];
  int stops = 0;

  @override
  Future<void> configure({required double volume}) async {
    if (!configuring.isCompleted) configuring.complete();
    await configured.future;
  }

  @override
  Future<void> playAsset(String assetPath) async => played.add(assetPath);
  @override
  Future<void> stop() async {
    stops++;
  }

  @override
  Future<void> setVolume(double volume) async {}
  @override
  Future<void> dispose() async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late _DelayedVoiceDriver driver;
  late MeditationVoiceController controller;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    driver = _DelayedVoiceDriver();
    controller = MeditationVoiceController(
      await SharedPreferences.getInstance(),
      driver,
    );
  });

  Future<void> startThen(Future<void> Function() interrupt) async {
    final speaking = controller.speakGuidance(
      'Arrive.',
      narrationAssetPath: 'approved/arrive.mp3',
    );
    await driver.configuring.future;
    await interrupt();
    driver.configured.complete();
    await speaking;
  }

  test('stop cancels narration still waiting for configuration', () async {
    await startThen(controller.stop);
    expect(driver.played, isEmpty);
    expect(driver.stops, 1);
    controller.dispose();
  });

  test('muting cancels narration still waiting for configuration', () async {
    await startThen(controller.toggleEnabled);
    expect(controller.state.enabled, isFalse);
    expect(driver.played, isEmpty);
    controller.dispose();
  });

  test('disposing cancels narration still waiting for configuration', () async {
    await startThen(() async {
      controller.dispose();
    });
    expect(driver.played, isEmpty);
  });

  test('only latest guidance plays when configuration is delayed', () async {
    final first = controller.speakGuidance(
      'First.',
      narrationAssetPath: 'approved/first.mp3',
    );
    await driver.configuring.future;
    final latest = controller.speakGuidance(
      'Latest.',
      narrationAssetPath: 'approved/latest.mp3',
    );
    driver.configured.complete();
    await Future.wait([first, latest]);
    expect(driver.played, ['approved/latest.mp3']);
    controller.dispose();
  });
}
