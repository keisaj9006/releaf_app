import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:releaf_app/features/brain/presentation/brain_game_editorial_artwork.dart';

void main() {
  const expected = <String, String>{
    'memory': 'assets/art/brain/memory.webp',
    'labyrinth': 'assets/art/brain/labyrinth.webp',
    'broken_mirror': 'assets/art/brain/broken_mirror.webp',
    'pattern_logic': 'assets/art/brain/pattern_logic.webp',
    'sequence_echo': 'assets/art/brain/sequence_echo.webp',
    'signal_scan': 'assets/art/brain/signal_scan.webp',
    'trail_switch': 'assets/art/brain/trail_switch.webp',
    'tower_plan': 'assets/art/brain/tower_plan.webp',
  };

  test('approved Brain artwork maps one-to-one to the intended game ids', () {
    for (final entry in expected.entries) {
      expect(
        brainGameEditorialAssetPath(entry.key),
        entry.value,
        reason: entry.key,
      );
    }
  });

  test('games without an approved dedicated image keep procedural artwork', () {
    for (final id in [
      'math_race',
      'rule_shift',
      'n_back',
      'spatial_span',
      'mental_rotation',
      'symbol_code',
      'color_conflict',
    ]) {
      expect(brainGameEditorialAssetPath(id), isNull, reason: id);
    }
  });

  test('every mapped Brain editorial asset is bundled as WebP', () {
    for (final path in expected.values) {
      expect(path, endsWith('.webp'));
      expect(File(path).existsSync(), isTrue, reason: path);
    }
  });
}
