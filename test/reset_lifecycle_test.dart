import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:releaf_app/core/providers.dart';
import 'package:releaf_app/features/relief/data/reset_catalog.dart';
import 'package:releaf_app/features/relief/application/reset_completion_store.dart';
import 'package:releaf_app/features/relief/presentation/breathing_widget.dart';
import 'package:releaf_app/theme/widgets/releaf_sensory_halo.dart';
import 'package:releaf_app/theme/widgets/releaf_session_living_form.dart';

Future<void> _pumpResetSession(
  WidgetTester tester, {
  String sessionId = 'equal-rhythm',
  bool reducedMotion = false,
}) async {
  SharedPreferences.setMockInitialValues(<String, Object>{});
  final preferences = await SharedPreferences.getInstance();

  await tester.pumpWidget(
    ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(preferences)],
      child: MaterialApp(
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(disableAnimations: reducedMotion),
          child: child!,
        ),
        home: BreathingWidget(sessionId: sessionId),
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
  for (final reduced in [false, true]) {
    testWidgets(
      'shared clock completes once at full duration, reduced $reduced',
      (tester) async {
        await _pumpResetSession(tester, reducedMotion: reduced);
        final container = ProviderScope.containerOf(
          tester.element(find.byType(BreathingWidget)),
        );
        final seconds = const ResetCatalog()
            .getById('equal-rhythm')!
            .durationSeconds;
        await tester.pump(Duration(seconds: seconds - 1));
        expect(container.read(resetCompletionStoreProvider), isEmpty);
        expect(
          find.byKey(const Key('reset-active-session-timer')),
          findsOneWidget,
        );
        await tester.pump(const Duration(seconds: 1));
        await tester.pump(const Duration(seconds: 1));
        expect(container.read(resetCompletionStoreProvider), hasLength(1));
        expect(
          container.read(resetCompletionStoreProvider).single.durationSeconds,
          seconds,
        );
        tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
        tester.binding.handleAppLifecycleStateChanged(
          AppLifecycleState.resumed,
        );
        await tester.pump(const Duration(seconds: 2));
        expect(container.read(resetCompletionStoreProvider), hasLength(1));
        await tester.pumpWidget(const SizedBox.shrink());
      },
    );
  }

  for (final session in const ResetCatalog().getAll().where(
    (session) => session.program?.breathPattern != null,
  )) {
    testWidgets('shared clock follows ${session.id} inhale, hold and exhale', (
      tester,
    ) async {
      await _pumpResetSession(tester, sessionId: session.id);
      final pattern = session.program!.breathPattern!;
      final form = tester.widget<ReleafSessionLivingForm>(
        find.byType(ReleafSessionLivingForm),
      );
      expect(form.elapsedSeconds, isNotNull);
      double scale() => tester
          .widgetList<Transform>(
            find.descendant(
              of: find.byType(ReleafSessionLivingForm),
              matching: find.byType(Transform),
            ),
          )
          .map((widget) => widget.transform.entry(0, 0))
          .firstWhere((value) => value != 1);
      await tester.pump(
        Duration(milliseconds: pattern.inhaleSeconds * 1000 - 250),
      );
      if (pattern.holdAfterInhaleSeconds > 0) {
        expect(find.text('Hold'), findsOneWidget);
        final held = scale();
        await tester.pump(const Duration(milliseconds: 400));
        expect(scale(), closeTo(held, 0.000001));
        await tester.pump(
          Duration(milliseconds: pattern.holdAfterInhaleSeconds * 1000 - 400),
        );
      }
      expect(find.text('Breathe out'), findsOneWidget);
      expect(
        form.elapsedSeconds!.value,
        closeTo(
          pattern.inhaleSeconds + pattern.holdAfterInhaleSeconds + 0.05,
          0.001,
        ),
      );
      final earlyExhale = scale();
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text('Breathe out'), findsOneWidget);
      expect(scale(), lessThan(earlyExhale));
      await tester.pumpWidget(const SizedBox.shrink());
    });
  }

  for (final reducedMotion in [false, true]) {
    testWidgets(
      'fractional breathing pause preserves phase, reduced $reducedMotion',
      (tester) async {
        await _pumpResetSession(tester, reducedMotion: reducedMotion);
        await tester.pump(const Duration(milliseconds: 4200));
        expect(find.text('Breathe in'), findsOneWidget);
        tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
        (tester.binding as AutomatedTestWidgetsFlutterBinding).elapseBlocking(
          const Duration(seconds: 3),
        );
        tester.binding.handleAppLifecycleStateChanged(
          AppLifecycleState.resumed,
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 600));
        expect(find.text('Breathe out'), findsOneWidget);
        expect(find.text('5 s left in this phase'), findsOneWidget);
        await tester.pumpWidget(const SizedBox.shrink());
      },
    );
  }

  testWidgets('breathing visual stops when no background frame is drawn', (
    tester,
  ) async {
    await _pumpResetSession(tester);
    await tester.pump(const Duration(seconds: 2));
    double scale() {
      final transforms = tester.widgetList<Transform>(
        find.descendant(
          of: find.byType(ReleafSessionLivingForm),
          matching: find.byType(Transform),
        ),
      );
      return transforms
          .map((widget) => widget.transform.entry(0, 0))
          .firstWhere((value) => value != 1);
    }

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    final pausedScale = scale();
    (tester.binding as AutomatedTestWidgetsFlutterBinding).elapseBlocking(
      const Duration(seconds: 3),
    );
    expect(scale(), closeTo(pausedScale, 0.000001));
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1));
    expect(scale(), closeTo(pausedScale, 0.001));
    await tester.pumpWidget(const SizedBox.shrink());
  });

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
