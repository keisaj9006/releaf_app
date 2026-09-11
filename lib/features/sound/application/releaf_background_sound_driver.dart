import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:audioplayers/audioplayers.dart' as audio;

import 'sound_player_controller.dart';

class ReleafBackgroundSoundDriver extends BaseAudioHandler
    implements SoundPlaybackDriver, SoundPlaybackIntentTracker {
  ReleafBackgroundSoundDriver({audio.AudioPlayer? player})
    : _player = player ?? audio.AudioPlayer() {
    _durationSubscription = _player.onDurationChanged.listen((duration) {
      final current = mediaItem.value;
      if (current != null) {
        mediaItem.add(current.copyWith(duration: duration));
      }
    });

    _positionSubscription = _player.onPositionChanged.listen((position) {
      _lastPosition = position;
    });

    _playerStateSubscription = _player.onPlayerStateChanged.listen((
      playerState,
    ) {
      _lastPlayerState = playerState;

      if (playerState == audio.PlayerState.completed) {
        _processingState = AudioProcessingState.completed;
      } else if (playerState == audio.PlayerState.stopped) {
        _processingState = AudioProcessingState.idle;
      } else {
        _processingState = AudioProcessingState.ready;
      }

      _broadcastPlaybackState();
    });
  }

  final audio.AudioPlayer _player;
  late final _native = AudioplayersSoundPlaybackDriver(player: _player);
  int _mediaRequest = 0;
  bool _disposed = false;

  @override
  int get playbackIntentVersion => _native.playbackIntentVersion;

  StreamSubscription<Duration>? _durationSubscription;
  StreamSubscription<Duration>? _positionSubscription;
  StreamSubscription<audio.PlayerState>? _playerStateSubscription;

  Duration _lastPosition = Duration.zero;
  audio.PlayerState _lastPlayerState = audio.PlayerState.stopped;
  AudioProcessingState _processingState = AudioProcessingState.idle;

  @override
  Stream<Duration> get onDurationChanged => _player.onDurationChanged;

  @override
  Stream<Duration> get onPositionChanged => _player.onPositionChanged;

  @override
  Stream<audio.PlayerState> get onPlayerStateChanged =>
      _player.onPlayerStateChanged;

  @override
  Future<void> setReleaseMode(audio.ReleaseMode mode) =>
      _native.setReleaseMode(mode);

  @override
  Future<void> setVolume(double volume) => _native.setVolume(volume);

  @override
  Future<void> playAsset(
    String assetPath, {
    String? trackId,
    String? title,
  }) async {
    if (_disposed) return;
    _mediaRequest++;
    _lastPosition = Duration.zero;
    _processingState = AudioProcessingState.loading;

    mediaItem.add(
      MediaItem(
        id: trackId ?? assetPath,
        title: title ?? 'Releaf Sound',
        album: 'Releaf',
        artist: 'Releaf',
        extras: <String, dynamic>{'assetPath': assetPath},
      ),
    );
    _broadcastPlaybackState();

    await _native.playAsset(assetPath, trackId: trackId, title: title);
  }

  @override
  Future<void> play() async {
    await _native.resume();
  }

  @override
  Future<void> resume() => play();

  @override
  Future<void> pause() async {
    await _native.pause();
  }

  @override
  Future<void> stop() async {
    final request = ++_mediaRequest;
    await _native.stop();
    if (_disposed || request != _mediaRequest) return;
    _lastPosition = Duration.zero;
    _processingState = AudioProcessingState.idle;
    _broadcastPlaybackState();
  }

  @override
  Future<void> seek(Duration position) async {
    _lastPosition = position;
    await _native.seek(position);
    _broadcastPlaybackState();
  }

  void _broadcastPlaybackState() {
    final playing = _lastPlayerState == audio.PlayerState.playing;
    final hasMedia = mediaItem.value != null;
    final controls = hasMedia
        ? <MediaControl>[
            playing ? MediaControl.pause : MediaControl.play,
            MediaControl.stop,
          ]
        : const <MediaControl>[];

    playbackState.add(
      PlaybackState(
        controls: controls,
        systemActions: hasMedia
            ? const <MediaAction>{MediaAction.seek}
            : const <MediaAction>{},
        androidCompactActionIndices: controls.length >= 2
            ? const <int>[0, 1]
            : null,
        processingState: _processingState,
        playing: playing,
        updatePosition: _lastPosition,
        speed: 1.0,
        repeatMode: AudioServiceRepeatMode.one,
      ),
    );
  }

  @override
  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;
    _mediaRequest++;
    // Invalidate synchronously before subscription cancellation can yield.
    final disposing = _native.dispose();
    await _durationSubscription?.cancel();
    await _positionSubscription?.cancel();
    await _playerStateSubscription?.cancel();
    await disposing;
  }
}
