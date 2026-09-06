import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'app_routes.dart';
import 'scaffold_with_nav.dart';

import '../features/home/home_screen.dart';
import '../features/habits/presentation/habits_screen.dart';
import '../features/relief/presentation/relief_screen.dart';
import '../features/relief/presentation/relief_session_gate.dart';
import '../features/relief/domain/models/reset_launch_options.dart';
import '../features/brain/presentation/brain_screen.dart';
import '../features/sound/presentation/sound_screen.dart';
import '../features/sound/presentation/sound_player_screen.dart';
import '../features/meditation/presentation/meditation_screen.dart';
import '../features/meditation/presentation/meditation_session_gate.dart';
import '../features/meditation/domain/meditation_resume_state.dart';
import '../features/sleep/presentation/sleep_screen.dart';
import '../features/brain/presentation/game_host_screen.dart';
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

GoRouter createAppRouter({String initialLocation = AppRoutes.home}) => GoRouter(
  initialLocation: initialLocation,
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
              path: AppRoutes.relief,
              pageBuilder: (context, state) => _fadePage(const ReliefScreen()),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.brain,
              pageBuilder: (context, state) => _fadePage(const BrainScreen()),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.meditate,
              pageBuilder: (context, state) =>
                  _fadePage(const MeditationScreen()),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.sleep,
              pageBuilder: (context, state) => _fadePage(const SleepScreen()),
            ),
          ],
        ),
      ],
    ),

    GoRoute(
      path: AppRoutes.meditationSession,
      pageBuilder: (context, state) {
        final meditationId = state.pathParameters['meditationId'] ?? '';
        final resumeState = state.extra is MeditationResumeState
            ? state.extra! as MeditationResumeState
            : null;
        return _fadePage(
          MeditationSessionGate(
            meditationId: meditationId,
            resumeState: resumeState,
          ),
        );
      },
    ),

    GoRoute(
      path: AppRoutes.habits,
      pageBuilder: (context, state) => _fadePage(const HabitsScreen()),
    ),

    GoRoute(
      path: AppRoutes.sound,
      pageBuilder: (context, state) => _fadePage(const SoundScreen()),
    ),

    GoRoute(
      path: AppRoutes.soundPlayer,
      pageBuilder: (context, state) {
        final trackId = state.pathParameters['trackId'] ?? '';
        return _fadePage(SoundPlayerScreen(trackId: trackId));
      },
    ),

    GoRoute(
      path: AppRoutes.reliefSession,
      pageBuilder: (context, state) {
        final sessionId = state.pathParameters['sessionId'] ?? '';
        final options = state.extra is ResetLaunchOptions
            ? state.extra! as ResetLaunchOptions
            : const ResetLaunchOptions();
        return _fadePage(
          ReliefSessionGate(
            sessionId: sessionId,
            launchOptions: options,
          ),
        );
      },
    ),

    GoRoute(
      path: AppRoutes.brainGame,
      pageBuilder: (context, state) {
        final gameId = state.pathParameters['gameId'] ?? '';
        return _fadePage(GameHostScreen(gameId: gameId));
      },
    ),

    GoRoute(
      path: AppRoutes.brainResult,
      pageBuilder: (context, state) {
        final result = state.extra;
        return _fadePage(
          GameResultScreen(
            gameId: result is BrainGameResult ? result.gameId : null,
            score: result is BrainGameResult ? result.score : null,
            completed: result is BrainGameResult,
          ),
        );
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

final GoRouter appRouter = createAppRouter();
