import '../../features/brain/domain/brain_level.dart';

class BrokenMirrorLevelProfile {
  const BrokenMirrorLevelProfile({
    required this.level,
    required this.fragmentCount,
    required this.snapFraction,
    required this.minSnapPixels,
    required this.shardSize,
    required this.spawnJitter,
  });

  final int level;
  final int fragmentCount;
  final double snapFraction;
  final double minSnapPixels;
  final double shardSize;
  final double spawnJitter;
}

BrokenMirrorLevelProfile brokenMirrorProfileForLevel(int rawLevel) {
  final level = rawLevel.clamp(1, maxBrainProfileLevel).toInt();

  if (level <= 12) {
    final index = level - 1;
    final fragmentCount = level >= 12
        ? 8
        : level >= 10
        ? 7
        : level >= 7
        ? 6
        : level >= 4
        ? 5
        : 4;

    return BrokenMirrorLevelProfile(
      level: level,
      fragmentCount: fragmentCount,
      snapFraction: (0.13 - (index * 0.0035)).clamp(0.09, 0.13).toDouble(),
      minSnapPixels: 28,
      shardSize: 120,
      spawnJitter: 14,
    );
  }

  final context = BrainLevelContext(level);
  return BrokenMirrorLevelProfile(
    level: level,
    fragmentCount: 8,
    snapFraction: (0.09 - ((level - 12) * 0.0008))
        .clamp(0.058, 0.09)
        .toDouble(),
    minSnapPixels:
        (30 - context.bandIndex * 2 - context.stepInBand ~/ 5)
            .clamp(20, 28)
            .toDouble(),
    shardSize: (122 - context.bandIndex * 6).clamp(96, 116).toDouble(),
    spawnJitter:
        (14 + context.bandIndex * 4 + context.stepInBand)
            .clamp(18, 42)
            .toDouble(),
  );
}
