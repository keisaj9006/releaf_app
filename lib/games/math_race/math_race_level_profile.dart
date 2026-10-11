import '../../features/brain/domain/brain_level.dart';
import '../../features/brain/presentation/widgets/brain_difficulty_selector.dart';

class MathRaceLevelProfile {
  const MathRaceLevelProfile({
    required this.level,
    required this.startingPuzzleLevel,
    required this.optionCount,
  });

  final int level;
  final int startingPuzzleLevel;
  final int optionCount;
}

MathRaceLevelProfile mathRaceProfileForLevel(
  int rawLevel,
  BrainDifficulty difficulty,
) {
  final level = rawLevel.clamp(1, maxBrainProfileLevel).toInt();
  final offset = switch (difficulty) {
    BrainDifficulty.easy => -2,
    BrainDifficulty.medium => 0,
    BrainDifficulty.hard => 2,
  };

  if (level <= 12) {
    final baseline = 1 + ((level - 1) * 3);
    return MathRaceLevelProfile(
      level: level,
      startingPuzzleLevel: (baseline + offset).clamp(1, 36).toInt(),
      optionCount: 4,
    );
  }

  final context = BrainLevelContext(level);
  final baseline = 37 + ((level - 13) * 2);
  final highLevelOffset = switch (difficulty) {
    BrainDifficulty.easy => -4,
    BrainDifficulty.medium => 0,
    BrainDifficulty.hard => 4,
  };

  return MathRaceLevelProfile(
    level: level,
    startingPuzzleLevel: (baseline + highLevelOffset).clamp(37, 120).toInt(),
    optionCount: context.bandIndex >= 4
        ? 6
        : context.bandIndex >= 2
        ? 5
        : 4,
  );
}
