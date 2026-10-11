import '../../features/brain/domain/brain_level.dart';

class PatternLogicLevelProfile {
  const PatternLogicLevelProfile({
    required this.level,
    required this.extraRounds,
    required this.supplementOffset,
    required this.supplementStride,
    required this.hardBias,
    required this.showHint,
  });

  final int level;
  final int extraRounds;
  final int supplementOffset;
  final int supplementStride;
  final int hardBias;
  final bool showHint;
}

PatternLogicLevelProfile patternLogicProfileForLevel(int rawLevel) {
  final level = rawLevel.clamp(1, maxBrainProfileLevel).toInt();

  if (level <= 12) {
    final legacyIndex = level - 1;
    return PatternLogicLevelProfile(
      level: level,
      extraRounds: legacyIndex,
      supplementOffset: legacyIndex,
      supplementStride: 1,
      hardBias: 0,
      showHint: level < 7,
    );
  }

  final context = BrainLevelContext(level);
  return PatternLogicLevelProfile(
    level: level,
    extraRounds: (12 + (level - 13) ~/ 5).clamp(12, 19).toInt(),
    supplementOffset: (level + context.bandIndex * 3) % 11,
    supplementStride: (1 + context.bandIndex ~/ 2).clamp(1, 3).toInt(),
    hardBias: context.bandIndex,
    showHint: false,
  );
}
