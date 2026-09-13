import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:releaf_app/core/providers.dart';
import 'package:releaf_app/features/home/home_personalization.dart';
import 'package:releaf_app/features/home/home_screen.dart';
import 'package:releaf_app/routing/app_router.dart';
import 'package:releaf_app/routing/app_routes.dart';

Future<void> _pumpHome(
  WidgetTester tester, {
  required Map<String, Object> initialValues,
  required int hour,
}) async {
  SharedPreferences.setMockInitialValues(initialValues);
  final preferences = await SharedPreferences.getInstance();
  final router = createAppRouter(initialLocation: AppRoutes.home);
  addTearDown(router.dispose);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(preferences),
        homeNowProvider.overrideWith(
          (ref) => DateTime(2026, 9, 13, hour),
        ),
      ],
      child: MaterialApp.router(routerConfig: router),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
}

void main() {
  testWidgets('parked Meditate is not used for the night recommendation', (
    tester,
  ) async {
    await _pumpHome(
      tester,
      initialValues: const {
        'releaf.home.intro.dismissed.v1': true,
      },
      hour: 21,
    );

    expect(find.text('Let the Day Go'), findsNothing);
    expect(find.text('Sleep sounds'), findsOneWidget);
  });

  testWidgets('mindfulness focus stays within the active Releaf 1.0 pillars', (
    tester,
  ) async {
    await _pumpHome(
      tester,
      initialValues: {
        'releaf.home.intro.dismissed.v1': true,
        'releaf.home.focus.v1': HomeFocus.mindfulness.name,
      },
      hour: 12,
    );

    expect(find.text('Mindfulness Basics'), findsNothing);
    expect(find.text('Back to the Room'), findsOneWidget);
  });

  testWidgets('recent meditation history is not rediscovered from Home', (
    tester,
  ) async {
    await _pumpHome(
      tester,
      initialValues: const {
        'releaf.home.intro.dismissed.v1': true,
        'meditation.recent_ids': <String>['breath-and-body-4'],
      },
      hour: 12,
    );

    expect(find.text('RECENT MEDITATION'), findsNothing);
  });
}
