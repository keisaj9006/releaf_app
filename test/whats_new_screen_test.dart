import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:releaf_app/core/providers.dart';
import 'package:releaf_app/core/subscription/revenuecat_service.dart';
import 'package:releaf_app/core/subscription/subscription_controller.dart';
import 'package:releaf_app/core/subscription/subscription_state.dart';
import 'package:releaf_app/features/home/home_screen.dart';
import 'package:releaf_app/features/sleep/application/sleep_progress_store.dart';
import 'package:releaf_app/features/relief/data/reset_catalog.dart';
import 'package:releaf_app/features/relief/presentation/relief_session_gate.dart';
import 'package:releaf_app/features/home/whats_new_content.dart';
import 'package:releaf_app/features/home/whats_new_screen.dart';
import 'package:releaf_app/features/home/whats_new_store.dart';
import 'package:releaf_app/routing/app_router.dart';
import 'package:releaf_app/routing/app_routes.dart';

class _FreeSubscriptionController extends SubscriptionController {
  _FreeSubscriptionController() : super(RevenueCatService()) {
    state = const SubscriptionState(isPremium: false);
  }
  @override
  Future<void> initAndRefresh() async {}
}

Future<void> _pumpRoute(
  WidgetTester tester, {
  required SharedPreferences preferences,
  String location = AppRoutes.home,
}) async {
  final router = createAppRouter(initialLocation: location);
  addTearDown(router.dispose);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(preferences),
        sleepProgressStoreProvider.overrideWith(
          (ref) => SleepProgressStore(preferences),
        ),
        subscriptionControllerProvider.overrideWith(
          (ref) => _FreeSubscriptionController(),
        ),
      ],
      child: MaterialApp.router(routerConfig: router),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
}

void main() {
  testWidgets('first Home entry shows release changes then persists Continue', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    await _pumpRoute(tester, preferences: preferences);
    expect(find.byType(WhatsNewScreen), findsOneWidget);
    expect(find.text(WhatsNewContent.current.heading), findsOneWidget);
    for (final item in WhatsNewContent.current.items) {
      expect(find.text(item.title), findsOneWidget);
    }
    expect(find.byKey(const Key('whats-new-emergency')), findsOneWidget);
    await tester.ensureVisible(find.byKey(const Key('whats-new-continue')));
    await tester.tap(find.byKey(const Key('whats-new-continue')));
    await tester.pumpAndSettle();
    expect(find.byType(WhatsNewScreen), findsNothing);
    expect(find.byType(HomeScreen), findsOneWidget);
    expect(
      preferences.getString(SharedPreferencesWhatsNewStore.storageKey),
      WhatsNewContent.current.releaseId,
    );
  });

  testWidgets('Emergency opens immediately without acknowledging release', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    await _pumpRoute(tester, preferences: preferences);
    await tester.tap(find.byKey(const Key('whats-new-emergency')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.byType(ReliefSessionGate), findsOneWidget);
    expect(
      preferences.getString(SharedPreferencesWhatsNewStore.storageKey),
      isNull,
    );
  });

  testWidgets('acknowledged release opens Home immediately', (tester) async {
    SharedPreferences.setMockInitialValues({
      SharedPreferencesWhatsNewStore.storageKey:
          WhatsNewContent.current.releaseId,
    });
    await _pumpRoute(
      tester,
      preferences: await SharedPreferences.getInstance(),
    );
    expect(find.byType(WhatsNewScreen), findsNothing);
    expect(find.byType(HomeScreen), findsOneWidget);
  });

  testWidgets('large text keeps Continue and Emergency reachable', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    await tester.binding.setSurfaceSize(const Size(320, 640));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await _pumpRoute(
      tester,
      preferences: await SharedPreferences.getInstance(),
    );
    await tester.ensureVisible(find.byKey(const Key('whats-new-continue')));
    expect(find.byKey(const Key('whats-new-emergency')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  for (final route in [
    AppRoutes.relief,
    AppRoutes.sleep,
    AppRoutes.brain,
    AppRoutes.account,
    AppRoutes.passwordReset,
    AppRoutes.reliefSessionFor(ResetCatalog.emergencySessionId),
    AppRoutes.sleepStoryPlayerFor('ST-DC-004'),
  ]) {
    testWidgets('direct $route bypasses What’s New', (tester) async {
      SharedPreferences.setMockInitialValues({});
      await _pumpRoute(
        tester,
        preferences: await SharedPreferences.getInstance(),
        location: route,
      );
      expect(find.byType(WhatsNewScreen), findsNothing);
      expect(tester.takeException(), isNull);
    });
  }
}
