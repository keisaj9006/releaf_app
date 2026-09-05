import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../releaf_design_tokens.dart';

/// Dedicated low-cognitive-load visual for Emergency mode.
///
/// The visual intentionally avoids the Releaf Living Form, game-like progress
/// and premium cues. It keeps one steady anchor in the centre while the icon
/// changes with the current grounding cue.
class ReleafEmergencyVisual extends StatefulWidget {
  const ReleafEmergencyVisual({
    super.key,
    required this.progress,
    required this.phaseLabel,
    this.reducedMotion = false,
  });

  final double progress;
  final String phaseLabel;
  final bool reducedMotion;

  @override
  State<ReleafEmergencyVisual> createState() =>
      _ReleafEmergencyVisualState();
}

class _ReleafEmergencyVisualState extends State<ReleafEmergencyVisual>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    );
    _syncMotion();
  }

  @override
  void didUpdateWidget(covariant ReleafEmergencyVisual oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.reducedMotion != widget.reducedMotion) {
      _syncMotion();
    }
  }

  void _syncMotion() {
    if (widget.reducedMotion) {
      _controller
        ..stop()
        ..value = 0.34;
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
    final safeProgress = widget.progress.clamp(0.0, 1.0).toDouble();

    return Semantics(
      container: true,
      label: 'Emergency grounding anchor. ${widget.phaseLabel}.',
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final pulse = widget.reducedMotion
              ? 0.38
              : (math.sin(_controller.value * math.pi * 2) + 1) / 2;

          return Stack(
            key: const Key('emergency-calming-visual'),
            fit: StackFit.expand,
            alignment: Alignment.center,
            children: [
              CustomPaint(
                key: const Key('emergency-anchor-field'),
                painter: _EmergencyAnchorPainter(
                  pulse: pulse,
                  progress: safeProgress,
                ),
              ),
              Center(
                child: AnimatedScale(
                  scale: widget.reducedMotion ? 1 : 0.99 + pulse * 0.018,
                  duration: widget.reducedMotion
                      ? Duration.zero
                      : ReleafMotion.standard,
                  child: Container(
                    width: 92,
                    height: 92,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF121714).withValues(alpha: 0.92),
                      border: Border.all(
                        color: ReleafFeatureAccents.emergency.withValues(
                          alpha: 0.34,
                        ),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: ReleafFeatureAccents.emergency.withValues(
                            alpha: 0.08 + pulse * 0.06,
                          ),
                          blurRadius: 34,
                          spreadRadius: 3,
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: AnimatedSwitcher(
                      duration: widget.reducedMotion
                          ? Duration.zero
                          : ReleafMotion.standard,
                      child: Icon(
                        _phaseIcon(widget.phaseLabel),
                        key: ValueKey(widget.phaseLabel),
                        size: 32,
                        color: const Color(0xFFF0E8D8),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

IconData _phaseIcon(String phaseLabel) {
  return switch (phaseLabel.toLowerCase()) {
    'arrive' => Icons.vertical_align_bottom_rounded,
    'look' => Icons.visibility_outlined,
    'feel' => Icons.touch_app_outlined,
    'listen' => Icons.hearing_rounded,
    'return' => Icons.my_location_rounded,
    _ => Icons.adjust_rounded,
  };
}

class _EmergencyAnchorPainter extends CustomPainter {
  const _EmergencyAnchorPainter({
    required this.pulse,
    required this.progress,
  });

  final double pulse;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;

    final center = Offset(size.width / 2, size.height * 0.52);
    final short = size.shortestSide;
    final accent = ReleafFeatureAccents.emergency;

    final glowRect = Rect.fromCenter(
      center: center,
      width: short * 1.10,
      height: short * 0.72,
    );
    canvas.drawOval(
      glowRect,
      Paint()
        ..shader = RadialGradient(
          colors: [
            accent.withValues(alpha: 0.10 + pulse * 0.04),
            accent.withValues(alpha: 0.025),
            Colors.transparent,
          ],
          stops: const [0, 0.55, 1],
        ).createShader(glowRect),
    );

    final horizonPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 1.15;

    for (var index = 0; index < 4; index++) {
      final widthFactor = 0.42 + index * 0.16 + pulse * 0.015;
      final heightFactor = 0.10 + index * 0.045;
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(center.dx, center.dy + short * 0.10),
          width: short * widthFactor,
          height: short * heightFactor,
        ),
        horizonPaint
          ..color = accent.withValues(alpha: 0.15 - index * 0.022),
      );
    }

    canvas.drawLine(
      Offset(size.width * 0.12, center.dy + short * 0.11),
      Offset(size.width * 0.88, center.dy + short * 0.11),
      Paint()
        ..strokeWidth = 1
        ..color = ReleafColors.textSecondary.withValues(alpha: 0.10),
    );

    final anchorRadius = short * 0.075;
    canvas.drawCircle(
      Offset(center.dx, center.dy + short * 0.11),
      anchorRadius,
      Paint()
        ..color = accent.withValues(alpha: 0.10 + progress * 0.03)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12),
    );

    for (var index = 0; index < 8; index++) {
      final angle = (math.pi * 2 / 8) * index;
      final radius = short * (0.29 + (index.isEven ? 0.03 : 0));
      canvas.drawCircle(
        Offset(
          center.dx + math.cos(angle) * radius,
          center.dy + math.sin(angle) * radius * 0.68,
        ),
        index % 3 == 0 ? 1.4 : 0.75,
        Paint()
          ..color = ReleafColors.textPrimary.withValues(
            alpha: index % 3 == 0 ? 0.18 : 0.07,
          ),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _EmergencyAnchorPainter oldDelegate) {
    return oldDelegate.pulse != pulse || oldDelegate.progress != progress;
  }
}
