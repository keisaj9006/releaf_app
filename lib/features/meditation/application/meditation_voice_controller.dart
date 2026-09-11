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
  FlutterMeditationVoiceDriver({audio.AudioPlayer? player})
    : _recordedVoice = player ?? audio.AudioPlayer();

  final audio.AudioPlayer _recordedVoice;
  Future<void> _pending = Future<void>.value();
  int _playRequest = 0;
  bool _disposed = false;

  Future<void> _enqueue(Future<void> Function() action) {
    final result = _pending.then((_) => action());
    // A failed asset must not poison later stop/dispose or playback requests.
    _pending = result.then<void>((_) {}, onError: (Object _, StackTrace _) {});
    return result;
  }

  @override
  Future<void> configure({required double volume}) async {
    await setVolume(volume);
  }

  @override
  Future<void> playAsset(String assetPath) async {
    if (_disposed || assetPath.trim().isEmpty) return;
    final request = ++_playRequest;
    bool current() => !_disposed && request == _playRequest;
    await _enqueue(() async {
      if (!current()) return;
      await _recordedVoice.stop();
      if (!current()) return;
      await _recordedVoice.setReleaseMode(audio.ReleaseMode.stop);
      if (!current()) return;
      await _recordedVoice.setSource(audio.AssetSource(assetPath));
      if (!current()) return;
      await _recordedVoice.resume();
    });
  }

  @override
  Future<void> setVolume(double volume) async {
    if (_disposed) return;
    final safeVolume = volume.clamp(0.0, 1.0).toDouble();
    await _enqueue(() async {
      if (!_disposed) await _recordedVoice.setVolume(safeVolume);
    });
  }

  @override
  Future<void> stop() async {
    _playRequest++;
    if (_disposed) return;
    await _enqueue(_recordedVoice.stop);
  }

  @override
  Future<void> dispose() async {
    if (_disposed) return _pending;
    _disposed = true;
    _playRequest++;
    await _enqueue(_recordedVoice.dispose);
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

final meditationVoiceControllerProvider =
    StateNotifierProvider.autoDispose<
      MeditationVoiceController,
      MeditationVoiceState
    >((ref) {
      return MeditationVoiceController(
        ref.watch(sharedPreferencesProvider),
        ref.watch(meditationVoiceDriverProvider),
      );
    });

class MeditationVoiceController extends StateNotifier<MeditationVoiceState> {
  MeditationVoiceController(this._preferences, this._driver)
    : super(
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
  int _guidanceRequest = 0;

  Future<void> speakGuidance(
    String guidance, {
    String? narrationAssetPath,
  }) async {
    final request = ++_guidanceRequest;
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
        if (!mounted) return;
        _configured = true;
      }

      if (!mounted || request != _guidanceRequest || !state.enabled) return;
      await _driver.playAsset(assetPath);
    } catch (_) {
      // Voice guidance is additive. Audio failure must never break
      // meditation timing, ambience, navigation, or completion.
    }
  }

  Future<void> stop() async {
    _guidanceRequest++;
    try {
      await _driver.stop();
    } catch (_) {
      // Keep the meditation usable if recorded audio cannot be stopped.
    }
  }

  @override
  void dispose() {
    _guidanceRequest++;
    super.dispose();
  }

  Future<void> toggleEnabled() async {
    final next = !state.enabled;
    state = state.copyWith(enabled: next);
    await _preferences.setBool(_enabledKey, next);

    if (!next) {
      await stop();
    }
  }

  Future<void> toggleCaptions() => setCaptions(!state.showCaptions);

  Future<void> setCaptions(bool showCaptions) async {
    state = state.copyWith(showCaptions: showCaptions);
    await _preferences.setBool(_captionsKey, showCaptions);
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
