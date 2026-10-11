import 'package:flutter_test/flutter_test.dart';
import 'package:releaf_app/features/brain/presentation/widgets/brain_difficulty_selector.dart';
import 'package:releaf_app/games/mental_rotation/mental_rotation_level_profile.dart';

void main() {
  test('Mental Rotation preserves legacy levels 1-12 exactly', () {
    for (final difficulty in BrainDifficulty.values) {
      for (var level = 1; level <= 12; level++) {
        final profile = mentalRotationProfileForLevel(level, difficulty);
        final index = level - 1;
        final expectedGrid = level >= 9
            ? 5
            : level >= 5
            ? 4
            : 3;
        final expectedRoundBase = switch (difficulty) {
          BrainDifficulty.easy => 6,
          BrainDifficulty.medium => 8,
          BrainDifficulty.hard => 10,
        };
        final expectedFillBase = switch (difficulty) {
          BrainDifficulty.easy => expectedGrid + 1,
          BrainDifficulty.medium => expectedGrid + 2,
          BrainDifficulty.hard => expectedGrid + 3,
        };

        expect(profile.level, level);
        expect(profile.gridSide, expectedGrid);
        expect(profile.roundCount, expectedRoundBase + index ~/ 4);
        expect(
          profile.filledCells,
          expectedFillBase.clamp(4, (expectedGrid * expectedGrid) - 2),
        );
        expect(profile.minimumQuarterTurns, 0);
      }
    }
  });

  test('Mental Rotation levels 13-50 stay bounded and grow by band', () {
    for (final difficulty in BrainDifficulty.values) {
      for (var level = 13; level <= 50; level++) {
        final profile = mentalRotationProfileForLevel(level, difficulty);
        expect(profile.level, level);
        expect(profile.gridSide, inInclusiveRange(5, 6));
        expect(profile.roundCount, inInclusiveRange(8, 17));
        expect(
          profile.filledCells,
          inInclusiveRange(5, (profile.gridSide * profile.gridSide) - 4),
        );
        expect(profile.minimumQuarterTurns, level >= 21 ? 1 : 0);
      }
    }

    expect(
      mentalRotationProfileForLevel(50, BrainDifficulty.hard).filledCells,
      greaterThan(
        mentalRotationProfileForLevel(13, BrainDifficulty.hard).filledCells,
      ),
    );
  });

  test('Mental Rotation clamps safely to 1-50', () {
    expect(
      mentalRotationProfileForLevel(-4, BrainDifficulty.medium).level,
      1,
    );
    expect(
      mentalRotationProfileForLevel(999, BrainDifficulty.medium).level,
      50,
    );
  });
}
