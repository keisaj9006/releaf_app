import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';

import '../tool/release/play_store_asset_policy.dart' as policy;

int _crc32(List<int> bytes) {
  var crc = 0xffffffff;
  for (final byte in bytes) {
    crc ^= byte;
    for (var bit = 0; bit < 8; bit++) {
      final mask = -(crc & 1);
      crc = (crc >> 1) ^ (0xedb88320 & mask);
    }
  }
  return (crc ^ 0xffffffff) & 0xffffffff;
}

List<int> _chunk(String type, List<int> data) {
  final typeBytes = type.codeUnits;
  final builder = BytesBuilder();
  final length = ByteData(4)..setUint32(0, data.length, Endian.big);
  builder.add(length.buffer.asUint8List());
  builder.add(typeBytes);
  builder.add(data);
  final crc = ByteData(4)
    ..setUint32(0, _crc32(<int>[...typeBytes, ...data]), Endian.big);
  builder.add(crc.buffer.asUint8List());
  return builder.takeBytes();
}

void _writePng(
  File file, {
  required int width,
  required int height,
  required int colorType,
}) {
  final ihdr = ByteData(13)
    ..setUint32(0, width, Endian.big)
    ..setUint32(4, height, Endian.big)
    ..setUint8(8, 8)
    ..setUint8(9, colorType)
    ..setUint8(10, 0)
    ..setUint8(11, 0)
    ..setUint8(12, 0);

  final bytes = BytesBuilder()
    ..add(const <int>[137, 80, 78, 71, 13, 10, 26, 10])
    ..add(_chunk('IHDR', ihdr.buffer.asUint8List()))
    ..add(_chunk('IDAT', const <int>[120, 156, 3, 0, 0, 0, 0, 1]))
    ..add(_chunk('IEND', const <int>[]));
  file
    ..createSync(recursive: true)
    ..writeAsBytesSync(bytes.takeBytes());
}

Directory _validStoreFixture() {
  final root = Directory.systemTemp.createTempSync('releaf-play-assets-');
  _writePng(
    File('${root.path}/store/google-play/app-icon.png'),
    width: 512,
    height: 512,
    colorType: 6,
  );
  _writePng(
    File('${root.path}/store/google-play/feature-graphic.png'),
    width: 1024,
    height: 500,
    colorType: 2,
  );
  for (var index = 1; index <= 4; index++) {
    _writePng(
      File(
        '${root.path}/store/google-play/screenshots/phone/'
        '0$index-screen.png',
      ),
      width: 1080,
      height: 1920,
      colorType: 2,
    );
  }
  return root;
}

void main() {
  test('strong Play listing accepts a complete compliant asset pack', () {
    final root = _validStoreFixture();
    addTearDown(() => root.deleteSync(recursive: true));

    final result = policy.auditPlayStoreAssets(
      root.path,
      strongListing: true,
    );

    expect(result.isReady, isTrue, reason: result.errors.join('\n'));
  });

  test('Play listing rejects an app icon without alpha', () {
    final root = _validStoreFixture();
    addTearDown(() => root.deleteSync(recursive: true));
    _writePng(
      File('${root.path}/store/google-play/app-icon.png'),
      width: 512,
      height: 512,
      colorType: 2,
    );

    final result = policy.auditPlayStoreAssets(
      root.path,
      strongListing: true,
    );

    expect(result.isReady, isFalse);
    expect(result.errors.join('\n'), contains('32-bit PNG with alpha'));
  });

  test('strong Play listing requires four portrait phone screenshots', () {
    final root = _validStoreFixture();
    addTearDown(() => root.deleteSync(recursive: true));
    File(
      '${root.path}/store/google-play/screenshots/phone/04-screen.png',
    ).deleteSync();

    final result = policy.auditPlayStoreAssets(
      root.path,
      strongListing: true,
    );

    expect(result.isReady, isFalse);
    expect(
      result.errors.join('\n'),
      contains('at least 4 portrait phone screenshots'),
    );
  });

  test('production Play release script enforces the strong asset gate', () {
    final source = File('tool/build_play_release.ps1').readAsStringSync();

    expect(source, contains('play_store_asset_policy.dart'));
    expect(source, contains('--strong-listing'));
    expect(source, contains('Google Play listing asset gate failed'));
  });
}
