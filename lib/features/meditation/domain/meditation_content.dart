enum MeditationAccessTier { free, premium }

enum MeditationCategory {
  startHere,
  anxiety,
  focus,
  mind,
  body,
  everyday,
  unguided,
}

class MeditationStep {
  const MeditationStep({
    required this.label,
    required this.guidance,
    required this.durationSeconds,
    this.spokenGuidance,
    this.narrationAssetPath,
  });

  final String label;
  final String guidance;
  final int durationSeconds;

  /// Optional longer narration written to be heard rather than read.
  /// Captions keep using [guidance] so the screen stays concise.
  final String? spokenGuidance;

  /// Optional pre-rendered Releaf Guide narration for this step.
  /// When present, the player uses this instead of device TTS.
  final String? narrationAssetPath;
}

class MeditationContent {
  const MeditationContent({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.durationSeconds,
    required this.category,
    required this.accessTier,
    required this.steps,
    this.backgroundSoundId,
    this.backgroundSoundVolume = 0.20,
    this.seriesId,
    this.seriesOrder,
    this.unguided = false,
  }) : assert(
          backgroundSoundVolume >= 0 && backgroundSoundVolume <= 1,
          'backgroundSoundVolume must be between 0 and 1',
        );

  final String id;
  final String title;
  final String subtitle;
  final int durationSeconds;
  final MeditationCategory category;
  final MeditationAccessTier accessTier;
  final List<MeditationStep> steps;

  /// Optional sound track from the canonical Releaf sound catalog.
  final String? backgroundSoundId;

  /// Session-specific mix level for the ambient layer.
  final double backgroundSoundVolume;

  /// Optional editorial collection/course identifier.
  final String? seriesId;

  /// One-based order inside an editorial collection/course.
  final int? seriesOrder;

  final bool unguided;

  bool get isPremium => accessTier == MeditationAccessTier.premium;
}
