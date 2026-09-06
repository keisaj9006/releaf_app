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

    _drawAtmosphericField(canvas, size, palette, intensity);

    switch (variant) {
      case ReleafMeditationArtworkVariant.editorial:
        _drawEditorialStone(canvas, size, palette, intensity);
        break;
      case ReleafMeditationArtworkVariant.anxiety:
        _drawAnxietyFabric(canvas, size, palette, intensity);
        break;
      case ReleafMeditationArtworkVariant.focus:
        _drawFocusArchitecture(canvas, size, palette, intensity);
        break;
      case ReleafMeditationArtworkVariant.body:
        _drawBodyMineralLayers(canvas, size, palette, intensity);
        break;
      case ReleafMeditationArtworkVariant.compassion:
        _drawCompassionField(canvas, size, palette, intensity);
        break;
      case ReleafMeditationArtworkVariant.everyday:
        _drawEverydayWindowLight(canvas, size, palette, intensity);
        break;
      case ReleafMeditationArtworkVariant.timer:
        _drawTimerStillness(canvas, size, palette, intensity);
        break;
    }

    _drawFineGrain(canvas, size, palette, variant.index, intensity);
    _drawVignette(canvas, rect);
  }

  @override
  bool shouldRepaint(covariant _MeditationArtworkPainter oldDelegate) {
    return variant != oldDelegate.variant || intensity != oldDelegate.intensity;
  }
}

void _drawAtmosphericField(
  Canvas canvas,
  Size size,
  _MeditationPalette palette,
  double intensity,
) {
  final center = Offset(size.width * 0.70, size.height * 0.30);
  final radius = size.longestSide * 0.74;

  canvas.drawRect(
    Offset.zero & size,
    Paint()
      ..shader = RadialGradient(
        colors: [
          palette.glow.withValues(alpha: 0.23 * intensity),
          palette.secondary.withValues(alpha: 0.05 * intensity),
          Colors.transparent,
        ],
        stops: const [0, 0.42, 1],
      ).createShader(Rect.fromCircle(center: center, radius: radius)),
  );
}

void _drawEditorialStone(
  Canvas canvas,
  Size size,
  _MeditationPalette palette,
  double intensity,
) {
  final shapes = <Rect>[
    Rect.fromCenter(
      center: Offset(size.width * 0.73, size.height * 0.26),
      width: size.width * 0.37,
      height: size.height * 0.44,
    ),
    Rect.fromCenter(
      center: Offset(size.width * 0.54, size.height * 0.56),
      width: size.width * 0.44,
      height: size.height * 0.34,
    ),
    Rect.fromCenter(
      center: Offset(size.width * 0.84, size.height * 0.66),
      width: size.width * 0.28,
      height: size.height * 0.28,
    ),
  ];

  for (var index = 0; index < shapes.length; index++) {
    final rect = shapes[index];
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        rect,
        Radius.circular(math.min(rect.width, rect.height) * 0.42),
      ),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            palette.highlight.withValues(alpha: (0.18 - index * 0.025) * intensity),
            palette.primary.withValues(alpha: (0.15 - index * 0.018) * intensity),
            Colors.black.withValues(alpha: 0.05),
          ],
        ).createShader(rect)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
    );
  }

  final mist = Rect.fromLTWH(
    -size.width * 0.05,
    size.height * 0.54,
    size.width * 1.1,
    size.height * 0.32,
  );
  canvas.drawOval(
    mist,
    Paint()
      ..shader = RadialGradient(
        colors: [
          palette.highlight.withValues(alpha: 0.08 * intensity),
          Colors.transparent,
        ],
      ).createShader(mist)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18),
  );
}

void _drawAnxietyFabric(
  Canvas canvas,
  Size size,
  _MeditationPalette palette,
  double intensity,
) {
  for (var index = 0; index < 4; index++) {
    final path = Path()
      ..moveTo(
        -size.width * 0.08,
        size.height * (0.22 + index * 0.15),
      )
      ..cubicTo(
        size.width * 0.22,
        size.height * (0.08 + index * 0.17),
        size.width * 0.50,
        size.height * (0.42 + index * 0.08),
        size.width * 0.72,
        size.height * (0.23 + index * 0.15),
      )
      ..cubicTo(
        size.width * 0.90,
        size.height * (0.10 + index * 0.16),
        size.width * 1.08,
        size.height * (0.30 + index * 0.12),
        size.width * 1.10,
        size.height * (0.42 + index * 0.13),
      )
      ..lineTo(
        size.width * 1.10,
        size.height * (0.49 + index * 0.13),
      )
      ..cubicTo(
        size.width * 0.78,
        size.height * (0.38 + index * 0.14),
        size.width * 0.48,
        size.height * (0.56 + index * 0.09),
        -size.width * 0.08,
        size.height * (0.34 + index * 0.15),
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
            palette.secondary.withValues(alpha: 0.07 * intensity),
            palette.highlight.withValues(alpha: 0.15 * intensity),
            palette.primary.withValues(alpha: 0.08 * intensity),
            Colors.transparent,
          ],
        ).createShader(Offset.zero & size)
        ..maskFilter = MaskFilter.blur(
          BlurStyle.normal,
          5 + index * 2,
        ),
    );
  }
}

void _drawFocusArchitecture(
  Canvas canvas,
  Size size,
  _MeditationPalette palette,
  double intensity,
) {
  final leftPlane = Path()
    ..moveTo(0, size.height * 0.18)
    ..lineTo(size.width * 0.48, size.height * 0.05)
    ..lineTo(size.width * 0.42, size.height)
    ..lineTo(0, size.height)
    ..close();

  canvas.drawPath(
    leftPlane,
    Paint()..color = palette.secondary.withValues(alpha: 0.08 * intensity),
  );

  final rightPlane = Path()
    ..moveTo(size.width * 0.58, 0)
    ..lineTo(size.width, 0)
    ..lineTo(size.width, size.height)
    ..lineTo(size.width * 0.74, size.height)
    ..close();

  canvas.drawPath(
    rightPlane,
    Paint()..color = palette.primary.withValues(alpha: 0.06 * intensity),
  );

  final beam = Path()
    ..moveTo(size.width * 0.62, -size.height * 0.04)
    ..lineTo(size.width * 0.74, -size.height * 0.04)
    ..lineTo(size.width * 0.50, size.height * 1.02)
    ..lineTo(size.width * 0.35, size.height * 1.02)
    ..close();

  canvas.drawPath(
    beam,
    Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          palette.highlight.withValues(alpha: 0.22 * intensity),
          palette.highlight.withValues(alpha: 0.05 * intensity),
        ],
      ).createShader(Offset.zero & size)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 7),
  );

  canvas.drawLine(
    Offset(size.width * 0.48, size.height * 0.07),
    Offset(size.width * 0.42, size.height * 0.94),
    Paint()
      ..strokeWidth = 1
      ..color = palette.highlight.withValues(alpha: 0.20 * intensity),
  );
}

void _drawBodyMineralLayers(
  Canvas canvas,
  Size size,
  _MeditationPalette palette,
  double intensity,
) {
  final center = Offset(size.width * 0.72, size.height * 0.54);

  for (var index = 0; index < 7; index++) {
    final width = size.width * (0.64 - index * 0.065);
    final height = size.height * (0.55 - index * 0.052);
    final shifted = center + Offset(
      math.sin(index * 1.2) * size.width * 0.018,
      index * size.height * 0.008,
    );

    canvas.drawOval(
      Rect.fromCenter(
        center: shifted,
        width: width,
        height: height,
      ),
      Paint()
        ..style = index.isEven ? PaintingStyle.fill : PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..color = (index.isEven ? palette.primary : palette.highlight)
            .withValues(alpha: (0.035 + index * 0.013) * intensity),
    );
  }

  final grounding = Rect.fromCenter(
    center: Offset(size.width * 0.50, size.height * 0.84),
    width: size.width * 0.72,
    height: size.height * 0.12,
  );
  canvas.drawOval(
    grounding,
    Paint()
      ..color = palette.secondary.withValues(alpha: 0.09 * intensity)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 16),
  );
}

void _drawCompassionField(
  Canvas canvas,
  Size size,
  _MeditationPalette palette,
  double intensity,
) {
  final centers = <Offset>[
    Offset(size.width * 0.56, size.height * 0.38),
    Offset(size.width * 0.74, size.height * 0.43),
    Offset(size.width * 0.64, size.height * 0.60),
  ];

  for (var index = 0; index < centers.length; index++) {
    final radius = size.shortestSide * (0.20 - index * 0.018);
    final rect = Rect.fromCircle(center: centers[index], radius: radius);
    canvas.drawCircle(
      centers[index],
      radius,
      Paint()
        ..shader = RadialGradient(
          colors: [
            (index.isEven ? palette.primary : palette.secondary)
                .withValues(alpha: 0.16 * intensity),
            palette.highlight.withValues(alpha: 0.045 * intensity),
            Colors.transparent,
          ],
          stops: const [0, 0.58, 1],
        ).createShader(rect)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
    );
  }

  final arcPaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1
    ..color = palette.highlight.withValues(alpha: 0.16 * intensity);

  canvas.drawArc(
    Rect.fromCenter(
      center: Offset(size.width * 0.66, size.height * 0.48),
      width: size.width * 0.50,
      height: size.height * 0.44,
    ),
    math.pi * 0.15,
    math.pi * 0.78,
    false,
    arcPaint,
  );
}

void _drawEverydayWindowLight(
  Canvas canvas,
  Size size,
  _MeditationPalette palette,
  double intensity,
) {
  final floor = Rect.fromLTWH(
    0,
    size.height * 0.55,
    size.width,
    size.height * 0.45,
  );
  canvas.drawRect(
    floor,
    Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.transparent,
          palette.primary.withValues(alpha: 0.045 * intensity),
        ],
      ).createShader(floor),
  );

  for (var index = 0; index < 3; index++) {
    final left = size.width * (0.50 + index * 0.13);
    final path = Path()
      ..moveTo(left, -10)
      ..lineTo(left + size.width * 0.085, -10)
      ..lineTo(left - size.width * 0.12, size.height * 0.92)
      ..lineTo(left - size.width * 0.24, size.height * 0.92)
      ..close();

    canvas.drawPath(
      path,
      Paint()
        ..color = palette.highlight.withValues(
          alpha: (0.06 + index * 0.018) * intensity,
        )
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );
  }

  for (var index = 0; index < 5; index++) {
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(
          size.width * (0.20 + index * 0.14),
          size.height * (0.26 + (index % 2) * 0.08),
        ),
        width: size.width * 0.08,
        height: size.height * 0.13,
      ),
      Paint()
        ..color = palette.secondary.withValues(alpha: 0.055 * intensity)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );
  }
}

void _drawTimerStillness(
  Canvas canvas,
  Size size,
  _MeditationPalette palette,
  double intensity,
) {
  final center = Offset(size.width * 0.68, size.height * 0.47);

  for (var index = 0; index < 6; index++) {
    final scale = 1 - index * 0.115;
    canvas.drawOval(
      Rect.fromCenter(
        center: center,
        width: size.width * 0.54 * scale,
        height: size.height * 0.32 * scale,
      ),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = index == 0 ? 1.4 : 0.9
        ..color = palette.highlight.withValues(
          alpha: (0.18 - index * 0.018) * intensity,
        ),
    );
  }

  canvas.drawCircle(
    center,
    math.max(2.5, size.shortestSide * 0.012),
    Paint()
      ..color = palette.highlight.withValues(alpha: 0.55 * intensity)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
  );

  canvas.drawLine(
    Offset(size.width * 0.10, size.height * 0.72),
    Offset(size.width * 0.92, size.height * 0.72),
    Paint()
      ..strokeWidth = 1
      ..color = palette.primary.withValues(alpha: 0.10 * intensity),
  );
}

void _drawFineGrain(
  Canvas canvas,
  Size size,
  _MeditationPalette palette,
  int seed,
  double intensity,
) {
  for (var index = 0; index < 32; index++) {
    final x = ((index * 43 + seed * 17) % 101) / 101 * size.width;
    final y = ((index * 61 + seed * 13) % 97) / 97 * size.height;
    final radius = index % 7 == 0 ? 0.95 : 0.45;
    canvas.drawCircle(
      Offset(x, y),
      radius,
      Paint()
        ..color = palette.highlight.withValues(
          alpha: (index % 5 == 0 ? 0.10 : 0.028) * intensity,
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
          Colors.black.withValues(alpha: 0.54),
        ],
        stops: const [0.46, 1],
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
        background: Color(0xFF17131A),
        backgroundEnd: Color(0xFF0A0D0C),
        primary: Color(0xFF94849F),
        secondary: Color(0xFF778C82),
        highlight: Color(0xFFE8E0D2),
        glow: Color(0xFFB9A9C1),
      ),
    ReleafMeditationArtworkVariant.anxiety => const _MeditationPalette(
        background: Color(0xFF0F1A1A),
        backgroundEnd: Color(0xFF080D0E),
        primary: Color(0xFF679D96),
        secondary: Color(0xFF8B7D91),
        highlight: Color(0xFFD9E6E1),
        glow: Color(0xFF78A8A2),
      ),
    ReleafMeditationArtworkVariant.focus => const _MeditationPalette(
        background: Color(0xFF111522),
        backgroundEnd: Color(0xFF080B11),
        primary: Color(0xFF7589B5),
        secondary: Color(0xFF657D82),
        highlight: Color(0xFFE1E6F2),
        glow: Color(0xFF899BC6),
      ),
    ReleafMeditationArtworkVariant.body => const _MeditationPalette(
        background: Color(0xFF1B1511),
        backgroundEnd: Color(0xFF0D0B09),
        primary: Color(0xFFAD8B74),
        secondary: Color(0xFF82796C),
        highlight: Color(0xFFEBDAC6),
        glow: Color(0xFFC39A80),
      ),
    ReleafMeditationArtworkVariant.compassion => const _MeditationPalette(
        background: Color(0xFF1B1218),
        backgroundEnd: Color(0xFF0D090C),
        primary: Color(0xFFAD7D8D),
        secondary: Color(0xFF837A91),
        highlight: Color(0xFFEDDCE2),
        glow: Color(0xFFC091A0),
      ),
    ReleafMeditationArtworkVariant.everyday => const _MeditationPalette(
        background: Color(0xFF141A14),
        backgroundEnd: Color(0xFF090D0A),
        primary: Color(0xFF849A80),
        secondary: Color(0xFF7B8790),
        highlight: Color(0xFFE0E7D9),
        glow: Color(0xFF97AA91),
      ),
    ReleafMeditationArtworkVariant.timer => const _MeditationPalette(
        background: Color(0xFF10171B),
        backgroundEnd: Color(0xFF080C0E),
        primary: Color(0xFF708B98),
        secondary: Color(0xFF71818B),
        highlight: Color(0xFFDCE4E8),
        glow: Color(0xFF829DA8),
      ),
  };
}
