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

  testWidgets('/brain renders the canonical BrainScreen', (
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
    for (final game in brainGames.where((game) => game.enabled)) {
      expect(find.text(game.title), findsOneWidget);
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
