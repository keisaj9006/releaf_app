import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:releaf_app/core/providers.dart';
import 'package:releaf_app/routing/app_router.dart';
import 'package:releaf_app/routing/app_routes.dart';

Future<SharedPreferences> _preferences() async {
  SharedPreferences.setMockInitialValues({});
  return SharedPreferences.getInstance();
}

Future<void> _pumpRoute(
  WidgetTester tester, {
  required String location,
  required SharedPreferences preferences,
}) async {
  final router = createAppRouter(initialLocation: location);
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
}

void main() {
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

    await tester.ensureVisible(find.text('CHOOSE A PRACTICE'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    final sleepRouter = createAppRouter(initialLocation: AppRoutes.sleep);
    addTearDown(sleepRouter.dispose);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(await _preferences()),
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
}
