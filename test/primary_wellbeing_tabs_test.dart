import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:releaf_app/core/providers.dart';
import 'package:releaf_app/core/subscription/revenuecat_service.dart';
import 'package:releaf_app/core/subscription/subscription_controller.dart';
import 'package:releaf_app/core/subscription/subscription_state.dart';
import 'package:releaf_app/features/meditation/application/meditation_audio_controller.dart';
import 'package:releaf_app/features/meditation/application/meditation_library_controller.dart';
import 'package:releaf_app/features/meditation/data/meditation_catalog.dart';
import 'package:releaf_app/features/meditation/domain/meditation_content.dart';
import 'package:releaf_app/features/meditation/domain/meditation_resume_state.dart';
import 'package:releaf_app/features/meditation/presentation/meditation_player_screen.dart';
import 'package:releaf_app/features/meditation/presentation/meditation_session_gate.dart';
import 'package:releaf_app/features/sound/data/sound_catalog.dart';
import 'package:releaf_app/routing/app_router.dart';
import 'package:releaf_app/routing/app_routes.dart';

Future<SharedPreferences> _preferences() async {
  SharedPreferences.setMockInitialValues({});
  return SharedPreferences.getInstance();
}

class _FixedSubscriptionController extends SubscriptionController {
  _FixedSubscriptionController({required bool isPremium})
      : super(RevenueCatService()) {
    state = SubscriptionState(isPremium: isPremium);
  }

  @override
  Future<void> initAndRefresh() async {}

  @override
  Future<void> refresh() async {}
}

class _FakeMeditationAudioDriver implements MeditationAudioDriver {
  int playCalls = 0;
  int pauseCalls = 0;
  int resumeCalls = 0;
  int stopCalls = 0;
  int volumeCalls = 0;
  String? lastAssetPath;
  double? lastVolume;

  @override
  Future<void> playAsset(
    String assetPath, {
    required double volume,
  }) async {
    playCalls += 1;
    lastAssetPath = assetPath;
  }

  @override
  Future<void> pause() async {
    pauseCalls += 1;
  }

  @override
  Future<void> resume() async {
    resumeCalls += 1;
  }

  @override
  Future<void> setVolume(double volume) async {
    volumeCalls += 1;
    lastVolume = volume;
  }

  @override
  Future<void> stop() async {
    stopCalls += 1;
  }

  @override
  Future<void> dispose() async {}
}

Future<void> _pumpRoute(
  WidgetTester tester, {
  required String location,
  required SharedPreferences preferences,
  bool isPremium = false,
  MeditationAudioDriver? meditationAudioDriver,
}) async {
  final router = createAppRouter(initialLocation: location);
  addTearDown(router.dispose);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(preferences),
        subscriptionControllerProvider.overrideWith(
          (ref) => _FixedSubscriptionController(isPremium: isPremium),
        ),
        meditationAudioDriverProvider.overrideWithValue(
          meditationAudioDriver ?? _FakeMeditationAudioDriver(),
        ),
      ],
      child: MaterialApp.router(routerConfig: router),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
}

void main() {
  test('Sound catalog exposes only real bundled sound spaces', () {
    const catalog = SoundCatalog();
    final tracks = catalog.getAll();

    expect(tracks, hasLength(8));
    expect(catalog.getById('brown-noise')?.assetPath, 'sounds/brown_noise.mp3');
    expect(catalog.getById('soft-rain')?.assetPath, 'sounds/soft_rain.mp3');
    expect(catalog.getById('night-air')?.assetPath, 'sounds/night_air.mp3');
    expect(catalog.getById('white-noise')?.assetPath, 'sounds/white_noise.mp3');
    expect(catalog.getById('pink-noise')?.assetPath, 'sounds/pink_noise.mp3');
    expect(catalog.getById('deep-drift')?.assetPath, 'sounds/deep_drift.mp3');
  });

  test('Meditation catalog keeps every session duration internally valid', () {
    const catalog = MeditationCatalog();

    for (final item in catalog.getAll()) {
      final stepDuration = item.steps.fold<int>(
        0,
        (total, step) => total + step.durationSeconds,
      );
      expect(
        stepDuration,
        item.durationSeconds,
        reason: '${item.id} steps must equal the declared session duration',
      );
    }
  });

  test('Meditation catalog exposes a premium Deeper Practice course', () {
    const catalog = MeditationCatalog();
    final course =
        catalog.getSeries(MeditationCatalog.deeperPracticeSeriesId);

    expect(course, hasLength(4));
    expect(course.every((item) => item.isPremium), isTrue);
    expect(course.first.title, 'Steady Attention');
    expect(course.last.title, 'Open Field');
    expect(course.every((item) => item.durationSeconds >= 480), isTrue);
  });

  test('Meditation catalog exposes a dedicated Sleep Practice series', () {
    const catalog = MeditationCatalog();
    final sleep = catalog.getSeries(MeditationCatalog.sleepSeriesId);

    expect(sleep, hasLength(3));
    expect(sleep.first.title, 'Let the Day Go');
    expect(sleep.first.isPremium, isFalse);
    expect(sleep.skip(1).every((item) => item.isPremium), isTrue);
    expect(
      sleep.map((item) => item.seriesOrder),
      orderedEquals([1, 2, 3]),
    );
    expect(sleep.every((item) => item.backgroundSoundId != null), isTrue);
  });

  test('Meditation catalog exposes a real Foundations series', () {
    const catalog = MeditationCatalog();
    final foundations = catalog.getSeries(MeditationCatalog.foundationsSeriesId);

    expect(foundations, hasLength(4));
    expect(foundations.first.title, 'Mindfulness Basics');
    expect(foundations.last.title, 'Open Awareness');
    expect(
      foundations.map((item) => item.seriesOrder),
      orderedEquals([1, 2, 3, 4]),
    );
    expect(catalog.getByCategory(MeditationCategory.focus), isNotEmpty);
  });

  test('Meditation session access cannot bypass premium entitlement', () {
    const catalog = MeditationCatalog();
    final free = catalog.getById('mindfulness-basics-2')!;
    final premium = catalog.getById('steady-attention-10')!;

    expect(
      canAccessMeditationSession(free, isPremiumUser: false),
      isTrue,
    );
    expect(
      canAccessMeditationSession(premium, isPremiumUser: false),
      isFalse,
    );
    expect(
      canAccessMeditationSession(premium, isPremiumUser: true),
      isTrue,
    );
  });

  test('Meditation library stores favorites, recents and completion', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(preferences),
      ],
    );
    addTearDown(container.dispose);

    final controller =
        container.read(meditationLibraryControllerProvider.notifier);

    await controller.toggleFavorite('mindfulness-basics-2');
    await controller.markRecent('mindfulness-basics-2');
    await controller.markCompleted('mindfulness-basics-2');

    final state = container.read(meditationLibraryControllerProvider);
    expect(state.isFavorite('mindfulness-basics-2'), isTrue);
    expect(state.recentIds.first, 'mindfulness-basics-2');
    expect(state.isCompleted('mindfulness-basics-2'), isTrue);
  });

  test('Meditation ambience mix persists and scales session audio', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final driver = _FakeMeditationAudioDriver();
    final controller = MeditationAudioController(
      const SoundCatalog(),
      preferences,
      driver,
    );
    addTearDown(controller.dispose);

    await controller.start(
      soundId: 'releaf-atmosphere-01',
      volume: 0.20,
    );
    await controller.setMix(0.50);

    expect(controller.state.mix, 0.50);
    expect(driver.lastVolume, closeTo(0.10, 0.001));

    final restored = MeditationAudioController(
      const SoundCatalog(),
      preferences,
      _FakeMeditationAudioDriver(),
    );
    addTearDown(restored.dispose);

    expect(restored.state.mix, 0.50);
  });

  testWidgets('Meditate is a primary destination, not a nested page', (
    WidgetTester tester,
  ) async {
    await _pumpRoute(
      tester,
      location: AppRoutes.meditate,
      preferences: await _preferences(),
    );

    expect(find.text('MEDITATION'), findsOneWidget);
    expect(find.text('Meditate'), findsWidgets);
    expect(find.text('FOUNDATIONS'), findsOneWidget);
    expect(find.text('NIGHT PRACTICE'), findsOneWidget);
    expect(
      find.byKey(const Key('meditation-sleep-course')),
      findsOneWidget,
    );
    expect(find.text('QUICK PRACTICES'), findsOneWidget);
    expect(find.text('EXPLORE BY INTENTION'), findsOneWidget);
    expect(find.byTooltip('Back'), findsNothing);

    final navigation = tester.widget<NavigationBar>(find.byType(NavigationBar));
    expect(navigation.destinations, hasLength(5));
    expect(navigation.selectedIndex, 3);
  });

  testWidgets('Sleep is a primary destination, not a nested page', (
    WidgetTester tester,
  ) async {
    await _pumpRoute(
      tester,
      location: AppRoutes.sleep,
      preferences: await _preferences(),
    );

    expect(find.text('NIGHT'), findsOneWidget);
    expect(find.text('Sleep'), findsWidgets);
    expect(find.text('SOUND FOR SLEEP'), findsOneWidget);
    expect(find.text('SLEEP MEDITATIONS'), findsOneWidget);
    expect(find.byKey(const Key('sleep-meditation-rail')), findsOneWidget);
    expect(find.text('WIND DOWN'), findsOneWidget);
    expect(find.byTooltip('Back'), findsNothing);

    final navigation = tester.widget<NavigationBar>(find.byType(NavigationBar));
    expect(navigation.destinations, hasLength(5));
    expect(navigation.selectedIndex, 4);
  });

  testWidgets('Meditate and Sleep stay overflow-free at 320px', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(320, 640));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await _pumpRoute(
      tester,
      location: AppRoutes.meditate,
      preferences: await _preferences(),
    );
    expect(tester.takeException(), isNull);

    await tester.ensureVisible(find.text('QUICK PRACTICES'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    final sleepRouter = createAppRouter(initialLocation: AppRoutes.sleep);
    addTearDown(sleepRouter.dispose);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(await _preferences()),
          subscriptionControllerProvider.overrideWith(
            (ref) => _FixedSubscriptionController(isPremium: false),
          ),
          meditationAudioDriverProvider.overrideWithValue(
            _FakeMeditationAudioDriver(),
          ),
        ],
        child: MaterialApp.router(routerConfig: sleepRouter),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(tester.takeException(), isNull);
    await tester.ensureVisible(find.text('WIND DOWN'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('Direct premium meditation route is gated for free users', (
    WidgetTester tester,
  ) async {
    await _pumpRoute(
      tester,
      location: AppRoutes.meditationSessionFor('steady-attention-10'),
      preferences: await _preferences(),
    );
    await tester.pumpAndSettle();

    expect(find.text('RELEAF PREMIUM'), findsOneWidget);
    expect(find.text('Unlock Premium'), findsOneWidget);
    expect(
      find.byKey(const Key('meditation-living-form')),
      findsNothing,
    );
  });

  testWidgets('Direct premium meditation route opens with entitlement', (
    WidgetTester tester,
  ) async {
    await _pumpRoute(
      tester,
      location: AppRoutes.meditationSessionFor('steady-attention-10'),
      preferences: await _preferences(),
      isPremium: true,
    );

    expect(
      find.byKey(const Key('meditation-living-form')),
      findsOneWidget,
    );
    expect(find.text('Steady Attention'), findsWidgets);
  });

  testWidgets('Meditation player uses the signature Living Form and pauses', (
    WidgetTester tester,
  ) async {
    final audioDriver = _FakeMeditationAudioDriver();

    await _pumpRoute(
      tester,
      location: AppRoutes.meditationSessionFor('mindfulness-basics-2'),
      preferences: await _preferences(),
      meditationAudioDriver: audioDriver,
    );

    expect(find.byKey(const Key('meditation-living-form')), findsOneWidget);
    expect(
      find.byKey(const Key('meditation-primary-control')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('meditation-sound-control')),
      findsOneWidget,
    );
    expect(find.text('ARRIVE'), findsOneWidget);
    expect(audioDriver.playCalls, 1);
    expect(audioDriver.lastAssetPath, 'sounds/relief_01.mp3');

    await tester.tap(find.text('Pause'));
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('PAUSED'), findsOneWidget);
    expect(find.text('Continue'), findsOneWidget);
    expect(audioDriver.pauseCalls, 1);

    await tester.tap(find.text('Continue'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(audioDriver.resumeCalls, 1);

    expect(
      find.byKey(const Key('meditation-sound-mix')),
      findsOneWidget,
    );

    await tester.tap(find.byKey(const Key('meditation-sound-toggle')));
    await tester.pump(const Duration(milliseconds: 300));
    expect(audioDriver.pauseCalls, 2);
  });

  testWidgets('Paused meditation resumes without auto-playing ambience', (
    WidgetTester tester,
  ) async {
    final preferences = await _preferences();
    final audioDriver = _FakeMeditationAudioDriver();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(preferences),
          meditationAudioDriverProvider.overrideWithValue(audioDriver),
          subscriptionControllerProvider.overrideWith(
            (ref) => _FixedSubscriptionController(isPremium: true),
          ),
        ],
        child: const MaterialApp(
          home: MeditationPlayerScreen(
            meditationId: 'mindfulness-basics-2',
            resumeState: MeditationResumeState(remainingSeconds: 45),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('00:45'), findsOneWidget);
    expect(find.text('Continue'), findsOneWidget);
    expect(audioDriver.playCalls, 0);

    await tester.tap(find.text('Continue'));
    await tester.pump(const Duration(milliseconds: 400));

    expect(audioDriver.playCalls, 1);
  });

  testWidgets('Meditation player stays overflow-free at 320px', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(320, 640));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await _pumpRoute(
      tester,
      location: AppRoutes.meditationSessionFor('mindfulness-basics-2'),
      preferences: await _preferences(),
    );

    expect(find.byKey(const Key('meditation-living-form')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Sleep premium affordances reflect the real entitlement', (
    WidgetTester tester,
  ) async {
    await _pumpRoute(
      tester,
      location: AppRoutes.sleep,
      preferences: await _preferences(),
    );

    expect(find.text('Unlock tonight'), findsOneWidget);

    // Dispose the first ProviderScope so the premium override cannot reuse
    // the free controller from the first half of this widget test.
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();

    final premiumRouter = createAppRouter(initialLocation: AppRoutes.sleep);
    addTearDown(premiumRouter.dispose);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(await _preferences()),
          subscriptionControllerProvider.overrideWith(
            (ref) => _FixedSubscriptionController(isPremium: true),
          ),
          meditationAudioDriverProvider.overrideWithValue(
            _FakeMeditationAudioDriver(),
          ),
        ],
        child: MaterialApp.router(routerConfig: premiumRouter),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Start tonight'), findsOneWidget);
    expect(find.text('Unlock tonight'), findsNothing);
  });
}
