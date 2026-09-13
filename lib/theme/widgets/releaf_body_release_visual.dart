import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../releaf_design_tokens.dart';

const List<String> _fullBodyScanStages = [
  'Face',
  'Shoulders',
  'Arms',
  'Chest',
  'Center',
  'Legs',
  'Feet',
  'Whole Body',
];

enum _BodyVisualMode { generic, fullBodyScan, shoulderDrop }

int _fullBodyScanStageIndex(String phaseLabel, double progress) {
  final normalized = phaseLabel.trim().toLowerCase();
  final exact = _fullBodyScanStages.indexWhere(
    (stage) => stage.toLowerCase() == normalized,
  );
  if (exact >= 0) return exact;

  final clamped = progress.clamp(0.0, 1.0).toDouble();
  return math.min(
    _fullBodyScanStages.length - 1,
    (clamped * _fullBodyScanStages.length).floor(),
  );
}

String _shoulderMovementCue(String phaseLabel) {
  final label = phaseLabel.trim().toLowerCase();
  if (label.contains('lift')) return 'LIFT GENTLY';
  if (label.contains('release') ||
      label.contains('drop') ||
      label.contains('let go')) {
    return 'LET THEM DROP';
  }
  if (label.contains('settle')) return 'SETTLE HERE';
  if (label.contains('notice')) return 'NOTICE YOUR SHOULDERS';
  return 'MOVE GENTLY';
}

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
        'Full Body Scan. Stage ${_fullBodyScanStageIndex(widget.phaseLabel, widget.progress) + 1} of ${_fullBodyScanStages.length}. ${widget.phaseLabel} is the current area of attention.${widget.reducedMotion ? ' Motion reduced.' : ''}',
      _BodyVisualMode.shoulderDrop =>
        'Shoulder Drop. ${_shoulderMovementCue(widget.phaseLabel).toLowerCase()}. Use only a small comfortable movement.',
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

  Widget _pilotOverlay(_BodyVisualMode mode) {
    return switch (mode) {
      _BodyVisualMode.fullBodyScan => _BodyScanStageIndicator(
        stageIndex: _fullBodyScanStageIndex(widget.phaseLabel, widget.progress),
      ),
      _BodyVisualMode.shoulderDrop => _ShoulderMovementCue(
        cue: _shoulderMovementCue(widget.phaseLabel),
      ),
      _BodyVisualMode.generic => const SizedBox.shrink(),
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

    Widget visual = AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          key: _visualKey(mode),
          painter: _visualPainter(mode, _controller.value),
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (mode != _BodyVisualMode.generic)
                Positioned(
                  top: 22,
                  left: 24,
                  right: 24,
                  child: _pilotOverlay(mode),
                ),
              Positioned(
                left: 24,
                right: 24,
                bottom: 28,
                child: Center(
                  child: AnimatedSwitcher(
                    duration: ReleafMotion.standard,
                    child: FittedBox(
                      key: ValueKey(widget.phaseLabel),
                      fit: BoxFit.scaleDown,
                      child: Text(
                        widget.phaseLabel.toUpperCase(),
                        maxLines: 1,
                        style: ReleafTypography.eyebrow.copyWith(
                          color: ReleafColors.sage,
                          letterSpacing: 1.3,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );

    if (widget.reducedMotion) {
      visual = KeyedSubtree(
        key: const Key('reset-body-motion-static'),
        child: visual,
      );
    }

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
        child: visual,
      ),
    );
  }
}

class _BodyScanStageIndicator extends StatelessWidget {
  const _BodyScanStageIndicator({required this.stageIndex});

  final int stageIndex;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('reset-body-scan-stage-indicator'),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: ReleafColors.surface.withValues(alpha: 0.60),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: ReleafColors.sage.withValues(alpha: 0.16),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                for (var index = 0; index < _fullBodyScanStages.length; index++)
                  Expanded(
                    child: Container(
                      height: index == stageIndex ? 4 : 3,
                      margin: EdgeInsets.only(
                        right: index == _fullBodyScanStages.length - 1 ? 0 : 4,
                      ),
                      decoration: BoxDecoration(
                        color: index == stageIndex
                            ? ReleafColors.sage
                            : index < stageIndex
                            ? ReleafColors.sage.withValues(alpha: 0.38)
                            : ReleafColors.textPrimary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(99),
                        boxShadow: index == stageIndex
                            ? [
                                BoxShadow(
                                  color: ReleafColors.sage.withValues(alpha: 0.24),
                                  blurRadius: 7,
                                ),
                              ]
                            : null,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text(
            '${stageIndex + 1} OF ${_fullBodyScanStages.length}',
            maxLines: 1,
            textScaler: TextScaler.noScaling,
            style: ReleafTypography.meta.copyWith(
              color: ReleafColors.textSecondary,
              fontSize: 9,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }
}

class _ShoulderMovementCue extends StatelessWidget {
  const _ShoulderMovementCue({required this.cue});

  final String cue;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        key: const Key('reset-shoulder-movement-cue'),
        constraints: const BoxConstraints(maxWidth: 230),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: ReleafColors.surface.withValues(alpha: 0.62),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: ReleafColors.sage.withValues(alpha: 0.18),
          ),
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            cue,
            maxLines: 1,
            style: ReleafTypography.eyebrow.copyWith(
              color: ReleafColors.textPrimary.withValues(alpha: 0.82),
              fontSize: 10,
              letterSpacing: 1.15,
            ),
          ),
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

    final center = Offset(size.width / 2, size.height / 2 + 8);
    final base = size.shortestSide;
    final pulse = 0.5 + 0.5 * math.sin(t * math.pi * 2);
    final label = phaseLabel.toLowerCase();

    final ambientPaint = Paint()
      ..color = ReleafColors.sage.withValues(alpha: 0.045 + pulse * 0.02)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 28);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(center.dx, center.dy - base * 0.015),
        width: base * 0.52,
        height: base * 0.73,
      ),
      ambientPaint,
    );

    final softBodyPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = ReleafColors.textPrimary.withValues(alpha: 0.025);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(center.dx, center.dy - base * 0.035),
        width: base * 0.19,
        height: base * 0.39,
      ),
      softBodyPaint,
    );

    final figurePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(2.6, base * 0.0095)
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = ReleafColors.textPrimary.withValues(alpha: 0.48);
    final accentPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(4.0, base * 0.0145)
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = ReleafColors.sage.withValues(alpha: 0.90);
    final glowPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(10.0, base * 0.032)
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = ReleafColors.sage.withValues(alpha: 0.14 + pulse * 0.11)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 16);

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

    final railPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(1.0, base * 0.004)
      ..strokeCap = StrokeCap.round
      ..color = ReleafColors.sage.withValues(alpha: 0.13);
    canvas.drawLine(
      Offset(center.dx, head.dy - base * 0.035),
      Offset(center.dx, rightFoot.dy + base * 0.03),
      railPaint,
    );

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

    final center = Offset(size.width / 2, size.height / 2 + 5);
    final base = size.shortestSide;
    final label = phaseLabel.toLowerCase();
    final pulse = 0.5 + 0.5 * math.sin(t * math.pi * 2);
    final lifting = label.contains('lift');
    final releasing =
        label.contains('release') || label.contains('drop') || label.contains('let go');
    final settling = label.contains('settle');
    final verticalShift = lifting
        ? -base * (0.025 + pulse * 0.010)
        : releasing
        ? base * (0.020 + pulse * 0.005)
        : settling
        ? base * 0.011
        : 0.0;

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(center.dx, center.dy - base * 0.035),
        width: base * 0.54,
        height: base * 0.48,
      ),
      Paint()
        ..color = ReleafColors.sage.withValues(alpha: 0.045 + pulse * 0.025)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 28),
    );

    final figurePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(3.1, base * 0.0115)
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = ReleafColors.textPrimary.withValues(alpha: 0.56);
    final ghostPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(2.2, base * 0.008)
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = ReleafColors.textPrimary.withValues(alpha: 0.16);
    final accentPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(4.5, base * 0.0165)
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = ReleafColors.sage.withValues(alpha: 0.90);
    final glowPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(10.0, base * 0.036)
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = ReleafColors.sage.withValues(alpha: 0.15 + pulse * 0.10)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15);
    final trackPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(1.3, base * 0.0045)
      ..strokeCap = StrokeCap.round
      ..color = ReleafColors.sage.withValues(alpha: 0.22);

    final head = Offset(center.dx, center.dy - base * 0.19);
    final headRadius = base * 0.071;
    final neckBottom = Offset(center.dx, center.dy - base * 0.075);
    canvas.drawCircle(head, headRadius, figurePaint);
    canvas.drawLine(
      Offset(center.dx, head.dy + headRadius),
      neckBottom,
      figurePaint,
    );

    final neutralY = center.dy - base * 0.045;
    final neutralLeft = Offset(center.dx - base * 0.19, neutralY);
    final neutralRight = Offset(center.dx + base * 0.19, neutralY);
    final neutralPath = Path()
      ..moveTo(neutralLeft.dx, neutralLeft.dy)
      ..quadraticBezierTo(
        center.dx - base * 0.08,
        neutralY - base * 0.025,
        neckBottom.dx,
        neckBottom.dy,
      )
      ..quadraticBezierTo(
        center.dx + base * 0.08,
        neutralY - base * 0.025,
        neutralRight.dx,
        neutralRight.dy,
      );
    canvas.drawPath(neutralPath, ghostPaint);

    final shoulderY = neutralY + verticalShift;
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

    final movementActive = lifting || releasing || settling;
    if (movementActive) {
      for (final x in [neutralLeft.dx, neutralRight.dx]) {
        final top = neutralY - base * 0.055;
        final bottom = neutralY + base * 0.055;
        canvas.drawLine(Offset(x, top), Offset(x, bottom), trackPaint);
        canvas.drawCircle(
          Offset(x, neutralY),
          base * 0.008,
          Paint()..color = ReleafColors.textPrimary.withValues(alpha: 0.24),
        );
        canvas.drawCircle(
          Offset(x, shoulderY),
          base * 0.010,
          Paint()..color = ReleafColors.sage.withValues(alpha: 0.76),
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
