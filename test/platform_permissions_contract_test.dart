import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('iOS declares motion permission for Labyrinth tilt control', () {
    final plist = File('ios/Runner/Info.plist').readAsStringSync();

    expect(plist, contains('<key>NSMotionUsageDescription</key>'));
    expect(
      plist,
      contains(
        'Releaf uses motion data so you can guide the ball in Labyrinth by tilting your device.',
      ),
    );
  });
}
