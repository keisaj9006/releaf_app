import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/audio_catalog.dart';
import '../../progress/data/leaves_repository.dart';

enum SessionPhase { running, feedback }

class BreathingWidget extends ConsumerStatefulWidget {
  final String sessionId;
  const BreathingWidget({super.key, required this.sessionId});

  @override
  ConsumerState<BreathingWidget> createState() => _BreathingWidgetState();
}

class _BreathingWidgetState extends ConsumerState<BreathingWidget> {
  ReliefSession? _session;
  int _remainingSeconds = 0;
  Timer? _timer;
  SessionPhase _phase = SessionPhase.running;
  bool _awarded = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final session = ref.read(audioCatalogProvider).getById(widget.sessionId);
      if (session == null) {
        if (mounted) context.pop(false);
        return;
      }

      setState(() {
        _session = session;
        _remainingSeconds = session.durationSeconds;
      });

      if (_remainingSeconds <= 0) {
        _triggerFeedbackPhase();
        return;
      }

      _startTimer();
    });
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
      _triggerFeedbackPhase();
    });
  }

  Future<void> _triggerFeedbackPhase() async {
    if (!mounted) return;

    HapticFeedback.mediumImpact();
    setState(() => _phase = SessionPhase.feedback);

    // award only once, only on completion (timer finished)
    if (_awarded) return;
    _awarded = true;

    final result = await ref.read(leavesNotifierProvider.notifier).markReliefDone();

    if (!mounted || result == null) return;

    HapticFeedback.lightImpact();
    final message = result.hasBonus
        ? '+${result.totalAdded} leaves • Perfect day bonus!'
        : '+${result.totalAdded} leaves';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _abortSession() {
    _timer?.cancel();
    if (mounted) context.pop(false);
  }

  void _submitFeedbackAndClose(bool helpedALot) {
    if (mounted) context.pop(helpedALot);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_session == null) {
      return const Scaffold(
        backgroundColor: Color(0xFF121417),
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF6B9080)),
        ),
      );
    }

    final minutes = _remainingSeconds ~/ 60;
    final seconds = _remainingSeconds % 60;
    final timeString =
        '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) return;
        _abortSession();
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF121417),
        body: SafeArea(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 450),
            child: _phase == SessionPhase.running
                ? _buildRunningState(timeString)
                : _buildFeedbackState(),
          ),
        ),
      ),
    );
  }

  Widget _buildRunningState(String timeString) {
    return Column(
      key: const ValueKey('running'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Align(
          alignment: Alignment.topLeft,
          child: IconButton(
            icon: const Icon(Icons.close, color: Color(0xFF686D7B)),
            onPressed: _abortSession,
          ),
        ),
        const Spacer(flex: 2),
        Text(
          timeString,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 64,
            fontWeight: FontWeight.w300,
            color: Color(0xFFF0F2F5),
            letterSpacing: -1.5,
          ),
        ),
        const Spacer(flex: 3),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Text(
            _session!.instructions.isNotEmpty
                ? _session!.instructions.first
                : 'Settle in.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 18,
              color: Color(0xFFA1A6B4),
              height: 1.4,
            ),
          ),
        ),
        const Spacer(flex: 2),
      ],
    );
  }

  Widget _buildFeedbackState() {
    return Padding(
      key: const ValueKey('feedback'),
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Did this help settle your nerves?',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: Color(0xFFF0F2F5),
            ),
          ),
          const SizedBox(height: 48),
          ElevatedButton(
            onPressed: () => _submitFeedbackAndClose(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6B9080),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Text(
              'Yes, much better',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: () => _submitFeedbackAndClose(false),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFFA1A6B4),
              side: const BorderSide(color: Color(0xFF2E323B)),
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Text(
              'Not really',
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}