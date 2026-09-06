// FILE: lib/features/brain/presentation/game_host_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../routing/app_routes.dart';
import '../../../games/memory/memory_game_screen.dart';
import '../../../games/labyrinth/labyrinth_game_screen.dart';
import '../../../games/math_race/math_race_screen.dart';
import '../../../games/broken_mirror/broken_mirror_game_screen.dart';
import '../../../games/rule_shift/rule_shift_screen.dart';
import '../../../games/sequence_echo/sequence_echo_screen.dart';
import '../../../games/n_back/n_back_screen.dart';
import '../../../games/spatial_span/spatial_span_screen.dart';
import '../../../games/mental_rotation/mental_rotation_screen.dart';
import '../../../games/trail_switch/trail_switch_screen.dart';
import '../../../games/tower_plan/tower_plan_screen.dart';
import '../../../games/symbol_code/symbol_code_screen.dart';
import '../../../games/color_conflict/color_conflict_screen.dart';
import '../../../games/pattern_logic/pattern_logic_screen.dart';
import '../../../games/signal_scan/signal_scan_screen.dart';
import '../application/brain_training_controller.dart';
import 'game_result_screen.dart';

const supportedBrainGameIds = <String>{
  'memory',
  'labyrinth',
  'math_race',
  'broken_mirror',
  'rule_shift',
  'sequence_echo',
  'n_back',
  'spatial_span',
  'mental_rotation',
  'trail_switch',
  'tower_plan',
  'symbol_code',
  'color_conflict',
  'pattern_logic',
  'signal_scan',
};

bool isSupportedBrainGame(String gameId) =>
    supportedBrainGameIds.contains(gameId);

Widget buildBrainGame({
  required String gameId,
  required ValueChanged<int?> onFinish,
  int trainingLevel = 1,
}) {
  return switch (gameId) {
    'memory' => MemoryGameScreen(onFinish: onFinish),
    'labyrinth' => LabirynthGameScreen(
        onFinish: onFinish,
        trainingLevel: trainingLevel,
      ),
    'math_race' => MathRaceScreen(
        onFinish: onFinish,
        trainingLevel: trainingLevel,
      ),
    'broken_mirror' => BrokenMirrorGameScreen(
        level: trainingLevel,
        enableTimer: trainingLevel >= 4,
        seconds: (75 - ((trainingLevel - 4) * 3)).clamp(48, 75).toInt(),
        onFinish: () => onFinish(null),
      ),
    'rule_shift' => RuleShiftScreen(
        onFinish: onFinish,
        trainingLevel: trainingLevel,
      ),
    'sequence_echo' => SequenceEchoScreen(
        onFinish: onFinish,
        trainingLevel: trainingLevel,
      ),
    'n_back' => NBackScreen(
        onFinish: onFinish,
        trainingLevel: trainingLevel,
      ),
    'spatial_span' => SpatialSpanScreen(
        onFinish: onFinish,
        trainingLevel: trainingLevel,
      ),
    'mental_rotation' => MentalRotationScreen(
        onFinish: onFinish,
        trainingLevel: trainingLevel,
      ),
    'trail_switch' => TrailSwitchScreen(
        onFinish: onFinish,
        trainingLevel: trainingLevel,
      ),
    'tower_plan' => TowerPlanScreen(
        onFinish: onFinish,
        trainingLevel: trainingLevel,
      ),
    'symbol_code' => SymbolCodeScreen(
        onFinish: onFinish,
        trainingLevel: trainingLevel,
      ),
    'color_conflict' => ColorConflictScreen(
        onFinish: onFinish,
        trainingLevel: trainingLevel,
      ),
    'pattern_logic' => PatternLogicScreen(
        onFinish: onFinish,
        trainingLevel: trainingLevel,
      ),
    'signal_scan' => SignalScanScreen(
        onFinish: onFinish,
        trainingLevel: trainingLevel,
      ),
    _ => _UnknownGame(gameId: gameId),
  };
}

class GameHostScreen extends ConsumerWidget {
  const GameHostScreen({super.key, required this.gameId});
  final String gameId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trainingLevel = ref.watch(
      brainTrainingControllerProvider.select(
        (state) => state.trainingLevelFor(gameId),
      ),
    );
    final child = buildBrainGame(
      gameId: gameId,
      onFinish: (score) => _finish(context, score),
      trainingLevel: trainingLevel,
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
