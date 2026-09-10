import 'package:flutter_test/flutter_test.dart';

import '../tool/release/revenuecat_key_policy.dart';

void main() {
  group('production Google RevenueCat key policy', () {
    test('accepts only a plausible Google public SDK key shape', () {
      const valid = 'goog_abcdefghijklmnop';

      expect(productionGoogleRevenueCatKeyError(valid), isNull);
      expect(isProductionGoogleRevenueCatKey(valid), isTrue);
      expect(
        productionGoogleRevenueCatKeyError('  $valid  '),
        isNull,
      );
    });

    test('rejects missing, test-store, secret and Apple keys', () {
      final invalidKeys = <String>[
        '',
        '   ',
        'test_abcdefghijklmnop',
        'sk_abcdefghijklmnop',
        'appl_abcdefghijklmnop',
      ];

      for (final key in invalidKeys) {
        expect(
          productionGoogleRevenueCatKeyError(key),
          isNotNull,
          reason: 'Expected release key policy to reject: $key',
        );
        expect(isProductionGoogleRevenueCatKey(key), isFalse);
      }
    });

    test('rejects wrong platform prefix, internal whitespace and short keys', () {
      final invalidKeys = <String>[
        'rcb_abcdefghijklmnop',
        'goog_abc defghijklmnop',
        'goog_short',
      ];

      for (final key in invalidKeys) {
        expect(
          productionGoogleRevenueCatKeyError(key),
          isNotNull,
          reason: 'Expected release key policy to reject: $key',
        );
      }
    });

    test('returns actionable failure reasons for dangerous key classes', () {
      expect(
        productionGoogleRevenueCatKeyError('test_abcdefghijklmnop'),
        contains('Test Store'),
      );
      expect(
        productionGoogleRevenueCatKeyError('sk_abcdefghijklmnop'),
        contains('secret API keys'),
      );
      expect(
        productionGoogleRevenueCatKeyError('appl_abcdefghijklmnop'),
        contains('Apple'),
      );
      expect(
        productionGoogleRevenueCatKeyError('android_abcdefghijklmnop'),
        contains('goog_'),
      );
    });
  });
}
