import 'dart:async';

import 'package:audioplayers/audioplayers.dart' as audio;
import 'package:audio_session/audio_session.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:releaf_app/core/providers.dart';
import 'package:releaf_app/features/relief/presentation/breathing_widget.dart';
import 'package:releaf_app/features/sound/application/sound_player_controller.dart';
import 'package:releaf_app/features/sound/data/sound_catalog.dart';
import 'package:releaf_app/features/sound/presentation/sound_player_screen.dart';
import 'package:releaf_app/features/sound/presentation/sound_screen.dart';

class _LoadingDriver
    implements SoundPlaybackDriver, SoundPlaybackIntentTracker {
  final events = StreamController<audio.PlayerState>.broadcast(sync: true);
  final positions = StreamController<Duration>.broadcast(sync: true);
  final durations = StreamController<Duration>.broadcast(sync: true);
  final seeks = <Duration>[];
  Completer<void>? configureGate;
  Completer<void>? loadGate;
  final configuring = Completer<void>();
  final loading = Completer<void>();
  bool fail = false;
  bool failConfiguration = false;
  bool failVolume = false;
  bool failPause = false;
  bool failStop = false;
  int stops = 0;
  Completer<void>? stopGate;
  Completer<void>? volumeGate;
  int loads = 0;
  int resumes = 0;
  int pauses = 0;
  int version = 0;

  @override
  int get playbackIntentVersion => version;
  @override
  Stream<Duration> get onDurationChanged => durations.stream;
  @override
  Stream<Duration> get onPositionChanged => positions.stream;
  @override
  Stream<audio.PlayerState> get onPlayerStateChanged => events.stream;
  @override
  Future<void> setReleaseMode(audio.ReleaseMode mode) async {
    if (!configuring.isCompleted) configuring.complete();
    if (configureGate != null) await configureGate!.future;
    if (failConfiguration) throw StateError('native/configuration/details');
  }

  @override
  Future<void> setVolume(double volume) async {
    final failThisWrite = failVolume;
    final gate = volumeGate;
    if (gate != null) await gate.future;
    if (failThisWrite) throw StateError('private/native/volume/details');
  }

  @override
  Future<void> playAsset(String path, {String? trackId, String? title}) async {
    final request = ++version;
    loads++;
    final shouldFail = fail;
    final gate = loadGate;
    if (!loading.isCompleted) loading.complete();
    if (gate != null) await gate.future;
    if (shouldFail) throw StateError('private/native/source/details');
    if (request == version) events.add(audio.PlayerState.playing);
  }

  @override
  Future<void> resume() async {
    version++;
    resumes++;
    events.add(audio.PlayerState.playing);
  }

  @override
  Future<void> pause() async {
    version++;
    pauses++;
    if (failPause) throw StateError('private/native/pause/details');
    events.add(audio.PlayerState.paused);
  }

  @override
  Future<void> stop() async {
    version++;
    stops++;
    if (failStop) throw StateError('private/native/stop/details');
    if (stopGate != null) await stopGate!.future;
    events.add(audio.PlayerState.stopped);
  }

  @override
  Future<void> seek(Duration position) async {
    seeks.add(position);
    positions.add(position);
  }

  @override
  Future<void> dispose() async {
    version++;
    await events.close();
    await positions.close();
    await durations.close();
  }
}

Future<SharedPreferences> _preferences() async {
  SharedPreferences.setMockInitialValues({});
  return SharedPreferences.getInstance();
}

Future<void> _pumpPlayer(
  WidgetTester tester,
  _LoadingDriver driver, {
  double textScale = 1,
}) async {
  final prefs = await _preferences();
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        soundPlaybackDriverProvider.overrideWithValue(driver),
      ],
      child: MaterialApp(
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(textScale)),
          child: child!,
        ),
        home: const SoundPlayerScreen(trackId: 'deep-drift'),
      ),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 50));
}

void main() {
  for (final minutes in <int?>[30, null]) {
    test('new timer $minutes survives delayed fallback stop', () async {
      var now = DateTime(2026, 9, 12);
      final driver = _LoadingDriver();
      final controller = SoundPlayerController(
        const SoundCatalog(),
        await _preferences(),
        driver: driver,
        now: () => now,
      );
      addTearDown(controller.dispose);
      await controller.playById('deep-drift');
      await controller.setSleepTimer(1);
      final gate = Completer<void>();
      driver.failPause = true;
      driver.stopGate = gate;
      now = now.add(const Duration(minutes: 1));
      final expiry = controller.syncSleepTimerNow();
      await Future<void>.delayed(Duration.zero);
      await controller.setSleepTimer(minutes);
      driver.stopGate = null;
      gate.complete();
      await expiry;
      expect(controller.state.isPlaying, isTrue);
      expect(controller.state.sleepTimerMinutes, minutes);
      expect(driver.loads, 2);
    });
  }

  for (final stopFails in [false, true]) {
    test(
      'expiry pause failure falls back to stop, stop failure $stopFails',
      () async {
        var now = DateTime(2026, 9, 12);
        final driver = _LoadingDriver();
        final controller = SoundPlayerController(
          const SoundCatalog(),
          await _preferences(),
          driver: driver,
          now: () => now,
        );
        addTearDown(controller.dispose);
        await controller.playById('deep-drift');
        await controller.setSleepTimer(1);
        final initialStops = driver.stops;
        driver.failPause = true;
        driver.failStop = stopFails;
        now = now.add(const Duration(minutes: 1));
        await controller.syncSleepTimerNow();
        expect(driver.stops, initialStops + 1);
        expect(controller.state.isPlaying, stopFails);
        expect(controller.state.hasPlaybackError, isTrue);
        expect(controller.state.sleepTimerRemainingSeconds, isNull);
        driver.failPause = false;
        driver.failStop = false;
        await controller.togglePlayPause();
        expect(driver.loads, 2);
        expect(controller.state.hasPlaybackError, isFalse);
      },
    );
  }

  test(
    'old timer volume failure does not label newer playback as failed',
    () async {
      var now = DateTime(2026, 9, 12);
      final driver = _LoadingDriver();
      final controller = SoundPlayerController(
        const SoundCatalog(),
        await _preferences(),
        driver: driver,
        now: () => now,
      );
      addTearDown(controller.dispose);
      await controller.playById('deep-drift');
      await controller.setSleepTimer(1);
      final gate = Completer<void>();
      driver.volumeGate = gate;
      driver.failVolume = true;
      now = now.add(const Duration(minutes: 1));
      final expiry = controller.syncSleepTimerNow();
      await Future<void>.delayed(Duration.zero);
      driver.volumeGate = null;
      driver.failVolume = false;
      await controller.playById('deep-drift');
      gate.complete();
      await expiry;
      expect(controller.state.isPlaying, isTrue);
      expect(controller.state.hasPlaybackError, isFalse);
      expect(driver.pauses, 0);
    },
  );

  test('sleep timer still pauses when native volume writes fail', () async {
    var now = DateTime(2026, 9, 12);
    final driver = _LoadingDriver();
    final controller = SoundPlayerController(
      const SoundCatalog(),
      await _preferences(),
      driver: driver,
      now: () => now,
    );
    addTearDown(controller.dispose);
    await controller.playById('deep-drift');
    await controller.setSleepTimer(1);
    driver.failVolume = true;
    now = now.add(const Duration(minutes: 1));
    await controller.syncSleepTimerNow();
    expect(driver.pauses, 1);
    expect(controller.state.isPlaying, isFalse);
    expect(controller.state.sleepTimerRemainingSeconds, isNull);
    expect(controller.state.hasPlaybackError, isTrue);
  });

  testWidgets('returning to Reset cancels a pending Sound load', (
    tester,
  ) async {
    final prefs = await _preferences();
    final gate = Completer<void>();
    final driver = _LoadingDriver()..loadGate = gate;
    final controller = SoundPlayerController(
      const SoundCatalog(),
      prefs,
      driver: driver,
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          soundPlayerControllerProvider.overrideWith((ref) => controller),
        ],
        child: const MaterialApp(
          home: BreathingWidget(sessionId: 'equal-rhythm'),
        ),
      ),
    );
    await tester.pump();
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    await tester.pump();
    final starting = controller.playById('deep-drift');
    await driver.loading.future;
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();
    gate.complete();
    await starting;
    await tester.pump();
    expect(controller.state.isPlaying, isFalse);
    expect(controller.state.isLoading, isFalse);
    expect(driver.pauses, greaterThan(0));
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('entering Reset cancels a pending Sound load', (tester) async {
    final prefs = await _preferences();
    final gate = Completer<void>();
    final driver = _LoadingDriver()..loadGate = gate;
    final controller = SoundPlayerController(
      const SoundCatalog(),
      prefs,
      driver: driver,
    );
    final starting = controller.playById('deep-drift');
    await driver.loading.future;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          soundPlayerControllerProvider.overrideWith((ref) => controller),
        ],
        child: const MaterialApp(
          home: BreathingWidget(sessionId: 'equal-rhythm'),
        ),
      ),
    );
    await tester.pump();
    gate.complete();
    await starting;
    await tester.pump();
    expect(controller.state.isPlaying, isFalse);
    expect(controller.state.isLoading, isFalse);
    expect(driver.pauses, greaterThan(0));
    await tester.pumpWidget(const SizedBox.shrink());
  });

  test(
    'Sound relative seek uses exact ten seconds and clamps at track ends',
    () async {
      final driver = _LoadingDriver();
      final controller = SoundPlayerController(
        const SoundCatalog(),
        await _preferences(),
        driver: driver,
      );
      addTearDown(controller.dispose);
      await controller.playById('deep-drift');
      driver.durations.add(const Duration(seconds: 90));
      driver.positions.add(const Duration(seconds: 7));
      await controller.seekRelative(const Duration(seconds: 10));
      await controller.seekRelative(const Duration(seconds: -10));
      await controller.seekRelative(const Duration(seconds: -10));
      await controller.seekRelative(const Duration(seconds: 200));
      expect(driver.seeks, [
        const Duration(seconds: 17),
        const Duration(seconds: 7),
        Duration.zero,
        const Duration(seconds: 90),
      ]);
    },
  );
  for (final failed in [false, true]) {
    testWidgets(
      'Sound mini player exposes ${failed ? 'retry' : 'cancel loading'}',
      (tester) async {
        final prefs = await _preferences();
        final gate = Completer<void>();
        final driver = _LoadingDriver()
          ..fail = failed
          ..loadGate = failed ? null : gate;
        final controller = SoundPlayerController(
          const SoundCatalog(),
          prefs,
          driver: driver,
        );
        final starting = controller.playById('deep-drift');
        await driver.loading.future;
        if (failed) await starting;
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              sharedPreferencesProvider.overrideWithValue(prefs),
              soundPlayerControllerProvider.overrideWith((ref) => controller),
            ],
            child: const MaterialApp(home: SoundScreen()),
          ),
        );
        await tester.pump();
        expect(
          find.text(failed ? 'Could not start' : 'Loading'),
          findsOneWidget,
        );
        driver.fail = false;
        await tester.tap(
          find.byTooltip(failed ? 'Retry sound' : 'Cancel loading'),
        );
        if (!failed) gate.complete();
        await starting;
        await tester.pump();
        expect(find.text(failed ? 'Playing' : 'Paused'), findsOneWidget);
        expect(controller.state.isPlaying, failed);
        expect(tester.takeException(), isNull);
      },
    );
  }
  for (final stage in ['configuration', 'source']) {
    for (final type in [
      AudioInterruptionType.pause,
      AudioInterruptionType.unknown,
    ]) {
      test('$type cancels pending $stage and follows resume policy', () async {
        final gate = Completer<void>();
        final driver = _LoadingDriver();
        if (stage == 'configuration') driver.configureGate = gate;
        if (stage == 'source') driver.loadGate = gate;
        final controller = SoundPlayerController(
          const SoundCatalog(),
          await _preferences(),
          driver: driver,
        );
        addTearDown(controller.dispose);
        final starting = controller.playById('deep-drift');
        await (stage == 'configuration'
            ? driver.configuring.future
            : driver.loading.future);
        expect(controller.state.isLoading, isTrue);
        await controller.handleAudioInterruption(
          AudioInterruptionEvent(true, type),
        );
        expect(driver.pauses, 1);
        expect(controller.state.isLoading, isFalse);
        gate.complete();
        await starting;
        expect(controller.state.isPlaying, isFalse);
        expect(controller.state.hasPlaybackError, isFalse);
        await controller.handleAudioInterruption(
          AudioInterruptionEvent(false, type),
        );
        expect(controller.state.isPlaying, type == AudioInterruptionType.pause);
      });
    }
  }

  for (final action in [
    'pause',
    'stop',
    'notification pause',
    'notification stop',
    'noisy',
  ]) {
    test('interruption end respects a later $action', () async {
      final driver = _LoadingDriver();
      final controller = SoundPlayerController(
        const SoundCatalog(),
        await _preferences(),
        driver: driver,
      );
      addTearDown(controller.dispose);
      await controller.playById('deep-drift');
      await controller.handleAudioInterruption(
        AudioInterruptionEvent(true, AudioInterruptionType.pause),
      );
      switch (action) {
        case 'pause':
          await controller.pause();
        case 'stop':
          await controller.stop();
        case 'notification pause':
          await driver.pause();
        case 'notification stop':
          await driver.stop();
        case 'noisy':
          await controller.handleBecomingNoisy();
      }
      await controller.handleAudioInterruption(
        AudioInterruptionEvent(false, AudioInterruptionType.pause),
      );
      expect(controller.state.isPlaying, isFalse);
      expect(driver.resumes, 0);
    });
  }

  test(
    'configuration failure keeps the chosen track available for retry',
    () async {
      final driver = _LoadingDriver()..failConfiguration = true;
      final controller = SoundPlayerController(
        const SoundCatalog(),
        await _preferences(),
        driver: driver,
      );
      addTearDown(controller.dispose);
      await controller.playById('deep-drift');
      expect(controller.state.currentTrackId, 'deep-drift');
      expect(controller.state.hasPlaybackError, isTrue);
      expect(controller.state.isLoading, isFalse);
      driver.failConfiguration = false;
      await controller.resume();
      expect(controller.state.isPlaying, isTrue);
      expect(controller.state.hasPlaybackError, isFalse);
      expect(controller.state.isLoading, isFalse);
    },
  );

  test(
    'an obsolete source failure cannot replace the newer playing track',
    () async {
      final gate = Completer<void>();
      final driver = _LoadingDriver()
        ..fail = true
        ..loadGate = gate;
      final controller = SoundPlayerController(
        const SoundCatalog(),
        await _preferences(),
        driver: driver,
      );
      addTearDown(controller.dispose);
      final first = controller.playById('deep-drift');
      await driver.loading.future;
      driver
        ..fail = false
        ..loadGate = null;
      await controller.playById('soft-rain');
      gate.complete();
      await first;
      expect(controller.state.currentTrackId, 'soft-rain');
      expect(controller.state.isPlaying, isTrue);
      expect(controller.state.isLoading, isFalse);
      expect(controller.state.hasPlaybackError, isFalse);
      expect(controller.state.recentIds, ['soft-rain']);
    },
  );
  test(
    'a source failure is contained and explicit resume reloads it',
    () async {
      final driver = _LoadingDriver()..fail = true;
      final prefs = await _preferences();
      final controller = SoundPlayerController(
        const SoundCatalog(),
        prefs,
        driver: driver,
      );
      addTearDown(controller.dispose);
      await expectLater(controller.playById('deep-drift'), completes);
      expect(controller.state.isPlaying, isFalse);
      expect(controller.state.recentIds, isEmpty);
      driver.fail = false;
      await controller.resume();
      expect(driver.loads, 2);
      expect(controller.state.isPlaying, isTrue);
      expect(controller.state.recentIds, ['deep-drift']);
    },
  );

  testWidgets(
    'Sound shows loading and lets the user cancel before configuration completes',
    (tester) async {
      final gate = Completer<void>();
      final driver = _LoadingDriver()..configureGate = gate;
      await _pumpPlayer(tester, driver);
      expect(find.text('LOADING'), findsOneWidget);
      final cancel = find.bySemanticsLabel('Cancel loading');
      await tester.ensureVisible(cancel);
      await tester.tap(cancel);
      gate.complete();
      await tester.pump();
      expect(find.text('PAUSED'), findsOneWidget);
      expect(driver.loads, 0);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'Sound failure offers a working retry without exposing native details',
    (tester) async {
      final driver = _LoadingDriver()..fail = true;
      await _pumpPlayer(tester, driver);
      expect(tester.takeException(), isNull);
      expect(
        find.text('There was a playback problem. Try again.'),
        findsOneWidget,
      );
      expect(find.textContaining('private/native'), findsNothing);
      driver.fail = false;
      final retry = find.bySemanticsLabel('Retry sound');
      await tester.ensureVisible(retry);
      await tester.tap(retry);
      await tester.pump();
      expect(find.text('PLAYING'), findsOneWidget);
      expect(
        find.text('There was a playback problem. Try again.'),
        findsNothing,
      );
      expect(driver.loads, 2);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('Sound loading remains usable at 320px with double text size', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(320, 640));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final gate = Completer<void>();
    final driver = _LoadingDriver()..loadGate = gate;
    await _pumpPlayer(tester, driver, textScale: 2);
    expect(tester.takeException(), isNull);
    expect(find.text('LOADING'), findsOneWidget);
    await tester.ensureVisible(find.bySemanticsLabel('Cancel loading'));
    expect(tester.takeException(), isNull);
    await tester.tap(find.bySemanticsLabel('Cancel loading'));
    gate.complete();
    await tester.pump();
    expect(find.text('PAUSED'), findsOneWidget);
  });
}
