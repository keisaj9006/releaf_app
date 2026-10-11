import 'package:flutter/material.dart';

/// Displays a production image asset while preserving an existing artwork
/// widget as a safe fallback if an asset cannot be decoded at runtime.
class ReleafAssetArtwork extends StatelessWidget {
  const ReleafAssetArtwork({
    super.key,
    required this.assetPath,
    this.alignment = Alignment.center,
    this.fit = BoxFit.cover,
    this.fallback,
  });

  final String assetPath;
  final AlignmentGeometry alignment;
  final BoxFit fit;
  final Widget? fallback;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: Image.asset(
        assetPath,
        fit: fit,
        alignment: alignment,
        filterQuality: FilterQuality.medium,
        errorBuilder: (context, error, stackTrace) =>
            fallback ?? const SizedBox.expand(),
      ),
    );
  }
}
