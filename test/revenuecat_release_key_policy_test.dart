import 'package:flutter_test/flutter_test.dart';

import '../tool/release/revenuecat_key_policy.dart';

void main() {
  test('Play release accepts only a Google RevenueCat public SDK key', () {
    expect(
      isProductionGoogleRevenueCatKey('goog_1234567890abcdef'),
      isTrue,
    );

    expect(isProductionGoogleRevenueCatKey(''), isFalse);
    expect(
      isProductionGoogleRevenueCatKey('test_1234567890abcdef'),
      isFalse,
    );
    expect(
      isProductionGoogleRevenueCatKey('sk_1234567890abcdef'),
      isFalse,
    );
    expect(
      isProductionGoogleRevenueCatKey('appl_1234567890abcdef'),
      isFalse,
    );
    expect(
      isProductionGoogleRevenueCatKey('REVENUECAT_ANDROID_API_KEY'),
      isFalse,
    );
  });

  test('key validation explains dangerous production key types', () {
    expect(
      productionGoogleRevenueCatKeyError('test_abc'),
      contains('Test Store'),
    );
    expect(
      productionGoogleRevenueCatKeyError('sk_abc'),
      contains('secret'),
    );
    expect(
      productionGoogleRevenueCatKeyError('appl_abc'),
      contains('Apple'),
    );
    expect(
      productionGoogleRevenueCatKeyError('other_abc'),
      contains('goog_'),
    );
  });

  test('Google key validation normalizes harmless outer whitespace', () {
    expect(
      isProductionGoogleRevenueCatKey('  goog_1234567890abcdef  '),
      isTrue,
    );
  });
}
