import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/providers.dart';

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

  Future<void> speak(String text);

  Future<void> setVolume(double volume);

  Future<void> stop();

  Future<void> dispose();
}

class FlutterMeditationVoiceDriver implements MeditationVoiceDriver {
  final FlutterTts _tts = FlutterTts();

  bool _configured = false;

  @override
  Future<void> configure({required double volume}) async {
    if (!_configured) {
      await _tts.setLanguage('en-GB');
      await _tts.setSpeechRate(0.42);
      await _tts.setPitch(0.94);
      await _tts.awaitSpeakCompletion(false);

      if (!kIsWeb && defaultTargetPlatform == TargetPlatform.iOS) {
        await _tts.setSharedInstance(true);
        await _tts.setIosAudioCategory(
          IosTextToSpeechAudioCategory.ambient,
          [
            IosTextToSpeechAudioCategoryOptions.allowBluetooth,
            IosTextToSpeechAudioCategoryOptions.allowBluetoothA2DP,
            IosTextToSpeechAudioCategoryOptions.mixWithOthers,
          ],
          IosTextToSpeechAudioMode.voicePrompt,
        );
      }

      _configured = true;
    }

    await _tts.setVolume(volume.clamp(0.0, 1.0).toDouble());
  }

  @override
  Future<void> speak(String text) async {
    if (text.trim().isEmpty) return;
    await _tts.stop();
    await _tts.speak(text, focus: false);
  }

  @override
  Future<void> setVolume(double volume) async {
    await _tts.setVolume(volume.clamp(0.0, 1.0).toDouble());
  }

  @override
  Future<void> stop() async {
    await _tts.stop();
  }

  @override
  Future<void> dispose() async {
    await _tts.stop();
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

  Future<void> speakGuidance(String guidance) async {
    if (!state.enabled || guidance.trim().isEmpty) return;

    try {
      if (!_configured) {
        await _driver.configure(volume: state.volume);
        _configured = true;
      }
      await _driver.speak(guidance);
    } catch (_) {
      // Voice guidance is additive. Platform TTS failure must never break
      // meditation timing, ambience, navigation, or completion.
    }
  }

  Future<void> stop() async {
    try {
      await _driver.stop();
    } catch (_) {
      // Keep the meditation usable if the platform voice engine fails.
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
      // Persist the user's preference even if this device cannot update TTS.
    }
  }
}
