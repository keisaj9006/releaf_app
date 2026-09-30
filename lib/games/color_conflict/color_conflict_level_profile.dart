import '../../features/brain/domain/brain_level.dart';
import '../../features/brain/presentation/widgets/brain_difficulty_selector.dart';

class ColorConflictLevelProfile {
  const ColorConflictLevelProfile({
    required this.colorCount,
    required this.totalRounds,
    required this.sessionSeconds,
    required this.congruentEvery,
  });

  final int colorCount;
  final int totalRounds;
  final int sessionSeconds;

  /// Zero retains the original difficulty-specific congruence pattern.
  final int congruentEvery;
}

ColorConflictLevelProfile colorConflictProfileForLevel(
  int rawLevel,
  BrainDifficulty difficulty,
  int rawRound,
) {
  final level = rawLevel.clamp(1, maxBrainProfileLevel).toInt();
  final round = rawRound < 0 ? 0 : rawRound;
  if (level <= 12) {
    final index = level - 1;
    final colorCount = switch (difficulty) {
      BrainDifficulty.easy => round < 3 ? 3 : 4,
      BrainDifficulty.medium => round < 4 ? 4 : 5,
      BrainDifficulty.hard => 5,
    };
    final baseRounds = switch (difficulty) {
      BrainDifficulty.easy => 9,
      BrainDifficulty.medium => 11,
      BrainDifficulty.hard => 13,
    };
    final baseSeconds = switch (difficulty) {
      BrainDifficulty.easy => 38,
      BrainDifficulty.medium => 30,
      BrainDifficulty.hard => 24,
    };
    return ColorConflictLevelProfile(
      colorCount: colorCount,
      totalRounds: baseRounds + index ~/ 3,
      sessionSeconds: (baseSeconds - index).clamp(12, 38),
      congruentEvery: 0,
    );
  }

  final context = BrainLevelContext(level);
  final baseRounds = switch (difficulty) {
    BrainDifficulty.easy => 14,
    BrainDifficulty.medium => 16,
    BrainDifficulty.hard => 18,
  };
  final baseSeconds = switch (difficulty) {
    BrainDifficulty.easy => 40,
    BrainDifficulty.medium => 34,
    BrainDifficulty.hard => 28,
  };
  return ColorConflictLevelProfile(
    colorCount: 5,
    totalRounds: (baseRounds + context.bandIndex + context.stepInBand ~/ 4)
        .clamp(14, 25),
    sessionSeconds:
        (baseSeconds - context.bandIndex * 2 - context.stepInBand ~/ 3).clamp(
          18,
          40,
        ),
    congruentEvery: (6 - context.bandIndex).clamp(3, 5),
  );
}
