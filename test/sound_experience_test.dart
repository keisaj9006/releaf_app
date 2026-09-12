import 'dart:io';
import 'dart:async';

import 'package:audioplayers/audioplayers.dart' as audio;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:releaf_app/core/providers.dart';
import 'package:releaf_app/features/meditation/presentation/meditation_player_screen.dart';
import 'package:releaf_app/features/sound/application/sound_player_controller.dart';
import 'package:releaf_app/features/sound/data/sound_catalog.dart';
import 'package:releaf_app/features/sound/presentation/sound_player_gate.dart';
import 'package:releaf_app/features/sound/presentation/sound_screen.dart';
import 'package:releaf_app/routing/app_router.dart';
import 'package:releaf_app/routing/app_routes.dart';

class _FakeSoundPlaybackDriver implements SoundPlaybackDriver {
  final List<double> volumeCalls = <double>[];
  int pauseCalls = 0;
  int resumeCalls = 0;
  String? lastAssetPath;
  String? lastTrackId;
  String? lastTitle;
  Completer<void>? nextVolumeGate;
  Completer<void>? volumeStarted;
  Completer<void>? nextPauseGate;
  Completer<void>? pauseStarted;
  Completer<void>? nextStopGate;
  Completer<void>? stopStarted;
  Completer<void>? nextPlayGate;
  Completer<void>? playStarted;
  final List<String> playedTrackIds = [];

  @override
  Stream<Duration> get onDurationChanged => const Stream<Duration>.empty();

  @override
  Stream<Duration> get onPositionChanged => const Stream<Duration>.empty();

  @override
  Stream<audio.PlayerState> get onPlayerStateChanged =>
      const Stream<audio.PlayerState>.empty();

  @override
  Future<void> setReleaseMode(audio.ReleaseMode mode) async {}

  @override
  Future<void> setVolume(double volume) async {
    final gate = nextVolumeGate;
    nextVolumeGate = null;
    if (gate != null) {
      volumeStarted?.complete();
      await gate.future;
    }
    volumeCalls.add(volume);
  }

  @override
  Future<void> playAsset(
    String assetPath, {
    String? trackId,
    String? title,
  }) async {
    final gate = nextPlayGate;
    nextPlayGate = null;
    if (gate != null) {
      playStarted?.complete();
      await gate.future;
    }
    lastAssetPath = assetPath;
    lastTrackId = trackId;
    lastTitle = title;
    playedTrackIds.add(trackId ?? assetPath);
  }

  @override
  Future<void> resume() async {
    resumeCalls += 1;
  }

  @override
  Future<void> pause() async {
    final gate = nextPauseGate;
    nextPauseGate = null;
    if (gate != null) {
      pauseStarted?.complete();
      await gate.future;
    }
    pauseCalls += 1;
  }

  @override
  Future<void> stop() async {
    final gate = nextStopGate;
    nextStopGate = null;
    if (gate != null) {
      stopStarted?.complete();
      await gate.future;
    }
  }

  @override
  Future<void> seek(Duration position) async {}

  @override
  Future<void> dispose() async {}
}

Future<SharedPreferences> _preferences() async {
  SharedPreferences.setMockInitialValues({});
  return SharedPreferences.getInstance();
}

class _StatefulSoundDriver extends _FakeSoundPlaybackDriver {
  final events = StreamController<audio.PlayerState>.broadcast(sync: true);
  @override
  Stream<audio.PlayerState> get onPlayerStateChanged => events.stream;
  @override
  Future<void> playAsset(String path, {String? trackId, String? title}) async {
    await super.playAsset(path, trackId: trackId, title: title);
    events.add(audio.PlayerState.playing);
  }

  @override
  Future<void> pause() async {
    await super.pause();
    events.add(audio.PlayerState.paused);
  }

  @override
  Future<void> resume() async {
    await super.resume();
    events.add(audio.PlayerState.playing);
  }

  @override
  Future<void> dispose() => events.close();
}

void main() {
  testWidgets('Meditation cancels Sound that is still preparing', (
    tester,
  ) async {
    final preferences = await _preferences();
    final gate = Completer<void>();
    final started = Completer<void>();
    final driver = _FakeSoundPlaybackDriver()
      ..nextVolumeGate = gate
      ..volumeStarted = started;
    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(preferences),
        soundPlaybackDriverProvider.overrideWithValue(driver),
      ],
    );
    addTearDown(container.dispose);
    final controller = container.read(soundPlayerControllerProvider.notifier);
    final loading = controller.playById('deep-drift');
    await started.future;
    expect(container.read(soundPlayerControllerProvider).isLoading, isTrue);
    expect(container.read(soundPlayerControllerProvider).isPlaying, isFalse);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          home: MeditationPlayerScreen(meditationId: 'unguided-5'),
        ),
      ),
    );
    await tester.pump();
    gate.complete();
    await loading;
    await tester.pump();
    expect(driver.playedTrackIds, isEmpty);
    expect(container.read(soundPlayerControllerProvider).isLoading, isFalse);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  test('an expired Sleep timer cannot pause a newer track start', () async {
    final driver = _StatefulSoundDriver();
    var now = DateTime(2026, 9, 11, 22);
    final controller = SoundPlayerController(
      const SoundCatalog(),
      await _preferences(),
      driver: driver,
      now: () => now,
    );
    addTearDown(controller.dispose);
    await controller.playById('deep-drift');
    await controller.setSleepTimer(1);
    now = now.add(const Duration(seconds: 61));
    final gate = Completer<void>();
    driver.nextVolumeGate = gate;
    driver.volumeStarted = Completer<void>();
    final expiring = controller.syncSleepTimerNow();
    await driver.volumeStarted!.future;
    await controller.playById('soft-rain');
    gate.complete();
    await expiring;
    expect(controller.state.currentTrackId, 'soft-rain');
    expect(controller.state.isPlaying, isTrue);
    expect(controller.state.sleepTimerMinutes, isNull);
    expect(driver.pauseCalls, 0);
    expect(driver.volumeCalls.last, controller.state.volume);
  });

  test('latest Sound track wins delayed startup configuration', () async {
    final driver = _FakeSoundPlaybackDriver();
    final preferences = await _preferences();
    final controller = SoundPlayerController(
      const SoundCatalog(),
      preferences,
      driver: driver,
    );
    addTearDown(controller.dispose);
    final gate = Completer<void>();
    driver.nextVolumeGate = gate;
    driver.volumeStarted = Completer<void>();
    final first = controller.playById('deep-drift');
    await driver.volumeStarted!.future;
    await controller.playById('soft-rain');
    gate.complete();
    await first;
    expect(controller.state.currentTrackId, 'soft-rain');
    expect(driver.playedTrackIds, ['soft-rain']);
    expect(preferences.getStringList('sound.recent_ids'), ['soft-rain']);
  });

  for (final action in ['pause', 'stop', 'dispose']) {
    test('$action cancels Sound startup during configuration', () async {
      final driver = _FakeSoundPlaybackDriver();
      final controller = SoundPlayerController(
        const SoundCatalog(),
        await _preferences(),
        driver: driver,
      );
      if (action != 'dispose') addTearDown(controller.dispose);
      final gate = Completer<void>();
      driver.nextVolumeGate = gate;
      driver.volumeStarted = Completer<void>();
      final first = controller.playById('deep-drift');
      await driver.volumeStarted!.future;
      if (action == 'pause') await controller.pause();
      if (action == 'stop') await controller.stop();
      if (action == 'dispose') controller.dispose();
      gate.complete();
      await first;
      expect(driver.playedTrackIds, isEmpty);
    });
  }

  test('a late stop cannot clear the new Sound selection', () async {
    final driver = _FakeSoundPlaybackDriver();
    final controller = SoundPlayerController(
      const SoundCatalog(),
      await _preferences(),
      driver: driver,
    );
    addTearDown(controller.dispose);
    await controller.playById('deep-drift');
    final gate = Completer<void>();
    driver.nextStopGate = gate;
    driver.stopStarted = Completer<void>();
    final stopping = controller.stop();
    await driver.stopStarted!.future;
    await controller.playById('soft-rain');
    gate.complete();
    await stopping;
    expect(controller.state.currentTrackId, 'soft-rain');
    expect(driver.lastTrackId, 'soft-rain');
  });

  test(
    'paused source loading cannot enter recents or count as ready to resume',
    () async {
      final driver = _FakeSoundPlaybackDriver();
      final controller = SoundPlayerController(
        const SoundCatalog(),
        await _preferences(),
        driver: driver,
      );
      addTearDown(controller.dispose);
      final gate = Completer<void>();
      driver.nextPlayGate = gate;
      driver.playStarted = Completer<void>();
      final first = controller.playById('deep-drift');
      await driver.playStarted!.future;
      await controller.pause();
      expect(driver.pauseCalls, 1);
      gate.complete();
      await first;
      expect(controller.state.recentIds, isEmpty);
      await controller.resume();
      expect(driver.playedTrackIds, ['deep-drift', 'deep-drift']);
      expect(driver.resumeCalls, 0);
      expect(controller.state.recentIds, ['deep-drift']);
    },
  );

  test('latest slider volume wins an earlier delayed output write', () async {
    final driver = _FakeSoundPlaybackDriver();
    final preferences = await _preferences();
    final controller = SoundPlayerController(
      const SoundCatalog(),
      preferences,
      driver: driver,
    );
    addTearDown(controller.dispose);
    await controller.playById('deep-drift');
    final gate = Completer<void>();
    driver.nextVolumeGate = gate;
    driver.volumeStarted = Completer<void>();
    final first = controller.setVolume(0.8);
    await driver.volumeStarted!.future;
    await controller.setVolume(0.1);
    gate.complete();
    await first;
    expect(driver.volumeCalls.last, 0.1);
    expect(controller.state.volume, 0.1);
    expect(preferences.getDouble('sound.volume.v1'), 0.1);
  });

  test('a delayed fade respects the newest base volume', () async {
    final driver = _FakeSoundPlaybackDriver();
    var now = DateTime(2026, 9, 11, 22);
    final controller = SoundPlayerController(
      const SoundCatalog(),
      await _preferences(),
      driver: driver,
      now: () => now,
    );
    addTearDown(controller.dispose);
    await controller.playById('deep-drift');
    await controller.setSleepTimer(1);
    now = now.add(const Duration(seconds: 50));
    final gate = Completer<void>();
    driver.nextVolumeGate = gate;
    driver.volumeStarted = Completer<void>();
    final fading = controller.syncSleepTimerNow();
    await driver.volumeStarted!.future;
    await controller.setVolume(0.2);
    gate.complete();
    await fading;
    expect(driver.volumeCalls.last, closeTo(0.1, 0.0001));
    expect(controller.state.volume, 0.2);
  });

  for (final replacement in [30, null]) {
    test('old Sleep fade cannot silence replacement $replacement', () async {
      final driver = _FakeSoundPlaybackDriver();
      var now = DateTime(2026, 9, 11, 22);
      final controller = SoundPlayerController(
        const SoundCatalog(),
        await _preferences(),
        driver: driver,
        now: () => now,
      );
      addTearDown(controller.dispose);
      await controller.playById('deep-drift');
      await controller.setSleepTimer(1);
      now = now.add(const Duration(seconds: 59));
      final gate = Completer<void>();
      driver.nextVolumeGate = gate;
      driver.volumeStarted = Completer<void>();
      final fading = controller.syncSleepTimerNow();
      await driver.volumeStarted!.future;
      await controller.setSleepTimer(replacement);
      gate.complete();
      await fading;
      expect(driver.volumeCalls.last, controller.state.volume);
    });
  }
  for (final manualPause in [false, true]) {
    test(
      'replacement Sleep timer recovers late expiry pause unless user paused: $manualPause',
      () async {
        final driver = _StatefulSoundDriver();
        var now = DateTime(2026, 9, 11, 22);
        final controller = SoundPlayerController(
          const SoundCatalog(),
          await _preferences(),
          driver: driver,
          now: () => now,
        );
        addTearDown(controller.dispose);
        await controller.playById('deep-drift');
        await controller.setSleepTimer(1);
        now = now.add(const Duration(minutes: 2));
        final gate = Completer<void>();
        driver.nextPauseGate = gate;
        driver.pauseStarted = Completer<void>();
        final expiring = controller.syncSleepTimerNow();
        await driver.pauseStarted!.future;
        await controller.setSleepTimer(30);
        if (manualPause) await controller.pause();
        gate.complete();
        await expiring;
        expect(controller.state.sleepTimerMinutes, 30);
        expect(driver.resumeCalls, manualPause ? 0 : 1);
        expect(controller.state.isPlaying, !manualPause);
      },
    );
  }
  test('Sound catalog only exposes real Flutter-bundled audio', () {
    const catalog = SoundCatalog();
    final tracks = catalog.getAll();
    final pubspec = File('pubspec.yaml').readAsStringSync();

    expect(tracks, hasLength(10));
    expect(tracks.map((track) => track.id).toSet(), hasLength(10));
    expect(tracks.map((track) => track.assetPath).toSet(), hasLength(10));

    for (final track in tracks) {
      expect(track.assetPath.endsWith('.mp3'), isTrue, reason: track.id);

      final sourceAsset = File('assets/${track.assetPath}');
      expect(
        sourceAsset.existsSync(),
        isTrue,
        reason: '${sourceAsset.path} must exist',
      );
      expect(
        pubspec,
        contains('- assets/${track.assetPath}'),
        reason: '${track.assetPath} must be declared in pubspec.yaml',
      );
    }

    expect(tracks.where((track) => track.isPremium), hasLength(5));
    expect(tracks.where((track) => !track.isPremium), hasLength(5));
  });

  test('Premium Sound access respects entitlement', () {
    const catalog = SoundCatalog();
    final premium = catalog.getById('pink-noise')!;
    final free = catalog.getById('soft-rain')!;

    expect(canAccessSoundTrack(premium, isPremiumUser: false), isFalse);
    expect(canAccessSoundTrack(premium, isPremiumUser: true), isTrue);
    expect(canAccessSoundTrack(free, isPremiumUser: false), isTrue);
  });

  test(
    'Sound controller can explicitly resume the interrupted track',
    () async {
      final preferences = await _preferences();
      final driver = _FakeSoundPlaybackDriver();
      final controller = SoundPlayerController(
        const SoundCatalog(),
        preferences,
        driver: driver,
      );
      addTearDown(controller.dispose);

      final track = const SoundCatalog().getById('deep-drift')!;
      await controller.play(track);
      await controller.resume();

      expect(controller.state.currentTrackId, track.id);
      expect(driver.resumeCalls, 1);
    },
  );

  test(
    'Sound controller forwards media metadata to the playback driver',
    () async {
      final preferences = await _preferences();
      final driver = _FakeSoundPlaybackDriver();
      final controller = SoundPlayerController(
        const SoundCatalog(),
        preferences,
        driver: driver,
      );
      addTearDown(controller.dispose);

      final track = const SoundCatalog().getById('deep-drift')!;
      await controller.play(track);

      expect(driver.lastAssetPath, track.assetPath);
      expect(driver.lastTrackId, track.id);
      expect(driver.lastTitle, track.title);
    },
  );

  test(
    'Sound volume starts gently and persists across controller instances',
    () async {
      final preferences = await _preferences();
      final first = SoundPlayerController(
        const SoundCatalog(),
        preferences,
        driver: _FakeSoundPlaybackDriver(),
      );

      expect(first.state.volume, closeTo(defaultSoundVolume, 0.0001));

      await first.setVolume(0.41);
      expect(first.state.volume, closeTo(0.41, 0.0001));
      first.dispose();

      final restored = SoundPlayerController(
        const SoundCatalog(),
        preferences,
        driver: _FakeSoundPlaybackDriver(),
      );
      addTearDown(restored.dispose);

      expect(restored.state.volume, closeTo(0.41, 0.0001));
    },
  );

  test('Sleep timer fade preserves the base volume curve', () {
    expect(
      soundOutputVolumeForSleepTimer(baseVolume: 0.8),
      closeTo(0.8, 0.0001),
    );
    expect(
      soundOutputVolumeForSleepTimer(
        baseVolume: 0.8,
        remainingSeconds: soundSleepTimerFadeSeconds + 1,
      ),
      closeTo(0.8, 0.0001),
    );
    expect(
      soundOutputVolumeForSleepTimer(baseVolume: 0.8, remainingSeconds: 10),
      closeTo(0.4, 0.0001),
    );
    expect(
      soundOutputVolumeForSleepTimer(baseVolume: 0.8, remainingSeconds: 0),
      0,
    );
  });

  for (final replacement in [30, null]) {
    test(
      'latest Sleep timer choice $replacement wins delayed audio setup',
      () async {
        final driver = _FakeSoundPlaybackDriver();
        final controller = SoundPlayerController(
          const SoundCatalog(),
          await _preferences(),
          driver: driver,
        );
        addTearDown(controller.dispose);
        await controller.playById('deep-drift');
        final gate = Completer<void>();
        driver.nextVolumeGate = gate;
        driver.volumeStarted = Completer<void>();
        final earlier = controller.setSleepTimer(15);
        await driver.volumeStarted!.future;
        await controller.setSleepTimer(replacement);
        gate.complete();
        await earlier;
        expect(controller.state.sleepTimerMinutes, replacement);
      },
    );
  }

  test(
    'old Sleep expiry cannot pause or clear a newly selected timer',
    () async {
      final driver = _FakeSoundPlaybackDriver();
      var now = DateTime(2026, 9, 11, 22);
      final controller = SoundPlayerController(
        const SoundCatalog(),
        await _preferences(),
        driver: driver,
        now: () => now,
      );
      addTearDown(controller.dispose);
      await controller.playById('deep-drift');
      await controller.setSleepTimer(1);
      now = now.add(const Duration(minutes: 2));
      final gate = Completer<void>();
      driver.nextVolumeGate = gate;
      driver.volumeStarted = Completer<void>();
      final expiring = controller.syncSleepTimerNow();
      await driver.volumeStarted!.future;
      await controller.setSleepTimer(30);
      gate.complete();
      await expiring;
      expect(driver.pauseCalls, 0);
      expect(controller.state.sleepTimerMinutes, 30);
    },
  );

  test(
    'Sleep timer duration starts when selected, not after audio setup',
    () async {
      final driver = _FakeSoundPlaybackDriver();
      var now = DateTime(2026, 9, 11, 22);
      final controller = SoundPlayerController(
        const SoundCatalog(),
        await _preferences(),
        driver: driver,
        now: () => now,
      );
      addTearDown(controller.dispose);
      await controller.playById('deep-drift');
      final gate = Completer<void>();
      driver.nextVolumeGate = gate;
      driver.volumeStarted = Completer<void>();
      final setting = controller.setSleepTimer(15);
      await driver.volumeStarted!.future;
      now = now.add(const Duration(seconds: 5));
      gate.complete();
      await setting;
      await controller.syncSleepTimerNow();
      expect(controller.state.sleepTimerRemainingSeconds, 895);
    },
  );

  test('disposed Sleep controller ignores delayed timer setup', () async {
    final driver = _FakeSoundPlaybackDriver();
    final controller = SoundPlayerController(
      const SoundCatalog(),
      await _preferences(),
      driver: driver,
    );
    await controller.playById('deep-drift');
    final gate = Completer<void>();
    driver.nextVolumeGate = gate;
    driver.volumeStarted = Completer<void>();
    final setting = controller.setSleepTimer(15);
    await driver.volumeStarted!.future;
    controller.dispose();
    gate.complete();
    await setting;
  });

  test('Sleep timer stores a visible real-time countdown', () async {
    final preferences = await _preferences();
    final controller = SoundPlayerController(
      const SoundCatalog(),
      preferences,
      driver: _FakeSoundPlaybackDriver(),
    );
    addTearDown(controller.dispose);

    await controller.setSleepTimer(30);

    expect(controller.state.sleepTimerMinutes, 30);
    expect(
      controller.state.sleepTimerRemainingSeconds,
      inInclusiveRange(1799, 1800),
    );

    await controller.setSleepTimer(null);

    expect(controller.state.sleepTimerMinutes, isNull);
    expect(controller.state.sleepTimerRemainingSeconds, isNull);
  });

  test(
    'Sleep countdown rounds partial seconds without adding a full second',
    () async {
      final preferences = await _preferences();
      var now = DateTime(2026, 9, 11, 22);
      final controller = SoundPlayerController(
        const SoundCatalog(),
        preferences,
        driver: _FakeSoundPlaybackDriver(),
        now: () => now,
      );
      addTearDown(controller.dispose);
      await controller.setSleepTimer(15);
      await controller.syncSleepTimerNow();
      expect(controller.state.sleepTimerRemainingSeconds, 900);
      now = now.add(const Duration(milliseconds: 1));
      await controller.syncSleepTimerNow();
      expect(controller.state.sleepTimerRemainingSeconds, 900);
      now = now.add(const Duration(milliseconds: 999));
      await controller.syncSleepTimerNow();
      expect(controller.state.sleepTimerRemainingSeconds, 899);
    },
  );

  test('Sleep timer expires exactly at the selected deadline once', () async {
    final preferences = await _preferences();
    final driver = _FakeSoundPlaybackDriver();
    final start = DateTime(2026, 9, 11, 22);
    var now = start;
    final controller = SoundPlayerController(
      const SoundCatalog(),
      preferences,
      driver: driver,
      now: () => now,
    );
    addTearDown(controller.dispose);
    await controller.playById('deep-drift');
    await controller.setSleepTimer(15);
    now = start
        .add(const Duration(minutes: 15))
        .subtract(const Duration(microseconds: 1));
    await controller.syncSleepTimerNow();
    expect(controller.state.sleepTimerRemainingSeconds, 1);
    expect(driver.pauseCalls, 0);
    now = start.add(const Duration(minutes: 15));
    await controller.syncSleepTimerNow();
    expect(controller.state.sleepTimerMinutes, isNull);
    expect(driver.pauseCalls, 1);
    await controller.syncSleepTimerNow();
    expect(driver.pauseCalls, 1);
  });

  test(
    'Sleep timer resync expires a deadline that passed in background',
    () async {
      final preferences = await _preferences();
      final driver = _FakeSoundPlaybackDriver();
      var now = DateTime(2026, 9, 8, 22);

      final controller = SoundPlayerController(
        const SoundCatalog(),
        preferences,
        driver: driver,
        now: () => now,
      );
      addTearDown(controller.dispose);

      final track = const SoundCatalog().getById('deep-drift')!;
      await controller.play(track);
      await controller.setSleepTimer(15);

      expect(controller.state.sleepTimerMinutes, 15);
      expect(controller.state.sleepTimerRemainingSeconds, 900);

      now = now.add(const Duration(minutes: 16));
      await controller.syncSleepTimerNow();

      expect(controller.state.sleepTimerMinutes, isNull);
      expect(controller.state.sleepTimerRemainingSeconds, isNull);
      expect(driver.pauseCalls, 1);
      expect(driver.volumeCalls.sublist(driver.volumeCalls.length - 2), [
        0.0,
        controller.state.volume,
      ]);
    },
  );

  testWidgets('Sound library renders its own audio-first visual language', (
    WidgetTester tester,
  ) async {
    final preferences = await _preferences();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [sharedPreferencesProvider.overrideWithValue(preferences)],
        child: const MaterialApp(home: SoundScreen()),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('AMBIENT AUDIO'), findsOneWidget);
    expect(find.text('Sound'), findsOneWidget);
    expect(find.byKey(const Key('sound-featured-card')), findsOneWidget);
    expect(find.text('Releaf Atmosphere I'), findsWidgets);
    expect(find.text('Releaf Atmosphere II'), findsOneWidget);
    expect(find.text('Brown Noise'), findsOneWidget);
    expect(find.text('Soft Rain'), findsOneWidget);
    expect(find.text('Night Air'), findsOneWidget);
    expect(find.text('White Noise'), findsOneWidget);
    expect(find.text('Pink Noise'), findsOneWidget);
    expect(find.text('Ocean Wash'), findsOneWidget);
    expect(find.text('Forest Canopy'), findsOneWidget);
    expect(find.text('Deep Drift'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Direct Sound player close falls back to Sound hub', (
    WidgetTester tester,
  ) async {
    final preferences = await _preferences();
    final router = createAppRouter(
      initialLocation: AppRoutes.soundPlayerFor('brown-noise'),
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(preferences),
          soundPlayerControllerProvider.overrideWith(
            (ref) => SoundPlayerController(
              const SoundCatalog(),
              preferences,
              driver: _FakeSoundPlaybackDriver(),
            ),
          ),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byTooltip('Close player'), findsOneWidget);
    await tester.tap(find.byTooltip('Close player'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byKey(const Key('sound-featured-card')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Premium Sound stays visible and opens preview before paywall', (
    WidgetTester tester,
  ) async {
    final preferences = await _preferences();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [sharedPreferencesProvider.overrideWithValue(preferences)],
        child: const MaterialApp(home: SoundScreen()),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('PREMIUM'), findsNWidgets(5));

    final premiumTrack = find.byKey(
      const Key('sound-track-releaf-atmosphere-02'),
    );
    expect(premiumTrack, findsOneWidget);

    await tester.ensureVisible(premiumTrack);
    await tester.pumpAndSettle();
    await tester.tap(premiumTrack);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byKey(const Key('sound-premium-preview')), findsOneWidget);
    expect(find.text('Releaf Atmosphere II'), findsWidgets);
    expect(find.textContaining('part of Releaf Premium'), findsOneWidget);
    expect(
      find.byKey(const Key('sound-premium-preview-unlock')),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('Sound library stays overflow-free at 320px', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(320, 640));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final preferences = await _preferences();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [sharedPreferencesProvider.overrideWithValue(preferences)],
        child: const MaterialApp(home: SoundScreen()),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byKey(const Key('sound-featured-card')), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.ensureVisible(find.text('AVAILABLE NOW'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
