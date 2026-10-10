import 'dart:ui' as ui;

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const assets = <String>[
    'assets/art/relief/reset.webp',
    'assets/art/relief/breathe.webp',
    'assets/art/relief/body_scan.webp',
    'assets/art/relief/tension_relief.webp',
    'assets/art/relief/sleep.webp',
    'assets/art/relief/sleep_stories.webp',
    'assets/art/relief/soundscapes.webp',
    'assets/art/relief/meditate.webp',
    'assets/art/relief/brain_games.webp',
    'assets/art/relief/emergency_calm.webp',
  ];

  test('all ten editorial illustrations are bundled and decode', () async {
    expect(assets, hasLength(10));
    for (final path in assets) {
      final data = await rootBundle.load(path);
      final codec = await ui.instantiateImageCodec(
        data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
      );
      final frame = await codec.getNextFrame();
      expect(frame.image.width, 1024, reason: path);
      expect(frame.image.height, 735, reason: path);
      frame.image.dispose();
      codec.dispose();
    }
  });
}
