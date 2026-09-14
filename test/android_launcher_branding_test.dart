import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';

int _fnv1a32(List<int> bytes) {
  var hash = 0x811c9dc5;
  for (final byte in bytes) {
    hash ^= byte;
    hash = (hash * 0x01000193) & 0xffffffff;
  }
  return hash;
}

void main() {
  test('all legacy Android launcher icons use the approved Releaf render', () {
    const expected = <String, List<int>>{
      'mipmap-mdpi': <int>[48, 0x8efd94f9],
      'mipmap-hdpi': <int>[72, 0xcbe0e6cc],
      'mipmap-xhdpi': <int>[96, 0x8488dc69],
      'mipmap-xxhdpi': <int>[144, 0xf5ae02af],
      'mipmap-xxxhdpi': <int>[192, 0x317fe250],
    };

    for (final entry in expected.entries) {
      final file = File(
        'android/app/src/main/res/${entry.key}/ic_launcher.png',
      );
      expect(file.existsSync(), isTrue, reason: '${file.path} must exist.');

      final bytes = file.readAsBytesSync();
      expect(
        bytes.take(8),
        orderedEquals(const <int>[137, 80, 78, 71, 13, 10, 26, 10]),
        reason: '${file.path} must be a PNG.',
      );
      expect(
        String.fromCharCodes(bytes.sublist(12, 16)),
        'IHDR',
        reason: '${file.path} must start with a valid IHDR chunk.',
      );

      final header = ByteData.sublistView(bytes);
      final expectedSize = entry.value[0];
      expect(
        header.getUint32(16, Endian.big),
        expectedSize,
        reason: '${file.path} width mismatch.',
      );
      expect(
        header.getUint32(20, Endian.big),
        expectedSize,
        reason: '${file.path} height mismatch.',
      );

      expect(
        _fnv1a32(bytes),
        entry.value[1],
        reason:
            '${file.path} must be the approved Releaf legacy launcher render, '
            'not the Flutter template icon or another unreviewed asset.',
      );
    }
  });
}
