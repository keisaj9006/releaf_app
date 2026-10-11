import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:releaf_app/core/providers.dart';
import 'package:releaf_app/features/sleep/application/sleep_progress_store.dart';
import 'package:releaf_app/features/sleep/presentation/sleep_screen.dart';
import 'package:releaf_app/features/stories/data/story_catalog.dart';
import 'package:releaf_app/features/stories/presentation/stories_preview_screen.dart';
import 'package:releaf_app/routing/app_routes.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('Stories preview catalogue contains the three prepared stories', () {
    expect(
      StoryCatalog.ownerPreview.map((story) => story.id).toList(),
      const [
        'TS01_BEYOND_THE_GATE',
        'TS02_KRYSTYNA_SKARBEK',
        'ST_L05_COMPUTER',
      ],
    );
  });

  testWidgets('Stories screen is focused and does not expose empty collections', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: StoriesPreviewScreen()),
    );
    await tester.pumpAndSettle();

    expect(find.text('Stories'), findsOneWidget);
    const titles = <String, String>{
      'TS01_BEYOND_THE_GATE': 'Beyond the Gate',
      'TS02_KRYSTYNA_SKARBEK': 'The Woman Who Crossed Every Border',
      'ST_L05_COMPUTER': 'Computer',
    };

    for (final entry in titles.entries) {
      final card = find.byKey(Key('story-preview-${entry.key}'));
      await tester.scrollUntilVisible(card, 300);
      expect(card, findsOneWidget);
      expect(
        find.descendant(of: card, matching: find.text(entry.value)),
        findsOneWidget,
      );
    }
    expect(find.text('OWNER PREVIEW'), findsNothing);
    expect(find.text('Night Mysteries'), findsNothing);
    expect(find.text('Fiction Escapes'), findsNothing);
    expect(find.text('Wonder Journeys'), findsNothing);
    expect(find.text('Drift Through History'), findsNothing);
    expect(find.text('See all'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Stories gateway opens a dedicated screen in preview builds', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final progress = SleepProgressStore(preferences);

    final router = GoRouter(
      initialLocation: AppRoutes.sleep,
      routes: [
        GoRoute(
          path: AppRoutes.sleep,
          builder: (_, _) => const SleepScreen(storiesPreviewEnabled: true),
        ),
        GoRoute(
          path: AppRoutes.storiesPreview,
          builder: (_, _) => const StoriesPreviewScreen(),
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(preferences),
          sleepProgressStoreProvider.overrideWith((ref) => progress),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    final stories = find.byKey(const Key('sleep-category-stories'));
    await tester.ensureVisible(stories);
    await tester.tap(stories);
    await tester.pumpAndSettle();

    expect(find.byType(StoriesPreviewScreen), findsOneWidget);
    expect(find.text('Stories'), findsOneWidget);
    expect(find.byKey(const Key('sleep-discovery-scroll')), findsNothing);
  });
}
