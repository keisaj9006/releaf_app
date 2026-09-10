import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('account deletion erases RevenueCat customer before Supabase user', () {
    final source = File(
      'supabase/functions/delete-account/index.ts',
    ).readAsStringSync();

    expect(source, contains('REVENUECAT_SECRET_API_KEY'));
    expect(
      source,
      contains('https://api.revenuecat.com/v1/subscribers/'),
    );
    expect(source, contains('method: "DELETE"'));
    expect(
      source,
      contains('response.status === 200 || response.status === 404'),
    );

    final revenueCatDelete = source.indexOf(
      'await deleteRevenueCatCustomer(user.id, revenueCatSecretApiKey)',
    );
    final supabaseDelete = source.indexOf(
      'adminClient.auth.admin.deleteUser(user.id)',
    );

    expect(revenueCatDelete, greaterThanOrEqualTo(0));
    expect(supabaseDelete, greaterThan(revenueCatDelete));

    // The server credential must only be referenced by environment-variable
    // name; no RevenueCat secret value belongs in source control.
    expect(source, isNot(contains('Bearer sk_')));
  });
}
