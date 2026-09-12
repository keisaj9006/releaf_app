import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:releaf_app/games/memory/memory_stats_screen.dart';

void main() {
  testWidgets('all fifty levels have readable horizontally browsable charts', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      'memory_current_level': 50,
      for (var i = 1; i <= 50; i++) 'memory_stats_time_$i': 20,
      for (var i = 1; i <= 50; i++) 'memory_stats_mistakes_$i': 2,
    });
    tester.view.physicalSize = const Size(320, 720);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const MaterialApp(home: MemoryStatsScreen()));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();
    expect(
      tester.widget<BarChart>(find.byType(BarChart)).data.barGroups,
      hasLength(50),
    );
    expect(
      tester.getSize(find.byType(BarChart)).width,
      greaterThanOrEqualTo(1200),
    );
    expect(tester.takeException(), isNull);
    await tester.tap(find.byKey(const Key('memory-stats-reset')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Reset stats'));
    await tester.pumpAndSettle();
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getInt('memory_current_level'), 50);
    expect(prefs.getInt('memory_stats_time_50'), isNull);
  });

  testWidgets('Memory stats renders saved progress in Brain visual language', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      'memory_stats_time_1': 18,
      'memory_stats_mistakes_1': 2,
      'memory_stats_time_2': 16,
      'memory_stats_mistakes_2': 1,
    });

    await tester.pumpWidget(const MaterialApp(home: MemoryStatsScreen()));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text('Training history'), findsOneWidget);
    expect(find.text('Completion time'), findsOneWidget);
    expect(find.text('Mistakes'), findsOneWidget);
    expect(find.text('2'), findsWidgets);
    expect(tester.takeException(), isNull);
  });
}
