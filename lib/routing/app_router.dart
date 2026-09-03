import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'app_routes.dart';
import 'scaffold_with_nav.dart';

import '../features/home/home_screen.dart';
import '../features/habits/presentation/habits_screen.dart';
import '../features/relief/presentation/relief_screen.dart';
import '../features/relief/presentation/breathing_widget.dart';
import '../legacy/screens/games_screen.dart';
import '../features/brain/presentation/game_result_screen.dart';
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
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return ScaffoldWithNavBar(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.home,
              pageBuilder: (context, state) => _fadePage(const HomeScreen()),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.habits,
              pageBuilder: (context, state) => _fadePage(const HabitsScreen()),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.relief,
              pageBuilder: (context, state) => _fadePage(const ReliefScreen()),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.brain,
              pageBuilder: (context, state) => _fadePage(const GamesScreen()),
            ),
          ],
        ),
      ],
    ),

    GoRoute(
      path: AppRoutes.reliefSession,
      pageBuilder: (context, state) {
        final sessionId = state.pathParameters['sessionId'] ?? '';
        return _fadePage(BreathingWidget(sessionId: sessionId));
      },
    ),

    GoRoute(
      path: '/brain-result',
      pageBuilder: (context, state) {
        final score = state.extra is int ? state.extra as int : null;
        return _fadePage(GameResultScreen(score: score));
      },
    ),

    GoRoute(
      path: AppRoutes.dailyLoop,
      pageBuilder: (context, state) => _fadePage(const DailyLoopScreen()),
    ),

    GoRoute(
      path: AppRoutes.dashboardLegacy,
      redirect: (_, _) => AppRoutes.home,
    ),
    GoRoute(
      path: AppRoutes.gamesLegacy,
      redirect: (_, _) => AppRoutes.brain,
    ),
    GoRoute(
      path: AppRoutes.mathRaceLegacy,
      redirect: (_, _) => AppRoutes.brain,
    ),
    GoRoute(
      path: AppRoutes.labirynthStatsLegacy,
      redirect: (_, _) => AppRoutes.brain,
    ),
  ],
);
