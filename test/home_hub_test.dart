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

Future<void> _pumpHome(
  WidgetTester tester, {
  required SharedPreferences preferences,
}) async {
  final router = createAppRouter(initialLocation: AppRoutes.home);
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
  testWidgets('Home renders the premium need-first hierarchy', (
    WidgetTester tester,
  ) async {
    await _pumpHome(tester, preferences: await _preferences());

    expect(find.text('RELEAF'), findsOneWidget);
    expect(find.text('RIGHT NOW'), findsOneWidget);
    expect(find.text('Calm down'), findsOneWidget);
    expect(find.text('Clear my head'), findsOneWidget);
    expect(find.text('Focus'), findsOneWidget);
    expect(find.text('Wind down'), findsOneWidget);
    expect(find.byKey(const Key('home-recommendation-card')), findsOneWidget);
    expect(find.text('DAILY ESSENTIALS'), findsOneWidget);
    expect(find.text('Your daily rhythm'), findsOneWidget);
    expect(find.text('0 Leaves collected'), findsOneWidget);
    expect(find.text('0/3'), findsOneWidget);
  });

  testWidgets('Home recommendation reacts to the selected need', (
    WidgetTester tester,
  ) async {
    await _pumpHome(tester, preferences: await _preferences());

    await tester.tap(find.text('Calm down'));
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('SUGGESTED FOR CALM'), findsOneWidget);
    expect(find.text('Back to the Room'), findsOneWidget);
    expect(find.text('You chose calm down.'), findsOneWidget);

    await tester.tap(find.text('Focus'));
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('SUGGESTED FOR FOCUS'), findsOneWidget);
    expect(find.text('Daily Brain Workout'), findsWidgets);
    expect(find.text('You chose focus.'), findsOneWidget);
  });

  testWidgets('Home remains overflow-free on a narrow phone', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(320, 640));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await _pumpHome(tester, preferences: await _preferences());

    expect(find.text('Calm down'), findsOneWidget);
    expect(find.byKey(const Key('home-recommendation-card')), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.ensureVisible(find.text('Your daily rhythm'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
