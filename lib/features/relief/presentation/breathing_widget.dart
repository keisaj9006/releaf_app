// FILE: lib/features/relief/presentation/breathing_widget.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/session/session_manager.dart';
import '../../progress/data/leaves_repository.dart';
import '../data/audio_catalog.dart';

class BreathingWidget extends ConsumerStatefulWidget {
  final ReliefSession session;
  const BreathingWidget({super.key, required this.session});

  @override
  ConsumerState<BreathingWidget> createState() => _BreathingWidgetState();
}

class _BreathingWidgetState extends ConsumerState<BreathingWidget> {
  late int _remainingSeconds;
  Timer? _timer;
  bool _completed = false;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.session.durationSeconds;
    if (_remainingSeconds <= 0) {
      scheduleMicrotask(() => _finishSession(shouldAward: true));
      return;
    }
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (_remainingSeconds > 1) {
        setState(() => _remainingSeconds--);
        return;
      }

      setState(() => _remainingSeconds = 0);
      timer.cancel();
      _finishSession(shouldAward: true);
    });
  }

  void _pauseAndMinimize() {
    _timer?.cancel(); // pause

    ref.read(sessionManagerProvider.notifier).setPausedSession(
      title: widget.session.title,
      subtitle: 'Paused • $_remainingSeconds s left',
      resumeRoute: '/relief',
      extra: null,
    );

    Navigator.of(context).maybePop();
  }

  Future<void> _finishSession({required bool shouldAward}) async {
    if (_completed) return;
    _completed = true;

    _timer?.cancel();

    if (shouldAward) {
      final leavesNotifier = ref.read(leavesNotifierProvider.notifier);
      final result = await leavesNotifier.markReliefDone();

      if (mounted && result != null) {
        HapticFeedback.lightImpact();
        final message = result.hasBonus
            ? '+${result.totalAdded} leaves • Perfect day bonus!'
            : '+${result.totalAdded} leaves';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      }
    }

    if (mounted) Navigator.of(context).maybePop();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<bool> _onWillPop() async {
    await _finishSession(shouldAward: false);
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final minutes = _remainingSeconds ~/ 60;
    final seconds = _remainingSeconds % 60;
    final timeString =
        '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(widget.session.title),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => _finishSession(shouldAward: false),
          ),
          actions: [
            IconButton(
              tooltip: 'Minimize',
              icon: const Icon(Icons.horizontal_rule),
              onPressed: _pauseAndMinimize,
            ),
            IconButton(
              tooltip: 'Close',
              icon: const Icon(Icons.close),
              onPressed: () => _finishSession(shouldAward: false),
            ),
          ],
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 8),
                Text(
                  timeString,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 48, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: ListView.builder(
                    itemCount: widget.session.instructions.length,
                    itemBuilder: (context, index) {
                      final instruction = widget.session.instructions[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          '${index + 1}. $instruction',
                          style: const TextStyle(fontSize: 16),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => _finishSession(shouldAward: false),
                  child: const Text('Stop Session'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}