import 'package:flutter_test/flutter_test.dart';
import 'package:releaf_app/core/legal/releaf_legal_config.dart';

void main() {
  const valid = ReleafLegalConfig(
    dataControllerName: 'Releaf Wellness Ltd',
    privacyContactEmail: 'privacy@releafwellness.co.uk',
    privacyPolicyUrl: 'https://releafwellness.co.uk/privacy',
    accountDeletionUrl: 'https://releafwellness.co.uk/delete-account',
    privacyLastUpdated: '2026-09-13',
  );

  test('accepts complete public production legal metadata', () {
    expect(valid.productionProblems, isEmpty);
    expect(valid.isProductionReady, isTrue);
  });

  test('rejects placeholder legal identity and example contact email', () {
    const config = ReleafLegalConfig(
      dataControllerName: 'TODO',
      privacyContactEmail: 'privacy@example.com',
      privacyPolicyUrl: 'https://releafwellness.co.uk/privacy',
      accountDeletionUrl: 'https://releafwellness.co.uk/delete-account',
      privacyLastUpdated: '2026-09-13',
    );

    expect(config.productionProblems, contains('data controller name'));
    expect(config.productionProblems, contains('privacy contact email'));
    expect(config.isProductionReady, isFalse);
  });

  test('rejects example and local HTTPS URLs', () {
    const config = ReleafLegalConfig(
      dataControllerName: 'Releaf Wellness Ltd',
      privacyContactEmail: 'privacy@releafwellness.co.uk',
      privacyPolicyUrl: 'https://example.com/privacy',
      accountDeletionUrl: 'https://localhost/delete-account',
      privacyLastUpdated: '2026-09-13',
    );

    expect(config.productionProblems, contains('public HTTPS privacy policy URL'));
    expect(config.productionProblems, contains('public HTTPS account deletion URL'));
    expect(config.isProductionReady, isFalse);
  });

  test('rejects malformed privacy last-updated date', () {
    const config = ReleafLegalConfig(
      dataControllerName: 'Releaf Wellness Ltd',
      privacyContactEmail: 'privacy@releafwellness.co.uk',
      privacyPolicyUrl: 'https://releafwellness.co.uk/privacy',
      accountDeletionUrl: 'https://releafwellness.co.uk/delete-account',
      privacyLastUpdated: 'September 2026',
    );

    expect(config.productionProblems, contains('privacy last-updated date (YYYY-MM-DD)'));
    expect(config.isProductionReady, isFalse);
  });
}
