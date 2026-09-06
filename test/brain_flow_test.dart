import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sensors_plus/sensors_plus.dart';

import 'package:releaf_app/core/providers.dart';
import 'package:releaf_app/features/brain/application/brain_training_controller.dart';
import 'package:releaf_app/features/brain/data/game_registry.dart';
import 'package:releaf_app/features/brain/presentation/brain_screen.dart';
import 'package:releaf_app/features/brain/presentation/game_host_screen.dart';
import 'package:releaf_app/features/brain/presentation/game_result_screen.dart';
import 'package:releaf_app/features/progress/data/leaves_repository.dart';
import 'package:releaf_app/games/math_race/math_race_screen.dart';
import 'package:releaf_app/games/rule_shift/rule_shift_screen.dart';
import 'package:releaf_app/games/sequence_echo/sequence_echo_screen.dart';
import 'package:releaf_app/games/n_back/n_back_screen.dart';
import 'package:releaf_app/games/spatial_span/spatial_span_screen.dart';
import 'package:releaf_app/games/mental_rotation/mental_rotation_screen.dart';
import 'package:releaf_app/games/trail_switch/trail_switch_screen.dart';
import 'package:releaf_app/games/tower_plan/tower_plan_screen.dart';
import 'package:releaf_app/games/symbol_code/symbol_code_screen.dart';
import 'package:releaf_app/games/color_conflict/color_conflict_screen.dart';
import 'package:releaf_app/games/pattern_logic/pattern_logic_screen.dart';
import 'package:releaf_app/games/signal_scan/signal_scan_screen.dart';
import 'package:releaf_app/games/broken_mirror/broken_mirror_game_screen.dart';
import 'package:releaf_app/games/labyrinth/labyrinth_game_screen.dart';
import 'package:releaf_app/games/memory/memory_game_screen.dart';
import 'package:releaf_app/routing/app_router.dart';
import 'package:releaf_app/routing/app_routes.dart';

void main() {
  test('Every enabled Brain registry entry resolves to a real game', () {
    final enabledGames = brainGames.where((game) => game.enabled);

    expect(enabledGames, isNotEmpty);
    expect(
      enabledGames.map((game) => game.id),
      everyElement(isIn(supportedBrainGameIds)),
    );

    final resolvedTypes = <String, Type>{
      for (final game in enabledGames)
        game.id: buildBrainGame(
          gameId: game.id,
          onFinish: (_) {},
        ).runtimeType,
    };

    expect(resolvedTypes['memory'], MemoryGameScreen);
    expect(resolvedTypes['labyrinth'], LabirynthGameScreen);
    expect(resolvedTypes['math_race'], MathRaceScreen);
    expect(resolvedTypes['broken_mirror'], BrokenMirrorGameScreen);
    expect(resolvedTypes['rule_shift'], RuleShiftScreen);
    expect(resolvedTypes['sequence_echo'], SequenceEchoScreen);
    expect(resolvedTypes['n_back'], NBackScreen);
    expect(resolvedTypes['spatial_span'], SpatialSpanScreen);
    expect(resolvedTypes['mental_rotation'], MentalRotationScreen);
    expect(resolvedTypes['trail_switch'], TrailSwitchScreen);
    expect(resolvedTypes['tower_plan'], TowerPlanScreen);
    expect(resolvedTypes['symbol_code'], SymbolCodeScreen);
    expect(resolvedTypes['color_conflict'], ColorConflictScreen);
    expect(resolvedTypes['pattern_logic'], PatternLogicScreen);
    expect(resolvedTypes['signal_scan'], SignalScanScreen);
  });

  testWidgets('/brain renders the premium Brain hub with current games only', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final router = createAppRouter(initialLocation: AppRoutes.brain);
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

    expect(find.byType(BrainScreen), findsOneWidget);
    expect(find.text("TODAY'S WORKOUT"), findsOneWidget);
    expect(find.text('Three focused challenges.'), findsOneWidget);
    expect(find.text('THIS WEEK'), findsOneWidget);
    expect(find.text('TRAIN BY SKILL'), findsOneWidget);
    expect(find.text('Memory'), findsWidgets);
    expect(find.text('Attention & control'), findsOneWidget);
    expect(find.text('Logic & reasoning'), findsOneWidget);
    expect(find.text('Spatial & visual'), findsOneWidget);
    expect(find.byKey(const Key('brain-weekly-activity')), findsOneWidget);

    for (final game in brainGames.where((game) => game.enabled)) {
      expect(find.text(game.title), findsWidgets);
      expect(find.byKey(Key('brain-game-card-${game.id}')), findsOneWidget);
    }

    expect(find.text('Laser'), findsNothing);
    expect(find.text('Reactivator'), findsNothing);
    expect(find.textContaining('Coming Soon'), findsNothing);
  });

  testWidgets('Brain does not fabricate numeric skill scores', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(preferences),
        ],
        child: const MaterialApp(home: BrainScreen()),
      ),
    );
    await tester.pump();

    expect(find.text('MEMORY'), findsWidgets);
    expect(find.text('SPATIAL PLANNING'), findsWidgets);
    expect(find.text('CALCULATION'), findsWidgets);
    expect(find.text('VISUAL RECONSTRUCTION'), findsWidgets);
    expect(find.text('ATTENTION SWITCHING'), findsWidgets);
    expect(find.text('WORKING MEMORY'), findsWidgets);
    expect(find.text('WORKING MEMORY UPDATE'), findsWidgets);
    expect(find.text('VISUOSPATIAL MEMORY'), findsWidgets);
    expect(find.text('SPATIAL REASONING'), findsWidgets);
    expect(find.text('VISUAL SEARCH & SWITCHING'), findsWidgets);
    expect(find.text('PLANNING & PROBLEM SOLVING'), findsWidgets);
    expect(find.text('ASSOCIATIVE MAPPING'), findsWidgets);
    expect(find.text('TRAINING'), findsNothing);
    expect(find.text('INHIBITORY CONTROL'), findsWidgets);
    expect(find.text('PATTERN REASONING'), findsWidgets);
    expect(find.text('SELECTIVE ATTENTION'), findsWidgets);

    expect(find.text('72'), findsNothing);
    expect(find.text('64'), findsNothing);
    expect(find.text('81'), findsNothing);
    expect(find.textContaining('%'), findsNothing);
  });

  testWidgets('Brain hub remains overflow-free at 320px width', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(320, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(preferences),
        ],
        child: const MaterialApp(home: BrainScreen()),
      ),
    );
    await tester.pump();

    expect(find.byType(BrainScreen), findsOneWidget);
    expect(find.text("TODAY'S WORKOUT"), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Daily Brain Workout starts with a real supported game', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final router = createAppRouter(initialLocation: AppRoutes.brain);
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

    expect(find.text('Start workout'), findsOneWidget);
    await tester.ensureVisible(find.byKey(const Key('brain-start-workout')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('brain-start-workout')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));

    expect(find.byType(MemoryGameScreen), findsOneWidget);
  });

  test('Brain weekly activity reports real active days and skill variety', () {
    final now = DateTime.now();
    final state = BrainTrainingState(
      records: [
        BrainSessionRecord(
          gameId: 'memory',
          completedAt: now,
          score: 10,
        ),
        BrainSessionRecord(
          gameId: 'labyrinth',
          completedAt: now.subtract(const Duration(days: 1)),
        ),
        BrainSessionRecord(
          gameId: 'memory',
          completedAt: now.subtract(const Duration(days: 1)),
          score: 8,
        ),
      ],
    );

    expect(state.sessionsLast7Days, 3);
    expect(state.activeDaysLast7Days, 2);
    expect(state.distinctGamesLast7Days, 2);
  });

  testWidgets('Daily Brain Workout favours less recently used skills', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final seedController = BrainTrainingController(preferences);
    await seedController.recordCompletion(gameId: 'memory', score: 10);
    seedController.dispose();

    final router = createAppRouter(initialLocation: AppRoutes.brain);
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

    await tester.ensureVisible(find.byKey(const Key('brain-start-workout')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('brain-start-workout')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));

    expect(find.byType(LabirynthGameScreen), findsOneWidget);
  });

  testWidgets('Every visible Brain game card routes to its real game', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(900, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final expectedTypes = <String, Type>{
      'memory': MemoryGameScreen,
      'labyrinth': LabirynthGameScreen,
      'math_race': MathRaceScreen,
      'broken_mirror': BrokenMirrorGameScreen,
      'rule_shift': RuleShiftScreen,
      'sequence_echo': SequenceEchoScreen,
      'n_back': NBackScreen,
      'spatial_span': SpatialSpanScreen,
      'mental_rotation': MentalRotationScreen,
      'trail_switch': TrailSwitchScreen,
      'tower_plan': TowerPlanScreen,
      'symbol_code': SymbolCodeScreen,
      'color_conflict': ColorConflictScreen,
      'pattern_logic': PatternLogicScreen,
      'signal_scan': SignalScanScreen,
    };

    for (final game in brainGames.where((game) => game.enabled)) {
      SharedPreferences.setMockInitialValues({});
      final preferences = await SharedPreferences.getInstance();
      final router = createAppRouter(initialLocation: AppRoutes.brain);

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

      final card = find.byKey(Key('brain-game-card-${game.id}'));
      expect(card, findsOneWidget);
      await tester.ensureVisible(card);
      await tester.pumpAndSettle();
      await tester.tap(card);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 250));

      expect(find.byType(expectedTypes[game.id]!), findsOneWidget);

      router.dispose();
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
    }
  });

  testWidgets('Rule Shift is a real playable Brain exercise', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(preferences),
        ],
        child: const MaterialApp(
          home: GameHostScreen(gameId: 'rule_shift'),
        ),
      ),
    );
    await tester.pump();

    expect(find.byType(RuleShiftScreen), findsOneWidget);
    expect(find.byKey(const Key('rule-shift-prompt')), findsOneWidget);
    expect(find.byKey(const Key('rule-shift-yes')), findsOneWidget);
    expect(find.byKey(const Key('rule-shift-no')), findsOneWidget);
    expect(find.text('IS THE NUMBER ODD?'), findsOneWidget);
  });

  test('Persistent Brain levels advance from completed sessions', () {
    final now = DateTime.now();
    final state = BrainTrainingState(
      records: [
        BrainSessionRecord(
          gameId: 'sequence_echo',
          completedAt: now,
          score: 500,
        ),
        BrainSessionRecord(
          gameId: 'sequence_echo',
          completedAt: now.subtract(const Duration(days: 1)),
          score: 400,
        ),
      ],
    );

    expect(state.completionCountFor('sequence_echo'), 2);
    expect(state.trainingLevelFor('sequence_echo'), 3);
    expect(state.trainingLevelFor('broken_mirror'), 1);
    expect(state.trainingLevelFor('labyrinth'), 1);
    expect(state.trainingLevelFor('math_race'), 1);
    expect(state.trainingLevelFor('n_back'), 1);
    expect(state.trainingLevelFor('spatial_span'), 1);
    expect(state.trainingLevelFor('mental_rotation'), 1);
    expect(state.trainingLevelFor('trail_switch'), 1);
    expect(state.trainingLevelFor('tower_plan'), 1);
    expect(state.trainingLevelFor('symbol_code'), 1);
    expect(state.trainingLevelFor('memory'), 1);
  });

  testWidgets('Game host injects the saved persistent training level', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final controller = BrainTrainingController(preferences);
    await controller.recordCompletion(gameId: 'sequence_echo', score: 300);
    await controller.recordCompletion(gameId: 'sequence_echo', score: 400);
    controller.dispose();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(preferences),
        ],
        child: const MaterialApp(
          home: GameHostScreen(gameId: 'sequence_echo'),
        ),
      ),
    );
    await tester.pump();

    final game = tester.widget<SequenceEchoScreen>(
      find.byType(SequenceEchoScreen),
    );
    expect(game.trainingLevel, 3);
    expect(find.text('L3'), findsOneWidget);
  });

  testWidgets('Memory uses the persistent Brain training level', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final controller = BrainTrainingController(preferences);

    for (var index = 0; index < 3; index++) {
      await controller.recordCompletion(gameId: 'memory', score: 300 + index);
    }
    controller.dispose();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(preferences),
        ],
        child: const MaterialApp(
          home: GameHostScreen(gameId: 'memory'),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    final game = tester.widget<MemoryGameScreen>(
      find.byType(MemoryGameScreen),
    );
    expect(game.trainingLevel, 4);
    expect(find.text('Brain L4'), findsOneWidget);
    expect(find.text('4 pairs'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });

  testWidgets('Labyrinth exposes progressive level and touch fallback', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(420, 840);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      MaterialApp(
        home: LabirynthGameScreen(
          trainingLevel: 6,
          onFinish: (_) {},
          motionStream: const Stream<AccelerometerEvent>.empty(),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('L6'), findsOneWidget);
    expect(find.text('Ready'), findsOneWidget);
    expect(find.byKey(const Key('labyrinth-board')), findsOneWidget);
    expect(find.text('ENTRY'), findsOneWidget);
    expect(find.text('Left'), findsOneWidget);
    expect(find.text('ROUTE'), findsOneWidget);
    expect(
      find.textContaining('Start at the left edge and reach the centre.'),
      findsOneWidget,
    );
    expect(find.textContaining('Drag anywhere'), findsOneWidget);

    final board = find.byKey(const Key('labyrinth-board'));
    await tester.drag(board, const Offset(0, -36));
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text('Ready'), findsNothing);
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });

  testWidgets('Math Race starts from the persistent Brain level', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: MathRaceScreen(
          trainingLevel: 5,
          onFinish: (_) {},
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Brain L5'), findsOneWidget);
    expect(find.text('Puzzle 13'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });

  testWidgets('Game host scales Broken Mirror from saved training level', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final controller = BrainTrainingController(preferences);
    for (var index = 0; index < 4; index++) {
      await controller.recordCompletion(gameId: 'broken_mirror');
    }
    controller.dispose();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(preferences),
        ],
        child: const MaterialApp(
          home: GameHostScreen(gameId: 'broken_mirror'),
        ),
      ),
    );
    await tester.pump();

    final game = tester.widget<BrokenMirrorGameScreen>(
      find.byType(BrokenMirrorGameScreen),
    );
    expect(game.level, 5);
    expect(game.enableTimer, isTrue);
    expect(game.seconds, 72);
    expect(find.textContaining('Level 5:'), findsOneWidget);
  });

  testWidgets('Higher training level materially increases Sequence Echo', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: SequenceEchoScreen(
          trainingLevel: 3,
          onFinish: (_) {},
        ),
      ),
    );
    await tester.pump();

    expect(
      find.descendant(
        of: find.byKey(const Key('sequence-echo-length')),
        matching: find.text('5'),
      ),
      findsOneWidget,
    );
  });

  testWidgets('New Brain difficulty levels materially change the task', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: SequenceEchoScreen(onFinish: (_) {}),
      ),
    );
    await tester.pump();

    expect(
      find.descendant(
        of: find.byKey(const Key('sequence-echo-length')),
        matching: find.text('4'),
      ),
      findsOneWidget,
    );
    await tester.tap(find.byKey(const Key('brain-difficulty-hard')));
    await tester.pump();
    expect(
      find.descendant(
        of: find.byKey(const Key('sequence-echo-length')),
        matching: find.text('5'),
      ),
      findsOneWidget,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: ColorConflictScreen(onFinish: (_) {}),
      ),
    );
    await tester.pump();
    await tester.tap(find.byKey(const Key('brain-difficulty-hard')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('color-conflict-start')));
    await tester.pump();
    expect(find.byKey(const Key('color-conflict-answer-4')), findsOneWidget);

    await tester.pumpWidget(
      MaterialApp(
        home: PatternLogicScreen(onFinish: (_) {}),
      ),
    );
    await tester.pump();
    expect(find.byKey(const Key('pattern-logic-answer-3')), findsOneWidget);
    await tester.tap(find.byKey(const Key('brain-difficulty-hard')));
    await tester.pump();
    expect(find.byKey(const Key('pattern-logic-answer-4')), findsOneWidget);

    await tester.pumpWidget(
      MaterialApp(
        home: SignalScanScreen(onFinish: (_) {}),
      ),
    );
    await tester.pump();
    expect(find.byKey(const Key('signal-scan-cell-24')), findsOneWidget);
    expect(find.byKey(const Key('signal-scan-cell-25')), findsNothing);
    await tester.tap(find.byKey(const Key('brain-difficulty-hard')));
    await tester.pump();
    expect(find.byKey(const Key('signal-scan-cell-35')), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });

  testWidgets('N-Back exposes difficulty and progressive N value', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: NBackScreen(
          trainingLevel: 9,
          onFinish: (_) {},
        ),
      ),
    );
    await tester.pump();

    expect(find.text('N-Back'), findsOneWidget);
    expect(find.text('L9'), findsOneWidget);
    expect(find.text('3-back'), findsOneWidget);

    await tester.tap(find.byKey(const Key('brain-difficulty-hard')));
    await tester.pump();

    expect(find.text('4-back'), findsOneWidget);
    expect(find.byKey(const Key('n-back-stimulus-card')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('N-Back moves from warmup into match decisions', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: NBackScreen(
          trainingLevel: 1,
          onFinish: (_) {},
        ),
      ),
    );
    await tester.pump();

    expect(find.byKey(const Key('n-back-continue')), findsOneWidget);
    await tester.tap(find.byKey(const Key('n-back-continue')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('n-back-continue')));
    await tester.pump();

    expect(find.byKey(const Key('n-back-match')), findsOneWidget);
    expect(find.byKey(const Key('n-back-different')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Spatial Span scales grid and span with level and difficulty', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: SpatialSpanScreen(
          trainingLevel: 9,
          onFinish: (_) {},
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Spatial Span'), findsOneWidget);
    expect(find.text('L9'), findsOneWidget);
    expect(find.byKey(const Key('spatial-span-cell-24')), findsOneWidget);
    expect(find.text('8'), findsWidgets);

    await tester.tap(find.byKey(const Key('brain-difficulty-hard')));
    await tester.pump();

    expect(find.byKey(const Key('spatial-span-cell-24')), findsOneWidget);
    expect(find.text('9'), findsWidgets);
    expect(find.byKey(const Key('spatial-span-board')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Mental Rotation scales grid with persistent level', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: MentalRotationScreen(
          trainingLevel: 10,
          onFinish: (_) {},
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Mental Rotation'), findsOneWidget);
    expect(find.text('L10'), findsOneWidget);
    expect(find.byKey(const Key('mental-left-24')), findsOneWidget);
    expect(find.byKey(const Key('mental-right-24')), findsOneWidget);
    expect(find.text('5×5'), findsOneWidget);

    await tester.tap(find.byKey(const Key('brain-difficulty-hard')));
    await tester.pump();

    expect(find.byKey(const Key('mental-rotation-puzzle')), findsOneWidget);
    expect(find.byKey(const Key('mental-rotation-same')), findsOneWidget);
    expect(find.byKey(const Key('mental-rotation-mirrored')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Trail Switch hard mode adds distractors and larger grid', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: TrailSwitchScreen(
          trainingLevel: 10,
          onFinish: (_) {},
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Trail Switch'), findsOneWidget);
    expect(find.text('L10'), findsOneWidget);
    expect(find.byKey(const Key('trail-switch-target-0')), findsOneWidget);
    expect(find.byKey(const Key('trail-switch-distractor-0')), findsNothing);

    await tester.tap(find.byKey(const Key('brain-difficulty-hard')));
    await tester.pump();

    expect(find.byKey(const Key('trail-switch-distractor-0')), findsOneWidget);
    expect(find.byKey(const Key('trail-switch-board')), findsOneWidget);
    expect(find.byKey(const Key('trail-switch-progress')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Tower Plan scales discs and enforces legal moves', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: TowerPlanScreen(
          trainingLevel: 9,
          onFinish: (_) {},
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Tower Plan'), findsOneWidget);
    expect(find.text('L9'), findsOneWidget);
    expect(find.byKey(const Key('tower-plan-peg-0')), findsOneWidget);
    expect(find.byKey(const Key('tower-plan-peg-1')), findsOneWidget);
    expect(find.byKey(const Key('tower-plan-peg-2')), findsOneWidget);
    expect(find.text('5'), findsWidgets);

    await tester.tap(find.byKey(const Key('brain-difficulty-hard')));
    await tester.pump();

    expect(find.text('6'), findsWidgets);
    expect(find.byKey(const Key('tower-plan-disc-0-6')), findsOneWidget);

    await tester.tap(find.byKey(const Key('tower-plan-peg-0')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('tower-plan-peg-1')));
    await tester.pump();

    expect(find.byKey(const Key('tower-plan-disc-1-1')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Symbol Code scales mapping and answer set by difficulty', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: SymbolCodeScreen(
          trainingLevel: 4,
          onFinish: (_) {},
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Symbol Code'), findsOneWidget);
    expect(find.text('L4'), findsOneWidget);
    expect(find.byKey(const Key('symbol-code-key-6')), findsOneWidget);
    expect(find.byKey(const Key('symbol-code-key-7')), findsNothing);
    expect(find.byKey(const Key('symbol-code-options')), findsOneWidget);

    await tester.tap(find.byKey(const Key('brain-difficulty-hard')));
    await tester.pump();

    expect(find.byKey(const Key('symbol-code-key-7')), findsOneWidget);
    expect(find.byKey(const Key('symbol-code-target')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('New Brain games stay overflow-free at 320px', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(320, 760);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final games = <Widget>[
      SequenceEchoScreen(onFinish: (_) {}),
      ColorConflictScreen(onFinish: (_) {}),
      PatternLogicScreen(onFinish: (_) {}),
      SignalScanScreen(onFinish: (_) {}),
      NBackScreen(onFinish: (_) {}),
      SpatialSpanScreen(onFinish: (_) {}),
      MentalRotationScreen(onFinish: (_) {}),
      TrailSwitchScreen(onFinish: (_) {}),
      TowerPlanScreen(onFinish: (_) {}),
      SymbolCodeScreen(onFinish: (_) {}),
    ];

    for (final game in games) {
      await tester.pumpWidget(MaterialApp(home: game));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 120));
      expect(tester.takeException(), isNull);

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
    }
  });

  testWidgets('Premium Brain game shells remain usable on a phone', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(360, 760);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(
      MaterialApp(
        home: MemoryGameScreen(onFinish: (_) {}),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 120));

    expect(find.text('Pattern Match'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(
      const MaterialApp(
        home: MathRaceScreen(),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 120));

    expect(find.text('Math Race'), findsOneWidget);
    expect(find.byKey(const Key('math-race-puzzle-card')), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });

  testWidgets('Broken Mirror snaps a dragged shard into its target', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(420, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(preferences),
        ],
        child: MaterialApp(
          home: BrokenMirrorGameScreen(onFinish: () {}),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 120));

    final board = find.byKey(const Key('broken-mirror-board'));
    final shard = find.byKey(const Key('broken-mirror-shard-5'));
    expect(board, findsOneWidget);
    expect(shard, findsOneWidget);
    expect(tester.takeException(), isNull);

    final boardRect = tester.getRect(board);
    final shardRect = tester.getRect(shard);
    final target = boardRect.topLeft +
        Offset(
          boardRect.width * 0.55,
          boardRect.height * 0.68,
        );

    final gesture = await tester.startGesture(shardRect.center);
    await gesture.moveTo(target);
    await gesture.up();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 120));

    expect(find.byKey(const Key('broken-mirror-shard-5')), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Opening a Brain game alone does not mark Brain complete', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(preferences),
        todayProvider.overrideWithValue('2026-09-03'),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          home: GameHostScreen(gameId: 'memory'),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 20));

    final state = container.read(leavesNotifierProvider);
    expect(state.brainDone, isFalse);
    expect(state.totalLeaves, 0);
  });

  testWidgets('Memory completion reaches the shared result and awards once', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(preferences),
        todayProvider.overrideWithValue('2026-09-03'),
      ],
    );
    addTearDown(container.dispose);
    final router = createAppRouter(
      initialLocation: AppRoutes.brainGameFor('memory'),
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 20));

    final memory = tester.widget<MemoryGameScreen>(
      find.byType(MemoryGameScreen),
    );
    memory.onFinish!(123);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));
    await tester.pump();

    expect(find.byType(GameResultScreen), findsOneWidget);
    expect(find.text('123'), findsOneWidget);
    expect(container.read(leavesNotifierProvider).brainDone, isTrue);
    expect(container.read(leavesNotifierProvider).totalLeaves, 2);

    final training = container.read(brainTrainingControllerProvider);
    expect(training.totalSessions, 1);
    expect(training.bestScoreFor('memory'), 123);

    await tester.ensureVisible(find.text('Back to Brain'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Back to Brain'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));
    expect(find.byType(BrainScreen), findsOneWidget);
  });

  testWidgets('An uncompleted result route does not award Brain leaves', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(preferences),
        todayProvider.overrideWithValue('2026-09-03'),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: GameResultScreen()),
      ),
    );
    await tester.pump();
    await tester.pump();

    final state = container.read(leavesNotifierProvider);
    expect(state.brainDone, isFalse);
    expect(state.totalLeaves, 0);
  });
}
