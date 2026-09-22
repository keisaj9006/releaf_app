import 'dart:async';

import 'package:audio_session/audio_session.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:releaf_app/features/stories/application/audioplayers_story_playback_driver.dart';
import 'package:releaf_app/features/stories/application/story_player_controller.dart';
import 'package:releaf_app/features/stories/data/story_playback_store.dart';
import 'package:releaf_app/features/stories/domain/relief_story.dart';

ReliefStory _story(String id) => ReliefStory(
  id: id,
  title: id,
  subtitle: 'Integration fixture, not bundled audio',
  series: 'Test',
  category: StoryCategory.storiesThatTeach,
  description: 'Fixture',
  estimatedDuration: const Duration(minutes: 28),
  audioAssetPath: 'stories/$id.mp3',
  artworkAssetPath: null,
  contentWarning: '',
  labels: const [],
  isPremium: false,
  chapters: const [],
  rightsStatus: 'TEST ONLY',
  scriptVersion: '2.0',
  audioVersion: 'mix-1',
);

/// Fake only the native plugin boundary; use the real driver AND controller.
class _Native implements AudioPlayer {
  final positions = StreamController<Duration>.broadcast(sync: true);
  final states = StreamController<PlayerState>.broadcast(sync: true);
  final durations = StreamController<Duration>.broadcast(sync: true);
  bool failHalt = false;
  bool failDurationStream = false;
  bool playing = false;
  int sourceLoads = 0;
  Duration cursor = Duration.zero;
  double rate = 1;
  @override
  double volume = 1;

  @override
  Stream<Duration> get onPositionChanged => positions.stream;
  @override
  Stream<Duration> get onDurationChanged => durations.stream;
  @override
  Stream<PlayerState> get onPlayerStateChanged => states.stream;

  @override
  Future<void> pause() async {
    if (failHalt) throw StateError('native pause unavailable');
    playing = false;
    states.add(PlayerState.paused);
  }
  @override
  Future<void> stop() async {
    if (failHalt) throw StateError('native stop unavailable');
    playing = false;
    states.add(PlayerState.stopped);
  }
  @override
  Future<void> resume() async {
    playing = true;
    states.add(PlayerState.playing);
  }
  @override
  Future<void> setReleaseMode(ReleaseMode mode) async {}
  @override
  Future<void> setVolume(double value) async { volume = value; }
  @override
  Future<void> setPlaybackRate(double value) async { rate = value; }
  @override
  Future<void> seek(Duration value) async {
    cursor = value;
    positions.add(value);
  }
  @override
  Future<void> setSource(Source value) async {
    sourceLoads++;
    if (failDurationStream) {
      durations.addError(StateError('native duration event failed'));
    } else {
      durations.add(const Duration(seconds: 100));
    }
  }
  @override
  Future<Duration?> getDuration() async =>
      failDurationStream ? null : const Duration(seconds: 100);
  @override
  Future<void> dispose() async {
    playing = false;
    await positions.close();
    await states.close();
    await durations.close();
  }
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late _Native native;
  late StoryPlaybackStore store;
  late StoryPlayerController controller;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    store = StoryPlaybackStore(await SharedPreferences.getInstance());
    native = _Native();
    controller = StoryPlayerController(
      store: store,
      driver: AudioplayersStoryPlaybackDriver(
        player: native,
        configureSession: () async {},
      ),
    );
  });
  tearDown(() => controller.dispose());

  test('real controller and driver restore and pause the same media timeline', () async {
    await store.saveProgress(_story('first'), position: const Duration(seconds: 37), duration: const Duration(seconds: 100));
    await store.setPlaybackRate(1.2);
    await controller.playStory(_story('first'));
    expect(native.cursor, const Duration(seconds: 37));
    expect(native.rate, 1.2);
    expect(native.playing, isTrue);
    await controller.seekRelative(const Duration(seconds: 10));
    await controller.pause();
    expect(native.playing, isFalse);
    expect(store.readProgress(_story('first'), duration: const Duration(seconds: 100)).position, const Duration(seconds: 47));
  });

  test('failed switch does not overwrite previous story checkpoint with zero', () async {
    await controller.playStory(_story('first'));
    native.positions.add(const Duration(seconds: 37));
    await controller.flushProgress();
    native.failHalt = true;
    await controller.playStory(_story('second'));
    expect(controller.state.story!.id, 'first');
    expect(controller.state.isPlaying, isTrue);
    expect(controller.state.errorMessage, isNotNull);
    expect(native.sourceLoads, 1);
    await controller.flushProgress();
    expect(store.readProgress(_story('first'), duration: const Duration(seconds: 100)).position, const Duration(seconds: 37));
  });

  test('a later unknown interruption cancels earlier resume permission', () async {
    await controller.playStory(_story('first'));
    await controller.handleAudioInterruption(AudioInterruptionEvent(true, AudioInterruptionType.pause));
    await controller.handleAudioInterruption(AudioInterruptionEvent(true, AudioInterruptionType.unknown));
    await controller.handleAudioInterruption(AudioInterruptionEvent(false, AudioInterruptionType.pause));
    expect(controller.state.isPlaying, isFalse);
    expect(native.playing, isFalse);
  });

  test('native duration error becomes a recoverable player error, not an unhandled stream error', () async {
    native.failDurationStream = true;
    await controller.playStory(_story('first')).timeout(const Duration(seconds: 2));
    expect(controller.state.errorMessage, isNotNull);
    expect(controller.state.isLoading, isFalse);
    expect(native.playing, isFalse);
    native.failDurationStream = false;
    await controller.resume();
    expect(controller.state.isPlaying, isTrue);
  });
}
