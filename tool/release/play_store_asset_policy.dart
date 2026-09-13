import 'dart:io';
import 'dart:typed_data';

class PlayStoreAssetAudit {
  const PlayStoreAssetAudit({required this.errors});

  final List<String> errors;

  bool get isReady => errors.isEmpty;
}

class _ImageMetadata {
  const _ImageMetadata({
    required this.width,
    required this.height,
    required this.kind,
    this.bitDepth,
    this.pngColorType,
  });

  final int width;
  final int height;
  final String kind;
  final int? bitDepth;
  final int? pngColorType;
}

const _pngSignature = <int>[137, 80, 78, 71, 13, 10, 26, 10];
const _jpegSofMarkers = <int>{
  0xc0,
  0xc1,
  0xc2,
  0xc3,
  0xc5,
  0xc6,
  0xc7,
  0xc9,
  0xca,
  0xcb,
  0xcd,
  0xce,
  0xcf,
};

PlayStoreAssetAudit auditPlayStoreAssets(
  String rootPath, {
  bool strongListing = false,
}) {
  final root = Directory(rootPath);
  final errors = <String>[];
  final storeRoot = Directory('${root.path}/store/google-play');

  final icon = File('${storeRoot.path}/app-icon.png');
  if (!icon.existsSync()) {
    errors.add(
      'Missing Google Play app icon: store/google-play/app-icon.png.',
    );
  } else {
    final metadata = _readImageMetadata(icon, errors, label: 'App icon');
    if (metadata != null) {
      if (metadata.kind != 'png' ||
          metadata.width != 512 ||
          metadata.height != 512 ||
          metadata.bitDepth != 8 ||
          metadata.pngColorType != 6) {
        errors.add(
          'App icon must be a 512 x 512 32-bit PNG with alpha.',
        );
      }
    }
    if (icon.lengthSync() > 1024 * 1024) {
      errors.add('App icon must be no larger than 1,024 KB.');
    }
  }

  final featureCandidates = <File>[
    File('${storeRoot.path}/feature-graphic.png'),
    File('${storeRoot.path}/feature-graphic.jpg'),
    File('${storeRoot.path}/feature-graphic.jpeg'),
  ].where((file) => file.existsSync()).toList();

  if (featureCandidates.isEmpty) {
    errors.add(
      'Missing Google Play feature graphic at store/google-play/'
      'feature-graphic.(png|jpg|jpeg).',
    );
  } else if (featureCandidates.length > 1) {
    errors.add('Provide exactly one Google Play feature graphic.');
  } else {
    final feature = featureCandidates.single;
    final metadata = _readImageMetadata(
      feature,
      errors,
      label: 'Feature graphic',
    );
    if (metadata != null) {
      if (metadata.width != 1024 || metadata.height != 500) {
        errors.add('Feature graphic must be exactly 1,024 x 500 px.');
      }
      if (metadata.kind == 'png' &&
          (metadata.bitDepth != 8 || metadata.pngColorType != 2)) {
        errors.add('Feature graphic PNG must be 24-bit PNG without alpha.');
      }
      if (metadata.kind != 'png' && metadata.kind != 'jpeg') {
        errors.add('Feature graphic must be JPEG or PNG.');
      }
    }
  }

  final screenshotsDirectory = Directory(
    '${storeRoot.path}/screenshots/phone',
  );
  var screenshots = <File>[];
  if (screenshotsDirectory.existsSync()) {
    screenshots = screenshotsDirectory
        .listSync(followLinks: false)
        .whereType<File>()
        .where((file) {
          final extension = _extension(file.path);
          return extension == 'png' ||
              extension == 'jpg' ||
              extension == 'jpeg';
        })
        .toList()
      ..sort((a, b) => a.path.compareTo(b.path));
  }

  final minimumScreenshots = strongListing ? 4 : 2;
  if (screenshots.length < minimumScreenshots) {
    errors.add(
      strongListing
          ? 'Strong listing requires at least 4 portrait phone screenshots.'
          : 'Google Play listing requires at least 2 phone screenshots.',
    );
  }

  for (final screenshot in screenshots) {
    final metadata = _readImageMetadata(
      screenshot,
      errors,
      label: 'Phone screenshot ${_basename(screenshot.path)}',
    );
    if (metadata == null) {
      continue;
    }
    if (metadata.width >= metadata.height) {
      errors.add(
        'Phone screenshot ${_basename(screenshot.path)} must be portrait.',
      );
    }
    if (strongListing &&
        (metadata.width < 1080 || metadata.height < 1920)) {
      errors.add(
        'Strong-listing phone screenshot ${_basename(screenshot.path)} '
        'must be at least 1,080 x 1,920 px.',
      );
    }
  }

  return PlayStoreAssetAudit(errors: List.unmodifiable(errors));
}

_ImageMetadata? _readImageMetadata(
  File file,
  List<String> errors, {
  required String label,
}) {
  try {
    final bytes = file.readAsBytesSync();
    final extension = _extension(file.path);
    if (extension == 'png') {
      return _readPngMetadata(bytes, errors, label: label);
    }
    if (extension == 'jpg' || extension == 'jpeg') {
      return _readJpegMetadata(bytes, errors, label: label);
    }
    errors.add('$label must use PNG or JPEG format.');
    return null;
  } on FileSystemException catch (error) {
    errors.add('$label could not be read: ${error.message}.');
    return null;
  }
}

_ImageMetadata? _readPngMetadata(
  Uint8List bytes,
  List<String> errors, {
  required String label,
}) {
  if (bytes.length < 33 || !_matches(bytes, 0, _pngSignature)) {
    errors.add('$label is not a valid PNG file.');
    return null;
  }

  final header = ByteData.sublistView(bytes);
  final ihdrLength = header.getUint32(8, Endian.big);
  final ihdrType = String.fromCharCodes(bytes.sublist(12, 16));
  if (ihdrLength != 13 || ihdrType != 'IHDR') {
    errors.add('$label has an invalid PNG IHDR header.');
    return null;
  }

  return _ImageMetadata(
    width: header.getUint32(16, Endian.big),
    height: header.getUint32(20, Endian.big),
    kind: 'png',
    bitDepth: bytes[24],
    pngColorType: bytes[25],
  );
}

_ImageMetadata? _readJpegMetadata(
  Uint8List bytes,
  List<String> errors, {
  required String label,
}) {
  if (bytes.length < 4 || bytes[0] != 0xff || bytes[1] != 0xd8) {
    errors.add('$label is not a valid JPEG file.');
    return null;
  }

  var offset = 2;
  while (offset < bytes.length) {
    while (offset < bytes.length && bytes[offset] != 0xff) {
      offset++;
    }
    while (offset < bytes.length && bytes[offset] == 0xff) {
      offset++;
    }
    if (offset >= bytes.length) {
      break;
    }

    final marker = bytes[offset++];
    if (marker == 0xd9 || marker == 0xda) {
      break;
    }
    if (marker == 0x01 || (marker >= 0xd0 && marker <= 0xd7)) {
      continue;
    }
    if (offset + 1 >= bytes.length) {
      break;
    }

    final segmentLength = (bytes[offset] << 8) | bytes[offset + 1];
    if (segmentLength < 2 || offset + segmentLength > bytes.length) {
      errors.add('$label has an invalid JPEG segment.');
      return null;
    }

    if (_jpegSofMarkers.contains(marker)) {
      if (segmentLength < 7 || offset + 6 >= bytes.length) {
        errors.add('$label has an invalid JPEG frame header.');
        return null;
      }
      final height = (bytes[offset + 3] << 8) | bytes[offset + 4];
      final width = (bytes[offset + 5] << 8) | bytes[offset + 6];
      if (width <= 0 || height <= 0) {
        errors.add('$label has invalid JPEG dimensions.');
        return null;
      }
      return _ImageMetadata(width: width, height: height, kind: 'jpeg');
    }

    offset += segmentLength;
  }

  errors.add('$label does not contain a readable JPEG frame.');
  return null;
}

bool _matches(List<int> bytes, int offset, List<int> expected) {
  if (offset + expected.length > bytes.length) {
    return false;
  }
  for (var index = 0; index < expected.length; index++) {
    if (bytes[offset + index] != expected[index]) {
      return false;
    }
  }
  return true;
}

String _extension(String path) {
  final name = _basename(path);
  final dot = name.lastIndexOf('.');
  return dot == -1 ? '' : name.substring(dot + 1).toLowerCase();
}

String _basename(String path) {
  final normalized = path.replaceAll('\\', '/');
  return normalized.substring(normalized.lastIndexOf('/') + 1);
}

void main(List<String> args) {
  var rootPath = '.';
  var strongListing = false;

  for (var index = 0; index < args.length; index++) {
    final argument = args[index];
    if (argument == '--strong-listing') {
      strongListing = true;
      continue;
    }
    if (argument == '--root') {
      if (index + 1 >= args.length) {
        stderr.writeln('Missing value for --root.');
        _printUsage();
        exitCode = 64;
        return;
      }
      rootPath = args[++index];
      continue;
    }

    stderr.writeln('Unknown argument: $argument');
    _printUsage();
    exitCode = 64;
    return;
  }

  final audit = auditPlayStoreAssets(
    rootPath,
    strongListing: strongListing,
  );
  if (audit.isReady) {
    stdout.writeln('PASS: Google Play asset pack is ready.');
    return;
  }

  stderr.writeln('FAIL: Google Play asset pack is not ready.');
  for (final error in audit.errors) {
    stderr.writeln('- $error');
  }
  exitCode = 1;
}

void _printUsage() {
  stderr.writeln(
    'Usage: dart run tool/release/play_store_asset_policy.dart '
    '[--root <path>] [--strong-listing]',
  );
}
