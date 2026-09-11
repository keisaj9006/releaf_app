import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('device release QA matrix protects mandatory production checks', () {
    final qa = File('docs/release/android_device_release_qa.md');
    expect(qa.existsSync(), isTrue);

    final text = qa.readAsStringSync();

    for (final required in <String>[
      'Do not mark this gate DONE from unit/widget tests alone.',
      'DQA-02',
      'Cold start offline',
      'DQA-04',
      'Sleep background audio + timer',
      'DQA-08',
      'Brain / Labyrinth lifecycle + sensors',
      'DQA-11',
      'Password recovery deep link',
      'DQA-13',
      'Monthly purchase',
      'DQA-15',
      'Restore purchases',
      'DQA-16',
      'RevenueCat identity isolation',
      'DQA-17',
      'Emergency without Premium',
      'DQA-18',
      'In-app account deletion',
      'DQA-19',
      'External web account deletion',
      'DQA-20',
      'local-first',
      'Play-distributed test build',
      'FAIL',
      'BLOCKED',
    ]) {
      expect(text, contains(required), reason: 'Missing QA contract: $required');
    }
  });

  test('release gate keeps device QA open until physical run', () {
    final gate = File('docs/release/releaf_1_0_release_gate.md');
    expect(gate.existsSync(), isTrue);

    final text = gate.readAsStringSync();
    expect(
      text,
      contains(
        '| Device release QA | AUTOMATION READY / PHYSICAL DEVICE RUN REQUIRED |',
      ),
    );
    expect(text, contains('docs/release/android_device_release_qa.md'));
  });
}
