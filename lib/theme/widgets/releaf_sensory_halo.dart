import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../releaf_design_tokens.dart';

/// Distinct Reset visual for sensory grounding.
///
/// The halo changes the number of active anchors as a 5-4-3-2-1 practice
/// progresses, giving the user a calm visual structure without implying
/// breathing.
class ReleafSensoryHalo extends StatefulWidget {
  const ReleafSensoryHalo({
    super.key,
    required this.progress,
    required this.activeCount,
    required this.phaseLabel,
    this.reducedMotion = false,
  });

  final double progress;
  final int activeCount;
  final String phaseLabel;
  final bool reducedMotion;

  @override
  State<ReleafSensoryHalo> createState() => _ReleafSensoryHaloState();
}

class _ReleafSensoryHaloState extends State<ReleafSensoryHalo>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 14),
    );
    _sync();
  }

  @override
  void didUpdateWidget(covariant ReleafSensoryHalo oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.reducedMotion != widget.reducedMotion) _sync();
  }

  void _sync() {
    if (widget.reducedMotion) {
      _controller.stop();
      _controller.value = 0.28;
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
      label:
          'Sensory grounding. ${widget.phaseLabel}. ${widget.activeCount} anchors.',
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: progress),
        duration: const Duration(milliseconds: 720),
        curve: Curves.easeOutCubic,
        builder: (context, animatedProgress, child) {
          return CustomPaint(
            key: const Key('reset-sensory-halo'),
            painter: _SensoryProgressPainter(progress: animatedProgress),
            child: child,
          );
        },
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return CustomPaint(
              painter: _SensoryHaloPainter(
                t: _controller.value,
                activeCount: widget.activeCount.clamp(1, 5).toInt(),
              ),
              child: Center(
                child: AnimatedSwitcher(
                  duration: ReleafMotion.standard,
                  child: Column(
                    key: ValueKey('${widget.phaseLabel}-${widget.activeCount}'),
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.activeCount.toString(),
                        style: ReleafTypography.display.copyWith(
                          fontSize: 54,
                          color: ReleafColors.textPrimary.withValues(alpha: 0.92),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.phaseLabel.toUpperCase(),
                        style: ReleafTypography.eyebrow.copyWith(
                          color: ReleafColors.sage,
                          letterSpacing: 1.3,
                        ),
                      ),
                    ],
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

class _SensoryHaloPainter extends CustomPainter {
  const _SensoryHaloPainter({required this.t, required this.activeCount});

  final double t;
  final int activeCount;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.shortestSide * 0.31;

    canvas.drawCircle(
      center,
      radius * 1.28,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..color = ReleafColors.borderSoft.withValues(alpha: 0.42),
    );

    canvas.drawCircle(
      center,
      radius * 0.72,
      Paint()
        ..color = ReleafColors.sage.withValues(alpha: 0.08)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 28),
    );

    for (var i = 0; i < 5; i++) {
      final baseAngle = (-math.pi / 2) + ((math.pi * 2 / 5) * i);
      final drift = math.sin((t * math.pi * 2) + i) * 0.035;
      final angle = baseAngle + drift;
      final point = Offset(
        center.dx + math.cos(angle) * radius,
        center.dy + math.sin(angle) * radius,
      );
      final active = i < activeCount;
      final dotRadius = active ? 7.0 : 4.0;

      if (active) {
        canvas.drawCircle(
          point,
          18,
          Paint()
            ..color = ReleafColors.sage.withValues(alpha: 0.13)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 9),
        );
      }

      canvas.drawCircle(
        point,
        dotRadius,
        Paint()
          ..color = active
              ? ReleafColors.sage
              : ReleafColors.textMuted.withValues(alpha: 0.20),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _SensoryHaloPainter oldDelegate) {
    return oldDelegate.t != t || oldDelegate.activeCount != activeCount;
  }
}

class _SensoryProgressPainter extends CustomPainter {
  const _SensoryProgressPainter({required this.progress});

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
        ..color = ReleafColors.borderSoft.withValues(alpha: 0.42),
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
        ..color = ReleafColors.sage.withValues(alpha: 0.82),
    );
  }

  @override
  bool shouldRepaint(covariant _SensoryProgressPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
