import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../releaf_design_tokens.dart';

/// Interactive visual for sensory grounding.
///
/// For sensory phases the user taps the halo whenever they notice one item.
/// Completed anchors visibly change state so the exercise feels active rather
/// than like a passive timer. Non-counting phases remain calm and ambient.
class ReleafSensoryHalo extends StatefulWidget {
  const ReleafSensoryHalo({
    super.key,
    required this.progress,
    required this.targetCount,
    required this.completedCount,
    required this.phaseLabel,
    this.onNotice,
    this.reducedMotion = false,
  });

  final double progress;
  final int targetCount;
  final int completedCount;
  final String phaseLabel;
  final VoidCallback? onNotice;
  final bool reducedMotion;

  @override
  State<ReleafSensoryHalo> createState() => _ReleafSensoryHaloState();
}

class _ReleafSensoryHaloState extends State<ReleafSensoryHalo>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  int get _target => widget.targetCount.clamp(0, 5).toInt();
  int get _completed => widget.completedCount.clamp(0, _target).toInt();
  int get _remaining => math.max(0, _target - _completed);

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
  void didUpdateWidget(covariant ReleafSensoryHalo oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.reducedMotion != widget.reducedMotion) _sync();
  }

  void _sync() {
    if (widget.reducedMotion) {
      _controller.stop();
      _controller.value = 0.22;
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
    final interactive = _target > 0 && widget.onNotice != null;

    return Semantics(
      container: true,
      button: interactive,
      onTap: interactive ? widget.onNotice : null,
      label: _semanticLabel,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: interactive ? widget.onNotice : null,
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
                  targetCount: _target,
                  completedCount: _completed,
                ),
                child: Center(
                  child: AnimatedSwitcher(
                    duration: ReleafMotion.standard,
                    switchInCurve: ReleafMotion.entranceCurve,
                    child: _CenterReadout(
                      key: ValueKey(
                        '${widget.phaseLabel}-$_target-$_completed',
                      ),
                      phaseLabel: widget.phaseLabel,
                      targetCount: _target,
                      remainingCount: _remaining,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  String get _semanticLabel {
    if (_target <= 0) {
      return 'Sensory grounding. ${widget.phaseLabel}.';
    }

    if (_remaining == 0) {
      return 'Sensory grounding. ${widget.phaseLabel}. Step complete.';
    }

    return 'Sensory grounding. ${widget.phaseLabel}. '
        '$_remaining of $_target left. Tap when you notice one.';
  }
}

class _CenterReadout extends StatelessWidget {
  const _CenterReadout({
    super.key,
    required this.phaseLabel,
    required this.targetCount,
    required this.remainingCount,
  });

  final String phaseLabel;
  final int targetCount;
  final int remainingCount;

  @override
  Widget build(BuildContext context) {
    final completed = targetCount > 0 && remainingCount == 0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (targetCount > 0)
          completed
              ? const Icon(
                  Icons.check_rounded,
                  key: Key('reset-sensory-step-complete'),
                  size: 52,
                  color: ReleafColors.sage,
                )
              : Text(
                  remainingCount.toString(),
                  key: const Key('reset-sensory-remaining'),
                  style: ReleafTypography.display.copyWith(
                    fontSize: 54,
                    color: ReleafColors.textPrimary.withValues(alpha: 0.94),
                  ),
                )
        else
          Icon(
            Icons.blur_on_rounded,
            size: 42,
            color: ReleafColors.sage.withValues(alpha: 0.78),
          ),
        const SizedBox(height: 5),
        Text(
          phaseLabel.toUpperCase(),
          style: ReleafTypography.eyebrow.copyWith(
            color: ReleafColors.sage,
            letterSpacing: 1.35,
          ),
        ),
      ],
    );
  }
}

class _SensoryHaloPainter extends CustomPainter {
  const _SensoryHaloPainter({
    required this.t,
    required this.targetCount,
    required this.completedCount,
  });

  final double t;
  final int targetCount;
  final int completedCount;

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

    final pulse = 0.90 + (math.sin(t * math.pi * 2) * 0.08);
    canvas.drawCircle(
      center,
      radius * 0.72 * pulse,
      Paint()
        ..color = ReleafColors.sage.withValues(alpha: 0.09)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 28),
    );

    final count = targetCount <= 0 ? 5 : targetCount;
    for (var i = 0; i < count; i++) {
      final baseAngle = (-math.pi / 2) + ((math.pi * 2 / count) * i);
      final drift = math.sin((t * math.pi * 2) + (i * 0.9)) * 0.055;
      final angle = baseAngle + drift;
      final point = Offset(
        center.dx + math.cos(angle) * radius,
        center.dy + math.sin(angle) * radius,
      );

      final done = targetCount > 0 && i < completedCount;
      final dotColor = done
          ? ReleafColors.premium
          : ReleafColors.sage.withValues(
              alpha: targetCount <= 0 ? 0.58 : 0.92,
            );

      canvas.drawCircle(
        point,
        done ? 20 : 16,
        Paint()
          ..color = dotColor.withValues(alpha: done ? 0.18 : 0.12)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 9),
      );

      canvas.drawCircle(
        point,
        done ? 8.0 : 6.5,
        Paint()..color = dotColor,
      );

      if (done) {
        canvas.drawCircle(
          point,
          2.2,
          Paint()
            ..color = ReleafColors.textPrimary.withValues(alpha: 0.82),
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _SensoryHaloPainter oldDelegate) {
    return oldDelegate.t != t ||
        oldDelegate.targetCount != targetCount ||
        oldDelegate.completedCount != completedCount;
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
