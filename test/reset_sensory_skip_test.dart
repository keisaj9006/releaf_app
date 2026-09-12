import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:releaf_app/core/providers.dart';
import 'package:releaf_app/features/relief/domain/models/reset_launch_options.dart';
import 'package:releaf_app/features/relief/presentation/breathing_widget.dart';

void main() {
  for (final words in [true, false]) {
    testWidgets('sensory steps can be skipped with guidance text $words', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(320, 640));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final semantics = tester.ensureSemantics();
      SharedPreferences.setMockInitialValues({});
      final preferences = await SharedPreferences.getInstance();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [sharedPreferencesProvider.overrideWithValue(preferences)],
          child: MaterialApp(
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaler: const TextScaler.linear(2),
                disableAnimations: true,
              ),
              child: child!,
            ),
            home: BreathingWidget(
              sessionId: 'back-to-room',
              launchOptions: ResetLaunchOptions(
                showGuidanceText: words,
                voiceGuidanceEnabled: false,
                ambientSoundEnabled: false,
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      final action = find.byKey(const Key('reset-step-advance-action'));
      expect(action, findsOneWidget);
      await tester.ensureVisible(action);
      await tester.tap(action);
      await tester.pump();
      for (var i = 0; i < 5; i++) {
        expect(find.bySemanticsLabel('Skip this sense'), findsOneWidget);
        expect(
          find.text('Skip this sense'),
          words ? findsOneWidget : findsNothing,
        );
        await tester.ensureVisible(action);
        await tester.tap(action);
        await tester.pump();
      }
      expect(find.bySemanticsLabel('Finish practice'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
      semantics.dispose();
    });
  }
}
