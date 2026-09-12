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

class _ReadingTextScaler extends TextScaler {
  const _ReadingTextScaler();
  @override
  double scale(double fontSize) => fontSize < 50 ? fontSize * 2 : fontSize;
  @override
  double get textScaleFactor => 2;
}

void main() {
  const destinations = [
    (AppRoutes.home, 'Home'),
    (AppRoutes.relief, 'Reset'),
    (AppRoutes.meditate, 'Meditate'),
    (AppRoutes.sleep, 'Sleep'),
    (AppRoutes.brain, 'Brain'),
  ];
  for (var index = 0; index < destinations.length; index++) {
    final target = destinations[index];
    testWidgets('${target.$2} deep link selects the approved primary tab', (
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
      if (index == 2 || index == 3) {
        expect(find.byTooltip('Open Emergency Calm'), findsOneWidget);
        expect(find.byTooltip('Account and Premium'), findsOneWidget);
      }
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    });
  }

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
        3,
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

  for (final scaler in [
    const TextScaler.linear(2),
    const _ReadingTextScaler(),
  ]) {
    testWidgets(
      'tab switching preserves Meditation scroll at 320px with $scaler',
      (tester) async {
        final originalError = FlutterError.onError;
        FlutterError.onError = (details) {
          FlutterError.dumpErrorToConsole(details);
          originalError?.call(details);
        };
        addTearDown(() => FlutterError.onError = originalError);
        await tester.binding.setSurfaceSize(const Size(320, 640));
        addTearDown(() => tester.binding.setSurfaceSize(null));
        SharedPreferences.setMockInitialValues({});
        final prefs = await SharedPreferences.getInstance();
        final router = createAppRouter(initialLocation: AppRoutes.meditate);
        addTearDown(router.dispose);
        await tester.pumpWidget(
          ProviderScope(
            overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
            child: MaterialApp.router(
              routerConfig: router,
              builder: (context, child) => MediaQuery(
                data: MediaQuery.of(context).copyWith(textScaler: scaler),
                child: child!,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        final scroll = tester.state<ScrollableState>(
          find
              .descendant(
                of: find.byType(MeditationScreen),
                matching: find.byType(Scrollable),
              )
              .first,
        );
        scroll.position.jumpTo(300);
        await tester.pump();
        for (final label in ['Sleep', 'Brain', 'Reset', 'Home', 'Meditate']) {
          await tester.tap(
            find.descendant(
              of: find.byType(NavigationBar),
              matching: find.text(label),
            ),
          );
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull, reason: label);
          if (label == 'Brain' || label == 'Reset') {
            final card = label == 'Reset'
                ? find.byKey(const Key('reset-sound-gateway'))
                : find
                      .byWidgetPredicate(
                        (widget) =>
                            widget.key is ValueKey<String> &&
                            (widget.key! as ValueKey<String>).value.startsWith(
                              'brain-game-card-',
                            ),
                      )
                      .first;
            final overlays = find.descendant(
              of: card,
              matching: find.byWidgetPredicate(
                (widget) =>
                    widget is DecoratedBox &&
                    widget.decoration is BoxDecoration &&
                    (widget.decoration as BoxDecoration).gradient != null,
              ),
            );
            expect(overlays, findsWidgets);
            for (final overlay in overlays.evaluate()) {
              expect(
                (overlay.renderObject! as RenderBox).size.height,
                greaterThan(0),
              );
            }
          }
        }
        final restored = tester.state<ScrollableState>(
          find
              .descendant(
                of: find.byType(MeditationScreen),
                matching: find.byType(Scrollable),
              )
              .first,
        );
        expect(identical(scroll, restored), isTrue);
        expect(restored.position.pixels, 300);
        await tester.pumpWidget(const SizedBox.shrink());
      },
    );
  }
}
