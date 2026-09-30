import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:releaf_app/features/brain/application/brain_training_controller.dart';
import 'package:releaf_app/features/brain/presentation/widgets/brain_difficulty_selector.dart';
import 'package:releaf_app/games/rule_shift/rule_shift_level_profile.dart';
import 'package:releaf_app/games/rule_shift/rule_shift_screen.dart';

void main() {
  test('levels 1–12 retain their exact legacy challenge dimensions', () {
    for (var level = 1; level <= 12; level++) {
      final profile = ruleShiftProfileForLevel(level);
      expect(profile.level, level);
      expect(profile.trialCount, 11 + level);
      expect(
        profile.ruleCount,
        level >= 7
            ? 4
            : level >= 4
            ? 3
            : 2,
      );
      expect(
        profile.switchBlockSize,
        level >= 6
            ? 1
            : level >= 3
            ? 2
            : 3,
      );
    }
  });

  test('levels 13–50 stay bounded and change across challenge bands', () {
    final signatures = <String>{};
    for (var level = 13; level <= 50; level++) {
      final profile = ruleShiftProfileForLevel(level);
      expect(profile.level, level);
      expect(profile.trialCount, inInclusiveRange(23, 30));
      expect(profile.ruleCount, inInclusiveRange(4, 6));
      expect(profile.switchBlockSize, 1);
      if ([13, 23, 33, 43, 50].contains(level)) {
        signatures.add('${profile.ruleCount}|${profile.trialCount}');
      }
    }
    expect(signatures, hasLength(5));
    expect(maxBrainTrainingLevelFor('rule_shift'), 50);
  });

  testWidgets('level 50 remains readable with 200% text', (tester) async {
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
        home: const RuleShiftScreen(trainingLevel: 50),
      ),
    );
    await tester.pump();
    expect(find.byKey(const Key('rule-shift-yes')), findsOneWidget);
    expect(find.byKey(const Key('rule-shift-no')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('mastery level actually presents the added rules', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: RuleShiftScreen(trainingLevel: 33)),
    );
    await tester.pump();
    for (var i = 0; i < 4; i++) {
      await tester.ensureVisible(find.byKey(const Key('rule-shift-no')));
      await tester.tap(find.byKey(const Key('rule-shift-no')));
      await tester.pump(const Duration(milliseconds: 300));
    }
    expect(find.text('IS IT A PRIME NUMBER?'), findsOneWidget);
    await tester.tap(find.byKey(const Key('rule-shift-no')));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('IS IT LESS THAN 4?'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('level 50 shows its own profile on a narrow phone', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(320, 640));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      const MaterialApp(home: RuleShiftScreen(trainingLevel: 50)),
    );
    await tester.pump();
    final profile = ruleShiftProfileForLevel(50);
    expect(
      find.textContaining(
        'LEVEL 50 · ROUND 1 OF ${profile.trialCount} · ${profile.ruleCount} RULES',
      ),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('level 13 completes once without altering reward semantics', (
    tester,
  ) async {
    final completions = <int?>[];
    await tester.pumpWidget(
      MaterialApp(
        home: RuleShiftScreen(trainingLevel: 13, onFinish: completions.add),
      ),
    );
    await tester.pump();
    final trialCount = ruleShiftProfileForLevel(13).trialCount;
    for (var i = 0; i < trialCount; i++) {
      await tester.ensureVisible(find.byKey(const Key('rule-shift-yes')));
      await tester.tap(find.byKey(const Key('rule-shift-yes')));
      await tester.pump(const Duration(milliseconds: 300));
    }
    expect(completions, hasLength(1));
    expect(completions.single, inInclusiveRange(0, trialCount * 100));
    await tester.pump(const Duration(seconds: 1));
    expect(completions, hasLength(1));
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'higher-level difficulty adjusts practice while saved label stays put',
    (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: RuleShiftScreen(trainingLevel: 23)),
      );
      await tester.pump();
      final medium = ruleShiftProfileForLevel(23).trialCount;
      expect(find.textContaining('ROUND 1 OF $medium'), findsOneWidget);
      await tester.tap(find.byKey(const Key('brain-difficulty-hard')));
      await tester.pump();
      final hard = ruleShiftProfileForLevel(25).trialCount;
      expect(
        find.textContaining('LEVEL 23 · ROUND 1 OF $hard'),
        findsOneWidget,
      );
      expect(
        tester
            .widget<BrainDifficultySelector>(
              find.byType(BrainDifficultySelector),
            )
            .value,
        BrainDifficulty.hard,
      );
    },
  );
}
