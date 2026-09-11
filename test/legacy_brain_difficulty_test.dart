import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:releaf_app/core/providers.dart';
import 'package:releaf_app/features/brain/presentation/game_host_screen.dart';
import 'package:releaf_app/features/brain/presentation/widgets/brain_difficulty_selector.dart';

void main() {
  test(
    'practice difficulty preserves Medium and bounds all training levels',
    () {
      for (var level = 1; level <= 12; level++) {
        final easy = brainPracticeLevelForDifficulty(
          level,
          BrainDifficulty.easy,
        );
        final medium = brainPracticeLevelForDifficulty(
          level,
          BrainDifficulty.medium,
        );
        final hard = brainPracticeLevelForDifficulty(
          level,
          BrainDifficulty.hard,
        );
        expect(medium, level);
        expect(easy, inInclusiveRange(1, medium));
        expect(hard, inInclusiveRange(medium, 12));
      }
      expect(brainPracticeLevelForDifficulty(-5, BrainDifficulty.easy), 1);
      expect(brainPracticeLevelForDifficulty(99, BrainDifficulty.hard), 12);
    },
  );
  for (final game in ['memory', 'broken_mirror', 'rule_shift']) {
    testWidgets(
      '$game supports difficulty before play and locks after interaction',
      (tester) async {
        SharedPreferences.setMockInitialValues({});
        final preferences = await SharedPreferences.getInstance();
        tester.view.physicalSize = const Size(320, 720);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        var completions = 0;
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              sharedPreferencesProvider.overrideWithValue(preferences),
            ],
            child: MaterialApp(
              home: Scaffold(
                body: buildBrainGame(
                  gameId: game,
                  trainingLevel: 6,
                  onFinish: (_) => completions++,
                ),
              ),
            ),
          ),
        );
        await tester.pump(const Duration(milliseconds: 300));
        expect(
          tester
              .widget<BrainDifficultySelector>(
                find.byType(BrainDifficultySelector),
              )
              .value,
          BrainDifficulty.medium,
        );
        if (game == 'memory') expect(find.text('5 pairs'), findsOneWidget);
        if (game == 'broken_mirror') {
          expect(
            find.textContaining('Level 6: place all 5 fragments'),
            findsOneWidget,
          );
        }
        if (game == 'rule_shift') {
          expect(
            find.textContaining('LEVEL 6 · ROUND 1 OF 17'),
            findsOneWidget,
          );
        }
        await tester.tap(find.byKey(const Key('brain-difficulty-hard')));
        await tester.pump(const Duration(milliseconds: 300));
        expect(
          tester
              .widget<BrainDifficultySelector>(
                find.byType(BrainDifficultySelector),
              )
              .value,
          BrainDifficulty.hard,
        );
        if (game == 'memory') {
          expect(find.text('Brain L6'), findsOneWidget);
          expect(find.text('6 pairs'), findsOneWidget);
          await tester.tap(find.bySemanticsLabel('Hidden memory card').first);
        } else if (game == 'broken_mirror') {
          expect(
            find.textContaining('Level 6: place all 6 fragments'),
            findsOneWidget,
          );
          await tester.drag(
            find.byKey(const ValueKey('broken-mirror-shard-0')),
            const Offset(8, 8),
          );
        } else {
          expect(
            find.textContaining('LEVEL 6 · ROUND 1 OF 19'),
            findsOneWidget,
          );
          await tester.tap(find.byKey(const Key('rule-shift-yes')));
        }
        await tester.pump(const Duration(milliseconds: 350));
        expect(
          tester
              .widget<BrainDifficultySelector>(
                find.byType(BrainDifficultySelector),
              )
              .enabled,
          isFalse,
        );
        await tester.tap(find.byKey(const Key('brain-difficulty-easy')));
        await tester.pump();
        expect(
          tester
              .widget<BrainDifficultySelector>(
                find.byType(BrainDifficultySelector),
              )
              .value,
          BrainDifficulty.hard,
        );
        expect(completions, 0);
        expect(preferences.getInt('memory_current_level'), isNull);
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox.shrink());
      },
    );
  }
}
