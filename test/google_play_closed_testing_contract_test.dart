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

  test('tester brief matches the active Reset Brain Sleep 1.0 surface', () {
    final plan = File('docs/release/google_play_closed_testing.md');
    expect(plan.existsSync(), isTrue);

    final text = plan.readAsStringSync();
    for (final activeTask in <String>[
      'RESET start, interruption/resume and completion',
      'BRAIN including at least one normal game and Labyrinth on a physical device',
      'Sleep sound playback, timer, lock/background/resume',
      'Premium paywall presentation',
      'Restore Purchases',
      'Emergency access without Premium',
    ]) {
      expect(text, contains(activeTask), reason: 'Missing active 1.0 tester task: $activeTask');
    }

    expect(
      text,
      isNot(contains('Meditation playback')),
      reason: 'Meditate is parked outside the active Releaf 1.0 testing/marketing surface.',
    );
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
