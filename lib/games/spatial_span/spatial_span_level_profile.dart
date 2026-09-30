import '../../features/brain/domain/brain_level.dart';
import '../../features/brain/presentation/widgets/brain_difficulty_selector.dart';

class SpatialSpanLevelProfile {
  const SpatialSpanLevelProfile({
    required this.gridSide,
    required this.sequenceLength,
    required this.onMs,
    required this.gapMs,
    required this.seed,
  });

  final int gridSide;
  final int sequenceLength;
  final int onMs;
  final int gapMs;
  final int seed;
}

SpatialSpanLevelProfile spatialSpanProfileForLevel(
  int rawLevel,
  BrainDifficulty difficulty,
  int round,
) {
  final level = rawLevel.clamp(1, maxBrainProfileLevel).toInt();
  final safeRound = round.clamp(1, 3).toInt();
  final seed = 1733 + level * 1009 + difficulty.index * 4093 + safeRound * 7919;
  if (level <= 12) {
    final index = level - 1;
    final gridSide = switch (difficulty) {
      BrainDifficulty.easy => level >= 10 ? 4 : 3,
      BrainDifficulty.medium => level >= 8 ? 5 : 4,
      BrainDifficulty.hard => level >= 7 ? 5 : 4,
    };
    final penalty = switch (difficulty) {
      BrainDifficulty.easy => 0,
      BrainDifficulty.medium => 55,
      BrainDifficulty.hard => 105,
    };
    return SpatialSpanLevelProfile(
      gridSide: gridSide,
      sequenceLength: (3 + difficulty.index + index ~/ 2 + safeRound - 1).clamp(
        3,
        11,
      ),
      onMs: (620 - index * 20 - penalty).clamp(260, 620),
      gapMs: (210 - index * 8).clamp(100, 210),
      seed: seed,
    );
  }

  final context = BrainLevelContext(level);
  return SpatialSpanLevelProfile(
    gridSide: difficulty == BrainDifficulty.easy && context.bandIndex < 3
        ? 4
        : 5,
    sequenceLength:
        (7 +
                context.bandIndex +
                context.stepInBand ~/ 4 +
                difficulty.index +
                safeRound -
                1)
            .clamp(8, 14),
    onMs:
        (410 -
                context.bandIndex * 20 -
                context.stepInBand * 3 -
                difficulty.index * 40)
            .clamp(260, 410),
    gapMs: (135 - context.bandIndex * 5 - context.stepInBand * 2).clamp(
      100,
      135,
    ),
    seed: seed,
  );
}
