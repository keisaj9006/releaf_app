import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('public Releaf web deployment keeps the release contract', () {
    final workflow = File('.github/workflows/flutter_web_pages.yml');

    expect(
      workflow.existsSync(),
      isTrue,
      reason: 'Releaf 1.0 requires a public HTTPS web deployment for the external account-deletion resource.',
    );

    final yaml = workflow.readAsStringSync();

    expect(yaml, contains('releaf-development'));
    expect(yaml, contains('subosito/flutter-action@v2'));
    expect(yaml, contains("flutter-version: '3.47.2'"));
    expect(yaml, contains('actions/configure-pages@v5'));
    expect(yaml, contains('flutter build web --release --base-href'));
    expect(yaml, contains('href="./#/account"'));
    expect(yaml, contains('build/web/delete-account.html'));
    expect(yaml, contains('SUPABASE_SERVICE_ROLE_KEY'));
    expect(yaml, contains('actions/upload-pages-artifact@v4'));
    expect(yaml, contains('actions/deploy-pages@v4'));
    expect(yaml, contains('pages: write'));
    expect(yaml, contains('id-token: write'));
    expect(yaml, isNot(contains('SecondPart')));
  });
}
