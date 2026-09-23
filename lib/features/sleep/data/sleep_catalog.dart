import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../meditation/data/meditation_catalog.dart';
import '../../meditation/domain/meditation_content.dart';
import '../../sound/data/sound_catalog.dart';
import '../../sound/domain/sound_content.dart';
import '../domain/sleep_content.dart';

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
  });

  final SoundCatalog soundCatalog;
  final MeditationCatalog meditationCatalog;

  static const _stories = <SleepContent>[
    SleepContent(
      id: 'ST-DC-004',
      title: 'The Princess and the Pea — A Rainy Night at the Palace',
      subtitle: 'A Dream Classics story currently in audio production.',
      description:
          'A rain-soaked return to the palace, prepared as a long-form bedtime story.',
      category: SleepCategory.stories,
      accessTier: SleepAccessTier.undecided,
      releaseStatus: SleepReleaseStatus.assetPending,
      storyCollection: SleepStoryCollection.dreamClassics,
      narrator: 'Theo Silk',
      accessibilityLabel:
          'The Princess and the Pea, a Dream Classics sleep story narrated by Theo Silk. Audio is coming soon.',
    ),
  ];

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
      ..._stories,
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

  List<SleepContent> getByStoryCollection(SleepStoryCollection collection) =>
      getAll()
          .where((item) => item.storyCollection == collection)
          .toList(growable: false);

  List<String> validateReferences() {
    final errors = <String>[];
    final seenIds = <String>{};

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
        case SleepPlaybackSourceType.asset:
          if (source.reference.trim().isEmpty) {
            errors.add('${item.id} has an empty asset reference');
          }
      }
    }
    return List<String>.unmodifiable(errors);
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
            releaseStatus: SleepReleaseStatus.ready,
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
            releaseStatus: practice.hasRecordedNarration || practice.unguided
                ? SleepReleaseStatus.ready
                : SleepReleaseStatus.guidanceOnly,
            duration: Duration(seconds: practice.durationSeconds),
            playbackSource: SleepPlaybackSource.meditation(practice.id),
            accessibilityLabel:
                '${practice.title}, ${practice.durationSeconds ~/ 60} minute sleep meditation.',
          ),
        )
        .toList(growable: false);
  }
}
