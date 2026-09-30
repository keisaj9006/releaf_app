import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:releaf_app/core/providers.dart';
import 'package:releaf_app/features/relief/application/reset_completion_store.dart';
import 'package:releaf_app/features/relief/data/reset_catalog.dart';
import 'package:releaf_app/features/relief/domain/models/reset_content.dart';
import 'package:releaf_app/routing/app_router.dart';
import 'package:releaf_app/routing/app_routes.dart';

Future<SharedPreferences> _preferences() async {
  SharedPreferences.setMockInitialValues({});
  return SharedPreferences.getInstance();
}

Future<SharedPreferences> _preferencesWithResetHistory() async {
  final now = DateTime.now().toUtc();
  final records = <ResetCompletionRecord>[
    ResetCompletionRecord(
      id: 'reset-test-1',
      sessionId: 'equal-rhythm',
      completedAt: now,
      durationSeconds: 120,
    ),
    ResetCompletionRecord(
      id: 'reset-test-2',
      sessionId: 'back-to-room',
      completedAt: now.subtract(const Duration(days: 2)),
      durationSeconds: 180,
    ),
    ResetCompletionRecord(
      id: 'reset-test-3',
      sessionId: 'equal-rhythm',
      completedAt: now.subtract(const Duration(days: 2, hours: 1)),
      durationSeconds: 120,
    ),
  ];

  SharedPreferences.setMockInitialValues(<String, Object>{
    'reset.completions.v1': records
        .map((record) => record.encode())
        .toList(growable: false),
  });
  return SharedPreferences.getInstance();
}

Future<void> _pumpResetHub(
  WidgetTester tester, {
  required SharedPreferences preferences,
  double textScale = 1,
}) async {
  final router = createAppRouter(initialLocation: AppRoutes.relief);
  addTearDown(router.dispose);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(preferences)],
      child: MaterialApp.router(
        routerConfig: router,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(textScale)),
          child: child!,
        ),
      ),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
}

Future<void> _selectGroup(
  WidgetTester tester,
  ResetDiscoveryGroup group,
) async {
  final selector = find.byKey(Key('reset-group-${group.name}'));
  final position = Scrollable.of(tester.element(selector)).position;
  position.jumpTo(position.minScrollExtent);
  await tester.pumpAndSettle();
  final target = position.pixels + tester.getCenter(selector).dy - 280;
  position.jumpTo(
    target.clamp(position.minScrollExtent, position.maxScrollExtent),
  );
  await tester.pumpAndSettle();
  await tester.tap(selector);
  await tester.pumpAndSettle();
}

Future<void> _openResetCard(WidgetTester tester, String id) async {
  await tester.ensureVisible(find.byKey(Key('reset-content-$id')));
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(Key('reset-session-$id')));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
}

void main() {
  test('Emergency Calm stays free and locally defined', () {
    const catalog = ResetCatalog();
    final emergency = catalog.getById(ResetCatalog.emergencySessionId);

    expect(emergency, isNotNull);
    expect(emergency!.accessTier, ResetAccessTier.free);
    expect(emergency.isEmergency, isTrue);
    expect(emergency.instructions, isNotEmpty);
    expect(emergency.program, isNotNull);
    expect(emergency.program!.steps, isNotEmpty);
  });

  testWidgets('Reset discovery presents Emergency and three focused purposes', (
    tester,
  ) async {
    await _pumpResetHub(tester, preferences: await _preferences());
    expect(find.byKey(const Key('reset-emergency-entry')), findsOneWidget);
    for (final group in ResetDiscoveryGroup.values) {
      expect(find.byKey(Key('reset-group-${group.name}')), findsOneWidget);
    }
    expect(find.byKey(const Key('reset-session-rail')), findsNothing);
    expect(find.byKey(const Key('reset-deep-rail')), findsNothing);
    expect(find.byKey(const Key('reset-content-equal-rhythm')), findsOneWidget);
    expect(
      find.byKey(const Key('reset-content-before-interview')),
      findsNothing,
    );
    await tester.tap(find.byKey(const Key('reset-group-situationalCalm')));
    await tester.pumpAndSettle();
    expect(
      find.byKey(const Key('reset-content-before-interview')),
      findsOneWidget,
    );
    expect(find.byKey(const Key('reset-content-equal-rhythm')), findsNothing);
    await tester.tap(find.byKey(const Key('reset-group-bodyMindReset')));
    await tester.pumpAndSettle();
    expect(
      find.byKey(const Key('reset-content-60s-grounding')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('reset-content-before-interview')),
      findsNothing,
    );
    expect(find.byKey(const Key('reset-sound-gateway')), findsOneWidget);
  });

  testWidgets('Reset hub offers Emergency and focused discovery', (
    tester,
  ) async {
    await _pumpResetHub(tester, preferences: await _preferences());
    expect(find.text('What do you need right now?'), findsOneWidget);
    expect(find.text('Emergency Calm · free'), findsOneWidget);
    expect(find.text('CHOOSE A RESET'), findsOneWidget);
    for (final group in ResetDiscoveryGroup.values) {
      expect(find.byKey(Key('reset-group-${group.name}')), findsOneWidget);
    }
    expect(find.byKey(const Key('reset-sound-gateway')), findsOneWidget);
    expect(find.byKey(const Key('reset-emergency-action')), findsOneWidget);
    expect(find.byKey(const Key('reset-progress-card')), findsNothing);
  });

  testWidgets(
    'Reset progress appears only after real completion history exists',
    (WidgetTester tester) async {
      await _pumpResetHub(
        tester,
        preferences: await _preferencesWithResetHistory(),
      );

      final progressCard = find.byKey(const Key('reset-progress-card'));
      await tester.ensureVisible(progressCard);
      await tester.pumpAndSettle();

      expect(progressCard, findsOneWidget);
      expect(find.text('YOUR RESET PRACTICE'), findsOneWidget);
      expect(find.byKey(const Key('reset-progress-week')), findsOneWidget);
      expect(find.byKey(const Key('reset-progress-days')), findsOneWidget);
      expect(find.byKey(const Key('reset-progress-total')), findsOneWidget);
      expect(find.text('This week'), findsOneWidget);
      expect(find.text('Active days'), findsOneWidget);
      expect(find.text('All time'), findsOneWidget);
      expect(find.text('3'), findsNWidgets(2));
      expect(find.text('2'), findsOneWidget);
    },
  );

  testWidgets('Every Reset purpose is populated and actionable', (
    tester,
  ) async {
    await _pumpResetHub(tester, preferences: await _preferences());
    expect(find.byKey(const Key('reset-content-equal-rhythm')), findsOneWidget);
    await _selectGroup(tester, ResetDiscoveryGroup.situationalCalm);
    expect(find.text('Calm for a situation'), findsWidgets);
    expect(
      find.byKey(const Key('reset-content-before-interview')),
      findsOneWidget,
    );
    await _selectGroup(tester, ResetDiscoveryGroup.bodyMindReset);
    expect(find.text('Body & mind reset'), findsWidgets);
    expect(
      find.byKey(const Key('reset-content-60s-grounding')),
      findsOneWidget,
    );
  });

  testWidgets('Breathing guidance remains tied to methods', (tester) async {
    await _pumpResetHub(tester, preferences: await _preferences());
    expect(
      find.byKey(const Key('reset-breathing-method-guide')),
      findsOneWidget,
    );
    expect(find.text('Choose the pattern, not the promise.'), findsOneWidget);
    expect(find.text('3–6'), findsOneWidget);
    expect(
      find.textContaining('same inhale-to-exhale ratio as 2–4'),
      findsOneWidget,
    );
    expect(find.textContaining('inhale–hold–exhale–hold'), findsOneWidget);
    expect(
      find.textContaining('slow paced breathing has broader support'),
      findsOneWidget,
    );
    expect(find.text('5–5 balanced breathing'), findsOneWidget);
    expect(find.text('5–5 Balanced'), findsOneWidget);
    expect(find.text('60s Grounding'), findsNothing);
    await _selectGroup(tester, ResetDiscoveryGroup.bodyMindReset);
    expect(find.byKey(const Key('reset-breathing-method-guide')), findsNothing);
    expect(find.text('60s Grounding'), findsOneWidget);
  });

  testWidgets('Situational purpose exposes the real situational library', (
    tester,
  ) async {
    await _pumpResetHub(tester, preferences: await _preferences());
    await _selectGroup(tester, ResetDiscoveryGroup.situationalCalm);
    expect(find.text('Before Panic Builds'), findsOneWidget);
    expect(
      find.byKey(const Key('reset-content-before-interview')),
      findsOneWidget,
    );
  });

  testWidgets('Deep Reset protocols retain their access previews', (
    tester,
  ) async {
    await _pumpResetHub(tester, preferences: await _preferences());
    await tester.ensureVisible(
      find.byKey(const Key('reset-content-wired-steady')),
    );
    expect(find.text('Wired → Steady'), findsOneWidget);
    expect(find.text('8 min protocol'), findsWidgets);
    expect(find.text('Premium'), findsWidgets);
    await _selectGroup(tester, ResetDiscoveryGroup.bodyMindReset);
    await tester.ensureVisible(
      find.byKey(const Key('reset-content-tension-body-scan')),
    );
    expect(find.text('Tension → Full Body Scan'), findsOneWidget);
  });

  testWidgets('Reset choices and cards expose useful accessibility semantics', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await _pumpResetHub(tester, preferences: await _preferences());
    final breathData = tester
        .getSemantics(find.byKey(const Key('reset-group-breathingMethods')))
        .getSemanticsData();
    expect(breathData.flagsCollection.isButton, isTrue);
    expect(breathData.hasAction(SemanticsAction.tap), isTrue);
    expect(breathData.label, contains('Breathing methods'));
    await _selectGroup(tester, ResetDiscoveryGroup.bodyMindReset);
    await tester.ensureVisible(
      find.byKey(const Key('reset-content-60s-grounding')),
    );
    final sessionData = tester
        .getSemantics(find.byKey(const Key('reset-session-60s-grounding')))
        .getSemanticsData();
    expect(sessionData.flagsCollection.isButton, isTrue);
    expect(sessionData.label, contains('Free, opens session preview.'));
    semantics.dispose();
  });

  testWidgets('Free and premium cards both open preview before launch', (
    WidgetTester tester,
  ) async {
    await _pumpResetHub(tester, preferences: await _preferences());

    await _selectGroup(tester, ResetDiscoveryGroup.bodyMindReset);
    await _openResetCard(tester, '60s-grounding');

    expect(
      find.byKey(const Key('reset-session-preview-sheet')),
      findsOneWidget,
    );
    expect(find.text('WHAT TO EXPECT'), findsOneWidget);
    expect(find.text('SESSION SETUP'), findsOneWidget);
    expect(find.byKey(const Key('reset-preview-voice-toggle')), findsOneWidget);
    expect(find.byKey(const Key('reset-preview-voice-volume')), findsOneWidget);
    final previewVoiceTile = find.byKey(
      const Key('reset-preview-voice-toggle'),
    );
    await tester.ensureVisible(previewVoiceTile);
    await tester.tap(
      find.descendant(of: previewVoiceTile, matching: find.byType(Switch)),
    );
    await tester.pump();
    expect(find.byKey(const Key('reset-preview-voice-volume')), findsNothing);
    expect(
      find.byKey(const Key('reset-preview-ambient-toggle')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('reset-preview-ambient-volume')),
      findsOneWidget,
    );
    expect(find.byKey(const Key('reset-preview-start')), findsOneWidget);
    expect(
      find.text('Let thoughts come and go without judgement.'),
      findsOneWidget,
    );

    await tester.tap(find.byKey(const Key('reset-preview-close')));
    await tester.pumpAndSettle();

    await _selectGroup(tester, ResetDiscoveryGroup.breathingMethods);
    await _openResetCard(tester, 'wired-steady');

    expect(
      find.byKey(const Key('reset-session-preview-sheet')),
      findsOneWidget,
    );
    expect(find.byKey(const Key('reset-preview-unlock')), findsOneWidget);
    expect(find.text('SESSION SETUP'), findsNothing);
  });

  testWidgets('Reset preview settings apply to the active free session', (
    WidgetTester tester,
  ) async {
    await _pumpResetHub(tester, preferences: await _preferences());

    await _selectGroup(tester, ResetDiscoveryGroup.bodyMindReset);
    await _openResetCard(tester, '60s-grounding');

    final guidanceTile = find.byKey(const Key('reset-preview-guidance-toggle'));
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
    expect(
      find.byKey(const Key('reset-active-session-guidance')),
      findsNothing,
    );
    expect(
      find.byKey(const Key('reset-active-session-guidance-hidden')),
      findsOneWidget,
    );
  });

  testWidgets('Breathing method ratio stays visible during the session', (
    WidgetTester tester,
  ) async {
    await _pumpResetHub(tester, preferences: await _preferences());

    final sessionCard = find.byKey(const Key('reset-session-equal-rhythm'));
    await tester.dragUntilVisible(
      sessionCard,
      find.byType(CustomScrollView).first,
      const Offset(0, -280),
    );
    await tester.pumpAndSettle();
    await tester.tap(sessionCard);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    await tester.tap(find.byKey(const Key('reset-preview-start')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byKey(const Key('reset-active-breath-method')), findsOneWidget);
    expect(find.text('5–5 balanced breathing'), findsOneWidget);
  });

  testWidgets('Reset audio controls remain available during a session', (
    WidgetTester tester,
  ) async {
    await _pumpResetHub(tester, preferences: await _preferences());

    await _selectGroup(tester, ResetDiscoveryGroup.bodyMindReset);
    await _openResetCard(tester, '60s-grounding');

    await tester.tap(find.byKey(const Key('reset-preview-start')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byKey(const Key('reset-active-audio-button')), findsOneWidget);

    await tester.tap(find.byKey(const Key('reset-active-audio-button')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(
      find.byKey(const Key('reset-active-audio-settings')),
      findsOneWidget,
    );
    expect(find.byKey(const Key('reset-active-master-mute')), findsOneWidget);
    expect(find.byKey(const Key('reset-active-voice-toggle')), findsOneWidget);
    expect(find.byKey(const Key('reset-active-voice-volume')), findsOneWidget);
    final activeVoiceTile = find.byKey(const Key('reset-active-voice-toggle'));
    await tester.ensureVisible(activeVoiceTile);
    await tester.tap(
      find.descendant(of: activeVoiceTile, matching: find.byType(Switch)),
    );
    await tester.pump();
    expect(find.byKey(const Key('reset-active-voice-volume')), findsNothing);
    expect(
      find.byKey(const Key('reset-active-ambient-toggle')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('reset-active-ambient-volume')),
      findsOneWidget,
    );
    expect(find.textContaining('Deep Drift'), findsOneWidget);
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

  testWidgets('Breathing guide remains readable on a narrow phone', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(320, 760));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await _pumpResetHub(tester, preferences: await _preferences());

    expect(
      find.byKey(const Key('reset-breathing-method-guide')),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('Reset remains overflow-free on a narrow phone', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(320, 640));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await _pumpResetHub(tester, preferences: await _preferences());

    expect(tester.takeException(), isNull);

    await _selectGroup(tester, ResetDiscoveryGroup.bodyMindReset);
    await _openResetCard(tester, '60s-grounding');

    expect(
      find.byKey(const Key('reset-session-preview-sheet')),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('Reset purpose selection works at 200% text on a narrow phone', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(320, 640));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await _pumpResetHub(
      tester,
      preferences: await _preferences(),
      textScale: 2,
    );
    for (final group in ResetDiscoveryGroup.values) {
      await _selectGroup(tester, group);
      expect(find.byKey(Key('reset-group-${group.name}')), findsOneWidget);
      expect(tester.takeException(), isNull);
    }
    expect(
      find.byKey(const Key('reset-content-60s-grounding')),
      findsOneWidget,
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
      tester
          .getSize(find.byKey(const Key('reset-group-breathingMethods')))
          .width,
      lessThanOrEqualTo(720),
    );
  });
}
