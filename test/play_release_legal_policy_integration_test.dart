import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Play release script delegates legal validation to shared policy', () {
    final script = File('tool/build_play_release.ps1').readAsStringSync();
    final policy = File('tool/release/legal_metadata_policy.dart');

    expect(policy.existsSync(), isTrue);
    expect(
      script,
      contains('dart run tool/release/legal_metadata_policy.dart'),
    );

    // The PowerShell entry point must not carry a weaker, duplicate legal
    // validator that can drift away from ReleafLegalConfig.
    expect(
      script,
      isNot(contains('RELEAF_PRIVACY_CONTACT_EMAIL must be a valid email address.')),
    );
    expect(
      script,
      isNot(contains('must be an absolute HTTPS URL.')),
    );
  });
}
