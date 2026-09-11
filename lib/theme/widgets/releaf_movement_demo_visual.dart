import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../releaf_design_tokens.dart';

enum ReleafMovementDemoKind { pushUps, shakeOut }

ReleafMovementDemoKind? releafMovementDemoKindForSession(String sessionId) {
  return switch (sessionId) {
    'pushups-activation' => ReleafMovementDemoKind.pushUps,
    'shake-it-out' => ReleafMovementDemoKind.shakeOut,
    _ => null,
  };
}

/// A small, first-party movement demonstration synchronized to Reset steps.
///
/// It deliberately uses vector line work instead of bundled video: the motion
/// stays sharp at every phone size, adds negligible app weight and can stop
/// completely when the platform requests reduced motion.
class ReleafMovementDemoVisual extends StatefulWidget {
  const ReleafMovementDemoVisual({
    super.key,
    required this.kind,
    required this.progress,
    required this.phaseLabel,
    this.reducedMotion = false,
  });

  final ReleafMovementDemoKind kind;
  final double progress;
  final String phaseLabel;
  final bool reducedMotion;

  @override
  State<ReleafMovementDemoVisual> createState() =>
      _ReleafMovementDemoVisualState();
}

class _ReleafMovementDemoVisualState extends State<ReleafMovementDemoVisual>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4200),
    );
    _syncMotion();
  }

  @override
  void didUpdateWidget(covariant ReleafMovementDemoVisual oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.reducedMotion != widget.reducedMotion) _syncMotion();
  }

  void _syncMotion() {
    if (widget.reducedMotion) {
      _controller.stop();
      _controller.value = 0.24;
    } else if (!_controller.isAnimating) {
      _controller.repeat();
    }
  }

  String get _semanticsLabel => switch (widget.kind) {
        ReleafMovementDemoKind.pushUps =>
          'Animated movement guide. Choose a comfortable floor, wall, or seated press and move slowly. Current step: ${widget.phaseLabel}.',
        ReleafMovementDemoKind.shakeOut =>
          'Animated movement guide. Use small loose movements through the hands, arms, and legs. A seated option is shown. Current step: ${widget.phaseLabel}.',
      };

  String get _caption => switch (widget.kind) {
        ReleafMovementDemoKind.pushUps =>
          widget.phaseLabel.toLowerCase().contains('move')
              ? 'SLOW, CONTROLLED REPS'
              : 'CHOOSE YOUR COMFORTABLE VERSION',
        ReleafMovementDemoKind.shakeOut =>
          widget.phaseLabel.toLowerCase().contains('still') ||
                  widget.phaseLabel.toLowerCase().contains('return')
              ? 'RETURN TO STILLNESS'
              : 'SMALL, LOOSE MOVEMENT',
      };

  String get _keySuffix => switch (widget.kind) {
        ReleafMovementDemoKind.pushUps => 'pushups',
        ReleafMovementDemoKind.shakeOut => 'shake-out',
      };

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
      label: _semanticsLabel,
      child: ExcludeSemantics(
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: progress),
          duration: widget.reducedMotion
              ? Duration.zero
              : const Duration(milliseconds: 720),
          curve: Curves.easeOutCubic,
          builder: (context, animatedProgress, child) {
            return AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                return CustomPaint(
                  key: Key('reset-movement-demo-$_keySuffix'),
                  painter: _MovementDemoPainter(
                    kind: widget.kind,
                    t: _controller.value,
                    progress: animatedProgress,
                    phaseLabel: widget.phaseLabel,
                  ),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 23),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: ReleafColors.surfaceSoft.withValues(
                              alpha: 0.86,
                            ),
                            borderRadius:
                                BorderRadius.circular(ReleafRadii.pill),
                            border: Border.all(
                              color: ReleafColors.sage.withValues(alpha: 0.20),
                            ),
                          ),
                          child: AnimatedSwitcher(
                            duration: ReleafMotion.standard,
                            child: Text(
                              _caption,
                              key: ValueKey(_caption),
                              style: ReleafTypography.eyebrow.copyWith(
                                color: ReleafColors.sage,
                                fontSize: 8,
                                letterSpacing: 1.1,
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
          },
        ),
      ),
    );
  }
}

class _MovementDemoPainter extends CustomPainter {
  const _MovementDemoPainter({
    required this.kind,
    required this.t,
    required this.progress,
    required this.phaseLabel,
  });

  final ReleafMovementDemoKind kind;
  final double t;
  final double progress;
  final String phaseLabel;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;

    final base = size.shortestSide;
    final center = Offset(size.width / 2, size.height / 2);
    final pulse = 0.5 + 0.5 * math.sin(t * math.pi * 2);

    canvas.drawCircle(
      Offset(center.dx, center.dy - base * 0.02),
      base * (0.34 + pulse * 0.008),
      Paint()
        ..color = ReleafColors.sage.withValues(alpha: 0.06 + pulse * 0.025)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 30),
    );

    switch (kind) {
      case ReleafMovementDemoKind.pushUps:
        _drawPushUpChoices(canvas, size, base);
      case ReleafMovementDemoKind.shakeOut:
        _drawShakeChoices(canvas, size, base);
    }

    _drawProgress(canvas, size, base);
  }

  Paint _linePaint(double base, {double alpha = 0.70}) => Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = math.max(2.3, base * 0.009)
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round
    ..color = ReleafColors.textPrimary.withValues(alpha: alpha);

  Paint _accentPaint(double base, {double alpha = 0.82}) => Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = math.max(2.5, base * 0.010)
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round
    ..color = ReleafColors.sage.withValues(alpha: alpha);

  void _drawPushUpChoices(Canvas canvas, Size size, double base) {
    final label = phaseLabel.toLowerCase();
    final shouldMove = label.contains('move');
    final shouldSettle = label.contains('notice') || label.contains('return');
    final repetition = shouldMove
        ? 0.5 - 0.5 * math.cos(t * math.pi * 2)
        : shouldSettle
            ? 0.12
            : 0.28;
    final centers = <double>[
      size.width * 0.22,
      size.width * 0.50,
      size.width * 0.78,
    ];

    for (var index = 0; index < centers.length; index++) {
      final rect = RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(centers[index], size.height * 0.47),
          width: base * 0.245,
          height: base * 0.42,
        ),
        Radius.circular(base * 0.05),
      );
      canvas.drawRRect(
        rect,
        Paint()..color = ReleafColors.surfaceSoft.withValues(alpha: 0.36),
      );
      canvas.drawRRect(
        rect,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1
          ..color = ReleafColors.sage.withValues(alpha: 0.13),
      );
    }

    _drawFloorPushUp(
      canvas,
      Offset(centers[0], size.height * 0.48),
      base,
      repetition,
    );
    _drawWallPushUp(
      canvas,
      Offset(centers[1], size.height * 0.48),
      base,
      repetition,
    );
    _drawSeatedPress(
      canvas,
      Offset(centers[2], size.height * 0.48),
      base,
      repetition,
    );

    _drawLabel(canvas, 'FLOOR', Offset(centers[0], size.height * 0.70), base);
    _drawLabel(canvas, 'WALL', Offset(centers[1], size.height * 0.70), base);
    _drawLabel(canvas, 'SEATED', Offset(centers[2], size.height * 0.70), base);
  }

  void _drawFloorPushUp(
    Canvas canvas,
    Offset center,
    double base,
    double repetition,
  ) {
    final line = _linePaint(base);
    final accent = _accentPaint(base);
    final floorY = center.dy + base * 0.10;
    canvas.drawLine(
      Offset(center.dx - base * 0.095, floorY),
      Offset(center.dx + base * 0.095, floorY),
      _linePaint(base, alpha: 0.20),
    );

    final lower = repetition * base * 0.035;
    final feet = Offset(center.dx - base * 0.075, floorY - base * 0.015);
    final hip = Offset(center.dx - base * 0.020, center.dy - lower);
    final shoulder = Offset(center.dx + base * 0.035, center.dy - lower);
    final hand = Offset(center.dx + base * 0.065, floorY - base * 0.006);
    final head = Offset(
      center.dx + base * 0.072,
      center.dy - base * 0.020 - lower,
    );

    canvas.drawLine(feet, hip, line);
    canvas.drawLine(hip, shoulder, accent);
    canvas.drawLine(shoulder, hand, line);
    canvas.drawCircle(head, base * 0.018, line);
  }

  void _drawWallPushUp(
    Canvas canvas,
    Offset center,
    double base,
    double repetition,
  ) {
    final line = _linePaint(base);
    final accent = _accentPaint(base);
    final wallX = center.dx + base * 0.075;
    canvas.drawLine(
      Offset(wallX, center.dy - base * 0.11),
      Offset(wallX, center.dy + base * 0.12),
      _linePaint(base, alpha: 0.24),
    );

    final lean = repetition * base * 0.035;
    final head = Offset(center.dx - base * 0.025 + lean, center.dy - base * 0.085);
    final shoulder = Offset(
      center.dx - base * 0.025 + lean,
      center.dy - base * 0.045,
    );
    final hips = Offset(center.dx - base * 0.055, center.dy + base * 0.035);
    final feet = Offset(center.dx - base * 0.080, center.dy + base * 0.115);
    final hands = Offset(wallX, center.dy - base * 0.025);

    canvas.drawCircle(head, base * 0.019, line);
    canvas.drawLine(shoulder, hips, accent);
    canvas.drawLine(hips, feet, line);
    canvas.drawLine(shoulder, hands, line);
  }

  void _drawSeatedPress(
    Canvas canvas,
    Offset center,
    double base,
    double repetition,
  ) {
    final line = _linePaint(base);
    final accent = _accentPaint(base);
    final chair = _linePaint(base, alpha: 0.22);
    final seatY = center.dy + base * 0.045;
    canvas.drawLine(
      Offset(center.dx - base * 0.065, seatY),
      Offset(center.dx + base * 0.055, seatY),
      chair,
    );
    canvas.drawLine(
      Offset(center.dx - base * 0.065, center.dy - base * 0.08),
      Offset(center.dx - base * 0.065, seatY + base * 0.09),
      chair,
    );

    final head = Offset(center.dx, center.dy - base * 0.085);
    final shoulder = Offset(center.dx, center.dy - base * 0.040);
    final hips = Offset(center.dx - base * 0.005, seatY);
    final knee = Offset(center.dx + base * 0.055, center.dy + base * 0.075);
    final foot = Offset(center.dx + base * 0.055, center.dy + base * 0.13);
    final press = base * (0.025 + repetition * 0.020);

    canvas.drawCircle(head, base * 0.019, line);
    canvas.drawLine(shoulder, hips, accent);
    canvas.drawLine(hips, knee, line);
    canvas.drawLine(knee, foot, line);
    canvas.drawLine(
      shoulder,
      Offset(center.dx + press, center.dy - base * 0.01),
      line,
    );
    canvas.drawCircle(
      Offset(center.dx + press, center.dy - base * 0.01),
      base * 0.010,
      accent,
    );
  }

  void _drawShakeChoices(Canvas canvas, Size size, double base) {
    final label = phaseLabel.toLowerCase();
    final still = label.contains('still') || label.contains('return');
    final hands = label.contains('hand');
    final arms = label.contains('arm');
    final legs = label.contains('leg');
    final wave = still ? 0.0 : math.sin(t * math.pi * 4);

    _drawStandingShake(
      canvas,
      Offset(size.width * 0.36, size.height * 0.48),
      base,
      wave,
      hands: hands,
      arms: arms,
      legs: legs,
    );
    _drawSeatedShake(
      canvas,
      Offset(size.width * 0.66, size.height * 0.48),
      base,
      wave,
      hands: hands,
      arms: arms,
      legs: legs,
    );

    _drawLabel(
      canvas,
      'STANDING',
      Offset(size.width * 0.36, size.height * 0.73),
      base,
    );
    _drawLabel(
      canvas,
      'SEATED',
      Offset(size.width * 0.66, size.height * 0.73),
      base,
    );
  }

  void _drawStandingShake(
    Canvas canvas,
    Offset center,
    double base,
    double wave, {
    required bool hands,
    required bool arms,
    required bool legs,
  }) {
    final line = _linePaint(base);
    final accent = _accentPaint(base);
    final handShift = wave * base * (hands ? 0.018 : arms ? 0.009 : 0.0);
    final armShift = wave * base * (arms ? 0.016 : 0.0);
    final legShift = wave * base * (legs ? 0.012 : 0.0);
    final head = Offset(center.dx, center.dy - base * 0.16);
    final shoulder = Offset(center.dx, center.dy - base * 0.095);
    final hips = Offset(center.dx, center.dy + base * 0.02);

    canvas.drawCircle(head, base * 0.033, line);
    canvas.drawLine(shoulder, hips, line);
    canvas.drawLine(
      shoulder,
      Offset(center.dx - base * 0.075 + armShift, center.dy - base * 0.015),
      arms || hands ? accent : line,
    );
    canvas.drawLine(
      shoulder,
      Offset(center.dx + base * 0.075 + handShift, center.dy - base * 0.015),
      arms || hands ? accent : line,
    );
    canvas.drawLine(
      hips,
      Offset(center.dx - base * 0.055 + legShift, center.dy + base * 0.145),
      legs ? accent : line,
    );
    canvas.drawLine(
      hips,
      Offset(center.dx + base * 0.055 - legShift, center.dy + base * 0.145),
      legs ? accent : line,
    );

    if (hands || arms || legs) {
      _drawMovementMarks(
        canvas,
        center,
        base,
        hands: hands || arms,
        legs: legs,
      );
    }
  }

  void _drawSeatedShake(
    Canvas canvas,
    Offset center,
    double base,
    double wave, {
    required bool hands,
    required bool arms,
    required bool legs,
  }) {
    final line = _linePaint(base);
    final accent = _accentPaint(base);
    final chair = _linePaint(base, alpha: 0.22);
    final handShift = wave * base * (hands ? 0.018 : arms ? 0.009 : 0.0);
    final legShift = wave * base * (legs ? 0.012 : 0.0);
    final head = Offset(center.dx, center.dy - base * 0.15);
    final shoulder = Offset(center.dx, center.dy - base * 0.085);
    final hips = Offset(center.dx, center.dy + base * 0.025);
    final knee = Offset(center.dx + base * 0.065, center.dy + base * 0.055);

    canvas.drawLine(
      Offset(center.dx - base * 0.06, center.dy + base * 0.03),
      Offset(center.dx + base * 0.08, center.dy + base * 0.03),
      chair,
    );
    canvas.drawLine(
      Offset(center.dx - base * 0.06, center.dy - base * 0.10),
      Offset(center.dx - base * 0.06, center.dy + base * 0.13),
      chair,
    );
    canvas.drawCircle(head, base * 0.033, line);
    canvas.drawLine(shoulder, hips, line);
    canvas.drawLine(
      shoulder,
      Offset(center.dx + base * 0.085 + handShift, center.dy - base * 0.01),
      arms || hands ? accent : line,
    );
    canvas.drawLine(hips, knee, line);
    canvas.drawLine(
      knee,
      Offset(center.dx + base * 0.065 + legShift, center.dy + base * 0.14),
      legs ? accent : line,
    );

    if (hands || arms || legs) {
      _drawMovementMarks(
        canvas,
        center,
        base,
        hands: hands || arms,
        legs: legs,
      );
    }
  }

  void _drawMovementMarks(
    Canvas canvas,
    Offset center,
    double base, {
    required bool hands,
    required bool legs,
  }) {
    final marks = _accentPaint(base, alpha: 0.45)
      ..strokeWidth = math.max(1.4, base * 0.005);
    if (hands) {
      canvas.drawArc(
        Rect.fromCenter(
          center: Offset(center.dx + base * 0.09, center.dy - base * 0.015),
          width: base * 0.055,
          height: base * 0.045,
        ),
        -math.pi * 0.65,
        math.pi * 1.3,
        false,
        marks,
      );
    }
    if (legs) {
      canvas.drawArc(
        Rect.fromCenter(
          center: Offset(center.dx + base * 0.06, center.dy + base * 0.14),
          width: base * 0.06,
          height: base * 0.035,
        ),
        0,
        math.pi,
        false,
        marks,
      );
    }
  }

  void _drawLabel(Canvas canvas, String text, Offset center, double base) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: ReleafColors.textMuted.withValues(alpha: 0.78),
          fontSize: math.max(7.0, base * 0.027),
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
        ),
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    )..layout(maxWidth: base * 0.23);
    painter.paint(
      canvas,
      Offset(center.dx - painter.width / 2, center.dy - painter.height / 2),
    );
  }

  void _drawProgress(Canvas canvas, Size size, double base) {
    final stroke = math.max(1.0, base * 0.0055);
    final ring = Rect.fromCircle(
      center: Offset(size.width / 2, size.height / 2),
      radius: base / 2 - stroke,
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
  bool shouldRepaint(covariant _MovementDemoPainter oldDelegate) {
    return oldDelegate.kind != kind ||
        oldDelegate.t != t ||
        oldDelegate.progress != progress ||
        oldDelegate.phaseLabel != phaseLabel;
  }
}
