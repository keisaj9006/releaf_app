import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('public account deletion web resource keeps the release contract', () {
    final resource = File('web/delete-account.html');

    expect(
      resource.existsSync(),
      isTrue,
      reason: 'Google Play requires an external account-deletion web resource.',
    );

    final html = resource.readAsStringSync();

    expect(html, contains('Delete your Releaf account'));
    expect(html, contains('You do not need the Android app installed.'));
    expect(html, contains('href="/#/account"'));
    expect(html, contains('Delete account'));
    expect(html, contains('Delete permanently'));
    expect(html, contains('Forgot password?'));

    expect(
      html,
      isNot(contains('SUPABASE_SERVICE_ROLE_KEY')),
      reason: 'The public deletion page must never expose server credentials.',
    );
  });
}
