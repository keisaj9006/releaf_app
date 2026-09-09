import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:releaf_app/features/meditation/application/meditation_voice_controller.dart';
import 'package:releaf_app/features/relief/application/reset_audio_preferences.dart';
import 'package:releaf_app/features/relief/domain/models/reset_launch_options.dart';

void main() {
  test('Meditation and Reset share the locked 0.82x Releaf Guide pacing', () {
    expect(releafNarrationSpeedMultiplier, 0.82);
    expect(releafFlutterTtsSpeechRate, closeTo(0.41, 0.0001));
  });

  test('Reset Releaf Guide voice is on by default', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final preferences = await SharedPreferences.getInstance();
    final controller = ResetAudioPreferencesController(preferences);

    expect(controller.state.voiceEnabled, isTrue);
  });

  test('Reset launch options also keep voice guidance on by default', () {
    const options = ResetLaunchOptions();
    expect(options.voiceGuidanceEnabled, isTrue);
    expect(options.ambientSoundEnabled, isTrue);
  });

  test('Reset audio preferences persist across controller instances', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();

    final controller = ResetAudioPreferencesController(preferences);
    await controller.setVoiceEnabled(false);
    await controller.setVoiceVolume(0.64);
    await controller.setAmbientEnabled(true);
    await controller.setAmbientVolume(0.21);
    controller.dispose();

    final restored = ResetAudioPreferencesController(preferences);
    addTearDown(restored.dispose);

    expect(restored.state.voiceEnabled, isFalse);
    expect(restored.state.voiceVolume, closeTo(0.64, 0.001));
    expect(restored.state.ambientEnabled, isTrue);
    expect(restored.state.ambientVolume, closeTo(0.21, 0.001));
  });
}
