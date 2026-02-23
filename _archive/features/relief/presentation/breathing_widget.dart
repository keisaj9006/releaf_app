// FILE: lib/features/relief/presentation/breathing_widget.dart
import 'dart:async';
import 'package:flutter/material.dart';

class BreathingWidget extends StatefulWidget {
  const BreathingWidget({
    super.key,
    this.totalSeconds = 60,
    this.onFinished,
  });

  final int totalSeconds;
  final VoidCallback? onFinished;

  @override
  State<BreathingWidget> createState() => _BreathingWidgetState();
}

class _BreathingWidgetState extends State<BreathingWidget> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;

  Timer? _timer;
  int remaining = 0;

  // Simple box breathing: 4-4-4-4
  static const _phases = <String>['Inhale', 'Hold', 'Exhale', 'Hold'];
  int _phaseIndex = 0;
  int _phaseTick = 0; // 0..3

  @override
  void initState() {
    super.initState();
    remaining = widget.totalSeconds;

    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _scale = Tween<double>(begin: 0.75, end: 1.05).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _controller.repeat(reverse: true);
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  void _tick() {
    if (!mounted) return;

    setState(() {
      remaining -= 1;
      _phaseTick += 1;

      if (_phaseTick >= 4) {
        _phaseTick = 0;
        _phaseIndex = (_phaseIndex + 1) % _phases.length;
      }
    });

    if (remaining <= 0) {
      _timer?.cancel();
      _controller.stop();
      widget.onFinished?.call();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final phase = _phases[_phaseIndex];

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(phase, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        AnimatedBuilder(
          animation: _scale,
          builder: (_, __) {
            return Transform.scale(
              scale: _scale.value,
              child: Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.15),
                  border: Border.all(color: Theme.of(context).colorScheme.primary.withOpacity(0.35)),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 12),
        Text('Remaining: ${remaining}s'),
      ],
    );
  }
}