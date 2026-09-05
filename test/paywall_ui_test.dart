import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:releaf_app/core/providers.dart';
import 'package:releaf_app/core/paywall/presentation/paywall_sheet.dart';
import 'package:releaf_app/core/subscription/revenuecat_service.dart';
import 'package:releaf_app/core/subscription/subscription_controller.dart';
import 'package:releaf_app/core/subscription/subscription_state.dart';

class _FixedSubscriptionController extends SubscriptionController {
  _FixedSubscriptionController({required bool isPremium})
      : super(RevenueCatService()) {
    state = SubscriptionState(isPremium: isPremium);
  }

  @override
  Future<void> initAndRefresh() async {}

  @override
  Future<void> refresh() async {}
}

Future<void> _pumpPaywall(
  WidgetTester tester, {
  required bool isPremium,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        subscriptionControllerProvider.overrideWith(
          (ref) => _FixedSubscriptionController(isPremium: isPremium),
        ),
      ],
      child: const MaterialApp(
        home: Scaffold(
          backgroundColor: Color(0xFF09100D),
          body: PaywallSheet(),
        ),
      ),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
}

void main() {
  testWidgets('Premium paywall uses the Releaf product hierarchy', (
    WidgetTester tester,
  ) async {
    await _pumpPaywall(tester, isPremium: false);

    expect(find.text('RELEAF PREMIUM'), findsOneWidget);
    expect(find.text('Unlock Premium'), findsOneWidget);
    expect(find.text('Deeper Reset protocols'), findsOneWidget);
    expect(find.text('Premium meditation sessions'), findsOneWidget);
    expect(
      find.byKey(const Key('premium-packages-unavailable')),
      findsOneWidget,
    );
    expect(find.text('Restore purchases'), findsOneWidget);
  });

  testWidgets('Premium paywall stays usable at 320px', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(320, 640));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await _pumpPaywall(tester, isPremium: false);

    expect(find.text('Unlock Premium'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.ensureVisible(
      find.byKey(const Key('premium-packages-unavailable')),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('Premium paywall reflects active entitlement', (
    WidgetTester tester,
  ) async {
    await _pumpPaywall(tester, isPremium: true);

    expect(find.byKey(const Key('premium-active-card')), findsOneWidget);
    expect(find.text('Premium is active on this device.'), findsOneWidget);
    expect(find.text('Restore purchases'), findsNothing);
  });
}
