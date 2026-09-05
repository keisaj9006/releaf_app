import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Reusable visual identities for editorial Releaf content.
///
/// Each variant shares the same organic Living Form construction while using
/// a distinct atmosphere, placement, ribbon, and particle field.
enum ReleafArtworkVariant {
  ambient,
  situational,
  breath,
  noBreath,
  lifeUpgrade,
  grounding,
  calm,
  focus,
  deepReset,
}

class ReleafArtwork extends StatelessWidget {
  const ReleafArtwork({
    super.key,
    required this.variant,
    this.intensity = 1,
  });

  final ReleafArtworkVariant variant;
  final double intensity;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: CustomPaint(
        painter: _ReleafArtworkPainter(
          variant: variant,
          intensity: intensity.clamp(0.0, 1.0).toDouble(),
        ),
        child: const SizedBox.expand(),
      ),
    );
  }
}

/// The signature Releaf Living Form without an artwork background.
///
/// It is deliberately asymmetric and layered so it can later become the
/// foundation for breathing and audio-reactive motion without replacing the
/// visual language introduced here.
class ReleafLivingForm extends StatelessWidget {
  const ReleafLivingForm({
    super.key,
    this.variant = ReleafArtworkVariant.ambient,
    this.opacity = 1,
  });

  final ReleafArtworkVariant variant;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: CustomPaint(
        painter: _LivingFormPainter(
          palette: _paletteFor(variant),
          phase: variant.index * 0.71,
          opacity: opacity.clamp(0.0, 1.0).toDouble(),
        ),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _ReleafArtworkPainter extends CustomPainter {
  const _ReleafArtworkPainter({
    required this.variant,
    required this.intensity,
  });

  final ReleafArtworkVariant variant;
  final double intensity;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;

    final palette = _paletteFor(variant);
    final rect = Offset.zero & size;
    final background = Paint()
      ..shader = LinearGradient(
        begin: _backgroundBegin(variant),
        end: _backgroundEnd(variant),
        colors: [palette.background, palette.backgroundEnd],
      ).createShader(rect);
    canvas.drawRect(rect, background);

    _drawLightField(canvas, size, palette, intensity);
    _drawRibbon(canvas, size, palette, variant.index, intensity);
    _drawLivingForm(
      canvas,
      size,
      palette,
      phase: variant.index * 0.71,
      opacity: intensity,
    );
    _drawParticles(canvas, size, palette, variant.index, intensity);
    _drawVignette(canvas, rect);
  }

  @override
  bool shouldRepaint(covariant _ReleafArtworkPainter oldDelegate) {
    return variant != oldDelegate.variant || intensity != oldDelegate.intensity;
  }
}

class _LivingFormPainter extends CustomPainter {
  const _LivingFormPainter({
    required this.palette,
    required this.phase,
    required this.opacity,
  });

  final _ArtworkPalette palette;
  final double phase;
  final double opacity;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    _drawLivingForm(
      canvas,
      size,
      palette,
      phase: phase,
      opacity: opacity,
    );
  }

  @override
  bool shouldRepaint(covariant _LivingFormPainter oldDelegate) {
    return palette != oldDelegate.palette ||
        phase != oldDelegate.phase ||
        opacity != oldDelegate.opacity;
  }
}

void _drawLightField(
  Canvas canvas,
  Size size,
  _ArtworkPalette palette,
  double intensity,
) {
  final center = Offset(size.width * 0.72, size.height * 0.30);
  final radius = size.longestSide * 0.62;
  final paint = Paint()
    ..shader = RadialGradient(
      colors: [
        palette.primary.withValues(alpha: 0.25 * intensity),
        palette.secondary.withValues(alpha: 0.08 * intensity),
        Colors.transparent,
      ],
      stops: const [0, 0.42, 1],
    ).createShader(Rect.fromCircle(center: center, radius: radius));
  canvas.drawRect(Offset.zero & size, paint);
}

void _drawLivingForm(
  Canvas canvas,
  Size size,
  _ArtworkPalette palette, {
  required double phase,
  required double opacity,
}) {
  final width = size.width;
  final height = size.height;
  final drift = math.sin(phase) * width * 0.035;
  final lift = math.cos(phase * 0.83) * height * 0.025;

  final path = Path()
    ..moveTo(width * 0.20 + drift, height * 0.60 + lift)
    ..cubicTo(
      width * 0.10,
      height * 0.31,
      width * 0.33,
      height * 0.08,
      width * 0.59 + drift,
      height * 0.18,
    )
    ..cubicTo(
      width * 0.88,
      height * 0.27,
      width * 0.94,
      height * 0.58,
      width * 0.72,
      height * 0.77 + lift,
    )
    ..cubicTo(
      width * 0.53,
      height * 0.94,
      width * 0.27,
      height * 0.88,
      width * 0.20 + drift,
      height * 0.60 + lift,
    )
    ..close();

  canvas.drawPath(
    path,
    Paint()
      ..color = palette.primary.withValues(alpha: 0.24 * opacity)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, height * 0.13),
  );

  final bounds = path.getBounds();
  canvas.drawPath(
    path,
    Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.34, -0.44),
        radius: 1.08,
        colors: [
          palette.highlight.withValues(alpha: 0.82 * opacity),
          palette.primary.withValues(alpha: 0.56 * opacity),
          palette.secondary.withValues(alpha: 0.24 * opacity),
          palette.backgroundEnd.withValues(alpha: 0.10 * opacity),
        ],
        stops: const [0, 0.31, 0.72, 1],
      ).createShader(bounds),
  );

  final membrane = Path()
    ..moveTo(width * 0.29, height * 0.54)
    ..cubicTo(
      width * 0.38,
      height * 0.26,
      width * 0.68,
      height * 0.22,
      width * 0.79,
      height * 0.45,
    )
    ..cubicTo(
      width * 0.67,
      height * 0.40,
      width * 0.48,
      height * 0.52,
      width * 0.29,
      height * 0.54,
    );
  canvas.drawPath(
    membrane,
    Paint()
      ..shader = LinearGradient(
        colors: [
          palette.highlight.withValues(alpha: 0.08 * opacity),
          palette.highlight.withValues(alpha: 0.56 * opacity),
          Colors.transparent,
        ],
      ).createShader(bounds)
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(1.0, height * 0.012)
      ..strokeCap = StrokeCap.round,
  );

  final innerPath = Path()
    ..moveTo(width * 0.35, height * 0.69)
    ..cubicTo(
      width * 0.48,
      height * 0.56,
      width * 0.67,
      height * 0.57,
      width * 0.75,
      height * 0.67,
    );
  canvas.drawPath(
    innerPath,
    Paint()
      ..color = palette.highlight.withValues(alpha: 0.18 * opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(0.8, height * 0.006)
      ..strokeCap = StrokeCap.round,
  );
}

void _drawRibbon(
  Canvas canvas,
  Size size,
  _ArtworkPalette palette,
  int seed,
  double intensity,
) {
  final inverted = seed.isOdd;
  final path = Path()
    ..moveTo(-size.width * 0.08, size.height * (inverted ? 0.24 : 0.78))
    ..cubicTo(
      size.width * 0.24,
      size.height * (inverted ? 0.72 : 0.38),
      size.width * 0.66,
      size.height * (inverted ? 0.18 : 0.88),
      size.width * 1.08,
      size.height * (inverted ? 0.60 : 0.28),
    );
  final bounds = Offset.zero & size;
  canvas.drawPath(
    path,
    Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.transparent,
          palette.secondary.withValues(alpha: 0.16 * intensity),
          palette.highlight.withValues(alpha: 0.34 * intensity),
          Colors.transparent,
        ],
      ).createShader(bounds)
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(1.0, size.height * 0.014)
      ..strokeCap = StrokeCap.round
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, size.height * 0.018),
  );
}

void _drawParticles(
  Canvas canvas,
  Size size,
  _ArtworkPalette palette,
  int seed,
  double intensity,
) {
  for (var index = 0; index < 24; index++) {
    final x = ((index * 37 + seed * 19) % 101) / 101 * size.width;
    final y = ((index * 53 + seed * 11) % 97) / 97 * size.height;
    final radius = index % 5 == 0 ? 1.2 : 0.55;
    final alpha = (index % 4 == 0 ? 0.20 : 0.08) * intensity;
    canvas.drawCircle(
      Offset(x, y),
      radius,
      Paint()..color = palette.highlight.withValues(alpha: alpha),
    );
  }
}

void _drawVignette(Canvas canvas, Rect rect) {
  canvas.drawRect(
    rect,
    Paint()
      ..shader = RadialGradient(
        radius: 0.92,
        colors: [Colors.transparent, Colors.black.withValues(alpha: 0.38)],
        stops: const [0.46, 1],
      ).createShader(rect),
  );
}

Alignment _backgroundBegin(ReleafArtworkVariant variant) {
  return variant.index.isEven ? Alignment.topLeft : Alignment.topRight;
}

Alignment _backgroundEnd(ReleafArtworkVariant variant) {
  return variant.index.isEven ? Alignment.bottomRight : Alignment.bottomLeft;
}

@immutable
class _ArtworkPalette {
  const _ArtworkPalette({
    required this.background,
    required this.backgroundEnd,
    required this.primary,
    required this.secondary,
    required this.highlight,
  });

  final Color background;
  final Color backgroundEnd;
  final Color primary;
  final Color secondary;
  final Color highlight;
}

_ArtworkPalette _paletteFor(ReleafArtworkVariant variant) {
  return switch (variant) {
    ReleafArtworkVariant.ambient => const _ArtworkPalette(
      background: Color(0xFF0A1510),
      backgroundEnd: Color(0xFF07100C),
      primary: Color(0xFF739A82),
      secondary: Color(0xFF315C4A),
      highlight: Color(0xFFC4D7C7),
    ),
    ReleafArtworkVariant.situational => const _ArtworkPalette(
      background: Color(0xFF241712),
      backgroundEnd: Color(0xFF100E0C),
      primary: Color(0xFFC07859),
      secondary: Color(0xFF6C8D72),
      highlight: Color(0xFFF0C5A2),
    ),
    ReleafArtworkVariant.breath => const _ArtworkPalette(
      background: Color(0xFF09202A),
      backgroundEnd: Color(0xFF071214),
      primary: Color(0xFF4CA8A1),
      secondary: Color(0xFF315B7B),
      highlight: Color(0xFFB9E2D7),
    ),
    ReleafArtworkVariant.noBreath => const _ArtworkPalette(
      background: Color(0xFF12251C),
      backgroundEnd: Color(0xFF0A120E),
      primary: Color(0xFF78A37F),
      secondary: Color(0xFF495C32),
      highlight: Color(0xFFD2D7A9),
    ),
    ReleafArtworkVariant.lifeUpgrade => const _ArtworkPalette(
      background: Color(0xFF17182A),
      backgroundEnd: Color(0xFF0C0D16),
      primary: Color(0xFF7778AA),
      secondary: Color(0xFFB08A62),
      highlight: Color(0xFFE7D5B6),
    ),
    ReleafArtworkVariant.grounding => const _ArtworkPalette(
      background: Color(0xFF14251D),
      backgroundEnd: Color(0xFF0A120E),
      primary: Color(0xFF7FA283),
      secondary: Color(0xFF8A704F),
      highlight: Color(0xFFD7D7B4),
    ),
    ReleafArtworkVariant.calm => const _ArtworkPalette(
      background: Color(0xFF0B2230),
      backgroundEnd: Color(0xFF091316),
      primary: Color(0xFF5CA6A4),
      secondary: Color(0xFF486C91),
      highlight: Color(0xFFC0E3DC),
    ),
    ReleafArtworkVariant.focus => const _ArtworkPalette(
      background: Color(0xFF181B2A),
      backgroundEnd: Color(0xFF0C1014),
      primary: Color(0xFF7C86A8),
      secondary: Color(0xFF9B7D55),
      highlight: Color(0xFFE2D6B6),
    ),
    ReleafArtworkVariant.deepReset => const _ArtworkPalette(
      background: Color(0xFF221721),
      backgroundEnd: Color(0xFF0C0D0E),
      primary: Color(0xFF8B6E84),
      secondary: Color(0xFFA68A5C),
      highlight: Color(0xFFE9D1AB),
    ),
  };
}
