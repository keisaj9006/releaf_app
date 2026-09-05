import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:releaf_app/core/providers.dart';
import 'package:releaf_app/features/brain/application/brain_training_controller.dart';
import 'package:releaf_app/features/brain/data/game_registry.dart';
import 'package:releaf_app/features/brain/presentation/brain_screen.dart';
import 'package:releaf_app/features/brain/presentation/game_host_screen.dart';
import 'package:releaf_app/features/brain/presentation/game_result_screen.dart';
import 'package:releaf_app/features/progress/data/leaves_repository.dart';
import 'package:releaf_app/games/math_race/math_race_screen.dart';
import 'package:releaf_app/games/rule_shift/rule_shift_screen.dart';
import 'package:releaf_app/legacy/screens/broken_mirror_game_screen.dart';
import 'package:releaf_app/legacy/screens/labirynth_game_screen.dart';
import 'package:releaf_app/legacy/screens/memory_game_screen.dart';
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
