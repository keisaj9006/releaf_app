enum SleepCategory {
  stories('Stories'),
  nature('Nature'),
  meditations('Meditations'),
  sleepMusic('Sleep Music');

  const SleepCategory(this.label);

  final String label;
}

enum SleepAccessTier { free, premium, undecided }

enum SleepReleaseStatus { ready, assetPending, guidanceOnly }

enum SleepPlaybackSourceType { story, sound, meditation }

class SleepPlaybackSource {
  const SleepPlaybackSource.story(String storyId)
    : type = SleepPlaybackSourceType.story,
      reference = storyId;

  const SleepPlaybackSource.sound(String soundId)
    : type = SleepPlaybackSourceType.sound,
      reference = soundId;

  const SleepPlaybackSource.meditation(String meditationId)
    : type = SleepPlaybackSourceType.meditation,
      reference = meditationId;

  final SleepPlaybackSourceType type;
  final String reference;
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
    this.featuredRank,
    this.popularRank,
    this.isNew = false,
    this.accessibilityLabel,
  }) : assert(id != ''),
       assert(title != ''),
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
  final int? featuredRank;
  final int? popularRank;
  final bool isNew;
  final String? accessibilityLabel;

  bool get isPremium => accessTier == SleepAccessTier.premium;

  bool get isPlayable =>
      releaseStatus == SleepReleaseStatus.ready &&
      accessTier != SleepAccessTier.undecided &&
      playbackSource != null;
}
