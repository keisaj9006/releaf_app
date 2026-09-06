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
  int _speechGeneration = 0;

  @override
  Future<void> configure({required double volume}) async {
    if (!_configured) {
      if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
        await _preferNaturalAndroidEngine();
      }

      await _tts.setLanguage('en-GB');
      await _preferNaturalBritishVoice();

      // Guided meditation should be substantially slower than conversational
      // speech. The quiet left after each instruction is intentional.
      await _tts.setSpeechRate(0.31);
      await _tts.setPitch(0.90);
      await _tts.awaitSpeakCompletion(true);

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

  Future<void> _preferNaturalAndroidEngine() async {
    try {
      final engines = await _tts.getEngines;
      if (engines is! List) return;

      final names = engines.map((engine) => engine.toString()).toList();
      if (names.contains('com.google.android.tts')) {
        await _tts.setEngine('com.google.android.tts');
      }
    } catch (_) {
      // Keep the current system engine when Google TTS is unavailable.
    }
  }

  Future<void> _preferNaturalBritishVoice() async {
    try {
      final voices = await _tts.getVoices;
      if (voices is! List) return;

      Map<dynamic, dynamic>? best;
      var bestScore = -1;

      for (final candidate in voices) {
        if (candidate is! Map) continue;

        final locale = (candidate['locale'] ?? '').toString();
        if (locale.toLowerCase().replaceAll('_', '-') != 'en-gb') {
          continue;
        }

        final name = (candidate['name'] ?? '').toString();
        final normalized = name.toLowerCase();
        var score = 0;

        if (normalized.contains('neural')) score += 8;
        if (normalized.contains('premium')) score += 7;
        if (normalized.contains('enhanced')) score += 6;
        if (normalized.contains('network')) score += 5;
        if (normalized.contains('wavenet')) score += 5;
        if (normalized.contains('legacy')) score -= 4;

        if (score > bestScore) {
          best = candidate;
          bestScore = score;
        }
      }

      if (best == null) return;

      final name = (best['name'] ?? '').toString();
      final locale = (best['locale'] ?? '').toString();
      if (name.isEmpty || locale.isEmpty) return;

      await _tts.setVoice({'name': name, 'locale': locale});
    } catch (_) {
      // Voice inventories vary across devices. Fall back rather than making
      // the meditation voice unavailable.
    }
  }

  List<String> _meditationSentences(String text) {
    final matches = RegExp(r'[^.!?]+[.!?]+|[^.!?]+$').allMatches(text);
    return matches
        .map((match) => match.group(0)?.trim() ?? '')
        .where((sentence) => sentence.isNotEmpty)
        .toList(growable: false);
  }

  Duration _pauseAfter(String sentence) {
    if (sentence.endsWith('?') || sentence.endsWith('!')) {
      return const Duration(milliseconds: 800);
    }
    return const Duration(milliseconds: 620);
  }

  @override
  Future<void> speak(String text) async {
    if (text.trim().isEmpty) return;

    final generation = ++_speechGeneration;
    await _tts.stop();
    final sentences = _meditationSentences(text);

    for (var index = 0; index < sentences.length; index++) {
      if (generation != _speechGeneration) return;

      await _tts.speak(sentences[index], focus: false);
      if (generation != _speechGeneration) return;

      if (index < sentences.length - 1) {
        await Future<void>.delayed(_pauseAfter(sentences[index]));
      }
    }
  }

  @override
  Future<void> setVolume(double volume) async {
    await _tts.setVolume(volume.clamp(0.0, 1.0).toDouble());
  }

  @override
  Future<void> stop() async {
    _speechGeneration += 1;
    await _tts.stop();
  }

  @override
  Future<void> dispose() async {
    _speechGeneration += 1;
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
