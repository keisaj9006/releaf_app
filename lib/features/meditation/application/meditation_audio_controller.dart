import 'dart:async';

import 'package:audioplayers/audioplayers.dart' as audio;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/providers.dart';
import '../../sound/data/sound_catalog.dart';

class MeditationAudioState {
  const MeditationAudioState({
    this.enabled = true,
    this.isPlaying = false,
    this.trackId,
    this.trackTitle,
  });

  final bool enabled;
  final bool isPlaying;
  final String? trackId;
  final String? trackTitle;

  MeditationAudioState copyWith({
    bool? enabled,
    bool? isPlaying,
    String? trackId,
    String? trackTitle,
    bool clearTrack = false,
  }) {
    return MeditationAudioState(
      enabled: enabled ?? this.enabled,
      isPlaying: isPlaying ?? this.isPlaying,
      trackId: clearTrack ? null : (trackId ?? this.trackId),
      trackTitle: clearTrack ? null : (trackTitle ?? this.trackTitle),
    );
  }
}

abstract class MeditationAudioDriver {
  Future<void> playAsset(
    String assetPath, {
    required double volume,
  });

  Future<void> pause();

  Future<void> resume();

  Future<void> stop();

  Future<void> dispose();
}

class AudioplayersMeditationAudioDriver implements MeditationAudioDriver {
  final audio.AudioPlayer _player = audio.AudioPlayer();

  @override
  Future<void> playAsset(
    String assetPath, {
    required double volume,
  }) async {
    await _player.setReleaseMode(audio.ReleaseMode.loop);
    await _player.setVolume(volume);
    await _player.play(audio.AssetSource(assetPath));
  }

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> resume() => _player.resume();

  @override
  Future<void> stop() => _player.stop();

  @override
  Future<void> dispose() => _player.dispose();
}

final meditationAudioDriverProvider =
    Provider.autoDispose<MeditationAudioDriver>((ref) {
  final driver = AudioplayersMeditationAudioDriver();
  ref.onDispose(() {
    unawaited(driver.dispose());
  });
  return driver;
});

final meditationAudioControllerProvider = StateNotifierProvider.autoDispose<
    MeditationAudioController, MeditationAudioState>((ref) {
  return MeditationAudioController(
    ref.watch(soundCatalogProvider),
    ref.watch(sharedPreferencesProvider),
    ref.watch(meditationAudioDriverProvider),
  );
});

class MeditationAudioController extends StateNotifier<MeditationAudioState> {
  MeditationAudioController(
    this._catalog,
    this._prefs,
    this._driver,
  ) : super(
          MeditationAudioState(
            enabled: _prefs.getBool(_enabledKey) ?? true,
          ),
        );

  static const _enabledKey = 'meditation.ambient_sound_enabled';

  final SoundCatalog _catalog;
  final SharedPreferences _prefs;
  final MeditationAudioDriver _driver;

  bool _sessionRunning = false;
  bool _hasStarted = false;
  String? _assetPath;
  double _volume = 0.20;

  Future<void> start({
    required String? soundId,
    required double volume,
  }) async {
    _sessionRunning = true;
    _volume = volume.clamp(0.0, 1.0).toDouble();

    final track = soundId == null ? null : _catalog.getById(soundId);
    _assetPath = track?.assetPath;
    _hasStarted = false;

    state = state.copyWith(
      trackId: track?.id,
      trackTitle: track?.title,
      clearTrack: track == null,
      isPlaying: false,
    );

    if (track == null || !state.enabled) return;
    await _playFromStart();
  }

  Future<void> pauseForSession() async {
    _sessionRunning = false;
    await _pausePlayback();
  }

  Future<void> resumeForSession() async {
    _sessionRunning = true;
    if (!state.enabled || _assetPath == null) return;

    if (!_hasStarted) {
      await _playFromStart();
      return;
    }

    try {
      await _driver.resume();
      if (!mounted) return;
      state = state.copyWith(isPlaying: true);
    } catch (_) {
      await _playFromStart();
    }
  }

  Future<void> toggleEnabled() async {
    final nextEnabled = !state.enabled;
    state = state.copyWith(enabled: nextEnabled);
    await _prefs.setBool(_enabledKey, nextEnabled);

    if (!nextEnabled) {
      await _pausePlayback();
      return;
    }

    if (_sessionRunning && _assetPath != null) {
      await resumeForSession();
    }
  }

  Future<void> stop() async {
    _sessionRunning = false;

    if (_hasStarted) {
      try {
        await _driver.stop();
      } catch (_) {
        // Audio failure must never block meditation navigation.
      }
    }

    _hasStarted = false;
    if (!mounted) return;
    state = state.copyWith(isPlaying: false);
  }

  Future<void> _playFromStart() async {
    final assetPath = _assetPath;
    if (assetPath == null || !state.enabled) return;

    try {
      await _driver.playAsset(assetPath, volume: _volume);
      _hasStarted = true;
      if (!mounted) return;
      state = state.copyWith(isPlaying: true);
    } catch (_) {
      _hasStarted = false;
      if (!mounted) return;
      state = state.copyWith(isPlaying: false);
    }
  }

  Future<void> _pausePlayback() async {
    if (!_hasStarted || !state.isPlaying) return;

    try {
      await _driver.pause();
    } catch (_) {
      // Keep the session usable even if the platform audio layer fails.
    }

    if (!mounted) return;
    state = state.copyWith(isPlaying: false);
  }
}
