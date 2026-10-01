import '../domain/relief_story.dart';

/// Media-time rules shared by Story controls and local resume state.
/// No rule derives real timing from estimatedDuration or narration word counts.
abstract final class StoryPlaybackPolicy {
  static const supportedRates = <double>[
    0.65,
    0.75,
    0.85,
    0.90,
    1.00,
    1.10,
    1.20,
    1.35,
    1.50,
  ];

  /// 1.0 plays the supplied recording unchanged, including its recorded pace.
  static double normaliseRate(Object? value) {
    if (value is! num || !value.isFinite) return 1.0;
    final rate = value.toDouble();
    return supportedRates.contains(rate) ? rate : 1.0;
  }

  /// Metadata readiness only: this does not prove a file exists or is licensed.
  static bool hasDeliveryMetadata(ReliefStory story) {
    return story.isAudioAvailable &&
        story.id.trim().isNotEmpty &&
        _hasVersion(story.scriptVersion) &&
        _hasVersion(story.audioVersion);
  }

  static bool _hasVersion(String value) {
    final version = value.trim();
    return version.isNotEmpty && version.toLowerCase() != 'pending';
  }

  static Duration clampPosition(Duration position, Duration duration) {
    if (duration <= Duration.zero || position < Duration.zero) {
      return Duration.zero;
    }
    return position > duration ? duration : position;
  }

  /// A ten-second skip always means ten seconds in the recording's timeline.
  static Duration seekRelative({
    required Duration position,
    required Duration delta,
    required Duration duration,
  }) => clampPosition(clampPosition(position, duration) + delta, duration);

  /// Reject the complete map if any boundary is missing, duplicated or invalid.
  static bool hasChapterTimings(ReliefStory story, Duration duration) {
    if (!hasDeliveryMetadata(story) ||
        duration <= Duration.zero ||
        story.chapters.isEmpty) {
      return false;
    }
    final ids = <String>{};
    Duration? previous;
    for (final chapter in story.chapters) {
      final start = chapter.start;
      if (chapter.id.trim().isEmpty ||
          chapter.title.trim().isEmpty ||
          !ids.add(chapter.id) ||
          start == null ||
          start < Duration.zero ||
          start >= duration) {
        return false;
      }
      if (previous == null) {
        if (start != Duration.zero) return false;
      } else if (start <= previous) {
        return false;
      }
      previous = start;
    }
    return true;
  }

  static Duration? chapterStart(
    ReliefStory story,
    String chapterId,
    Duration duration,
  ) {
    if (!hasChapterTimings(story, duration)) return null;
    for (final chapter in story.chapters) {
      if (chapter.id == chapterId) return chapter.start;
    }
    return null;
  }
}
