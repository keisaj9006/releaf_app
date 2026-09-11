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
    this.mix = 0.72,
  });

  final bool enabled;
  final bool isPlaying;
  final String? trackId;
  final String? trackTitle;
  final double mix;

  MeditationAudioState copyWith({
    bool? enabled,
    bool? isPlaying,
    String? trackId,
    String? trackTitle,
    double? mix,
    bool clearTrack = false,
  }) {
    return MeditationAudioState(
      enabled: enabled ?? this.enabled,
      isPlaying: isPlaying ?? this.isPlaying,
      trackId: clearTrack ? null : (trackId ?? this.trackId),
      trackTitle: clearTrack ? null : (trackTitle ?? this.trackTitle),
      mix: mix ?? this.mix,
    );
  }
}

abstract class MeditationAudioDriver {
  Future<void> playAsset(String assetPath, {required double volume});

  Future<void> pause();

  Future<void> resume();

  Future<void> setVolume(double volume);

  Future<void> stop();

  Future<void> dispose();
}

class AudioplayersMeditationAudioDriver implements MeditationAudioDriver {
  AudioplayersMeditationAudioDriver({audio.AudioPlayer? player})
    : _player = player ?? audio.AudioPlayer();
  final audio.AudioPlayer _player;
  Future<void> _pending = Future<void>.value();
  int _request = 0;
  bool _disposed = false;
  bool _sourceReady = false;

  Future<void> _enqueue(Future<void> Function() action) {
    final result = _pending.then((_) => action());
    _pending = result.then<void>((_) {}, onError: (Object _, StackTrace _) {});
    return result;
  }

  @override
  Future<void> playAsset(String assetPath, {required double volume}) async {
    if (_disposed) return;
    _sourceReady = false;
    final request = ++_request;
    bool current() => !_disposed && request == _request;
    await _enqueue(() async {
      if (!current()) return;
      await _player.stop();
      if (!current()) return;
      await _player.setReleaseMode(audio.ReleaseMode.loop);
      if (!current()) return;
      await _player.setVolume(volume.clamp(0.0, 1.0).toDouble());
      if (!current()) return;
      await _player.setSource(audio.AssetSource(assetPath));
      if (!current()) return;
      _sourceReady = true;
      await _player.resume();
    });
  }

  @override
  Future<void> pause() async {
    _request++;
    if (!_disposed) await _enqueue(_player.pause);
  }

  @override
  Future<void> resume() async {
    if (_disposed || !_sourceReady) return;
    final request = ++_request;
    await _enqueue(() async {
      if (!_disposed && request == _request) await _player.resume();
    });
  }

  @override
  Future<void> setVolume(double volume) async {
    if (_disposed) return;
    await _enqueue(() async {
      if (!_disposed) {
        await _player.setVolume(volume.clamp(0.0, 1.0).toDouble());
      }
    });
  }

  @override
  Future<void> stop() async {
    _sourceReady = false;
    _request++;
    if (!_disposed) await _enqueue(_player.stop);
  }

  @override
  Future<void> dispose() async {
    if (_disposed) return _pending;
    _disposed = true;
    _sourceReady = false;
    _request++;
    await _enqueue(_player.dispose);
  }
}

final meditationAudioDriverProvider =
    Provider.autoDispose<MeditationAudioDriver>((ref) {
      final driver = AudioplayersMeditationAudioDriver();
      ref.onDispose(() {
        unawaited(driver.dispose());
      });
      return driver;
    });

final meditationAudioControllerProvider =
    StateNotifierProvider.autoDispose<
      MeditationAudioController,
      MeditationAudioState
    >((ref) {
      return MeditationAudioController(
        ref.watch(soundCatalogProvider),
        ref.watch(sharedPreferencesProvider),
        ref.watch(meditationAudioDriverProvider),
      );
    });

class MeditationAudioController extends StateNotifier<MeditationAudioState> {
  MeditationAudioController(this._catalog, this._prefs, this._driver)
    : super(
        MeditationAudioState(
          enabled: _prefs.getBool(_enabledKey) ?? true,
          mix: (_prefs.getDouble(_mixKey) ?? 0.72).clamp(0.0, 1.0).toDouble(),
        ),
      );

  static const _enabledKey = 'meditation.ambient_sound_enabled';
  static const _mixKey = 'meditation.ambient_sound_mix';

  final SoundCatalog _catalog;
  final SharedPreferences _prefs;
  final MeditationAudioDriver _driver;

  bool _sessionRunning = false;
  bool _hasStarted = false;
  String? _assetPath;
  double _sessionVolume = 0.20;
  double _driverVolume = 0;
  int _playbackRequest = 0;
  int _fadeRequest = 0;

  bool _current(int request) => mounted && request == _playbackRequest;

  @override
  void dispose() {
    _playbackRequest++;
    _fadeRequest++;
    super.dispose();
  }

  double get _effectiveVolume =>
      (_sessionVolume * state.mix).clamp(0.0, 1.0).toDouble();

  Future<void> start({
    required String? soundId,
    required double volume,
    bool playImmediately = true,
  }) async {
    final request = ++_playbackRequest;
    _fadeRequest++;
    _sessionRunning = playImmediately;
    _sessionVolume = volume.clamp(0.0, 1.0).toDouble();

    final track = soundId == null ? null : _catalog.getById(soundId);
    _assetPath = track?.assetPath;
    _hasStarted = false;

    state = state.copyWith(
      trackId: track?.id,
      trackTitle: track?.title,
      clearTrack: track == null,
      isPlaying: false,
    );

    try {
      await _driver.stop();
    } catch (_) {
      // Failure to stop the previous layer must not break session startup.
    }
    if (!_current(request) ||
        track == null ||
        !state.enabled ||
        !playImmediately) {
      return;
    }
    await _playFromStart();
  }

  Future<void> pauseForSession() async {
    _sessionRunning = false;
    await _pausePlayback();
  }

  Future<void> resumeForSession() async {
    final request = ++_playbackRequest;
    _fadeRequest++;
    _sessionRunning = true;
    if (!state.enabled || _assetPath == null) return;

    if (!_hasStarted) {
      await _playFromStart();
      return;
    }

    try {
      await _driver.resume();
      if (!_current(request) || !_sessionRunning || !state.enabled) return;
      state = state.copyWith(isPlaying: true);
      await _fadeTo(_effectiveVolume, const Duration(milliseconds: 180));
    } catch (_) {
      if (_current(request) && _sessionRunning && state.enabled) {
        await _playFromStart();
      }
    }
  }

  Future<void> setMix(double mix) async {
    _fadeRequest++;
    final safe = mix.clamp(0.0, 1.0).toDouble();
    state = state.copyWith(mix: safe);
    await _prefs.setDouble(_mixKey, safe);

    if (!mounted || !_hasStarted || !state.enabled || !_sessionRunning) return;

    try {
      await _driver.setVolume(_effectiveVolume);
      _driverVolume = _effectiveVolume;
    } catch (_) {
      // A failed volume change must not interrupt the meditation.
    }
  }

  Future<void> toggleEnabled() async {
    final nextEnabled = !state.enabled;
    state = state.copyWith(enabled: nextEnabled);
    final playback = !nextEnabled
        ? _pausePlayback()
        : _sessionRunning && _assetPath != null
        ? resumeForSession()
        : Future<void>.value();
    await _prefs.setBool(_enabledKey, nextEnabled);
    await playback;
  }

  Future<void> stop() async {
    final request = ++_playbackRequest;
    _fadeRequest++;
    _sessionRunning = false;

    try {
      if (_hasStarted) await _fadeTo(0, const Duration(milliseconds: 180));
      if (!_current(request)) return;
      await _driver.stop();
    } catch (_) {
      // Audio failure must never block meditation navigation.
    }
    if (!_current(request)) return;
    _hasStarted = false;
    _driverVolume = 0;
    if (!mounted) return;
    state = state.copyWith(isPlaying: false);
  }

  Future<void> _playFromStart() async {
    final request = _playbackRequest;
    final assetPath = _assetPath;
    if (assetPath == null || !state.enabled) return;

    try {
      await _driver.playAsset(assetPath, volume: 0);
      if (!_current(request) || !_sessionRunning || !state.enabled) return;
      _driverVolume = 0;
      _hasStarted = true;
      if (!mounted) return;
      state = state.copyWith(isPlaying: true);
      await _fadeTo(_effectiveVolume, const Duration(milliseconds: 220));
    } catch (_) {
      if (!_current(request)) return;
      _hasStarted = false;
      if (!mounted) return;
      state = state.copyWith(isPlaying: false);
    }
  }

  Future<void> _fadeTo(double target, Duration duration) async {
    final request = ++_fadeRequest;
    if (!_hasStarted) return;

    final safeTarget = target.clamp(0.0, 1.0).toDouble();
    final start = _driverVolume;
    const steps = 4;
    final stepDuration = Duration(
      milliseconds: duration.inMilliseconds ~/ steps,
    );

    for (var step = 1; step <= steps; step++) {
      if (!mounted || request != _fadeRequest) return;
      final fraction = step / steps;
      final value = start + ((safeTarget - start) * fraction);
      try {
        await _driver.setVolume(value);
        if (!mounted || request != _fadeRequest) return;
        _driverVolume = value;
      } catch (_) {
        return;
      }
      if (step != steps && stepDuration.inMilliseconds > 0) {
        await Future<void>.delayed(stepDuration);
      }
    }
  }

  Future<void> _pausePlayback() async {
    final request = ++_playbackRequest;
    _fadeRequest++;

    try {
      if (_hasStarted && state.isPlaying) {
        await _fadeTo(0, const Duration(milliseconds: 140));
      }
      if (!_current(request)) return;
      await _driver.pause();
    } catch (_) {
      // Keep the session usable even if the platform audio layer fails.
    }

    if (!_current(request)) return;
    state = state.copyWith(isPlaying: false);
  }
}
