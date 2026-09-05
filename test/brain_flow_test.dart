import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:releaf_app/core/providers.dart';
import 'package:releaf_app/features/brain/data/game_registry.dart';
import 'package:releaf_app/features/brain/presentation/brain_screen.dart';
import 'package:releaf_app/features/brain/presentation/game_host_screen.dart';
import 'package:releaf_app/features/brain/presentation/game_result_screen.dart';
import 'package:releaf_app/features/progress/data/leaves_repository.dart';
import 'package:releaf_app/games/math_race/math_race_screen.dart';
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
    expect(find.text('DAILY BRAIN WORKOUT'), findsOneWidget);
    expect(find.text('Train your mind today.'), findsOneWidget);
    expect(find.text('YOUR TRAINING'), findsOneWidget);
    expect(find.text('GAMES'), findsOneWidget);

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

    expect(find.text('Memory'), findsWidgets);
    expect(find.text('Spatial focus'), findsWidgets);
    expect(find.text('Mental calculation'), findsWidgets);
    expect(find.text('Visual patterns'), findsWidgets);

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

    await tester.pumpWidget(const MaterialApp(home: BrainScreen()));
    await tester.pump();

    expect(find.byType(BrainScreen), findsOneWidget);
    expect(find.text('DAILY BRAIN WORKOUT'), findsOneWidget);
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

    expect(find.text('Start with Memory'), findsOneWidget);
    await tester.tap(find.text('Start with Memory'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));

    expect(find.byType(MemoryGameScreen), findsOneWidget);
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
