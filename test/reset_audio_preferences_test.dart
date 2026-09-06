import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:releaf_app/features/relief/application/reset_audio_preferences.dart';

void main() {
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
