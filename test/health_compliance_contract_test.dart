import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('health release copy keeps the Google Play safety contract', () {
    final privacySource = File('lib/features/legal/privacy.dart');
    expect(privacySource.existsSync(), isTrue);

    final source = privacySource.readAsStringSync();
    expect(source, contains("title: 'Health & safety'"));
    expect(
      source,
      contains('Releaf is a wellness app, not a medical device.'),
    );
    expect(
      source,
      contains(
        'It does not diagnose, treat, cure, or prevent any medical condition.',
      ),
    );
    expect(
      source,
      contains(
        'For medical advice, diagnosis, or treatment, consult a qualified healthcare professional.',
      ),
    );
  });

  test('health declaration mapping remains explicit for Releaf 1.0', () {
    final declaration = File(
      'docs/release/google_play_health_declaration.md',
    );
    expect(declaration.existsSync(), isTrue);

    final markdown = declaration.readAsStringSync();
    expect(markdown, contains('Sleep Management'));
    expect(
      markdown,
      contains('Stress Management, Relaxation, Mental Acuity'),
    );
    expect(markdown, contains('Mental and Behavioral Health'));
    expect(markdown, contains('Emergency and First Aid'));
    expect(markdown, contains('Activity and Fitness'));
    expect(markdown, contains('Play Console submission required'));
  });
}
