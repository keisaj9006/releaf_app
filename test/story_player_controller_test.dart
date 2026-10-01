import 'dart:async';

import 'package:audio_session/audio_session.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:releaf_app/features/stories/application/story_playback_driver.dart';
import 'package:releaf_app/features/stories/application/story_player_controller.dart';
import 'package:releaf_app/features/stories/data/story_catalog.dart';
import 'package:releaf_app/features/stories/data/story_playback_store.dart';
import 'package:releaf_app/features/stories/domain/relief_story.dart';

ReliefStory _story({String id = 'pilot', String audioVersion = 'mix-1'}) => ReliefStory(
  id: id,
  title: 'Test-only pilot',
  subtitle: 'Not a real bundled recording',
  series: 'Test',
  category: StoryCategory.trueStoriesOfCourage,
  description: 'Fixture',
  estimatedDuration: const Duration(minutes: 28),
  audioAssetPath: 'stories/test-only.mp3',
  artworkAssetPath: null,
  contentWarning: 'Wartime imprisonment.',
  labels: const ['TRUE STORY'],
  isPremium: false,
  chapters: const [
    ReliefStoryChapter(id: 'one', title: 'One', start: Duration.zero),
    ReliefStoryChapter(id: 'two', title: 'Two', start: Duration(seconds: 40)),
  ],
  rightsStatus: 'NOT YET CLEARED FOR COMMERCIAL RELEASE',
  scriptVersion: '2.0',
  audioVersion: audioVersion,
);

class _Transport implements StoryPlaybackDriver {
  final positions = StreamController<Duration>.broadcast(sync: true);
  final states = StreamController<PlayerState>.broadcast(sync: true);
  final prepared = <String>[];
  final audible = <({String id, Duration position, double rate})>[];
  final loadStarted = Completer<void>();
  Completer<void>? loadGate;
  Duration? duration = const Duration(seconds: 100);
  Duration position = Duration.zero;
  double rate = 1;
  String? source;
  bool failLoad = false;
  bool failStart = false;
  bool failPause = false;
  bool failStop = false;
  bool failSeek = false;
  bool failRate = false;
  int stopCalls = 0;
  bool disposed = false;
  int _intent = 0;

  @override
  int get playbackIntentVersion => _intent;
  @override
  Stream<Duration> get onPositionChanged => positions.stream;
  @override
  Stream<PlayerState> get onPlayerStateChanged => states.stream;

  @override
  Future<Duration?> prepare(ReliefStory story) async {
    final ticket = ++_intent;
    prepared.add(story.id);
    if (!loadStarted.isCompleted) loadStarted.complete();
    final gate = loadGate;
    loadGate = null;
    if (gate != null) await gate.future;
    if (ticket != _intent || disposed) return null;
    if (failLoad) throw StateError('load failed');
    source = story.id;
    return duration;
  }

  @override
  Future<void> startAt(Duration value, double speed) async {
    _intent++;
    if (failStart) throw StateError('start failed');
    position = value;
    rate = speed;
    audible.add((id: source!, position: value, rate: speed));
    states.add(PlayerState.playing);
  }

  @override
  Future<void> pause() async {
    _intent++;
    if (failPause) throw StateError('pause failed');
    states.add(PlayerState.paused);
  }

  @override
  Future<void> stop() async {
    _intent++;
    stopCalls++;
    if (failStop) throw StateError('stop failed');
    states.add(PlayerState.stopped);
  }

  @override
  Future<void> seek(Duration value) async {
    if (failSeek) throw StateError('seek failed');
    position = value;
    positions.add(value);
  }

  @override
  Future<void> setPlaybackRate(double value) async {
    if (failRate) throw StateError('rate failed');
    rate = value;
  }

  @override
  Future<void> dispose() async {
    if (disposed) return;
    disposed = true;
    _intent++;
    await positions.close();
    await states.close();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late StoryPlaybackStore store;
  late _Transport transport;
  late StoryPlayerController controller;
  late DateTime now;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    store = StoryPlaybackStore(await SharedPreferences.getInstance());
    transport = _Transport();
    now = DateTime(2026, 9, 22, 20);
    controller = StoryPlayerController(store: store, driver: transport, now: () => now);
  });
  tearDown(() { if (controller.mounted) controller.dispose(); });

  Future<void> play([ReliefStory? story]) async {
    final selected = story ?? _story();
    await store.acknowledgeWarning(selected);
    await controller.playStory(selected);
  }

  test('missing delivery never starts audio or creates playback progress', () async {
    await controller.playStory(StoryCatalog.all.first);
    expect(controller.state.isAudioUnavailable, isTrue);
    expect(controller.state.isPlaying, isFalse);
    expect(transport.prepared, isEmpty);
    expect(store.lastPlayedId, isNull);
  });

  test('warning is enforced by controller, not only by a future screen', () async {
    await controller.playStory(_story());
    expect(controller.state.warningRequired, isTrue);
    expect(transport.prepared, isEmpty);
    await controller.resume();
    expect(transport.audible, isEmpty);
    expect(store.isWarningAcknowledged(_story()), isFalse);
    await store.acknowledgeWarning(_story());
    await controller.resume();
    expect(controller.state.isPlaying, isTrue);
  });

  test('restores position and speed before the first audible frame', () async {
    await store.saveProgress(_story(), position: const Duration(seconds: 35), duration: const Duration(seconds: 100));
    await store.setPlaybackRate(1.2);
    await play();
    expect(transport.audible.single, (id: 'pilot', position: const Duration(seconds: 35), rate: 1.2));
    expect(controller.state.duration, const Duration(seconds: 100));
    expect(controller.state.isPlaying, isTrue);
    expect(controller.state.isLoading, isFalse);
  });

  test('runtime default is the unchanged delivered recording', () async {
    await play();
    expect(transport.audible.single.rate, 1.0);
  });

  test('pause persists position and resume does not reload ready source', () async {
    await play();
    transport.positions.add(const Duration(seconds: 37));
    await controller.pause();
    expect(controller.state.isPlaying, isFalse);
    expect(store.readProgress(_story(), duration: const Duration(seconds: 100)).position, const Duration(seconds: 37));
    await controller.resume();
    expect(transport.prepared, ['pilot']);
    expect(transport.audible.last.position, const Duration(seconds: 37));
    expect(controller.state.isPlaying, isTrue);
  });

  for (final action in ['pause', 'stop', 'replace', 'dispose', 'external-pause']) {
    test('$action prevents late autoplay from a delayed source', () async {
      await store.acknowledgeWarning(_story());
      await store.acknowledgeWarning(_story(id: 'second'));
      final gate = Completer<void>();
      transport.loadGate = gate;
      final start = controller.playStory(_story());
      await transport.loadStarted.future;
      Future<void> next = Future.value();
      switch (action) {
        case 'pause': next = controller.pause();
        case 'stop': next = controller.stop();
        case 'replace': next = controller.playStory(_story(id: 'second'));
        case 'external-pause': next = transport.pause();
        case 'dispose': controller.dispose();
      }
      gate.complete();
      await Future.wait([start, next]);
      expect(transport.audible.map((entry) => entry.id).toList(), action == 'replace' ? ['second'] : isEmpty);
      if (controller.mounted) expect(controller.state.isLoading, isFalse);
    });
  }

  test('two fast ten-second presses accumulate on the media timeline', () async {
    await play();
    transport.positions.add(const Duration(seconds: 20));
    await Future.wait([
      controller.seekRelative(const Duration(seconds: 10)),
      controller.seekRelative(const Duration(seconds: 10)),
    ]);
    expect(transport.position, const Duration(seconds: 40));
    expect(controller.state.position, const Duration(seconds: 40));
    await controller.seekRelative(const Duration(seconds: -90));
    expect(transport.position, Duration.zero);
    await controller.seekRelative(const Duration(seconds: 200));
    expect(transport.position, const Duration(seconds: 100));
    expect(store.readProgress(_story(), duration: const Duration(seconds: 100)).completed, isFalse);
  });

  test('chapter jump uses measured offsets and ignores unknown chapter', () async {
    await play();
    await controller.jumpToChapter('two');
    expect(controller.state.position, const Duration(seconds: 40));
    await controller.jumpToChapter('missing');
    expect(controller.state.position, const Duration(seconds: 40));
  });

  test('end-of-file marks complete without looping or starting another story', () async {
    await play();
    transport.states.add(PlayerState.completed);
    await controller.flushProgress();
    expect(controller.state.isPlaying, isFalse);
    expect(controller.state.position, const Duration(seconds: 100));
    expect(store.readProgress(_story(), duration: const Duration(seconds: 100)).completed, isTrue);
    expect(transport.audible, hasLength(1));
    await controller.resume();
    expect(transport.audible.last.position, Duration.zero);
  });

  test('new edit starts fresh instead of using old recording position', () async {
    await play();
    transport.positions.add(const Duration(seconds: 60));
    await controller.pause();
    await play(_story(audioVersion: 'mix-2'));
    expect(transport.audible.last.position, Duration.zero);
  });

  for (final kind in ['load', 'start', 'duration']) {
    test('$kind failure is recoverable and never reported as playing', () async {
      transport.failLoad = kind == 'load';
      transport.failStart = kind == 'start';
      if (kind == 'duration') transport.duration = null;
      await play();
      expect(controller.state.errorMessage, isNotNull);
      expect(controller.state.isLoading, isFalse);
      expect(controller.state.isPlaying, isFalse);
      transport.failLoad = false;
      transport.failStart = false;
      transport.duration = const Duration(seconds: 100);
      await controller.resume();
      expect(controller.state.isPlaying, isTrue);
      expect(controller.state.errorMessage, isNull);
    });
  }

  test('playback speed persists only after native operation succeeds', () async {
    await play();
    await controller.setPlaybackRate(1.35);
    expect(controller.state.rate, 1.35);
    expect(store.playbackRate, 1.35);
    transport.failRate = true;
    await controller.setPlaybackRate(1.5);
    expect(store.playbackRate, 1.35);
    expect(controller.state.errorMessage, isNotNull);
    await controller.setPlaybackRate(double.nan);
    expect(store.playbackRate, 1.35);
  });

  test('failed seek reverts optimistic position and preserves checkpoint', () async {
    await play();
    transport.positions.add(const Duration(seconds: 20));
    await controller.flushProgress();
    transport.failSeek = true;
    await controller.seekTo(const Duration(seconds: 80));
    expect(controller.state.position, const Duration(seconds: 20));
    expect(controller.state.errorMessage, isNotNull);
    expect(store.readProgress(_story(), duration: const Duration(seconds: 100)).position, const Duration(seconds: 20));
  });

  test('timer expires by wall clock even with a different playback speed', () async {
    await play();
    await controller.setPlaybackRate(1.5);
    await controller.setSleepTimer(1);
    now = now.add(const Duration(seconds: 59));
    await controller.syncSleepTimerNow();
    expect(controller.state.sleepTimerRemainingSeconds, 1);
    expect(controller.state.isPlaying, isTrue);
    now = now.add(const Duration(seconds: 3));
    await controller.syncSleepTimerNow();
    expect(controller.state.isPlaying, isFalse);
    expect(controller.state.sleepTimerRemainingSeconds, isNull);
    await controller.resume();
    expect(controller.state.isPlaying, isTrue);
  });

  test('timer expiry cancels a load that has not yet become audible', () async {
    await store.acknowledgeWarning(_story());
    final gate = Completer<void>();
    transport.loadGate = gate;
    final start = controller.playStory(_story());
    await transport.loadStarted.future;
    await controller.setSleepTimer(1);
    now = now.add(const Duration(seconds: 62));
    final expiry = controller.syncSleepTimerNow();
    gate.complete();
    await Future.wait([start, expiry]);
    expect(transport.audible, isEmpty);
    expect(controller.state.isPlaying, isFalse);
  });

  test('cancelled timer cannot stop subsequent playback', () async {
    await play();
    await controller.setSleepTimer(1);
    await controller.setSleepTimer(null);
    now = now.add(const Duration(minutes: 2));
    await controller.syncSleepTimerNow();
    expect(controller.state.isPlaying, isTrue);
  });

  test('pause failure attempts stop and reports the transport error', () async {
    await play();
    transport.failPause = true;
    final prior = transport.stopCalls;
    await controller.pause();
    expect(transport.stopCalls, greaterThan(prior));
    expect(controller.state.isPlaying, isFalse);
    expect(controller.state.errorMessage, isNotNull);
  });

  test('failed pause and stop do not falsely claim that playback stopped', () async {
    await play();
    transport.failPause = true;
    transport.failStop = true;
    await controller.pause();
    expect(controller.state.isPlaying, isTrue);
    expect(controller.state.errorMessage, isNotNull);
  });

  for (final type in AudioInterruptionType.values) {
    test('speech interruption $type pauses and applies existing resume policy', () async {
      await play();
      await controller.handleAudioInterruption(AudioInterruptionEvent(true, type));
      expect(controller.state.isPlaying, isFalse);
      await controller.handleAudioInterruption(AudioInterruptionEvent(false, type));
      expect(controller.state.isPlaying, type != AudioInterruptionType.unknown);
    });
  }

  test('manual pause cancels interruption autoresume', () async {
    await play();
    await controller.handleAudioInterruption(AudioInterruptionEvent(true, AudioInterruptionType.pause));
    await controller.pause();
    await controller.handleAudioInterruption(AudioInterruptionEvent(false, AudioInterruptionType.pause));
    expect(controller.state.isPlaying, isFalse);
    expect(transport.audible, hasLength(1));
  });

  test('headphone disconnect pauses and never automatically resumes', () async {
    await play();
    await controller.handleBecomingNoisy();
    await controller.handleAudioInterruption(AudioInterruptionEvent(false, AudioInterruptionType.pause));
    expect(controller.state.isPlaying, isFalse);
    expect(transport.audible, hasLength(1));
  });

  test('progress flush does not need a mounted player screen', () async {
    await play();
    transport.positions.add(const Duration(seconds: 23));
    await controller.flushProgress();
    expect(store.readProgress(_story(), duration: const Duration(seconds: 100)).position, const Duration(seconds: 23));
  });
}
