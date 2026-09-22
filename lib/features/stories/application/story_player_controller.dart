import 'dart:async';

import 'package:audio_session/audio_session.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/audio/releaf_audio_session.dart';
import '../data/story_playback_store.dart';
import '../domain/relief_story.dart';
import 'story_playback_driver.dart';
import 'story_playback_policy.dart';
import 'story_player_state.dart';

/// Screen-independent narration state. Runtime integration must give this
/// controller exclusive audio ownership before exposing it to users.
class StoryPlayerController extends StateNotifier<StoryPlayerState> {
  StoryPlayerController({
    required StoryPlaybackStore store,
    required StoryPlaybackDriver driver,
    DateTime Function()? now,
    Future<void> Function(ReliefStory story)? beforePlayback,
  }) : _store = store,
       _driver = driver,
       _now = now ?? DateTime.now,
       _beforePlayback = beforePlayback,
       super(StoryPlayerState(rate: store.playbackRate)) {
    _positionSub = _driver.onPositionChanged.listen(
      _onPosition,
      onError: (Object error, StackTrace stack) => _streamError(),
    );
    _stateSub = _driver.onPlayerStateChanged.listen(
      _onNativeState,
      onError: (Object error, StackTrace stack) => _streamError(),
    );
  }

  final StoryPlaybackStore _store;
  final StoryPlaybackDriver _driver;
  final DateTime Function() _now;
  final Future<void> Function(ReliefStory story)? _beforePlayback;
  StreamSubscription<Duration>? _positionSub;
  StreamSubscription<PlayerState>? _stateSub;
  Future<void> _operations = Future<void>.value();
  bool _closed = false;
  bool _ready = false;
  bool _wantPlaying = false;
  bool _seeking = false;
  bool _completionEligible = false;
  int _request = 0;
  int _seekRequest = 0;
  Duration _confirmedPosition = Duration.zero;
  DateTime? _lastSave;
  Timer? _timer;
  DateTime? _deadline;
  int? _interruptedRequest;
  int? _interruptedNativeIntent;
  Future<void>? _interruptionPause;

  bool _current(int request) => !_closed && mounted && request == _request;

  Future<void> _enqueue(Future<void> Function() action) {
    final next = _operations.then((_) async {
      if (!_closed) await action();
    });
    _operations = next.then<void>((_) {}, onError: (Object _, StackTrace _) {});
    return next;
  }

  Future<void> playStory(ReliefStory story) {
    if (_closed) return Future<void>.value();
    final checkpoint = flushProgress();
    final previous = state;
    final request = ++_request;
    _interruptedRequest = null;
    _seekRequest++;
    _seeking = false;
    _ready = false;
    // Start cancellation now, not after a slow previous load leaves the queue.
    final halting = _halt();
    final available = StoryPlaybackPolicy.hasDeliveryMetadata(story);
    final acknowledged = _store.isWarningAcknowledged(story);
    _wantPlaying = available && acknowledged;
    _confirmedPosition = Duration.zero;
    state = StoryPlayerState(
      story: story,
      rate: _store.playbackRate,
      isLoading: _wantPlaying,
      isAudioUnavailable: !available,
      warningRequired: available && !acknowledged,
      sleepTimerRemainingSeconds: previous.sleepTimerRemainingSeconds,
    );
    return _enqueue(() async {
      await checkpoint;
      final halted = await halting;
      if (!_current(request)) return;
      if (!halted.stopped) {
        state = previous.copyWith(
          isLoading: false,
          errorMessage: 'Playback could not be stopped. Please try again.',
        );
        return;
      }
      if (!_wantPlaying) return;
      try {
        await _beforePlayback?.call(story);
        if (!_current(request)) return;
        final preparing = _driver.prepare(story);
        final nativeIntent = _driver.playbackIntentVersion;
        final duration = await preparing;
        if (!_current(request) || nativeIntent != _driver.playbackIntentVersion) {
          return;
        }
        if (duration == null || duration <= Duration.zero) {
          throw StateError('Measured narration duration unavailable');
        }
        final saved = _store.readProgress(story, duration: duration);
        _confirmedPosition = saved.position >= duration
            ? Duration.zero
            : saved.position;
        state = state.copyWith(
          position: _confirmedPosition,
          duration: duration,
          completed: saved.completed,
          rate: _store.playbackRate,
        );
        await _startPrepared(request);
      } catch (_) {
        await _playbackFailure(request);
      } finally {
        if (_current(request)) state = state.copyWith(isLoading: false);
      }
    });
  }

  Future<void> _startPrepared(int request) async {
    if (!_current(request) || !_wantPlaying) return;
    final position = state.position >= state.duration
        ? Duration.zero
        : state.position;
    final starting = _driver.startAt(position, state.rate);
    final nativeIntent = _driver.playbackIntentVersion;
    await starting;
    if (!_current(request) || nativeIntent != _driver.playbackIntentVersion) {
      return;
    }
    _ready = true;
    _completionEligible = true;
    _confirmedPosition = position;
    state = state.copyWith(
      isPlaying: true,
      isLoading: false,
      position: position,
      warningRequired: false,
      clearError: true,
    );
    await flushProgress();
  }

  Future<void> resume() {
    if (_closed || state.story == null || state.isPlaying || state.isLoading) {
      return Future<void>.value();
    }
    final story = state.story!;
    if (!_ready || !_store.isWarningAcknowledged(story)) return playStory(story);
    final request = ++_request;
    _interruptedRequest = null;
    _wantPlaying = true;
    state = state.copyWith(isLoading: true, clearError: true);
    return _enqueue(() async {
      try {
        if (!_current(request)) return;
        await _beforePlayback?.call(story);
        if (_current(request)) await _startPrepared(request);
      } catch (_) {
        await _playbackFailure(request);
      } finally {
        if (_current(request)) state = state.copyWith(isLoading: false);
      }
    });
  }

  Future<void> togglePlayPause() => state.isPlaying || state.isLoading
      ? pause()
      : resume();

  Future<({bool stopped, bool hadError, bool usedStop})> _halt({
    bool stop = false,
  }) async {
    try {
      if (stop) {
        await _driver.stop();
      } else {
        await _driver.pause();
      }
      return (stopped: true, hadError: false, usedStop: stop);
    } catch (_) {
      if (!stop) {
        try {
          await _driver.stop();
          return (stopped: true, hadError: true, usedStop: true);
        } catch (_) {
          // Keep the last observed playback state if both native calls failed.
        }
      }
      return (stopped: false, hadError: true, usedStop: stop);
    }
  }

  Future<void> pause() => _suspend();

  Future<void> stop() {
    if (_closed) return Future<void>.value();
    _cancelTimer();
    return _suspend(stop: true);
  }

  Future<void> _suspend({bool stop = false}) {
    if (_closed) return Future<void>.value();
    final request = ++_request;
    _interruptedRequest = null;
    _wantPlaying = false;
    _seekRequest++;
    _seeking = false;
    if (state.isLoading || stop) _ready = false;
    state = state.copyWith(isLoading: false, position: _confirmedPosition);
    final halting = _halt(stop: stop);
    return _enqueue(() async {
      final result = await halting;
      if (!_current(request)) return;
      if (result.usedStop) _ready = false;
      state = state.copyWith(
        isPlaying: result.stopped ? false : state.isPlaying,
        errorMessage: result.hadError
            ? 'Playback could not pause normally. Please try again.'
            : null,
      );
      await flushProgress();
    });
  }

  Future<void> _playbackFailure(int request) async {
    if (!_current(request)) return;
    _ready = false;
    _wantPlaying = false;
    final result = await _halt();
    if (!_current(request)) return;
    state = state.copyWith(
      isLoading: false,
      isPlaying: result.stopped ? false : state.isPlaying,
      errorMessage: 'Narration could not be played. Please try again.',
    );
  }

  Future<void> seekRelative(Duration delta) => seekTo(
    StoryPlaybackPolicy.seekRelative(
      position: state.position,
      delta: delta,
      duration: state.duration,
    ),
  );

  Future<void> seekTo(Duration position) {
    if (_closed || !_ready || state.isLoading || state.duration <= Duration.zero) {
      return Future<void>.value();
    }
    final request = _request;
    final seek = ++_seekRequest;
    final target = StoryPlaybackPolicy.clampPosition(position, state.duration);
    _interruptedRequest = null;
    _completionEligible = false;
    _seeking = true;
    // Optimistic target lets successive +10 taps accumulate rather than repeat.
    state = state.copyWith(position: target);
    return _enqueue(() async {
      if (!_current(request) || seek != _seekRequest) return;
      try {
        await _driver.seek(target);
        if (!_current(request) || seek != _seekRequest) return;
        _confirmedPosition = target;
        state = state.copyWith(position: target, clearError: true);
        await flushProgress();
      } catch (_) {
        if (_current(request) && seek == _seekRequest) {
          state = state.copyWith(
            position: _confirmedPosition,
            errorMessage: 'Could not move to that position. Please try again.',
          );
        }
      } finally {
        if (_current(request) && seek == _seekRequest) _seeking = false;
      }
    });
  }

  Future<void> jumpToChapter(String chapterId) {
    final story = state.story;
    if (story == null) return Future<void>.value();
    final position = StoryPlaybackPolicy.chapterStart(story, chapterId, state.duration);
    return position == null ? Future<void>.value() : seekTo(position);
  }

  Future<void> setPlaybackRate(double rate) {
    if (_closed || !rate.isFinite || !StoryPlaybackPolicy.supportedRates.contains(rate)) {
      return Future<void>.value();
    }
    return _enqueue(() async {
      try {
        if (_ready) await _driver.setPlaybackRate(rate);
        if (_closed) return;
        final saved = await _store.setPlaybackRate(rate);
        if (_closed) return;
        state = state.copyWith(
          rate: rate,
          clearError: saved,
          errorMessage: saved ? null : 'Playback speed could not be saved.',
        );
      } catch (_) {
        if (!_closed) {
          state = state.copyWith(errorMessage: 'Playback speed could not be changed.');
        }
      }
    });
  }

  Future<void> setSleepTimer(int? minutes) async {
    if (_closed || (minutes != null && (minutes < 1 || minutes > 180))) return;
    _cancelTimer();
    if (minutes == null) return;
    _deadline = _now().add(Duration(minutes: minutes));
    state = state.copyWith(sleepTimerRemainingSeconds: minutes * 60);
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      unawaited(syncSleepTimerNow());
    });
    await syncSleepTimerNow();
  }

  Future<void> syncSleepTimerNow() async {
    if (_closed || _deadline == null) return;
    final remaining = (_deadline!.difference(_now()).inMicroseconds /
        Duration.microsecondsPerSecond).ceil();
    if (remaining > 0) {
      state = state.copyWith(sleepTimerRemainingSeconds: remaining);
      return;
    }
    _cancelTimer();
    await pause();
  }

  void _cancelTimer() {
    _timer?.cancel();
    _timer = null;
    _deadline = null;
    if (!_closed && mounted) state = state.copyWith(clearSleepTimer: true);
  }

  Future<void> handleAudioInterruption(AudioInterruptionEvent event) async {
    if (_closed) return;
    const mode = ReleafAudioMode.guidedMeditation;
    if (event.begin) {
      if (!releafShouldPauseForInterruption(mode, event.type)) return;
      if (!state.isPlaying && !state.isLoading) return;
      final pausing = pause();
      _interruptionPause = pausing;
      _interruptedRequest = releafShouldAutoResumeAfterInterruption(mode, event.type)
          ? _request
          : null;
      _interruptedNativeIntent = _driver.playbackIntentVersion;
      await pausing;
      return;
    }
    if (!releafShouldAutoResumeAfterInterruption(mode, event.type)) {
      _interruptedRequest = null;
      return;
    }
    final request = _interruptedRequest;
    final nativeIntent = _interruptedNativeIntent;
    if (request == null) return;
    await _interruptionPause;
    if (!_current(request) || _interruptedRequest != request ||
        nativeIntent != _driver.playbackIntentVersion) {
      return;
    }
    _interruptedRequest = null;
    await syncSleepTimerNow();
    if (_current(request)) await resume();
  }

  Future<void> handleBecomingNoisy() {
    _interruptedRequest = null;
    return pause();
  }

  void _onPosition(Duration position) {
    if (_closed || !_ready || state.isLoading || _seeking) return;
    final safe = StoryPlaybackPolicy.clampPosition(position, state.duration);
    if (state.isPlaying && safe > _confirmedPosition) _completionEligible = true;
    _confirmedPosition = safe;
    state = state.copyWith(position: safe);
    if (_lastSave == null || _now().difference(_lastSave!) >= const Duration(seconds: 5)) {
      unawaited(flushProgress());
    }
  }

  void _onNativeState(PlayerState native) {
    if (_closed || !_ready || state.isLoading) return;
    if (native == PlayerState.completed) {
      if (_seeking) return;
      _wantPlaying = false;
      _confirmedPosition = state.duration;
      _cancelTimer();
      state = state.copyWith(
        isPlaying: false,
        position: state.duration,
        completed: state.completed || _completionEligible,
      );
      unawaited(flushProgress());
    } else if (native == PlayerState.paused || native == PlayerState.stopped) {
      if (native == PlayerState.stopped) _ready = false;
      state = state.copyWith(isPlaying: false);
      unawaited(flushProgress());
    } else if (native == PlayerState.playing && _wantPlaying) {
      state = state.copyWith(isPlaying: true);
    }
  }

  void _streamError() {
    if (_closed) return;
    state = state.copyWith(errorMessage: 'The audio connection was interrupted.');
    unawaited(pause());
  }

  Future<void> flushProgress() async {
    if (_closed) return;
    final snapshot = state;
    final story = snapshot.story;
    if (story == null || snapshot.duration <= Duration.zero) return;
    final request = _request;
    final position = _confirmedPosition;
    _lastSave = _now();
    final saved = await _store.saveProgress(
      story,
      position: position,
      duration: snapshot.duration,
      completed: snapshot.completed,
    );
    if (!saved && _current(request) && state.errorMessage == null) {
      state = state.copyWith(errorMessage: 'Listening position could not be saved.');
    }
  }

  @override
  void dispose() {
    if (_closed) return;
    unawaited(flushProgress());
    _cancelTimer();
    _closed = true;
    _request++;
    _positionSub?.cancel();
    _stateSub?.cancel();
    unawaited(_driver.dispose().catchError((Object _) {}));
    super.dispose();
  }
}
