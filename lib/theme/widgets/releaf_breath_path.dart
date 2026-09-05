import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../releaf_design_tokens.dart';

/// Releaf's precise paced-breathing cue.
///
/// The luminous point moves from left to right during inhale, pauses at the
/// right edge for an inhale hold, returns during exhale, and pauses at the
/// left edge for an exhale hold. Durations remain fully configurable.
class ReleafBreathPath extends StatefulWidget {
  const ReleafBreathPath({
    super.key,
    required this.inhaleSeconds,
    required this.exhaleSeconds,
    this.holdAfterInhaleSeconds = 0,
    this.holdAfterExhaleSeconds = 0,
    this.reducedMotion = false,
  });

  final int inhaleSeconds;
  final int holdAfterInhaleSeconds;
  final int exhaleSeconds;
  final int holdAfterExhaleSeconds;
  final bool reducedMotion;

  @override
  State<ReleafBreathPath> createState() => _ReleafBreathPathState();
}

class _ReleafBreathPathState extends State<ReleafBreathPath>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  int get _cycleSeconds => math.max(
        1,
        widget.inhaleSeconds +
            widget.holdAfterInhaleSeconds +
            widget.exhaleSeconds +
            widget.holdAfterExhaleSeconds,
      );

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: _cycleSeconds),
    );
    _sync();
  }

  @override
  void didUpdateWidget(covariant ReleafBreathPath oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.inhaleSeconds != widget.inhaleSeconds ||
        oldWidget.holdAfterInhaleSeconds != widget.holdAfterInhaleSeconds ||
        oldWidget.exhaleSeconds != widget.exhaleSeconds ||
        oldWidget.holdAfterExhaleSeconds != widget.holdAfterExhaleSeconds) {
      _controller.duration = Duration(seconds: _cycleSeconds);
    }
    if (oldWidget.reducedMotion != widget.reducedMotion) {
      _sync();
    }
  }

  void _sync() {
    if (widget.reducedMotion) {
      _controller.stop();
      _controller.value = 0;
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
      label: _semanticsLabel,
      child: SizedBox(
        key: const Key('reset-breath-path'),
        height: 66,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final frame = _frameAt(_controller.value);
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedSwitcher(
                  duration: ReleafMotion.quick,
                  child: Text(
                    frame.label,
                    key: ValueKey(frame.label),
                    style: ReleafTypography.eyebrow.copyWith(
                      color: ReleafColors.textSecondary,
                      letterSpacing: 1.1,
                    ),
                  ),
                ),
                const SizedBox(height: 9),
                Expanded(
                  child: CustomPaint(
                    painter: _BreathPathPainter(
                      position: frame.position,
                      accent: _accentFor(frame.phase),
                    ),
                    child: const SizedBox.expand(),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  String get _semanticsLabel {
    final parts = <String>[
      'Breathing guide',
      'inhale ${widget.inhaleSeconds} seconds',
    ];
    if (widget.holdAfterInhaleSeconds > 0) {
      parts.add('hold ${widget.holdAfterInhaleSeconds} seconds');
    }
    parts.add('exhale ${widget.exhaleSeconds} seconds');
    if (widget.holdAfterExhaleSeconds > 0) {
      parts.add('rest ${widget.holdAfterExhaleSeconds} seconds');
    }
    return parts.join(', ');
  }

  _BreathPathFrame _frameAt(double normalized) {
    final total = _cycleSeconds.toDouble();
    final elapsed = normalized * total;

    var cursor = 0.0;
    final inhaleEnd = cursor + widget.inhaleSeconds;
    if (elapsed < inhaleEnd) {
      final p = widget.inhaleSeconds == 0
          ? 1.0
          : (elapsed - cursor) / widget.inhaleSeconds;
      return _BreathPathFrame(
        phase: _BreathPathPhase.inhale,
        label: 'BREATHE IN',
        position: p.clamp(0.0, 1.0).toDouble(),
      );
    }
    cursor = inhaleEnd;

    final holdInEnd = cursor + widget.holdAfterInhaleSeconds;
    if (widget.holdAfterInhaleSeconds > 0 && elapsed < holdInEnd) {
      return const _BreathPathFrame(
        phase: _BreathPathPhase.hold,
        label: 'HOLD',
        position: 1,
      );
    }
    cursor = holdInEnd;

    final exhaleEnd = cursor + widget.exhaleSeconds;
    if (elapsed < exhaleEnd) {
      final p = widget.exhaleSeconds == 0
          ? 1.0
          : (elapsed - cursor) / widget.exhaleSeconds;
      return _BreathPathFrame(
        phase: _BreathPathPhase.exhale,
        label: 'BREATHE OUT',
        position: (1 - p).clamp(0.0, 1.0).toDouble(),
      );
    }

    return const _BreathPathFrame(
      phase: _BreathPathPhase.rest,
      label: 'REST',
      position: 0,
    );
  }

  Color _accentFor(_BreathPathPhase phase) {
    return switch (phase) {
      _BreathPathPhase.inhale => ReleafColors.sage,
      _BreathPathPhase.hold => ReleafColors.premium,
      _BreathPathPhase.exhale => ReleafColors.sageStrong,
      _BreathPathPhase.rest => ReleafColors.textSecondary,
    };
  }
}

enum _BreathPathPhase { inhale, hold, exhale, rest }

class _BreathPathFrame {
  const _BreathPathFrame({
    required this.phase,
    required this.label,
    required this.position,
  });

  final _BreathPathPhase phase;
  final String label;
  final double position;
}

class _BreathPathPainter extends CustomPainter {
  const _BreathPathPainter({
    required this.position,
    required this.accent,
  });

  final double position;
  final Color accent;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;

    final y = size.height * 0.48;
    final left = 12.0;
    final right = math.max(left, size.width - 12);
    final x = left + ((right - left) * position);

    final trackPaint = Paint()
      ..color = ReleafColors.border.withValues(alpha: 0.80)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(Offset(left, y), Offset(right, y), trackPaint);

    final endpointPaint = Paint()
      ..color = ReleafColors.textMuted.withValues(alpha: 0.30);
    canvas.drawCircle(Offset(left, y), 3.5, endpointPaint);
    canvas.drawCircle(Offset(right, y), 3.5, endpointPaint);

    canvas.drawCircle(
      Offset(x, y),
      12,
      Paint()
        ..color = accent.withValues(alpha: 0.16)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );
    canvas.drawCircle(
      Offset(x, y),
      5.5,
      Paint()..color = accent,
    );
    canvas.drawCircle(
      Offset(x - 1.5, y - 1.5),
      1.5,
      Paint()..color = ReleafColors.textPrimary.withValues(alpha: 0.75),
    );
  }

  @override
  bool shouldRepaint(covariant _BreathPathPainter oldDelegate) {
    return oldDelegate.position != position || oldDelegate.accent != accent;
  }
}
