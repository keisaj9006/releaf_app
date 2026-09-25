import 'sleep_content.dart';

enum SleepApprovalState { pending, approved }

enum SleepRightsState { pending, cleared }

/// Editorial intake for a local Sleep item. This does not grant runtime access.
class SleepManifestEntry {
  const SleepManifestEntry({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.audioAsset,
    required this.artworkAsset,
    required this.duration,
    required this.accessTier,
    required this.source,
    required this.creatorSource,
    required this.licenceRecord,
    required this.approval,
    required this.rights,
    required this.releaseNotes,
    this.narratorProvenance,
    this.ambienceAsset,
  });

  final String id;
  final String title;
  final String description;
  final SleepCategory category;
  final String audioAsset;
  final String artworkAsset;
  final Duration? duration;
  final SleepAccessTier accessTier;
  final SleepPlaybackSource source;
  final String creatorSource;
  final String licenceRecord;
  final SleepApprovalState approval;
  final SleepRightsState rights;
  final String releaseNotes;
  final String? narratorProvenance;
  final String? ambienceAsset;

  SleepManifestEntry copyWith({
    String? id,
    String? title,
    String? description,
    SleepCategory? category,
    String? audioAsset,
    String? artworkAsset,
    Duration? duration,
    SleepAccessTier? accessTier,
    SleepPlaybackSource? source,
    String? creatorSource,
    String? licenceRecord,
    SleepApprovalState? approval,
    SleepRightsState? rights,
    String? releaseNotes,
    String? narratorProvenance,
    String? ambienceAsset,
  }) => SleepManifestEntry(
    id: id ?? this.id,
    title: title ?? this.title,
    description: description ?? this.description,
    category: category ?? this.category,
    audioAsset: audioAsset ?? this.audioAsset,
    artworkAsset: artworkAsset ?? this.artworkAsset,
    duration: duration ?? this.duration,
    accessTier: accessTier ?? this.accessTier,
    source: source ?? this.source,
    creatorSource: creatorSource ?? this.creatorSource,
    licenceRecord: licenceRecord ?? this.licenceRecord,
    approval: approval ?? this.approval,
    rights: rights ?? this.rights,
    releaseNotes: releaseNotes ?? this.releaseNotes,
    narratorProvenance: narratorProvenance ?? this.narratorProvenance,
    ambienceAsset: ambienceAsset ?? this.ambienceAsset,
  );
}

class SleepManifestValidation {
  const SleepManifestValidation({
    required this.errors,
    required this.releaseErrors,
    required this.runtimeReadyIds,
  });

  /// All candidate issues, including expected gaps in pending material.
  final List<String> errors;

  /// Invalid approved entries and duplicate IDs that must fail release checks.
  final List<String> releaseErrors;
  final Set<String> runtimeReadyIds;
}
