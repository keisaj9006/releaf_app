import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:releaf_app/core/providers.dart';
import 'package:releaf_app/features/brain/presentation/brain_screen.dart';

void main() {
  testWidgets('Brain cards show current and maximum progressive level', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      'brain.training.completion_counts.v1': <String>[
        'labyrinth|50',
        'sequence_echo|22',
      ],
    });
    final preferences = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(preferences),
        ],
        child: const MaterialApp(home: BrainScreen()),
      ),
    );
    await tester.pump();

    expect(find.text('L26/50 · 3 MODES'), findsOneWidget);
    expect(find.text('L12/12 · 3 MODES'), findsOneWidget);
  });
}
