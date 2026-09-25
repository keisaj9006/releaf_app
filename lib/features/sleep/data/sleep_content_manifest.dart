import '../domain/sleep_content.dart';
import '../domain/sleep_content_manifest.dart';

abstract final class SleepContentManifest {
  /// A candidate is promoted only in the same reviewed change that passes the
  /// repository asset, provenance and catalog checks.
  static const promotedIds = <String>{};

  /// Intake candidates only. Existing playable Sound tracks retain their
  /// established catalog contract until they receive a documented migration.
  static const candidates = <SleepManifestEntry>[
    SleepManifestEntry(
      id: 'ST-DC-004',
      title: 'The Princess and the Pea — A Rainy Night at the Palace',
      description: 'A gentle bedtime retelling awaiting production assets.',
      category: SleepCategory.stories,
      audioAsset: '',
      artworkAsset: '',
      duration: null,
      accessTier: SleepAccessTier.undecided,
      source: SleepPlaybackSource.story('ST-DC-004'),
      creatorSource: 'Releaf Story catalog',
      licenceRecord: '',
      approval: SleepApprovalState.pending,
      rights: SleepRightsState.pending,
      releaseNotes: 'Narration, artwork, rights and owner approval pending.',
      narratorProvenance: '',
    ),
  ];

  static SleepManifestValidation validate({
    required List<SleepManifestEntry> entries,
    required bool Function(String path) assetExists,
    required bool Function(SleepPlaybackSource source) sourceExists,
  }) {
    final errors = <String>[];
    final releaseErrors = <String>[];
    final ready = <String>{};
    final counts = <String, int>{};

    for (final entry in entries) {
      counts[entry.id] = (counts[entry.id] ?? 0) + 1;
    }

    for (final entry in entries) {
      final issues = <String>[];
      final id = entry.id.trim();
      if (id.isEmpty || !RegExp(r'^[A-Za-z0-9][A-Za-z0-9_-]*$').hasMatch(id)) {
        issues.add('content ID is malformed');
      }
      if ((counts[entry.id] ?? 0) > 1) {
        issues.add('duplicate content ID');
      }
      if (entry.title.trim().isEmpty) issues.add('title is missing');
      if (entry.description.trim().isEmpty) {
        issues.add('description is missing');
      }
      if (entry.audioAsset.trim().isEmpty || !assetExists(entry.audioAsset)) {
        issues.add('audio asset is missing');
      }
      if (entry.artworkAsset.trim().isEmpty ||
          !assetExists(entry.artworkAsset)) {
        issues.add('artwork asset is missing');
      }
      if (entry.ambienceAsset != null &&
          entry.ambienceAsset!.trim().isNotEmpty &&
          !assetExists(entry.ambienceAsset!)) {
        issues.add('ambience asset is missing');
      }
      if (entry.duration == null || entry.duration! <= Duration.zero) {
        issues.add('duration is missing or invalid');
      }
      if (entry.accessTier == SleepAccessTier.undecided) {
        issues.add('access tier is undecided');
      }
      if (entry.creatorSource.trim().isEmpty) {
        issues.add('creator/source is missing');
      }
      if (entry.licenceRecord.trim().isEmpty) {
        issues.add('licence record is missing');
      }
      if (entry.approval != SleepApprovalState.approved) {
        issues.add('content is not approved');
      }
      if (entry.rights != SleepRightsState.cleared) {
        issues.add('rights are not cleared');
      }
      if (entry.category == SleepCategory.stories ||
          entry.category == SleepCategory.meditations) {
        if (entry.narratorProvenance?.trim().isEmpty ?? true) {
          issues.add('narrator provenance is missing');
        }
      }
      if (!sourceExists(entry.source)) {
        issues.add('player source is unknown');
      }

      for (final issue in issues) {
        final message = '${entry.id}: $issue';
        errors.add(message);
        if (entry.approval == SleepApprovalState.approved ||
            issue == 'duplicate content ID') {
          releaseErrors.add(message);
        }
      }
      if (issues.isEmpty) ready.add(entry.id);
    }

    return SleepManifestValidation(
      errors: List<String>.unmodifiable(errors),
      releaseErrors: List<String>.unmodifiable(releaseErrors),
      runtimeReadyIds: Set<String>.unmodifiable(ready),
    );
  }
}
