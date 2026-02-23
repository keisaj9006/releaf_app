// FILE: lib/features/brain/data/game_registry.dart
import 'package:flutter/material.dart';

class BrainGameMeta {
  final String id;
  final String title;
  final IconData icon;
  final bool enabled;

  const BrainGameMeta({
    required this.id,
    required this.title,
    required this.icon,
    this.enabled = true,
  });
}

/// Jedno źródło prawdy dla listy gier w Brain.
const brainGames = <BrainGameMeta>[
  BrainGameMeta(id: 'memory', title: 'Memory', icon: Icons.grid_view),
  BrainGameMeta(id: 'labyrinth', title: 'Labyrinth', icon: Icons.route),
  BrainGameMeta(id: 'math_race', title: 'Math Race', icon: Icons.calculate),

  // Legacy (jeśli chcesz utrzymać tę grę zanim ją przeniesiemy na czysto)
  BrainGameMeta(id: 'broken_mirror', title: 'Broken Mirror', icon: Icons.auto_fix_high),
];