enum StoryCategory { trueStoriesOfCourage, meaningStories, storiesThatTeach }

enum SleepStoryCollection {
  dreamClassics('Dream Classics'),
  nightMysteries('Night Mysteries'),
  fictionEscapes('Fiction Escapes'),
  wonderJourneys('Wonder Journeys'),
  driftThroughHistory('Drift Through History');

  const SleepStoryCollection(this.label);

  final String label;
}

class ReliefStoryChapter {
  const ReliefStoryChapter({
    required this.id,
    required this.title,
    required this.start,
  });

  final String id;
  final String title;
  final Duration start;
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
    this.sleepCollection,
    this.narrator,
  });

  final String id;
  final String title;
  final String subtitle;
  final String series;
  final StoryCategory? category;
  final String description;
  final Duration? estimatedDuration;
  final String? audioAssetPath;
  final String? artworkAssetPath;
  final String contentWarning;
  final List<String> labels;
  final bool? isPremium;
  final List<ReliefStoryChapter> chapters;
  final String rightsStatus;
  final String scriptVersion;
  final String audioVersion;
  final SleepStoryCollection? sleepCollection;
  final String? narrator;

  bool get isAudioAvailable => audioAssetPath?.trim().isNotEmpty == true;

  ReliefStoryChapter? chapterAt(Duration position) {
    if (position.isNegative || chapters.isEmpty) return null;

    ReliefStoryChapter? current;
    for (final chapter in chapters) {
      if (chapter.start > position) break;
      current = chapter;
    }
    return current;
  }
}
