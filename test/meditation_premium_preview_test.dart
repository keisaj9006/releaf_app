import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:releaf_app/core/providers.dart';
import 'package:releaf_app/features/meditation/presentation/meditation_screen.dart';

void main() {
  testWidgets('Premium meditation opens preview before paywall', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(preferences),
        ],
        child: const MaterialApp(home: MeditationScreen()),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    final bodyCategory = find.text('Body Awareness').first;
    await tester.ensureVisible(bodyCategory);
    await tester.pumpAndSettle();
    await tester.tap(bodyCategory);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Body Scan'), findsOneWidget);
    await tester.tap(find.text('Body Scan'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(
      find.byKey(const Key('meditation-premium-preview')),
      findsOneWidget,
    );
    expect(find.text('PREMIUM PREVIEW'), findsOneWidget);
    expect(find.text('Body Scan'), findsWidgets);
    expect(
      find.byKey(const Key('meditation-premium-preview-unlock')),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });
}
