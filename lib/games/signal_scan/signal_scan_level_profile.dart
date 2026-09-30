import '../../features/brain/domain/brain_level.dart';
import '../../features/brain/presentation/widgets/brain_difficulty_selector.dart';

class SignalScanLevelProfile {
  const SignalScanLevelProfile({
    required this.effectiveDifficulty,
    required this.gridSize,
    required this.totalRounds,
    required this.symbolSize,
    required this.targetIndices,
  });

  final BrainDifficulty effectiveDifficulty;
  final int gridSize;
  final int totalRounds;
  final double symbolSize;
  final List<int> targetIndices;
  int get targetCount => targetIndices.length;
}

SignalScanLevelProfile signalScanProfileForLevel(
  int rawLevel,
  BrainDifficulty difficulty,
  int rawRound,
) {
  final level = rawLevel.clamp(1, maxBrainProfileLevel).toInt();
  final round = rawRound < 0 ? 0 : rawRound;
  if (level <= 12) {
    final index = level - 1;
    final pressureRound = round + index ~/ 3;
    final effective = switch (difficulty) {
      BrainDifficulty.easy when pressureRound >= 4 => BrainDifficulty.medium,
      BrainDifficulty.medium when pressureRound >= 4 => BrainDifficulty.hard,
      _ => difficulty,
    };
    final base = switch (effective) {
      BrainDifficulty.easy => round < 2 ? 4 : 5,
      BrainDifficulty.medium => round < 3 ? 5 : 6,
      BrainDifficulty.hard => round < 4 ? 6 : 7,
    };
    final gridSize = (base + index ~/ 4).clamp(4, 8);
    final baseRounds = switch (difficulty) {
      BrainDifficulty.easy => 6,
      BrainDifficulty.medium => 8,
      BrainDifficulty.hard => 10,
    };
    final symbolBase = gridSize >= 6 ? 21.0 : 27.0;
    return SignalScanLevelProfile(
      effectiveDifficulty: effective,
      gridSize: gridSize,
      totalRounds: baseRounds + index ~/ 2,
      symbolSize: (symbolBase - index * 0.55).clamp(14.0, 27.0),
      targetIndices: List<int>.unmodifiable([
        (round * 7 + 3 + effective.index * 2) % (gridSize * gridSize),
      ]),
    );
  }

  final context = BrainLevelContext(level);
  const gridSize = 5;
  final targetCount = context.bandIndex >= 3 ? 3 : 2;
  final totalRounds =
      (5 + context.bandIndex + context.stepInBand ~/ 5 + difficulty.index)
          .clamp(6, 11);
  final first = (round * 7 + 3 + difficulty.index * 2 + level * 11) % 25;
  return SignalScanLevelProfile(
    effectiveDifficulty: difficulty,
    gridSize: gridSize,
    totalRounds: totalRounds,
    symbolSize: 24,
    targetIndices: List<int>.unmodifiable([
      for (var i = 0; i < targetCount; i++) (first + i * 9) % 25,
    ]),
  );
}
