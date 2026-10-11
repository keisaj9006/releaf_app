import 'package:flutter/material.dart';

String? brainGameEditorialAssetPath(String gameId) => switch (gameId) {
  'memory' => 'assets/art/brain/memory.webp',
  'labyrinth' => 'assets/art/brain/labyrinth.webp',
  'broken_mirror' => 'assets/art/brain/broken_mirror.webp',
  'pattern_logic' => 'assets/art/brain/pattern_logic.webp',
  'sequence_echo' => 'assets/art/brain/sequence_echo.webp',
  'signal_scan' => 'assets/art/brain/signal_scan.webp',
  'trail_switch' => 'assets/art/brain/trail_switch.webp',
  'tower_plan' => 'assets/art/brain/tower_plan.webp',
  _ => null,
};

class BrainGameEditorialArtwork extends StatelessWidget {
  const BrainGameEditorialArtwork({
    super.key,
    required this.gameId,
    required this.fallback,
    this.intensity = 1,
    this.alignment = Alignment.center,
  });

  final String gameId;
  final Widget fallback;
  final double intensity;
  final AlignmentGeometry alignment;

  @override
  Widget build(BuildContext context) {
    final assetPath = brainGameEditorialAssetPath(gameId);
    if (assetPath == null) return fallback;

    return ExcludeSemantics(
      child: Stack(
        fit: StackFit.expand,
        children: [
          fallback,
          Opacity(
            opacity: intensity.clamp(0.0, 1.0).toDouble(),
            child: Image.asset(
              assetPath,
              fit: BoxFit.cover,
              alignment: alignment,
              filterQuality: FilterQuality.medium,
              errorBuilder: (context, error, stackTrace) => fallback,
            ),
          ),
        ],
      ),
    );
  }
}
