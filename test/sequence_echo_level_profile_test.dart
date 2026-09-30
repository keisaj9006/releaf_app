import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:releaf_app/features/brain/presentation/widgets/brain_difficulty_selector.dart';
import 'package:releaf_app/games/sequence_echo/sequence_echo_level_profile.dart';
import 'package:releaf_app/games/sequence_echo/sequence_echo_screen.dart';

void main() {
  const base = <int>[0, 4, 8, 2, 6, 1, 7, 3, 5, 0, 8, 4, 2, 7, 1, 6, 3, 5];

  test('levels 1–12 retain every existing sequence parameter', () {
    for (var level = 1; level <= 12; level++) {
      final index = level - 1;
      for (final difficulty in BrainDifficulty.values) {
        final baseRounds = switch (difficulty) {
          BrainDifficulty.easy => 5,
          BrainDifficulty.medium => 6,
          BrainDifficulty.hard => 7,
        };
        final baseLength = switch (difficulty) {
          BrainDifficulty.easy => 3,
          BrainDifficulty.medium => 4,
          BrainDifficulty.hard => 5,
        };
        final baseFlash = switch (difficulty) {
          BrainDifficulty.easy => 560,
          BrainDifficulty.medium => 410,
          BrainDifficulty.hard => 290,
        };
        final roundPenalty = switch (difficulty) {
          BrainDifficulty.easy => 35,
          BrainDifficulty.medium => 30,
          BrainDifficulty.hard => 18,
        };
        for (final round in [0, 2, 4]) {
          final profile = sequenceEchoProfileForLevel(level, difficulty, round);
          final expectedLength = baseLength + round + index ~/ 2;
          final offset = (round * 3 + difficulty.index * 2) % base.length;
          expect(profile.totalRounds, baseRounds + index ~/ 3);
          expect(profile.sequenceLength, expectedLength);
          expect(
            profile.flashMs,
            (baseFlash - round * roundPenalty - index * 12).clamp(145, 560),
          );
          expect(
            profile.sequence,
            List<int>.generate(
              expectedLength,
              (i) => base[(offset + i) % base.length],
            ),
          );
        }
      }
    }
  });

  testWidgets('level 50 Sequence Echo opens on a narrow phone', (tester) async {
    await tester.binding.setSurfaceSize(const Size(320, 720));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      const MaterialApp(home: SequenceEchoScreen(trainingLevel: 50)),
    );
    await tester.pump();
    expect(find.text('L50'), findsOneWidget);
    expect(find.byKey(const Key('brain-difficulty-selector')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('level 50 can present and accept a sequence on a narrow phone', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(320, 720));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(
        home: SequenceEchoScreen(trainingLevel: 50, onFinish: (_) {}),
      ),
    );
    await tester.pump();
    final profile = sequenceEchoProfileForLevel(50, BrainDifficulty.medium, 0);
    expect(
      tester.getSize(find.byKey(const Key('sequence-echo-cell-0'))).width,
      greaterThanOrEqualTo(48),
    );
    await tester.ensureVisible(find.byKey(const Key('sequence-echo-start')));
    await tester.tap(find.byKey(const Key('sequence-echo-start')));
    for (var i = 0; i < profile.sequenceLength * 2 + 3; i++) {
      await tester.pump(const Duration(milliseconds: 300));
    }
    expect(find.text('Repeat the sequence.'), findsOneWidget);
    final firstCell = find.byKey(
      Key('sequence-echo-cell-${profile.sequence.first}'),
    );
    await tester.ensureVisible(firstCell);
    await tester.tap(firstCell);
    await tester.pump(const Duration(milliseconds: 60));
    expect(
      find.byKey(Key('sequence-echo-cell-${profile.sequence.first}-correct')),
      findsOneWidget,
    );
    await tester.pump(const Duration(milliseconds: 240));
    expect(find.text('Good. Keep going.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  test('levels 13–50 are deterministic, bounded and change by band', () {
    final signatures = <String>{};
    for (var level = 13; level <= 50; level++) {
      for (final difficulty in BrainDifficulty.values) {
        final first = sequenceEchoProfileForLevel(level, difficulty, 0);
        final again = sequenceEchoProfileForLevel(level, difficulty, 0);
        expect(first.sequence, again.sequence);
        expect(first.totalRounds, inInclusiveRange(7, 12));
        for (final round in [0, first.totalRounds - 1]) {
          final profile = sequenceEchoProfileForLevel(level, difficulty, round);
          expect(profile.sequenceLength, inInclusiveRange(7, 18));
          expect(profile.flashMs, inInclusiveRange(145, 560));
          expect(profile.sequence, hasLength(profile.sequenceLength));
          expect(
            profile.sequence.every((cell) => cell >= 0 && cell < 9),
            isTrue,
          );
          for (var i = 1; i < profile.sequence.length; i++) {
            expect(profile.sequence[i], isNot(profile.sequence[i - 1]));
          }
        }
      }
      if ([13, 23, 33, 43, 50].contains(level)) {
        final profile = sequenceEchoProfileForLevel(
          level,
          BrainDifficulty.medium,
          0,
        );
        signatures.add(
          '${profile.sequenceLength}|${profile.flashMs}|${profile.totalRounds}',
        );
      }
    }
    expect(signatures, hasLength(5));
  });
}
