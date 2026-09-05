enum MeditationAccessTier { free, premium }

enum MeditationCategory {
  startHere,
  anxiety,
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
  });

  final String label;
  final String guidance;
  final int durationSeconds;
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

  final bool unguided;

  bool get isPremium => accessTier == MeditationAccessTier.premium;
}
