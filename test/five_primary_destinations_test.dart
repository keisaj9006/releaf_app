import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:releaf_app/core/providers.dart';
import 'package:releaf_app/routing/app_router.dart';
import 'package:releaf_app/routing/app_routes.dart';
import 'package:releaf_app/features/meditation/presentation/meditation_screen.dart';
import 'package:releaf_app/features/relief/presentation/breathing_widget.dart';
import 'package:releaf_app/features/account/presentation/account_screen.dart';

void main() {
  const destinations = [
    (AppRoutes.home, 'Home'),
    (AppRoutes.relief, 'Reset'),
    (AppRoutes.sleep, 'Sleep'),
    (AppRoutes.brain, 'Brain'),
  ];

  for (var index = 0; index < destinations.length; index++) {
    final target = destinations[index];
    testWidgets('${target.$2} deep link selects the active primary tab', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final router = createAppRouter(initialLocation: target.$1);
      addTearDown(router.dispose);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
          child: MaterialApp.router(routerConfig: router),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      final nav = tester.widget<NavigationBar>(find.byType(NavigationBar));
      expect(
        nav.destinations.whereType<NavigationDestination>().map(
          (item) => item.label,
        ),
        destinations.map((item) => item.$2),
      );
      expect(nav.selectedIndex, index);
      if (target.$1 == AppRoutes.sleep) {
        expect(find.byTooltip('Open Emergency Calm'), findsOneWidget);
        expect(find.byTooltip('Account and Premium'), findsOneWidget);
      }
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    });
  }

  testWidgets('Meditate remains parked and accessible only by direct route', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final router = createAppRouter(initialLocation: AppRoutes.meditate);
    addTearDown(router.dispose);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(MeditationScreen), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);
    expect(find.text('Meditate'), findsNothing);
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets(
    'Sleep restores its library and reselecting Sleep opens the root',
    (tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final router = createAppRouter(initialLocation: AppRoutes.sleep);
      addTearDown(router.dispose);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
          child: MaterialApp.router(routerConfig: router),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('sleep-open-sound-library')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('sound-open-meditate')), findsOneWidget);
      for (final label in ['Brain', 'Sleep']) {
        await tester.tap(
          find.descendant(
            of: find.byType(NavigationBar),
            matching: find.text(label),
          ),
        );
        await tester.pumpAndSettle();
      }
      expect(find.byKey(const Key('sound-open-meditate')), findsOneWidget);
      expect(
        tester.widget<NavigationBar>(find.byType(NavigationBar)).selectedIndex,
        2,
      );
      await tester.tap(
        find.descendant(
          of: find.byType(NavigationBar),
          matching: find.text('Sleep'),
        ),
      );
      await tester.pumpAndSettle();
      expect(router.routeInformationProvider.value.uri.path, AppRoutes.sleep);
      expect(find.byKey(const Key('sleep-open-sound-library')), findsOneWidget);
      await tester.tap(find.byTooltip('Open Emergency Calm'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byTooltip('Open Emergency Calm'), findsNothing);
      expect(find.byType(BreathingWidget), findsOneWidget);
      expect(find.text('Unlock Premium'), findsNothing);
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Account and Premium'));
      await tester.pumpAndSettle();
      expect(find.byType(NavigationBar), findsNothing);
      expect(find.byType(AccountScreen), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  testWidgets('four active destinations remain stable at large text', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(320, 640));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final router = createAppRouter(initialLocation: AppRoutes.home);
    addTearDown(router.dispose);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
        child: MaterialApp.router(
          routerConfig: router,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: const TextScaler.linear(2)),
            child: child!,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    for (final label in ['Reset', 'Sleep', 'Brain', 'Home']) {
      await tester.tap(
        find.descendant(
          of: find.byType(NavigationBar),
          matching: find.text(label),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: label);
    }

    expect(find.text('Meditate'), findsNothing);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
