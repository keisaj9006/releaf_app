import 'dart:async';

import 'package:audioplayers/audioplayers.dart' as audio;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/providers.dart';
import '../data/sound_catalog.dart';
import '../domain/sound_content.dart';

abstract class SoundPlaybackDriver {
  Stream<Duration> get onDurationChanged;
  Stream<Duration> get onPositionChanged;
  Stream<audio.PlayerState> get onPlayerStateChanged;

  Future<void> setReleaseMode(audio.ReleaseMode mode);
  Future<void> setVolume(double volume);
  Future<void> playAsset(String assetPath);
  Future<void> resume();
  Future<void> pause();
  Future<void> stop();
  Future<void> seek(Duration position);
  Future<void> dispose();
}

class AudioplayersSoundPlaybackDriver implements SoundPlaybackDriver {
  final audio.AudioPlayer _player = audio.AudioPlayer();

  @override
  Stream<Duration> get onDurationChanged => _driver.onDurationChanged;

  @override
  Stream<Duration> get onPositionChanged => _driver.onPositionChanged;

  @override
  Stream<audio.PlayerState> get onPlayerStateChanged =>
      _driver.onPlayerStateChanged;

  @override
  Future<void> setReleaseMode(audio.ReleaseMode mode) =>
      _player.setReleaseMode(mode);

  @override
  Future<void> setVolume(double volume) => _player.setVolume(volume);

  @override
  Future<void> playAsset(String assetPath) =>
      _player.play(audio.AssetSource(assetPath));

  @override
  Future<void> resume() => _player.resume();

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> stop() => _player.stop();

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  @override
  Future<void> dispose() => _player.dispose();
}

class SoundPlayerState {
  const SoundPlayerState({
    this.currentTrackId,
    this.isPlaying = false,
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.volume = 0.78,
    this.favoriteIds = const <String>{},
    this.recentIds = const <String>[],
    this.sleepTimerMinutes,
    this.sleepTimerRemainingSeconds,
  });

  final String? currentTrackId;
  final bool isPlaying;
  final Duration position;
  final Duration duration;
  final double volume;
  final Set<String> favoriteIds;
  final List<String> recentIds;
  final int? sleepTimerMinutes;
  final int? sleepTimerRemainingSeconds;

  SoundPlayerState copyWith({
    String? currentTrackId,
    bool clearCurrentTrack = false,
    bool? isPlaying,
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
      currentTrackId:
          clearCurrentTrack ? null : (currentTrackId ?? this.currentTrackId),
      isPlaying: isPlaying ?? this.isPlaying,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      volume: volume ?? this.volume,
      favoriteIds: favoriteIds ?? this.favoriteIds,
      recentIds: recentIds ?? this.recentIds,
      sleepTimerMinutes:
          clearSleepTimer ? null : (sleepTimerMinutes ?? this.sleepTimerMinutes),
      sleepTimerRemainingSeconds: clearSleepTimer
          ? null
          : (sleepTimerRemainingSeconds ?? this.sleepTimerRemainingSeconds),
    );
  }
}

final soundPlayerControllerProvider =
    StateNotifierProvider<SoundPlayerController, SoundPlayerState>((ref) {
  return SoundPlayerController(
    ref.watch(soundCatalogProvider),
    ref.watch(sharedPreferencesProvider),
  );
});

class SoundPlayerController extends StateNotifier<SoundPlayerState> {
  SoundPlayerController(
    this._catalog,
    this._prefs, {
    SoundPlaybackDriver? driver,
  })  : _driver = driver ?? AudioplayersSoundPlaybackDriver(),
        super(
          SoundPlayerState(
            favoriteIds:
                (_prefs.getStringList(_favoritesKey) ?? const <String>[]).toSet(),
            recentIds:
                _prefs.getStringList(_recentsKey) ?? const <String>[],
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
    _playerStateSubscription = _driver.onPlayerStateChanged.listen((playerState) {
      if (!mounted) return;
      state = state.copyWith(
        isPlaying: playerState == audio.PlayerState.playing,
      );
    });
  }

  static const _favoritesKey = 'sound.favorite_ids';
  static const _recentsKey = 'sound.recent_ids';

  final SoundCatalog _catalog;
  final SharedPreferences _prefs;
  final SoundPlaybackDriver _driver;

  StreamSubscription<Duration>? _durationSubscription;
  StreamSubscription<Duration>? _positionSubscription;
  StreamSubscription<audio.PlayerState>? _playerStateSubscription;
  Timer? _sleepTimer;
  DateTime? _sleepTimerDeadline;

  Future<void> play(SoundContent track) async {
    await _driver.setReleaseMode(audio.ReleaseMode.loop);
    await _driver.setVolume(state.volume);

    if (state.currentTrackId == track.id) {
      await _driver.resume();
    } else {
      await _driver.stop();
      state = state.copyWith(
        currentTrackId: track.id,
        position: Duration.zero,
        duration: Duration.zero,
        isPlaying: false,
      );
      await _driver.playAsset(track.assetPath);
      await _markRecent(track.id);
    }
  }

  Future<void> playById(String id) async {
    final track = _catalog.getById(id);
    if (track == null) return;
    await play(track);
  }

  Future<void> togglePlayPause() async {
    if (state.currentTrackId == null) return;
    if (state.isPlaying) {
      await _driver.pause();
    } else {
      await _driver.resume();
    }
  }

  Future<void> pause() async {
    if (state.currentTrackId == null || !state.isPlaying) return;
    await _driver.pause();
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
    final safe = volume.clamp(0.0, 1.0).toDouble();
    state = state.copyWith(volume: safe);
    await _driver.setVolume(safe);
  }

  Future<void> stop() async {
    _sleepTimer?.cancel();
    _sleepTimer = null;
    _sleepTimerDeadline = null;
    await _driver.stop();
    state = state.copyWith(
      clearCurrentTrack: true,
      clearSleepTimer: true,
      position: Duration.zero,
      duration: Duration.zero,
      isPlaying: false,
    );
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
    _sleepTimer?.cancel();
    _sleepTimer = null;
    _sleepTimerDeadline = null;

    if (minutes == null) {
      state = state.copyWith(clearSleepTimer: true);
      return;
    }

    final totalSeconds = minutes * 60;
    _sleepTimerDeadline = DateTime.now().add(Duration(minutes: minutes));
    state = state.copyWith(
      sleepTimerMinutes: minutes,
      sleepTimerRemainingSeconds: totalSeconds,
    );

    _sleepTimer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (!mounted) {
        timer.cancel();
        return;
      }

      final deadline = _sleepTimerDeadline;
      if (deadline == null) {
        timer.cancel();
        return;
      }

      final remaining = deadline.difference(DateTime.now()).inSeconds + 1;
      if (remaining > 0) {
        state = state.copyWith(
          sleepTimerRemainingSeconds: remaining,
        );
        return;
      }

      timer.cancel();
      _sleepTimer = null;
      _sleepTimerDeadline = null;
      await _driver.pause();
      if (!mounted) return;
      state = state.copyWith(
        isPlaying: false,
        clearSleepTimer: true,
      );
    });
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
    _sleepTimer?.cancel();
    _sleepTimerDeadline = null;
    _durationSubscription?.cancel();
    _positionSubscription?.cancel();
    _playerStateSubscription?.cancel();
    unawaited(_driver.dispose());
    super.dispose();
  }
}
