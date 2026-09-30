import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:releaf_app/features/brain/application/brain_training_controller.dart';
import 'package:releaf_app/features/brain/presentation/widgets/brain_difficulty_selector.dart';
import 'package:releaf_app/games/color_conflict/color_conflict_level_profile.dart';
import 'package:releaf_app/games/color_conflict/color_conflict_screen.dart';

void main() {
  test('levels 1–12 preserve existing choices, rounds and clock', () {
    for (var level = 1; level <= 12; level++) {
      for (final difficulty in BrainDifficulty.values) {
        for (var round = 0; round < 6; round++) {
          final profile = colorConflictProfileForLevel(
            level,
            difficulty,
            round,
          );
          final index = level - 1;
          final colors = switch (difficulty) {
            BrainDifficulty.easy => round < 3 ? 3 : 4,
            BrainDifficulty.medium => round < 4 ? 4 : 5,
            BrainDifficulty.hard => 5,
          };
          final baseRounds = [9, 11, 13][difficulty.index];
          final baseSeconds = [38, 30, 24][difficulty.index];
          expect(profile.colorCount, colors);
          expect(profile.totalRounds, baseRounds + index ~/ 3);
          expect(profile.sessionSeconds, (baseSeconds - index).clamp(12, 38));
        }
      }
    }
  });

  test('levels 13–50 use bounded, distinct challenge bands', () {
    final signatures = <String>{};
    for (var level = 13; level <= 50; level++) {
      for (final difficulty in BrainDifficulty.values) {
        final profile = colorConflictProfileForLevel(level, difficulty, 0);
        expect(profile.colorCount, 5);
        expect(profile.totalRounds, inInclusiveRange(14, 25));
        expect(profile.sessionSeconds, inInclusiveRange(18, 40));
        expect(profile.congruentEvery, inInclusiveRange(3, 5));
      }
      if ([13, 23, 33, 43, 50].contains(level)) {
        final p = colorConflictProfileForLevel(
          level,
          BrainDifficulty.medium,
          0,
        );
        signatures.add(
          '${p.totalRounds}|${p.sessionSeconds}|${p.congruentEvery}',
        );
      }
    }
    expect(signatures, hasLength(5));
    expect(maxBrainTrainingLevelFor('color_conflict'), 50);
  });

  testWidgets('level 13 completes once across the full new session', (
    tester,
  ) async {
    final completions = <int?>[];
    await tester.pumpWidget(
      MaterialApp(
        home: ColorConflictScreen(trainingLevel: 13, onFinish: completions.add),
      ),
    );
    await tester.pump();
    await tester.ensureVisible(find.byKey(const Key('color-conflict-start')));
    await tester.tap(find.byKey(const Key('color-conflict-start')));
    await tester.pump();
    final rounds = colorConflictProfileForLevel(
      13,
      BrainDifficulty.medium,
      0,
    ).totalRounds;
    for (var round = 0; round < rounds; round++) {
      final answer = find.byKey(const Key('color-conflict-answer-0'));
      await tester.ensureVisible(answer);
      await tester.tap(answer);
      await tester.pump(const Duration(milliseconds: 200));
    }
    expect(completions, hasLength(1));
    expect(completions.single, inInclusiveRange(0, rounds * 200));
    await tester.pump(const Duration(seconds: 1));
    expect(completions, hasLength(1));
    expect(tester.takeException(), isNull);
  });

  testWidgets('level 50 keeps start and choices at 320 dp with 200% text', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(320, 640));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: const TextScaler.linear(2)),
          child: child!,
        ),
        home: const ColorConflictScreen(trainingLevel: 50),
      ),
    );
    await tester.pump();
    await tester.ensureVisible(find.byKey(const Key('color-conflict-start')));
    await tester.tap(find.byKey(const Key('color-conflict-start')));
    await tester.pump();
    expect(find.byKey(const Key('color-conflict-answer-4')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('level 50 starts with its real round and clock profile', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(320, 640));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      const MaterialApp(home: ColorConflictScreen(trainingLevel: 50)),
    );
    await tester.pump();
    final p = colorConflictProfileForLevel(50, BrainDifficulty.medium, 0);
    expect(find.text('1/${p.totalRounds}'), findsOneWidget);
    await tester.ensureVisible(find.byKey(const Key('color-conflict-start')));
    await tester.tap(find.byKey(const Key('color-conflict-start')));
    await tester.pump();
    expect(find.text('${p.sessionSeconds}s'), findsOneWidget);
    expect(find.byKey(const Key('color-conflict-answer-4')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
