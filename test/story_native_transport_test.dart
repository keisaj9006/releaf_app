import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:releaf_app/features/stories/application/audioplayers_story_playback_driver.dart';
import 'package:releaf_app/features/stories/domain/relief_story.dart';

const _story = ReliefStory(
  id: 'native-fixture', title: 'Test', subtitle: 'Test', series: 'Test',
  category: StoryCategory.storiesThatTeach, description: 'Fixture only',
  estimatedDuration: Duration(minutes: 28), audioAssetPath: 'stories/fixture.mp3',
  artworkAssetPath: null, contentWarning: '', labels: [], isPremium: false,
  chapters: [], rightsStatus: 'TEST ONLY', scriptVersion: '2.0', audioVersion: '1',
);

class _Player implements AudioPlayer {
  final events = StreamController<PlayerState>.broadcast(sync: true);
  final durations = StreamController<Duration>.broadcast(sync: true);
  final positions = StreamController<Duration>.broadcast(sync: true);
  final operations = <String>[];
  final audibleStarts = <({Duration position, double rate})>[];
  final reached = Completer<void>();
  Completer<void>? gate;
  String? delayed;
  String? failed;
  Duration? length = const Duration(seconds: 100);
  Duration cursor = Duration.zero;
  double rate = 1;
  double volume = 1;
  bool playing = false;

  Future<void> operation(String name) async {
    operations.add(name);
    if (name == delayed) {
      if (!reached.isCompleted) reached.complete();
      await gate?.future;
    }
    if (name == failed) throw StateError('native $name failed');
  }
  @override
  Stream<Duration> get onDurationChanged => durations.stream;
  @override
  Stream<Duration> get onPositionChanged => positions.stream;
  @override
  Stream<PlayerState> get onPlayerStateChanged => events.stream;
  @override
  Future<void> setReleaseMode(ReleaseMode mode) => operation('mode:$mode');
  @override
  Future<void> stop() async { await operation('stop'); playing = false; events.add(PlayerState.stopped); }
  @override
  Future<void> pause() async { await operation('pause'); playing = false; events.add(PlayerState.paused); }
  @override
  Future<void> setSource(Source source) async { await operation('source'); if (length != null) durations.add(length!); }
  @override
  Future<Duration?> getDuration() async => length;
  @override
  Future<void> resume() async { await operation('resume'); playing = true; events.add(PlayerState.playing); }
  @override
  Future<void> setPlaybackRate(double value) async { await operation('rate'); rate = value; }
  @override
  Future<void> seek(Duration value) async { await operation('seek'); cursor = value; positions.add(value); }
  @override
  Future<void> setVolume(double value) async {
    await operation(value == 0 ? 'mute' : 'unmute');
    volume = value;
    if (value > 0 && playing) audibleStarts.add((position: cursor, rate: rate));
  }
  @override
  Future<void> dispose() async { playing = false; await events.close(); await durations.close(); await positions.close(); }
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('preparation is silent, stop-mode and uses actual native duration', () async {
    final player = _Player();
    var sessions = 0;
    final driver = AudioplayersStoryPlaybackDriver(player: player, configureSession: () async { sessions++; });
    addTearDown(driver.dispose);
    expect(await driver.prepare(_story), const Duration(seconds: 100));
    expect(sessions, 1);
    expect(player.operations, contains('mode:ReleaseMode.stop'));
    expect(player.operations, isNot(contains('resume')));
    expect(player.audibleStarts, isEmpty);
    await driver.startAt(const Duration(seconds: 35), 1.2);
    expect(player.audibleStarts.single, (position: const Duration(seconds: 35), rate: 1.2));
  });

  for (final step in ['source', 'resume', 'rate', 'seek']) {
    test('pause during $step prevents later audible autoplay', () async {
      final player = _Player();
      final driver = AudioplayersStoryPlaybackDriver(player: player, configureSession: () async {});
      addTearDown(driver.dispose);
      if (step != 'source') await driver.prepare(_story);
      player.delayed = step;
      final gate = player.gate = Completer<void>();
      final pending = step == 'source'
          ? driver.prepare(_story)
          : driver.startAt(const Duration(seconds: 35), 1.2);
      await player.reached.future;
      final pausing = driver.pause();
      gate.complete();
      await Future.wait<Object?>([pending, pausing]);
      expect(player.audibleStarts, isEmpty);
      expect(player.playing, isFalse);
    });
  }

  test('failed native priming stays muted and stops playback', () async {
    final player = _Player();
    final driver = AudioplayersStoryPlaybackDriver(player: player, configureSession: () async {});
    addTearDown(driver.dispose);
    await driver.prepare(_story);
    player.failed = 'rate';
    await expectLater(driver.startAt(const Duration(seconds: 20), 1.2), throwsStateError);
    expect(player.audibleStarts, isEmpty);
    expect(player.playing, isFalse);
  });

  test('cancelled duration wait finishes without an estimated-length fallback', () async {
    final player = _Player()..length = null;
    final driver = AudioplayersStoryPlaybackDriver(player: player, configureSession: () async {});
    addTearDown(driver.dispose);
    final loading = driver.prepare(_story);
    await Future<void>.delayed(Duration.zero);
    await driver.pause();
    expect(await loading, isNull);
    expect(player.audibleStarts, isEmpty);
  });
}
