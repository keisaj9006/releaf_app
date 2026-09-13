import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../releaf_design_tokens.dart';

enum _BodyVisualMode { generic, fullBodyScan, shoulderDrop }

/// Body-focused Reset visual that mirrors gentle tension and release without
/// implying a breathing rhythm.
class ReleafBodyReleaseVisual extends StatefulWidget {
  const ReleafBodyReleaseVisual({
    super.key,
    required this.progress,
    required this.phaseLabel,
    this.reducedMotion = false,
    this.sessionId,
  });

  final double progress;
  final String phaseLabel;
  final bool reducedMotion;

  /// Optional explicit session identity. Active Reset routes also expose the
  /// same value through GoRouter, which keeps existing call sites compatible.
  final String? sessionId;

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

  String? _routeSessionId(BuildContext context) {
    try {
      return GoRouterState.of(context).pathParameters['sessionId'];
    } catch (_) {
      return null;
    }
  }

  _BodyVisualMode _visualMode(BuildContext context) {
    final sessionId = widget.sessionId ?? _routeSessionId(context);
    if (sessionId == 'tension-body-scan') {
      return _BodyVisualMode.fullBodyScan;
    }
    if (sessionId == 'shoulder-drop-reset') {
      return _BodyVisualMode.shoulderDrop;
    }

    // These fallbacks keep the visual independently previewable in widget
    // tests and design tooling where there is no app router above it.
    final label = widget.phaseLabel.toLowerCase();
    if (label == 'face' || label == 'whole body') {
      return _BodyVisualMode.fullBodyScan;
    }
    if (label == 'lift') return _BodyVisualMode.shoulderDrop;
    return _BodyVisualMode.generic;
  }

  String _semanticsLabel(_BodyVisualMode mode) {
    return switch (mode) {
      _BodyVisualMode.fullBodyScan =>
        'Illustrated whole-body attention map. ${widget.phaseLabel} is highlighted as the current area of attention.',
      _BodyVisualMode.shoulderDrop =>
        'Illustrated shoulder movement guide. ${widget.phaseLabel}. Follow only a small comfortable shoulder movement.',
      _BodyVisualMode.generic =>
        'Illustrated upper-body guide. ${widget.phaseLabel}. The active jaw or shoulder area is highlighted.',
    };
  }

  Key _visualKey(_BodyVisualMode mode) {
    return switch (mode) {
      _BodyVisualMode.fullBodyScan =>
        const Key('reset-full-body-scan-map'),
      _BodyVisualMode.shoulderDrop =>
        const Key('reset-shoulder-drop-guide'),
      _BodyVisualMode.generic => const Key('reset-body-release-visual'),
    };
  }

  CustomPainter _visualPainter(_BodyVisualMode mode, double t) {
    return switch (mode) {
      _BodyVisualMode.fullBodyScan => _FullBodyScanPainter(
        t: t,
        phaseLabel: widget.phaseLabel,
      ),
      _BodyVisualMode.shoulderDrop => _ShoulderDropPainter(
        t: t,
        phaseLabel: widget.phaseLabel,
      ),
      _BodyVisualMode.generic => _BodyReleasePainter(
        t: t,
        phaseLabel: widget.phaseLabel,
      ),
    };
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final progress = widget.progress.clamp(0.0, 1.0).toDouble();
    final mode = _visualMode(context);

    return Semantics(
      container: true,
      image: true,
      excludeSemantics: true,
      label: _semanticsLabel(mode),
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: progress),
        duration: const Duration(milliseconds: 720),
        curve: Curves.easeOutCubic,
        builder: (context, animatedProgress, child) {
          return CustomPaint(
            painter: _BodyProgressPainter(progress: animatedProgress),
            child: child,
          );
        },
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return CustomPaint(
              key: _visualKey(mode),
              painter: _visualPainter(mode, _controller.value),
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

class _FullBodyScanPainter extends CustomPainter {
  const _FullBodyScanPainter({required this.t, required this.phaseLabel});

  final double t;
  final String phaseLabel;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;

    final center = Offset(size.width / 2, size.height / 2 - 4);
    final base = size.shortestSide;
    final pulse = 0.5 + 0.5 * math.sin(t * math.pi * 2);
    final label = phaseLabel.toLowerCase();

    final figurePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(3.0, base * 0.0105)
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = ReleafColors.textPrimary.withValues(alpha: 0.58);
    final accentPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(4.0, base * 0.015)
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = ReleafColors.sage.withValues(alpha: 0.92);
    final glowPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(10.0, base * 0.034)
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = ReleafColors.sage.withValues(alpha: 0.18 + pulse * 0.12)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 16);

    canvas.drawCircle(
      center,
      base * (0.33 + pulse * 0.005),
      Paint()
        ..color = ReleafColors.sage.withValues(alpha: 0.055 + pulse * 0.025)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 30),
    );

    final head = Offset(center.dx, center.dy - base * 0.265);
    final headRadius = base * 0.052;
    final neck = Offset(center.dx, center.dy - base * 0.185);
    final leftShoulder = Offset(center.dx - base * 0.12, center.dy - base * 0.155);
    final rightShoulder = Offset(center.dx + base * 0.12, center.dy - base * 0.155);
    final leftHip = Offset(center.dx - base * 0.068, center.dy + base * 0.075);
    final rightHip = Offset(center.dx + base * 0.068, center.dy + base * 0.075);
    final leftHand = Offset(center.dx - base * 0.19, center.dy + base * 0.105);
    final rightHand = Offset(center.dx + base * 0.19, center.dy + base * 0.105);
    final leftKnee = Offset(center.dx - base * 0.063, center.dy + base * 0.205);
    final rightKnee = Offset(center.dx + base * 0.063, center.dy + base * 0.205);
    final leftFoot = Offset(center.dx - base * 0.078, center.dy + base * 0.325);
    final rightFoot = Offset(center.dx + base * 0.078, center.dy + base * 0.325);

    final shoulderPath = Path()
      ..moveTo(leftShoulder.dx, leftShoulder.dy)
      ..quadraticBezierTo(center.dx, neck.dy, rightShoulder.dx, rightShoulder.dy);
    final torsoPath = Path()
      ..moveTo(leftShoulder.dx, leftShoulder.dy)
      ..quadraticBezierTo(
        center.dx - base * 0.105,
        center.dy - base * 0.02,
        leftHip.dx,
        leftHip.dy,
      )
      ..lineTo(rightHip.dx, rightHip.dy)
      ..quadraticBezierTo(
        center.dx + base * 0.105,
        center.dy - base * 0.02,
        rightShoulder.dx,
        rightShoulder.dy,
      );
    final armsPath = Path()
      ..moveTo(leftShoulder.dx, leftShoulder.dy)
      ..quadraticBezierTo(
        center.dx - base * 0.175,
        center.dy - base * 0.025,
        leftHand.dx,
        leftHand.dy,
      )
      ..moveTo(rightShoulder.dx, rightShoulder.dy)
      ..quadraticBezierTo(
        center.dx + base * 0.175,
        center.dy - base * 0.025,
        rightHand.dx,
        rightHand.dy,
      );
    final legsPath = Path()
      ..moveTo(leftHip.dx, leftHip.dy)
      ..lineTo(leftKnee.dx, leftKnee.dy)
      ..lineTo(leftFoot.dx, leftFoot.dy)
      ..moveTo(rightHip.dx, rightHip.dy)
      ..lineTo(rightKnee.dx, rightKnee.dy)
      ..lineTo(rightFoot.dx, rightFoot.dy);
    final feetPath = Path()
      ..moveTo(leftFoot.dx - base * 0.025, leftFoot.dy)
      ..lineTo(leftFoot.dx + base * 0.025, leftFoot.dy)
      ..moveTo(rightFoot.dx - base * 0.025, rightFoot.dy)
      ..lineTo(rightFoot.dx + base * 0.025, rightFoot.dy);

    canvas.drawCircle(head, headRadius, figurePaint);
    canvas.drawLine(
      Offset(center.dx, head.dy + headRadius),
      neck,
      figurePaint,
    );
    canvas.drawPath(shoulderPath, figurePaint);
    canvas.drawPath(torsoPath, figurePaint);
    canvas.drawPath(armsPath, figurePaint);
    canvas.drawPath(legsPath, figurePaint);
    canvas.drawPath(feetPath, figurePaint);

    void highlightPath(Path path) {
      canvas.drawPath(path, glowPaint);
      canvas.drawPath(path, accentPaint);
    }

    void highlightLine(Offset a, Offset b) {
      canvas.drawLine(a, b, glowPaint);
      canvas.drawLine(a, b, accentPaint);
    }

    if (label.contains('whole')) {
      canvas.drawCircle(head, headRadius, glowPaint);
      canvas.drawCircle(head, headRadius, accentPaint);
      highlightPath(shoulderPath);
      highlightPath(torsoPath);
      highlightPath(armsPath);
      highlightPath(legsPath);
      highlightPath(feetPath);
    } else if (label.contains('face')) {
      canvas.drawCircle(head, headRadius, glowPaint);
      canvas.drawCircle(head, headRadius, accentPaint);
    } else if (label.contains('shoulder')) {
      highlightPath(shoulderPath);
      highlightLine(
        Offset(center.dx, head.dy + headRadius),
        neck,
      );
    } else if (label.contains('arm')) {
      highlightPath(armsPath);
      canvas.drawCircle(leftHand, base * 0.014, accentPaint);
      canvas.drawCircle(rightHand, base * 0.014, accentPaint);
    } else if (label.contains('chest')) {
      final chest = Rect.fromCenter(
        center: Offset(center.dx, center.dy - base * 0.07),
        width: base * 0.16,
        height: base * 0.105,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(chest, Radius.circular(base * 0.04)),
        glowPaint,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(chest, Radius.circular(base * 0.04)),
        accentPaint,
      );
    } else if (label.contains('center')) {
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(center.dx, center.dy + base * 0.025),
          width: base * 0.13,
          height: base * 0.10,
        ),
        glowPaint,
      );
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(center.dx, center.dy + base * 0.025),
          width: base * 0.13,
          height: base * 0.10,
        ),
        accentPaint,
      );
    } else if (label.contains('leg')) {
      highlightPath(legsPath);
    } else if (label.contains('feet') || label.contains('foot')) {
      highlightPath(feetPath);
      canvas.drawCircle(leftFoot, base * 0.018, glowPaint);
      canvas.drawCircle(rightFoot, base * 0.018, glowPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _FullBodyScanPainter oldDelegate) {
    return oldDelegate.t != t || oldDelegate.phaseLabel != phaseLabel;
  }
}

class _ShoulderDropPainter extends CustomPainter {
  const _ShoulderDropPainter({required this.t, required this.phaseLabel});

  final double t;
  final String phaseLabel;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;

    final center = Offset(size.width / 2, size.height / 2);
    final base = size.shortestSide;
    final label = phaseLabel.toLowerCase();
    final pulse = 0.5 + 0.5 * math.sin(t * math.pi * 2);
    final lifting = label.contains('lift');
    final releasing = label.contains('release') || label.contains('drop');
    final settling = label.contains('settle');
    final verticalShift = lifting
        ? -base * (0.022 + pulse * 0.012)
        : releasing
        ? base * (0.018 + pulse * 0.006)
        : settling
        ? base * 0.012
        : 0.0;

    canvas.drawCircle(
      Offset(center.dx, center.dy - base * 0.04),
      base * (0.29 + pulse * 0.005),
      Paint()
        ..color = ReleafColors.sage.withValues(alpha: 0.065 + pulse * 0.03)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 30),
    );

    final figurePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(3.5, base * 0.013)
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = ReleafColors.textPrimary.withValues(alpha: 0.68);
    final accentPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(4.8, base * 0.018)
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = ReleafColors.sage.withValues(alpha: 0.92);
    final glowPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(10.0, base * 0.038)
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = ReleafColors.sage.withValues(alpha: 0.20 + pulse * 0.10)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15);

    final head = Offset(center.dx, center.dy - base * 0.19);
    final headRadius = base * 0.073;
    final neckBottom = Offset(center.dx, center.dy - base * 0.075);
    canvas.drawCircle(head, headRadius, figurePaint);
    canvas.drawLine(
      Offset(center.dx, head.dy + headRadius),
      neckBottom,
      figurePaint,
    );

    final shoulderY = center.dy - base * 0.045 + verticalShift;
    final leftShoulder = Offset(center.dx - base * 0.19, shoulderY);
    final rightShoulder = Offset(center.dx + base * 0.19, shoulderY);
    final shoulderPath = Path()
      ..moveTo(leftShoulder.dx, leftShoulder.dy)
      ..quadraticBezierTo(
        center.dx - base * 0.08,
        shoulderY - base * 0.025,
        neckBottom.dx,
        neckBottom.dy,
      )
      ..quadraticBezierTo(
        center.dx + base * 0.08,
        shoulderY - base * 0.025,
        rightShoulder.dx,
        rightShoulder.dy,
      );
    canvas.drawPath(shoulderPath, glowPaint);
    canvas.drawPath(shoulderPath, accentPaint);

    final torsoPath = Path()
      ..moveTo(leftShoulder.dx, leftShoulder.dy)
      ..quadraticBezierTo(
        center.dx - base * 0.15,
        center.dy + base * 0.10,
        center.dx - base * 0.11,
        center.dy + base * 0.20,
      )
      ..moveTo(rightShoulder.dx, rightShoulder.dy)
      ..quadraticBezierTo(
        center.dx + base * 0.15,
        center.dy + base * 0.10,
        center.dx + base * 0.11,
        center.dy + base * 0.20,
      );
    canvas.drawPath(torsoPath, figurePaint);

    if (lifting || releasing) {
      final direction = lifting ? -1.0 : 1.0;
      final arrowPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(2.0, base * 0.007)
        ..strokeCap = StrokeCap.round
        ..color = lifting
            ? ReleafColors.premium.withValues(alpha: 0.76)
            : ReleafColors.sage.withValues(alpha: 0.76);
      for (final x in [leftShoulder.dx, rightShoulder.dx]) {
        final start = Offset(x, shoulderY - direction * base * 0.012);
        final end = Offset(x, shoulderY + direction * base * 0.052);
        canvas.drawLine(start, end, arrowPaint);
        final tip = end.dy - direction * base * 0.014;
        canvas.drawLine(
          end,
          Offset(end.dx - base * 0.012, tip),
          arrowPaint,
        );
        canvas.drawLine(
          end,
          Offset(end.dx + base * 0.012, tip),
          arrowPaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _ShoulderDropPainter oldDelegate) {
    return oldDelegate.t != t || oldDelegate.phaseLabel != phaseLabel;
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