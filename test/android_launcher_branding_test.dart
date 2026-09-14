import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;

void main() {
  test('all legacy Android launcher icons use Releaf branding', () {
    const expectedSizes = <String, int>{
      'mipmap-mdpi': 48,
      'mipmap-hdpi': 72,
      'mipmap-xhdpi': 96,
      'mipmap-xxhdpi': 144,
      'mipmap-xxxhdpi': 192,
    };

    for (final entry in expectedSizes.entries) {
      final file = File(
        'android/app/src/main/res/${entry.key}/ic_launcher.png',
      );
      expect(file.existsSync(), isTrue, reason: '${file.path} must exist.');

      final icon = img.decodePng(file.readAsBytesSync());
      expect(icon, isNotNull, reason: '${file.path} must be a readable PNG.');
      expect(icon!.width, entry.value, reason: '${file.path} width mismatch.');
      expect(icon.height, entry.value, reason: '${file.path} height mismatch.');

      final corner = icon.getPixel(0, 0);
      expect(
        corner.a.toInt(),
        255,
        reason: '${file.path} must have an opaque Releaf launcher background.',
      );
      expect(
        corner.r.toInt(),
        closeTo(0x0A, 2),
        reason: '${file.path} must use the Releaf #0A1712 background.',
      );
      expect(corner.g.toInt(), closeTo(0x17, 2));
      expect(corner.b.toInt(), closeTo(0x12, 2));

      var releafGreenPixels = 0;
      for (final pixel in icon) {
        final r = pixel.r.toInt();
        final g = pixel.g.toInt();
        final b = pixel.b.toInt();
        if (g > r && g > b && r >= 70 && g >= 100) {
          releafGreenPixels++;
        }
      }

      expect(
        releafGreenPixels,
        greaterThan(icon.width * icon.height * 0.03),
        reason: '${file.path} must contain the Releaf green leaf mark, not a Flutter placeholder.',
      );
    }
  });
}
