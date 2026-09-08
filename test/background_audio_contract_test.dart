import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Android declares Releaf background media playback service', () {
    final manifest = File('android/app/src/main/AndroidManifest.xml').readAsStringSync();
    final activity = File(
      'android/app/src/main/kotlin/app/releaf/mobile/MainActivity.kt',
    ).readAsStringSync();

    expect(
      manifest,
      contains('android.permission.FOREGROUND_SERVICE_MEDIA_PLAYBACK'),
    );
    expect(
      manifest,
      contains('com.ryanheise.audioservice.AudioService'),
    );
    expect(
      manifest,
      contains('com.ryanheise.audioservice.MediaButtonReceiver'),
    );
    expect(
      manifest,
      contains('android:foregroundServiceType="mediaPlayback"'),
    );
    expect(activity, contains('AudioServiceActivity'));
  });

  test('iOS declares audio background mode', () {
    final plist = File('ios/Runner/Info.plist').readAsStringSync();

    expect(plist, contains('<key>UIBackgroundModes</key>'));
    expect(plist, contains('<string>audio</string>'));
  });
}
