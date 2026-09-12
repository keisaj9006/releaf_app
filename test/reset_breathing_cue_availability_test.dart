import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:releaf_app/core/providers.dart';
import 'package:releaf_app/features/relief/data/reset_catalog.dart';
import 'package:releaf_app/features/relief/domain/models/reset_launch_options.dart';
import 'package:releaf_app/features/relief/presentation/breathing_widget.dart';
import 'package:releaf_app/features/relief/presentation/reset_session_preview_sheet.dart';
import 'package:releaf_app/theme/widgets/releaf_session_living_form.dart';

Future<SharedPreferences> _pump(WidgetTester tester, Widget home) async {
  SharedPreferences.setMockInitialValues({
    'reset.audio.voice.enabled': true,
    'reset.audio.ambient.enabled': false,
  });
  final preferences = await SharedPreferences.getInstance();
  await tester.pumpWidget(
    ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(preferences)],
      child: MaterialApp(
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(disableAnimations: true),
          child: child!,
        ),
        home: home,
      ),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
  return preferences;
}

void main() {
  testWidgets('guided breathing exposes one live phase, not a live countdown', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await _pump(tester, const BreathingWidget(sessionId: 'equal-rhythm'));
    SemanticsData phase() => tester
        .getSemantics(
          find.bySemanticsLabel(RegExp(r'Releaf calming visual\. Breathe')),
        )
        .getSemanticsData();
    final inhale = phase();
    expect(inhale.flagsCollection.isLiveRegion, isTrue);
    expect(inhale.label, 'Releaf calming visual. Breathe in');
    await tester.pump(const Duration(seconds: 1));
    expect(phase().label, inhale.label);
    await tester.pump(const Duration(seconds: 4));
    expect(phase().label, 'Releaf calming visual. Breathe out');
    expect(phase().flagsCollection.isLiveRegion, isTrue);
    await tester.pumpWidget(const SizedBox.shrink());
    semantics.dispose();
  });

  testWidgets('no words breathing does not enable live phase announcements', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await _pump(
      tester,
      const BreathingWidget(
        sessionId: 'equal-rhythm',
        launchOptions: ResetLaunchOptions(showGuidanceText: false),
      ),
    );
    final phase = tester
        .getSemantics(
          find.bySemanticsLabel(RegExp(r'Releaf calming visual\. Breathe')),
        )
        .getSemanticsData();
    expect(phase.flagsCollection.isLiveRegion, isFalse);
    await tester.pumpWidget(const SizedBox.shrink());
    semantics.dispose();
  });

  testWidgets('reduced motion keeps unequal breathing path stationary', (
    tester,
  ) async {
    await _pump(tester, const BreathingWidget(sessionId: '90s-calm-down'));
    CustomPainter path() => tester
        .widget<CustomPaint>(find.byKey(const Key('reset-breath-path')))
        .painter!;
    final first = path();
    void paintPath(Canvas canvas) => first.paint(canvas, const Size(240, 240));
    expect(paintPath, paintsExactlyCountTimes(#drawOval, 1));
    expect(paintPath, paintsExactlyCountTimes(#drawCircle, 0));
    await tester.pump(const Duration(milliseconds: 400));
    expect(path().shouldRepaint(first), isFalse);
    expect(find.text('Breathe in'), findsOneWidget);
    final form = find.byType(ReleafSessionLivingForm);
    final progress = tester.widget<TweenAnimationBuilder<double>>(
      find.descendant(
        of: form,
        matching: find.byType(TweenAnimationBuilder<double>),
      ),
    );
    expect(progress.duration, Duration.zero);
    final phase = tester.widget<AnimatedOpacity>(
      find.descendant(of: form, matching: find.byType(AnimatedOpacity)),
    );
    expect(phase.duration, Duration.zero);
    await tester.pump(const Duration(seconds: 4));
    expect(find.text('Breathe out'), findsOneWidget);
    expect(path().shouldRepaint(first), isFalse);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('no words mode omits the added breathing phase countdown', (
    tester,
  ) async {
    await _pump(
      tester,
      const BreathingWidget(
        sessionId: 'equal-rhythm',
        launchOptions: ResetLaunchOptions(showGuidanceText: false),
      ),
    );
    expect(find.byKey(const Key('reset-breath-phase-remaining')), findsNothing);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets(
    'reduced motion removes active Reset text and shell transitions',
    (tester) async {
      await _pump(tester, const BreathingWidget(sessionId: 'equal-rhythm'));
      final transitions = tester.widgetList<AnimatedSwitcher>(
        find.descendant(
          of: find.byType(BreathingWidget),
          matching: find.byType(AnimatedSwitcher),
        ),
      );
      expect(transitions.length, greaterThanOrEqualTo(2));
      for (final transition in transitions) {
        expect(transition.duration, Duration.zero);
      }
      expect(find.text('Breathe in'), findsOneWidget);
      expect(find.text('5 s left in this phase'), findsOneWidget);
      await tester.pump(const Duration(seconds: 1));
      expect(find.text('4 s left in this phase'), findsOneWidget);
      await tester.pump(const Duration(seconds: 4));
      expect(find.text('Breathe out'), findsOneWidget);
      expect(find.text('5 s left in this phase'), findsOneWidget);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  testWidgets(
    'breathing preview discloses unavailable cues without changing preferences',
    (tester) async {
      final preferences = await _pump(
        tester,
        Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () => showResetSessionPreview(
                context,
                session: const ResetCatalog().getById('equal-rhythm')!,
                isLocked: false,
              ),
              child: const Text('Preview'),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Preview'));
      await tester.pumpAndSettle();
      final tile = find.byKey(const Key('reset-preview-voice-toggle'));
      await tester.ensureVisible(tile);
      final toggle = tester.widget<Switch>(
        find.descendant(of: tile, matching: find.byType(Switch)),
      );
      expect(toggle.value, isFalse);
      expect(toggle.onChanged, isNull);
      expect(
        find.text(
          'Follow the on-screen breathing rhythm. Breathing audio is not available yet.',
        ),
        findsOneWidget,
      );
      expect(find.byKey(const Key('reset-preview-voice-volume')), findsNothing);
      expect(preferences.getBool('reset.audio.voice.enabled'), isTrue);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'breathing audio settings remain honest while visual guidance advances without motion',
    (tester) async {
      final semantics = tester.ensureSemantics();
      final preferences = await _pump(
        tester,
        const BreathingWidget(sessionId: 'equal-rhythm'),
      );
      expect(find.text('Breathe in'), findsOneWidget);
      expect(
        find.bySemanticsLabel(RegExp(r'Releaf calming visual\. Breathe in')),
        findsOneWidget,
      );
      await tester.pump(const Duration(seconds: 5));
      expect(find.text('Breathe out'), findsOneWidget);
      expect(
        find.bySemanticsLabel(RegExp(r'Releaf calming visual\. Breathe out')),
        findsOneWidget,
      );
      semantics.dispose();

      await tester.tap(find.byKey(const Key('reset-active-audio-button')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      final toggle = tester.widget<SwitchListTile>(
        find.byKey(const Key('reset-active-voice-toggle')),
      );
      expect(toggle.value, isFalse);
      expect(toggle.onChanged, isNull);
      expect(
        find.text(
          'Follow the on-screen breathing rhythm. Breathing audio is not available yet.',
        ),
        findsOneWidget,
      );
      final cueDescription = tester.widget<RichText>(
        find.descendant(
          of: find.text(
            'Follow the on-screen breathing rhythm. Breathing audio is not available yet.',
          ),
          matching: find.byType(RichText),
        ),
      );
      final foreground = cueDescription.text.style!.color!;
      const background = Color(0xFF0D1512);
      final visibleColor = Color.alphaBlend(foreground, background);
      final textLuminance = visibleColor.computeLuminance();
      final backgroundLuminance = background.computeLuminance();
      final contrast = textLuminance > backgroundLuminance
          ? (textLuminance + 0.05) / (backgroundLuminance + 0.05)
          : (backgroundLuminance + 0.05) / (textLuminance + 0.05);
      expect(contrast, greaterThanOrEqualTo(4.5));
      expect(find.byKey(const Key('reset-active-voice-volume')), findsNothing);
      expect(find.text('Turn sound on'), findsOneWidget);
      expect(preferences.getBool('reset.audio.voice.enabled'), isTrue);
      expect(tester.takeException(), isNull);
    },
  );
}
