import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

String _between(String source, String start, String end) {
  final startIndex = source.indexOf(start);
  final endIndex = source.indexOf(end);
  expect(startIndex, isNonNegative, reason: 'Missing marker $start');
  expect(endIndex, greaterThan(startIndex), reason: 'Missing marker $end');
  return source
      .substring(startIndex + start.length, endIndex)
      .trim();
}

void main() {
  test('Google Play listing copy stays inside metadata limits', () {
    final file = File('docs/release/google_play_store_listing.md');
    expect(file.existsSync(), isTrue);

    final source = file.readAsStringSync();
    final appName = _between(
      source,
      '<!-- APP_NAME_START -->',
      '<!-- APP_NAME_END -->',
    );
    final shortDescription = _between(
      source,
      '<!-- SHORT_DESCRIPTION_START -->',
      '<!-- SHORT_DESCRIPTION_END -->',
    );
    final fullDescription = _between(
      source,
      '<!-- FULL_DESCRIPTION_START -->',
      '<!-- FULL_DESCRIPTION_END -->',
    );

    expect(appName.length, lessThanOrEqualTo(30));
    expect(shortDescription.length, lessThanOrEqualTo(80));
    expect(fullDescription.length, lessThanOrEqualTo(4000));
    expect(appName, 'Releaf');
  });

  test('listing keeps release health and product truthfulness safeguards', () {
    final source = File(
      'docs/release/google_play_store_listing.md',
    ).readAsStringSync();
    final fullDescription = _between(
      source,
      '<!-- FULL_DESCRIPTION_START -->',
      '<!-- FULL_DESCRIPTION_END -->',
    );

    expect(
      fullDescription,
      contains('Releaf is a wellness app, not a medical device.'),
    );
    expect(
      fullDescription,
      contains('does not diagnose, treat, cure, or prevent any medical condition'),
    );
    expect(
      fullDescription,
      contains('consult a qualified healthcare professional'),
    );
    expect(fullDescription, contains('does not claim automatic cloud backup'));
    expect(fullDescription, contains('Sleep content does not use narration'));
    expect(
      fullDescription,
      contains('is not an emergency-response service'),
    );
  });
}
