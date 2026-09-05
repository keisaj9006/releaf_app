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

  bool get _isReleasePhase {
    final label = widget.phaseLabel.toLowerCase();
    return label.contains('release') ||
        label.contains('let go') ||
        label.contains('notice');
  }

  bool get _isTensionPhase {
    final label = widget.phaseLabel.toLowerCase();
    return label.contains('shoulders') ||
        label.contains('again') ||
        label.contains('press');
  }

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
      label: 'Body reset. ${widget.phaseLabel}.',
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
                tension: _isTensionPhase,
                release: _isReleasePhase,
              ),
              child: Center(
                child: AnimatedSwitcher(
                  duration: ReleafMotion.standard,
                  child: Column(
                    key: ValueKey(widget.phaseLabel),
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _isReleasePhase
                            ? Icons.expand_more_rounded
                            : _isTensionPhase
                                ? Icons.expand_less_rounded
                                : Icons.self_improvement_rounded,
                        size: 46,
                        color: ReleafColors.sage,
                      ),
                      const SizedBox(height: 6),
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

class _BodyReleasePainter extends CustomPainter {
  const _BodyReleasePainter({
    required this.t,
    required this.tension,
    required this.release,
  });

  final double t;
  final bool tension;
  final bool release;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;

    final center = Offset(size.width / 2, size.height / 2);
    final base = size.shortestSide * 0.27;
    final pulse = math.sin(t * math.pi * 2) * 0.04;

    final contraction = tension ? 0.78 : (release ? 1.12 : 1.0);
    final glowAlpha = tension ? 0.13 : (release ? 0.22 : 0.16);

    canvas.drawCircle(
      center,
      base * (0.70 + pulse),
      Paint()
        ..color = ReleafColors.sage.withValues(alpha: glowAlpha)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 28),
    );

    final shoulderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..color = ReleafColors.sage.withValues(alpha: 0.74);

    final y = center.dy + (release ? 16 : (tension ? -14 : 0));
    final span = base * 1.55 * contraction;

    final leftRect = Rect.fromCenter(
      center: Offset(center.dx - base * 0.78, y),
      width: span,
      height: base * 0.9,
    );
    final rightRect = Rect.fromCenter(
      center: Offset(center.dx + base * 0.78, y),
      width: span,
      height: base * 0.9,
    );

    canvas.drawArc(
      leftRect,
      -math.pi * 0.10,
      math.pi * 0.62,
      false,
      shoulderPaint,
    );
    canvas.drawArc(
      rightRect,
      math.pi * 0.48,
      math.pi * 0.62,
      false,
      shoulderPaint,
    );

    canvas.drawCircle(
      center,
      base * 0.12,
      Paint()..color = ReleafColors.premium.withValues(alpha: 0.86),
    );
  }

  @override
  bool shouldRepaint(covariant _BodyReleasePainter oldDelegate) {
    return oldDelegate.t != t ||
        oldDelegate.tension != tension ||
        oldDelegate.release != release;
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
