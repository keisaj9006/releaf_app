import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
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
  testWidgets('Reset hub renders the current premium product hierarchy', (
    WidgetTester tester,
  ) async {
    await _pumpResetHub(tester, preferences: await _preferences());

    expect(find.text('What do you need right now?'), findsOneWidget);
    expect(find.text('QUICK RESET'), findsOneWidget);
    expect(find.text('Feel steadier in 2–4 minutes.'), findsOneWidget);
    expect(find.text('AVAILABLE NOW'), findsOneWidget);
    expect(find.text('DEEP RESET'), findsOneWidget);
    expect(
      find.text('Go deeper with guided 8-minute protocols.'),
      findsOneWidget,
    );
    expect(find.text('SOUND'), findsOneWidget);

    expect(find.byKey(const Key('reset-category-carousel')), findsOneWidget);
    expect(find.byKey(const Key('reset-session-rail')), findsOneWidget);
    expect(find.byKey(const Key('reset-deep-rail')), findsOneWidget);
    expect(find.byKey(const Key('reset-sound-gateway')), findsOneWidget);
    expect(find.byKey(const Key('reset-emergency-action')), findsOneWidget);
  });

  testWidgets('Quick Reset categories are populated and actionable', (
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

    await _moveRailForward(tester, const Key('reset-category-carousel'));
    await _moveRailForward(tester, const Key('reset-category-carousel'));
    expect(find.text('Situational'), findsOneWidget);
    expect(find.text('For moments that hit fast.'), findsOneWidget);

    await _moveRailForward(tester, const Key('reset-category-carousel'));
    expect(find.text('Life Upgrade'), findsOneWidget);
    expect(
      find.text('Small practices for stronger everyday regulation.'),
      findsOneWidget,
    );
    expect(find.text('More coming'), findsNothing);
  });

  testWidgets('Category selection filters Available Now instead of jumping', (
    WidgetTester tester,
  ) async {
    await _pumpResetHub(tester, preferences: await _preferences());

    await tester.tap(find.byKey(const Key('reset-category-breath')));
    await tester.pumpAndSettle();

    expect(find.text('BREATH'), findsWidgets);
    expect(find.byKey(const Key('reset-clear-category-filter')), findsOneWidget);
    expect(find.text('Equal Rhythm'), findsOneWidget);
    expect(find.text('60s Grounding'), findsNothing);

    await tester.tap(find.byKey(const Key('reset-clear-category-filter')));
    await tester.pumpAndSettle();

    expect(find.text('AVAILABLE NOW'), findsOneWidget);
    expect(find.text('60s Grounding'), findsOneWidget);
  });

  testWidgets('Situational category exposes the real situational library', (
    WidgetTester tester,
  ) async {
    await _pumpResetHub(tester, preferences: await _preferences());

    await _moveRailForward(tester, const Key('reset-category-carousel'));
    await _moveRailForward(tester, const Key('reset-category-carousel'));

    await tester.tap(find.byKey(const Key('reset-category-situational')));
    await tester.pumpAndSettle();

    expect(find.text('SITUATIONAL'), findsWidgets);
    expect(find.text('Before an Interview'), findsOneWidget);
    expect(find.byKey(const Key('reset-clear-category-filter')), findsOneWidget);
  });

  testWidgets('Deep Reset starts with real 8-minute premium protocols', (
    WidgetTester tester,
  ) async {
    await _pumpResetHub(tester, preferences: await _preferences());

    await tester.ensureVisible(find.byKey(const Key('reset-deep-rail')));
    await tester.pump();

    expect(find.text('Wired → Steady'), findsOneWidget);
    expect(find.text('8 min protocol'), findsOneWidget);
    expect(find.text('Premium'), findsWidgets);

    await _moveRailForward(tester, const Key('reset-deep-rail'));
    expect(find.text('Tension → Full Body Scan'), findsOneWidget);
  });

  testWidgets('Reset cards expose useful accessibility semantics', (
    WidgetTester tester,
  ) async {
    final semantics = tester.ensureSemantics();
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
    expect(sessionData.label, contains('Free, opens session preview.'));

    semantics.dispose();
  });

  testWidgets('Free and premium cards both open preview before launch', (
    WidgetTester tester,
  ) async {
    await _pumpResetHub(tester, preferences: await _preferences());

    await tester.ensureVisible(
      find.byKey(const Key('reset-session-60s-grounding')),
    );
    await tester.tap(find.byKey(const Key('reset-session-60s-grounding')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byKey(const Key('reset-session-preview-sheet')), findsOneWidget);
    expect(find.text('WHAT TO EXPECT'), findsOneWidget);
    expect(find.text('SESSION SETUP'), findsOneWidget);
    expect(find.byKey(const Key('reset-preview-start')), findsOneWidget);

    await tester.tap(find.byKey(const Key('reset-preview-close')));
    await tester.pumpAndSettle();

    await tester.ensureVisible(
      find.byKey(const Key('reset-session-wired-steady')),
    );
    await tester.tap(find.byKey(const Key('reset-session-wired-steady')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byKey(const Key('reset-session-preview-sheet')), findsOneWidget);
    expect(find.byKey(const Key('reset-preview-unlock')), findsOneWidget);
    expect(find.text('SESSION SETUP'), findsNothing);
  });

  testWidgets('Reset preview settings apply to the active free session', (
    WidgetTester tester,
  ) async {
    await _pumpResetHub(tester, preferences: await _preferences());

    await tester.ensureVisible(
      find.byKey(const Key('reset-session-60s-grounding')),
    );
    await tester.tap(find.byKey(const Key('reset-session-60s-grounding')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    final guidanceTile =
        find.byKey(const Key('reset-preview-guidance-toggle'));
    final timerTile = find.byKey(const Key('reset-preview-timer-toggle'));

    await tester.ensureVisible(guidanceTile);
    await tester.tap(
      find.descendant(of: guidanceTile, matching: find.byType(Switch)),
    );
    await tester.pump();

    await tester.ensureVisible(timerTile);
    await tester.tap(
      find.descendant(of: timerTile, matching: find.byType(Switch)),
    );
    await tester.pump();

    await tester.tap(find.byKey(const Key('reset-preview-start')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byKey(const Key('reset-active-session-timer')), findsNothing);
    expect(find.byKey(const Key('reset-active-session-title')), findsOneWidget);
    expect(find.byKey(const Key('reset-active-session-guidance')), findsNothing);
    expect(
      find.byKey(const Key('reset-active-session-guidance-hidden')),
      findsOneWidget,
    );
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

  testWidgets('Reset remains overflow-free on a narrow phone', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(320, 640));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await _pumpResetHub(tester, preferences: await _preferences());

    expect(tester.takeException(), isNull);

    await tester.ensureVisible(
      find.byKey(const Key('reset-session-60s-grounding')),
    );
    await tester.tap(find.byKey(const Key('reset-session-60s-grounding')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byKey(const Key('reset-session-preview-sheet')), findsOneWidget);
    expect(tester.takeException(), isNull);
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
