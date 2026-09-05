enum SoundAccessTier { free, premium }

enum SoundCategory { atmosphere }

class SoundContent {
  const SoundContent({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.assetPath,
    required this.category,
    required this.accessTier,
  });

  final String id;
  final String title;
  final String subtitle;

  /// Path relative to Flutter's asset bundle root, e.g. sounds/file.mp3.
  final String assetPath;
  final SoundCategory category;
  final SoundAccessTier accessTier;

  bool get isPremium => accessTier == SoundAccessTier.premium;
}
