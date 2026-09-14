import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('production Android release workflow keeps signing and billing secrets private', () {
    final workflow = File('.github/workflows/android_production_release.yml');

    expect(
      workflow.existsSync(),
      isTrue,
      reason: 'Releaf 1.0 needs a manual production AAB workflow backed by the private upload key.',
    );

    final yaml = workflow.readAsStringSync();

    expect(yaml, contains('workflow_dispatch'));
    expect(yaml, isNot(contains('branches:')));
    expect(yaml, contains("flutter-version: '3.47.2'"));
    expect(yaml, contains('ANDROID_UPLOAD_KEYSTORE_BASE64'));
    expect(yaml, contains('ANDROID_UPLOAD_STORE_PASSWORD'));
    expect(yaml, contains('ANDROID_UPLOAD_KEY_PASSWORD'));
    expect(yaml, contains('ANDROID_UPLOAD_KEY_ALIAS'));
    expect(yaml, contains('REVENUECAT_ANDROID_API_KEY'));
    expect(yaml, contains('goog_'));
    expect(yaml, contains('version: 1.0.0+20260913'));
    expect(yaml, contains('base64 --decode'));
    expect(yaml, contains('android/key.properties'));
    expect(yaml, contains('flutter build appbundle --release'));
    expect(yaml, contains('jarsigner -verify'));
    expect(yaml, contains('sha256sum'));
    expect(yaml, contains('actions/upload-artifact@v4'));
    expect(yaml, isNot(contains('changeit')));
    expect(yaml, isNot(contains('ci-upload-keystore.jks')));
    expect(yaml, isNot(contains('signingConfigs.getByName("debug")')));
  });
}
