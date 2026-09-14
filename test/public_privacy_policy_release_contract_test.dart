import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('public Privacy Policy is generated fail-closed from release metadata', () {
    final renderer = File('tool/release/render_privacy_policy.dart');
    final workflow = File('.github/workflows/flutter_web_pages.yml');

    expect(
      renderer.existsSync(),
      isTrue,
      reason: 'The public Privacy Policy must be generated from approved release metadata, not committed with fake placeholders.',
    );
    expect(workflow.existsSync(), isTrue);

    final rendererSource = renderer.readAsStringSync();
    final workflowSource = workflow.readAsStringSync();

    for (final key in <String>[
      'RELEAF_DATA_CONTROLLER_NAME',
      'RELEAF_PRIVACY_CONTACT_EMAIL',
      'RELEAF_PRIVACY_POLICY_URL',
      'RELEAF_ACCOUNT_DELETION_URL',
      'RELEAF_PRIVACY_LAST_UPDATED',
    ]) {
      expect(rendererSource, contains(key));
      expect(workflowSource, contains(key));
    }

    expect(rendererSource, contains('Supabase'));
    expect(rendererSource, contains('RevenueCat'));
    expect(rendererSource, contains('Google Play'));
    expect(rendererSource, contains('lawful basis'));
    expect(rendererSource, contains('retention'));
    expect(rendererSource, contains('Information Commissioner'));
    expect(rendererSource, contains('accelerometer'));
    expect(rendererSource, contains('local'));
    expect(rendererSource, contains('Delete your account'));

    expect(workflowSource, contains('tool/release/legal_metadata_policy.dart'));
    expect(workflowSource, contains('tool/release/render_privacy_policy.dart'));
    expect(workflowSource, contains('build/web/privacy-policy.html'));
    expect(workflowSource, contains('build/web/delete-account.html'));
    expect(workflowSource, contains('actions/upload-pages-artifact@v4'));

    expect(rendererSource, isNot(contains('TBD')));
    expect(rendererSource, isNot(contains('TODO')));
    expect(rendererSource, isNot(contains('example@example.com')));
    expect(rendererSource, isNot(contains('SUPABASE_SERVICE_ROLE_KEY')));
    expect(rendererSource, isNot(contains('REVENUECAT_SECRET_API_KEY')));
  });
}
