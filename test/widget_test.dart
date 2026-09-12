import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:releaf_app/core/providers.dart';
import 'package:releaf_app/core/subscription/revenuecat_service.dart';
import 'package:releaf_app/main.dart';

void main() {
  test(
    'RevenueCat accepts missing configuration without initialization',
    () async {
      final service = RevenueCatService();

      await service.init(apiKey: '', debug: false);

      expect(service.isInitialized, isFalse);
      expect(await service.getCustomerInfoSafe(), isNull);
      expect(await service.getOfferingsSafe(), isNull);
    },
  );

  test('RevenueCat recognizes a supplied public Test Store SDK key', () {
    expect(RevenueCatService.hasConfiguredApiKey(''), isFalse);
    expect(
      RevenueCatService.hasConfiguredApiKey('REVENUECAT_ANDROID_API_KEY'),
      isFalse,
    );
    expect(
      RevenueCatService.hasConfiguredApiKey(' test_abcdefghijklmnop '),
      isTrue,
    );
  });

  test('RevenueCat runtime accepts only supported public SDK key shapes', () {
    for (final prefix in ['test_', 'goog_', 'appl_']) {
      expect(
        RevenueCatService.hasConfiguredApiKey(' ${prefix}abcdefghijklmnop '),
        isTrue,
      );
    }
    for (final invalid in [
      'sk_abcdefghijklmnop',
      'arbitrary_configuration',
      'test_',
      'goog_short',
      'appl_abc defghijklmnop',
      'test_abcdefghijklmnop\nextra',
    ]) {
      expect(RevenueCatService.hasConfiguredApiKey(invalid), isFalse);
    }
  });

  testWidgets('App boots with required provider overrides', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
        child: const ReleafApp(),
      ),
    );
    await tester.pump();

    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.text('RELEAF'), findsOneWidget);
    expect(find.text('RIGHT NOW'), findsOneWidget);
  });
}
