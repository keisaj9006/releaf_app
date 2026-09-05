import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../releaf_design_tokens.dart';

/// ACT-informed visual metaphor: the thought remains present while gaining
/// distance from the center of attention. It is not erased or "fixed".
class ReleafThoughtUnhookVisual extends StatefulWidget {
  const ReleafThoughtUnhookVisual({
    super.key,
    required this.progress,
    required this.phaseLabel,
    this.reducedMotion = false,
  });

  final double progress;
  final String phaseLabel;
  final bool reducedMotion;

  @override
  State<ReleafThoughtUnhookVisual> createState() =>
      _ReleafThoughtUnhookVisualState();
}

class _ReleafThoughtUnhookVisualState extends State<ReleafThoughtUnhookVisual>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  double get _distance {
    final label = widget.phaseLabel.toLowerCase();
    if (label.contains('notice')) return 0.16;
    if (label.contains('name')) return 0.26;
    if (label.contains('unhook')) return 0.50;
    if (label.contains('space')) return 0.72;
    if (label.contains('refocus')) return 0.82;
    return 0.30;
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    );
    _sync();
  }

  @override
  void didUpdateWidget(covariant ReleafThoughtUnhookVisual oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.reducedMotion != widget.reducedMotion) _sync();
  }

  void _sync() {
    if (widget.reducedMotion) {
      _controller.stop();
      _controller.value = 0.24;
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
      label: 'Thought exercise. ${widget.phaseLabel}.',
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: progress),
        duration: const Duration(milliseconds: 720),
        curve: Curves.easeOutCubic,
        builder: (context, animatedProgress, child) {
          return CustomPaint(
            key: const Key('reset-thought-unhook-visual'),
            painter: _ThoughtProgressPainter(progress: animatedProgress),
            child: child,
          );
        },
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return CustomPaint(
              painter: _ThoughtUnhookPainter(
                t: _controller.value,
                distance: _distance,
              ),
              child: Center(
                child: AnimatedSwitcher(
                  duration: ReleafMotion.standard,
                  child: Text(
                    widget.phaseLabel.toUpperCase(),
                    key: ValueKey(widget.phaseLabel),
                    style: ReleafTypography.eyebrow.copyWith(
                      color: ReleafColors.sage,
                      letterSpacing: 1.3,
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

class _ThoughtUnhookPainter extends CustomPainter {
  const _ThoughtUnhookPainter({
    required this.t,
    required this.distance,
  });

  final double t;
  final double distance;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.shortestSide * 0.32;
    final wobble = math.sin(t * math.pi * 2) * 0.035;
    final angle = -math.pi * 0.18 + wobble;
    final separation = radius * distance;
    final thoughtPoint = Offset(
      center.dx + math.cos(angle) * separation,
      center.dy + math.sin(angle) * separation,
    );

    canvas.drawCircle(
      center,
      radius * 0.74,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..color = ReleafColors.borderSoft.withValues(alpha: 0.40),
    );

    final path = Path()
      ..moveTo(center.dx, center.dy)
      ..quadraticBezierTo(
        center.dx + separation * 0.30,
        center.dy - radius * 0.18,
        thoughtPoint.dx,
        thoughtPoint.dy,
      );

    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.4
        ..strokeCap = StrokeCap.round
        ..color = ReleafColors.sage.withValues(alpha: 0.48),
    );

    canvas.drawCircle(
      center,
      12,
      Paint()
        ..color = ReleafColors.sage.withValues(alpha: 0.16)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );
    canvas.drawCircle(
      center,
      5,
      Paint()..color = ReleafColors.sage,
    );

    canvas.drawCircle(
      thoughtPoint,
      18,
      Paint()
        ..color = ReleafColors.premium.withValues(alpha: 0.16)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 9),
    );
    canvas.drawCircle(
      thoughtPoint,
      7,
      Paint()..color = ReleafColors.premium,
    );
  }

  @override
  bool shouldRepaint(covariant _ThoughtUnhookPainter oldDelegate) {
    return oldDelegate.t != t || oldDelegate.distance != distance;
  }
}

class _ThoughtProgressPainter extends CustomPainter {
  const _ThoughtProgressPainter({required this.progress});

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
        ..color = ReleafColors.premium.withValues(alpha: 0.82),
    );
  }

  @override
  bool shouldRepaint(covariant _ThoughtProgressPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
