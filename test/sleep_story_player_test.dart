import 'dart:async';

import 'package:audioplayers/audioplayers.dart' as audio;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:releaf_app/features/sleep/application/sleep_progress_store.dart';
import 'package:releaf_app/features/sleep/presentation/sleep_story_player_screen.dart';
import 'package:releaf_app/features/sound/application/sound_player_controller.dart';
import 'package:releaf_app/features/sound/data/sound_catalog.dart';
import 'package:releaf_app/features/stories/data/story_catalog.dart';
import 'package:releaf_app/features/stories/domain/relief_story.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _StoryDriver implements SoundPlaybackDriver {
  final durations = StreamController<Duration>.broadcast(sync: true);
  final positions = StreamController<Duration>.broadcast(sync: true);
  final states = StreamController<audio.PlayerState>.broadcast(sync: true);
  final seeks = <Duration>[];
  int playCalls = 0;
  bool failPlay = false;
  Completer<void>? playGate;

  @override
  Stream<Duration> get onDurationChanged => durations.stream;
  @override
  Stream<Duration> get onPositionChanged => positions.stream;
  @override
  Stream<audio.PlayerState> get onPlayerStateChanged => states.stream;
  @override
  Future<void> setReleaseMode(audio.ReleaseMode mode) async {}
  @override
  Future<void> setVolume(double volume) async {}
  @override
  Future<void> playAsset(
    String assetPath, {
    String? trackId,
    String? title,
  }) async {
    playCalls++;
    final gate = playGate;
    playGate = null;
    if (gate != null) await gate.future;
    if (failPlay) throw StateError('private native failure');
    durations.add(const Duration(minutes: 20));
    states.add(audio.PlayerState.playing);
  }

  @override
  Future<void> resume() async => states.add(audio.PlayerState.playing);
  @override
  Future<void> pause() async => states.add(audio.PlayerState.paused);
  @override
  Future<void> stop() async => states.add(audio.PlayerState.stopped);
  @override
  Future<void> seek(Duration position) async {
    seeks.add(position);
    positions.add(position);
  }

  @override
  Future<void> dispose() async {
    await durations.close();
    await positions.close();
    await states.close();
  }
}

const playableStory = ReliefStory(
  id: 'playable-story',
  title: 'The Quiet Garden',
  subtitle: 'A gentle story for the end of the day.',
  series: 'Dream Classics',
  category: null,
  description: 'A calm walk through a moonlit garden.',
  estimatedDuration: Duration(minutes: 20),
  audioAssetPath: 'sounds/story.mp3',
  artworkAssetPath: null,
  contentWarning: '',
  labels: <String>['DREAM CLASSICS'],
  isPremium: false,
  chapters: <ReliefStoryChapter>[
    ReliefStoryChapter(id: 'arrival', title: 'Arrival', start: Duration.zero),
    ReliefStoryChapter(
      id: 'garden',
      title: 'The Garden',
      start: Duration(minutes: 1),
    ),
  ],
  rightsStatus: 'TEST ONLY',
  scriptVersion: 'test',
  audioVersion: 'test',
  sleepCollection: SleepStoryCollection.dreamClassics,
  narrator: 'Theo Silk',
);

Future<({ProviderContainer container, SleepProgressStore progress})>
_pumpPlayer(
  WidgetTester tester, {
  required ReliefStory story,
  required _StoryDriver driver,
  Size size = const Size(390, 844),
  double textScale = 1,
  SleepProgressStore? progress,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  SharedPreferences.setMockInitialValues({});
  final preferences = await SharedPreferences.getInstance();
  final effectiveProgress = progress ?? SleepProgressStore(preferences);
  final container = ProviderContainer(
    overrides: [
      storyByIdProvider.overrideWith(
        (ref, id) => id == story.id ? story : null,
      ),
      sleepProgressStoreProvider.overrideWith((ref) => effectiveProgress),
      soundPlayerControllerProvider.overrideWith(
        (ref) => SoundPlayerController(
          const SoundCatalog(),
          preferences,
          driver: driver,
        ),
      ),
    ],
  );
  addTearDown(container.dispose);

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(textScaler: TextScaler.linear(textScale)),
          child: SleepStoryPlayerScreen(storyId: story.id),
        ),
      ),
    ),
  );
  await tester.pump();
  return (container: container, progress: effectiveProgress);
}

void main() {
  test('Story access respects explicit Premium assignment', () {
    expect(canAccessSleepStory(playableStory, isPremiumUser: false), isTrue);
    const premium = ReliefStory(
      id: 'premium',
      title: 'Premium',
      subtitle: 'Premium',
      series: 'Dream Classics',
      category: null,
      description: 'Premium',
      estimatedDuration: Duration(minutes: 10),
      audioAssetPath: 'sounds/premium.mp3',
      artworkAssetPath: null,
      contentWarning: '',
      labels: <String>[],
      isPremium: true,
      chapters: <ReliefStoryChapter>[],
      rightsStatus: 'TEST ONLY',
      scriptVersion: 'test',
      audioVersion: 'test',
    );
    expect(canAccessSleepStory(premium, isPremiumUser: false), isFalse);
    expect(canAccessSleepStory(premium, isPremiumUser: true), isTrue);
  });

  testWidgets('asset-pending Story is honest and never starts playback', (
    tester,
  ) async {
    final driver = _StoryDriver();
    final story = StoryCatalog.getById('ST-DC-004')!;
    await _pumpPlayer(tester, story: story, driver: driver);

    expect(find.text(story.title), findsOneWidget);
    expect(find.text('Theo Silk'), findsOneWidget);
    expect(find.byKey(const Key('story-audio-pending')), findsOneWidget);
    expect(find.byKey(const Key('story-play-pause')), findsNothing);
    expect(driver.playCalls, 0);
    expect(tester.takeException(), isNull);
  });

  testWidgets('player restores progress and seeks exactly ten seconds', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final progress = SleepProgressStore(preferences);
    await progress.updatePosition(
      contentId: playableStory.id,
      position: const Duration(seconds: 75),
      duration: const Duration(minutes: 20),
      chapterId: 'garden',
    );
    final driver = _StoryDriver();
    await _pumpPlayer(
      tester,
      story: playableStory,
      driver: driver,
      progress: progress,
    );
    await tester.pump();

    expect(driver.seeks.first, const Duration(seconds: 75));
    expect(find.text('The Garden'), findsWidgets);
    expect(find.text('1:15'), findsOneWidget);

    await tester.tap(find.byKey(const Key('story-seek-back')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('story-seek-forward')));
    await tester.pump();

    expect(
      driver.seeks,
      containsAllInOrder(<Duration>[
        const Duration(seconds: 65),
        const Duration(seconds: 75),
      ]),
    );
  });

  testWidgets('loading failure is recoverable without native details', (
    tester,
  ) async {
    final driver = _StoryDriver()..failPlay = true;
    await _pumpPlayer(tester, story: playableStory, driver: driver);
    await tester.pump();

    expect(find.byKey(const Key('story-playback-error')), findsOneWidget);
    expect(find.textContaining('private native'), findsNothing);

    driver.failPlay = false;
    await tester.tap(find.byKey(const Key('story-retry')));
    await tester.pump();

    expect(driver.playCalls, 2);
    expect(find.byKey(const Key('story-playback-error')), findsNothing);
  });

  testWidgets('loading state disables playback until the Story is ready', (
    tester,
  ) async {
    final gate = Completer<void>();
    final driver = _StoryDriver()..playGate = gate;
    await _pumpPlayer(tester, story: playableStory, driver: driver);

    expect(find.text('LOADING'), findsOneWidget);
    final playButton = tester.widget<FilledButton>(
      find.byKey(const Key('story-play-pause')),
    );
    expect(playButton.onPressed, isNull);

    gate.complete();
    await tester.pump();
    expect(find.text('PLAYING'), findsOneWidget);
  });

  testWidgets('finite completion persists a completed Story record', (
    tester,
  ) async {
    final driver = _StoryDriver();
    final result = await _pumpPlayer(
      tester,
      story: playableStory,
      driver: driver,
    );
    driver.positions.add(const Duration(minutes: 20));
    driver.states.add(audio.PlayerState.completed);
    await tester.pump();

    final record = result.progress.recordFor(playableStory.id);
    expect(record?.isCompleted, isTrue);
    expect(record?.position, const Duration(minutes: 20));
    expect(record?.chapterId, 'garden');
  });

  testWidgets('lifecycle transition persists the latest Story position', (
    tester,
  ) async {
    final driver = _StoryDriver();
    final result = await _pumpPlayer(
      tester,
      story: playableStory,
      driver: driver,
    );
    await tester.pump();
    driver.positions.add(const Duration(minutes: 4));
    await tester.pump();

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();

    expect(
      result.progress.recordFor(playableStory.id)?.position,
      const Duration(minutes: 4),
    );
  });

  testWidgets('Story player remains usable at 320px with large text', (
    tester,
  ) async {
    await _pumpPlayer(
      tester,
      story: playableStory,
      driver: _StoryDriver(),
      size: const Size(320, 640),
      textScale: 2,
    );
    await tester.pump();

    expect(find.byKey(const Key('story-player-scroll')), findsOneWidget);
    expect(find.byKey(const Key('story-play-pause')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
