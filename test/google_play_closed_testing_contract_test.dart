import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('closed testing plan preserves conditional Play eligibility rule', () {
    final plan = File('docs/release/google_play_closed_testing.md');
    expect(plan.existsSync(), isTrue);

    final text = plan.readAsStringSync();
    for (final required in <String>[
      'personal developer accounts created after 13 November 2023',
      'at least 12 testers',
      'at least 14 days',
      'Do not assume this applies to Releaf',
      'production upload keystore',
      'RevenueCat',
      'Play licence testers',
      'Restore Purchases',
      'Emergency access without Premium',
      'android_device_release_qa.md',
      'Do not fabricate tester engagement or feedback.',
      'Production access has been granted',
    ]) {
      expect(text, contains(required), reason: 'Missing closed-test contract: $required');
    }
  });

  test('release gate does not claim closed testing is complete', () {
    final gate = File('docs/release/releaf_1_0_release_gate.md');
    expect(gate.existsSync(), isTrue);
    final text = gate.readAsStringSync();

    expect(
      text,
      contains(
        '| Play closed testing | PLAN READY / ACCOUNT CHECK + PLAY RUN REQUIRED |',
      ),
    );
    expect(text, contains('docs/release/google_play_closed_testing.md'));
    expect(
      text,
      isNot(contains('| Play closed testing | DONE |')),
    );
  });
}
