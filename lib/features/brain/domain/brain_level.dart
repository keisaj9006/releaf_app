/// Profile ceiling prepared for all registered Brain games.
/// Live caps rise per game only after its 13–50 profile is playable and tested.
const maxBrainProfileLevel = 50;
const brainCompletionsPerLevel = 2;

enum BrainLevelBand { foundation, build, challenge, advanced, mastery }

class BrainLevelContext {
  const BrainLevelContext(this.level)
    : assert(level >= 1 && level <= maxBrainProfileLevel);

  final int level;

  int get bandIndex => (level - 1) ~/ 10;
  int get stepInBand => (level - 1) % 10;
  BrainLevelBand get band => BrainLevelBand.values[bandIndex];
}

int brainLevelForCompletionCount(
  int completed, {
  int maxLevel = maxBrainProfileLevel,
}) {
  assert(maxLevel >= 1 && maxLevel <= maxBrainProfileLevel);
  final safeCompleted = completed < 0 ? 0 : completed;
  return (1 + safeCompleted ~/ brainCompletionsPerLevel)
      .clamp(1, maxLevel)
      .toInt();
}

int brainSessionsUntilNextLevel(
  int completed, {
  int maxLevel = maxBrainProfileLevel,
}) {
  final level = brainLevelForCompletionCount(completed, maxLevel: maxLevel);
  if (level >= maxLevel) return 0;
  final safeCompleted = completed < 0 ? 0 : completed;
  return brainCompletionsPerLevel - safeCompleted % brainCompletionsPerLevel;
}
