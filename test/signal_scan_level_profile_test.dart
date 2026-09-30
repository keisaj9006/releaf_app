import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:releaf_app/features/brain/application/brain_training_controller.dart';
import 'package:releaf_app/features/brain/presentation/widgets/brain_difficulty_selector.dart';
import 'package:releaf_app/games/signal_scan/signal_scan_level_profile.dart';
import 'package:releaf_app/games/signal_scan/signal_scan_screen.dart';

void main() {
  test(
    'legacy Signal Scan profiles retain representative field and target values',
    () {
      for (final (
            level,
            difficulty,
            round,
            effective,
            side,
            rounds,
            size,
            target,
          )
          in [
            (1, BrainDifficulty.easy, 0, BrainDifficulty.easy, 4, 6, 27.0, 3),
            (
              1,
              BrainDifficulty.medium,
              0,
              BrainDifficulty.medium,
              5,
              8,
              27.0,
              5,
            ),
            (1, BrainDifficulty.hard, 0, BrainDifficulty.hard, 6, 10, 21.0, 7),
            (
              1,
              BrainDifficulty.easy,
              4,
              BrainDifficulty.medium,
              6,
              6,
              21.0,
              33,
            ),
            (
              7,
              BrainDifficulty.medium,
              0,
              BrainDifficulty.medium,
              6,
              11,
              17.7,
              5,
            ),
            (9, BrainDifficulty.hard, 0, BrainDifficulty.hard, 8, 14, 16.6, 7),
            (
              12,
              BrainDifficulty.hard,
              4,
              BrainDifficulty.hard,
              8,
              15,
              14.95,
              35,
            ),
          ]) {
        final profile = signalScanProfileForLevel(level, difficulty, round);
        expect(profile.effectiveDifficulty, effective);
        expect(profile.gridSize, side);
        expect(profile.totalRounds, rounds);
        expect(profile.symbolSize, closeTo(size, 0.001));
        expect(profile.targetIndices, [target]);
      }
    },
  );

  test('higher Signal Scan levels keep targets unique and field usable', () {
    final signatures = <String>{};
    for (var level = 13; level <= 50; level++) {
      for (final difficulty in BrainDifficulty.values) {
        for (var round = 0; round < 11; round++) {
          final profile = signalScanProfileForLevel(level, difficulty, round);
          expect(profile.gridSize, 5);
          expect(profile.targetCount, inInclusiveRange(2, 3));
          expect(profile.totalRounds, inInclusiveRange(6, 11));
          expect(profile.effectiveDifficulty, difficulty);
          expect(profile.targetIndices, hasLength(profile.targetCount));
          expect(profile.targetIndices.toSet(), hasLength(profile.targetCount));
          expect(profile.targetIndices.every((i) => i >= 0 && i < 25), isTrue);
        }
      }
      if ([13, 23, 33, 43, 50].contains(level)) {
        final profile = signalScanProfileForLevel(
          level,
          BrainDifficulty.medium,
          0,
        );
        signatures.add('${profile.targetCount}|${profile.totalRounds}');
      }
    }
    expect(signatures, hasLength(5));
    expect(maxBrainTrainingLevelFor('signal_scan'), 50);
    expect(maxBrainTrainingLevelFor('color_conflict'), 12);
  });

  testWidgets('level 13 accepts each target once before advancing', (
    tester,
  ) async {
    final completions = <int?>[];
    await tester.pumpWidget(
      MaterialApp(
        home: SignalScanScreen(trainingLevel: 13, onFinish: completions.add),
      ),
    );
    await tester.pump();
    final profile = signalScanProfileForLevel(13, BrainDifficulty.medium, 0);
    final first = find.byKey(
      Key('signal-scan-cell-${profile.targetIndices[0]}'),
    );
    await tester.ensureVisible(first);
    await tester.tap(first);
    await tester.pump(const Duration(milliseconds: 80));
    expect(find.text('1 of 2 found'), findsOneWidget);
    expect(
      tester
          .widget<BrainDifficultySelector>(find.byType(BrainDifficultySelector))
          .enabled,
      isFalse,
    );
    expect(find.text('1/${profile.totalRounds}'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 100));
    await tester.tap(first);
    await tester.pump();
    expect(find.text('1 of 2 found'), findsOneWidget);
    final wrongIndex = List<int>.generate(
      25,
      (i) => i,
    ).firstWhere((i) => !profile.targetIndices.contains(i));
    final wrong = find.byKey(Key('signal-scan-cell-$wrongIndex'));
    await tester.ensureVisible(wrong);
    await tester.tap(wrong);
    await tester.pump();
    expect(find.text('That was a distractor. Keep scanning.'), findsOneWidget);
    expect(find.text('1 of 2 found'), findsOneWidget);
    final second = find.byKey(
      Key('signal-scan-cell-${profile.targetIndices[1]}'),
    );
    await tester.ensureVisible(second);
    await tester.tap(second);
    await tester.pump(const Duration(milliseconds: 80));
    expect(find.text('2 of 2 found'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('2/${profile.totalRounds}'), findsOneWidget);
    expect(find.text('0 of 2 found'), findsOneWidget);
    expect(completions, isEmpty);
  });

  testWidgets(
    'level 13 finishes exactly once after every target of every round',
    (tester) async {
      final completions = <int?>[];
      await tester.pumpWidget(
        MaterialApp(
          home: SignalScanScreen(trainingLevel: 13, onFinish: completions.add),
        ),
      );
      await tester.pump();
      final rounds = signalScanProfileForLevel(
        13,
        BrainDifficulty.medium,
        0,
      ).totalRounds;
      for (var round = 0; round < rounds; round++) {
        final targets = signalScanProfileForLevel(
          13,
          BrainDifficulty.medium,
          round,
        ).targetIndices;
        for (final target in targets) {
          final cell = find.byKey(Key('signal-scan-cell-$target'));
          await tester.ensureVisible(cell);
          await tester.tap(cell);
          await tester.pump(const Duration(milliseconds: 170));
        }
        if (round < rounds - 1) expect(completions, isEmpty);
      }
      expect(completions, hasLength(1));
      expect(completions.single, greaterThan(0));
      await tester.pump(const Duration(seconds: 1));
      expect(completions, hasLength(1));
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('level 50 remains readable at 320 dp with 200% text', (
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
        home: SignalScanScreen(trainingLevel: 50, onFinish: (_) {}),
      ),
    );
    await tester.pump();
    expect(find.text('L50'), findsOneWidget);
    expect(find.text('5×5'), findsOneWidget);
    expect(
      find.text(
        'Find every matching symbol. Difficulty changes how similar the distractors look.',
      ),
      findsOneWidget,
    );
    expect(
      tester.getSize(find.byKey(const Key('signal-scan-cell-0'))).width,
      greaterThanOrEqualTo(44),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('level 13 keeps a phone-sized field and asks for two targets', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(320, 720));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(home: SignalScanScreen(trainingLevel: 13, onFinish: (_) {})),
    );
    await tester.pump();
    expect(find.text('5×5'), findsOneWidget);
    expect(find.text('0 of 2 found'), findsOneWidget);
    expect(
      tester.getSize(find.byKey(const Key('signal-scan-cell-0'))).width,
      greaterThanOrEqualTo(44),
    );
    expect(tester.takeException(), isNull);
  });
}
