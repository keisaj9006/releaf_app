import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../releaf_design_tokens.dart';
import 'releaf_artwork.dart';
import 'releaf_session_living_form.dart';

/// Calm, non-diagnostic visual language reserved for Emergency mode.
///
/// It deliberately avoids game-like progress, premium cues and fake controls.
/// The small trainer silhouette is abstract rather than a realistic person.
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
      duration: const Duration(seconds: 10),
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
        ..value = 0.32;
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
      label: 'Emergency grounding visual. ${widget.phaseLabel}.',
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final wave = widget.reducedMotion
              ? 0.42
              : (math.sin(_controller.value * math.pi * 2) + 1) / 2;
          final ringOpacity = 0.08 + (wave * 0.08);
          final trainerScale = 0.985 + (wave * 0.025);

          return Stack(
            key: const Key('emergency-calming-visual'),
            fit: StackFit.expand,
            alignment: Alignment.center,
            children: [
              Center(
                child: FractionallySizedBox(
                  widthFactor: 0.90,
                  heightFactor: 0.90,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: ReleafColors.sage.withValues(
                          alpha: ringOpacity,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Center(
                child: FractionallySizedBox(
                  widthFactor: 0.72,
                  heightFactor: 0.72,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: ReleafColors.sage.withValues(
                          alpha: ringOpacity + 0.04,
                        ),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: ReleafColors.glowSage.withValues(
                            alpha: 0.48 + (wave * 0.24),
                          ),
                          blurRadius: 72,
                          spreadRadius: 8,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Center(
                child: FractionallySizedBox(
                  widthFactor: 0.70,
                  heightFactor: 0.70,
                  child: ReleafSessionLivingForm(
                    variant: ReleafArtworkVariant.ambient,
                    progress: progress,
                    breathing: false,
                    reducedMotion: widget.reducedMotion,
                  ),
                ),
              ),
              Center(
                child: Transform.scale(
                  scale: trainerScale,
                  child: FractionallySizedBox(
                    widthFactor: 0.30,
                    heightFactor: 0.30,
                    child: const CustomPaint(
                      key: Key('emergency-trainer-silhouette'),
                      painter: _EmergencyTrainerPainter(),
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

class _EmergencyTrainerPainter extends CustomPainter {
  const _EmergencyTrainerPainter();

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;

    final center = Offset(size.width / 2, size.height / 2);
    final short = size.shortestSide;

    final auraPaint = Paint()
      ..color = ReleafColors.background.withValues(alpha: 0.68)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
    canvas.drawCircle(center, short * 0.34, auraPaint);

    final fill = Paint()
      ..color = ReleafColors.textPrimary.withValues(alpha: 0.78)
      ..style = PaintingStyle.fill;

    final outline = Paint()
      ..color = ReleafColors.sage.withValues(alpha: 0.40)
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(1.2, short * 0.018)
      ..strokeCap = StrokeCap.round;

    final headRadius = short * 0.105;
    final headCenter = Offset(center.dx, center.dy - short * 0.14);
    canvas.drawCircle(headCenter, headRadius, fill);

    final shoulderRect = Rect.fromCenter(
      center: Offset(center.dx, center.dy + short * 0.105),
      width: short * 0.45,
      height: short * 0.28,
    );
    final shoulderPath = Path()
      ..moveTo(shoulderRect.left, shoulderRect.bottom)
      ..quadraticBezierTo(
        shoulderRect.left + short * 0.04,
        shoulderRect.top + short * 0.02,
        center.dx - short * 0.12,
        shoulderRect.top,
      )
      ..quadraticBezierTo(
        center.dx,
        shoulderRect.top + short * 0.07,
        center.dx + short * 0.12,
        shoulderRect.top,
      )
      ..quadraticBezierTo(
        shoulderRect.right - short * 0.04,
        shoulderRect.top + short * 0.02,
        shoulderRect.right,
        shoulderRect.bottom,
      )
      ..close();

    canvas.drawPath(shoulderPath, fill);
    canvas.drawPath(shoulderPath, outline);

    canvas.drawArc(
      Rect.fromCenter(
        center: Offset(center.dx, center.dy + short * 0.12),
        width: short * 0.50,
        height: short * 0.34,
      ),
      math.pi * 0.08,
      math.pi * 0.84,
      false,
      outline,
    );
  }

  @override
  bool shouldRepaint(covariant _EmergencyTrainerPainter oldDelegate) => false;
}
