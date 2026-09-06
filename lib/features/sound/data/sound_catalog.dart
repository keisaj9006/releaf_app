import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/sound_content.dart';

final soundCatalogProvider = Provider<SoundCatalog>((ref) {
  return const SoundCatalog();
});

/// Canonical catalog for real audio currently bundled with Releaf.
///
/// More specific soundscapes (rain, ocean, forest, brown noise, stories)
/// should only be added when the corresponding licensed/owned audio exists.
class SoundCatalog {
  const SoundCatalog();

  static const List<SoundContent> _tracks = [
    SoundContent(
      id: 'releaf-atmosphere-01',
      title: 'Releaf Atmosphere I',
      subtitle: 'Long-form ambient audio from the current Releaf library.',
      assetPath: 'sounds/relief_01.mp3',
      category: SoundCategory.atmosphere,
      accessTier: SoundAccessTier.free,
    ),
    SoundContent(
      id: 'releaf-atmosphere-02',
      title: 'Releaf Atmosphere II',
      subtitle: 'A second ambient space from the current Releaf library.',
      assetPath: 'sounds/relief_02.mp3',
      category: SoundCategory.atmosphere,
      accessTier: SoundAccessTier.free,
    ),
    SoundContent(
      id: 'brown-noise',
      title: 'Brown Noise',
      subtitle:
          'Low-frequency synthetic noise with a softer high end for a steady sound bed.',
      assetPath: 'sounds/brown_noise.mp3',
      category: SoundCategory.noise,
      accessTier: SoundAccessTier.free,
    ),
    SoundContent(
      id: 'soft-rain',
      title: 'Soft Rain',
      subtitle:
          'A gentle original rain texture without thunder or sudden peaks.',
      assetPath: 'sounds/soft_rain.mp3',
      category: SoundCategory.weather,
      accessTier: SoundAccessTier.free,
    ),
    SoundContent(
      id: 'night-air',
      title: 'Night Air',
      subtitle:
          'A soft wind-like night texture without voices, wildlife or sharp events.',
      assetPath: 'sounds/night_air.mp3',
      category: SoundCategory.environment,
      accessTier: SoundAccessTier.free,
    ),
    SoundContent(
      id: 'white-noise',
      title: 'White Noise',
      subtitle:
          'An even full-spectrum synthetic noise bed for a consistent masking layer.',
      assetPath: 'sounds/white_noise.mp3',
      category: SoundCategory.noise,
      accessTier: SoundAccessTier.free,
    ),
    SoundContent(
      id: 'pink-noise',
      title: 'Pink Noise',
      subtitle:
          'A softer weighted synthetic noise bed with less high-frequency emphasis.',
      assetPath: 'sounds/pink_noise.mp3',
      category: SoundCategory.noise,
      accessTier: SoundAccessTier.free,
    ),
    SoundContent(
      id: 'deep-drift',
      title: 'Deep Drift',
      subtitle:
          'An original slow tonal pad with a low, steady harmonic movement.',
      assetPath: 'sounds/deep_drift.mp3',
      category: SoundCategory.atmosphere,
      accessTier: SoundAccessTier.free,
    ),
  ];

  List<SoundContent> getAll() => _tracks;

  SoundContent? getById(String id) {
    for (final track in _tracks) {
      if (track.id == id) return track;
    }
    return null;
  }
}
