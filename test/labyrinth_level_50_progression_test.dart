import 'package:flutter_test/flutter_test.dart';

import 'package:releaf_app/features/brain/application/brain_training_controller.dart';
import 'package:releaf_app/features/brain/presentation/widgets/brain_difficulty_selector.dart';
import 'package:releaf_app/games/labyrinth/labyrinth_game_screen.dart';

void main() {
  test('Labyrinth persistent Brain progression reaches level 50', () {
    expect(maxBrainTrainingLevelFor('labyrinth'), 50);

    final state = BrainTrainingState(
      completionCounts: const <String, int>{'labyrinth': 98},
    );

    expect(state.trainingLevelFor('labyrinth'), 50);
    expect(state.sessionsUntilNextTrainingLevelFor('labyrinth'), 0);
  });

  test('Labyrinth difficulty remains relative through level 50', () {
    expect(
      labyrinthProfileLevelForDifficulty(25, BrainDifficulty.easy),
      23,
    );
    expect(
      labyrinthProfileLevelForDifficulty(25, BrainDifficulty.medium),
      25,
    );
    expect(
      labyrinthProfileLevelForDifficulty(25, BrainDifficulty.hard),
      27,
    );
    expect(
      labyrinthProfileLevelForDifficulty(50, BrainDifficulty.hard),
      50,
    );
  });

  test('Labyrinth higher levels materially tighten ball precision', () {
    final level12 = labyrinthBallRadiusForLevel(12);
    final level25 = labyrinthBallRadiusForLevel(25);
    final level50 = labyrinthBallRadiusForLevel(50);

    expect(level25, lessThan(level12));
    expect(level50, lessThan(level25));
    expect(level50, greaterThanOrEqualTo(0.10));
  });

  test('Labyrinth L13-L50 create higher-complexity playable profiles', () {
    final level12 = labyrinthLevelProfileForTesting(12, mazeStage: 12);
    final level25 = labyrinthLevelProfileForTesting(25, mazeStage: 25);
    final level50 = labyrinthLevelProfileForTesting(50, mazeStage: 50);

    expect(level25.level, 25);
    expect(level50.level, 50);
    expect(level25.columns * level25.rows, greaterThan(level12.columns * level12.rows));
    expect(level50.columns * level50.rows, greaterThanOrEqualTo(level25.columns * level25.rows));
    expect(level50.shortestPathMoves, greaterThan(level12.shortestPathMoves));
    expect(level50.timeLimitSeconds, inInclusiveRange(55, 180));
  });
}
