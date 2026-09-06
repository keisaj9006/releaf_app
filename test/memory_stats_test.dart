import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:releaf_app/games/memory/memory_stats_screen.dart';

void main() {
  testWidgets('Memory stats renders saved progress in Brain visual language', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      'memory_stats_time_1': 18,
      'memory_stats_mistakes_1': 2,
      'memory_stats_time_2': 16,
      'memory_stats_mistakes_2': 1,
    });

    await tester.pumpWidget(
      const MaterialApp(home: MemoryStatsScreen()),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text('Training history'), findsOneWidget);
    expect(find.text('Completion time'), findsOneWidget);
    expect(find.text('Mistakes'), findsOneWidget);
    expect(find.text('2'), findsWidgets);
    expect(tester.takeException(), isNull);
  });
}
