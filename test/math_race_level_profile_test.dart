import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:releaf_app/features/brain/presentation/widgets/brain_difficulty_selector.dart';
import 'package:releaf_app/games/math_race/math_puzzle_generator.dart';
import 'package:releaf_app/games/math_race/math_race_level_profile.dart';

void main() {
  test('Math Race preserves legacy level 1-12 starting puzzle mapping', () {
    for (final difficulty in BrainDifficulty.values) {
      for (var level = 1; level <= 12; level++) {
        final profile = mathRaceProfileForLevel(level, difficulty);
        final baseline = 1 + ((level - 1) * 3);
        final offset = switch (difficulty) {
          BrainDifficulty.easy => -2,
          BrainDifficulty.medium => 0,
          BrainDifficulty.hard => 2,
        };

        expect(profile.level, level);
        expect(profile.startingPuzzleLevel, (baseline + offset).clamp(1, 36));
        expect(profile.optionCount, 4);
      }
    }
  });

  test('Math Race levels 13-50 increase puzzle range with bounded options', () {
    var previousMedium = 0;
    for (var level = 13; level <= 50; level++) {
      for (final difficulty in BrainDifficulty.values) {
        final profile = mathRaceProfileForLevel(level, difficulty);
        expect(profile.level, level);
        expect(profile.startingPuzzleLevel, inInclusiveRange(37, 120));
        expect(profile.optionCount, inInclusiveRange(4, 6));
      }

      final medium =
          mathRaceProfileForLevel(level, BrainDifficulty.medium).startingPuzzleLevel;
      expect(medium, greaterThan(previousMedium));
      previousMedium = medium;
    }
  });

  test('high-level Math Race puzzles remain integral and unambiguous', () {
    for (final puzzleLevel in [41, 60, 90, 120]) {
      final generator = MathPuzzleGenerator(random: Random(1200 + puzzleLevel));
      for (final optionCount in [4, 5, 6]) {
        for (var sample = 0; sample < 40; sample++) {
          final puzzle = generator.generateForLevel(
            level: puzzleLevel,
            optionCount: optionCount,
          );
          expect(puzzle.correctAnswer, greaterThan(0));
          expect(puzzle.options, hasLength(optionCount));
          expect(puzzle.options.toSet(), hasLength(optionCount));
          expect(puzzle.options, contains(puzzle.correctAnswer));
          expect(puzzle.options.every((value) => value > 0), isTrue);
        }
      }
    }
  });

  test('Math Race profile clamps safely to 1-50', () {
    expect(mathRaceProfileForLevel(-3, BrainDifficulty.medium).level, 1);
    expect(mathRaceProfileForLevel(999, BrainDifficulty.medium).level, 50);
  });
}
