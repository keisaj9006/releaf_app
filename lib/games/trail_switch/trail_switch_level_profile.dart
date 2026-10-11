import '../../features/brain/domain/brain_level.dart';
import '../../features/brain/presentation/widgets/brain_difficulty_selector.dart';

class TrailSwitchLevelProfile {
  const TrailSwitchLevelProfile({
    required this.level,
    required this.targetCount,
    required this.distractorCount,
    required this.gridSide,
    required this.startWithLetter,
  });

  final int level;
  final int targetCount;
  final int distractorCount;
  final int gridSide;
  final bool startWithLetter;
}

TrailSwitchLevelProfile trailSwitchProfileForLevel(
  int rawLevel,
  BrainDifficulty difficulty,
) {
  final level = rawLevel.clamp(1, maxBrainProfileLevel).toInt();

  if (level <= 12) {
    final index = level - 1;
    final baseTargets = switch (difficulty) {
      BrainDifficulty.easy => 6,
      BrainDifficulty.medium => 8,
      BrainDifficulty.hard => 10,
    };
    final targetCount = (baseTargets + index ~/ 2).clamp(6, 16).toInt();
    final distractorCount = difficulty == BrainDifficulty.hard
        ? (3 + index ~/ 3).clamp(3, 6).toInt()
        : 0;
    final total = targetCount + distractorCount;
    final gridSide = total <= 9
        ? 3
        : total <= 16
        ? 4
        : 5;

    return TrailSwitchLevelProfile(
      level: level,
      targetCount: targetCount,
      distractorCount: distractorCount,
      gridSide: gridSide,
      startWithLetter: false,
    );
  }

  final context = BrainLevelContext(level);
  final baseTargets = switch (difficulty) {
    BrainDifficulty.easy => 12,
    BrainDifficulty.medium => 14,
    BrainDifficulty.hard => 16,
  };
  final targetMax = switch (difficulty) {
    BrainDifficulty.easy => 16,
    BrainDifficulty.medium => 18,
    BrainDifficulty.hard => 19,
  };
  final targetCount =
      (baseTargets + context.bandIndex - 1 + context.stepInBand ~/ 3)
          .clamp(baseTargets, targetMax)
          .toInt();

  var distractorCount = switch (difficulty) {
    BrainDifficulty.easy => 0,
    BrainDifficulty.medium => context.bandIndex >= 3
        ? (2 + context.stepInBand ~/ 5).clamp(2, 3).toInt()
        : context.bandIndex >= 2
        ? 1
        : 0,
    BrainDifficulty.hard =>
      (6 + context.bandIndex - 1 + context.stepInBand ~/ 4)
          .clamp(6, 8)
          .toInt(),
  };

  final maxDistractors = (25 - targetCount).clamp(0, 8).toInt();
  distractorCount = distractorCount.clamp(0, maxDistractors).toInt();
  final total = targetCount + distractorCount;

  return TrailSwitchLevelProfile(
    level: level,
    targetCount: targetCount,
    distractorCount: distractorCount,
    gridSide: total <= 16 ? 4 : 5,
    startWithLetter:
        difficulty != BrainDifficulty.easy &&
        level >= 21 &&
        (level + difficulty.index).isOdd,
  );
}
