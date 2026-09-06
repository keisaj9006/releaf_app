import 'dart:async';

import 'package:audioplayers/audioplayers.dart' as audio;
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

  Future<void> playAsset(String assetPath);

  Future<void> setVolume(double volume);

  Future<void> stop();

  Future<void> dispose();
}

class FlutterMeditationVoiceDriver implements MeditationVoiceDriver {
  final FlutterTts _tts = FlutterTts();
  final audio.AudioPlayer _recordedVoice = audio.AudioPlayer();

  bool _configured = false;
  int _speechGeneration = 0;

  @override
  Future<void> configure({required double volume}) async {
    if (!_configured) {
      if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
        await _preferNaturalAndroidEngine();
      }

      await _tts.setLanguage('en-GB');
      await _preferCalmFemaleVoice();

      // Guided meditation should be substantially slower than conversational
      // speech. The quiet left after each instruction is intentional.
      await _tts.setSpeechRate(0.27);
      await _tts.setPitch(0.93);
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

    final safeVolume = volume.clamp(0.0, 1.0).toDouble();
    await _tts.setVolume(safeVolume);
    await _recordedVoice.setVolume(safeVolume);
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

  Future<void> _preferCalmFemaleVoice() async {
    try {
      final voices = await _tts.getVoices;
      if (voices is! List) return;

      final candidates = voices.whereType<Map>().toList(growable: false);
      if (candidates.isEmpty) return;

      Map<dynamic, dynamic>? best;
      var bestScore = -100000;

      for (final candidate in candidates) {
        final locale = (candidate['locale'] ?? '').toString();
        final normalizedLocale =
            locale.toLowerCase().replaceAll('_', '-');
        if (!normalizedLocale.startsWith('en-')) continue;

        final name = (candidate['name'] ?? '').toString();
        if (name.isEmpty || locale.isEmpty) continue;

        final normalizedName = name.toLowerCase();
        final features = (candidate['features'] ?? '').toString().toLowerCase();
        final networkRequired =
            (candidate['network_required'] ?? '').toString().toLowerCase();
        final quality = int.tryParse((candidate['quality'] ?? '').toString());

        var score = 0;

        // Gender is the highest-priority requirement. Google Android voices
        // often encode this directly in the voice name.
        if (normalizedName.contains('#female_') ||
            normalizedName.contains('female')) {
          score += 5000;
        }
        if (normalizedName.contains('#male_') ||
            normalizedName.contains('male')) {
          score -= 10000;
        }

        // Prefer British English, but a clearly identified female English
        // voice is better than a male British fallback.
        if (normalizedLocale == 'en-gb') {
          score += 1200;
        } else if (normalizedLocale == 'en-au') {
          score += 700;
        } else if (normalizedLocale == 'en-us') {
          score += 500;
        }

        // Google's FIS British family is historically female. Prefer it when
        // gender metadata is not exposed by the engine.
        if (normalizedLocale == 'en-gb' &&
            normalizedName.contains('x-fis')) {
          score += 2600;
        }

        // Prefer higher-quality / network voices when available.
        if (normalizedName.contains('neural')) score += 900;
        if (normalizedName.contains('premium')) score += 800;
        if (normalizedName.contains('enhanced')) score += 700;
        if (normalizedName.contains('wavenet')) score += 650;
        if (normalizedName.contains('network') ||
            networkRequired == 'true' ||
            features.contains('network')) {
          score += 450;
        }
        if (quality != null) score += quality * 20;
        if (normalizedName.contains('legacy')) score -= 900;

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
      // Voice inventories differ between devices. Keep meditation usable if
      // the preferred female voice cannot be selected on this phone.
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
      return const Duration(milliseconds: 1200);
    }
    return const Duration(milliseconds: 900);
  }

  @override
  Future<void> speak(String text) async {
    if (text.trim().isEmpty) return;

    final generation = ++_speechGeneration;
    await _recordedVoice.stop();
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
  Future<void> playAsset(String assetPath) async {
    if (assetPath.trim().isEmpty) return;

    _speechGeneration += 1;
    await _tts.stop();
    await _recordedVoice.stop();
    await _recordedVoice.setReleaseMode(audio.ReleaseMode.stop);
    await _recordedVoice.play(audio.AssetSource(assetPath));
  }

  @override
  Future<void> setVolume(double volume) async {
    final safeVolume = volume.clamp(0.0, 1.0).toDouble();
    await _tts.setVolume(safeVolume);
    await _recordedVoice.setVolume(safeVolume);
  }

  @override
  Future<void> stop() async {
    _speechGeneration += 1;
    await Future.wait([
      _tts.stop(),
      _recordedVoice.stop(),
    ]);
  }

  @override
  Future<void> dispose() async {
    _speechGeneration += 1;
    await _tts.stop();
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

    try {
      if (!_configured) {
        await _driver.configure(volume: state.volume);
        _configured = true;
      }

      if (narrationAssetPath != null &&
          narrationAssetPath.trim().isNotEmpty) {
        try {
          await _driver.playAsset(narrationAssetPath);
          return;
        } catch (_) {
          // A missing/corrupt recorded track should fall back to TTS rather
          // than breaking the meditation.
        }
      }

      await _driver.speak(guidance);
    } catch (_) {
      // Voice guidance is additive. Audio failure must never break
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
