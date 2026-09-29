import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:releaf_app/features/sleep/data/sleep_content_manifest.dart';

import '../tool/release/sleep_content_manifest_policy.dart';

void main() {
  test('Sleep intake reports pending assets without promoting them', () {
    final result = auditSleepContentManifest(
      root: Directory.current,
      entries: SleepContentManifest.candidates,
      promotedIds: SleepContentManifest.promotedIds,
    );

    debugPrint(
      'Sleep intake: ${SleepContentManifest.candidates.length} candidate(s), '
      '${SleepContentManifest.promotedIds.length} promoted, '
      '${result.candidateBytes} candidate bytes, '
      '${result.promotedBytes} promoted bytes.',
    );
    for (final issue in result.candidateIssues) {
      debugPrint('Pending/review: $issue');
    }
    expect(
      result.releaseErrors,
      isEmpty,
      reason: result.releaseErrors.join('\n'),
    );
  });
}
