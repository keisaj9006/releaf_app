import '../../features/brain/domain/brain_level.dart';
import '../../features/brain/presentation/widgets/brain_difficulty_selector.dart';

class NBackLevelProfile {
  const NBackLevelProfile({
    required this.depth,
    required this.trialCount,
    required this.seed,
    required this.matchChance,
  });

  final int depth;
  final int trialCount;
  final int seed;
  final double matchChance;
}

NBackLevelProfile nBackProfileForLevel(
  int rawLevel,
  BrainDifficulty difficulty,
) {
  final level = rawLevel.clamp(1, maxBrainProfileLevel).toInt();
  final seed = 9049 + level * 271 + difficulty.index * 991;
  if (level <= 12) {
    final index = level - 1;
    final baseDepth = difficulty.index + 1;
    final extra = switch (difficulty) {
      BrainDifficulty.easy => index >= 9 ? 1 : 0,
      BrainDifficulty.medium => index >= 7 ? 1 : 0,
      BrainDifficulty.hard => index >= 8 ? 1 : 0,
    };
    return NBackLevelProfile(
      depth: (baseDepth + extra).clamp(1, 4),
      trialCount: 12 + difficulty.index * 3 + index ~/ 2,
      seed: seed,
      matchChance: 0.34,
    );
  }

  final context = BrainLevelContext(level);
  return NBackLevelProfile(
    depth: (difficulty.index + 2 + context.bandIndex ~/ 2).clamp(1, 4),
    trialCount:
        (18 +
                context.bandIndex * 3 +
                context.stepInBand ~/ 3 +
                difficulty.index * 3)
            .clamp(18, 38),
    seed: seed,
    matchChance: 0.34,
  );
}
