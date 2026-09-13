import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../releaf_design_tokens.dart';
import 'releaf_artwork.dart';

class ReleafSessionLivingForm extends StatefulWidget {
  const ReleafSessionLivingForm({
    super.key,
    required this.variant,
    required this.progress,
    this.breathing = false,
    this.phaseProgress,
    this.phaseLabel,
    this.phaseSecondsRemaining,
    this.reducedMotion = false,
  });

  final ReleafArtworkVariant variant;
  final double progress;
  final bool breathing;
  final double? phaseProgress;
  final String? phaseLabel;
  final int? phaseSecondsRemaining;
  final bool reducedMotion;

  @override
  State<ReleafSessionLivingForm> createState() =>
      _ReleafSessionLivingFormState();
}

class _ReleafSessionLivingFormState extends State<ReleafSessionLivingForm>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 5200),
    );
    _syncAnimationState();
  }

  @override
  void didUpdateWidget(covariant ReleafSessionLivingForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.breathing != widget.breathing ||
        oldWidget.reducedMotion != widget.reducedMotion ||
        oldWidget.phaseProgress != widget.phaseProgress) {
      _syncAnimationState();
    }
  }

  void _syncAnimationState() {
    if (widget.reducedMotion || widget.phaseProgress != null) {
      _controller.stop();
      return;
    }
    if (widget.breathing) {
      _controller.repeat(reverse: true);
    } else {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final phaseProgress = widget.phaseProgress?.clamp(0.0, 1.0);
    final showBreathPath = widget.breathing && phaseProgress != null;
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final localT = phaseProgress ?? _controller.value;
        final wave = 0.5 - 0.5 * math.cos(localT * math.pi);
        final scale = widget.breathing && !widget.reducedMotion
            ? 0.88 + (0.20 * wave)
            : 1.0;
        final glow = widget.breathing && !widget.reducedMotion
            ? 0.16 + (0.18 * wave)
            : 0.12;

        return Stack(
          alignment: Alignment.center,
          children: [
            CustomPaint(
              key: const Key('reset-living-form'),
              painter: _LivingFormBackdropPainter(
                glow: glow,
                progress: widget.progress.clamp(0.0, 1.0),
              ),
              child: const SizedBox.expand(),
            ),
            if (showBreathPath)
              CustomPaint(
                key: const Key('reset-breath-path'),
                painter: _BreathPathPainter(
                  progress: widget.reducedMotion ? null : phaseProgress,
                  reducedMotion: widget.reducedMotion,
                ),
                child: const SizedBox.expand(),
              ),
            Transform.scale(
              scale: scale,
              child: SizedBox(
                width: 180,
                height: 180,
                child: widget.breathing
                    ? CustomPaint(
                        key: const Key('reset-breathing-lungs'),
                        painter: _BreathingLungsPainter(
                          emphasis: widget.reducedMotion ? 0.58 : wave,
                        ),
                      )
                    : ReleafLivingForm(
                        variant: widget.variant,
                        opacity: 0.96,
                      ),
              ),
            ),
            if (widget.phaseLabel != null && widget.phaseLabel!.isNotEmpty)
              Positioned(
                bottom: 20,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: ReleafColors.background.withValues(alpha: 0.78),
                    borderRadius: BorderRadius.circular(ReleafRadii.pill),
                    border: Border.all(
                      color: ReleafColors.sage.withValues(alpha: 0.16),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 7,
                    ),
                    child: Text(
                      widget.phaseSecondsRemaining == null
                          ? widget.phaseLabel!
                          : '${widget.phaseLabel!} · ${widget.phaseSecondsRemaining}s',
                      key: const Key('reset-living-form-phase'),
                      style: ReleafTypography.meta.copyWith(
                        color: ReleafColors.textPrimary,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.25,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _BreathingLungsPainter extends CustomPainter {
  const _BreathingLungsPainter({required this.emphasis});

  final double emphasis;

  @override
  void paint(Canvas canvas, Size size) {
    final e = emphasis.clamp(0.0, 1.0);
    final center = Offset(size.width / 2, size.height * 0.49);

    final haloRect = Rect.fromCenter(
      center: center,
      width: size.width * 0.90,
      height: size.height * 0.86,
    );
    final halo = Paint()
      ..shader = RadialGradient(
        colors: [
          ReleafColors.sage.withValues(alpha: 0.10 + 0.07 * e),
          ReleafColors.sage.withValues(alpha: 0.0),
        ],
      ).createShader(haloRect);
    canvas.drawOval(haloRect, halo);

    Path lobe(bool left) {
      final direction = left ? -1.0 : 1.0;
      final p = Path()
        ..moveTo(size.width * (0.50 + direction * 0.025), size.height * 0.28)
        ..cubicTo(
          size.width * (0.50 + direction * 0.13),
          size.height * 0.25,
          size.width * (0.50 + direction * 0.31),
          size.height * 0.34,
          size.width * (0.50 + direction * 0.33),
          size.height * 0.54,
        )
        ..cubicTo(
          size.width * (0.50 + direction * 0.34),
          size.height * 0.72,
          size.width * (0.50 + direction * 0.19),
          size.height * 0.83,
          size.width * (0.50 + direction * 0.055),
          size.height * 0.77,
        )
        ..cubicTo(
          size.width * (0.50 + direction * 0.02),
          size.height * 0.67,
          size.width * (0.50 + direction * 0.018),
          size.height * 0.40,
          size.width * (0.50 + direction * 0.025),
          size.height * 0.28,
        )
        ..close();
      return p;
    }

    final fillShaderRect = Rect.fromLTWH(
      size.width * 0.16,
      size.height * 0.20,
      size.width * 0.68,
      size.height * 0.65,
    );
    final fill = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          ReleafColors.sage.withValues(alpha: 0.24 + 0.08 * e),
          ReleafColors.sage.withValues(alpha: 0.08 + 0.05 * e),
        ],
      ).createShader(fillShaderRect)
      ..style = PaintingStyle.fill;
    final outline = Paint()
      ..color = ReleafColors.sage.withValues(alpha: 0.70 + 0.14 * e)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final vein = Paint()
      ..color = ReleafColors.sage.withValues(alpha: 0.26 + 0.12 * e)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.15
      ..strokeCap = StrokeCap.round;

    for (final left in [true, false]) {
      final path = lobe(left);
      canvas.drawPath(path, fill);
      canvas.drawPath(path, outline);

      final d = left ? -1.0 : 1.0;
      final branch = Path()
        ..moveTo(size.width * 0.50, size.height * 0.32)
        ..cubicTo(
          size.width * (0.50 + d * 0.07),
          size.height * 0.38,
          size.width * (0.50 + d * 0.14),
          size.height * 0.49,
          size.width * (0.50 + d * 0.20),
          size.height * 0.68,
        );
      canvas.drawPath(branch, vein);

      final upperVein = Path()
        ..moveTo(size.width * (0.50 + d * 0.09), size.height * 0.43)
        ..quadraticBezierTo(
          size.width * (0.50 + d * 0.19),
          size.height * 0.39,
          size.width * (0.50 + d * 0.25),
          size.height * 0.42,
        );
      final lowerVein = Path()
        ..moveTo(size.width * (0.50 + d * 0.13), size.height * 0.56)
        ..quadraticBezierTo(
          size.width * (0.50 + d * 0.22),
          size.height * 0.56,
          size.width * (0.50 + d * 0.27),
          size.height * 0.62,
        );
      canvas.drawPath(upperVein, vein);
      canvas.drawPath(lowerVein, vein);
    }

    final stem = Paint()
      ..color = ReleafColors.sage.withValues(alpha: 0.72)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round;
    final airway = Path()
      ..moveTo(size.width * 0.50, size.height * 0.14)
      ..lineTo(size.width * 0.50, size.height * 0.30)
      ..moveTo(size.width * 0.50, size.height * 0.30)
      ..quadraticBezierTo(
        size.width * 0.46,
        size.height * 0.33,
        size.width * 0.43,
        size.height * 0.38,
      )
      ..moveTo(size.width * 0.50, size.height * 0.30)
      ..quadraticBezierTo(
        size.width * 0.54,
        size.height * 0.33,
        size.width * 0.57,
        size.height * 0.38,
      );
    canvas.drawPath(airway, stem);

    final centerGlow = Paint()
      ..color = ReleafColors.sage.withValues(alpha: 0.12 + 0.08 * e)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
    canvas.drawCircle(center, size.width * (0.09 + 0.015 * e), centerGlow);
  }

  @override
  bool shouldRepaint(covariant _BreathingLungsPainter oldDelegate) {
    return oldDelegate.emphasis != emphasis;
  }
}

class _LivingFormBackdropPainter extends CustomPainter {
  const _LivingFormBackdropPainter({
    required this.glow,
    required this.progress,
  });

  final double glow;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) * 0.41;

    final halo = Paint()
      ..shader = RadialGradient(
        colors: [
          ReleafColors.sage.withValues(alpha: glow),
          ReleafColors.sage.withValues(alpha: 0),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius, halo);

    final track = Paint()
      ..color = ReleafColors.borderSoft.withValues(alpha: 0.52)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(center, radius * 0.88, track);

    if (progress > 0) {
      final progressPaint = Paint()
        ..color = ReleafColors.sage.withValues(alpha: 0.72)
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = 2.6;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius * 0.88),
        -math.pi / 2,
        math.pi * 2 * progress,
        false,
        progressPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _LivingFormBackdropPainter oldDelegate) {
    return oldDelegate.glow != glow || oldDelegate.progress != progress;
  }
}

class _BreathPathPainter extends CustomPainter {
  const _BreathPathPainter({
    required this.progress,
    required this.reducedMotion,
  });

  final double? progress;
  final bool reducedMotion;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) * 0.31;
    final rect = Rect.fromCircle(center: center, radius: radius);
    final pathPaint = Paint()
      ..color = ReleafColors.sage.withValues(alpha: 0.22)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6;
    canvas.drawArc(rect, 0, math.pi * 2, false, pathPaint);

    if (reducedMotion || progress == null) return;
    final angle = (-math.pi / 2) + (math.pi * 2 * progress!.clamp(0.0, 1.0));
    final marker = Offset(
      center.dx + math.cos(angle) * radius,
      center.dy + math.sin(angle) * radius,
    );
    final markerPaint = Paint()..color = ReleafColors.sage;
    canvas.drawCircle(marker, 4.2, markerPaint);
  }

  @override
  bool shouldRepaint(covariant _BreathPathPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.reducedMotion != reducedMotion;
  }
}
