import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:releaf_app/features/brain/application/brain_training_controller.dart';
import 'package:releaf_app/features/brain/presentation/widgets/brain_difficulty_selector.dart';
import 'package:releaf_app/games/memory/memory_level_profile.dart';

void main() {
  test(
    'Memory level fifty survives controller reload and keeps cumulative counts',
    () async {
      SharedPreferences.setMockInitialValues({
        'brain.training.completion_counts.v1': ['memory|97'],
      });
      final prefs = await SharedPreferences.getInstance();
      final controller = BrainTrainingController(prefs);
      expect(controller.state.trainingLevelFor('memory'), 49);
      await controller.recordCompletion(gameId: 'memory', score: 100);
      controller.dispose();
      final restored = BrainTrainingController(prefs);
      expect(restored.state.trainingLevelFor('memory'), 50);
      expect(restored.state.completionCountFor('memory'), 98);
      expect(restored.state.sessionsUntilNextTrainingLevelFor('memory'), 0);
      restored.dispose();
    },
  );

  test('legacy Memory profiles remain exact for every difficulty', () {
    for (var level = 1; level <= 12; level++) {
      for (final difficulty in BrainDifficulty.values) {
        final old = brainPracticeLevelForDifficulty(level, difficulty);
        final pairs = (3 + (old - 1) ~/ 2).clamp(3, 8);
        final seconds = (58 - (old - 1) * 2 + (pairs - 3) * 2).clamp(34, 58);
        final profile = memoryLevelProfile(level, difficulty);
        expect((profile.pairs, profile.seconds), (pairs, seconds));
      }
    }
  });

  test('all fifty Medium profiles are distinct and use existing symbols', () {
    final profiles = <(int, int)>{};
    for (var level = 1; level <= 50; level++) {
      final p = memoryLevelProfile(level, BrainDifficulty.medium);
      expect(p.pairs, inInclusiveRange(3, 12));
      expect(p.seconds, inInclusiveRange(40, 58));
      profiles.add((p.pairs, p.seconds));
    }
    expect(profiles, hasLength(50));
    final last = memoryLevelProfile(50, BrainDifficulty.medium);
    expect((last.pairs, last.seconds), (12, 47));
  });

  test(
    'Memory hosted progress reaches fifty while other games retain twelve',
    () {
      for (final count in [22, 24, 96, 98, 120]) {
        final state = BrainTrainingState(
          completionCounts: {'memory': count, 'sequence_echo': count},
        );
        expect(state.trainingLevelFor('memory'), (1 + count ~/ 2).clamp(1, 50));
        expect(state.trainingLevelFor('sequence_echo'), 12);
        expect(
          state.sessionsUntilNextTrainingLevelFor('memory'),
          count >= 98 ? 0 : 2,
        );
      }
    },
  );
}
