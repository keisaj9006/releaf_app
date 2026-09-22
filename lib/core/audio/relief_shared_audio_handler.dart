import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/sound/application/sound_player_controller.dart';
import '../../features/sound/data/sound_catalog.dart';
import '../../features/sound/domain/sound_content.dart';
import '../../features/stories/application/story_playback_driver.dart';
import '../../features/stories/application/story_playback_policy.dart';
import '../../features/stories/application/story_player_controller.dart';
import '../../features/stories/application/story_player_state.dart';
import '../../features/stories/data/story_playback_store.dart';
import '../../features/stories/domain/relief_story.dart';

enum ReliefMediaOwner { none, sound, story }

class _MediaClaim {
  const _MediaClaim(this.isCurrent, this.ready);
  final bool Function() isCurrent;
  final Future<bool> ready;

  Future<void> wait() async {
    final stopped = await ready;
    if (!stopped || !isCurrent()) {
      throw StateError('Audio ownership was cancelled or could not transfer');
    }
  }
}

/// One system media session. The decoders remain separate so an obsolete
/// command in one driver's queue can never seek or unmute the other source.
/// Only the owner is permitted to start; a failed handoff is fail-closed.
class ReliefSharedAudioHandler extends BaseAudioHandler {
  ReliefSharedAudioHandler({
    required SharedPreferences preferences,
    required SoundPlaybackDriver soundDriver,
    required StoryPlaybackDriver storyDriver,
    required Future<void> Function() configureSoundSession,
    DateTime Function()? now,
  }) : _soundDriver = soundDriver,
       _storyDriver = storyDriver {
    sound = ReliefManagedSoundController(
      preferences: preferences,
      driver: soundDriver,
      now: now,
      reserve: () => _reserve(ReliefMediaOwner.sound),
      configureSession: configureSoundSession,
    );
    final store = StoryPlaybackStore(preferences);
    stories = ReliefManagedStoryController(
      store: store,
      driver: storyDriver,
      now: now,
      reserve: () { _storyClaim = _reserve(ReliefMediaOwner.story); },
      beforePlayback: (_) async {
        final claim = _storyClaim;
        if (claim == null) throw StateError('No narration ownership request');
        await claim.wait();
      },
    );
    _removeSoundListener = sound.addListener((_) => _publish(), fireImmediately: false);
    _removeStoryListener = stories.addListener((_) => _publish(), fireImmediately: false);
  }

  final SoundPlaybackDriver _soundDriver;
  final StoryPlaybackDriver _storyDriver;
  late final ReliefManagedSoundController sound;
  late final ReliefManagedStoryController stories;
  late final void Function() _removeSoundListener;
  late final void Function() _removeStoryListener;
  ReliefMediaOwner _owner = ReliefMediaOwner.none;
  ReliefMediaOwner get owner => _owner;
  int _epoch = 0;
  bool _closing = false;
  Future<void>? _closeFuture;
  _MediaClaim? _storyClaim;
  ({int epoch, ReliefMediaOwner owner})? _interruption;

  _MediaClaim _reserve(ReliefMediaOwner target) {
    final epoch = ++_epoch;
    bool current() => !_closing && epoch == _epoch;
    if (_closing) return _MediaClaim(current, Future<bool>.value(false));
    _interruption = null;
    _owner = target;
    // Stop is invoked synchronously, before a queue/configuration can yield.
    // Error handlers are attached immediately even if the claimant is cancelled.
    final stopping = target == ReliefMediaOwner.story ? sound.stop() : stories.stop();
    final ready = () async {
      try {
        await stopping;
        if (!current()) return false;
        if (target == ReliefMediaOwner.sound) {
          // Story stop contains errors for its UI. Confirm native shutdown before
          // granting another decoder permission; UI state alone is not evidence.
          await _storyDriver.stop();
          if (!current()) return false;
        }
        return true;
      } catch (_) {
        if (current()) {
          _owner = target == ReliefMediaOwner.story
              ? ReliefMediaOwner.sound : ReliefMediaOwner.story;
          _publish();
        }
        return false;
      }
    }();
    _publish();
    return _MediaClaim(current, ready);
  }

  @override
  Future<void> play() async {
    if (_closing) return;
    switch (_owner) {
      case ReliefMediaOwner.sound:
        await sound.resume();
      case ReliefMediaOwner.story:
        await stories.resume();
      case ReliefMediaOwner.none:
        return;
    }
  }

  @override
  Future<void> pause() async {
    if (_closing) return;
    ++_epoch;
    _interruption = null;
    // Also cancel requests which have not reached their native load yet.
    final soundPause = _settle(sound.pause());
    final storyPause = _settle(stories.pause());
    await Future.wait([soundPause, storyPause]);
    _publish();
  }

  static Future<bool> _settle(Future<void> action) async {
    try { await action; return true; } catch (_) { return false; }
  }

  @override
  Future<void> stop() async {
    if (_closing) return;
    final epoch = ++_epoch;
    _interruption = null;
    final soundStop = _settle(sound.stop());
    final storyStop = _settle(stories.stop());
    final results = await Future.wait([soundStop, storyStop]);
    if (_closing || epoch != _epoch) return;
    final storyStopped = await _settle(_storyDriver.stop());
    if (_closing || epoch != _epoch) return;
    if (results.every((result) => result) && storyStopped) {
      _owner = ReliefMediaOwner.none;
      _storyClaim = null;
    }
    _publish();
  }

  @override
  Future<void> seek(Duration position) async {
    if (_closing) return;
    switch (_owner) {
      case ReliefMediaOwner.story:
        await stories.seekTo(position);
      case ReliefMediaOwner.sound:
        final duration = sound.snapshot.duration;
        if (duration > Duration.zero) {
          await sound.seekTo(StoryPlaybackPolicy.clampPosition(position, duration));
        }
      case ReliefMediaOwner.none:
        return;
    }
    _publish();
  }

  Future<void> _skip(Duration delta) async {
    if (_owner == ReliefMediaOwner.story) {
      await stories.seekRelative(delta);
    } else if (_owner == ReliefMediaOwner.sound) {
      await seek(sound.snapshot.position + delta);
    }
  }

  @override
  Future<void> fastForward() => _skip(const Duration(seconds: 10));
  @override
  Future<void> rewind() => _skip(const Duration(seconds: -10));
  @override
  Future<void> setSpeed(double speed) async {
    if (!_closing && _owner == ReliefMediaOwner.story) {
      await stories.setPlaybackRate(speed);
    }
  }

  Future<void> handleAudioInterruption(AudioInterruptionEvent event) async {
    if (_closing) return;
    if (event.begin) {
      _interruption = (epoch: _epoch, owner: _owner);
    }
    final interrupted = _interruption;
    if (interrupted == null || interrupted.epoch != _epoch || interrupted.owner != _owner) {
      return;
    }
    switch (interrupted.owner) {
      case ReliefMediaOwner.sound:
        await sound.handleAudioInterruption(event);
      case ReliefMediaOwner.story:
        await stories.handleAudioInterruption(event);
      case ReliefMediaOwner.none:
        return;
    }
    if (!event.begin && identical(_interruption, interrupted)) _interruption = null;
  }

  Future<void> handleBecomingNoisy() => pause();

  /// Called at the application boundary, not from an ephemeral player screen.
  Future<void> onAppResumed() async {
    if (_closing) return;
    await Future.wait([
      sound.syncSleepTimerNow(), stories.syncSleepTimerNow(), stories.flushProgress(),
    ]);
  }

  Future<void> checkpoint() => stories.flushProgress();

  void _publish() {
    if (_closing) return;
    if (_owner == ReliefMediaOwner.none) {
      mediaItem.add(null);
      playbackState.add(PlaybackState(
        controls: const [], systemActions: const {}, playing: false,
        processingState: AudioProcessingState.idle,
      ));
      return;
    }
    final narration = _owner == ReliefMediaOwner.story;
    final ss = sound.snapshot;
    final ns = stories.snapshot;
    final track = ss.currentTrackId == null
        ? null : const SoundCatalog().getById(ss.currentTrackId!);
    final id = narration ? ns.story?.id : track?.id;
    if (id == null) {
      mediaItem.add(null);
      playbackState.add(PlaybackState(
        controls: const [], systemActions: const {}, playing: false,
        processingState: AudioProcessingState.idle,
      ));
      return;
    }
    final duration = narration ? ns.duration : ss.duration;
    final title = narration ? ns.story!.title : track!.title;
    final key = '${narration ? 'story' : 'sound'}:$id';
    final current = mediaItem.value;
    if (current?.id != key || current?.duration != (duration > Duration.zero ? duration : null) || current?.title != title) {
      mediaItem.add(MediaItem(
        id: key, title: title, artist: 'Relief',
        album: narration ? 'Relief Stories' : 'Relief Sound',
        duration: duration > Duration.zero ? duration : null,
      ));
    }
    final loading = narration ? ns.isLoading : ss.isLoading;
    final playing = narration ? ns.isPlaying && !loading : ss.isPlaying;
    final error = narration ? ns.errorMessage != null : ss.hasPlaybackError;
    final completed = narration && !playing && ns.completed && duration > Duration.zero && ns.position >= duration;
    playbackState.add(PlaybackState(
      controls: [
        MediaControl.rewind,
        playing || loading ? MediaControl.pause : MediaControl.play,
        MediaControl.fastForward,
        MediaControl.stop,
      ],
      systemActions: {MediaAction.seek, if (narration) MediaAction.setSpeed},
      androidCompactActionIndices: const [0, 1, 2],
      processingState: loading ? AudioProcessingState.loading
          : completed ? AudioProcessingState.completed
          : error && !playing ? AudioProcessingState.error : AudioProcessingState.ready,
      playing: playing,
      updatePosition: narration ? ns.position : ss.position,
      speed: narration ? ns.rate : 1.0,
      repeatMode: narration ? AudioServiceRepeatMode.none : AudioServiceRepeatMode.one,
    ));
  }

  Future<void> close() => _closeFuture ??= _close();
  Future<void> _close() async {
    if (_closing) return;
    _closing = true;
    ++_epoch;
    _interruption = null;
    _removeSoundListener();
    _removeStoryListener();
    final a = _settle(sound.stop());
    final b = _settle(stories.stop());
    await Future.wait([a, b]);
    sound.dispose();
    stories.dispose();
    await Future.wait([_soundDriver.dispose(), _storyDriver.dispose()]);
  }
}

/// The existing Sound controller still owns Sound's loops, volume, timers and
/// cancellation. This boundary only reserves shared ownership before entry.
class ReliefManagedSoundController extends SoundPlayerController {
  ReliefManagedSoundController({
    required SharedPreferences preferences,
    required SoundPlaybackDriver driver,
    required _MediaClaim Function() reserve,
    required Future<void> Function() configureSession,
    DateTime Function()? now,
  }) : _reserve = reserve, _configureSession = configureSession,
       super(const SoundCatalog(), preferences, driver: driver, now: now);

  final _MediaClaim Function() _reserve;
  final Future<void> Function() _configureSession;
  int _entry = 0;
  bool _preparingEntry = false;
  bool _closed = false;
  SoundPlayerState get snapshot => state;

  @override
  Future<void> play(SoundContent track) async {
    if (_closed) return;
    final entry = ++_entry;
    _preparingEntry = true;
    state = state.copyWith(currentTrackId: track.id, isLoading: true, hasPlaybackError: false);
    final claim = _reserve();
    try {
      await claim.wait();
      if (_closed || entry != _entry) return;
      await _configureSession();
      if (_closed || entry != _entry || !claim.isCurrent()) return;
      _preparingEntry = false;
      await super.play(track);
    } catch (_) {
      if (!_closed && entry == _entry) {
        state = state.copyWith(isLoading: false, hasPlaybackError: true);
      }
    } finally {
      if (!_closed && entry == _entry) {
        _preparingEntry = false;
        if (state.isLoading) state = state.copyWith(isLoading: false);
      }
    }
  }

  @override
  Future<void> pause() {
    if (_closed) return Future<void>.value();
    ++_entry;
    _preparingEntry = false;
    return super.pause();
  }

  @override
  Future<void> togglePlayPause() => _preparingEntry ? pause() : super.togglePlayPause();

  @override
  Future<void> stop() async {
    if (_closed) return;
    final entry = ++_entry;
    _preparingEntry = false;
    final previous = state;
    try {
      await super.stop();
    } catch (_) {
      if (!_closed && entry == _entry) {
        state = previous.copyWith(isLoading: false, hasPlaybackError: true, clearSleepTimer: true);
      }
      rethrow;
    }
  }

  @override
  void dispose() {
    if (_closed) return;
    _closed = true;
    ++_entry;
    super.dispose();
  }
}

class ReliefManagedStoryController extends StoryPlayerController {
  ReliefManagedStoryController({
    required StoryPlaybackStore store,
    required super.driver,
    required void Function() reserve,
    required super.beforePlayback,
    super.now,
  }) : _store = store, _reserve = reserve, super(store: store);

  final StoryPlaybackStore _store;
  final void Function() _reserve;
  bool _closed = false;
  bool _reservingResume = false;
  StoryPlayerState get snapshot => state;

  bool _eligible(ReliefStory story) =>
      StoryPlaybackPolicy.hasDeliveryMetadata(story) && _store.isWarningAcknowledged(story);

  @override
  Future<void> playStory(ReliefStory story) {
    if (_closed) return Future<void>.value();
    if (!_reservingResume && _eligible(story)) _reserve();
    return super.playStory(story);
  }

  @override
  Future<void> resume() {
    if (_closed || state.story == null || state.isLoading || state.isPlaying) {
      return Future<void>.value();
    }
    if (_eligible(state.story!)) _reserve();
    _reservingResume = true;
    try { return super.resume(); } finally { _reservingResume = false; }
  }

  @override
  void dispose() {
    if (_closed) return;
    _closed = true;
    super.dispose();
  }
}
