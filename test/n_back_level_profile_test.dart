import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:releaf_app/features/brain/application/brain_training_controller.dart';
import 'package:releaf_app/features/brain/presentation/widgets/brain_difficulty_selector.dart';
import 'package:releaf_app/games/n_back/n_back_level_profile.dart';
import 'package:releaf_app/games/n_back/n_back_screen.dart';

void main() {
  test('N-Back levels 1–12 retain depth, trials and sequence seed', () {
    for (var level = 1; level <= 12; level++) {
      final index = level - 1;
      for (final difficulty in BrainDifficulty.values) {
        final baseDepth = difficulty.index + 1;
        final extra = switch (difficulty) {
          BrainDifficulty.easy => index >= 9 ? 1 : 0,
          BrainDifficulty.medium => index >= 7 ? 1 : 0,
          BrainDifficulty.hard => index >= 8 ? 1 : 0,
        };
        final baseTrials = 12 + difficulty.index * 3;
        final profile = nBackProfileForLevel(level, difficulty);
        expect(profile.depth, (baseDepth + extra).clamp(1, 4));
        expect(profile.trialCount, baseTrials + index ~/ 2);
        expect(profile.seed, 9049 + level * 271 + difficulty.index * 991);
        expect(profile.matchChance, 0.34);
      }
    }
  });

  test('N-Back levels 13–50 remain bounded and progress across bands', () {
    final signatures = <String>{};
    for (var level = 13; level <= 50; level++) {
      for (final difficulty in BrainDifficulty.values) {
        final profile = nBackProfileForLevel(level, difficulty);
        expect(profile.depth, inInclusiveRange(1, 4));
        expect(profile.trialCount, inInclusiveRange(18, 38));
        expect(profile.trialCount, greaterThan(profile.depth + 3));
        expect(profile.matchChance, inInclusiveRange(0.28, 0.38));
        expect(nBackProfileForLevel(level, difficulty).seed, profile.seed);
      }
      if ([13, 23, 33, 43, 50].contains(level)) {
        final profile = nBackProfileForLevel(level, BrainDifficulty.medium);
        signatures.add(
          '${profile.depth}|${profile.trialCount}|${profile.matchChance}',
        );
      }
    }
    expect(signatures, hasLength(5));
    expect(maxBrainTrainingLevelFor('n_back'), 50);
    expect(maxBrainTrainingLevelFor('pattern_logic'), 12);
  });

  testWidgets('N-Back level 50 opens and advances at 320 dp', (tester) async {
    await tester.binding.setSurfaceSize(const Size(320, 720));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(home: NBackScreen(trainingLevel: 50, onFinish: (_) {})),
    );
    await tester.pump();
    expect(find.text('L50'), findsOneWidget);
    expect(find.byKey(const Key('n-back-stimulus-card')), findsOneWidget);
    await tester.tap(find.byKey(const Key('n-back-continue')));
    await tester.pump(const Duration(milliseconds: 130));
    expect(tester.takeException(), isNull);
  });
}
