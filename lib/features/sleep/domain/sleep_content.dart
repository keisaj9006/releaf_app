enum SleepCategory {
  stories('Stories'),
  nature('Nature'),
  meditations('Meditations'),
  sleepMusic('Sleep Music');

  const SleepCategory(this.label);

  final String label;
}

enum SleepStoryCollection {
  dreamClassics('Dream Classics'),
  nightMysteries('Night Mysteries'),
  fictionEscapes('Fiction Escapes'),
  wonderJourneys('Wonder Journeys'),
  driftThroughHistory('Drift Through History');

  const SleepStoryCollection(this.label);

  final String label;
}

enum SleepAccessTier { free, premium, undecided }

enum SleepReleaseStatus { ready, assetPending, guidanceOnly }

enum SleepPlaybackSourceType { sound, meditation, asset }

class SleepPlaybackSource {
  const SleepPlaybackSource.sound(String soundId)
    : type = SleepPlaybackSourceType.sound,
      reference = soundId;

  const SleepPlaybackSource.meditation(String meditationId)
    : type = SleepPlaybackSourceType.meditation,
      reference = meditationId;

  const SleepPlaybackSource.asset(String assetPath)
    : type = SleepPlaybackSourceType.asset,
      reference = assetPath;

  final SleepPlaybackSourceType type;
  final String reference;
}

class SleepChapter {
  const SleepChapter({
    required this.id,
    required this.title,
    required this.startsAt,
  }) : assert(id != ''),
       assert(title != '');

  final String id;
  final String title;
  final Duration startsAt;
}

class SleepContent {
  const SleepContent({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.category,
    required this.accessTier,
    required this.releaseStatus,
    this.duration,
    this.playbackSource,
    this.storyCollection,
    this.artworkAssetPath,
    this.narrator,
    this.featuredRank,
    this.popularRank,
    this.isNew = false,
    this.chapters = const [],
    this.accessibilityLabel,
  }) : assert(id != ''),
       assert(title != ''),
       assert(
         category == SleepCategory.stories || storyCollection == null,
         'Only Stories may belong to a Story collection.',
       ),
       assert(
         category == SleepCategory.stories || narrator == null,
         'Narrator metadata belongs to Stories; Meditation resolves its own voice contract.',
       ),
       assert(featuredRank == null || featuredRank > 0),
       assert(popularRank == null || popularRank > 0);

  final String id;
  final String title;
  final String subtitle;
  final String description;
  final SleepCategory category;
  final SleepAccessTier accessTier;
  final SleepReleaseStatus releaseStatus;
  final Duration? duration;
  final SleepPlaybackSource? playbackSource;
  final SleepStoryCollection? storyCollection;
  final String? artworkAssetPath;
  final String? narrator;
  final int? featuredRank;
  final int? popularRank;
  final bool isNew;
  final List<SleepChapter> chapters;
  final String? accessibilityLabel;

  bool get isPremium => accessTier == SleepAccessTier.premium;

  bool get isPlayable =>
      releaseStatus == SleepReleaseStatus.ready &&
      accessTier != SleepAccessTier.undecided &&
      playbackSource != null;

  SleepChapter? chapterAt(Duration position) {
    if (position.isNegative || chapters.isEmpty) return null;

    SleepChapter? current;
    for (final chapter in chapters) {
      if (chapter.startsAt > position) break;
      current = chapter;
    }
    return current;
  }
}
