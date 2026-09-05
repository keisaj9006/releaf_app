import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../releaf_design_tokens.dart';
import 'releaf_artwork.dart';

/// Signature animated Releaf form used during active Reset sessions.
///
/// The motion is deliberately subtle and presentation-only. Session timing,
/// rewards and instructions remain owned by the Reset feature.
class ReleafSessionLivingForm extends StatefulWidget {
  const ReleafSessionLivingForm({
    super.key,
    required this.variant,
    required this.progress,
    required this.breathing,
    this.phaseLabel,
    this.inhaleSeconds = 4,
    this.holdAfterInhaleSeconds = 0,
    this.exhaleSeconds = 4,
    this.holdAfterExhaleSeconds = 0,
    this.reducedMotion = false,
  });

  final ReleafArtworkVariant variant;
  final double progress;
  final bool breathing;
  final String? phaseLabel;
  final int inhaleSeconds;
  final int holdAfterInhaleSeconds;
  final int exhaleSeconds;
  final int holdAfterExhaleSeconds;
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
      duration: Duration(seconds: _cycleSecondsFor(widget)),
    );
    _syncAnimation();
  }

  @override
  void didUpdateWidget(covariant ReleafSessionLivingForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.breathing != widget.breathing ||
        oldWidget.inhaleSeconds != widget.inhaleSeconds ||
        oldWidget.holdAfterInhaleSeconds != widget.holdAfterInhaleSeconds ||
        oldWidget.exhaleSeconds != widget.exhaleSeconds ||
        oldWidget.holdAfterExhaleSeconds != widget.holdAfterExhaleSeconds) {
      _controller.duration = Duration(seconds: _cycleSecondsFor(widget));
    }
    if (oldWidget.reducedMotion != widget.reducedMotion ||
        oldWidget.breathing != widget.breathing ||
        oldWidget.inhaleSeconds != widget.inhaleSeconds ||
        oldWidget.holdAfterInhaleSeconds != widget.holdAfterInhaleSeconds ||
        oldWidget.exhaleSeconds != widget.exhaleSeconds ||
        oldWidget.holdAfterExhaleSeconds != widget.holdAfterExhaleSeconds) {
      _syncAnimation();
    }
  }

  void _syncAnimation() {
    if (widget.reducedMotion) {
      _controller.stop();
      _controller.value = 0.42;
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
      label: widget.phaseLabel == null
          ? 'Releaf calming visual'
          : 'Releaf calming visual. ${widget.phaseLabel}',
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0, end: progress),
        duration: const Duration(milliseconds: 720),
        curve: Curves.easeOutCubic,
        builder: (context, animatedProgress, child) {
          return CustomPaint(
            key: const Key('reset-living-form'),
            painter: _SessionProgressPainter(
              progress: animatedProgress,
            ),
            child: child,
          );
        },
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final motion = _motionValue(_controller.value);
            final breathingScale = widget.breathing
                ? 0.94 + (motion * 0.12)
                : 0.955 + (motion * 0.075);
            final glowOpacity = widget.breathing
                ? 0.15 + (motion * 0.18)
                : 0.12 + (motion * 0.13);
            final driftX =
                widget.breathing ? 0.0 : math.sin(_controller.value * math.pi * 2) * 5;
            final driftY =
                widget.breathing ? 0.0 : math.cos(_controller.value * math.pi * 2) * 3;
            final rotation =
                widget.breathing ? 0.0 : math.sin(_controller.value * math.pi * 2) * 0.018;

            return AspectRatio(
              aspectRatio: 1,
              child: Stack(
                fit: StackFit.expand,
                alignment: Alignment.center,
                children: [
                  Center(
                    child: FractionallySizedBox(
                      widthFactor: 0.78,
                      heightFactor: 0.78,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: ReleafColors.sage.withValues(
                                alpha: glowOpacity,
                              ),
                              blurRadius: 58,
                              spreadRadius: 10,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Center(
                    child: Transform.translate(
                      offset: Offset(driftX, driftY),
                      child: Transform.rotate(
                        angle: rotation,
                        child: Transform.scale(
                          scale: breathingScale,
                          child: FractionallySizedBox(
                            widthFactor: 0.78,
                            heightFactor: 0.78,
                            child: ReleafLivingForm(
                              variant: widget.variant,
                              opacity: 0.96,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Center(
                    child: AnimatedOpacity(
                      duration: ReleafMotion.standard,
                      opacity: widget.phaseLabel == null ? 0 : 1,
                      child: Text(
                        widget.phaseLabel ?? '',
                        textAlign: TextAlign.center,
                        style: ReleafTypography.sectionTitle.copyWith(
                          fontSize: 17,
                          color: ReleafColors.textPrimary.withValues(
                            alpha: 0.90,
                          ),
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  double _motionValue(double t) {
    if (!widget.breathing) {
      return (math.sin(t * math.pi * 2) + 1) / 2;
    }

    final total = _cycleSecondsFor(widget).toDouble();
    final inhaleEnd = widget.inhaleSeconds / total;
    final holdInEnd =
        (widget.inhaleSeconds + widget.holdAfterInhaleSeconds) / total;
    final exhaleEnd =
        (widget.inhaleSeconds +
            widget.holdAfterInhaleSeconds +
            widget.exhaleSeconds) /
        total;

    if (t < inhaleEnd) {
      return inhaleEnd == 0 ? 1 : t / inhaleEnd;
    }
    if (t < holdInEnd) return 1;
    if (t < exhaleEnd) {
      final span = exhaleEnd - holdInEnd;
      return span == 0 ? 0 : 1 - ((t - holdInEnd) / span);
    }
    return 0;
  }

  static int _cycleSecondsFor(ReleafSessionLivingForm widget) {
    if (!widget.breathing) return 12;
    final total =
        widget.inhaleSeconds +
        widget.holdAfterInhaleSeconds +
        widget.exhaleSeconds +
        widget.holdAfterExhaleSeconds;
    return math.max(1, total);
  }
}

class _SessionProgressPainter extends CustomPainter {
  const _SessionProgressPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;

    final strokeWidth = math.max(1.0, size.shortestSide * 0.006);
    final rect = Rect.fromLTWH(
      strokeWidth,
      strokeWidth,
      size.width - (strokeWidth * 2),
      size.height - (strokeWidth * 2),
    );

    canvas.drawArc(
      rect,
      -math.pi / 2,
      math.pi * 2,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round
        ..color = ReleafColors.borderSoft.withValues(alpha: 0.55),
    );

    canvas.drawArc(
      rect,
      -math.pi / 2,
      math.pi * 2 * progress,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round
        ..shader = const SweepGradient(
          colors: [
            ReleafColors.sageStrong,
            ReleafColors.sage,
            ReleafColors.premium,
          ],
        ).createShader(rect),
    );
  }

  @override
  bool shouldRepaint(covariant _SessionProgressPainter oldDelegate) {
    return progress != oldDelegate.progress;
  }
}
