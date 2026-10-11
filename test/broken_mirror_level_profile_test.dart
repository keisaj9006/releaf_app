import 'package:flutter_test/flutter_test.dart';
import 'package:releaf_app/games/broken_mirror/broken_mirror_level_profile.dart';

void main() {
  test('Broken Mirror preserves legacy levels 1-12 exactly', () {
    for (var level = 1; level <= 12; level++) {
      final profile = brokenMirrorProfileForLevel(level);
      final index = level - 1;
      final expectedFragments = level >= 12
          ? 8
          : level >= 10
          ? 7
          : level >= 7
          ? 6
          : level >= 4
          ? 5
          : 4;

      expect(profile.level, level);
      expect(profile.fragmentCount, expectedFragments);
      expect(
        profile.snapFraction,
        (0.13 - (index * 0.0035)).clamp(0.09, 0.13).toDouble(),
      );
      expect(profile.minSnapPixels, 28);
      expect(profile.shardSize, 120);
      expect(profile.spawnJitter, 14);
    }
  });

  test('Broken Mirror levels 13-50 remain playable and progressively precise', () {
    var previousSnap = brokenMirrorProfileForLevel(12).snapFraction;
    var previousSize = brokenMirrorProfileForLevel(12).shardSize;

    for (var level = 13; level <= 50; level++) {
      final profile = brokenMirrorProfileForLevel(level);
      expect(profile.level, level);
      expect(profile.fragmentCount, 8);
      expect(profile.snapFraction, inInclusiveRange(0.058, 0.09));
      expect(profile.minSnapPixels, inInclusiveRange(20, 28));
      expect(profile.shardSize, inInclusiveRange(96, 116));
      expect(profile.spawnJitter, inInclusiveRange(18, 42));
      expect(profile.snapFraction, lessThanOrEqualTo(previousSnap));
      expect(profile.shardSize, lessThanOrEqualTo(previousSize));
      previousSnap = profile.snapFraction;
      previousSize = profile.shardSize;
    }
  });

  test('Broken Mirror profile clamps to 1-50', () {
    expect(brokenMirrorProfileForLevel(-9).level, 1);
    expect(brokenMirrorProfileForLevel(999).level, 50);
  });
}
