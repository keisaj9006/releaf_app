import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:releaf_app/core/providers.dart';
import 'package:releaf_app/features/sleep/application/sleep_progress_store.dart';
import 'package:releaf_app/features/sleep/data/sleep_catalog.dart';
import 'package:releaf_app/features/sleep/domain/sleep_content.dart';
import 'package:releaf_app/features/sleep/presentation/sleep_screen.dart';
import 'package:releaf_app/routing/app_routes.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<({SharedPreferences preferences, SleepProgressStore progress})>
_testState() async {
  SharedPreferences.setMockInitialValues({});
  final preferences = await SharedPreferences.getInstance();
  return (preferences: preferences, progress: SleepProgressStore(preferences));
}

Future<void> _pumpSleep(
  WidgetTester tester, {
  required SharedPreferences preferences,
  required SleepProgressStore progress,
  bool storiesPreviewEnabled = false,
  Size size = const Size(390, 844),
  double textScale = 1,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(preferences),
        sleepProgressStoreProvider.overrideWith((ref) => progress),
      ],
      child: MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(textScaler: TextScaler.linear(textScale)),
          child: SleepScreen(storiesPreviewEnabled: storiesPreviewEnabled),
        ),
      ),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
}

Future<void> _selectCategory(
  WidgetTester tester,
  SleepCategory category,
) async {
  final gateway = find.byKey(Key('sleep-category-${category.name}'));
  await tester.ensureVisible(gateway);
  await tester.tap(gateway);
  await tester.pumpAndSettle();
}

void main() {
  test('Sleep content resolves through the existing feature routes', () {
    const catalog = SleepCatalog();

    expect(
      sleepRouteFor(catalog.getById('deep-drift')!),
      AppRoutes.soundPlayerFor('deep-drift'),
    );
    expect(
      sleepRouteFor(catalog.getById('let-the-day-go-6')!),
      AppRoutes.meditationSessionFor('let-the-day-go-6'),
    );
    expect(
      sleepRouteFor(catalog.getById('ST-DC-004')!),
      AppRoutes.sleepStoryPlayerFor('ST-DC-004'),
    );
  });

  testWidgets('Sleep discovery exposes four clear category gateways', (
    tester,
  ) async {
    final state = await _testState();
    await _pumpSleep(
      tester,
      preferences: state.preferences,
      progress: state.progress,
    );

    for (final category in SleepCategory.values) {
      expect(
        find.byKey(Key('sleep-category-${category.name}')),
        findsOneWidget,
      );
    }
    expect(find.text('Tonight'), findsOneWidget);
    expect(find.text('Popular'), findsNothing);
    await _selectCategory(tester, SleepCategory.stories);
    expect(find.text('Bedtime stories'), findsOneWidget);
    expect(find.text('Night Mysteries'), findsNothing);
    expect(find.text('Fiction Escapes'), findsNothing);
    expect(find.text('Wonder Journeys'), findsNothing);
    expect(find.text('Drift Through History'), findsNothing);
    expect(find.text('See all'), findsNothing);
    expect(find.byKey(const Key('sleep-open-sound-library')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('pending Story drafts stay out of customer discovery', (
    tester,
  ) async {
    final state = await _testState();
    await _pumpSleep(
      tester,
      preferences: state.preferences,
      progress: state.progress,
    );

    await _selectCategory(tester, SleepCategory.stories);
    expect(find.byKey(const Key('sleep-content-ST-DC-004')), findsNothing);
    expect(find.text('AUDIO IN PRODUCTION'), findsNothing);
    expect(find.text('Bedtime stories'), findsOneWidget);
  });

  testWidgets('standard Sleep view never renders empty Story collections', (
    tester,
  ) async {
    final state = await _testState();
    await _pumpSleep(
      tester,
      preferences: state.preferences,
      progress: state.progress,
    );

    await _selectCategory(tester, SleepCategory.stories);
    expect(find.text('Bedtime stories'), findsOneWidget);
    expect(find.text('Dream Classics'), findsNothing);
    expect(find.text('See all'), findsNothing);
  });

  testWidgets('category filter shows only the selected content family', (
    tester,
  ) async {
    final state = await _testState();
    await _pumpSleep(
      tester,
      preferences: state.preferences,
      progress: state.progress,
    );

    await _selectCategory(tester, SleepCategory.nature);

    expect(find.text('Nature for the night'), findsOneWidget);
    expect(find.byKey(const Key('sleep-content-soft-rain')), findsOneWidget);
    expect(find.byKey(const Key('sleep-content-deep-drift')), findsNothing);
    expect(find.text('Dream Classics'), findsNothing);
  });

  testWidgets('Continue Listening uses valid local Sleep progress', (
    tester,
  ) async {
    final state = await _testState();
    await state.progress.updatePosition(
      contentId: 'deep-drift',
      position: const Duration(minutes: 8),
      duration: const Duration(minutes: 30),
    );
    await _pumpSleep(
      tester,
      preferences: state.preferences,
      progress: state.progress,
    );

    expect(find.text('Continue Listening'), findsOneWidget);
    expect(find.byKey(const Key('sleep-continue-deep-drift')), findsOneWidget);
    expect(find.text('8 min listened'), findsOneWidget);
  });

  testWidgets('Premium content opens a preview before any paywall', (
    tester,
  ) async {
    final state = await _testState();
    await _pumpSleep(
      tester,
      preferences: state.preferences,
      progress: state.progress,
    );

    await _selectCategory(tester, SleepCategory.nature);
    final premiumSound = find.byKey(const Key('sleep-content-ocean-wash'));
    expect(premiumSound, findsOneWidget);
    await tester.ensureVisible(premiumSound);
    await tester.tap(premiumSound);
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('sleep-premium-preview')), findsOneWidget);
    expect(find.text('Ocean Wash'), findsWidgets);
    expect(
      find.byKey(const Key('sleep-premium-preview-unlock')),
      findsOneWidget,
    );
  });

  testWidgets('Sleep removes the duplicate owner-preview row', (
    tester,
  ) async {
    final state = await _testState();
    await _pumpSleep(
      tester,
      preferences: state.preferences,
      progress: state.progress,
      storiesPreviewEnabled: true,
    );

    expect(find.byKey(const Key('sleep-stories-preview')), findsNothing);
    expect(find.text('OWNER PREVIEW'), findsNothing);
    expect(find.byKey(const Key('sleep-category-stories')), findsOneWidget);
  });

  testWidgets('Sleep remains usable at 320px with large text', (tester) async {
    final state = await _testState();
    await _pumpSleep(
      tester,
      preferences: state.preferences,
      progress: state.progress,
      size: const Size(320, 640),
      textScale: 2,
    );

    expect(find.byKey(const Key('sleep-discovery-scroll')), findsOneWidget);
    expect(find.byKey(const Key('sleep-open-sound-library')), findsOneWidget);
    for (final category in SleepCategory.values) {
      await _selectCategory(tester, category);
      expect(
        find.byKey(Key('sleep-category-${category.name}')),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    }
  });
  testWidgets('Sleep has one primary action and four category gateways', (
    tester,
  ) async {
    final state = await _testState();
    await _pumpSleep(
      tester,
      preferences: state.preferences,
      progress: state.progress,
    );

    expect(find.byKey(const Key('sleep-primary-tonight')), findsOneWidget);
    expect(find.byKey(const Key('sleep-primary-continue')), findsNothing);
    expect(find.text('Popular'), findsNothing);
    for (final category in SleepCategory.values) {
      expect(
        find.byKey(Key('sleep-category-${category.name}')),
        findsOneWidget,
      );
    }
    expect(find.byKey(const Key('sleep-content-soft-rain')), findsNothing);
    expect(find.byKey(const Key('sleep-open-sound-library')), findsOneWidget);
  });

  testWidgets('valid progress replaces Tonight; unknown progress falls back', (
    tester,
  ) async {
    final state = await _testState();
    await state.progress.updatePosition(
      contentId: 'unknown-item',
      position: const Duration(minutes: 2),
      duration: const Duration(minutes: 20),
    );
    await _pumpSleep(
      tester,
      preferences: state.preferences,
      progress: state.progress,
    );
    expect(find.byKey(const Key('sleep-primary-tonight')), findsOneWidget);

    await state.progress.updatePosition(
      contentId: 'deep-drift',
      position: const Duration(minutes: 8),
      duration: const Duration(minutes: 30),
    );
    await _pumpSleep(
      tester,
      preferences: state.preferences,
      progress: state.progress,
    );
    expect(find.byKey(const Key('sleep-primary-continue')), findsOneWidget);
    expect(find.byKey(const Key('sleep-primary-tonight')), findsNothing);
    expect(find.byKey(const Key('sleep-continue-deep-drift')), findsOneWidget);
  });
}
