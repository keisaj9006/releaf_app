// FILE: lib/routing/app_router.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'app_routes.dart';
import 'scaffold_with_nav.dart';

// Tabs (NOWY świat: features/*)
import '../features/home/home_screen.dart';
import '../features/habits/presentation/habits_screen.dart';
import '../features/relief/presentation/relief_screen.dart';
import '../features/brain/presentation/brain_screen.dart';

// Brain flow
import '../features/brain/presentation/game_host_screen.dart';
import '../features/brain/presentation/game_result_screen.dart';

// Fullscreen flow
import '../features/home/daily_loop_screen.dart';

CustomTransitionPage<void> _fadePage(Widget child) {
  return CustomTransitionPage<void>(
    child: child,
    transitionDuration: const Duration(milliseconds: 220),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(opacity: animation, child: child);
    },
  );
}

final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.home,

  errorPageBuilder: (context, state) {
    return _fadePage(
      Scaffold(
        appBar: AppBar(title: const Text('Page Not Found')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('GoException: no routes for location: ${state.uri}'),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () => context.go(AppRoutes.home),
                child: const Text('Home'),
              ),
            ],
          ),
        ),
      ),
    );
  },

  routes: [
    // ---- SHELL: Bottom tabs ----
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return ScaffoldWithNavBar(navigationShell: navigationShell);
      },
      branches: [
        // HOME
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.home,
              pageBuilder: (context, state) => _fadePage(const HomeScreen()),
            ),
          ],
        ),

        // HABITS
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.habits,
              pageBuilder: (context, state) => _fadePage(const HabitsScreen()),
            ),
          ],
        ),

        // RELIEF
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.relief,
              pageBuilder: (context, state) => _fadePage(const ReliefScreen()),
            ),
          ],
        ),

        // BRAIN
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.brain,
              pageBuilder: (context, state) => _fadePage(const BrainScreen()),
              routes: [
                GoRoute(
                  path: AppRoutes.brainGame,
                  pageBuilder: (context, state) {
                    final gameId = state.pathParameters['gameId']!;
                    return _fadePage(GameHostScreen(gameId: gameId));
                  },
                ),
                GoRoute(
                  path: AppRoutes.brainResult,
                  pageBuilder: (context, state) {
                    final score = state.extra is int ? state.extra as int : null;
                    return _fadePage(GameResultScreen(score: score));
                  },
                ),
              ],
            ),
          ],
        ),
      ],
    ),

    // ---- DAILY LOOP (pełny ekran, poza tabami) ----
    GoRoute(
      path: AppRoutes.dailyLoop,
      pageBuilder: (context, state) => _fadePage(const DailyLoopScreen()),
    ),

    // ---- LEGACY ALIASES (bez 404) ----
    GoRoute(
      path: AppRoutes.dashboardLegacy,
      redirect: (_, __) => AppRoutes.home,
    ),
    GoRoute(
      path: AppRoutes.gamesLegacy,
      redirect: (_, __) => AppRoutes.brain,
    ),
    GoRoute(
      path: AppRoutes.mathRaceLegacy,
      redirect: (_, __) => '${AppRoutes.brain}/game/math_race',
    ),
    GoRoute(
      path: AppRoutes.labirynthStatsLegacy,
      redirect: (_, __) => AppRoutes.brain,
    ),
  ],
);