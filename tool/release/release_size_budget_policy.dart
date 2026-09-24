import 'dart:io';

const int measuredAppBundleBaselineBytes = 93375235;
const int measuredReleaseAssetTreeBaselineBytes = 56348319;

// These limits leave roughly 12% above the measured 1.0 baseline. Crossing a
// limit is allowed only through an intentional, reviewed policy update.
const int maxAppBundleBytes = 105000000;
const int maxReleaseAssetTreeBytes = 63000000;

final class ReleaseSizeBudgetResult {
  const ReleaseSizeBudgetResult({
    required this.appBundleBytes,
    required this.releaseAssetTreeBytes,
    required this.errors,
  });

  final int appBundleBytes;
  final int releaseAssetTreeBytes;
  final List<String> errors;

  bool get isReady => errors.isEmpty;
  int get appBundleHeadroomBytes => maxAppBundleBytes - appBundleBytes;
  int get releaseAssetTreeHeadroomBytes =>
      maxReleaseAssetTreeBytes - releaseAssetTreeBytes;
}

ReleaseSizeBudgetResult auditReleaseSizeBudget({
  required int appBundleBytes,
  required int releaseAssetTreeBytes,
}) {
  final errors = <String>[];
  if (appBundleBytes > maxAppBundleBytes) {
    errors.add(
      'Release AAB is $appBundleBytes bytes; budget is '
      '$maxAppBundleBytes bytes.',
    );
  }
  if (releaseAssetTreeBytes > maxReleaseAssetTreeBytes) {
    errors.add(
      'Release asset tree is $releaseAssetTreeBytes bytes; budget is '
      '$maxReleaseAssetTreeBytes bytes.',
    );
  }
  return ReleaseSizeBudgetResult(
    appBundleBytes: appBundleBytes,
    releaseAssetTreeBytes: releaseAssetTreeBytes,
    errors: List.unmodifiable(errors),
  );
}

int _directoryBytes(Directory directory) => directory
    .listSync(recursive: true, followLinks: false)
    .whereType<File>()
    .fold(0, (total, file) => total + file.lengthSync());

Never _usage() {
  stderr.writeln(
    'Usage: dart run tool/release/release_size_budget_policy.dart '
    '--aab <app-release.aab> --assets <assets-directory>',
  );
  exit(64);
}

void main(List<String> arguments) {
  String? aabPath;
  String? assetsPath;
  for (var index = 0; index < arguments.length; index++) {
    if (index + 1 >= arguments.length) _usage();
    switch (arguments[index]) {
      case '--aab':
        aabPath = arguments[++index];
      case '--assets':
        assetsPath = arguments[++index];
      default:
        _usage();
    }
  }

  if (aabPath == null || assetsPath == null) _usage();
  final aab = File(aabPath);
  final assets = Directory(assetsPath);
  if (!aab.existsSync()) {
    stderr.writeln('Release AAB was not found: ${aab.path}');
    exit(66);
  }
  if (!assets.existsSync()) {
    stderr.writeln('Runtime asset directory was not found: ${assets.path}');
    exit(66);
  }

  final result = auditReleaseSizeBudget(
    appBundleBytes: aab.lengthSync(),
    releaseAssetTreeBytes: _directoryBytes(assets),
  );
  stdout.writeln(
    'Release AAB: ${result.appBundleBytes} / $maxAppBundleBytes bytes '
    '(baseline $measuredAppBundleBaselineBytes)',
  );
  stdout.writeln(
    'Release asset tree: ${result.releaseAssetTreeBytes} / '
    '$maxReleaseAssetTreeBytes bytes '
    '(baseline $measuredReleaseAssetTreeBaselineBytes)',
  );
  if (!result.isReady) {
    for (final error in result.errors) {
      stderr.writeln('FAIL: $error');
    }
    exit(1);
  }
  stdout.writeln('PASS: release size budgets are within the measured limits.');
}
