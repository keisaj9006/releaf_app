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

  testWidgets('Simple equal breathing stays visually minimal', (
    WidgetTester tester,
  ) async {
    final preferences = await _preferences();
    final router = createAppRouter(
      initialLocation: AppRoutes.reliefSessionFor('90s-calm-down'),
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
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byKey(const Key('reset-living-form')), findsOneWidget);
    expect(find.byKey(const Key('reset-breath-path')), findsNothing);
    expect(find.text('Breathe in'), findsOneWidget);
  });

  testWidgets('Structured breathing renders the curved Releaf Breath Path', (
    WidgetTester tester,
  ) async {
    final preferences = await _preferences();
    final router = createAppRouter(
      initialLocation: AppRoutes.reliefSessionFor('longer-exhale'),
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
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byKey(const Key('reset-living-form')), findsOneWidget);
    expect(find.byKey(const Key('reset-breath-path')), findsOneWidget);
    expect(find.text('Breathe in'), findsOneWidget);
  });

  testWidgets('Grounding stays breath-free and has no Breath Path', (
    WidgetTester tester,
  ) async {
    final preferences = await _preferences();
    final router = createAppRouter(
      initialLocation: AppRoutes.reliefSessionFor('60s-grounding'),
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
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byKey(const Key('reset-living-form')), findsOneWidget);
    expect(find.byKey(const Key('reset-breath-path')), findsNothing);
    expect(find.text('Arrive'), findsOneWidget);
  });

  testWidgets('Back to the Room is interactive and can switch to 3-2-1', (
    WidgetTester tester,
  ) async {
    final preferences = await _preferences();
    final router = createAppRouter(
      initialLocation: AppRoutes.reliefSessionFor('back-to-room'),
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
    await tester.pump(const Duration(seconds: 16));
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byKey(const Key('reset-sensory-halo')), findsOneWidget);
    expect(find.byKey(const Key('reset-living-form')), findsNothing);
    expect(find.text('SEE'), findsOneWidget);
    expect(find.byKey(const Key('reset-sensory-tap-hint')), findsOneWidget);
    expect(find.byKey(const Key('reset-simplify-action')), findsOneWidget);
    expect(find.text('5'), findsOneWidget);

    await tester.tap(find.byKey(const Key('reset-sensory-halo')));
    await tester.pump(const Duration(milliseconds: 120));
    expect(find.text('4'), findsOneWidget);

    await tester.tap(find.byKey(const Key('reset-simplify-action')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('01:00'), findsOneWidget);
    expect(find.byKey(const Key('reset-simplified-active')), findsOneWidget);
    expect(find.text('Notice three things you can see.'), findsOneWidget);
    expect(find.text('3'), findsOneWidget);

    for (var i = 0; i < 3; i++) {
      await tester.tap(find.byKey(const Key('reset-sensory-halo')));
      await tester.pump(const Duration(milliseconds: 120));
    }
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('FEEL'), findsOneWidget);
    expect(find.text('Notice two things you can physically feel.'), findsOneWidget);
  });

  testWidgets('Jaw and Shoulders uses the distinct Body Reset visual', (
    WidgetTester tester,
  ) async {
    final preferences = await _preferences();
    final router = createAppRouter(
      initialLocation: AppRoutes.reliefSessionFor('jaw-shoulders'),
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
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byKey(const Key('reset-body-release-visual')), findsOneWidget);
    expect(find.byKey(const Key('reset-living-form')), findsNothing);
    expect(find.text('Notice'), findsOneWidget);
    expect(find.text('01:30'), findsOneWidget);
  });

  testWidgets('Name the Thought uses the distinct thought-unhook visual', (
    WidgetTester tester,
  ) async {
    final preferences = await _preferences();
    final router = createAppRouter(
      initialLocation: AppRoutes.reliefSessionFor('name-the-thought'),
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
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byKey(const Key('reset-thought-unhook-visual')), findsOneWidget);
    expect(find.byKey(const Key('reset-living-form')), findsNothing);
    expect(find.text('Notice'), findsOneWidget);
    expect(find.text('02:00'), findsOneWidget);

    await tester.pump(const Duration(seconds: 41));
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Unhook'), findsOneWidget);
    expect(
      find.text(
        'Try adding: “I am noticing the thought that…” before the sentence.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('A premium Relief preview cannot bypass the paywall', (
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

    expect(
      find.byKey(const Key('reset-session-preview-sheet')),
      findsOneWidget,
    );
    expect(find.byKey(const Key('reset-preview-unlock')), findsOneWidget);
    expect(find.text('03:00'), findsNothing);

    await tester.tap(find.byKey(const Key('reset-preview-unlock')));
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

    await tester.ensureVisible(find.text(freeSession.title));
    await tester.pump();
    await tester.tap(find.text(freeSession.title));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));
    expect(
      find.byKey(const Key('reset-session-preview-sheet')),
      findsOneWidget,
    );
    expect(find.text('01:00'), findsNothing);

    await tester.tap(find.byKey(const Key('reset-preview-start')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));
    expect(find.text('01:00'), findsOneWidget);
    expect(find.byKey(const Key('reset-living-form')), findsOneWidget);

    await tester.tap(find.byTooltip('Exit reset'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));

    final state = container.read(leavesNotifierProvider);
    expect(state.reliefDone, isFalse);
    expect(state.totalLeaves, 0);
    expect(find.text('Reset'), findsOneWidget);
  });

  testWidgets('60s Grounding advances through visible grounding steps', (
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
    await tester.pump(const Duration(milliseconds: 250));

    expect(find.text('Arrive'), findsOneWidget);
    expect(
      find.text('Sit comfortably and place your feet on the ground.'),
      findsOneWidget,
    );

    await tester.pump(const Duration(seconds: 16));
    await tester.pump(const Duration(milliseconds: 350));

    expect(find.text('Feel'), findsOneWidget);
    expect(
      find.text(
        'Notice three physical sensations where your body meets the floor or chair.',
      ),
      findsOneWidget,
    );
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

    await tester.ensureVisible(find.text(freeSession.title));
    await tester.pump();
    await tester.tap(find.text(freeSession.title));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));
    expect(
      find.byKey(const Key('reset-session-preview-sheet')),
      findsOneWidget,
    );

    await tester.tap(find.byKey(const Key('reset-preview-start')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));
    expect(find.byKey(const Key('reset-living-form')), findsOneWidget);
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
