import 'dart:async';

import 'package:audioplayers/audioplayers.dart' as audio;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/audio/releaf_guide_contract.dart';
import '../../../core/providers.dart';

const double releafNarrationSpeedMultiplier =
    releafGuideNarrationSpeedMultiplier;

class MeditationVoiceState {
  const MeditationVoiceState({
    this.enabled = true,
    this.showCaptions = false,
    this.volume = 0.92,
  });

  final bool enabled;
  final bool showCaptions;
  final double volume;

  MeditationVoiceState copyWith({
    bool? enabled,
    bool? showCaptions,
    double? volume,
  }) {
    return MeditationVoiceState(
      enabled: enabled ?? this.enabled,
      showCaptions: showCaptions ?? this.showCaptions,
      volume: volume ?? this.volume,
    );
  }
}

abstract class MeditationVoiceDriver {
  Future<void> configure({required double volume});

  Future<void> playAsset(String assetPath);

  Future<void> setVolume(double volume);

  Future<void> stop();

  Future<void> dispose();
}

class FlutterMeditationVoiceDriver implements MeditationVoiceDriver {
  final audio.AudioPlayer _recordedVoice = audio.AudioPlayer();

  @override
  Future<void> configure({required double volume}) async {
    final safeVolume = volume.clamp(0.0, 1.0).toDouble();
    await _recordedVoice.setVolume(safeVolume);
  }

  @override
  Future<void> playAsset(String assetPath) async {
    if (assetPath.trim().isEmpty) return;

    await _recordedVoice.stop();
    await _recordedVoice.setReleaseMode(audio.ReleaseMode.stop);
    await _recordedVoice.play(audio.AssetSource(assetPath));
  }

  @override
  Future<void> setVolume(double volume) async {
    final safeVolume = volume.clamp(0.0, 1.0).toDouble();
    await _recordedVoice.setVolume(safeVolume);
  }

  @override
  Future<void> stop() async {
    await _recordedVoice.stop();
  }

  @override
  Future<void> dispose() async {
    await _recordedVoice.dispose();
  }
}

final meditationVoiceDriverProvider =
    Provider.autoDispose<MeditationVoiceDriver>((ref) {
  final driver = FlutterMeditationVoiceDriver();
  ref.onDispose(() {
    unawaited(driver.dispose());
  });
  return driver;
});

final meditationVoiceControllerProvider = StateNotifierProvider.autoDispose<
    MeditationVoiceController, MeditationVoiceState>((ref) {
  return MeditationVoiceController(
    ref.watch(sharedPreferencesProvider),
    ref.watch(meditationVoiceDriverProvider),
  );
});

class MeditationVoiceController extends StateNotifier<MeditationVoiceState> {
  MeditationVoiceController(
    this._preferences,
    this._driver,
  ) : super(
          MeditationVoiceState(
            enabled: _preferences.getBool(_enabledKey) ?? true,
            showCaptions: _preferences.getBool(_captionsKey) ?? false,
            volume: (_preferences.getDouble(_volumeKey) ?? 0.92)
                .clamp(0.0, 1.0)
                .toDouble(),
          ),
        );

  static const _enabledKey = 'meditation.voice.enabled';
  static const _captionsKey = 'meditation.voice.captions';
  static const _volumeKey = 'meditation.voice.volume';

  final SharedPreferences _preferences;
  final MeditationVoiceDriver _driver;

  bool _configured = false;

  Future<void> speakGuidance(
    String guidance, {
    String? narrationAssetPath,
  }) async {
    if (!state.enabled || guidance.trim().isEmpty) return;

    final assetPath = narrationAssetPath?.trim();
    if (assetPath == null || assetPath.isEmpty) {
      // Releaf never substitutes a device/system voice. Until an approved
      // Releaf Guide recording exists, the session remains silent and can
      // continue to use its on-screen guidance.
      return;
    }

    try {
      if (!_configured) {
        await _driver.configure(volume: state.volume);
        _configured = true;
      }

      await _driver.playAsset(assetPath);
    } catch (_) {
      // Voice guidance is additive. Audio failure must never break
      // meditation timing, ambience, navigation, or completion.
    }
  }

  Future<void> stop() async {
    try {
      await _driver.stop();
    } catch (_) {
      // Keep the meditation usable if recorded audio cannot be stopped.
    }
  }

  Future<void> toggleEnabled() async {
    final next = !state.enabled;
    state = state.copyWith(enabled: next);
    await _preferences.setBool(_enabledKey, next);

    if (!next) {
      await stop();
    }
  }

  Future<void> toggleCaptions() async {
    final next = !state.showCaptions;
    state = state.copyWith(showCaptions: next);
    await _preferences.setBool(_captionsKey, next);
  }

  Future<void> setVolume(double volume) async {
    final safe = volume.clamp(0.0, 1.0).toDouble();
    state = state.copyWith(volume: safe);
    await _preferences.setDouble(_volumeKey, safe);

    if (!_configured) return;

    try {
      await _driver.setVolume(safe);
    } catch (_) {
      // Persist the user's preference even if audio volume cannot be updated.
    }
  }
}
