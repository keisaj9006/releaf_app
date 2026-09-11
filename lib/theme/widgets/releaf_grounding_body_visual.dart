import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../releaf_design_tokens.dart';

/// A lightweight illustrated guide for body-contact grounding.
///
/// The figure stays intentionally abstract and inclusive while making the
/// physical instruction unmistakable: sit with both feet supported, then
/// notice contact at the feet, seat and back. It is drawn at runtime so it
/// adds no video/image payload and respects reduced-motion preferences.
class ReleafGroundingBodyVisual extends StatefulWidget {
  const ReleafGroundingBodyVisual({
    super.key,
    required this.progress,
    required this.phaseLabel,
    this.reducedMotion = false,
  });

  final double progress;
  final String phaseLabel;
  final bool reducedMotion;

  @override
  State<ReleafGroundingBodyVisual> createState() =>
      _ReleafGroundingBodyVisualState();
}

class _ReleafGroundingBodyVisualState
    extends State<ReleafGroundingBodyVisual>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 7),
    );
    _syncMotion();
  }

  @override
  void didUpdateWidget(covariant ReleafGroundingBodyVisual oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.reducedMotion != widget.reducedMotion) _syncMotion();
  }

  void _syncMotion() {
    if (widget.reducedMotion) {
      _controller.stop();
      _controller.value = 0.28;
    } else if (!_controller.isAnimating) {
      _controller.repeat();
    }
  }

  String get _semanticInstruction {
    final phase = widget.phaseLabel.toLowerCase();
    if (phase.contains('arrive')) {
      return 'Illustrated grounding guide. Place both feet on the floor.';
    }
    if (phase.contains('feel')) {
      return 'Illustrated grounding guide. Notice support under the feet and seat.';
    }
    if (phase.contains('notice')) {
      return 'Illustrated grounding guide. Notice where the body meets the chair and floor.';
    }
    return 'Illustrated grounding guide. Let the body settle into its support.';
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
      label: _semanticInstruction,
      child: ExcludeSemantics(
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: progress),
          duration: const Duration(milliseconds: 720),
          curve: Curves.easeOutCubic,
          builder: (context, animatedProgress, child) {
            return AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                return Stack(
                  fit: StackFit.expand,
                  children: [
                    CustomPaint(
                      key: const Key('reset-grounding-body-visual'),
                      painter: _GroundingBodyPainter(
                        t: _controller.value,
                        progress: animatedProgress,
                        phaseLabel: widget.phaseLabel,
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: AnimatedSwitcher(
                        duration: ReleafMotion.standard,
                        child: Padding(
                          key: ValueKey(widget.phaseLabel),
                          padding: const EdgeInsets.only(bottom: 30),
                          child: Text(
                            widget.phaseLabel,
                            style: ReleafTypography.eyebrow.copyWith(
                              color: ReleafColors.sage,
                              letterSpacing: 1.3,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _GroundingBodyPainter extends CustomPainter {
  const _GroundingBodyPainter({
    required this.t,
    required this.progress,
    required this.phaseLabel,
  });

  final double t;
  final double progress;
  final String phaseLabel;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;

    final width = size.shortestSide;
    final center = Offset(size.width / 2, size.height / 2);
    final phase = phaseLabel.toLowerCase();
    final showFeet = phase.contains('arrive') || phase.contains('feel');
    final showSeat = phase.contains('feel') || phase.contains('notice');
    final showBack = phase.contains('notice');
    final showAll = phase.contains('release');
    final pulse = 0.5 + 0.5 * math.sin(t * math.pi * 2);

    canvas.drawCircle(
      Offset(center.dx, center.dy + width * 0.08),
      width * (0.31 + pulse * 0.008),
      Paint()
        ..color = ReleafColors.sage.withValues(alpha: 0.075 + pulse * 0.025)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 32),
    );

    final figurePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(3.5, width * 0.014)
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = ReleafColors.textPrimary.withValues(alpha: 0.72);
    final supportPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(2.0, width * 0.007)
      ..strokeCap = StrokeCap.round
      ..color = ReleafColors.textMuted.withValues(alpha: 0.30);

    final headCenter = Offset(center.dx, center.dy - width * 0.25);
    canvas.drawCircle(headCenter, width * 0.055, figurePaint);

    final neck = Offset(center.dx, center.dy - width * 0.175);
    final hips = Offset(center.dx, center.dy + width * 0.025);
    final bodyPath = Path()
      ..moveTo(neck.dx, neck.dy)
      ..quadraticBezierTo(
        center.dx - width * 0.018,
        center.dy - width * 0.06,
        hips.dx,
        hips.dy,
      );
    canvas.drawPath(bodyPath, figurePaint);

    final shoulderY = center.dy - width * 0.145;
    canvas.drawLine(
      Offset(center.dx - width * 0.105, shoulderY),
      Offset(center.dx + width * 0.105, shoulderY),
      figurePaint,
    );
    canvas.drawArc(
      Rect.fromCenter(
        center: Offset(center.dx, center.dy - width * 0.045),
        width: width * 0.27,
        height: width * 0.23,
      ),
      math.pi * 0.03,
      math.pi * 0.94,
      false,
      figurePaint,
    );

    final floorY = center.dy + width * 0.30;
    final seatY = center.dy + width * 0.045;
    canvas.drawLine(
      Offset(center.dx - width * 0.31, floorY),
      Offset(center.dx + width * 0.31, floorY),
      supportPaint,
    );
    canvas.drawLine(
      Offset(center.dx - width * 0.18, seatY),
      Offset(center.dx + width * 0.18, seatY),
      supportPaint,
    );
    canvas.drawLine(
      Offset(center.dx - width * 0.18, center.dy - width * 0.18),
      Offset(center.dx - width * 0.18, seatY),
      supportPaint,
    );

    final leftKnee = Offset(center.dx - width * 0.145, center.dy + width * 0.11);
    final rightKnee = Offset(center.dx + width * 0.145, center.dy + width * 0.11);
    final leftAnkle = Offset(center.dx - width * 0.145, floorY - width * 0.022);
    final rightAnkle = Offset(center.dx + width * 0.145, floorY - width * 0.022);
    canvas.drawLine(hips, leftKnee, figurePaint);
    canvas.drawLine(hips, rightKnee, figurePaint);
    canvas.drawLine(leftKnee, leftAnkle, figurePaint);
    canvas.drawLine(rightKnee, rightAnkle, figurePaint);

    final footSize = Size(width * 0.12, width * 0.035);
    final leftFoot = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(leftAnkle.dx + width * 0.035, floorY),
        width: footSize.width,
        height: footSize.height,
      ),
      Radius.circular(width * 0.018),
    );
    final rightFoot = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(rightAnkle.dx + width * 0.035, floorY),
        width: footSize.width,
        height: footSize.height,
      ),
      Radius.circular(width * 0.018),
    );
    canvas.drawRRect(leftFoot, figurePaint);
    canvas.drawRRect(rightFoot, figurePaint);

    final contactPaint = Paint()
      ..color = ReleafColors.sage.withValues(alpha: 0.74)
      ..maskFilter = MaskFilter.blur(
        BlurStyle.normal,
        width * (0.028 + pulse * 0.009),
      );
    void contact(Offset point, double strength) {
      canvas.drawCircle(
        point,
        width * (0.025 + pulse * 0.006) * strength,
        contactPaint,
      );
      canvas.drawCircle(
        point,
        width * 0.010,
        Paint()..color = ReleafColors.sage.withValues(alpha: 0.92),
      );
    }

    if (showFeet || showAll) {
      contact(Offset(leftAnkle.dx + width * 0.035, floorY), 1);
      contact(Offset(rightAnkle.dx + width * 0.035, floorY), 1);
    }
    if (showSeat || showAll) contact(hips, 1.05);
    if (showBack || showAll) {
      contact(Offset(center.dx - width * 0.17, center.dy - width * 0.06), 0.9);
    }

    final stroke = math.max(1.0, width * 0.0055);
    final ring = Rect.fromCircle(
      center: center,
      radius: width / 2 - stroke,
    );
    canvas.drawArc(
      ring,
      -math.pi / 2,
      math.pi * 2,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..color = ReleafColors.borderSoft.withValues(alpha: 0.34),
    );
    canvas.drawArc(
      ring,
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
  bool shouldRepaint(covariant _GroundingBodyPainter oldDelegate) {
    return oldDelegate.t != t ||
        oldDelegate.progress != progress ||
        oldDelegate.phaseLabel != phaseLabel;
  }
}
