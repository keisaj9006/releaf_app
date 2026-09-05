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
  ];

  List<SoundContent> getAll() => _tracks;

  SoundContent? getById(String id) {
    for (final track in _tracks) {
      if (track.id == id) return track;
    }
    return null;
  }
}
