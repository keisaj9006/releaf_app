import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../releaf_design_tokens.dart';

class ReleafObjectFocusVisual extends StatefulWidget {
  const ReleafObjectFocusVisual({
    super.key,
    required this.progress,
    required this.phaseLabel,
    this.reducedMotion = false,
  });

  final double progress;
  final String phaseLabel;
  final bool reducedMotion;

  @override
  State<ReleafObjectFocusVisual> createState() =>
      _ReleafObjectFocusVisualState();
}

class _ReleafObjectFocusVisualState extends State<ReleafObjectFocusVisual>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

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
  void didUpdateWidget(covariant ReleafObjectFocusVisual oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.reducedMotion != widget.reducedMotion) _sync();
  }

  void _sync() {
    if (widget.reducedMotion) {
      _controller.stop();
      _controller.value = 0.2;
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
    return Semantics(
      container: true,
      label: 'Object grounding. ${widget.phaseLabel}.',
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            key: const Key('reset-object-focus-visual'),
            painter: _ObjectFocusPainter(
              t: _controller.value,
              progress: widget.progress.clamp(0.0, 1.0).toDouble(),
            ),
            child: Center(
              child: Text(
                widget.phaseLabel.toUpperCase(),
                style: ReleafTypography.eyebrow.copyWith(
                  color: ReleafColors.sage,
                  letterSpacing: 1.3,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ObjectFocusPainter extends CustomPainter {
  const _ObjectFocusPainter({
    required this.t,
    required this.progress,
  });

  final double t;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.shortestSide * 0.28;
    final angle = (t * math.pi * 2) * 0.16;

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(angle);

    final objectRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset.zero,
        width: radius * 1.25,
        height: radius * 1.55,
      ),
      Radius.circular(radius * 0.34),
    );

    canvas.drawRRect(
      objectRect,
      Paint()
        ..color = ReleafColors.sage.withValues(alpha: 0.12)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 24),
    );

    canvas.drawRRect(
      objectRect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            ReleafColors.sage.withValues(alpha: 0.72),
            ReleafColors.sageStrong.withValues(alpha: 0.28),
          ],
        ).createShader(objectRect.outerRect),
    );

    canvas.drawRRect(
      objectRect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6
        ..color = ReleafColors.textPrimary.withValues(alpha: 0.28),
    );

    canvas.restore();

    final ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..color = ReleafColors.borderSoft.withValues(alpha: 0.42);
    canvas.drawCircle(center, radius * 1.42, ringPaint);
    canvas.drawCircle(center, radius * 1.12, ringPaint);

    final sweep = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..color = ReleafColors.premium.withValues(alpha: 0.74);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius * 1.42),
      -math.pi / 2,
      math.pi * 2 * progress,
      false,
      sweep,
    );
  }

  @override
  bool shouldRepaint(covariant _ObjectFocusPainter oldDelegate) {
    return oldDelegate.t != t || oldDelegate.progress != progress;
  }
}

class ReleafSoundRippleVisual extends StatefulWidget {
  const ReleafSoundRippleVisual({
    super.key,
    required this.progress,
    required this.phaseLabel,
    this.reducedMotion = false,
  });

  final double progress;
  final String phaseLabel;
  final bool reducedMotion;

  @override
  State<ReleafSoundRippleVisual> createState() =>
      _ReleafSoundRippleVisualState();
}

class _ReleafSoundRippleVisualState extends State<ReleafSoundRippleVisual>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    );
    _sync();
  }

  @override
  void didUpdateWidget(covariant ReleafSoundRippleVisual oldWidget) {
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
    return Semantics(
      container: true,
      label: 'Sound grounding. ${widget.phaseLabel}.',
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            key: const Key('reset-sound-ripple-visual'),
            painter: _SoundRipplePainter(
              t: _controller.value,
              progress: widget.progress.clamp(0.0, 1.0).toDouble(),
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.hearing_rounded,
                    size: 42,
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
          );
        },
      ),
    );
  }
}

class _SoundRipplePainter extends CustomPainter {
  const _SoundRipplePainter({
    required this.t,
    required this.progress,
  });

  final double t;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.shortestSide * 0.42;

    for (var i = 0; i < 4; i++) {
      final phase = (t + i * 0.22) % 1.0;
      final radius = maxRadius * (0.25 + phase * 0.75);
      final alpha = (1 - phase) * 0.34;
      canvas.drawCircle(
        center,
        radius,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..color = ReleafColors.sage.withValues(alpha: alpha),
      );
    }

    canvas.drawCircle(
      center,
      maxRadius * 0.18,
      Paint()
        ..color = ReleafColors.sage.withValues(alpha: 0.13)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18),
    );

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: maxRadius),
      -math.pi / 2,
      math.pi * 2 * progress,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round
        ..color = ReleafColors.sageStrong.withValues(alpha: 0.78),
    );
  }

  @override
  bool shouldRepaint(covariant _SoundRipplePainter oldDelegate) {
    return oldDelegate.t != t || oldDelegate.progress != progress;
  }
}

class ReleafAcceptanceSpaceVisual extends StatefulWidget {
  const ReleafAcceptanceSpaceVisual({
    super.key,
    required this.progress,
    required this.phaseLabel,
    this.reducedMotion = false,
  });

  final double progress;
  final String phaseLabel;
  final bool reducedMotion;

  @override
  State<ReleafAcceptanceSpaceVisual> createState() =>
      _ReleafAcceptanceSpaceVisualState();
}

class _ReleafAcceptanceSpaceVisualState
    extends State<ReleafAcceptanceSpaceVisual>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  double get _spaceFactor {
    final label = widget.phaseLabel.toLowerCase();
    if (label.contains('notice')) return 0.38;
    if (label.contains('allow')) return 0.50;
    if (label.contains('room')) return 0.66;
    if (label.contains('carry')) return 0.78;
    if (label.contains('return')) return 0.88;
    return 0.48;
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 9),
    );
    _sync();
  }

  @override
  void didUpdateWidget(covariant ReleafAcceptanceSpaceVisual oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.reducedMotion != widget.reducedMotion) _sync();
  }

  void _sync() {
    if (widget.reducedMotion) {
      _controller.stop();
      _controller.value = 0.25;
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
    return Semantics(
      container: true,
      label: 'Acceptance practice. ${widget.phaseLabel}.',
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            key: const Key('reset-acceptance-space-visual'),
            painter: _AcceptanceSpacePainter(
              t: _controller.value,
              spaceFactor: _spaceFactor,
              progress: widget.progress.clamp(0.0, 1.0).toDouble(),
            ),
            child: Center(
              child: Text(
                widget.phaseLabel.toUpperCase(),
                style: ReleafTypography.eyebrow.copyWith(
                  color: ReleafColors.sage,
                  letterSpacing: 1.3,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _AcceptanceSpacePainter extends CustomPainter {
  const _AcceptanceSpacePainter({
    required this.t,
    required this.spaceFactor,
    required this.progress,
  });

  final double t;
  final double spaceFactor;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.shortestSide * 0.42;
    final wobble = math.sin(t * math.pi * 2) * 0.025;
    final innerRadius = maxRadius * (0.16 + wobble);
    final outerRadius = maxRadius * spaceFactor;

    canvas.drawCircle(
      center,
      outerRadius,
      Paint()
        ..color = ReleafColors.sage.withValues(alpha: 0.09)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 26),
    );
    canvas.drawCircle(
      center,
      outerRadius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4
        ..color = ReleafColors.sage.withValues(alpha: 0.45),
    );

    canvas.drawCircle(
      center,
      innerRadius,
      Paint()..color = ReleafColors.premium.withValues(alpha: 0.88),
    );

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: maxRadius),
      -math.pi / 2,
      math.pi * 2 * progress,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round
        ..color = ReleafColors.premium.withValues(alpha: 0.76),
    );
  }

  @override
  bool shouldRepaint(covariant _AcceptanceSpacePainter oldDelegate) {
    return oldDelegate.t != t ||
        oldDelegate.spaceFactor != spaceFactor ||
        oldDelegate.progress != progress;
  }
}

class ReleafNextStepVisual extends StatefulWidget {
  const ReleafNextStepVisual({
    super.key,
    required this.progress,
    required this.phaseLabel,
    this.reducedMotion = false,
  });

  final double progress;
  final String phaseLabel;
  final bool reducedMotion;

  @override
  State<ReleafNextStepVisual> createState() => _ReleafNextStepVisualState();
}

class _ReleafNextStepVisualState extends State<ReleafNextStepVisual>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 7),
    );
    _sync();
  }

  @override
  void didUpdateWidget(covariant ReleafNextStepVisual oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.reducedMotion != widget.reducedMotion) _sync();
  }

  void _sync() {
    if (widget.reducedMotion) {
      _controller.stop();
      _controller.value = 0.25;
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
    return Semantics(
      container: true,
      label: 'Next step practice. ${widget.phaseLabel}.',
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            key: const Key('reset-next-step-visual'),
            painter: _NextStepPainter(
              t: _controller.value,
              progress: widget.progress.clamp(0.0, 1.0).toDouble(),
            ),
            child: Center(
              child: Text(
                widget.phaseLabel.toUpperCase(),
                style: ReleafTypography.eyebrow.copyWith(
                  color: ReleafColors.sage,
                  letterSpacing: 1.3,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _NextStepPainter extends CustomPainter {
  const _NextStepPainter({
    required this.t,
    required this.progress,
  });

  final double t;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    final centerY = size.height * 0.56;
    final startX = size.width * 0.19;
    final gap = size.width * 0.155;
    final pulse = 1 + math.sin(t * math.pi * 2) * 0.08;

    final path = Path()..moveTo(startX, centerY);
    for (var i = 1; i < 5; i++) {
      path.lineTo(startX + gap * i, centerY - (i.isOdd ? 12 : 0));
    }
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round
        ..color = ReleafColors.borderSoft.withValues(alpha: 0.48),
    );

    for (var i = 0; i < 5; i++) {
      final x = startX + gap * i;
      final y = centerY - (i.isOdd ? 12 : 0);
      final reached = progress >= (i / 5);
      final isNext = !reached || (i == 4 && progress < 1);
      final base = isNext ? 9.0 * pulse : 7.0;

      if (isNext) {
        canvas.drawCircle(
          Offset(x, y),
          20,
          Paint()
            ..color = ReleafColors.sage.withValues(alpha: 0.12)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 9),
        );
      }

      canvas.drawCircle(
        Offset(x, y),
        base,
        Paint()
          ..color = reached
              ? ReleafColors.premium.withValues(alpha: 0.82)
              : ReleafColors.sage,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _NextStepPainter oldDelegate) {
    return oldDelegate.t != t || oldDelegate.progress != progress;
  }
}
