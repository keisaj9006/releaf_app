enum StoryCategory {
  trueStoriesOfCourage,
  meaningStories,
  storiesThatTeach,
}

class ReliefStoryChapter {
  const ReliefStoryChapter({
    required this.id,
    required this.title,
    this.start,
  });

  final String id;
  final String title;

  /// Measured offset in the final delivery recording. Null means not imported.
  /// Zero is a real first-chapter timestamp, never an unknown-time placeholder.
  final Duration? start;
}

class ReliefStory {
  const ReliefStory({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.series,
    required this.category,
    required this.description,
    required this.estimatedDuration,
    required this.audioAssetPath,
    required this.artworkAssetPath,
    required this.contentWarning,
    required this.labels,
    required this.isPremium,
    required this.chapters,
    required this.rightsStatus,
    required this.scriptVersion,
    required this.audioVersion,
  });

  final String id;
  final String title;
  final String subtitle;
  final String series;
  final StoryCategory category;
  final String description;
  final Duration estimatedDuration;
  final String? audioAssetPath;
  final String? artworkAssetPath;
  final String contentWarning;
  final List<String> labels;
  final bool isPremium;
  final List<ReliefStoryChapter> chapters;
  final String rightsStatus;
  final String scriptVersion;
  final String audioVersion;

  bool get isAudioAvailable => audioAssetPath?.trim().isNotEmpty == true;
}
