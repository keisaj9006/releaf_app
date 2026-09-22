import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:releaf_app/core/providers.dart';
import 'package:releaf_app/features/stories/story_preview_config.dart';
import 'package:releaf_app/routing/app_router.dart';
import 'package:releaf_app/routing/app_routes.dart';

Future<void> _pumpStoriesRoute(
  WidgetTester tester, {
  required bool previewEnabled,
}) async {
  SharedPreferences.setMockInitialValues({});
  final preferences = await SharedPreferences.getInstance();
  final router = createAppRouter(
    initialLocation: AppRoutes.storiesPreview,
    storiesPreviewEnabled: previewEnabled,
  );
  addTearDown(router.dispose);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(preferences),
      ],
      child: MaterialApp.router(routerConfig: router),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
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

    expect(find.text('Sleep'), findsOneWidget);
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
}
