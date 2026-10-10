import 'package:flutter/material.dart';

/// The ten approved category illustrations. Individual game and audio-track
/// artwork remains separate; this enum is not a complete content catalogue.
enum ReliefEditorialAsset {
  reset('reset'),
  breathe('breathe'),
  bodyScan('body_scan'),
  tensionRelief('tension_relief'),
  sleep('sleep'),
  sleepStories('sleep_stories'),
  soundscapes('soundscapes'),
  meditate('meditate'),
  brainGames('brain_games'),
  emergencyCalm('emergency_calm');

  const ReliefEditorialAsset(this.fileName);

  final String fileName;

  String get assetPath => 'assets/art/relief/$fileName.webp';
}

/// Decorative, offline artwork only. Labels, access gates and gesture handlers
/// stay with the existing card. Live breathing/movement visuals are not changed.
class ReliefEditorialImage extends StatelessWidget {
  const ReliefEditorialImage({
    super.key,
    required this.asset,
    required this.fallback,
    this.intensity = 1,
    this.alignment = const Alignment(0, -0.1),
  });

  final ReliefEditorialAsset asset;
  final Widget fallback;
  final double intensity;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    final level = intensity.isFinite
        ? intensity.clamp(0.0, 1.0).toDouble()
        : 1.0;
    return ExcludeSemantics(
      child: level == 0
          ? fallback
          : ClipRect(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Opacity(
                    opacity: level,
                    child: Image.asset(
                      asset.assetPath,
                      fit: BoxFit.cover,
                      alignment: alignment,
                      cacheWidth: 1024,
                      filterQuality: FilterQuality.medium,
                      excludeFromSemantics: true,
                      frameBuilder: (context, child, frame, synchronous) {
                        return frame == null ? fallback : child;
                      },
                      errorBuilder: (context, error, stackTrace) => fallback,
                    ),
                  ),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0x05000000), Color(0x47040910)],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
