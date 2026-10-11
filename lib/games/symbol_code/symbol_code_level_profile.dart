import '../../features/brain/domain/brain_level.dart';
import '../../features/brain/presentation/widgets/brain_difficulty_selector.dart';

class SymbolCodeLevelProfile {
  const SymbolCodeLevelProfile({
    required this.level,
    required this.mappingCount,
    required this.trialCount,
    required this.optionCount,
    required this.remapEvery,
  });

  final int level;
  final int mappingCount;
  final int trialCount;
  final int optionCount;

  /// Zero keeps one mapping for the whole session.
  final int remapEvery;
}

SymbolCodeLevelProfile symbolCodeProfileForLevel(
  int rawLevel,
  BrainDifficulty difficulty,
) {
  final level = rawLevel.clamp(1, maxBrainProfileLevel).toInt();

  if (level <= 12) {
    final index = level - 1;
    final mappingBase = switch (difficulty) {
      BrainDifficulty.easy => 4,
      BrainDifficulty.medium => 6,
      BrainDifficulty.hard => 7,
    };
    final trialBase = switch (difficulty) {
      BrainDifficulty.easy => 8,
      BrainDifficulty.medium => 10,
      BrainDifficulty.hard => 12,
    };
    final optionCount = switch (difficulty) {
      BrainDifficulty.easy => 3,
      BrainDifficulty.medium => 4,
      BrainDifficulty.hard => 5,
    };

    return SymbolCodeLevelProfile(
      level: level,
      mappingCount: (mappingBase + index ~/ 3).clamp(4, 9).toInt(),
      trialCount: (trialBase + index ~/ 2).clamp(8, 18).toInt(),
      optionCount: optionCount,
      remapEvery: 0,
    );
  }

  final context = BrainLevelContext(level);
  final baseTrials = switch (difficulty) {
    BrainDifficulty.easy => 13,
    BrainDifficulty.medium => 15,
    BrainDifficulty.hard => 17,
  };

  final mappingCount = switch (difficulty) {
    BrainDifficulty.easy => (7 + context.bandIndex - 1).clamp(7, 9).toInt(),
    BrainDifficulty.medium || BrainDifficulty.hard => 9,
  };

  final optionCount = switch (difficulty) {
    BrainDifficulty.easy =>
      (3 + context.bandIndex - 1).clamp(3, 5).toInt(),
    BrainDifficulty.medium =>
      (4 + (context.bandIndex - 1) ~/ 2).clamp(4, 6).toInt(),
    BrainDifficulty.hard =>
      (5 + (context.bandIndex - 1) ~/ 2).clamp(5, 6).toInt(),
  };

  final remapEvery = switch (context.band) {
    BrainLevelBand.foundation || BrainLevelBand.build => 0,
    BrainLevelBand.challenge => 9,
    BrainLevelBand.advanced => 7,
    BrainLevelBand.mastery => 5,
  };

  return SymbolCodeLevelProfile(
    level: level,
    mappingCount: mappingCount,
    trialCount: (baseTrials + (level - 12) ~/ 4 + context.stepInBand ~/ 5)
        .clamp(baseTrials, 24)
        .toInt(),
    optionCount: optionCount,
    remapEvery: remapEvery,
  );
}
