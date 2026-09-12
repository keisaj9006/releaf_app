import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:releaf_app/games/memory/memory_game_screen.dart';

void main() {
  testWidgets('timeout prevents pending pair resolution', (tester) async {
    var completions = 0;
    await tester.pumpWidget(
      MaterialApp(home: MemoryGameScreen(onFinish: (_) => completions++)),
    );
    await tester.pump(const Duration(milliseconds: 57500));
    await tester.tap(find.byKey(const ValueKey('memory-card-0')));
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('memory-card-1')));
    await tester.pump(const Duration(seconds: 1));
    expect(find.text("Time's up. Try again."), findsOneWidget);
    expect(completions, 0);
    for (var i = 0; i < 2; i++) {
      final card = tester.widget<Semantics>(
        find.byKey(ValueKey('memory-card-$i'), skipOffstage: false),
      );
      expect(card.properties.label, 'Revealed memory card');
    }
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('level fifty can be completed through the actual board', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(800, 1700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    var completions = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: MemoryGameScreen(
          trainingLevel: 50,
          onFinish: (_) => completions++,
        ),
      ),
    );
    final known = <String, List<int>>{};
    Future<String> reveal(int index) async {
      final card = find.byKey(ValueKey('memory-card-$index'));
      await tester.ensureVisible(card);
      await tester.tap(card);
      await tester.pump(const Duration(milliseconds: 1));
      return tester
          .widget<Text>(
            find.descendant(of: card, matching: find.byType(Text)).last,
          )
          .data!;
    }

    // Learn the board by revealing pairs, just as a player does.
    for (var i = 0; i < 24; i += 2) {
      final a = await reveal(i);
      final b = await reveal(i + 1);
      if (a != b) {
        known.putIfAbsent(a, () => []).add(i);
        known.putIfAbsent(b, () => []).add(i + 1);
      }
      await tester.pump(const Duration(milliseconds: 801));
    }
    for (final pair in known.values) {
      expect(pair, hasLength(2));
      await reveal(pair[0]);
      await reveal(pair[1]);
      await tester.pump(const Duration(milliseconds: 801));
    }
    await tester.pumpAndSettle();
    expect(find.text("You've matched all cards."), findsOneWidget);
    await tester.tap(find.text('Finish session'));
    await tester.pumpAndSettle();
    expect(completions, 1);
    expect(
      (await SharedPreferences.getInstance()).getInt('memory_stats_time_50'),
      isNotNull,
    );
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('reset invalidates an unresolved pair', (tester) async {
    await tester.pumpWidget(
      MaterialApp(home: MemoryGameScreen(onFinish: (_) {})),
    );
    await tester.tap(find.byKey(const ValueKey('memory-card-0')));
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('memory-card-1')));
    await tester.pump();
    await tester.tap(find.byTooltip('Reset level'));
    await tester.pump(const Duration(seconds: 1));
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('standalone saved level fifty survives reload at large text', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({'memory_current_level': 50});
    tester.view.physicalSize = const Size(320, 720);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: const TextScaler.linear(2)),
          child: child!,
        ),
        home: const MemoryGameScreen(),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Level 50'), findsOneWidget);
    expect(find.text('12 pairs'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
