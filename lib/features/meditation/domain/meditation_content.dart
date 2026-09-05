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
    this.unguided = false,
  });

  final String id;
  final String title;
  final String subtitle;
  final int durationSeconds;
  final MeditationCategory category;
  final MeditationAccessTier accessTier;
  final List<MeditationStep> steps;
  final bool unguided;

  bool get isPremium => accessTier == MeditationAccessTier.premium;
}
