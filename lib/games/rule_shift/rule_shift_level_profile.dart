import '../../features/brain/domain/brain_level.dart';

class RuleShiftLevelProfile {
  const RuleShiftLevelProfile({
    required this.level,
    required this.trialCount,
    required this.ruleCount,
    required this.switchBlockSize,
  });

  final int level;
  final int trialCount;
  final int ruleCount;
  final int switchBlockSize;
}

RuleShiftLevelProfile ruleShiftProfileForLevel(int rawLevel) {
  final level = rawLevel.clamp(1, maxBrainProfileLevel).toInt();
  if (level <= 12) {
    return RuleShiftLevelProfile(
      level: level,
      trialCount: 11 + level,
      ruleCount: level >= 7
          ? 4
          : level >= 4
          ? 3
          : 2,
      switchBlockSize: level >= 6
          ? 1
          : level >= 3
          ? 2
          : 3,
    );
  }

  final context = BrainLevelContext(level);
  return RuleShiftLevelProfile(
    level: level,
    trialCount: (21 + context.bandIndex * 2 + context.stepInBand ~/ 3).clamp(
      23,
      30,
    ),
    ruleCount: (3 + context.bandIndex).clamp(4, 6),
    switchBlockSize: 1,
  );
}
