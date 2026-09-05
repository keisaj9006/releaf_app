// FILE: lib/features/brain/data/game_registry.dart
import 'package:flutter/material.dart';

enum BrainGameGroup {
  memory,
  attention,
  reasoning,
  spatial,
}

class BrainGameMeta {
  final String id;
  final String title;
  final IconData icon;
  final BrainGameGroup group;
  final bool enabled;
  final bool hasDifficultyLevels;

  const BrainGameMeta({
    required this.id,
    required this.title,
    required this.icon,
    required this.group,
    this.enabled = true,
    this.hasDifficultyLevels = false,
  });
}

/// Jedno źródło prawdy dla listy gier w Brain.
const brainGames = <BrainGameMeta>[
  BrainGameMeta(
    id: 'memory',
    title: 'Memory',
    icon: Icons.grid_view,
    group: BrainGameGroup.memory,
  ),
  BrainGameMeta(
    id: 'labyrinth',
    title: 'Labyrinth',
    icon: Icons.route,
    group: BrainGameGroup.spatial,
  ),
  BrainGameMeta(
    id: 'math_race',
    title: 'Math Race',
    icon: Icons.calculate,
    group: BrainGameGroup.reasoning,
  ),

  // Legacy (jeśli chcesz utrzymać tę grę zanim ją przeniesiemy na czysto)
  BrainGameMeta(
    id: 'broken_mirror',
    title: 'Broken Mirror',
    icon: Icons.auto_fix_high,
    group: BrainGameGroup.spatial,
  ),
  BrainGameMeta(
    id: 'rule_shift',
    title: 'Rule Shift',
    icon: Icons.swap_horiz_rounded,
    group: BrainGameGroup.attention,
  ),
  BrainGameMeta(
    id: 'sequence_echo',
    title: 'Sequence Echo',
    icon: Icons.scatter_plot_rounded,
    group: BrainGameGroup.memory,
    hasDifficultyLevels: true,
  ),
  BrainGameMeta(
    id: 'color_conflict',
    title: 'Color Conflict',
    icon: Icons.palette_outlined,
    group: BrainGameGroup.attention,
    hasDifficultyLevels: true,
  ),
  BrainGameMeta(
    id: 'pattern_logic',
    title: 'Pattern Logic',
    icon: Icons.extension_rounded,
    group: BrainGameGroup.reasoning,
    hasDifficultyLevels: true,
  ),
  BrainGameMeta(
    id: 'signal_scan',
    title: 'Signal Scan',
    icon: Icons.center_focus_strong_rounded,
    group: BrainGameGroup.attention,
    hasDifficultyLevels: true,
  ),
];