import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:releaf_app/core/providers.dart';
import 'package:releaf_app/features/meditation/presentation/meditation_screen.dart';

Future<void> _pumpLibrary(
  WidgetTester tester, {
  String? recentId,
  double textScale = 1,
}) async {
  SharedPreferences.setMockInitialValues({
    if (recentId != null) 'meditation.recent_ids': [recentId],
  });
  final preferences = await SharedPreferences.getInstance();
  await tester.pumpWidget(
    ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(preferences)],
      child: MaterialApp(
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(textScale)),
          child: child!,
        ),
        home: const MeditationScreen(),
      ),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
}

void main() {
  testWidgets('Featured practice discloses missing voice before starting', (
    tester,
  ) async {
    await _pumpLibrary(tester, recentId: 'breath-and-body-4');
    final hero = find.byKey(const Key('meditation-featured-practice'));
    expect(
      find.descendant(of: hero, matching: find.text('Captions only')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: hero, matching: find.text('Eyes-closed ready')),
      findsNothing,
    );
    expect(
      find.descendant(of: hero, matching: find.text('Read & practise')),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('Recorded practice retains its voice and start action', (
    tester,
  ) async {
    await _pumpLibrary(tester);
    final hero = find.byKey(const Key('meditation-featured-practice'));
    expect(
      find.descendant(of: hero, matching: find.text('Recorded guide')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: hero, matching: find.text('Start practice')),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('Caption availability remains readable at 320px and large text', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(320, 740));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await _pumpLibrary(tester, recentId: 'breath-and-body-4', textScale: 2);
    final action = find.text('Read & practise');
    expect(action, findsOneWidget);
    await tester.ensureVisible(action);
    await tester.pumpAndSettle();
    expect(action.hitTestable(), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Premium meditation opens preview before paywall', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [sharedPreferencesProvider.overrideWithValue(preferences)],
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
    expect(find.textContaining('Captions only'), findsWidgets);
    await tester.tap(find.text('Body Scan'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byKey(const Key('meditation-premium-preview')), findsOneWidget);
    expect(find.text('PREMIUM PREVIEW'), findsOneWidget);
    expect(find.text('Body Scan'), findsWidgets);
    final preview = find.byKey(const Key('meditation-premium-preview'));
    expect(
      find.descendant(of: preview, matching: find.text('Captions only')),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: preview,
        matching: find.textContaining('no recorded voice'),
      ),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('meditation-premium-preview-unlock')),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });
}
