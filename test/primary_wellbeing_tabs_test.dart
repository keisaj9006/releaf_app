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
