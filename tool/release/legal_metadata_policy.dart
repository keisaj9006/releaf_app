import 'dart:io';

import 'package:releaf_app/core/legal/releaf_legal_config.dart';

void main() {
  final env = Platform.environment;
  final config = ReleafLegalConfig(
    dataControllerName: env['RELEAF_DATA_CONTROLLER_NAME'] ?? '',
    privacyContactEmail: env['RELEAF_PRIVACY_CONTACT_EMAIL'] ?? '',
    privacyPolicyUrl: env['RELEAF_PRIVACY_POLICY_URL'] ?? '',
    accountDeletionUrl: env['RELEAF_ACCOUNT_DELETION_URL'] ?? '',
    privacyLastUpdated: env['RELEAF_PRIVACY_LAST_UPDATED'] ?? '',
  );

  final problems = config.productionProblems;
  if (problems.isNotEmpty) {
    stderr.writeln(
      'Invalid Releaf production legal metadata: ${problems.join(', ')}.',
    );
    exitCode = 2;
    return;
  }

  stdout.writeln('Releaf production legal metadata is valid.');
}
