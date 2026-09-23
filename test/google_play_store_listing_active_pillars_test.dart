import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

String _between(String source, String start, String end) {
  final startIndex = source.indexOf(start);
  final endIndex = source.indexOf(end);
  expect(startIndex, isNonNegative, reason: 'Missing marker $start');
  expect(endIndex, greaterThan(startIndex), reason: 'Missing marker $end');
  return source.substring(startIndex + start.length, endIndex).trim();
}

void main() {
  test('Google Play listing promotes only active Releaf 1.0 pillars', () {
    final source = File(
      'docs/release/google_play_store_listing.md',
    ).readAsStringSync().replaceAll('\r\n', '\n');
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

    expect(shortDescription, contains('Reset'));
    expect(shortDescription.toLowerCase(), contains('brain'));
    expect(shortDescription.toLowerCase(), contains('sleep'));
    expect(shortDescription.toLowerCase(), isNot(contains('meditat')));

    expect(fullDescription, contains('\nReset\n'));
    expect(fullDescription, contains('\nBrain\n'));
    expect(fullDescription, contains('\nSleep\n'));
    expect(fullDescription, contains('\nEmergency Calm\n'));
    expect(fullDescription, isNot(contains('\nMeditate\n')));
    expect(
      fullDescription.toLowerCase(),
      isNot(contains('meditation sessions')),
    );

    expect(source, isNot(contains('sleep, meditation/mindfulness')));
    expect(source, isNot(contains('**Meditate**')));
    expect(source, isNot(contains('Meditate with calm guidance and ambience')));
  });
}
