import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:releaf_app/core/providers.dart';
import 'package:releaf_app/features/relief/presentation/breathing_widget.dart';

Future<void> _pumpResetSession(WidgetTester tester) async {
  SharedPreferences.setMockInitialValues(<String, Object>{});
  final preferences = await SharedPreferences.getInstance();

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(preferences),
      ],
      child: const MaterialApp(
        home: BreathingWidget(sessionId: 'equal-rhythm'),
      ),
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
  testWidgets(
    'active Reset pauses its countdown while the app is backgrounded',
    (WidgetTester tester) async {
      await _pumpResetSession(tester);

      expect(_timerText(tester), '02:00');

      await tester.pump(const Duration(seconds: 2));
      final beforeBackground = _timerText(tester);
      expect(beforeBackground, isNot('02:00'));

      await tester.binding.handleAppLifecycleStateChanged(
        AppLifecycleState.paused,
      );
      await tester.pump();

      await tester.pump(const Duration(seconds: 8));
      expect(_timerText(tester), beforeBackground);

      await tester.binding.handleAppLifecycleStateChanged(
        AppLifecycleState.resumed,
      );
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      expect(_timerText(tester), isNot(beforeBackground));
    },
  );
}
