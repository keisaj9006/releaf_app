import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('GitHub Pages remains a manual Releaf web fallback', () {
    final workflow = File('.github/workflows/flutter_web_pages.yml');

    expect(
      workflow.existsSync(),
      isTrue,
      reason: 'Releaf keeps a manual GitHub Pages fallback for the public legal web bundle.',
    );

    final yaml = workflow.readAsStringSync();

    expect(yaml, contains('workflow_dispatch:'));
    expect(
      yaml,
      isNot(contains('\n  push:\n')),
      reason: 'AppDeploy is the primary live legal host; Pages must not create a failing deployment check on every branch push.',
    );
    expect(yaml, contains('subosito/flutter-action@v2'));
    expect(yaml, contains("flutter-version: '3.47.2'"));
    expect(yaml, contains('actions/configure-pages@v5'));
    expect(yaml, contains('flutter build web --release --base-href'));
    expect(yaml, contains('href="./#/account"'));
    expect(yaml, contains('build/web/delete-account.html'));
    expect(yaml, contains('build/web/privacy-policy.html'));
    expect(yaml, contains('tool/release/legal_metadata_policy.dart'));
    expect(yaml, contains('tool/release/render_privacy_policy.dart'));
    expect(yaml, contains('SUPABASE_SERVICE_ROLE_KEY'));
    expect(yaml, contains('actions/upload-pages-artifact@v4'));
    expect(yaml, contains('actions/deploy-pages@v4'));
    expect(yaml, contains('pages: write'));
    expect(yaml, contains('id-token: write'));
    expect(yaml, isNot(contains('SecondPart')));
  });
}
