import 'dart:io';

class PlayStoreAssetAudit {
  const PlayStoreAssetAudit({required this.errors});

  final List<String> errors;

  bool get isReady => errors.isEmpty;
}

PlayStoreAssetAudit auditPlayStoreAssets(
  String rootPath, {
  bool strongListing = false,
}) {
  return const PlayStoreAssetAudit(
    errors: <String>['Google Play asset policy not implemented.'],
  );
}

void main(List<String> args) {
  stderr.writeln('Google Play asset policy not implemented.');
  exitCode = 1;
}
