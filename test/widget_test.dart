import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:releaf_app/core/providers.dart';
import 'package:releaf_app/core/subscription/revenuecat_service.dart';
import 'package:releaf_app/main.dart';

void main() {
  test('RevenueCat accepts missing configuration without initialization', () async {
    final service = RevenueCatService();

    await service.init(apiKey: '', debug: false);

    expect(service.isInitialized, isFalse);
    expect(await service.getCustomerInfoSafe(), isNull);
    expect(await service.getOfferingsSafe(), isNull);
  });

  testWidgets('App boots with required provider overrides', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
        child: const ReleafApp(),
      ),
    );
    await tester.pump();

    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.text('Bring Releaf to your life.'), findsOneWidget);
  });
}
