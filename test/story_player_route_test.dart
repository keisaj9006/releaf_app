import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:releaf_app/core/providers.dart';
import 'package:releaf_app/features/sleep/application/sleep_progress_store.dart';
import 'package:releaf_app/features/stories/story_preview_config.dart';
import 'package:releaf_app/routing/app_router.dart';
import 'package:releaf_app/routing/app_routes.dart';

Future<void> _pumpStoriesRoute(
  WidgetTester tester, {
  required bool previewEnabled,
  String initialLocation = AppRoutes.storiesPreview,
}) async {
  SharedPreferences.setMockInitialValues({});
  final preferences = await SharedPreferences.getInstance();
  final router = createAppRouter(
    initialLocation: initialLocation,
    storiesPreviewEnabled: previewEnabled,
  );
  addTearDown(router.dispose);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(preferences),
        sleepProgressStoreProvider.overrideWith(
          (ref) => SleepProgressStore(preferences),
        ),
      ],
      child: MaterialApp.router(routerConfig: router),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  test('Story player path includes its stable content ID', () {
    expect(
      AppRoutes.sleepStoryPlayerFor('ST-DC-004'),
      '/sleep/story/ST-DC-004',
    );
  });

  test('Stories preview route redirects to Sleep when preview is disabled', () {
    expect(
      StoryPreviewConfig.redirectWhenDisabled(
        enabled: false,
        sleepRoute: AppRoutes.sleep,
      ),
      AppRoutes.sleep,
    );
  });

  test('Stories preview route stays open when preview is enabled', () {
    expect(
      StoryPreviewConfig.redirectWhenDisabled(
        enabled: true,
        sleepRoute: AppRoutes.sleep,
      ),
      isNull,
    );
  });

  testWidgets('direct Stories preview route is hidden when disabled', (
    WidgetTester tester,
  ) async {
    await _pumpStoriesRoute(tester, previewEnabled: false);

    expect(find.byKey(const Key('sleep-featured-sound')), findsOneWidget);
    expect(find.text('Stories Preview'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('direct Stories preview route opens when enabled', (
    WidgetTester tester,
  ) async {
    await _pumpStoriesRoute(tester, previewEnabled: true);

    expect(find.text('Stories Preview'), findsOneWidget);
    expect(find.text('OWNER PREVIEW'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('direct canonical Story route shows honest asset-pending state', (
    WidgetTester tester,
  ) async {
    await _pumpStoriesRoute(
      tester,
      previewEnabled: false,
      initialLocation: AppRoutes.sleepStoryPlayerFor('ST-DC-004'),
    );

    expect(
      find.text('The Princess and the Pea — A Rainy Night at the Palace'),
      findsOneWidget,
    );
    expect(find.byKey(const Key('story-audio-pending')), findsOneWidget);
    expect(find.byKey(const Key('story-play-pause')), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
