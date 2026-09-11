import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:releaf_app/core/providers.dart';
import 'package:releaf_app/features/relief/data/reset_catalog.dart';
import 'package:releaf_app/features/relief/presentation/breathing_widget.dart';
import 'package:releaf_app/features/relief/presentation/reset_session_preview_sheet.dart';

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
