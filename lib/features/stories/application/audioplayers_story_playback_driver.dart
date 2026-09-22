import 'dart:async';

import 'package:audioplayers/audioplayers.dart';

import '../../../core/audio/releaf_audio_session.dart';
import '../domain/relief_story.dart';
import 'story_playback_driver.dart';
import 'story_playback_policy.dart';

/// Paused-load narration adapter. This is NOT a second background service.
/// App integration must assign exclusive ownership via the shared media handler.
class AudioplayersStoryPlaybackDriver implements StoryPlaybackDriver {
  AudioplayersStoryPlaybackDriver({
    AudioPlayer? player,
    Future<void> Function()? configureSession,
  }) : _player = player ?? AudioPlayer(),
       _configureSession = configureSession ?? _configureSpeech;

  static Future<void> _configureSpeech() async {
    await configureReleafAudioSession(ReleafAudioMode.guidedMeditation);
  }

  final AudioPlayer _player;
  final Future<void> Function() _configureSession;
  Future<void> _pending = Future<void>.value();
  Completer<void>? _loadingCancelled;
  bool _disposed = false;
  bool _ready = false;
  int _intent = 0;
  Duration _duration = Duration.zero;

  @override
  int get playbackIntentVersion => _intent;
  @override
  Stream<Duration> get onPositionChanged => _player.onPositionChanged;
  @override
  Stream<PlayerState> get onPlayerStateChanged => _player.onPlayerStateChanged;

  bool _current(int request) => !_disposed && request == _intent;

  int _invalidate() {
    final cancelled = _loadingCancelled;
    if (cancelled != null && !cancelled.isCompleted) cancelled.complete();
    _loadingCancelled = null;
    return ++_intent;
  }

  Future<T> _enqueue<T>(Future<T> Function() action) {
    final next = _pending.then((_) => action());
    _pending = next.then<void>((_) {}, onError: (Object _, StackTrace _) {});
    return next;
  }

  @override
  Future<Duration?> prepare(ReliefStory story) {
    if (_disposed) return Future<Duration?>.value();
    final request = _invalidate();
    final cancelled = _loadingCancelled = Completer<void>();
    _ready = false;
    _duration = Duration.zero;
    return _enqueue(() async {
      if (!_current(request)) return null;
      if (!StoryPlaybackPolicy.hasDeliveryMetadata(story)) {
        throw StateError('No versioned narration delivery is available');
      }
      final measured = Completer<Duration>();
      var loadingSource = false;
      final subscription = _player.onDurationChanged.listen((duration) {
        if (loadingSource && _current(request) && duration > Duration.zero &&
            !measured.isCompleted) {
          measured.complete(duration);
        }
      });
      try {
        await _player.stop();
        if (!_current(request)) return null;
        await _configureSession();
        if (!_current(request)) return null;
        await _player.setReleaseMode(ReleaseMode.stop);
        if (!_current(request)) return null;
        await _player.setVolume(0);
        if (!_current(request)) return null;
        loadingSource = true;
        await _player.setSource(AssetSource(story.audioAssetPath!));
        if (!_current(request)) return null;
        var duration = await _player.getDuration();
        if (!_current(request)) return null;
        if (duration == null || duration <= Duration.zero) {
          duration = await Future.any<Duration?>([
            measured.future,
            cancelled.future.then<Duration?>((_) => null),
          ]).timeout(const Duration(seconds: 10), onTimeout: () => null);
        }
        if (!_current(request)) return null;
        if (duration == null || duration <= Duration.zero) {
          throw StateError('Measured narration duration unavailable');
        }
        _duration = duration;
        _ready = true;
        return duration;
      } finally {
        await subscription.cancel();
        if (identical(_loadingCancelled, cancelled)) _loadingCancelled = null;
      }
    });
  }

  @override
  Future<void> startAt(Duration position, double rate) {
    if (_disposed) return Future<void>.value();
    final request = _invalidate();
    return _enqueue(() async {
      if (!_current(request)) return;
      if (!_ready || !rate.isFinite || !StoryPlaybackPolicy.supportedRates.contains(rate)) {
        throw StateError('Narration is not prepared or playback rate is invalid');
      }
      final target = StoryPlaybackPolicy.clampPosition(position, _duration);
      try {
        // audioplayers documents rate setup after resume. Prime MUTED, restore
        // speed and media position, then permit audible output. Do not reorder.
        await _player.setVolume(0);
        if (!_current(request)) return;
        await _player.resume();
        if (!_current(request)) return;
        await _player.setPlaybackRate(rate);
        if (!_current(request)) return;
        await _player.seek(target);
        if (!_current(request)) return;
        await _player.setVolume(1);
      } catch (_) {
        if (_current(request)) {
          _ready = false;
          try { await _player.setVolume(0); } catch (_) { /* still attempt stop */ }
          try { await _player.stop(); } catch (_) { /* controller reports error */ }
        }
        rethrow;
      }
    });
  }

  @override
  Future<void> pause() {
    final request = _invalidate();
    return _enqueue(() async {
      if (_current(request)) await _player.pause();
    });
  }

  @override
  Future<void> stop() {
    final request = _invalidate();
    _ready = false;
    return _enqueue(() async {
      if (_current(request)) await _player.stop();
    });
  }

  @override
  Future<void> seek(Duration position) {
    final request = _intent;
    return _enqueue(() async {
      if (_current(request) && _ready) {
        await _player.seek(StoryPlaybackPolicy.clampPosition(position, _duration));
      }
    });
  }

  @override
  Future<void> setPlaybackRate(double rate) {
    final request = _intent;
    return _enqueue(() async {
      if (!_current(request) || !_ready) return;
      if (!rate.isFinite || !StoryPlaybackPolicy.supportedRates.contains(rate)) {
        throw ArgumentError.value(rate, 'rate');
      }
      await _player.setPlaybackRate(rate);
    });
  }

  @override
  Future<void> dispose() {
    if (_disposed) return _pending;
    _disposed = true;
    _ready = false;
    _invalidate();
    return _enqueue(_player.dispose);
  }
}
