import 'dart:async';

import 'package:audioplayers/audioplayers.dart' as audio;
import 'package:audio_session/audio_session.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/providers.dart';
import '../../../core/audio/releaf_audio_session.dart';
import '../data/sound_catalog.dart';
import '../domain/sound_content.dart';

const int soundSleepTimerFadeSeconds = 20;
const double defaultSoundVolume = 0.62;

double soundOutputVolumeForSleepTimer({
  required double baseVolume,
  int? remainingSeconds,
}) {
  final safeBase = baseVolume.clamp(0.0, 1.0).toDouble();
  if (remainingSeconds == null ||
      remainingSeconds > soundSleepTimerFadeSeconds) {
    return safeBase;
  }

  final safeRemaining = remainingSeconds
      .clamp(0, soundSleepTimerFadeSeconds)
      .toInt();
  final factor = safeRemaining / soundSleepTimerFadeSeconds;
  return (safeBase * factor).clamp(0.0, 1.0).toDouble();
}

abstract class SoundPlaybackDriver {
  Stream<Duration> get onDurationChanged;
  Stream<Duration> get onPositionChanged;
  Stream<audio.PlayerState> get onPlayerStateChanged;

  Future<void> setReleaseMode(audio.ReleaseMode mode);
  Future<void> setVolume(double volume);
  Future<void> playAsset(String assetPath, {String? trackId, String? title});
  Future<void> resume();
  Future<void> pause();
  Future<void> stop();
  Future<void> seek(Duration position);
  Future<void> dispose();
}

/// Native transport actions can arrive directly from media notifications.
/// Their version lets a pending controller start observe that cancellation.
abstract interface class SoundPlaybackIntentTracker {
  int get playbackIntentVersion;
}

class AudioplayersSoundPlaybackDriver
    implements SoundPlaybackDriver, SoundPlaybackIntentTracker {
  AudioplayersSoundPlaybackDriver({audio.AudioPlayer? player})
    : _player = player ?? audio.AudioPlayer();

  final audio.AudioPlayer _player;
  Future<void> _pending = Future<void>.value();
  int _playRequest = 0;
  bool _disposed = false;
  bool _sourceReady = false;

  @override
  int get playbackIntentVersion => _playRequest;

  Future<void> _enqueue(Future<void> Function() action) {
    final result = _pending.then((_) => action());
    _pending = result.then<void>((_) {}, onError: (Object _, StackTrace _) {});
    return result;
  }

  bool _current(int request) => !_disposed && request == _playRequest;

  @override
  Stream<Duration> get onDurationChanged => _player.onDurationChanged;

  @override
  Stream<Duration> get onPositionChanged => _player.onPositionChanged;

  @override
  Stream<audio.PlayerState> get onPlayerStateChanged =>
      _player.onPlayerStateChanged;

  @override
  Future<void> setReleaseMode(audio.ReleaseMode mode) => _enqueue(() async {
    if (!_disposed) await _player.setReleaseMode(mode);
  });

  @override
  Future<void> setVolume(double volume) => _enqueue(() async {
    if (!_disposed) await _player.setVolume(volume);
  });

  @override
  Future<void> playAsset(
    String assetPath, {
    String? trackId,
    String? title,
  }) async {
    if (_disposed || assetPath.trim().isEmpty) return;
    final request = ++_playRequest;
    _sourceReady = false;
    await _enqueue(() async {
      if (!_current(request)) return;
      await _player.stop();
      if (!_current(request)) return;
      await _player.setSource(audio.AssetSource(assetPath));
      if (!_current(request)) return;
      _sourceReady = true;
      await _player.resume();
    });
  }

  @override
  Future<void> resume() async {
    if (_disposed || !_sourceReady) return;
    final request = ++_playRequest;
    await _enqueue(() async {
      if (_current(request) && _sourceReady) await _player.resume();
    });
  }

  @override
  Future<void> pause() async {
    final request = ++_playRequest;
    await _enqueue(() async {
      if (_current(request)) await _player.pause();
    });
  }

  @override
  Future<void> stop() async {
    final request = ++_playRequest;
    await _enqueue(() async {
      if (_current(request)) await _player.stop();
    });
  }

  @override
  Future<void> seek(Duration position) async {
    final request = _playRequest;
    await _enqueue(() async {
      if (_current(request) && _sourceReady) await _player.seek(position);
    });
  }

  @override
  Future<void> dispose() async {
    if (_disposed) return _pending;
    _disposed = true;
    _sourceReady = false;
    _playRequest++;
    await _enqueue(_player.dispose);
  }
}

class SoundPlayerState {
  const SoundPlayerState({
    this.currentTrackId,
    this.isPlaying = false,
    this.isLoading = false,
    this.hasPlaybackError = false,
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.volume = defaultSoundVolume,
    this.favoriteIds = const <String>{},
    this.recentIds = const <String>[],
    this.sleepTimerMinutes,
    this.sleepTimerRemainingSeconds,
  });

  final String? currentTrackId;
  final bool isPlaying;
  final bool isLoading;
  final bool hasPlaybackError;
  final Duration position;
  final Duration duration;
  final double volume;
  final Set<String> favoriteIds;
  final List<String> recentIds;
  final int? sleepTimerMinutes;
  final int? sleepTimerRemainingSeconds;

  bool get isSleepTimerFading {
    final remaining = sleepTimerRemainingSeconds;
    return remaining != null &&
        remaining > 0 &&
        remaining <= soundSleepTimerFadeSeconds;
  }

  SoundPlayerState copyWith({
    String? currentTrackId,
    bool clearCurrentTrack = false,
    bool? isPlaying,
    bool? isLoading,
    bool? hasPlaybackError,
    Duration? position,
    Duration? duration,
    double? volume,
    Set<String>? favoriteIds,
    List<String>? recentIds,
    int? sleepTimerMinutes,
    int? sleepTimerRemainingSeconds,
    bool clearSleepTimer = false,
  }) {
    return SoundPlayerState(
      currentTrackId: clearCurrentTrack
          ? null
          : (currentTrackId ?? this.currentTrackId),
      isPlaying: isPlaying ?? this.isPlaying,
      isLoading: isLoading ?? this.isLoading,
      hasPlaybackError: hasPlaybackError ?? this.hasPlaybackError,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      volume: volume ?? this.volume,
      favoriteIds: favoriteIds ?? this.favoriteIds,
      recentIds: recentIds ?? this.recentIds,
      sleepTimerMinutes: clearSleepTimer
          ? null
          : (sleepTimerMinutes ?? this.sleepTimerMinutes),
      sleepTimerRemainingSeconds: clearSleepTimer
          ? null
          : (sleepTimerRemainingSeconds ?? this.sleepTimerRemainingSeconds),
    );
  }
}

final soundPlaybackDriverProvider = Provider<SoundPlaybackDriver?>((ref) {
  return null;
});

final soundPlayerControllerProvider =
    StateNotifierProvider<SoundPlayerController, SoundPlayerState>((ref) {
      return SoundPlayerController(
        ref.watch(soundCatalogProvider),
        ref.watch(sharedPreferencesProvider),
        driver: ref.watch(soundPlaybackDriverProvider),
      );
    });

class SoundPlayerController extends StateNotifier<SoundPlayerState> {
  SoundPlayerController(
    this._catalog,
    this._prefs, {
    SoundPlaybackDriver? driver,
    DateTime Function()? now,
  }) : _driver = driver ?? AudioplayersSoundPlaybackDriver(),
       _now = now ?? DateTime.now,
       super(
         SoundPlayerState(
           volume: (_prefs.getDouble(_volumeKey) ?? defaultSoundVolume)
               .clamp(0.0, 1.0)
               .toDouble(),
           favoriteIds:
               (_prefs.getStringList(_favoritesKey) ?? const <String>[])
                   .toSet(),
           recentIds: _prefs.getStringList(_recentsKey) ?? const <String>[],
         ),
       ) {
    _durationSubscription = _driver.onDurationChanged.listen((duration) {
      if (!mounted) return;
      state = state.copyWith(duration: duration);
    });
    _positionSubscription = _driver.onPositionChanged.listen((position) {
      if (!mounted) return;
      state = state.copyWith(position: position);
    });
    _playerStateSubscription = _driver.onPlayerStateChanged.listen((
      playerState,
    ) {
      if (!mounted) return;
      state = state.copyWith(
        isPlaying: playerState == audio.PlayerState.playing,
      );
    });
  }

  static const _favoritesKey = 'sound.favorite_ids';
  static const _recentsKey = 'sound.recent_ids';
  static const _volumeKey = 'sound.volume.v1';

  final SoundCatalog _catalog;
  final SharedPreferences _prefs;
  final SoundPlaybackDriver _driver;
  final DateTime Function() _now;

  StreamSubscription<Duration>? _durationSubscription;
  StreamSubscription<Duration>? _positionSubscription;
  StreamSubscription<audio.PlayerState>? _playerStateSubscription;
  Timer? _sleepTimer;
  DateTime? _sleepTimerDeadline;
  int _sleepTimerRequest = 0;
  int _playbackRequest = 0;
  int? _startingRequest;
  String? _readyTrackId;
  int _outputVolumeRequest = 0;
  double _desiredOutputVolume = defaultSoundVolume;
  int? _interruptedPlaybackRequest;
  int? _interruptedDriverIntent;
  Future<void>? _interruptionPause;

  Future<void> handleAudioInterruption(AudioInterruptionEvent event) async {
    if (!mounted) return;
    if (event.begin) {
      if (!releafShouldPauseForInterruption(
        ReleafAudioMode.sound,
        event.type,
      )) {
        return;
      }
      final canAutoResume = releafShouldAutoResumeAfterInterruption(
        ReleafAudioMode.sound,
        event.type,
      );
      if (!canAutoResume) _interruptedPlaybackRequest = null;
      if (state.isPlaying || state.isLoading) {
        final pausing = pause();
        _interruptionPause = pausing;
        _interruptedPlaybackRequest = canAutoResume ? _playbackRequest : null;
        _interruptedDriverIntent = _driverPlaybackIntent;
        await pausing;
      }
      return;
    }
    if (!releafShouldAutoResumeAfterInterruption(
      ReleafAudioMode.sound,
      event.type,
    )) {
      _interruptedPlaybackRequest = null;
      return;
    }
    final request = _interruptedPlaybackRequest;
    final driverIntent = _interruptedDriverIntent;
    if (request == null) return;
    // A short interruption can end before native pause has reported its state.
    // Wait for it, then recheck cancellation before requesting any resume.
    await _interruptionPause;
    if (!mounted || _interruptedPlaybackRequest != request) return;
    final shouldResume =
        request == _playbackRequest && driverIntent == _driverPlaybackIntent;
    _interruptedPlaybackRequest = null;
    if (shouldResume) await resume();
  }

  Future<void> handleBecomingNoisy() async {
    _interruptedPlaybackRequest = null;
    await pause();
  }

  bool _currentPlaybackRequest(int request) =>
      mounted && request == _playbackRequest;

  int? get _driverPlaybackIntent => switch (_driver) {
    SoundPlaybackIntentTracker driver => driver.playbackIntentVersion,
    _ => null,
  };

  bool _currentSleepTimerRequest(int request) =>
      mounted && request == _sleepTimerRequest;

  Future<void> _writeOutputVolume(double volume) async {
    if (!mounted) return;
    var request = ++_outputVolumeRequest;
    var output = _desiredOutputVolume = volume.clamp(0.0, 1.0).toDouble();
    while (mounted) {
      await _driver.setVolume(output);
      if (!mounted || request == _outputVolumeRequest) return;
      // Repair a stale native write without making it a new user/timer choice.
      request = _outputVolumeRequest;
      output = _desiredOutputVolume;
    }
  }

  Future<void> play(SoundContent track) async {
    if (!mounted) return;
    final request = ++_playbackRequest;
    var driverIntent = _driverPlaybackIntent;
    bool current() =>
        _currentPlaybackRequest(request) &&
        driverIntent == _driverPlaybackIntent;
    _startingRequest = request;
    final canResume = _readyTrackId == track.id;
    state = state.copyWith(
      currentTrackId: track.id,
      isLoading: true,
      hasPlaybackError: false,
      isPlaying: canResume && state.isPlaying,
      position: canResume ? state.position : Duration.zero,
      duration: canResume ? state.duration : Duration.zero,
    );
    try {
      if (!canResume) {
        _readyTrackId = null;
        // Invalidate a pending native load before waiting on configuration.
        final stopping = _driver.stop();
        driverIntent = _driverPlaybackIntent;
        await stopping;
        if (!current()) return;
      }
      await _driver.setReleaseMode(audio.ReleaseMode.loop);
      if (!current()) return;
      await _writeOutputVolume(
        soundOutputVolumeForSleepTimer(
          baseVolume: state.volume,
          remainingSeconds: state.sleepTimerRemainingSeconds,
        ),
      );
      if (!current()) return;

      if (canResume) {
        final resuming = _driver.resume();
        driverIntent = _driverPlaybackIntent;
        await resuming;
      } else {
        final playing = _driver.playAsset(
          track.assetPath,
          trackId: track.id,
          title: track.title,
        );
        driverIntent = _driverPlaybackIntent;
        await playing;
        if (!current()) return;
        _readyTrackId = track.id;
        await _markRecent(track.id);
      }
    } catch (_) {
      if (current()) {
        _readyTrackId = null;
        state = state.copyWith(isPlaying: false, hasPlaybackError: true);
      }
    } finally {
      if (_startingRequest == request) {
        _startingRequest = null;
        if (mounted) state = state.copyWith(isLoading: false);
      }
    }
  }

  Future<void> playById(String id) async {
    final track = _catalog.getById(id);
    if (track == null) return;
    await play(track);
  }

  Future<void> togglePlayPause() async {
    if (!mounted) return;
    if (state.isPlaying || _startingRequest == _playbackRequest) {
      await pause();
    } else {
      await resume();
    }
  }

  Future<void> pause() async {
    if (!mounted) return;
    final starting = _startingRequest == _playbackRequest;
    _playbackRequest++;
    state = state.copyWith(isLoading: false);
    if (!starting && (state.currentTrackId == null || !state.isPlaying)) return;
    await _driver.pause();
  }

  Future<void> resume() async {
    if (!mounted) return;
    if (state.currentTrackId == null || state.isPlaying) return;
    await playById(state.currentTrackId!);
  }

  Future<void> seekRelative(Duration delta) async {
    if (state.currentTrackId == null) return;

    final maxMs = state.duration.inMilliseconds;
    final targetMs = (state.position + delta).inMilliseconds;
    final clamped = maxMs <= 0
        ? targetMs.clamp(0, 1 << 31)
        : targetMs.clamp(0, maxMs);

    await _driver.seek(Duration(milliseconds: clamped.toInt()));
  }

  Future<void> seekTo(Duration position) async {
    if (state.currentTrackId == null) return;
    await _driver.seek(position);
  }

  Future<void> setVolume(double volume) async {
    if (!mounted) return;
    final safe = volume.clamp(0.0, 1.0).toDouble();
    state = state.copyWith(volume: safe);
    await _prefs.setDouble(_volumeKey, safe);
    if (!mounted) return;
    await _writeOutputVolume(
      soundOutputVolumeForSleepTimer(
        baseVolume: state.volume,
        remainingSeconds: state.sleepTimerRemainingSeconds,
      ),
    );
  }

  Future<void> stop() async {
    if (!mounted) return;
    _playbackRequest++;
    _sleepTimerRequest++;
    _readyTrackId = null;
    _sleepTimer?.cancel();
    _sleepTimer = null;
    _sleepTimerDeadline = null;
    state = state.copyWith(
      clearCurrentTrack: true,
      clearSleepTimer: true,
      isLoading: false,
      hasPlaybackError: false,
      position: Duration.zero,
      duration: Duration.zero,
      isPlaying: false,
    );
    await _driver.stop();
  }

  Future<void> toggleFavorite(String trackId) async {
    final next = Set<String>.from(state.favoriteIds);
    if (!next.add(trackId)) {
      next.remove(trackId);
    }
    state = state.copyWith(favoriteIds: next);
    await _prefs.setStringList(_favoritesKey, next.toList());
  }

  Future<void> setSleepTimer(int? minutes) async {
    if (!mounted) return;
    final request = ++_sleepTimerRequest;
    final selectedDeadline = minutes == null
        ? null
        : _now().add(Duration(minutes: minutes));
    _sleepTimer?.cancel();
    _sleepTimer = null;
    _sleepTimerDeadline = null;

    if (minutes == null) {
      state = state.copyWith(clearSleepTimer: true);
      if (state.currentTrackId != null) {
        await _writeOutputVolume(state.volume);
      }
      return;
    }

    if (state.currentTrackId != null) {
      await _writeOutputVolume(state.volume);
    }

    if (!_currentSleepTimerRequest(request)) return;

    final totalSeconds = minutes * 60;
    _sleepTimerDeadline = selectedDeadline;
    state = state.copyWith(
      sleepTimerMinutes: minutes,
      sleepTimerRemainingSeconds: totalSeconds,
    );

    _sleepTimer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (!_currentSleepTimerRequest(request)) {
        timer.cancel();
        return;
      }

      await syncSleepTimerNow();
      if (_sleepTimerDeadline == null) {
        timer.cancel();
      }
    });
    await syncSleepTimerNow();
  }

  Future<void> syncSleepTimerNow() async {
    if (!mounted) return;

    final deadline = _sleepTimerDeadline;
    if (deadline == null) return;
    final request = _sleepTimerRequest;

    final remaining =
        (deadline.difference(_now()).inMicroseconds /
                Duration.microsecondsPerSecond)
            .ceil();
    if (remaining > 0) {
      state = state.copyWith(sleepTimerRemainingSeconds: remaining);

      if (state.currentTrackId != null) {
        await _writeOutputVolume(
          soundOutputVolumeForSleepTimer(
            baseVolume: state.volume,
            remainingSeconds: remaining,
          ),
        );
      }
      return;
    }

    _sleepTimer?.cancel();
    _sleepTimer = null;
    _sleepTimerDeadline = null;

    final playbackRequest = _playbackRequest;
    var driverIntent = _driverPlaybackIntent;
    bool playbackCurrent() =>
        _currentPlaybackRequest(playbackRequest) &&
        driverIntent == _driverPlaybackIntent;
    final wasPlaying = state.isPlaying;
    final trackId = state.currentTrackId;
    // Expiry is already reached; a later Play must start at the normal volume.
    state = state.copyWith(clearSleepTimer: true);
    if (state.currentTrackId != null) {
      await _writeOutputVolume(0);
    }
    if (!_currentSleepTimerRequest(request) || !playbackCurrent()) {
      await _restoreExpiredTimerVolume(request);
      return;
    }
    final pausing = _driver.pause();
    driverIntent = _driverPlaybackIntent;
    await pausing;
    if (!_currentSleepTimerRequest(request)) {
      if (mounted &&
          wasPlaying &&
          playbackCurrent() &&
          trackId == state.currentTrackId) {
        await _driver.resume();
      }
      return;
    }
    if (!playbackCurrent()) {
      await _restoreExpiredTimerVolume(request);
      return;
    }
    if (state.currentTrackId != null) {
      await _writeOutputVolume(state.volume);
    }

    if (!_currentSleepTimerRequest(request) || !playbackCurrent()) {
      return;
    }
    state = state.copyWith(isPlaying: false, clearSleepTimer: true);
  }

  Future<void> _restoreExpiredTimerVolume(int request) async {
    if (_currentSleepTimerRequest(request) && state.sleepTimerMinutes == null) {
      // A notification can cancel expiry after its mute without replacing the
      // timer. Restore output only; preserve that newer transport decision.
      await _writeOutputVolume(state.volume);
    }
  }

  Future<void> _markRecent(String trackId) async {
    final next = <String>[
      trackId,
      ...state.recentIds.where((id) => id != trackId),
    ].take(6).toList();

    state = state.copyWith(recentIds: next);
    await _prefs.setStringList(_recentsKey, next);
  }

  @override
  void dispose() {
    _playbackRequest++;
    _outputVolumeRequest++;
    _sleepTimerRequest++;
    _sleepTimer?.cancel();
    _sleepTimerDeadline = null;
    _durationSubscription?.cancel();
    _positionSubscription?.cancel();
    _playerStateSubscription?.cancel();
    unawaited(_driver.dispose());
    super.dispose();
  }
}
