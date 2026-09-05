import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Brain-specific artwork built from the same premium Releaf language as Reset,
/// but with sharper geometry and more structured visual rhythm.
enum ReleafBrainArtworkVariant {
  hero,
  memory,
  labyrinth,
  mathRace,
  brokenMirror,
  ruleShift,
  sequenceEcho,
  colorConflict,
  patternLogic,
  signalScan,
}

class ReleafBrainArtwork extends StatelessWidget {
  const ReleafBrainArtwork({
    super.key,
    required this.variant,
    this.intensity = 1,
  });

  final ReleafBrainArtworkVariant variant;
  final double intensity;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: CustomPaint(
        painter: _ReleafBrainArtworkPainter(
          variant: variant,
          intensity: intensity.clamp(0.0, 1.0).toDouble(),
        ),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _ReleafBrainArtworkPainter extends CustomPainter {
  const _ReleafBrainArtworkPainter({
    required this.variant,
    required this.intensity,
  });

  final ReleafBrainArtworkVariant variant;
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

    _drawAmbientField(canvas, size, palette, intensity);

    switch (variant) {
      case ReleafBrainArtworkVariant.hero:
        _drawHeroNetwork(canvas, size, palette, intensity);
      case ReleafBrainArtworkVariant.memory:
        _drawMemoryEcho(canvas, size, palette, intensity);
      case ReleafBrainArtworkVariant.labyrinth:
        _drawLabyrinthPath(canvas, size, palette, intensity);
      case ReleafBrainArtworkVariant.mathRace:
        _drawMathPulse(canvas, size, palette, intensity);
      case ReleafBrainArtworkVariant.brokenMirror:
        _drawMirrorFragments(canvas, size, palette, intensity);
      case ReleafBrainArtworkVariant.ruleShift:
        _drawRuleShift(canvas, size, palette, intensity);
      case ReleafBrainArtworkVariant.sequenceEcho:
        _drawSequenceEcho(canvas, size, palette, intensity);
      case ReleafBrainArtworkVariant.colorConflict:
        _drawColorConflict(canvas, size, palette, intensity);
      case ReleafBrainArtworkVariant.patternLogic:
        _drawPatternLogic(canvas, size, palette, intensity);
      case ReleafBrainArtworkVariant.signalScan:
        _drawSignalScan(canvas, size, palette, intensity);
    }

    _drawStructuredParticles(canvas, size, palette, variant.index, intensity);
    _drawVignette(canvas, rect);
  }

  @override
  bool shouldRepaint(covariant _ReleafBrainArtworkPainter oldDelegate) {
    return variant != oldDelegate.variant || intensity != oldDelegate.intensity;
  }
}

void _drawAmbientField(
  Canvas canvas,
  Size size,
  _BrainPalette palette,
  double intensity,
) {
  final center = Offset(size.width * 0.68, size.height * 0.30);
  final radius = size.longestSide * 0.72;

  canvas.drawRect(
    Offset.zero & size,
    Paint()
      ..shader = RadialGradient(
        colors: [
          palette.primary.withValues(alpha: 0.28 * intensity),
          palette.secondary.withValues(alpha: 0.08 * intensity),
          Colors.transparent,
        ],
        stops: const [0, 0.44, 1],
      ).createShader(Rect.fromCircle(center: center, radius: radius)),
  );
}

void _drawHeroNetwork(
  Canvas canvas,
  Size size,
  _BrainPalette palette,
  double intensity,
) {
  final glow = Paint()
    ..color = palette.primary.withValues(alpha: 0.16 * intensity)
    ..maskFilter = MaskFilter.blur(BlurStyle.normal, 24);

  final core = Offset(size.width * 0.72, size.height * 0.42);
  canvas.drawCircle(core, size.shortestSide * 0.19, glow);

  final linePaint = Paint()
    ..color = palette.highlight.withValues(alpha: 0.28 * intensity)
    ..style = PaintingStyle.stroke
    ..strokeWidth = math.max(1.2, size.shortestSide * 0.006)
    ..strokeCap = StrokeCap.round;

  final points = <Offset>[
    Offset(size.width * 0.46, size.height * 0.23),
    Offset(size.width * 0.71, size.height * 0.18),
    Offset(size.width * 0.88, size.height * 0.35),
    Offset(size.width * 0.80, size.height * 0.64),
    Offset(size.width * 0.57, size.height * 0.72),
    Offset(size.width * 0.40, size.height * 0.52),
  ];

  for (var i = 0; i < points.length; i++) {
    final next = points[(i + 1) % points.length];
    canvas.drawLine(points[i], next, linePaint);
    canvas.drawLine(points[i], core, linePaint);
    canvas.drawCircle(
      points[i],
      math.max(2.0, size.shortestSide * 0.012),
      Paint()..color = palette.highlight.withValues(alpha: 0.62 * intensity),
    );
  }

  canvas.drawCircle(
    core,
    math.max(4.0, size.shortestSide * 0.022),
    Paint()..color = palette.highlight.withValues(alpha: 0.82 * intensity),
  );
}

void _drawMemoryEcho(
  Canvas canvas,
  Size size,
  _BrainPalette palette,
  double intensity,
) {
  final base = Rect.fromCenter(
    center: Offset(size.width * 0.67, size.height * 0.43),
    width: size.width * 0.34,
    height: size.height * 0.38,
  );

  for (var i = 0; i < 4; i++) {
    final shift = Offset(-i * size.width * 0.055, i * size.height * 0.045);
    final rect = base.shift(shift);
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, Radius.circular(size.shortestSide * 0.06)),
      Paint()
        ..color = palette.primary.withValues(alpha: (0.08 + i * 0.055) * intensity)
        ..style = PaintingStyle.fill,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, Radius.circular(size.shortestSide * 0.06)),
      Paint()
        ..color = palette.highlight.withValues(alpha: 0.22 * intensity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );
  }
}

void _drawLabyrinthPath(
  Canvas canvas,
  Size size,
  _BrainPalette palette,
  double intensity,
) {
  final path = Path()
    ..moveTo(size.width * 0.42, size.height * 0.70)
    ..lineTo(size.width * 0.42, size.height * 0.48)
    ..lineTo(size.width * 0.58, size.height * 0.48)
    ..lineTo(size.width * 0.58, size.height * 0.27)
    ..lineTo(size.width * 0.79, size.height * 0.27)
    ..lineTo(size.width * 0.79, size.height * 0.58)
    ..lineTo(size.width * 0.68, size.height * 0.58)
    ..lineTo(size.width * 0.68, size.height * 0.76)
    ..lineTo(size.width * 0.91, size.height * 0.76);

  canvas.drawPath(
    path,
    Paint()
      ..color = palette.primary.withValues(alpha: 0.20 * intensity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(6, size.shortestSide * 0.038)
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 12),
  );

  canvas.drawPath(
    path,
    Paint()
      ..color = palette.highlight.withValues(alpha: 0.72 * intensity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(1.5, size.shortestSide * 0.010)
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round,
  );
}

void _drawMathPulse(
  Canvas canvas,
  Size size,
  _BrainPalette palette,
  double intensity,
) {
  final baseline = size.height * 0.56;
  final path = Path()..moveTo(size.width * 0.38, baseline);

  const values = <double>[0.0, -0.12, 0.16, -0.22, 0.08, -0.08, 0.20, -0.05, 0.0];
  for (var i = 1; i < values.length; i++) {
    path.lineTo(
      size.width * (0.38 + i * 0.065),
      baseline + size.height * values[i],
    );
  }

  canvas.drawPath(
    path,
    Paint()
      ..color = palette.primary.withValues(alpha: 0.18 * intensity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(8, size.shortestSide * 0.045)
      ..strokeCap = StrokeCap.round
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 14),
  );

  canvas.drawPath(
    path,
    Paint()
      ..color = palette.highlight.withValues(alpha: 0.80 * intensity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(1.4, size.shortestSide * 0.009)
      ..strokeCap = StrokeCap.round,
  );

  for (var i = 0; i < 4; i++) {
    final x = size.width * (0.48 + i * 0.11);
    final height = size.height * (0.09 + (i % 2) * 0.05);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(x, size.height * 0.22, size.width * 0.035, height),
        Radius.circular(size.width * 0.02),
      ),
      Paint()..color = palette.secondary.withValues(alpha: 0.28 * intensity),
    );
  }
}

void _drawMirrorFragments(
  Canvas canvas,
  Size size,
  _BrainPalette palette,
  double intensity,
) {
  final center = Offset(size.width * 0.70, size.height * 0.47);
  final fragments = <List<Offset>>[
    [
      center + Offset(-size.width * 0.18, -size.height * 0.16),
      center + Offset(-size.width * 0.02, -size.height * 0.28),
      center + Offset(size.width * 0.04, -size.height * 0.05),
    ],
    [
      center + Offset(size.width * 0.02, -size.height * 0.25),
      center + Offset(size.width * 0.20, -size.height * 0.12),
      center + Offset(size.width * 0.06, size.height * 0.02),
    ],
    [
      center + Offset(-size.width * 0.15, -size.height * 0.03),
      center + Offset(size.width * 0.01, -size.height * 0.02),
      center + Offset(-size.width * 0.04, size.height * 0.23),
      center + Offset(-size.width * 0.20, size.height * 0.14),
    ],
    [
      center + Offset(size.width * 0.04, size.height * 0.02),
      center + Offset(size.width * 0.20, -size.height * 0.04),
      center + Offset(size.width * 0.17, size.height * 0.21),
      center + Offset(size.width * 0.02, size.height * 0.23),
    ],
  ];

  for (var i = 0; i < fragments.length; i++) {
    final path = Path()..moveTo(fragments[i].first.dx, fragments[i].first.dy);
    for (final point in fragments[i].skip(1)) {
      path.lineTo(point.dx, point.dy);
    }
    path.close();

    canvas.drawPath(
      path,
      Paint()
        ..color = palette.primary.withValues(
          alpha: (0.10 + i * 0.045) * intensity,
        ),
    );
    canvas.drawPath(
      path,
      Paint()
        ..color = palette.highlight.withValues(alpha: 0.34 * intensity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.1,
    );
  }
}

void _drawRuleShift(
  Canvas canvas,
  Size size,
  _BrainPalette palette,
  double intensity,
) {
  final centerY = size.height * 0.48;
  final linePaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = math.max(1.5, size.shortestSide * 0.008)
    ..strokeCap = StrokeCap.round
    ..color = palette.highlight.withValues(alpha: 0.64 * intensity);

  final glowPaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = math.max(8, size.shortestSide * 0.038)
    ..strokeCap = StrokeCap.round
    ..color = palette.primary.withValues(alpha: 0.14 * intensity)
    ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);

  final upper = Path()
    ..moveTo(size.width * 0.36, centerY - size.height * 0.12)
    ..cubicTo(
      size.width * 0.52,
      centerY - size.height * 0.12,
      size.width * 0.57,
      centerY + size.height * 0.10,
      size.width * 0.76,
      centerY + size.height * 0.10,
    )
    ..lineTo(size.width * 0.70, centerY + size.height * 0.04)
    ..moveTo(size.width * 0.76, centerY + size.height * 0.10)
    ..lineTo(size.width * 0.69, centerY + size.height * 0.16);

  final lower = Path()
    ..moveTo(size.width * 0.36, centerY + size.height * 0.15)
    ..cubicTo(
      size.width * 0.52,
      centerY + size.height * 0.15,
      size.width * 0.58,
      centerY - size.height * 0.10,
      size.width * 0.78,
      centerY - size.height * 0.10,
    )
    ..lineTo(size.width * 0.71, centerY - size.height * 0.16)
    ..moveTo(size.width * 0.78, centerY - size.height * 0.10)
    ..lineTo(size.width * 0.71, centerY - size.height * 0.04);

  canvas.drawPath(upper, glowPaint);
  canvas.drawPath(lower, glowPaint);
  canvas.drawPath(upper, linePaint);
  canvas.drawPath(lower, linePaint);

  for (final offset in <Offset>[
    Offset(size.width * 0.36, centerY - size.height * 0.12),
    Offset(size.width * 0.36, centerY + size.height * 0.15),
  ]) {
    canvas.drawCircle(
      offset,
      math.max(3, size.shortestSide * 0.017),
      Paint()
        ..color = palette.primary.withValues(alpha: 0.72 * intensity),
    );
  }
}

void _drawSequenceEcho(
  Canvas canvas,
  Size size,
  _BrainPalette palette,
  double intensity,
) {
  final points = <Offset>[
    Offset(size.width * 0.44, size.height * 0.34),
    Offset(size.width * 0.61, size.height * 0.24),
    Offset(size.width * 0.78, size.height * 0.38),
    Offset(size.width * 0.70, size.height * 0.58),
    Offset(size.width * 0.50, size.height * 0.64),
  ];

  for (var i = 0; i < points.length - 1; i++) {
    canvas.drawLine(
      points[i],
      points[i + 1],
      Paint()
        ..color = palette.highlight.withValues(alpha: 0.38 * intensity)
        ..strokeWidth = math.max(1.5, size.shortestSide * 0.008),
    );
  }

  for (var i = 0; i < points.length; i++) {
    final radius = math.max(5, size.shortestSide * (0.024 + i * 0.004));
    canvas.drawCircle(
      points[i],
      radius * 2.2,
      Paint()
        ..color = palette.primary.withValues(alpha: 0.10 * intensity)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
    );
    canvas.drawCircle(
      points[i],
      radius,
      Paint()
        ..color = palette.highlight.withValues(alpha: 0.72 * intensity),
    );
  }
}

void _drawColorConflict(
  Canvas canvas,
  Size size,
  _BrainPalette palette,
  double intensity,
) {
  final rects = <Rect>[
    Rect.fromLTWH(
      size.width * 0.42,
      size.height * 0.24,
      size.width * 0.34,
      size.height * 0.10,
    ),
    Rect.fromLTWH(
      size.width * 0.52,
      size.height * 0.40,
      size.width * 0.28,
      size.height * 0.10,
    ),
    Rect.fromLTWH(
      size.width * 0.39,
      size.height * 0.56,
      size.width * 0.38,
      size.height * 0.10,
    ),
  ];
  final colors = [palette.primary, palette.secondary, palette.highlight];

  for (var i = 0; i < rects.length; i++) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        rects[i],
        Radius.circular(size.shortestSide * 0.04),
      ),
      Paint()
        ..color = colors[i].withValues(alpha: 0.36 * intensity),
    );
    canvas.drawLine(
      rects[i].topLeft + Offset(rects[i].width * 0.14, rects[i].height / 2),
      rects[i].topRight - Offset(rects[i].width * 0.14, -rects[i].height / 2),
      Paint()
        ..color = palette.highlight.withValues(alpha: 0.56 * intensity)
        ..strokeWidth = math.max(2, size.shortestSide * 0.012)
        ..strokeCap = StrokeCap.round,
    );
  }
}

void _drawPatternLogic(
  Canvas canvas,
  Size size,
  _BrainPalette palette,
  double intensity,
) {
  final origin = Offset(size.width * 0.46, size.height * 0.28);
  final cell = size.shortestSide * 0.11;

  for (var row = 0; row < 3; row++) {
    for (var col = 0; col < 3; col++) {
      final center = origin + Offset(col * cell * 1.28, row * cell * 1.28);
      final selected = row == 2 && col == 2;
      canvas.drawCircle(
        center,
        cell * 0.36,
        Paint()
          ..style = selected ? PaintingStyle.stroke : PaintingStyle.fill
          ..strokeWidth = 2
          ..color = (selected ? palette.highlight : palette.primary)
              .withValues(alpha: (selected ? 0.74 : 0.26) * intensity),
      );
      if ((row + col).isEven && !selected) {
        canvas.drawCircle(
          center,
          cell * 0.12,
          Paint()
            ..color =
                palette.highlight.withValues(alpha: 0.65 * intensity),
        );
      }
    }
  }
}

void _drawSignalScan(
  Canvas canvas,
  Size size,
  _BrainPalette palette,
  double intensity,
) {
  final origin = Offset(size.width * 0.43, size.height * 0.24);
  final step = size.shortestSide * 0.085;

  for (var row = 0; row < 5; row++) {
    for (var col = 0; col < 5; col++) {
      final point = origin + Offset(col * step, row * step);
      final target = row == 3 && col == 2;
      canvas.drawCircle(
        point,
        target ? step * 0.22 : step * 0.10,
        Paint()
          ..color = (target ? palette.highlight : palette.primary)
              .withValues(alpha: (target ? 0.88 : 0.28) * intensity),
      );
      if (target) {
        canvas.drawCircle(
          point,
          step * 0.42,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.4
            ..color =
                palette.secondary.withValues(alpha: 0.56 * intensity),
        );
      }
    }
  }
}

void _drawStructuredParticles(
  Canvas canvas,
  Size size,
  _BrainPalette palette,
  int seed,
  double intensity,
) {
  for (var i = 0; i < 18; i++) {
    final x = ((i * 31 + seed * 17) % 97) / 97 * size.width;
    final y = ((i * 47 + seed * 13) % 89) / 89 * size.height;
    final radius = i % 4 == 0 ? 1.3 : 0.6;
    canvas.drawCircle(
      Offset(x, y),
      radius,
      Paint()
        ..color = palette.highlight.withValues(
          alpha: (i % 3 == 0 ? 0.16 : 0.06) * intensity,
        ),
    );
  }
}

void _drawVignette(Canvas canvas, Rect rect) {
  canvas.drawRect(
    rect,
    Paint()
      ..shader = RadialGradient(
        radius: 0.98,
        colors: [Colors.transparent, Colors.black.withValues(alpha: 0.46)],
        stops: const [0.48, 1],
      ).createShader(rect),
  );
}

@immutable
class _BrainPalette {
  const _BrainPalette({
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

_BrainPalette _paletteFor(ReleafBrainArtworkVariant variant) {
  return switch (variant) {
    ReleafBrainArtworkVariant.hero => const _BrainPalette(
      background: Color(0xFF0B1716),
      backgroundEnd: Color(0xFF10111C),
      primary: Color(0xFF5A9D94),
      secondary: Color(0xFF5E6AA8),
      highlight: Color(0xFFCAE5DA),
    ),
    ReleafBrainArtworkVariant.memory => const _BrainPalette(
      background: Color(0xFF101827),
      backgroundEnd: Color(0xFF0A1018),
      primary: Color(0xFF6B83C0),
      secondary: Color(0xFF4C8E8A),
      highlight: Color(0xFFD6DEF4),
    ),
    ReleafBrainArtworkVariant.labyrinth => const _BrainPalette(
      background: Color(0xFF102018),
      backgroundEnd: Color(0xFF09110D),
      primary: Color(0xFF77A47F),
      secondary: Color(0xFF4E7E6E),
      highlight: Color(0xFFD3E5D4),
    ),
    ReleafBrainArtworkVariant.mathRace => const _BrainPalette(
      background: Color(0xFF1D1827),
      backgroundEnd: Color(0xFF0E0D14),
      primary: Color(0xFF9A76B5),
      secondary: Color(0xFF557EA7),
      highlight: Color(0xFFE6D8F0),
    ),
    ReleafBrainArtworkVariant.brokenMirror => const _BrainPalette(
      background: Color(0xFF211A18),
      backgroundEnd: Color(0xFF0F0D0C),
      primary: Color(0xFFB1886A),
      secondary: Color(0xFF647A86),
      highlight: Color(0xFFF0D7C6),
    ),
    ReleafBrainArtworkVariant.ruleShift => const _BrainPalette(
      background: Color(0xFF171225),
      backgroundEnd: Color(0xFF0A0B13),
      primary: Color(0xFF9D83E0),
      secondary: Color(0xFF5C86A7),
      highlight: Color(0xFFE2DAFF),
    ),
    ReleafBrainArtworkVariant.sequenceEcho => const _BrainPalette(
      background: Color(0xFF111A29),
      backgroundEnd: Color(0xFF090E17),
      primary: Color(0xFF6E8FD0),
      secondary: Color(0xFF5CB7A8),
      highlight: Color(0xFFDDE7FF),
    ),
    ReleafBrainArtworkVariant.colorConflict => const _BrainPalette(
      background: Color(0xFF21151E),
      backgroundEnd: Color(0xFF100B10),
      primary: Color(0xFFD77A9D),
      secondary: Color(0xFF6DB8B0),
      highlight: Color(0xFFFFDDE8),
    ),
    ReleafBrainArtworkVariant.patternLogic => const _BrainPalette(
      background: Color(0xFF181828),
      backgroundEnd: Color(0xFF0A0A13),
      primary: Color(0xFF8E86D7),
      secondary: Color(0xFFB58B5A),
      highlight: Color(0xFFE7E2FF),
    ),
    ReleafBrainArtworkVariant.signalScan => const _BrainPalette(
      background: Color(0xFF0F1D20),
      backgroundEnd: Color(0xFF081012),
      primary: Color(0xFF55A6A0),
      secondary: Color(0xFF6C7FC2),
      highlight: Color(0xFFD9FFF8),
    ),
  };
}
