import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
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

Future<void> _moveRailForward(WidgetTester tester, Key railKey) async {
  await tester.drag(find.byKey(railKey), const Offset(-320, 0));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('Reset hub renders three differentiated editorial rails', (
    WidgetTester tester,
  ) async {
    await _pumpResetHub(tester, preferences: await _preferences());

    expect(find.text('Reset'), findsOneWidget);
    expect(find.text('What do you need right now?'), findsOneWidget);
    expect(find.text('QUICK RESET'), findsOneWidget);
    expect(find.text('Feel steadier in 2–4 minutes.'), findsOneWidget);
    expect(find.text('AVAILABLE NOW'), findsOneWidget);
    expect(find.text('Small resets, ready when you are.'), findsOneWidget);
    expect(find.text('DEEP RESET'), findsOneWidget);
    expect(
      find.text('Go deeper with guided 8-minute protocols.'),
      findsOneWidget,
    );

    expect(find.byKey(const Key('reset-category-carousel')), findsOneWidget);
    expect(find.byKey(const Key('reset-session-rail')), findsOneWidget);
    expect(find.byKey(const Key('reset-deep-rail')), findsOneWidget);
    expect(find.byType(PageView), findsNWidgets(3));
    expect(find.byKey(const Key('reset-emergency-action')), findsOneWidget);
    expect(find.byType(FloatingActionButton), findsNothing);
  });

  testWidgets('Category carousel contains all editorial categories', (
    WidgetTester tester,
  ) async {
    await _pumpResetHub(tester, preferences: await _preferences());

    expect(find.text('Breath'), findsWidgets);
    expect(find.text('Use your breath to shift your state.'), findsOneWidget);
    expect(find.text('No-Breath'), findsWidgets);
    expect(
      find.text('Ground your body without a breathing drill.'),
      findsOneWidget,
    );

    await _moveRailForward(
      tester,
      const Key('reset-category-carousel'),
    );
    await _moveRailForward(
      tester,
      const Key('reset-category-carousel'),
    );
    expect(find.text('Situational'), findsOneWidget);
    expect(find.text('For moments that hit fast.'), findsOneWidget);

    await _moveRailForward(
      tester,
      const Key('reset-category-carousel'),
    );
    expect(find.text('Life Upgrade'), findsOneWidget);
    expect(
      find.text('Small practices for stronger everyday regulation.'),
      findsOneWidget,
    );
    expect(find.text('More coming'), findsWidgets);
  });

  testWidgets('Only canonical real content appears in playable rails', (
    WidgetTester tester,
  ) async {
    await _pumpResetHub(tester, preferences: await _preferences());

    await tester.ensureVisible(find.byKey(const Key('reset-session-rail')));
    await tester.pump();
    expect(find.text('60s Grounding'), findsOneWidget);

    await _moveRailForward(tester, const Key('reset-session-rail'));
    expect(find.text('90s Calm Down'), findsOneWidget);

    await _moveRailForward(tester, const Key('reset-session-rail'));
    expect(find.text('5 min Focus Anchor'), findsOneWidget);
    expect(find.text('Premium'), findsWidgets);

    expect(find.text('3 min Deep Reset'), findsOneWidget);
    expect(find.text('Current 3-minute protocol'), findsOneWidget);

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

  testWidgets('Available categories focus real sessions; empty ones do not act', (
    WidgetTester tester,
  ) async {
    await _pumpResetHub(tester, preferences: await _preferences());

    final breathCard = tester.widget<ReleafPressableCard>(
      find.byKey(const Key('reset-category-breath')),
    );
    final noBreathCard = tester.widget<ReleafPressableCard>(
      find.byKey(const Key('reset-category-noBreath')),
    );
    expect(breathCard.onPressed, isNotNull);
    expect(noBreathCard.onPressed, isNotNull);

    await tester.tap(find.byKey(const Key('reset-category-breath')));
    await tester.pumpAndSettle();
    final sessionRail = tester.widget<PageView>(
      find.byKey(const Key('reset-session-rail')),
    );
    expect(sessionRail.controller!.page, closeTo(1, 0.05));
    expect(find.text('90s Calm Down'), findsOneWidget);

    await tester.ensureVisible(
      find.byKey(const Key('reset-category-carousel')),
    );
    await tester.pump();
    await _moveRailForward(
      tester,
      const Key('reset-category-carousel'),
    );
    await _moveRailForward(
      tester,
      const Key('reset-category-carousel'),
    );

    final situationalCard = tester.widget<ReleafPressableCard>(
      find.byKey(const Key('reset-category-situational')),
    );
    final lifeUpgradeCard = tester.widget<ReleafPressableCard>(
      find.byKey(const Key('reset-category-lifeUpgrade')),
    );
    expect(situationalCard.onPressed, isNull);
    expect(lifeUpgradeCard.onPressed, isNull);
  });

  testWidgets('Reset editorial cards expose useful accessibility semantics', (
    WidgetTester tester,
  ) async {
    final semantics = tester.ensureSemantics();
    addTearDown(semantics.dispose);
    await _pumpResetHub(tester, preferences: await _preferences());

    final breathNode = tester.getSemantics(
      find.byKey(const Key('reset-category-breath')),
    );
    final breathData = breathNode.getSemanticsData();
    expect(breathData.flagsCollection.isButton, isTrue);
    expect(breathData.hasAction(SemanticsAction.tap), isTrue);
    expect(
      breathData.label,
      contains('Use your breath to shift your state.'),
    );

    await tester.ensureVisible(find.byKey(const Key('reset-session-rail')));
    await tester.pump();
    final sessionNode = tester.getSemantics(
      find.byKey(const Key('reset-session-60s-grounding')),
    );
    final sessionData = sessionNode.getSemanticsData();
    expect(sessionData.flagsCollection.isButton, isTrue);
    expect(sessionData.label, contains('Free, starts session.'));

    await tester.ensureVisible(
      find.byKey(const Key('reset-category-carousel')),
    );
    await tester.pump();
    await _moveRailForward(
      tester,
      const Key('reset-category-carousel'),
    );
    await _moveRailForward(
      tester,
      const Key('reset-category-carousel'),
    );
    final unavailableNode = tester.getSemantics(
      find.byKey(const Key('reset-category-situational')),
    );
    final unavailableData = unavailableNode.getSemanticsData();
    expect(unavailableData.hasAction(SemanticsAction.tap), isFalse);
    expect(unavailableData.label, contains('Not available yet.'));
  });

  testWidgets('Reset free and Premium cards preserve access behavior', (
    WidgetTester tester,
  ) async {
    await _pumpResetHub(tester, preferences: await _preferences());

    await tester.ensureVisible(find.byKey(const Key('reset-session-rail')));
    await tester.pump();
    await tester.tap(find.text('60s Grounding'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('01:00'), findsOneWidget);
    expect(find.text('Unlock Premium'), findsNothing);

    await tester.tap(find.byIcon(Icons.close));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    await tester.ensureVisible(find.text('3 min Deep Reset'));
    await tester.pump();
    await tester.tap(find.text('3 min Deep Reset'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Unlock Premium'), findsOneWidget);
    expect(find.text('03:00'), findsNothing);
  });

  testWidgets('Reset header Emergency action opens the free session', (
    WidgetTester tester,
  ) async {
    await _pumpResetHub(tester, preferences: await _preferences());

    await tester.tap(find.byKey(const Key('reset-emergency-action')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('02:00'), findsOneWidget);
    expect(find.text('Unlock Premium'), findsNothing);
  });

  testWidgets('Editorial rails do not overflow on a narrow phone', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(320, 640));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await _pumpResetHub(tester, preferences: await _preferences());

    expect(tester.takeException(), isNull);
    await _moveRailForward(
      tester,
      const Key('reset-category-carousel'),
    );
    expect(tester.takeException(), isNull);

    await tester.ensureVisible(find.byKey(const Key('reset-session-rail')));
    await tester.pump();
    await _moveRailForward(tester, const Key('reset-session-rail'));
    await _moveRailForward(tester, const Key('reset-session-rail'));
    expect(tester.takeException(), isNull);

    await tester.ensureVisible(find.byKey(const Key('reset-deep-rail')));
    await tester.pump();
    expect(tester.takeException(), isNull);
    expect(
      tester.getSize(find.byKey(const Key('reset-content-column'))).width,
      320,
    );
  });

  testWidgets('Reset keeps editorial proportions on a large viewport', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(900, 1000));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await _pumpResetHub(tester, preferences: await _preferences());

    expect(tester.takeException(), isNull);
    expect(
      tester.getSize(find.byKey(const Key('reset-content-column'))).width,
      lessThanOrEqualTo(720),
    );
    expect(
      tester.getSize(find.byKey(const Key('reset-category-carousel'))).width,
      lessThanOrEqualTo(470),
    );
    expect(
      tester.getSize(find.byKey(const Key('reset-session-rail'))).width,
      lessThanOrEqualTo(600),
    );
  });
}
