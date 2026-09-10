import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:releaf_app/core/legal/releaf_legal_config.dart';
import 'package:releaf_app/features/legal/privacy.dart';

void main() {
  test('legal config requires complete production HTTPS metadata', () {
    const incomplete = ReleafLegalConfig(
      dataControllerName: '',
      privacyContactEmail: 'not-an-email',
      privacyPolicyUrl: 'http://example.com/privacy',
      accountDeletionUrl: '',
      privacyLastUpdated: '',
    );

    expect(incomplete.isProductionReady, isFalse);
    expect(incomplete.missingProductionFields, hasLength(5));

    const ready = ReleafLegalConfig(
      dataControllerName: 'Releaf Example Ltd',
      privacyContactEmail: 'privacy@example.com',
      privacyPolicyUrl: 'https://example.com/privacy',
      accountDeletionUrl: 'https://example.com/delete-account',
      privacyLastUpdated: '9 September 2026',
    );

    expect(ready.isProductionReady, isTrue);
    expect(ready.missingProductionFields, isEmpty);
    expect(ready.privacyPolicyUri?.scheme, 'https');
    expect(ready.accountDeletionUri?.scheme, 'https');
  });

  testWidgets('development build clearly blocks missing legal metadata', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: PrivacyScreen()),
    );

    await tester.scrollUntilVisible(
      find.byKey(const Key('privacy-development-legal-warning')),
      300,
      scrollable: find.byType(Scrollable).first,
    );

    expect(
      find.byKey(const Key('privacy-development-legal-warning')),
      findsOneWidget,
    );
    expect(find.byKey(const Key('privacy-open-policy')), findsNothing);
    expect(find.byKey(const Key('privacy-open-deletion')), findsNothing);
    expect(tester.takeException(), isNull);
  });

  test('privacy disclosure stays aligned with the Data Safety release mapping', () {
    final privacySource = File(
      'lib/features/legal/privacy.dart',
    ).readAsStringSync();

    expect(privacySource, contains('purchase history'));
    expect(privacySource, contains('Releaf account identifier'));
    expect(privacySource, contains('device accelerometer'));
    expect(
      privacySource,
      contains('not sent to the Releaf backend or RevenueCat'),
    );
    expect(privacySource, contains('encrypted HTTPS connections'));
    expect(privacySource, contains('matching RevenueCat customer'));
  });
}
