import 'dart:math' as math;

import 'package:flutter/material.dart';

enum ReleafSoundArtworkVariant {
  field,
  atmosphereOne,
  atmosphereTwo,
}

class ReleafSoundArtwork extends StatelessWidget {
  const ReleafSoundArtwork({
    super.key,
    required this.variant,
    this.intensity = 1,
  });

  final ReleafSoundArtworkVariant variant;
  final double intensity;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: CustomPaint(
        painter: _ReleafSoundArtworkPainter(
          variant: variant,
          intensity: intensity.clamp(0.0, 1.0).toDouble(),
        ),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _ReleafSoundArtworkPainter extends CustomPainter {
  const _ReleafSoundArtworkPainter({
    required this.variant,
    required this.intensity,
  });

  final ReleafSoundArtworkVariant variant;
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
          colors: [
            palette.background,
            palette.backgroundEnd,
          ],
        ).createShader(rect),
    );

    _drawGlow(canvas, size, palette, intensity);
    _drawWaveField(canvas, size, palette, intensity);
    _drawSpectralBars(canvas, size, palette, intensity);
    _drawParticles(canvas, size, palette, variant.index, intensity);
    _drawVignette(canvas, rect);
  }

  @override
  bool shouldRepaint(covariant _ReleafSoundArtworkPainter oldDelegate) {
    return variant != oldDelegate.variant || intensity != oldDelegate.intensity;
  }
}

void _drawGlow(
  Canvas canvas,
  Size size,
  _SoundPalette palette,
  double intensity,
) {
  final center = Offset(size.width * 0.72, size.height * 0.30);
  canvas.drawRect(
    Offset.zero & size,
    Paint()
      ..shader = RadialGradient(
        colors: [
          palette.glow.withValues(alpha: 0.30 * intensity),
          palette.primary.withValues(alpha: 0.07 * intensity),
          Colors.transparent,
        ],
        stops: const [0, 0.42, 1],
      ).createShader(
        Rect.fromCircle(
          center: center,
          radius: size.longestSide * 0.72,
        ),
      ),
  );
}

void _drawWaveField(
  Canvas canvas,
  Size size,
  _SoundPalette palette,
  double intensity,
) {
  for (var band = 0; band < 5; band++) {
    final path = Path();
    final centerY = size.height * (0.34 + band * 0.09);
    final amplitude = size.height * (0.024 + band * 0.005);
    final frequency = 1.7 + band * 0.34;

    for (var step = 0; step <= 54; step++) {
      final t = step / 54;
      final x = size.width * t;
      final y = centerY +
          math.sin((t * math.pi * 2 * frequency) + band * 0.7) * amplitude +
          math.sin((t * math.pi * 5) + band) * amplitude * 0.22;

      if (step == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = band == 2 ? 1.5 : 1
        ..strokeCap = StrokeCap.round
        ..color = (band.isEven ? palette.primary : palette.secondary)
            .withValues(alpha: (0.10 + band * 0.018) * intensity),
    );
  }
}

void _drawSpectralBars(
  Canvas canvas,
  Size size,
  _SoundPalette palette,
  double intensity,
) {
  final baseline = size.height * 0.78;
  final barWidth = math.max(1.0, size.width / 92);

  for (var index = 0; index < 34; index++) {
    final phase = index / 33;
    final envelope = math.sin(phase * math.pi);
    final modulation =
        0.42 + 0.58 * ((math.sin(index * 1.37) + 1) / 2);
    final height = size.height * 0.18 * envelope * modulation;
    final x = size.width * (0.12 + phase * 0.76);

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          x,
          baseline - height,
          barWidth,
          height,
        ),
        const Radius.circular(2),
      ),
      Paint()
        ..color = palette.highlight.withValues(
          alpha: (0.10 + envelope * 0.16) * intensity,
        ),
    );
  }
}

void _drawParticles(
  Canvas canvas,
  Size size,
  _SoundPalette palette,
  int seed,
  double intensity,
) {
  for (var index = 0; index < 26; index++) {
    final x = ((index * 47 + seed * 19) % 101) / 101 * size.width;
    final y = ((index * 31 + seed * 23) % 89) / 89 * size.height;
    final radius = index % 6 == 0 ? 1.1 : 0.45;

    canvas.drawCircle(
      Offset(x, y),
      radius,
      Paint()
        ..color = palette.highlight.withValues(
          alpha: (index % 4 == 0 ? 0.18 : 0.06) * intensity,
        ),
    );
  }
}

void _drawVignette(Canvas canvas, Rect rect) {
  canvas.drawRect(
    rect,
    Paint()
      ..shader = RadialGradient(
        radius: 0.96,
        colors: [
          Colors.transparent,
          Colors.black.withValues(alpha: 0.50),
        ],
        stops: const [0.48, 1],
      ).createShader(rect),
  );
}

@immutable
class _SoundPalette {
  const _SoundPalette({
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

_SoundPalette _paletteFor(ReleafSoundArtworkVariant variant) {
  return switch (variant) {
    ReleafSoundArtworkVariant.field => const _SoundPalette(
        background: Color(0xFF061014),
        backgroundEnd: Color(0xFF081117),
        primary: Color(0xFF6CAAB4),
        secondary: Color(0xFF577A91),
        highlight: Color(0xFFC9E0E4),
        glow: Color(0xFF4C8994),
      ),
    ReleafSoundArtworkVariant.atmosphereOne => const _SoundPalette(
        background: Color(0xFF071417),
        backgroundEnd: Color(0xFF091016),
        primary: Color(0xFF72B7B4),
        secondary: Color(0xFF5D8DA4),
        highlight: Color(0xFFD2E8E7),
        glow: Color(0xFF4FA29E),
      ),
    ReleafSoundArtworkVariant.atmosphereTwo => const _SoundPalette(
        background: Color(0xFF0A0F1A),
        backgroundEnd: Color(0xFF10101B),
        primary: Color(0xFF7F96C0),
        secondary: Color(0xFF6C7899),
        highlight: Color(0xFFDCE2F3),
        glow: Color(0xFF657CA6),
      ),
  };
}
