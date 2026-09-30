import 'package:flutter_test/flutter_test.dart';
import 'package:releaf_app/features/brain/domain/brain_level.dart';
import 'package:releaf_app/features/brain/application/brain_training_controller.dart'
    as training;

void main() {
  test('fifty-level context uses five ten-level challenge bands', () {
    for (final (level, band, step) in [
      (1, BrainLevelBand.foundation, 0),
      (10, BrainLevelBand.foundation, 9),
      (11, BrainLevelBand.build, 0),
      (20, BrainLevelBand.build, 9),
      (21, BrainLevelBand.challenge, 0),
      (30, BrainLevelBand.challenge, 9),
      (31, BrainLevelBand.advanced, 0),
      (40, BrainLevelBand.advanced, 9),
      (41, BrainLevelBand.mastery, 0),
      (50, BrainLevelBand.mastery, 9),
    ]) {
      final context = BrainLevelContext(level);
      expect(context.band, band);
      expect(context.stepInBand, step);
    }
  });

  test(
    'legacy games remain capped until their 13–50 profiles are playable',
    () {
      for (final id in training.progressiveBrainGameIds) {
        if (id == 'memory' ||
            id == 'labyrinth' ||
            id == 'sequence_echo' ||
            id == 'n_back' ||
            id == 'spatial_span' ||
            id == 'signal_scan' ||
            id == 'rule_shift') {
          expect(training.maxBrainTrainingLevelFor(id), 50);
        } else {
          expect(training.maxBrainTrainingLevelFor(id), 12, reason: id);
        }
      }
    },
  );

  test('Sequence Echo reveals earned level 50 without migrating counts', () {
    const state = training.BrainTrainingState(
      completionCounts: {'sequence_echo': 98},
    );
    expect(state.trainingLevelFor('sequence_echo'), 50);
    expect(state.sessionsUntilNextTrainingLevelFor('sequence_echo'), 0);
  });

  test('two completions per level reach and stop at 50', () {
    for (final (count, level, remaining) in [
      (0, 1, 2),
      (1, 1, 1),
      (2, 2, 2),
      (24, 13, 2),
      (97, 49, 1),
      (98, 50, 0),
      (500, 50, 0),
    ]) {
      expect(brainLevelForCompletionCount(count), level);
      expect(brainSessionsUntilNextLevel(count), remaining);
    }
  });
}
