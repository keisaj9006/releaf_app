import 'dart:io';

import 'package:releaf_app/features/meditation/data/meditation_catalog.dart';
import 'package:releaf_app/features/sleep/data/sleep_catalog.dart';
import 'package:releaf_app/features/sleep/data/sleep_content_manifest.dart';
import 'package:releaf_app/features/sleep/domain/sleep_content.dart';
import 'package:releaf_app/features/sleep/domain/sleep_content_manifest.dart';
import 'package:releaf_app/features/sound/data/sound_catalog.dart';
import 'package:releaf_app/features/stories/data/story_catalog.dart';

const _audioExtensions = {'.mp3', '.m4a', '.wav'};
const _artworkExtensions = {'.png', '.jpg', '.webp'};

class SleepContentAudit {
  const SleepContentAudit({
    required this.candidateIssues,
    required this.releaseErrors,
    required this.runtimeReadyIds,
    required this.candidateBytes,
    required this.promotedBytes,
  });

  final List<String> candidateIssues;
  final List<String> releaseErrors;
  final Set<String> runtimeReadyIds;
  final int candidateBytes;
  final int promotedBytes;

  bool get canRelease => releaseErrors.isEmpty;
}

SleepContentAudit auditSleepContentManifest({
  required Directory root,
  required List<SleepManifestEntry> entries,
  Set<String> promotedIds = const {},
}) {
  final issues = <String>[];
  final releaseErrors = <String>[];
  final checkedFiles = <String, int>{};

  bool assetExists(String path) {
    if (!_safeLocalAssetPath(path)) return false;
    final file = _assetFile(root, path);
    if (!file.existsSync()) return false;
    checkedFiles[path] = file.lengthSync();
    return true;
  }

  final validation = SleepContentManifest.validate(
    entries: entries,
    assetExists: assetExists,
    sourceExists: _sourceExists,
  );
  issues.addAll(validation.errors);
  releaseErrors.addAll(validation.releaseErrors);

  for (final entry in entries) {
    final canonical = const SleepCatalog().getById(entry.id);
    final catalogProblem = canonical == null
        ? 'content ID is not registered in Sleep'
        : canonical.category != entry.category ||
              canonical.playbackSource?.type != entry.source.type ||
              canonical.playbackSource?.reference != entry.source.reference
        ? 'category or player source conflicts with Sleep catalog'
        : canonical.accessTier != entry.accessTier
        ? 'access tier conflicts with player source'
        : null;
    if (catalogProblem != null) {
      final message = '${entry.id}: $catalogProblem';
      issues.add(message);
      if (entry.approval == SleepApprovalState.approved ||
          promotedIds.contains(entry.id)) {
        releaseErrors.add(message);
      }
    }

    final paths = <(String, Set<String>, String)>[
      (entry.audioAsset, _audioExtensions, 'audio'),
      (entry.artworkAsset, _artworkExtensions, 'artwork'),
      if (entry.ambienceAsset != null && entry.ambienceAsset!.isNotEmpty)
        (entry.ambienceAsset!, _audioExtensions, 'ambience'),
    ];
    for (final (path, extensions, role) in paths) {
      if (path.isEmpty) continue;
      final problem = !_safeLocalAssetPath(path)
          ? '$role asset path is unsafe'
          : !extensions.any(
              (extension) => path.toLowerCase().endsWith(extension),
            )
          ? '$role format is unsupported'
          : null;
      if (problem == null) continue;
      final message = '${entry.id}: $problem';
      issues.add(message);
      if (entry.approval == SleepApprovalState.approved ||
          promotedIds.contains(entry.id)) {
        releaseErrors.add(message);
      }
    }
  }

  for (final id in promotedIds) {
    if (!entries.any((entry) => entry.id == id)) {
      releaseErrors.add('$id: promoted item is absent');
    } else if (!validation.runtimeReadyIds.contains(id) ||
        issues.any((issue) => issue.startsWith('$id:'))) {
      releaseErrors.add('$id: promoted item is not ready');
    }
  }

  final promotedPaths = <String>{};
  for (final entry in entries) {
    if (!promotedIds.contains(entry.id) ||
        !validation.runtimeReadyIds.contains(entry.id)) {
      continue;
    }
    promotedPaths.add(entry.audioAsset);
    promotedPaths.add(entry.artworkAsset);
    if (entry.ambienceAsset != null) promotedPaths.add(entry.ambienceAsset!);
  }

  return SleepContentAudit(
    candidateIssues: List<String>.unmodifiable(issues.toSet()),
    releaseErrors: List<String>.unmodifiable(releaseErrors.toSet()),
    runtimeReadyIds: Set<String>.unmodifiable(validation.runtimeReadyIds),
    candidateBytes: checkedFiles.values.fold(0, (sum, bytes) => sum + bytes),
    promotedBytes: promotedPaths.fold<int>(
      0,
      (sum, path) => sum + (checkedFiles[path] ?? 0),
    ),
  );
}

bool _safeLocalAssetPath(String path) {
  if (!path.startsWith('assets/') ||
      path.contains('\\') ||
      path.contains(':')) {
    return false;
  }
  return path
      .split('/')
      .every((part) => part.isNotEmpty && part != '.' && part != '..');
}

File _assetFile(Directory root, String path) => File(
  '${root.absolute.path}${Platform.pathSeparator}${path.replaceAll('/', Platform.pathSeparator)}',
);

bool _sourceExists(SleepPlaybackSource source) => switch (source.type) {
  SleepPlaybackSourceType.story =>
    StoryCatalog.getById(source.reference) != null,
  SleepPlaybackSourceType.sound =>
    const SoundCatalog().getById(source.reference) != null,
  SleepPlaybackSourceType.meditation =>
    const MeditationCatalog().getById(source.reference) != null,
};
