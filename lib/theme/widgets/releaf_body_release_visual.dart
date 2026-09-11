import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../releaf_design_tokens.dart';

/// Body-focused Reset visual that mirrors gentle tension and release without
/// implying a breathing rhythm.
class ReleafBodyReleaseVisual extends StatefulWidget {
  const ReleafBodyReleaseVisual({
    super.key,
    required this.progress,
    required this.phaseLabel,
    this.reducedMotion = false,
  });

  final double progress;
  final String phaseLabel;
  final bool reducedMotion;

  @override
  State<ReleafBodyReleaseVisual> createState() =>
      _ReleafBodyReleaseVisualState();
}

class _ReleafBodyReleaseVisualState extends State<ReleafBodyReleaseVisual>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    );
    _sync();
  }

  @override
  void didUpdateWidget(covariant ReleafBodyReleaseVisual oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.reducedMotion != widget.reducedMotion) _sync();
  }

  void _sync() {
    if (widget.reducedMotion) {
      _controller.stop();
      _controller.value = 0.32;
    } else if (!_controller.isAnimating) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final progress = widget.progress.clamp(0.0, 1.0).toDouble();

    return Semantics(
      container: true,
      image: true,
      label:
          'Illustrated upper-body guide. ${widget.phaseLabel}. The active jaw or shoulder area is highlighted.',
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: progress),
        duration: const Duration(milliseconds: 720),
        curve: Curves.easeOutCubic,
        builder: (context, animatedProgress, child) {
          return CustomPaint(
            key: const Key('reset-body-release-visual'),
            painter: _BodyProgressPainter(progress: animatedProgress),
            child: child,
          );
        },
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return CustomPaint(
              painter: _BodyReleasePainter(
                t: _controller.value,
                phaseLabel: widget.phaseLabel,
              ),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: AnimatedSwitcher(
                  duration: ReleafMotion.standard,
                  child: Padding(
                    key: ValueKey(widget.phaseLabel),
                    padding: const EdgeInsets.only(bottom: 30),
                    child: Text(
                      widget.phaseLabel.toUpperCase(),
                      style: ReleafTypography.eyebrow.copyWith(
                        color: ReleafColors.sage,
                        letterSpacing: 1.3,
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _BodyReleasePainter extends CustomPainter {
  const _BodyReleasePainter({
    required this.t,
    required this.phaseLabel,
  });

  final double t;
  final String phaseLabel;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;

    final center = Offset(size.width / 2, size.height / 2);
    final base = size.shortestSide;
    final label = phaseLabel.toLowerCase();
    final jaw = label.contains('jaw');
    final shoulders = label.contains('shoulder') ||
        label.contains('again') ||
        label.contains('press');
    final release = label.contains('release') || label.contains('let go');
    final notice = label.contains('notice');
    final pulse = 0.5 + 0.5 * math.sin(t * math.pi * 2);
    final shoulderLift = shoulders ? base * (0.024 + pulse * 0.012) : 0.0;
    final shoulderDrop = release ? base * 0.025 : 0.0;

    canvas.drawCircle(
      Offset(center.dx, center.dy - base * 0.015),
      base * (0.29 + pulse * 0.006),
      Paint()
        ..color = ReleafColors.sage.withValues(alpha: 0.08 + pulse * 0.035)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 32),
    );

    final figurePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(3.5, base * 0.013)
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = ReleafColors.textPrimary.withValues(alpha: 0.70);
    final accentPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(4.5, base * 0.018)
      ..strokeCap = StrokeCap.round
      ..color = ReleafColors.sage.withValues(alpha: 0.88);
    final glowPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(9.0, base * 0.038)
      ..strokeCap = StrokeCap.round
      ..color = ReleafColors.sage.withValues(alpha: 0.20 + pulse * 0.10)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15);

    final head = Offset(center.dx, center.dy - base * 0.18);
    final headRadius = base * 0.075;
    canvas.drawCircle(head, headRadius, figurePaint);

    final jawRect = Rect.fromCenter(
      center: Offset(head.dx, head.dy + headRadius * 0.33),
      width: headRadius * 1.35,
      height: headRadius * 1.18,
    );
    if (jaw || notice) {
      canvas.drawArc(jawRect, 0.18, math.pi - 0.36, false, glowPaint);
      canvas.drawArc(jawRect, 0.18, math.pi - 0.36, false, accentPaint);
    }

    final neckTop = Offset(center.dx, head.dy + headRadius);
    final neckBottom = Offset(center.dx, center.dy - base * 0.075);
    canvas.drawLine(neckTop, neckBottom, figurePaint);

    final shoulderY = center.dy - base * 0.055 - shoulderLift + shoulderDrop;
    final leftShoulder = Offset(center.dx - base * 0.19, shoulderY);
    final rightShoulder = Offset(center.dx + base * 0.19, shoulderY);
    final shoulderPath = Path()
      ..moveTo(leftShoulder.dx, leftShoulder.dy)
      ..quadraticBezierTo(
        center.dx - base * 0.08,
        shoulderY - base * 0.028,
        neckBottom.dx,
        neckBottom.dy,
      )
      ..quadraticBezierTo(
        center.dx + base * 0.08,
        shoulderY - base * 0.028,
        rightShoulder.dx,
        rightShoulder.dy,
      );
    if (shoulders || release || notice) {
      canvas.drawPath(shoulderPath, glowPaint);
      canvas.drawPath(shoulderPath, accentPaint);
    } else {
      canvas.drawPath(shoulderPath, figurePaint);
    }

    final torsoPath = Path()
      ..moveTo(leftShoulder.dx, leftShoulder.dy)
      ..quadraticBezierTo(
        center.dx - base * 0.16,
        center.dy + base * 0.10,
        center.dx - base * 0.12,
        center.dy + base * 0.19,
      )
      ..moveTo(rightShoulder.dx, rightShoulder.dy)
      ..quadraticBezierTo(
        center.dx + base * 0.16,
        center.dy + base * 0.10,
        center.dx + base * 0.12,
        center.dy + base * 0.19,
      );
    canvas.drawPath(torsoPath, figurePaint);

    if (shoulders) {
      final arrowPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(2.0, base * 0.007)
        ..strokeCap = StrokeCap.round
        ..color = ReleafColors.premium.withValues(alpha: 0.72);
      for (final x in [leftShoulder.dx, rightShoulder.dx]) {
        canvas.drawLine(
          Offset(x, shoulderY + base * 0.07),
          Offset(x, shoulderY + base * 0.025),
          arrowPaint,
        );
      }
    } else if (release) {
      final arrowPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(2.0, base * 0.007)
        ..strokeCap = StrokeCap.round
        ..color = ReleafColors.sage.withValues(alpha: 0.68);
      for (final x in [leftShoulder.dx, rightShoulder.dx]) {
        canvas.drawLine(
          Offset(x, shoulderY - base * 0.045),
          Offset(x, shoulderY + base * 0.005),
          arrowPaint,
        );
      }
    }

    if (notice) {
      canvas.drawCircle(
        Offset(center.dx, center.dy + base * 0.04),
        base * (0.012 + pulse * 0.004),
        Paint()..color = ReleafColors.premium.withValues(alpha: 0.78),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _BodyReleasePainter oldDelegate) {
    return oldDelegate.t != t || oldDelegate.phaseLabel != phaseLabel;
  }
}

class _BodyProgressPainter extends CustomPainter {
  const _BodyProgressPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;

    final stroke = math.max(1.0, size.shortestSide * 0.0055);
    final rect = Rect.fromCircle(
      center: Offset(size.width / 2, size.height / 2),
      radius: (size.shortestSide / 2) - stroke,
    );

    canvas.drawArc(
      rect,
      -math.pi / 2,
      math.pi * 2,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round
        ..color = ReleafColors.borderSoft.withValues(alpha: 0.38),
    );

    canvas.drawArc(
      rect,
      -math.pi / 2,
      math.pi * 2 * progress,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round
        ..color = ReleafColors.sage.withValues(alpha: 0.80),
    );
  }

  @override
  bool shouldRepaint(covariant _BodyProgressPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
