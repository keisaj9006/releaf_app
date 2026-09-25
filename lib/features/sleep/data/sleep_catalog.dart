import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../meditation/data/meditation_catalog.dart';
import '../../meditation/domain/meditation_content.dart';
import '../../sound/data/sound_catalog.dart';
import '../../sound/domain/sound_content.dart';
import '../../stories/data/story_catalog.dart';
import '../../stories/domain/relief_story.dart';
import '../domain/sleep_content.dart';
import '../domain/sleep_content_manifest.dart';
import 'sleep_content_manifest.dart';

final sleepCatalogProvider = Provider<SleepCatalog>((ref) {
  return SleepCatalog(
    soundCatalog: ref.watch(soundCatalogProvider),
    meditationCatalog: ref.watch(meditationCatalogProvider),
  );
});

class SleepCatalog {
  const SleepCatalog({
    this.soundCatalog = const SoundCatalog(),
    this.meditationCatalog = const MeditationCatalog(),
    this.manifestEntries = SleepContentManifest.candidates,
  });

  final SoundCatalog soundCatalog;
  final MeditationCatalog meditationCatalog;
  final List<SleepManifestEntry> manifestEntries;

  SleepReleaseStatus _releaseStatusFor(
    String id,
    SleepReleaseStatus sourceStatus,
  ) {
    for (final entry in manifestEntries) {
      if (entry.id != id) continue;
      if (entry.approval != SleepApprovalState.approved ||
          entry.rights != SleepRightsState.cleared ||
          !SleepContentManifest.promotedIds.contains(id)) {
        return SleepReleaseStatus.assetPending;
      }
      break;
    }
    return sourceStatus;
  }

  static const _storyIds = <String>['ST-DC-004'];

  static const _natureIds = <String>[
    'soft-rain',
    'night-air',
    'ocean-wash',
    'forest-canopy',
  ];

  static const _sleepMusicIds = <String>[
    'deep-drift',
    'releaf-atmosphere-01',
    'releaf-atmosphere-02',
  ];

  static const _sleepMeditationIds = <String>[
    'let-the-day-go-6',
    'body-into-stillness-8',
    'quiet-night-10',
  ];

  List<SleepContent> getAll() {
    final items = <SleepContent>[
      ..._storyItems(),
      ..._soundItems(_natureIds, SleepCategory.nature),
      ..._sleepMeditations(),
      ..._soundItems(_sleepMusicIds, SleepCategory.sleepMusic),
    ];
    return List<SleepContent>.unmodifiable(items);
  }

  SleepContent? getById(String id) {
    for (final item in getAll()) {
      if (item.id == id) return item;
    }
    return null;
  }

  List<SleepContent> getByCategory(SleepCategory category) => getAll()
      .where((item) => item.category == category)
      .toList(growable: false);

  List<SleepContent> getFeatured() => _ranked(
    getAll().where((item) => item.featuredRank != null && item.isPlayable),
    (item) => item.featuredRank!,
  );

  List<SleepContent> getPopular() => _ranked(
    getAll().where((item) => item.popularRank != null && item.isPlayable),
    (item) => item.popularRank!,
  );

  List<SleepContent> getByStoryCollection(SleepStoryCollection collection) =>
      getAll()
          .where((item) {
            final source = item.playbackSource;
            if (source?.type != SleepPlaybackSourceType.story) return false;
            return StoryCatalog.getById(source!.reference)?.sleepCollection ==
                collection;
          })
          .toList(growable: false);

  List<String> validateReferences() {
    final errors = <String>[];
    final seenIds = <String>{};

    for (final id in _storyIds) {
      if (StoryCatalog.getById(id) == null) {
        errors.add('$id references unknown Story $id');
      }
    }
    for (final id in [..._natureIds, ..._sleepMusicIds]) {
      if (soundCatalog.getById(id) == null) {
        errors.add('$id references unknown Sound $id');
      }
    }
    for (final id in _sleepMeditationIds) {
      if (meditationCatalog.getById(id) == null) {
        errors.add('$id references unknown Meditation $id');
      }
    }

    for (final item in getAll()) {
      if (!seenIds.add(item.id)) {
        errors.add('Duplicate Sleep content id: ${item.id}');
      }

      final source = item.playbackSource;
      if (source == null) continue;
      switch (source.type) {
        case SleepPlaybackSourceType.story:
          if (StoryCatalog.getById(source.reference) == null) {
            errors.add(
              '${item.id} references unknown Story ${source.reference}',
            );
          }
        case SleepPlaybackSourceType.sound:
          if (soundCatalog.getById(source.reference) == null) {
            errors.add(
              '${item.id} references unknown Sound ${source.reference}',
            );
          }
        case SleepPlaybackSourceType.meditation:
          if (meditationCatalog.getById(source.reference) == null) {
            errors.add(
              '${item.id} references unknown Meditation ${source.reference}',
            );
          }
      }
    }
    return List<String>.unmodifiable(errors);
  }

  List<SleepContent> _storyItems() {
    return _storyIds
        .map(StoryCatalog.getById)
        .whereType<ReliefStory>()
        .map(
          (story) => SleepContent(
            id: story.id,
            title: story.title,
            subtitle: story.subtitle,
            description: story.description,
            category: SleepCategory.stories,
            accessTier: switch (story.isPremium) {
              true => SleepAccessTier.premium,
              false => SleepAccessTier.free,
              null => SleepAccessTier.undecided,
            },
            releaseStatus: _releaseStatusFor(
              story.id,
              story.isAudioAvailable
                  ? SleepReleaseStatus.ready
                  : SleepReleaseStatus.assetPending,
            ),
            duration: story.estimatedDuration,
            playbackSource: SleepPlaybackSource.story(story.id),
            accessibilityLabel:
                '${story.title}, ${story.sleepCollection?.label ?? 'Sleep Story'}${story.narrator == null ? '' : ', narrated by ${story.narrator}'}.',
          ),
        )
        .toList(growable: false);
  }

  List<SleepContent> _soundItems(List<String> ids, SleepCategory category) {
    return ids
        .map(soundCatalog.getById)
        .whereType<SoundContent>()
        .map(
          (track) => SleepContent(
            id: track.id,
            title: track.title,
            subtitle: track.subtitle,
            description: track.subtitle,
            category: category,
            accessTier: track.isPremium
                ? SleepAccessTier.premium
                : SleepAccessTier.free,
            releaseStatus: _releaseStatusFor(
              track.id,
              SleepReleaseStatus.ready,
            ),
            featuredRank: switch (track.id) {
              'deep-drift' => 1,
              'soft-rain' => 2,
              _ => null,
            },
            popularRank: switch (track.id) {
              'deep-drift' => 1,
              'soft-rain' => 2,
              'ocean-wash' => 3,
              'releaf-atmosphere-01' => 4,
              _ => null,
            },
            playbackSource: SleepPlaybackSource.sound(track.id),
            accessibilityLabel: '${track.title}. ${track.subtitle}',
          ),
        )
        .toList(growable: false);
  }

  List<SleepContent> _sleepMeditations() {
    return _sleepMeditationIds
        .map(meditationCatalog.getById)
        .whereType<MeditationContent>()
        .map(
          (practice) => SleepContent(
            id: practice.id,
            title: practice.title,
            subtitle: practice.subtitle,
            description: practice.subtitle,
            category: SleepCategory.meditations,
            accessTier: practice.accessTier == MeditationAccessTier.premium
                ? SleepAccessTier.premium
                : SleepAccessTier.free,
            releaseStatus: _releaseStatusFor(
              practice.id,
              practice.hasRecordedNarration || practice.unguided
                  ? SleepReleaseStatus.ready
                  : SleepReleaseStatus.guidanceOnly,
            ),
            duration: Duration(seconds: practice.durationSeconds),
            playbackSource: SleepPlaybackSource.meditation(practice.id),
            accessibilityLabel:
                '${practice.title}, ${practice.durationSeconds ~/ 60} minute sleep meditation.',
          ),
        )
        .toList(growable: false);
  }

  static List<SleepContent> _ranked(
    Iterable<SleepContent> items,
    int Function(SleepContent) rankOf,
  ) {
    final ranked = items.toList(growable: false)
      ..sort((a, b) {
        final byRank = rankOf(a).compareTo(rankOf(b));
        return byRank != 0 ? byRank : a.id.compareTo(b.id);
      });
    return List<SleepContent>.unmodifiable(ranked);
  }
}
