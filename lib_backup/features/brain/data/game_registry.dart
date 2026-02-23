// FILE: lib/features/brain/data/game_registry.dart
import 'package:flutter/material.dart';

import '../../../games/math_race/math_race_screen.dart';

/// Signature of a function that builds a game widget.
typedef BrainGameBuilder = Widget Function(BuildContext context);

/// A registry mapping game identifiers to builder functions. It allows
/// the app to construct a game screen by its identifier.
final Map<String, BrainGameBuilder> gameRegistry = {
  'math-race': (context) => const MathRaceScreen(),
};