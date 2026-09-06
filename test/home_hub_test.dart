import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:releaf_app/core/providers.dart';
import 'package:releaf_app/features/home/daily_insight.dart';
import 'package:releaf_app/features/home/home_personalization.dart';
import 'package:releaf_app/features/home/home_screen.dart';
import 'package:releaf_app/routing/app_router.dart';
import 'package:releaf_app/routing/app_routes.dart';

Future<SharedPreferences> _preferences() async {
  SharedPreferences.setMockInitialValues({});
  return SharedPreferences.getInstance();
}

Future<void> _pumpHome(
  WidgetTester tester, {
  required SharedPreferences preferences,
}) async {
  final router = createAppRouter(initialLocation: AppRoutes.home);
  addTearDown(router.dispose);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(preferences),
        homeNowProvider.overrideWithValue(DateTime(2026, 9, 6, 12)),
      ],
      child: MaterialApp.router(routerConfig: router),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
}

void main() {
  test('Daily insight rotation is deterministic and source-backed', () {
    final day = DateTime(2026, 9, 6);
    final first = DailyInsightCatalog.forDate(day);
    final sameDay = DailyInsightCatalog.forDate(
      DateTime(2026, 9, 6, 23, 59),
    );
    final nextDay = DailyInsightCatalog.forDate(DateTime(2026, 9, 7));

    expect(DailyInsightCatalog.all, hasLength(20));
    expect(first.id, sameDay.id);
    expect(first.id, isNot(nextDay.id));
    expect(first.sourcePublisher, isNotEmpty);
    expect(first.sourceTitle, isNotEmpty);
    expect(first.sourceUrl, startsWith('https://'));
    expect(first.evidenceLabel, isNotEmpty);
    expect(first.evidenceNote, isNotEmpty);
  });


  testWidgets('Home renders the premium need-first hierarchy', (
    WidgetTester tester,
  ) async {
    await _pumpHome(tester, preferences: await _preferences());

    expect(find.text('RELEAF'), findsOneWidget);
    expect(find.text('RIGHT NOW'), findsOneWidget);
    expect(find.text('Calm down'), findsOneWidget);
    expect(find.text('Clear my head'), findsOneWidget);
    expect(find.text('Focus'), findsOneWidget);
    expect(find.text('Wind down'), findsWidgets);
    expect(find.byKey(const Key('home-recommendation-card')), findsOneWidget);
    expect(find.text('DAILY ESSENTIALS'), findsOneWidget);
    expect(find.text('Your daily rhythm'), findsOneWidget);
    expect(find.text('0 Leaves collected'), findsOneWidget);
    expect(find.text('0/2'), findsOneWidget);
    expect(find.text('Habit'), findsNothing);
  });

  testWidgets('Home shows Daily Insight with evidence details', (
    WidgetTester tester,
  ) async {
    final insight = DailyInsightCatalog.forDate(DateTime(2026, 9, 6));
    await _pumpHome(tester, preferences: await _preferences());

    expect(find.text('DAILY INSIGHT'), findsOneWidget);
    expect(find.byKey(const Key('home-daily-insight')), findsOneWidget);
    expect(find.text('NEW TODAY'), findsOneWidget);
    expect(find.text('Read why this matters'), findsOneWidget);
    expect(find.text(insight.headline), findsOneWidget);

    await tester.ensureVisible(find.byKey(const Key('home-daily-insight')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('home-daily-insight-info')));
    await tester.pumpAndSettle();

    expect(find.text('EVIDENCE'), findsOneWidget);
    expect(find.text(insight.evidenceLabel), findsWidgets);
    expect(find.text('SOURCE'), findsOneWidget);
    expect(find.text(insight.sourcePublisher), findsWidgets);
    expect(
      find.byKey(const Key('home-daily-insight-source')),
      findsOneWidget,
    );
  });

  testWidgets('Home first-use welcome is optional and persists dismissal', (
    WidgetTester tester,
  ) async {
    final preferences = await _preferences();
    await _pumpHome(tester, preferences: preferences);

    expect(find.byKey(const Key('home-welcome-card')), findsOneWidget);
    expect(find.text('WELCOME TO RELEAF'), findsOneWidget);

    await tester.tap(find.byKey(const Key('home-welcome-dismiss')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('home-welcome-card')), findsNothing);
    expect(preferences.getBool('releaf.home.intro.dismissed.v1'), isTrue);
  });

  testWidgets('Home recommendation reacts to the selected need', (
    WidgetTester tester,
  ) async {
    await _pumpHome(tester, preferences: await _preferences());

    await tester.ensureVisible(find.text('Calm down'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Calm down'));
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('SUGGESTED FOR CALM'), findsOneWidget);
    expect(find.text('Back to the Room'), findsOneWidget);
    expect(find.text('You chose calm down.'), findsOneWidget);

    await tester.ensureVisible(find.text('Focus'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Focus'));
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('SUGGESTED FOR FOCUS'), findsOneWidget);
    expect(find.text('Daily Brain Workout'), findsWidgets);
    expect(find.text('You chose focus.'), findsOneWidget);
  });

  testWidgets('Home focus persists and tunes default recommendations', (
    WidgetTester tester,
  ) async {
    final preferences = await _preferences();
    await _pumpHome(tester, preferences: preferences);

    expect(find.text('Personalize recommendations'), findsOneWidget);

    await tester.ensureVisible(find.byKey(const Key('home-focus-strip')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('home-focus-strip')));
    await tester.pumpAndSettle();

    expect(
      find.text('What should Releaf help you with most?'),
      findsOneWidget,
    );

    await tester.tap(find.byKey(const Key('home-focus-mindfulness')));
    await tester.pumpAndSettle();

    expect(find.text('Build mindfulness'), findsOneWidget);
    expect(find.text('SUGGESTED FOR YOUR FOCUS'), findsOneWidget);
    expect(find.text('Mindfulness Basics'), findsOneWidget);
    expect(
      preferences.getString('releaf.home.focus.v1'),
      HomeFocus.mindfulness.name,
    );
  });

  testWidgets('Home Continue surfaces the most recent accessible meditation', (
    WidgetTester tester,
  ) async {
    final preferences = await _preferences();
    await preferences.setBool('releaf.home.intro.dismissed.v1', true);
    await preferences.setStringList(
      'meditation.recent_ids',
      ['breath-and-body-4'],
    );

    await _pumpHome(tester, preferences: preferences);

    expect(find.text('CONTINUE'), findsOneWidget);
    expect(find.text('RECENT MEDITATION'), findsOneWidget);
    expect(find.text('Breath & Body'), findsOneWidget);
    expect(
      find.text('Return to a practice you used recently.'),
      findsOneWidget,
    );
  });

  testWidgets('Home mindfulness recommendation advances with meditation progress', (
    WidgetTester tester,
  ) async {
    final preferences = await _preferences();
    await preferences.setString('releaf.home.focus.v1', HomeFocus.mindfulness.name);
    await preferences.setStringList(
      'meditation.completed_ids',
      ['mindfulness-basics-2'],
    );

    await _pumpHome(tester, preferences: preferences);

    expect(find.text('SUGGESTED FOR YOUR FOCUS'), findsOneWidget);
    expect(find.text('Breath & Body'), findsOneWidget);
    expect(
      find.text('Matches your focus: Build mindfulness.'),
      findsOneWidget,
    );
  });

  testWidgets('Home remains overflow-free on a narrow phone', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(320, 640));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await _pumpHome(tester, preferences: await _preferences());

    expect(find.text('Calm down'), findsOneWidget);
    expect(find.byKey(const Key('home-recommendation-card')), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.ensureVisible(find.byKey(const Key('home-focus-strip')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('home-focus-strip')));
    await tester.pumpAndSettle();
    expect(find.text('What should Releaf help you with most?'), findsOneWidget);
    expect(tester.takeException(), isNull);

    Navigator.of(tester.element(find.text('YOUR FOCUS').last)).pop();
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Your daily rhythm'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
