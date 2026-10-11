import 'package:flutter_test/flutter_test.dart';
import 'package:releaf_app/features/brain/presentation/widgets/brain_difficulty_selector.dart';
import 'package:releaf_app/games/trail_switch/trail_switch_level_profile.dart';

void main() {
  test('Trail Switch preserves legacy levels 1-12 exactly', () {
    for (final difficulty in BrainDifficulty.values) {
      for (var level = 1; level <= 12; level++) {
        final profile = trailSwitchProfileForLevel(level, difficulty);
        final index = level - 1;
        final baseTargets = switch (difficulty) {
          BrainDifficulty.easy => 6,
          BrainDifficulty.medium => 8,
          BrainDifficulty.hard => 10,
        };
        final expectedTargets = (baseTargets + index ~/ 2).clamp(6, 16);
        final expectedDistractors = difficulty == BrainDifficulty.hard
            ? (3 + index ~/ 3).clamp(3, 6)
            : 0;
        final total = expectedTargets + expectedDistractors;
        final expectedGrid = total <= 9 ? 3 : total <= 16 ? 4 : 5;

        expect(profile.level, level);
        expect(profile.targetCount, expectedTargets);
        expect(profile.distractorCount, expectedDistractors);
        expect(profile.gridSide, expectedGrid);
        expect(profile.startWithLetter, isFalse);
      }
    }
  });

  test('Trail Switch levels 13-50 stay readable on a 5x5 board', () {
    var sawLetterFirst = false;
    var sawNumberFirst = false;

    for (final difficulty in BrainDifficulty.values) {
      for (var level = 13; level <= 50; level++) {
        final profile = trailSwitchProfileForLevel(level, difficulty);
        expect(profile.level, level);
        expect(profile.targetCount, inInclusiveRange(12, 19));
        expect(profile.distractorCount, inInclusiveRange(0, 8));
        expect(profile.targetCount + profile.distractorCount, lessThanOrEqualTo(25));
        expect(profile.gridSide, inInclusiveRange(4, 5));

        if (difficulty != BrainDifficulty.easy && level >= 21) {
          sawLetterFirst |= profile.startWithLetter;
          sawNumberFirst |= !profile.startWithLetter;
        }
      }
    }

    expect(sawLetterFirst, isTrue);
    expect(sawNumberFirst, isTrue);
  });

  test('Trail Switch profile clamps safely to 1-50', () {
    expect(trailSwitchProfileForLevel(-7, BrainDifficulty.medium).level, 1);
    expect(trailSwitchProfileForLevel(999, BrainDifficulty.medium).level, 50);
  });
}
