import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:releaf_app/core/providers.dart';
import 'package:releaf_app/core/subscription/revenuecat_service.dart';
import 'package:releaf_app/core/subscription/subscription_controller.dart';
import 'package:releaf_app/core/subscription/subscription_state.dart';
import 'package:releaf_app/features/home/daily_insight.dart';
import 'package:releaf_app/features/home/home_personalization.dart';
import 'package:releaf_app/features/home/home_screen.dart';
import 'package:releaf_app/features/progress/data/leaves_repository.dart';
import 'package:releaf_app/routing/app_router.dart';
import 'package:releaf_app/routing/app_routes.dart';

Future<SharedPreferences> _preferences() async {
  SharedPreferences.setMockInitialValues({});
  return SharedPreferences.getInstance();
}

Future<void> _pumpHome(
  WidgetTester tester, {
  required SharedPreferences preferences,
  int hour = 12,
  bool premium = false,
  DateTime Function()? clock,
  String Function()? day,
}) async {
  final router = createAppRouter(initialLocation: AppRoutes.home);
  addTearDown(router.dispose);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(preferences),
        if (day != null) todayProvider.overrideWith((ref) => day()),
        homeNowProvider.overrideWith(
          (ref) => clock?.call() ?? DateTime(2026, 9, 6, hour),
        ),
        if (premium)
          subscriptionControllerProvider.overrideWith(
            (ref) => _PremiumSubscription(),
          ),
      ],
      child: MaterialApp.router(routerConfig: router),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
}

class _PremiumSubscription extends SubscriptionController {
  _PremiumSubscription() : super(RevenueCatService()) {
    state = const SubscriptionState(isPremium: true);
  }
  @override
  Future<void> initAndRefresh() async {}
}

void main() {
  testWidgets(
    'Home refreshes daily flags after midnight without losing Leaves',
    (tester) async {
      final preferences = await _preferences();
      await preferences.setString('todayKey', '2026-09-03');
      await preferences.setInt('totalLeaves', 6);
      for (final key in ['reliefDone', 'habitDone', 'brainDone']) {
        await preferences.setBool(key, true);
      }
      var day = '2026-09-03';
      await _pumpHome(tester, preferences: preferences, day: () => day);
      final container = ProviderScope.containerOf(
        tester.element(find.byType(HomeScreen)),
      );
      expect(container.read(leavesNotifierProvider).reliefDone, isTrue);
      day = '2026-09-04';
      await tester.pump(const Duration(minutes: 1));
      await tester.pump();
      final state = container.read(leavesNotifierProvider);
      expect(state.todayKey, day);
      expect(state.totalLeaves, 6);
      expect(state.reliefDone, isFalse);
      expect(state.brainDone, isFalse);
      expect(state.habitDone, isFalse);
      expect(preferences.getInt('totalLeaves'), 6);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  testWidgets(
    'Home first frame does not restart the clock while backgrounded',
    (tester) async {
      var reads = 0;
      tester.binding.addPostFrameCallback((_) {
        tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      });
      await _pumpHome(
        tester,
        preferences: await _preferences(),
        clock: () {
          reads++;
          return DateTime(2026, 9, 6, 12);
        },
      );
      final container = ProviderScope.containerOf(
        tester.element(find.byType(HomeScreen)),
      );
      container.read(homeNowProvider);
      final before = reads;
      await tester.pump(const Duration(minutes: 1));
      container.read(homeNowProvider);
      expect(reads, before);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pump();
      expect(reads, greaterThan(before));
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  for (final resumed in [false, true]) {
    testWidgets(
      'Home refreshes time-dependent content after ${resumed ? 'resume' : 'a minute'}',
      (tester) async {
        var now = DateTime(2026, 9, 6, 12);
        await _pumpHome(
          tester,
          preferences: await _preferences(),
          clock: () => now,
        );
        expect(find.text('Good afternoon'), findsOneWidget);
        if (resumed) {
          tester.binding.handleAppLifecycleStateChanged(
            AppLifecycleState.paused,
          );
          await tester.pump();
        }
        now = DateTime(2026, 9, 6, 21);
        if (resumed) {
          tester.binding.handleAppLifecycleStateChanged(
            AppLifecycleState.resumed,
          );
          await tester.pump();
        } else {
          await tester.pump(const Duration(minutes: 1));
        }
        await tester.pump();
        expect(find.text('Good evening'), findsOneWidget);
        expect(find.text('Let the Day Go'), findsOneWidget);
        await tester.pumpWidget(const SizedBox.shrink());
      },
    );
  }

  for (final hour in [18, 21]) {
    testWidgets(
      'Home describes the actual sound-first Sleep destination at $hour',
      (tester) async {
        final preferences = await _preferences();
        await preferences.setBool('releaf.home.intro.dismissed.v1', true);
        await preferences.setString(
          'releaf.home.focus.v1',
          HomeFocus.sleep.name,
        );
        await _pumpHome(
          tester,
          preferences: preferences,
          hour: hour,
          premium: true,
        );
        expect(find.text('Sleep • Sound • Timer'), findsOneWidget);
        expect(find.textContaining('guided wind-down'), findsNothing);
        expect(find.textContaining('8 min protocol'), findsNothing);
        expect(find.text('Sleep • Guided • Sound'), findsNothing);
        await tester.pumpWidget(const SizedBox.shrink());
      },
    );
  }

  test('Daily insight rotation is deterministic and source-backed', () {
    final day = DateTime(2026, 9, 6);
    final first = DailyInsightCatalog.forDate(day);
    final sameDay = DailyInsightCatalog.forDate(DateTime(2026, 9, 6, 23, 59));
    final nextDay = DailyInsightCatalog.forDate(DateTime(2026, 9, 7));

    expect(DailyInsightCatalog.all, hasLength(30));
    expect(
      DailyInsightCatalog.all.map((insight) => insight.id).toSet(),
      hasLength(30),
    );
    expect(first.id, sameDay.id);
    expect(first.id, isNot(nextDay.id));

    for (final insight in DailyInsightCatalog.all) {
      expect(insight.sourcePublisher, isNotEmpty, reason: insight.id);
      expect(insight.sourceTitle, isNotEmpty, reason: insight.id);
      expect(insight.sourceUrl, startsWith('https://'), reason: insight.id);
      expect(insight.evidenceLabel, isNotEmpty, reason: insight.id);
      expect(insight.evidenceNote, isNotEmpty, reason: insight.id);
      expect(insight.teaser, isNotEmpty, reason: insight.id);
      expect(insight.teaser, isNot(insight.headline), reason: insight.id);
    }
  });

  test(
    'Daily insight rotation avoids repeating a category on consecutive days',
    () {
      final anchor = DateTime.utc(2026, 1, 1);
      final cycle = List<DailyInsight>.generate(
        DailyInsightCatalog.all.length,
        (index) =>
            DailyInsightCatalog.forDate(anchor.add(Duration(days: index))),
      );

      expect(
        cycle.map((insight) => insight.id).toSet(),
        DailyInsightCatalog.all.map((insight) => insight.id).toSet(),
      );

      for (var index = 1; index < cycle.length; index++) {
        expect(
          cycle[index].category,
          isNot(cycle[index - 1].category),
          reason: '${cycle[index - 1].id} -> ${cycle[index].id}',
        );
      }

      expect(
        cycle.first.category,
        isNot(cycle.last.category),
        reason: 'rotation wrap-around must also change category',
      );
    },
  );

  testWidgets('Home renders the premium need-first hierarchy', (
    WidgetTester tester,
  ) async {
    await _pumpHome(tester, preferences: await _preferences());

    expect(find.text('RELEAF'), findsOneWidget);
    expect(find.byKey(const Key('home-emergency-action')), findsOneWidget);
    expect(find.byKey(const Key('home-account-button')), findsOneWidget);
    expect(find.byType(FloatingActionButton), findsNothing);
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
    expect(find.text('DID YOU KNOW?'), findsOneWidget);
    expect(find.text('Reveal today’s insight'), findsOneWidget);
    expect(find.text(insight.teaser), findsOneWidget);
    expect(find.text(insight.headline), findsNothing);

    await tester.ensureVisible(find.byKey(const Key('home-daily-insight')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('home-daily-insight-info')));
    await tester.pumpAndSettle();

    expect(find.text(insight.headline), findsOneWidget);
    expect(find.text('EVIDENCE'), findsOneWidget);
    expect(find.text(insight.evidenceLabel), findsWidgets);
    expect(find.text('SOURCE'), findsOneWidget);
    expect(find.text(insight.sourcePublisher), findsWidgets);
    expect(find.byKey(const Key('home-daily-insight-source')), findsOneWidget);
  });

  testWidgets(
    'Daily Insight browses the whole collection and keeps today fixed',
    (tester) async {
      final today = DailyInsightCatalog.forDate(DateTime(2026, 9, 6));
      final entries = DailyInsightCatalog.all;
      final initial = entries.indexWhere((entry) => entry.id == today.id);
      await _pumpHome(tester, preferences: await _preferences());
      await tester.ensureVisible(find.byKey(const Key('home-daily-insight')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('home-daily-insight-info')));
      await tester.pumpAndSettle();
      for (var offset = 0; offset < entries.length; offset++) {
        final index = (initial + offset) % entries.length;
        expect(find.text(entries[index].headline), findsOneWidget);
        expect(find.text(entries[index].sourceTitle), findsOneWidget);
        expect(find.text('${index + 1} of ${entries.length}'), findsOneWidget);
        await tester.tap(find.byKey(const Key('home-daily-insight-next')));
        await tester.pumpAndSettle();
      }
      expect(find.text(today.headline), findsOneWidget);
      await tester.tap(find.byKey(const Key('home-daily-insight-previous')));
      await tester.pumpAndSettle();
      expect(
        find.text(
          entries[(initial - 1 + entries.length) % entries.length].headline,
        ),
        findsOneWidget,
      );
      await tester.tap(find.byTooltip('Close'));
      await tester.pumpAndSettle();
      expect(find.text(today.teaser), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('Daily Insight browsing fits a narrow screen with large text', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 720);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    tester.platformDispatcher.textScaleFactorTestValue = 1.8;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await _pumpHome(tester, preferences: await _preferences());
    await tester.ensureVisible(find.byKey(const Key('home-daily-insight')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('home-daily-insight-info')));
    await tester.pumpAndSettle();
    expect(find.byTooltip('Next insight'), findsOneWidget);
    await tester.tap(find.byKey(const Key('home-daily-insight-next')));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
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

    expect(find.text('What should Releaf help you with most?'), findsOneWidget);

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
    await preferences.setStringList('meditation.recent_ids', [
      'breath-and-body-4',
    ]);

    await _pumpHome(tester, preferences: preferences);

    expect(find.text('CONTINUE'), findsOneWidget);
    expect(find.text('RECENT MEDITATION'), findsOneWidget);
    expect(find.text('Breath & Body'), findsOneWidget);
    expect(
      find.text('Return to a practice you used recently.'),
      findsOneWidget,
    );
  });

  testWidgets('Home restores a persisted paused meditation after restart', (
    WidgetTester tester,
  ) async {
    final preferences = await _preferences();
    await preferences.setBool('releaf.home.intro.dismissed.v1', true);
    await preferences.setBool('session.active.v1', true);
    await preferences.setString('session.title.v1', 'Breath & Body');
    await preferences.setString(
      'session.subtitle.v1',
      'Meditation · 3 min remaining',
    );
    await preferences.setString(
      'session.resume_route.v1',
      AppRoutes.meditationSessionFor('breath-and-body-4'),
    );
    await preferences.setString(
      'session.extra_json.v1',
      '{"type":"meditation","remainingSeconds":180}',
    );

    await _pumpHome(tester, preferences: preferences);

    expect(find.text('PAUSED SESSION'), findsOneWidget);
    expect(find.text('Breath & Body'), findsOneWidget);
    expect(find.text('Meditation · 3 min remaining'), findsOneWidget);
  });

  testWidgets(
    'Home mindfulness recommendation advances with meditation progress',
    (WidgetTester tester) async {
      final preferences = await _preferences();
      await preferences.setString(
        'releaf.home.focus.v1',
        HomeFocus.mindfulness.name,
      );
      await preferences.setStringList('meditation.completed_ids', [
        'mindfulness-basics-2',
      ]);

      await _pumpHome(tester, preferences: preferences);

      expect(find.text('SUGGESTED FOR YOUR FOCUS'), findsOneWidget);
      expect(find.text('Breath & Body'), findsOneWidget);
      expect(
        find.text('Matches your focus: Build mindfulness.'),
        findsOneWidget,
      );
    },
  );

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
