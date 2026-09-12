import '../../features/brain/presentation/widgets/brain_difficulty_selector.dart';

const maxMemoryLevel = 50;

class MemoryLevelProfile {
  const MemoryLevelProfile(this.pairs, this.seconds);
  final int pairs;
  final int seconds;
}

MemoryLevelProfile memoryLevelProfile(int level, BrainDifficulty difficulty) {
  final base = level.clamp(1, maxMemoryLevel).toInt();
  final offset = switch (difficulty) {
    BrainDifficulty.easy => -2,
    BrainDifficulty.medium => 0,
    BrainDifficulty.hard => 2,
  };
  // Preserve the original difficulty boundaries for every existing level.
  final practice = base <= 12
      ? brainPracticeLevelForDifficulty(base, difficulty)
      : (base + offset).clamp(1, maxMemoryLevel).toInt();
  if (practice >= 13) {
    if (practice <= 18) return MemoryLevelProfile(8, 45 - (practice - 13));
    final band = (practice - 19) ~/ 8;
    return MemoryLevelProfile(9 + band, 48 + band * 2 - (practice - 19) % 8);
  }
  final pairs = (3 + (practice - 1) ~/ 2).clamp(3, 8).toInt();
  return MemoryLevelProfile(
    pairs,
    (58 - (practice - 1) * 2 + (pairs - 3) * 2).clamp(34, 58).toInt(),
  );
}
