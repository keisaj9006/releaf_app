// FILE: lib/features/brain/presentation/game_host_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../routing/app_routes.dart';
import '../../../legacy/screens/memory_game_screen.dart';
import '../../../legacy/screens/labirynth_game_screen.dart';
import '../../../games/math_race/math_race_screen.dart';
import '../../../legacy/screens/broken_mirror_game_screen.dart';

class GameHostScreen extends StatelessWidget {
  const GameHostScreen({super.key, required this.gameId});
  final String gameId;

  @override
  Widget build(BuildContext context) {
    final Widget child = switch (gameId) {
      'memory' => const MemoryGameScreen(),
      'labyrinth' => const LabirynthGameScreen(),
      'math_race' => const MathRaceScreen(),
      'broken_mirror' => const BrokenMirrorGameScreen(),
      _ => _UnknownGame(gameId: gameId),
    };

    return Scaffold(
      body: SafeArea(child: child),
    );
  }
}

class _UnknownGame extends StatelessWidget {
  const _UnknownGame({required this.gameId});
  final String gameId;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Unknown game: $gameId'),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: () => context.go(AppRoutes.brain),
            child: const Text('Back to Brain'),
          ),
        ],
      ),
    );
  }
}
