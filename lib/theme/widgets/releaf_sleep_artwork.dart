import 'dart:math' as math;

import 'package:flutter/material.dart';

enum ReleafSleepArtworkVariant {
  night,
  sound,
  racingMind,
  body,
  breath,
}

class ReleafSleepArtwork extends StatelessWidget {
  const ReleafSleepArtwork({
    super.key,
    required this.variant,
    this.intensity = 1,
  });

  final ReleafSleepArtworkVariant variant;
  final double intensity;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: CustomPaint(
        painter: _ReleafSleepArtworkPainter(
          variant: variant,
          intensity: intensity.clamp(0.0, 1.0).toDouble(),
        ),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _ReleafSleepArtworkPainter extends CustomPainter {
  const _ReleafSleepArtworkPainter({
    required this.variant,
    required this.intensity,
  });

  final ReleafSleepArtworkVariant variant;
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
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            palette.skyTop,
            palette.skyMid,
            palette.horizon,
            palette.ground,
          ],
          stops: const [0, 0.46, 0.72, 1],
        ).createShader(rect),
    );

    _drawNightGlow(canvas, size, palette, intensity);
    _drawStars(canvas, size, palette, variant.index, intensity);
    _drawHorizon(canvas, size, palette, intensity);
    _drawAtmosphere(canvas, size, palette, intensity);
    _drawVignette(canvas, rect);
  }

  @override
  bool shouldRepaint(covariant _ReleafSleepArtworkPainter oldDelegate) {
    return variant != oldDelegate.variant || intensity != oldDelegate.intensity;
  }
}

void _drawNightGlow(
  Canvas canvas,
  Size size,
  _SleepPalette palette,
  double intensity,
) {
  final center = Offset(size.width * 0.72, size.height * 0.24);
  final radius = size.longestSide * 0.54;

  canvas.drawRect(
    Offset.zero & size,
    Paint()
      ..shader = RadialGradient(
        colors: [
          palette.glow.withValues(alpha: 0.28 * intensity),
          palette.glow.withValues(alpha: 0.07 * intensity),
          Colors.transparent,
        ],
        stops: const [0, 0.42, 1],
      ).createShader(Rect.fromCircle(center: center, radius: radius)),
  );

  canvas.drawCircle(
    center,
    math.max(1.6, size.shortestSide * 0.008),
    Paint()..color = palette.star.withValues(alpha: 0.72 * intensity),
  );
}

void _drawStars(
  Canvas canvas,
  Size size,
  _SleepPalette palette,
  int seed,
  double intensity,
) {
  for (var index = 0; index < 34; index++) {
    final x = ((index * 43 + seed * 23) % 103) / 103 * size.width;
    final y = ((index * 29 + seed * 17) % 71) / 100 * size.height;
    final radius = index % 8 == 0 ? 1.25 : 0.55;

    canvas.drawCircle(
      Offset(x, y),
      radius,
      Paint()
        ..color = palette.star.withValues(
          alpha: (index % 5 == 0 ? 0.34 : 0.12) * intensity,
        ),
    );
  }
}

void _drawHorizon(
  Canvas canvas,
  Size size,
  _SleepPalette palette,
  double intensity,
) {
  final path = Path()
    ..moveTo(-20, size.height * 0.70)
    ..cubicTo(
      size.width * 0.18,
      size.height * 0.64,
      size.width * 0.34,
      size.height * 0.73,
      size.width * 0.52,
      size.height * 0.67,
    )
    ..cubicTo(
      size.width * 0.71,
      size.height * 0.60,
      size.width * 0.82,
      size.height * 0.69,
      size.width + 20,
      size.height * 0.62,
    )
    ..lineTo(size.width + 20, size.height + 20)
    ..lineTo(-20, size.height + 20)
    ..close();

  canvas.drawPath(
    path,
    Paint()
      ..color = palette.ridge.withValues(alpha: 0.86 * intensity + 0.08),
  );

  final distant = Path()
    ..moveTo(-20, size.height * 0.76)
    ..cubicTo(
      size.width * 0.24,
      size.height * 0.70,
      size.width * 0.46,
      size.height * 0.79,
      size.width * 0.68,
      size.height * 0.73,
    )
    ..cubicTo(
      size.width * 0.82,
      size.height * 0.69,
      size.width * 0.90,
      size.height * 0.76,
      size.width + 20,
      size.height * 0.72,
    )
    ..lineTo(size.width + 20, size.height + 20)
    ..lineTo(-20, size.height + 20)
    ..close();

  canvas.drawPath(
    distant,
    Paint()..color = palette.ground.withValues(alpha: 0.94),
  );
}

void _drawAtmosphere(
  Canvas canvas,
  Size size,
  _SleepPalette palette,
  double intensity,
) {
  for (var index = 0; index < 3; index++) {
    final y = size.height * (0.62 + index * 0.07);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * (0.54 + index * 0.04), y),
        width: size.width * (0.92 - index * 0.10),
        height: size.height * 0.08,
      ),
      Paint()
        ..color =
            palette.mist.withValues(alpha: (0.05 + index * 0.02) * intensity)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18),
    );
  }
}

void _drawVignette(Canvas canvas, Rect rect) {
  canvas.drawRect(
    rect,
    Paint()
      ..shader = RadialGradient(
        radius: 0.98,
        colors: [
          Colors.transparent,
          Colors.black.withValues(alpha: 0.48),
        ],
        stops: const [0.50, 1],
      ).createShader(rect),
  );
}

@immutable
class _SleepPalette {
  const _SleepPalette({
    required this.skyTop,
    required this.skyMid,
    required this.horizon,
    required this.ground,
    required this.ridge,
    required this.glow,
    required this.star,
    required this.mist,
  });

  final Color skyTop;
  final Color skyMid;
  final Color horizon;
  final Color ground;
  final Color ridge;
  final Color glow;
  final Color star;
  final Color mist;
}

_SleepPalette _paletteFor(ReleafSleepArtworkVariant variant) {
  return switch (variant) {
    ReleafSleepArtworkVariant.night => const _SleepPalette(
        skyTop: Color(0xFF080C1B),
        skyMid: Color(0xFF11162A),
        horizon: Color(0xFF171B28),
        ground: Color(0xFF080A0E),
        ridge: Color(0xFF0D1018),
        glow: Color(0xFF9199BC),
        star: Color(0xFFE3E5F0),
        mist: Color(0xFF98A4B8),
      ),
    ReleafSleepArtworkVariant.sound => const _SleepPalette(
        skyTop: Color(0xFF07131A),
        skyMid: Color(0xFF0F202A),
        horizon: Color(0xFF17272E),
        ground: Color(0xFF071014),
        ridge: Color(0xFF0B171C),
        glow: Color(0xFF79A2B2),
        star: Color(0xFFD8E8ED),
        mist: Color(0xFF86A6AD),
      ),
    ReleafSleepArtworkVariant.racingMind => const _SleepPalette(
        skyTop: Color(0xFF0C0E1E),
        skyMid: Color(0xFF1B1830),
        horizon: Color(0xFF201C2C),
        ground: Color(0xFF09090F),
        ridge: Color(0xFF12101B),
        glow: Color(0xFF9A83B1),
        star: Color(0xFFE6DCF0),
        mist: Color(0xFF9B8BAA),
      ),
    ReleafSleepArtworkVariant.body => const _SleepPalette(
        skyTop: Color(0xFF10120E),
        skyMid: Color(0xFF20251D),
        horizon: Color(0xFF292B22),
        ground: Color(0xFF0B0D0A),
        ridge: Color(0xFF171A14),
        glow: Color(0xFFAAA080),
        star: Color(0xFFEAE4D1),
        mist: Color(0xFFA49E8C),
      ),
    ReleafSleepArtworkVariant.breath => const _SleepPalette(
        skyTop: Color(0xFF071510),
        skyMid: Color(0xFF10231B),
        horizon: Color(0xFF182A20),
        ground: Color(0xFF07100C),
        ridge: Color(0xFF0D1913),
        glow: Color(0xFF82AA91),
        star: Color(0xFFDDECE3),
        mist: Color(0xFF91AA9B),
      ),
  };
}
