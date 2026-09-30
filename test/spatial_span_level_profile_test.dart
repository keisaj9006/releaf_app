import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:releaf_app/features/brain/application/brain_training_controller.dart';
import 'package:releaf_app/features/brain/presentation/widgets/brain_difficulty_selector.dart';
import 'package:releaf_app/games/spatial_span/spatial_span_level_profile.dart';
import 'package:releaf_app/games/spatial_span/spatial_span_screen.dart';

void main() {
  test('Spatial Span levels 1–12 retain every existing challenge value', () {
    for (var level = 1; level <= 12; level++) {
      final index = level - 1;
      for (final difficulty in BrainDifficulty.values) {
        for (var round = 1; round <= 3; round++) {
          final profile = spatialSpanProfileForLevel(level, difficulty, round);
          final side = switch (difficulty) {
            BrainDifficulty.easy => level >= 10 ? 4 : 3,
            BrainDifficulty.medium => level >= 8 ? 5 : 4,
            BrainDifficulty.hard => level >= 7 ? 5 : 4,
          };
          final penalty = switch (difficulty) {
            BrainDifficulty.easy => 0,
            BrainDifficulty.medium => 55,
            BrainDifficulty.hard => 105,
          };
          expect(profile.gridSide, side);
          expect(
            profile.sequenceLength,
            (3 + difficulty.index + index ~/ 2 + round - 1).clamp(3, 11),
          );
          expect(profile.onMs, (620 - index * 20 - penalty).clamp(260, 620));
          expect(profile.gapMs, (210 - index * 8).clamp(100, 210));
          expect(
            profile.seed,
            1733 + level * 1009 + difficulty.index * 4093 + round * 7919,
          );
        }
      }
    }
  });

  test('Spatial Span levels 13–50 are bounded and distinct by band', () {
    final signatures = <String>{};
    for (var level = 13; level <= 50; level++) {
      for (final difficulty in BrainDifficulty.values) {
        for (var round = 1; round <= 3; round++) {
          final profile = spatialSpanProfileForLevel(level, difficulty, round);
          expect(profile.gridSide, inInclusiveRange(4, 5));
          expect(profile.sequenceLength, inInclusiveRange(8, 14));
          expect(profile.onMs, inInclusiveRange(260, 410));
          expect(profile.gapMs, inInclusiveRange(100, 135));
          expect(
            profile.sequenceLength,
            lessThan(profile.gridSide * profile.gridSide),
          );
          expect(
            spatialSpanProfileForLevel(level, difficulty, round).seed,
            profile.seed,
          );
        }
      }
      if ([13, 23, 33, 43, 50].contains(level)) {
        final profile = spatialSpanProfileForLevel(
          level,
          BrainDifficulty.medium,
          1,
        );
        signatures.add(
          '${profile.gridSide}|${profile.sequenceLength}|${profile.onMs}',
        );
      }
    }
    expect(signatures, hasLength(5));
    expect(maxBrainTrainingLevelFor('spatial_span'), 50);
    expect(maxBrainTrainingLevelFor('pattern_logic'), 12);
  });

  testWidgets('Spatial Span level 50 shows its grid on a narrow phone', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(320, 720));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(home: SpatialSpanScreen(trainingLevel: 50, onFinish: (_) {})),
    );
    await tester.pump();
    expect(find.text('L50'), findsOneWidget);
    expect(find.text('5×5'), findsOneWidget);
    expect(find.byKey(const Key('spatial-span-cell-24')), findsOneWidget);
    final start = find.byKey(const Key('spatial-span-start'));
    await tester.ensureVisible(start);
    await tester.tap(start);
    final profile = spatialSpanProfileForLevel(50, BrainDifficulty.medium, 1);
    for (var i = 0; i < profile.sequenceLength * 2 + 4; i++) {
      await tester.pump(const Duration(milliseconds: 350));
    }
    expect(
      find.text('Your turn. Tap the same locations in the same order.'),
      findsOneWidget,
    );
    final firstCell = math.Random(
      profile.seed,
    ).nextInt(profile.gridSide * profile.gridSide);
    final cell = find.byKey(Key('spatial-span-cell-$firstCell'));
    await tester.ensureVisible(cell);
    await tester.tap(cell);
    await tester.pump(const Duration(milliseconds: 60));
    expect(
      find.text('1/${profile.sequenceLength} correct. Keep going.'),
      findsOneWidget,
    );
    await tester.pump(const Duration(milliseconds: 130));
    expect(tester.takeException(), isNull);
  });
}
