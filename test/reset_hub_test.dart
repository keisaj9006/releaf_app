import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:releaf_app/core/providers.dart';
import 'package:releaf_app/routing/app_router.dart';
import 'package:releaf_app/routing/app_routes.dart';
import 'package:releaf_app/theme/widgets/releaf_components.dart';

Future<SharedPreferences> _preferences() async {
  SharedPreferences.setMockInitialValues({});
  return SharedPreferences.getInstance();
}

Future<void> _pumpResetHub(
  WidgetTester tester, {
  required SharedPreferences preferences,
}) async {
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
  await tester.pump(const Duration(milliseconds: 300));
}

void main() {
  testWidgets('Reset hub renders the frozen hierarchy and active content', (
    WidgetTester tester,
  ) async {
    await _pumpResetHub(
      tester,
      preferences: await _preferences(),
    );

    expect(find.text('Reset'), findsOneWidget);
    expect(find.text('Choose what you need right now.'), findsOneWidget);
    expect(find.text('QUICK RESET'), findsOneWidget);
    expect(find.text('Feel steadier in 2–4 minutes.'), findsOneWidget);
    expect(find.text('Situational'), findsOneWidget);
    expect(find.text('Breath'), findsWidgets);
    expect(find.text('No-Breath'), findsWidgets);
    expect(find.text('Life Upgrade'), findsOneWidget);
    expect(find.text('DEEP RESET'), findsOneWidget);
    expect(
      find.text('Go deeper with guided 8-minute protocols.'),
      findsOneWidget,
    );

    for (final title in [
      '60s Grounding',
      '90s Calm Down',
      '3 min Deep Reset',
      '5 min Focus Anchor',
    ]) {
      expect(find.text(title), findsOneWidget);
    }

    expect(find.text('Premium'), findsNWidgets(2));
    expect(find.byKey(const Key('reset-emergency-action')), findsOneWidget);
    expect(find.byType(FloatingActionButton), findsNothing);
  });

  testWidgets('Only real catalog sessions are playable from Reset', (
    WidgetTester tester,
  ) async {
    await _pumpResetHub(
      tester,
      preferences: await _preferences(),
    );

    for (final id in [
      '60s-grounding',
      '90s-calm-down',
      '3min-breath',
      '5min-focus',
    ]) {
      final card = tester.widget<ReleafPressableCard>(
        find.byKey(Key('reset-session-$id')),
      );
      expect(card.onPressed, isNotNull);
    }

    for (final category in [
      'situational',
      'breath',
      'noBreath',
      'lifeUpgrade',
    ]) {
      final card = tester.widget<ReleafPressableCard>(
        find.byKey(Key('reset-category-$category')),
      );
      expect(card.onPressed, isNull);
    }

    expect(find.text('Coming later'), findsNWidgets(2));
    for (final unimplementedSession in [
      'Wired → Steady',
      'Tension → Full Body Scan',
      'Overwhelm → Stability',
      'Evening → Proper Unwind',
      'Anger → Release & Calm',
      'Overthinking → Let It Go',
    ]) {
      expect(find.text(unimplementedSession), findsNothing);
    }
  });

  testWidgets('Reset free and Premium cards preserve access behavior', (
    WidgetTester tester,
  ) async {
    await _pumpResetHub(
      tester,
      preferences: await _preferences(),
    );

    await tester.tap(find.text('60s Grounding'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('01:00'), findsOneWidget);
    expect(find.text('Unlock Premium'), findsNothing);

    await tester.tap(find.byIcon(Icons.close));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    await tester.scrollUntilVisible(
      find.text('3 min Deep Reset'),
      180,
      scrollable: find.byKey(const Key('reset-scroll-view')),
    );
    await tester.tap(find.text('3 min Deep Reset'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Unlock Premium'), findsOneWidget);
    expect(find.text('03:00'), findsNothing);
  });

  testWidgets('Reset header Emergency action opens the free session', (
    WidgetTester tester,
  ) async {
    await _pumpResetHub(
      tester,
      preferences: await _preferences(),
    );

    await tester.tap(find.byKey(const Key('reset-emergency-action')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('02:00'), findsOneWidget);
    expect(find.text('Unlock Premium'), findsNothing);
  });

  testWidgets('Reset hub does not overflow on a narrow phone', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(320, 640));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await _pumpResetHub(
      tester,
      preferences: await _preferences(),
    );

    expect(tester.takeException(), isNull);
    expect(
      tester.getSize(find.byKey(const Key('reset-content-column'))).width,
      320,
    );
  });

  testWidgets('Reset hub constrains content on a large viewport', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(900, 1000));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await _pumpResetHub(
      tester,
      preferences: await _preferences(),
    );

    expect(tester.takeException(), isNull);
    expect(
      tester.getSize(find.byKey(const Key('reset-content-column'))).width,
      lessThanOrEqualTo(720),
    );
  });
}
