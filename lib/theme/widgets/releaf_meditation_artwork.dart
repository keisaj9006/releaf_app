import 'dart:math' as math;

import 'package:flutter/material.dart';

enum ReleafMeditationArtworkVariant {
  editorial,
  anxiety,
  focus,
  body,
  compassion,
  everyday,
  timer,
}

class ReleafMeditationArtwork extends StatelessWidget {
  const ReleafMeditationArtwork({
    super.key,
    required this.variant,
    this.intensity = 1,
  });

  final ReleafMeditationArtworkVariant variant;
  final double intensity;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: CustomPaint(
        painter: _MeditationArtworkPainter(
          variant: variant,
          intensity: intensity.clamp(0.0, 1.0).toDouble(),
        ),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _MeditationArtworkPainter extends CustomPainter {
  const _MeditationArtworkPainter({
    required this.variant,
    required this.intensity,
  });

  final ReleafMeditationArtworkVariant variant;
  final double intensity;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;

    final palette = _paletteFor(variant);
    final rect = Offset.zero & size;

    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [palette.background, palette.backgroundEnd],
        ).createShader(rect),
    );

    _drawSoftField(canvas, size, palette, intensity);
    _drawFoldedLight(canvas, size, palette, intensity);
    _drawFineGrain(canvas, size, palette, variant.index, intensity);
    _drawVignette(canvas, rect);
  }

  @override
  bool shouldRepaint(covariant _MeditationArtworkPainter oldDelegate) {
    return variant != oldDelegate.variant || intensity != oldDelegate.intensity;
  }
}

void _drawSoftField(
  Canvas canvas,
  Size size,
  _MeditationPalette palette,
  double intensity,
) {
  final center = Offset(size.width * 0.68, size.height * 0.34);
  final radius = size.longestSide * 0.72;

  canvas.drawRect(
    Offset.zero & size,
    Paint()
      ..shader = RadialGradient(
        colors: [
          palette.glow.withValues(alpha: 0.25 * intensity),
          palette.secondary.withValues(alpha: 0.07 * intensity),
          Colors.transparent,
        ],
        stops: const [0, 0.42, 1],
      ).createShader(Rect.fromCircle(center: center, radius: radius)),
  );
}

void _drawFoldedLight(
  Canvas canvas,
  Size size,
  _MeditationPalette palette,
  double intensity,
) {
  for (var index = 0; index < 3; index++) {
    final y = size.height * (0.26 + index * 0.18);
    final amplitude = size.height * (0.10 - index * 0.012);
    final path = Path()
      ..moveTo(-size.width * 0.08, y + amplitude * 0.5)
      ..cubicTo(
        size.width * 0.22,
        y - amplitude,
        size.width * 0.54,
        y + amplitude,
        size.width * 0.83,
        y - amplitude * 0.35,
      )
      ..cubicTo(
        size.width * 1.04,
        y - amplitude * 0.72,
        size.width * 1.12,
        y + amplitude * 0.55,
        size.width * 1.08,
        y + amplitude,
      )
      ..lineTo(size.width * 1.08, y + amplitude * 1.7)
      ..cubicTo(
        size.width * 0.76,
        y + amplitude * 0.92,
        size.width * 0.38,
        y + amplitude * 1.9,
        -size.width * 0.08,
        y + amplitude * 1.15,
      )
      ..close();

    canvas.drawPath(
      path,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Colors.transparent,
            palette.primary.withValues(alpha: (0.08 + index * 0.02) * intensity),
            palette.highlight.withValues(alpha: (0.14 - index * 0.025) * intensity),
            Colors.transparent,
          ],
          stops: const [0, 0.34, 0.66, 1],
        ).createShader(Offset.zero & size)
        ..maskFilter = MaskFilter.blur(
          BlurStyle.normal,
          12 + index * 4,
        ),
    );
  }

  final line = Path()
    ..moveTo(size.width * 0.18, size.height * 0.62)
    ..cubicTo(
      size.width * 0.42,
      size.height * 0.48,
      size.width * 0.63,
      size.height * 0.72,
      size.width * 0.92,
      size.height * 0.54,
    );

  canvas.drawPath(
    line,
    Paint()
      ..color = palette.highlight.withValues(alpha: 0.20 * intensity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..strokeCap = StrokeCap.round,
  );
}

void _drawFineGrain(
  Canvas canvas,
  Size size,
  _MeditationPalette palette,
  int seed,
  double intensity,
) {
  for (var index = 0; index < 34; index++) {
    final x = ((index * 43 + seed * 17) % 101) / 101 * size.width;
    final y = ((index * 61 + seed * 13) % 97) / 97 * size.height;
    final radius = index % 7 == 0 ? 0.95 : 0.45;
    canvas.drawCircle(
      Offset(x, y),
      radius,
      Paint()
        ..color = palette.highlight.withValues(
          alpha: (index % 5 == 0 ? 0.12 : 0.035) * intensity,
        ),
    );
  }

  final softLinePaint = Paint()
    ..color = palette.primary.withValues(alpha: 0.035 * intensity)
    ..strokeWidth = 1;

  for (var index = 0; index < 4; index++) {
    final offset = math.sin(index * 1.7) * size.width * 0.06;
    canvas.drawLine(
      Offset(size.width * (0.10 + index * 0.19), -20),
      Offset(size.width * (0.42 + index * 0.19) + offset, size.height + 20),
      softLinePaint,
    );
  }
}

void _drawVignette(Canvas canvas, Rect rect) {
  canvas.drawRect(
    rect,
    Paint()
      ..shader = RadialGradient(
        radius: 0.95,
        colors: [
          Colors.transparent,
          Colors.black.withValues(alpha: 0.52),
        ],
        stops: const [0.48, 1],
      ).createShader(rect),
  );
}

@immutable
class _MeditationPalette {
  const _MeditationPalette({
    required this.background,
    required this.backgroundEnd,
    required this.primary,
    required this.secondary,
    required this.highlight,
    required this.glow,
  });

  final Color background;
  final Color backgroundEnd;
  final Color primary;
  final Color secondary;
  final Color highlight;
  final Color glow;
}

_MeditationPalette _paletteFor(ReleafMeditationArtworkVariant variant) {
  return switch (variant) {
    ReleafMeditationArtworkVariant.editorial => const _MeditationPalette(
        background: Color(0xFF15131B),
        backgroundEnd: Color(0xFF0B1010),
        primary: Color(0xFF8C819E),
        secondary: Color(0xFF728D83),
        highlight: Color(0xFFE5DDCF),
        glow: Color(0xFFB3A6BE),
      ),
    ReleafMeditationArtworkVariant.anxiety => const _MeditationPalette(
        background: Color(0xFF111A1A),
        backgroundEnd: Color(0xFF090E0E),
        primary: Color(0xFF6D9C98),
        secondary: Color(0xFF7E8797),
        highlight: Color(0xFFD7E5DE),
        glow: Color(0xFF83ADA7),
      ),
    ReleafMeditationArtworkVariant.focus => const _MeditationPalette(
        background: Color(0xFF131624),
        backgroundEnd: Color(0xFF090C12),
        primary: Color(0xFF7D89AE),
        secondary: Color(0xFF5E807B),
        highlight: Color(0xFFDDE1EF),
        glow: Color(0xFF909BC2),
      ),
    ReleafMeditationArtworkVariant.body => const _MeditationPalette(
        background: Color(0xFF1A1712),
        backgroundEnd: Color(0xFF0D0C0A),
        primary: Color(0xFF9B8970),
        secondary: Color(0xFF758379),
        highlight: Color(0xFFE9DEC8),
        glow: Color(0xFFB8A58A),
      ),
    ReleafMeditationArtworkVariant.compassion => const _MeditationPalette(
        background: Color(0xFF1B1418),
        backgroundEnd: Color(0xFF0D0A0C),
        primary: Color(0xFFA07B87),
        secondary: Color(0xFF7B7D8D),
        highlight: Color(0xFFEAD9DE),
        glow: Color(0xFFB8939E),
      ),
    ReleafMeditationArtworkVariant.everyday => const _MeditationPalette(
        background: Color(0xFF141A15),
        backgroundEnd: Color(0xFF0A0E0B),
        primary: Color(0xFF7E9A83),
        secondary: Color(0xFF7E8995),
        highlight: Color(0xFFDDE5D8),
        glow: Color(0xFF91AA94),
      ),
    ReleafMeditationArtworkVariant.timer => const _MeditationPalette(
        background: Color(0xFF11171B),
        backgroundEnd: Color(0xFF090D0F),
        primary: Color(0xFF718996),
        secondary: Color(0xFF717D89),
        highlight: Color(0xFFD9E1E5),
        glow: Color(0xFF849AA5),
      ),
  };
}
