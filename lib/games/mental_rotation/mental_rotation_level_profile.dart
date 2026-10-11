import '../../features/brain/domain/brain_level.dart';
import '../../features/brain/presentation/widgets/brain_difficulty_selector.dart';

class MentalRotationLevelProfile {
  const MentalRotationLevelProfile({
    required this.level,
    required this.gridSide,
    required this.roundCount,
    required this.filledCells,
    required this.minimumQuarterTurns,
  });

  final int level;
  final int gridSide;
  final int roundCount;
  final int filledCells;
  final int minimumQuarterTurns;
}

MentalRotationLevelProfile mentalRotationProfileForLevel(
  int rawLevel,
  BrainDifficulty difficulty,
) {
  final level = rawLevel.clamp(1, maxBrainProfileLevel).toInt();

  if (level <= 12) {
    final index = level - 1;
    final gridSide = level >= 9
        ? 5
        : level >= 5
        ? 4
        : 3;
    final roundBase = switch (difficulty) {
      BrainDifficulty.easy => 6,
      BrainDifficulty.medium => 8,
      BrainDifficulty.hard => 10,
    };
    final fillBase = switch (difficulty) {
      BrainDifficulty.easy => gridSide + 1,
      BrainDifficulty.medium => gridSide + 2,
      BrainDifficulty.hard => gridSide + 3,
    };

    return MentalRotationLevelProfile(
      level: level,
      gridSide: gridSide,
      roundCount: roundBase + index ~/ 4,
      filledCells: fillBase.clamp(4, (gridSide * gridSide) - 2).toInt(),
      minimumQuarterTurns: 0,
    );
  }

  final context = BrainLevelContext(level);
  final gridSide = context.bandIndex >= 2 ? 6 : 5;
  final roundBase = switch (difficulty) {
    BrainDifficulty.easy => 8,
    BrainDifficulty.medium => 10,
    BrainDifficulty.hard => 12,
  };
  final fillBase = switch (difficulty) {
    BrainDifficulty.easy => gridSide + 1,
    BrainDifficulty.medium => gridSide + 2,
    BrainDifficulty.hard => gridSide + 3,
  };

  return MentalRotationLevelProfile(
    level: level,
    gridSide: gridSide,
    roundCount: (roundBase + context.bandIndex + context.stepInBand ~/ 4)
        .clamp(roundBase, 17)
        .toInt(),
    filledCells:
        (fillBase + context.bandIndex - 1 + context.stepInBand ~/ 5)
            .clamp(5, (gridSide * gridSide) - 4)
            .toInt(),
    minimumQuarterTurns: context.bandIndex >= 2 ? 1 : 0,
  );
}
