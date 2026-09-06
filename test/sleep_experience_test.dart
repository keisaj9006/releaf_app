import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:releaf_app/core/providers.dart';
import 'package:releaf_app/features/sleep/presentation/sleep_screen.dart';

Future<SharedPreferences> _preferences() async {
  SharedPreferences.setMockInitialValues({});
  return SharedPreferences.getInstance();
}

void main() {
  testWidgets('Sleep stays audio-only and exposes Premium preview', (
    WidgetTester tester,
  ) async {
    final preferences = await _preferences();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(preferences),
        ],
        child: const MaterialApp(home: SleepScreen()),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Sleep'), findsOneWidget);
    expect(
      find.text(
        'No voice. No instructions. Just low-stimulation sound for the final part of the day.',
      ),
      findsOneWidget,
    );
    expect(find.textContaining('Voice guidance'), findsNothing);
    expect(find.byKey(const Key('sleep-featured-sound')), findsOneWidget);

    final premiumSound = find.byKey(const Key('sleep-sound-pink-noise'));
    expect(premiumSound, findsOneWidget);

    await tester.ensureVisible(premiumSound);
    await tester.pumpAndSettle();
    await tester.tap(premiumSound);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byKey(const Key('sleep-premium-preview')), findsOneWidget);
    expect(find.text('Pink Noise'), findsWidgets);
    expect(find.textContaining('No voice'), findsWidgets);
    expect(
      find.byKey(const Key('sleep-premium-preview-unlock')),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('Sleep remains overflow-free at 320px', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(320, 640));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final preferences = await _preferences();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(preferences),
        ],
        child: const MaterialApp(home: SleepScreen()),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byKey(const Key('sleep-featured-sound')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
