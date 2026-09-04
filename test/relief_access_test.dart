import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:releaf_app/core/providers.dart';
import 'package:releaf_app/core/subscription/revenuecat_service.dart';
import 'package:releaf_app/core/subscription/subscription_controller.dart';
import 'package:releaf_app/core/subscription/subscription_state.dart';
import 'package:releaf_app/features/progress/data/leaves_repository.dart';
import 'package:releaf_app/features/relief/data/audio_catalog.dart' as legacy;
import 'package:releaf_app/features/relief/data/reset_catalog.dart';
import 'package:releaf_app/features/relief/presentation/relief_session_gate.dart';
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

void main() {
  const catalog = legacy.AudioCatalog();
  final freeSession = catalog.getById('60s-grounding')!;
  final premiumSession = catalog.getById('3min-breath')!;
  final emergencySession = catalog.getById(
    legacy.AudioCatalog.emergencySessionId,
  )!;

  test('Relief access policy allows free and entitled sessions', () {
    expect(
      canAccessReliefSession(freeSession, isPremiumUser: false),
      isTrue,
    );
    expect(
      canAccessReliefSession(premiumSession, isPremiumUser: false),
      isFalse,
    );
    expect(
      canAccessReliefSession(premiumSession, isPremiumUser: true),
      isTrue,
    );
    expect(
      canAccessReliefSession(emergencySession, isPremiumUser: false),
      isTrue,
    );
  });

  testWidgets('A free Relief session opens from its direct route', (
    WidgetTester tester,
  ) async {
    final preferences = await _preferences();
    final router = createAppRouter(
      initialLocation: AppRoutes.reliefSessionFor(freeSession.id),
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(preferences),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pump();
    await tester.pump();

    expect(find.text('01:00'), findsOneWidget);
    expect(find.text('Unlock Premium'), findsNothing);
  });

  testWidgets('A premium Relief tile opens the paywall for a free user', (
    WidgetTester tester,
  ) async {
    final preferences = await _preferences();
    final router = createAppRouter(initialLocation: AppRoutes.relief);
    addTearDown(router.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(preferences),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));

    await tester.ensureVisible(find.text(premiumSession.title));
    await tester.pump();
    await tester.tap(find.text(premiumSession.title));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));

    expect(find.text('Unlock Premium'), findsOneWidget);
    expect(find.text('03:00'), findsNothing);
  });

  testWidgets('A direct premium route cannot bypass entitlement', (
    WidgetTester tester,
  ) async {
    final preferences = await _preferences();
    final router = createAppRouter(
      initialLocation: AppRoutes.reliefSessionFor(premiumSession.id),
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(preferences),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));

    expect(find.text('Unlock Premium'), findsOneWidget);
    expect(find.text('03:00'), findsNothing);
  });

  testWidgets('A direct premium route opens with entitlement', (
    WidgetTester tester,
  ) async {
    final preferences = await _preferences();
    final router = createAppRouter(
      initialLocation: AppRoutes.reliefSessionFor(premiumSession.id),
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(preferences),
          subscriptionControllerProvider.overrideWith(
            (ref) => _FixedSubscriptionController(isPremium: true),
          ),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pump();
    await tester.pump();

    expect(find.text('03:00'), findsOneWidget);
    expect(find.text('Unlock Premium'), findsNothing);
  });

  testWidgets('Emergency opens without reading subscription state', (
    WidgetTester tester,
  ) async {
    final preferences = await _preferences();
    final router = createAppRouter(
      initialLocation: AppRoutes.reliefSessionFor(emergencySession.id),
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(preferences),
          subscriptionControllerProvider.overrideWith(
            (ref) => throw StateError('Emergency must not read RevenueCat'),
          ),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pump();
    await tester.pump();

    expect(find.text('02:00'), findsOneWidget);
    expect(find.text('Unlock Premium'), findsNothing);
  });

  testWidgets('Unknown direct session ID returns safely to Relief', (
    WidgetTester tester,
  ) async {
    final preferences = await _preferences();
    final router = createAppRouter(
      initialLocation: AppRoutes.reliefSessionFor('missing-session'),
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(preferences),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));

    expect(find.text('Reset'), findsOneWidget);
    expect(find.text('Page Not Found'), findsNothing);
  });

  testWidgets('Aborting 60s Grounding gives no Relief reward', (
    WidgetTester tester,
  ) async {
    final preferences = await _preferences();
    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(preferences),
        todayProvider.overrideWithValue('2026-09-04'),
      ],
    );
    addTearDown(container.dispose);
    final router = createAppRouter(initialLocation: AppRoutes.relief);
    addTearDown(router.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));

    await tester.tap(find.text(freeSession.title));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));
    expect(find.text('01:00'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.close));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));

    final state = container.read(leavesNotifierProvider);
    expect(state.reliefDone, isFalse);
    expect(state.totalLeaves, 0);
    expect(find.text('Reset'), findsOneWidget);
  });

  testWidgets('Completing 60s Grounding awards Relief once and shows feedback', (
    WidgetTester tester,
  ) async {
    final preferences = await _preferences();
    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(preferences),
        todayProvider.overrideWithValue('2026-09-04'),
      ],
    );
    addTearDown(container.dispose);
    final router = createAppRouter(initialLocation: AppRoutes.relief);
    addTearDown(router.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));

    await tester.tap(find.text(freeSession.title));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));
    await tester.pump(const Duration(seconds: 60));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Did this help settle your nerves?'), findsOneWidget);
    expect(container.read(leavesNotifierProvider).reliefDone, isTrue);
    expect(container.read(leavesNotifierProvider).totalLeaves, 1);

    await container.read(leavesNotifierProvider.notifier).markReliefDone();
    expect(container.read(leavesNotifierProvider).totalLeaves, 1);
  });

  testWidgets('Completing Emergency gives no Leaves', (
    WidgetTester tester,
  ) async {
    final preferences = await _preferences();
    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(preferences),
        todayProvider.overrideWithValue('2026-09-04'),
        subscriptionControllerProvider.overrideWith(
          (ref) => throw StateError('Emergency must not read RevenueCat'),
        ),
      ],
    );
    addTearDown(container.dispose);
    final router = createAppRouter(
      initialLocation: AppRoutes.reliefSessionFor(
        ResetCatalog.emergencySessionId,
      ),
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(seconds: 120));
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Did this help settle your nerves?'), findsOneWidget);
    final state = container.read(leavesNotifierProvider);
    expect(state.reliefDone, isFalse);
    expect(state.totalLeaves, 0);
  });
}
