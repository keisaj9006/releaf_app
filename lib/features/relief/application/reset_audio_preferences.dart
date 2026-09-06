import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/providers.dart';
import '../domain/models/reset_launch_options.dart';

class ResetAudioPreferences {
  const ResetAudioPreferences({
    this.voiceEnabled = true,
    this.voiceVolume = 0.78,
    this.ambientEnabled = true,
    this.ambientVolume = 0.16,
  });

  final bool voiceEnabled;
  final double voiceVolume;
  final bool ambientEnabled;
  final double ambientVolume;

  ResetLaunchOptions applyTo(ResetLaunchOptions base) {
    return base.copyWith(
      voiceGuidanceEnabled: voiceEnabled,
      voiceVolume: voiceVolume,
      ambientSoundEnabled: ambientEnabled,
      ambientVolume: ambientVolume,
    );
  }

  ResetAudioPreferences copyWith({
    bool? voiceEnabled,
    double? voiceVolume,
    bool? ambientEnabled,
    double? ambientVolume,
  }) {
    return ResetAudioPreferences(
      voiceEnabled: voiceEnabled ?? this.voiceEnabled,
      voiceVolume: (voiceVolume ?? this.voiceVolume).clamp(0.0, 1.0).toDouble(),
      ambientEnabled: ambientEnabled ?? this.ambientEnabled,
      ambientVolume:
          (ambientVolume ?? this.ambientVolume).clamp(0.0, 1.0).toDouble(),
    );
  }
}

final resetAudioPreferencesProvider = StateNotifierProvider<
    ResetAudioPreferencesController, ResetAudioPreferences>((ref) {
  return ResetAudioPreferencesController(
    ref.watch(sharedPreferencesProvider),
  );
});

class ResetAudioPreferencesController
    extends StateNotifier<ResetAudioPreferences> {
  ResetAudioPreferencesController(this._preferences)
      : super(
          ResetAudioPreferences(
            voiceEnabled: _preferences.getBool(_voiceEnabledKey) ?? true,
            voiceVolume: (_preferences.getDouble(_voiceVolumeKey) ?? 0.78)
                .clamp(0.0, 1.0)
                .toDouble(),
            ambientEnabled:
                _preferences.getBool(_ambientEnabledKey) ?? true,
            ambientVolume:
                (_preferences.getDouble(_ambientVolumeKey) ?? 0.16)
                    .clamp(0.0, 1.0)
                    .toDouble(),
          ),
        );

  static const _voiceEnabledKey = 'reset.audio.voice.enabled';
  static const _voiceVolumeKey = 'reset.audio.voice.volume';
  static const _ambientEnabledKey = 'reset.audio.ambient.enabled';
  static const _ambientVolumeKey = 'reset.audio.ambient.volume';

  final SharedPreferences _preferences;

  Future<void> setVoiceEnabled(bool enabled) async {
    state = state.copyWith(voiceEnabled: enabled);
    await _preferences.setBool(_voiceEnabledKey, enabled);
  }

  Future<void> setVoiceVolume(double volume) async {
    final safe = volume.clamp(0.0, 1.0).toDouble();
    state = state.copyWith(voiceVolume: safe);
    await _preferences.setDouble(_voiceVolumeKey, safe);
  }

  Future<void> setAmbientEnabled(bool enabled) async {
    state = state.copyWith(ambientEnabled: enabled);
    await _preferences.setBool(_ambientEnabledKey, enabled);
  }

  Future<void> setAmbientVolume(double volume) async {
    final safe = volume.clamp(0.0, 1.0).toDouble();
    state = state.copyWith(ambientVolume: safe);
    await _preferences.setDouble(_ambientVolumeKey, safe);
  }
}
