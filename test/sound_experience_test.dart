import 'package:audioplayers/audioplayers.dart' as audio;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:releaf_app/core/providers.dart';
import 'package:releaf_app/features/sound/application/sound_player_controller.dart';
import 'package:releaf_app/features/sound/data/sound_catalog.dart';
import 'package:releaf_app/features/sound/presentation/sound_player_gate.dart';
import 'package:releaf_app/features/sound/presentation/sound_screen.dart';

class _FakeSoundPlaybackDriver implements SoundPlaybackDriver {
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
  Future<void> setVolume(double volume) async {}

  @override
  Future<void> playAsset(String assetPath) async {}

  @override
  Future<void> resume() async {}

  @override
  Future<void> pause() async {}

  @override
  Future<void> stop() async {}

  @override
  Future<void> seek(Duration position) async {}

  @override
  Future<void> dispose() async {}
}

Future<SharedPreferences> _preferences() async {
  SharedPreferences.setMockInitialValues({});
  return SharedPreferences.getInstance();
}

void main() {
  test('Sound catalog only exposes real bundled audio', () {
    const catalog = SoundCatalog();
    final tracks = catalog.getAll();

    expect(tracks, hasLength(8));
    expect(
      tracks.map((track) => track.assetPath),
      containsAll([
        'sounds/relief_01.mp3',
        'sounds/relief_02.mp3',
        'sounds/brown_noise.mp3',
        'sounds/soft_rain.mp3',
        'sounds/night_air.mp3',
        'sounds/white_noise.mp3',
        'sounds/pink_noise.mp3',
        'sounds/deep_drift.mp3',
      ]),
    );
    expect(tracks.every((track) => track.assetPath.endsWith('.mp3')), isTrue);
    expect(tracks.where((track) => track.isPremium), hasLength(4));
    expect(tracks.where((track) => !track.isPremium), hasLength(4));
  });

  test('Premium Sound access respects entitlement', () {
    const catalog = SoundCatalog();
    final premium = catalog.getById('deep-drift')!;
    final free = catalog.getById('soft-rain')!;

    expect(
      canAccessSoundTrack(premium, isPremiumUser: false),
      isFalse,
    );
    expect(
      canAccessSoundTrack(premium, isPremiumUser: true),
      isTrue,
    );
    expect(
      canAccessSoundTrack(free, isPremiumUser: false),
      isTrue,
    );
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

  testWidgets('Sound library renders its own audio-first visual language', (
    WidgetTester tester,
  ) async {
    final preferences = await _preferences();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(preferences),
        ],
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
    expect(find.text('Deep Drift'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Premium Sound stays visible and opens preview before paywall', (
    WidgetTester tester,
  ) async {
    final preferences = await _preferences();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(preferences),
        ],
        child: const MaterialApp(home: SoundScreen()),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('PREMIUM'), findsNWidgets(4));

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
        overrides: [
          sharedPreferencesProvider.overrideWithValue(preferences),
        ],
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
