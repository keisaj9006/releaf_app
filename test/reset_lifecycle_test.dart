import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:releaf_app/core/providers.dart';
import 'package:releaf_app/features/relief/presentation/breathing_widget.dart';
import 'package:releaf_app/theme/widgets/releaf_sensory_halo.dart';

Future<void> _pumpResetSession(
  WidgetTester tester, {
  String sessionId = 'equal-rhythm',
}) async {
  SharedPreferences.setMockInitialValues(<String, Object>{});
  final preferences = await SharedPreferences.getInstance();

  await tester.pumpWidget(
    ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(preferences)],
      child: MaterialApp(home: BreathingWidget(sessionId: sessionId)),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
}

String _timerText(WidgetTester tester) {
  final timer = find.byKey(const Key('reset-active-session-timer'));
  expect(timer, findsOneWidget);
  final text = tester.widget<Text>(timer);
  return text.data ?? '';
}

void main() {
  for (final simplified in [false, true]) {
    testWidgets(
      'sensory notices survive lifecycle pause, simplified $simplified',
      (tester) async {
        await _pumpResetSession(tester, sessionId: 'back-to-room');
        if (simplified) {
          await tester.tap(find.byKey(const Key('reset-simplify-action')));
        } else {
          await tester.tap(find.byKey(const Key('reset-step-advance-action')));
        }
        await tester.pump();
        final halo = find.byType(ReleafSensoryHalo);
        await tester.tap(halo);
        await tester.pump();
        expect(tester.widget<ReleafSensoryHalo>(halo).completedCount, 1);
        final remaining = _timerText(tester);
        for (final state in [
          AppLifecycleState.inactive,
          AppLifecycleState.hidden,
          AppLifecycleState.paused,
        ]) {
          tester.binding.handleAppLifecycleStateChanged(state);
          await tester.pump();
        }
        await tester.pump(const Duration(seconds: 90));
        expect(_timerText(tester), remaining);
        expect(tester.widget<ReleafSensoryHalo>(halo).completedCount, 1);
        expect(tester.widget<ReleafSensoryHalo>(halo).phaseLabel, 'See');
        tester.binding.handleAppLifecycleStateChanged(
          AppLifecycleState.resumed,
        );
        await tester.pump();
        await tester.pump(const Duration(seconds: 1));
        expect(_timerText(tester), isNot(remaining));
        final target = simplified ? 3 : 5;
        for (var i = 1; i < target; i++) {
          await tester.tap(halo);
          await tester.pump();
        }
        expect(tester.widget<ReleafSensoryHalo>(halo).phaseLabel, 'Feel');
        expect(tester.widget<ReleafSensoryHalo>(halo).completedCount, 0);
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox.shrink());
      },
    );
  }

  testWidgets(
    'active Reset pauses its countdown while the app is backgrounded',
    (WidgetTester tester) async {
      await _pumpResetSession(tester);

      expect(_timerText(tester), '02:00');

      await tester.pump(const Duration(seconds: 2));
      final beforeBackground = _timerText(tester);
      expect(beforeBackground, isNot('02:00'));

      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      await tester.pump();

      await tester.pump(const Duration(seconds: 8));
      expect(_timerText(tester), beforeBackground);

      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      expect(_timerText(tester), isNot(beforeBackground));
    },
  );
}
