import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:releaf_app/core/providers.dart';
import 'package:releaf_app/features/relief/data/audio_catalog.dart';
import 'package:releaf_app/features/relief/presentation/relief_session_gate.dart';
import 'package:releaf_app/routing/app_router.dart';
import 'package:releaf_app/routing/app_routes.dart';

Future<SharedPreferences> _preferences() async {
  SharedPreferences.setMockInitialValues({});
  return SharedPreferences.getInstance();
}

void main() {
  const catalog = AudioCatalog();
  final freeSession = catalog.getById('60s-grounding')!;
  final premiumSession = catalog.getById('3min-breath')!;
  final emergencySession = catalog.getById(AudioCatalog.emergencySessionId)!;

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
}
