import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:releaf_app/core/audio/relief_shared_audio_handler.dart';
import 'package:releaf_app/features/sound/application/sound_player_controller.dart';
import 'package:releaf_app/features/stories/application/audioplayers_story_playback_driver.dart';
import 'package:releaf_app/features/stories/data/story_playback_store.dart';
import 'package:releaf_app/features/stories/domain/relief_story.dart';

ReliefStory _story({String id = 'pilot', String warning = '', String? path = 'stories/test-only.mp3'}) => ReliefStory(
  id: id, title: 'Test narration', subtitle: 'Not a bundled recording',
  series: 'Test', category: StoryCategory.storiesThatTeach, description: 'Fixture',
  estimatedDuration: const Duration(minutes: 28), audioAssetPath: path,
  artworkAssetPath: null, contentWarning: warning, labels: const [], isPremium: false,
  chapters: const [], rightsStatus: 'TEST ONLY', scriptVersion: '2.0', audioVersion: 'mix-1',
);

// Fake only the native plugin boundary. Both production drivers and controllers
// participate, so observing two audible sources catches a real coordination bug.
class _Native implements AudioPlayer {
  final positions = StreamController<Duration>.broadcast(sync: true);
  final durations = StreamController<Duration>.broadcast(sync: true);
  final states = StreamController<PlayerState>.broadcast(sync: true);
  final sourceStarted = Completer<void>();
  Completer<void>? sourceGate;
  Completer<void>? stopGate;
  final stopStarted = Completer<void>();
  final held = <Completer<void>>[];
  bool failHalt = false;
  bool playing = false;
  int loads = 0;
  int audibleStarts = 0;
  double rate = 1;
  ReleaseMode? releaseModeSeen;
  Duration cursor = Duration.zero;
  void Function()? checkAudibility;
  @override
  double volume = 1;
  @override
  Stream<Duration> get onPositionChanged => positions.stream;
  @override
  Stream<Duration> get onDurationChanged => durations.stream;
  @override
  Stream<PlayerState> get onPlayerStateChanged => states.stream;
  @override
  Future<void> setSource(Source source) async {
    final gate = sourceGate;
    sourceGate = null;
    if (!sourceStarted.isCompleted) sourceStarted.complete();
    if (gate != null) { held.add(gate); await gate.future; }
    loads++;
    durations.add(const Duration(seconds: 100));
  }
  @override
  Future<Duration?> getDuration() async => const Duration(seconds: 100);
  @override
  Future<void> resume() async {
    playing = true;
    if (volume > 0) audibleStarts++;
    checkAudibility?.call();
    states.add(PlayerState.playing);
  }
  @override
  Future<void> pause() async {
    if (failHalt) throw StateError('Native pause failed');
    playing = false;
    states.add(PlayerState.paused);
  }
  @override
  Future<void> stop() async {
    final gate = stopGate;
    stopGate = null;
    if (gate != null) {
      held.add(gate);
      if (!stopStarted.isCompleted) stopStarted.complete();
      await gate.future;
    }
    if (failHalt) throw StateError('Native stop failed');
    playing = false;
    states.add(PlayerState.stopped);
  }
  @override
  Future<void> setVolume(double value) async {
    if (playing && volume == 0 && value > 0) audibleStarts++;
    volume = value;
    checkAudibility?.call();
  }
  @override
  Future<void> setPlaybackRate(double value) async { rate = value; }
  @override
  Future<void> setReleaseMode(ReleaseMode value) async { releaseModeSeen = value; }
  @override
  Future<void> seek(Duration value) async { cursor = value; positions.add(value); }
  @override
  Future<void> dispose() async {
    playing = false;
    await positions.close(); await durations.close(); await states.close();
  }
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late _Native sound;
  late _Native story;
  late ReliefSharedAudioHandler handler;
  late StoryPlaybackStore store;
  late DateTime now;
  late bool overlapped;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    store = StoryPlaybackStore(prefs);
    now = DateTime(2026, 9, 22, 22);
    sound = _Native(); story = _Native(); overlapped = false;
    void check() {
      if (sound.playing && sound.volume > 0 && story.playing && story.volume > 0) {
        overlapped = true;
      }
    }
    sound.checkAudibility = check; story.checkAudibility = check;
    handler = ReliefSharedAudioHandler(
      preferences: prefs,
      soundDriver: AudioplayersSoundPlaybackDriver(player: sound),
      storyDriver: AudioplayersStoryPlaybackDriver(player: story, configureSession: () async {}),
      configureSoundSession: () async {}, now: () => now,
    );
  });
  tearDown(() async {
    sound.failHalt = false; story.failHalt = false;
    for (final gate in [...sound.held, ...story.held]) {
      if (!gate.isCompleted) gate.complete();
    }
    await handler.close();
  });

  test('Story takes audible ownership from Sound without overlap', () async {
    await handler.sound.playById('deep-drift');
    await handler.stories.playStory(_story());
    expect(sound.playing, isFalse);
    expect(story.playing, isTrue);
    expect(overlapped, isFalse);
    expect(handler.owner, ReliefMediaOwner.story);
    expect(handler.sound.state.currentTrackId, isNull);
  });

  test('Sound takes ownership and Story resumes its own position and rate', () async {
    await handler.stories.playStory(_story());
    await handler.stories.seekTo(const Duration(seconds: 37));
    await handler.stories.setPlaybackRate(1.2);
    await handler.sound.playById('soft-rain');
    expect(story.playing, isFalse);
    expect(sound.playing, isTrue);
    expect(sound.releaseModeSeen, ReleaseMode.loop);
    expect(sound.rate, 1.0);
    expect(handler.owner, ReliefMediaOwner.sound);
    expect(store.readProgress(_story(), duration: const Duration(seconds: 100)).position, const Duration(seconds: 37));
    await handler.stories.resume();
    expect(story.cursor, const Duration(seconds: 37));
    expect(story.rate, 1.2);
    expect(story.releaseModeSeen, ReleaseMode.stop);
    expect(overlapped, isFalse);
  });

  test('warning and unavailable delivery do not steal Sound ownership', () async {
    await handler.sound.playById('deep-drift');
    await handler.stories.playStory(_story(warning: 'Wartime imprisonment.'));
    expect(handler.stories.state.warningRequired, isTrue);
    expect(story.loads, 0);
    expect(sound.playing, isTrue);
    expect(handler.owner, ReliefMediaOwner.sound);
    await handler.stories.playStory(_story(path: null));
    expect(handler.stories.state.isAudioUnavailable, isTrue);
    expect(sound.playing, isTrue);
    expect(story.loads, 0);
  });

  for (final action in ['pause', 'stop', 'sound']) {
    test('media $action cancels Story while native source is delayed', () async {
      final gate = story.sourceGate = Completer<void>();
      final loading = handler.stories.playStory(_story());
      await story.sourceStarted.future;
      final next = switch (action) {
        'pause' => handler.pause(),
        'stop' => handler.stop(),
        _ => handler.sound.playById('deep-drift'),
      };
      gate.complete();
      await Future.wait([loading, next]);
      expect(story.audibleStarts, 0);
      expect(story.playing, isFalse);
      expect(sound.playing, action == 'sound');
      expect(overlapped, isFalse);
    });
  }

  test('Story cancels delayed Sound source before any sound is emitted', () async {
    final gate = sound.sourceGate = Completer<void>();
    final loading = handler.sound.playById('deep-drift');
    await sound.sourceStarted.future;
    final replacement = handler.stories.playStory(_story());
    await Future<void>.delayed(Duration.zero);
    gate.complete();
    await Future.wait([loading, replacement]);
    expect(sound.audibleStarts, 0);
    expect(story.playing, isTrue);
    expect(overlapped, isFalse);
  });

  test('stop during a delayed handoff cannot be undone by the older request', () async {
    await handler.stories.playStory(_story());
    final gate = story.stopGate = Completer<void>();
    final replacing = handler.sound.playById('deep-drift');
    await story.stopStarted.future.timeout(const Duration(seconds: 2));
    final stopping = handler.stop();
    gate.complete();
    await Future.wait([replacing, stopping]);
    expect(sound.playing, isFalse);
    expect(story.playing, isFalse);
    expect(handler.owner, ReliefMediaOwner.none);
    await handler.play();
    expect(sound.playing, isFalse);
    expect(story.playing, isFalse);
  });

  test('notification metadata uses actual media time and selected Story speed', () async {
    await handler.stories.playStory(_story());
    await handler.seek(const Duration(seconds: 30));
    await handler.setSpeed(1.35);
    await handler.fastForward();
    expect(story.cursor, const Duration(seconds: 40));
    expect(handler.mediaItem.value!.id, 'story:pilot');
    expect(handler.mediaItem.value!.duration, const Duration(seconds: 100));
    expect(handler.playbackState.value.speed, 1.35);
    expect(handler.playbackState.value.updatePosition, const Duration(seconds: 40));
    expect(handler.playbackState.value.repeatMode, AudioServiceRepeatMode.none);
    await handler.rewind();
    expect(story.cursor, const Duration(seconds: 30));
    await handler.pause();
    expect(handler.playbackState.value.playing, isFalse);
    await handler.play();
    expect(story.playing, isTrue);
  });

  test('inactive Story events cannot replace Sound notification metadata', () async {
    await handler.stories.playStory(_story());
    await handler.sound.playById('deep-drift');
    story.states.add(PlayerState.completed);
    story.positions.add(const Duration(seconds: 100));
    expect(handler.mediaItem.value!.id, 'sound:deep-drift');
    expect(handler.playbackState.value.repeatMode, AudioServiceRepeatMode.one);
    expect(handler.playbackState.value.speed, 1.0);
  });

  test('failed Story shutdown blocks Sound instead of allowing two sources', () async {
    await handler.stories.playStory(_story());
    story.failHalt = true;
    await handler.sound.playById('deep-drift');
    expect(story.playing, isTrue);
    expect(sound.loads, 0);
    expect(handler.sound.state.hasPlaybackError, isTrue);
    expect(overlapped, isFalse);
  });

  test('failed Sound shutdown blocks Story instead of allowing two sources', () async {
    await handler.sound.playById('deep-drift');
    sound.failHalt = true;
    await handler.stories.playStory(_story());
    expect(sound.playing, isTrue);
    expect(story.loads, 0);
    expect(handler.stories.state.errorMessage, isNotNull);
    expect(overlapped, isFalse);
  });

  test('notification pause during interruption prevents automatic resume', () async {
    await handler.stories.playStory(_story());
    await handler.handleAudioInterruption(AudioInterruptionEvent(true, AudioInterruptionType.pause));
    await handler.pause();
    await handler.handleAudioInterruption(AudioInterruptionEvent(false, AudioInterruptionType.pause));
    expect(story.playing, isFalse);
  });

  test('headphone disconnect works with no player screen mounted', () async {
    await handler.stories.playStory(_story());
    await handler.handleBecomingNoisy();
    expect(story.playing, isFalse);
    expect(handler.playbackState.value.playing, isFalse);
  });

  test('app resume expires Story wall-clock timer without a player screen', () async {
    await handler.stories.playStory(_story());
    await handler.stories.setSleepTimer(1);
    now = now.add(const Duration(seconds: 61));
    await handler.onAppResumed();
    expect(story.playing, isFalse);
    expect(handler.stories.state.sleepTimerRemainingSeconds, isNull);
  });
}
