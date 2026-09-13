import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:releaf_app/core/providers.dart';
import 'package:releaf_app/features/brain/application/brain_training_controller.dart';
import 'package:releaf_app/features/brain/presentation/game_result_screen.dart';

Future<SharedPreferences> _preferencesWithScore(int score) async {
  SharedPreferences.setMockInitialValues({});
  final preferences = await SharedPreferences.getInstance();
  final seed = BrainTrainingController(preferences);
  await seed.recordCompletion(gameId: 'sequence_echo', score: score);
  seed.dispose();
  return preferences;
}

void main() {
  testWidgets('completed Brain result marks a new higher score as Personal best', (
    tester,
  ) async {
    final preferences = await _preferencesWithScore(100);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(preferences),
        ],
        child: const MaterialApp(
          home: GameResultScreen(
            gameId: 'sequence_echo',
            score: 150,
            completed: true,
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('150'), findsOneWidget);
    expect(find.text('Personal best'), findsOneWidget);

    final restored = BrainTrainingController(preferences);
    addTearDown(restored.dispose);
    expect(restored.state.bestScoreFor('sequence_echo'), 150);
    expect(restored.state.completionCountFor('sequence_echo'), 2);
    expect(tester.takeException(), isNull);
  });

  testWidgets('completed Brain result does not label a lower score Personal best', (
    tester,
  ) async {
    final preferences = await _preferencesWithScore(200);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(preferences),
        ],
        child: const MaterialApp(
          home: GameResultScreen(
            gameId: 'sequence_echo',
            score: 150,
            completed: true,
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('150'), findsOneWidget);
    expect(find.text('Personal best'), findsNothing);

    final restored = BrainTrainingController(preferences);
    addTearDown(restored.dispose);
    expect(restored.state.bestScoreFor('sequence_echo'), 200);
    expect(restored.state.completionCountFor('sequence_echo'), 2);
    expect(tester.takeException(), isNull);
  });
}
