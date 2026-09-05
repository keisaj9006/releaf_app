// FILE: lib/features/brain/presentation/game_host_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../routing/app_routes.dart';
import '../../../legacy/screens/memory_game_screen.dart';
import '../../../legacy/screens/labirynth_game_screen.dart';
import '../../../games/math_race/math_race_screen.dart';
import '../../../legacy/screens/broken_mirror_game_screen.dart';
import '../../../games/rule_shift/rule_shift_screen.dart';
import 'game_result_screen.dart';

const supportedBrainGameIds = <String>{
  'memory',
  'labyrinth',
  'math_race',
  'broken_mirror',
  'rule_shift',
};

bool isSupportedBrainGame(String gameId) =>
    supportedBrainGameIds.contains(gameId);

Widget buildBrainGame({
  required String gameId,
  required ValueChanged<int?> onFinish,
}) {
  return switch (gameId) {
    'memory' => MemoryGameScreen(onFinish: onFinish),
    'labyrinth' => LabirynthGameScreen(onFinish: onFinish),
    'math_race' => MathRaceScreen(onFinish: onFinish),
    'broken_mirror' => BrokenMirrorGameScreen(onFinish: () => onFinish(null)),
    'rule_shift' => RuleShiftScreen(onFinish: onFinish),
    _ => _UnknownGame(gameId: gameId),
  };
}

class GameHostScreen extends StatelessWidget {
  const GameHostScreen({super.key, required this.gameId});
  final String gameId;

  @override
  Widget build(BuildContext context) {
    final child = buildBrainGame(
      gameId: gameId,
      onFinish: (score) => _finish(context, score),
    );

    return Scaffold(
      body: SafeArea(child: child),
    );
  }

  void _finish(BuildContext context, int? score) {
    if (!context.mounted) return;
    context.go(
      AppRoutes.brainResult,
      extra: BrainGameResult(gameId: gameId, score: score),
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
