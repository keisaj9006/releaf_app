import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:releaf_app/core/providers.dart';
import 'package:releaf_app/features/sleep/application/sleep_progress_store.dart';
import 'package:releaf_app/features/sleep/data/sleep_catalog.dart';
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

  testWidgets('Sleep discovery exposes the frozen taxonomy and collections', (
    tester,
  ) async {
    final state = await _testState();
    await _pumpSleep(
      tester,
      preferences: state.preferences,
      progress: state.progress,
    );

    for (final label in const [
      'All',
      'Stories',
      'Nature',
      'Meditations',
      'Sleep Music',
    ]) {
      expect(find.text(label), findsWidgets);
    }
    expect(find.text('Tonight'), findsOneWidget);
    expect(find.text('Popular'), findsOneWidget);
    for (final collection in const [
      'Dream Classics',
      'Night Mysteries',
      'Fiction Escapes',
      'Wonder Journeys',
      'Drift Through History',
    ]) {
      expect(find.text(collection), findsOneWidget);
    }
    expect(find.byKey(const Key('sleep-open-sound-library')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('asset-pending Story is visible without a start action', (
    tester,
  ) async {
    final state = await _testState();
    await _pumpSleep(
      tester,
      preferences: state.preferences,
      progress: state.progress,
    );

    final card = find.byKey(const Key('sleep-content-ST-DC-004'));
    expect(card, findsOneWidget);
    expect(find.text('AUDIO IN PRODUCTION'), findsOneWidget);
    expect(
      find.descendant(
        of: card,
        matching: find.byIcon(Icons.play_arrow_rounded),
      ),
      findsNothing,
    );
  });

  testWidgets('each Story collection exposes its See all destination', (
    tester,
  ) async {
    final state = await _testState();
    await _pumpSleep(
      tester,
      preferences: state.preferences,
      progress: state.progress,
    );

    final seeAll = find.byKey(
      const Key('sleep-story-collection-dreamClassics-see-all'),
    );
    expect(seeAll, findsOneWidget);
    await tester.ensureVisible(seeAll);
    await tester.tap(seeAll);
    await tester.pumpAndSettle();

    expect(
      find.byKey(const Key('sleep-story-collection-dreamClassics-sheet')),
      findsOneWidget,
    );
    expect(find.text('Dream Classics'), findsWidgets);
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

    await tester.tap(find.byKey(const Key('sleep-filter-nature')));
    await tester.pumpAndSettle();

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

  testWidgets('Sleep keeps the separate owner preview behind its flag', (
    tester,
  ) async {
    final state = await _testState();
    await _pumpSleep(
      tester,
      preferences: state.preferences,
      progress: state.progress,
      storiesPreviewEnabled: true,
    );

    expect(find.byKey(const Key('sleep-stories-preview')), findsOneWidget);
    expect(find.text('OWNER PREVIEW'), findsOneWidget);
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
    expect(find.byKey(const Key('sleep-filter-all')), findsOneWidget);
    expect(find.byKey(const Key('sleep-open-sound-library')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
