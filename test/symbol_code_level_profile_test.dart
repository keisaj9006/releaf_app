import 'package:flutter_test/flutter_test.dart';
import 'package:releaf_app/features/brain/presentation/widgets/brain_difficulty_selector.dart';
import 'package:releaf_app/games/symbol_code/symbol_code_level_profile.dart';

void main() {
  test('Symbol Code preserves legacy levels 1-12 exactly', () {
    for (final difficulty in BrainDifficulty.values) {
      for (var level = 1; level <= 12; level++) {
        final profile = symbolCodeProfileForLevel(level, difficulty);
        final index = level - 1;
        final expectedMappingBase = switch (difficulty) {
          BrainDifficulty.easy => 4,
          BrainDifficulty.medium => 6,
          BrainDifficulty.hard => 7,
        };
        final expectedTrialBase = switch (difficulty) {
          BrainDifficulty.easy => 8,
          BrainDifficulty.medium => 10,
          BrainDifficulty.hard => 12,
        };
        final expectedOptions = switch (difficulty) {
          BrainDifficulty.easy => 3,
          BrainDifficulty.medium => 4,
          BrainDifficulty.hard => 5,
        };

        expect(
          profile.mappingCount,
          (expectedMappingBase + index ~/ 3).clamp(4, 9),
          reason: '$difficulty level $level mapping',
        );
        expect(
          profile.trialCount,
          (expectedTrialBase + index ~/ 2).clamp(8, 18),
          reason: '$difficulty level $level trials',
        );
        expect(profile.optionCount, expectedOptions);
        expect(profile.remapEvery, 0);
      }
    }
  });

  test('Symbol Code levels 13-50 stay bounded and add remapping by band', () {
    for (final difficulty in BrainDifficulty.values) {
      for (var level = 13; level <= 50; level++) {
        final profile = symbolCodeProfileForLevel(level, difficulty);
        expect(profile.level, level);
        expect(profile.mappingCount, inInclusiveRange(7, 9));
        expect(profile.trialCount, inInclusiveRange(13, 24));
        expect(profile.optionCount, inInclusiveRange(3, 6));

        if (level <= 20) {
          expect(profile.remapEvery, 0);
        } else if (level <= 30) {
          expect(profile.remapEvery, 9);
        } else if (level <= 40) {
          expect(profile.remapEvery, 7);
        } else {
          expect(profile.remapEvery, 5);
        }
      }
    }
  });

  test('Symbol Code clamps to levels 1-50', () {
    expect(
      symbolCodeProfileForLevel(-4, BrainDifficulty.medium).level,
      1,
    );
    expect(
      symbolCodeProfileForLevel(999, BrainDifficulty.medium).level,
      50,
    );
  });
}
