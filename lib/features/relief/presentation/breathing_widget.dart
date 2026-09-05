import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../progress/data/leaves_repository.dart';
import '../../../theme/releaf_design_tokens.dart';
import '../../../theme/widgets/releaf_artwork.dart';
import '../../../theme/widgets/releaf_components.dart';
import '../../../theme/widgets/releaf_session_living_form.dart';
import '../data/reset_catalog.dart';
import '../domain/models/breath_pattern.dart';
import '../domain/models/reset_content.dart';
import '../domain/models/reset_launch_options.dart';
import '../domain/models/reset_session_program.dart';

enum SessionPhase { running, feedback }

class BreathingWidget extends ConsumerStatefulWidget {
  final String sessionId;
  final ResetLaunchOptions launchOptions;

  const BreathingWidget({
    super.key,
    required this.sessionId,
    this.launchOptions = const ResetLaunchOptions(),
  });

  @override
  ConsumerState<BreathingWidget> createState() => _BreathingWidgetState();
}

class _BreathingWidgetState extends ConsumerState<BreathingWidget> {
  ResetContent? _session;
  int _remainingSeconds = 0;
  Timer? _timer;
  SessionPhase _phase = SessionPhase.running;
  bool _awarded = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final session = ref.read(resetCatalogProvider).getById(widget.sessionId);
      if (session == null) {
        if (mounted) context.pop();
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

    if (_awarded || _session?.isEmergency == true) return;
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
    if (mounted) context.pop();
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
        backgroundColor: ReleafColors.background,
        body: Center(
          child: CircularProgressIndicator(color: ReleafColors.sage),
        ),
      );
    }

    final minutes = _remainingSeconds ~/ 60;
    final seconds = _remainingSeconds % 60;
    final timeString =
        '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _abortSession();
      },
      child: Scaffold(
        backgroundColor: ReleafColors.background,
        body: SafeArea(
          child: AnimatedSwitcher(
            duration: ReleafMotion.slow,
            switchInCurve: ReleafMotion.entranceCurve,
            switchOutCurve: Curves.easeInCubic,
            child: _session!.isEmergency
                ? (_phase == SessionPhase.running
                    ? _buildLegacyEmergencyRunningState(timeString)
                    : _buildLegacyEmergencyFeedbackState())
                : (_phase == SessionPhase.running
                    ? _buildPremiumRunningState(timeString)
                    : _buildPremiumFeedbackState()),
          ),
        ),
      ),
    );
  }

  Widget _buildPremiumRunningState(String timeString) {
    final session = _session!;
    final reducedMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    final progress = session.durationSeconds <= 0
        ? 1.0
        : 1 - (_remainingSeconds / session.durationSeconds);
    final phaseLabel = _sessionPhaseLabel(session);
    final artwork = _artworkFor(session);

    return Stack(
      key: const ValueKey('running'),
      fit: StackFit.expand,
      children: [
        ReleafArtwork(
          variant: artwork,
          intensity: 0.42,
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                ReleafColors.background.withValues(alpha: 0.62),
                ReleafColors.background.withValues(alpha: 0.78),
                ReleafColors.background.withValues(alpha: 0.96),
              ],
              stops: const [0, 0.48, 1],
            ),
          ),
        ),
        Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final formSize = math.min(
                  math.max(230.0, constraints.maxWidth * 0.64),
                  math.min(360.0, constraints.maxHeight * 0.54),
                );

                return Padding(
                  padding: const EdgeInsets.fromLTRB(
                    ReleafSpacing.screen,
                    ReleafSpacing.sm,
                    ReleafSpacing.screen,
                    ReleafSpacing.xl,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _SessionTopBar(
                        session: session,
                        timeString: timeString,
                        showTimer: widget.launchOptions.showSessionTimer,
                        onClose: _abortSession,
                      ),
                      const SizedBox(height: ReleafSpacing.sm),
                      Expanded(
                        child: Center(
                          child: SizedBox(
                            width: formSize,
                            height: formSize,
                            child: ReleafSessionLivingForm(
                              variant: artwork,
                              progress: progress,
                              breathing:
                                  session.program?.type ==
                                  ResetProgramType.pacedBreathing,
                              phaseLabel: phaseLabel,
                              inhaleSeconds:
                                  session.program?.breathPattern?.inhaleSeconds ??
                                  4,
                              holdAfterInhaleSeconds:
                                  session
                                      .program
                                      ?.breathPattern
                                      ?.holdAfterInhaleSeconds ??
                                  0,
                              exhaleSeconds:
                                  session.program?.breathPattern?.exhaleSeconds ??
                                  4,
                              holdAfterExhaleSeconds:
                                  session
                                      .program
                                      ?.breathPattern
                                      ?.holdAfterExhaleSeconds ??
                                  0,
                              reducedMotion: reducedMotion,
                            ),
                          ),
                        ),
                      ),
                      if (widget.launchOptions.showGuidanceText)
                        Padding(
                          key: const Key('reset-active-session-guidance'),
                          padding: const EdgeInsets.fromLTRB(
                            ReleafSpacing.sm,
                            ReleafSpacing.sm,
                            ReleafSpacing.sm,
                            0,
                          ),
                          child: Column(
                            children: [
                              Text(
                                _guidanceTitle(session),
                                textAlign: TextAlign.center,
                                style: ReleafTypography.eyebrow.copyWith(
                                  color: ReleafColors.sage.withValues(
                                    alpha: 0.90,
                                  ),
                                ),
                              ),
                              const SizedBox(height: ReleafSpacing.xs),
                              AnimatedSwitcher(
                                duration: ReleafMotion.standard,
                                switchInCurve: ReleafMotion.entranceCurve,
                                switchOutCurve: Curves.easeInCubic,
                                child: Text(
                                  _currentGuidance(session),
                                  key: ValueKey(
                                    'guidance-${_sessionStepIndex(session)}',
                                  ),
                                  textAlign: TextAlign.center,
                                  style: ReleafTypography.body.copyWith(
                                    color: ReleafColors.textPrimary.withValues(
                                      alpha: 0.78,
                                    ),
                                    fontSize: 16,
                                    height: 1.45,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        const SizedBox(
                          key: Key('reset-active-session-guidance-hidden'),
                          height: 1,
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPremiumFeedbackState() {
    final session = _session!;
    final artwork = _artworkFor(session);

    return Stack(
      key: const ValueKey('feedback'),
      fit: StackFit.expand,
      children: [
        ReleafArtwork(
          variant: artwork,
          intensity: 0.28,
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            color: ReleafColors.background.withValues(alpha: 0.84),
          ),
        ),
        Align(
          alignment: Alignment.center,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: ReleafSpacing.screen,
              vertical: ReleafSpacing.xl,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: SizedBox(
                      width: 170,
                      height: 170,
                      child: ReleafLivingForm(
                        variant: artwork,
                        opacity: 0.92,
                      ),
                    ),
                  ),
                  const SizedBox(height: ReleafSpacing.xl),
                  Text(
                    'RESET COMPLETE',
                    textAlign: TextAlign.center,
                    style: ReleafTypography.eyebrow.copyWith(
                      color: ReleafColors.sage,
                    ),
                  ),
                  const SizedBox(height: ReleafSpacing.sm),
                  const Text(
                    'Did this help settle your nerves?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 28,
                      height: 1.2,
                      fontWeight: FontWeight.w700,
                      color: ReleafColors.textPrimary,
                      letterSpacing: -0.7,
                    ),
                  ),
                  const SizedBox(height: ReleafSpacing.sm),
                  Text(
                    'There is no right answer — this helps Releaf understand the session outcome.',
                    textAlign: TextAlign.center,
                    style: ReleafTypography.body.copyWith(
                      color: ReleafColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: ReleafSpacing.xxl),
                  SizedBox(
                    height: ReleafControlSizes.prominent,
                    child: FilledButton(
                      onPressed: () => _submitFeedbackAndClose(true),
                      style: FilledButton.styleFrom(
                        backgroundColor: ReleafColors.sage,
                        foregroundColor: ReleafColors.background,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(ReleafRadii.pill),
                        ),
                      ),
                      child: const Text(
                        'Yes, much better',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: ReleafSpacing.sm),
                  SizedBox(
                    height: ReleafControlSizes.prominent,
                    child: OutlinedButton(
                      onPressed: () => _submitFeedbackAndClose(false),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: ReleafColors.textSecondary,
                        side: const BorderSide(
                          color: ReleafColors.border,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(ReleafRadii.pill),
                        ),
                      ),
                      child: const Text(
                        'Not really',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLegacyEmergencyRunningState(String timeString) {
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
        if (widget.launchOptions.showSessionTimer)
          Text(
            timeString,
            key: const Key('reset-active-session-timer'),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 64,
              fontWeight: FontWeight.w300,
              color: Color(0xFFF0F2F5),
              letterSpacing: -1.5,
            ),
          )
        else
          Text(
            _session!.title,
            key: const Key('reset-active-session-title'),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w500,
              color: Color(0xFFF0F2F5),
              letterSpacing: -0.5,
            ),
          ),
        const Spacer(flex: 3),
        if (widget.launchOptions.showGuidanceText)
          Padding(
            key: const Key('reset-active-session-guidance'),
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
          )
        else
          const SizedBox(
            key: Key('reset-active-session-guidance-hidden'),
            height: 1,
          ),
        const Spacer(flex: 2),
      ],
    );
  }

  Widget _buildLegacyEmergencyFeedbackState() {
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

  String? _sessionPhaseLabel(ResetContent session) {
    final program = session.program;
    if (program == null) return null;

    final elapsed = _elapsedSeconds(session);

    if (program.type == ResetProgramType.pacedBreathing) {
      final pattern = program.breathPattern;
      if (pattern == null) return null;
      final frame = pattern.frameAtElapsedSeconds(elapsed);
      return _breathPhaseLabel(frame.phase);
    }

    return program.stepAtElapsedSeconds(elapsed).label;
  }

  int _sessionStepIndex(ResetContent session) {
    final program = session.program;
    if (program != null) {
      return program.stepIndexAtElapsedSeconds(_elapsedSeconds(session));
    }

    if (session.instructions.isEmpty || session.durationSeconds <= 0) return 0;
    final elapsed = _elapsedSeconds(session);
    final segment = session.durationSeconds / session.instructions.length;
    return math.min(
      session.instructions.length - 1,
      (elapsed / segment).floor(),
    );
  }

  String _currentGuidance(ResetContent session) {
    final program = session.program;
    if (program != null) {
      return program.stepAtElapsedSeconds(_elapsedSeconds(session)).guidance;
    }

    if (session.instructions.isEmpty) return 'Settle in.';
    return session.instructions[_sessionStepIndex(session)];
  }

  int _elapsedSeconds(ResetContent session) {
    return (session.durationSeconds - _remainingSeconds)
        .clamp(0, session.durationSeconds);
  }

  String _breathPhaseLabel(BreathPhase phase) {
    return switch (phase) {
      BreathPhase.inhale => 'Breathe in',
      BreathPhase.holdAfterInhale => 'Hold',
      BreathPhase.exhale => 'Breathe out',
      BreathPhase.holdAfterExhale => 'Rest',
    };
  }

  String _guidanceTitle(ResetContent session) {
    if (session.program?.type == ResetProgramType.pacedBreathing) {
      return 'FOLLOW THE RHYTHM';
    }
    return 'STAY WITH THE MOMENT';
  }

  ReleafArtworkVariant _artworkFor(ResetContent session) {
    return switch (session.id) {
      '60s-grounding' => ReleafArtworkVariant.grounding,
      '90s-calm-down' => ReleafArtworkVariant.calm,
      '5min-focus' => ReleafArtworkVariant.focus,
      '3min-breath' => ReleafArtworkVariant.deepReset,
      _ => ReleafArtworkVariant.ambient,
    };
  }
}

class _SessionTopBar extends StatelessWidget {
  const _SessionTopBar({
    required this.session,
    required this.timeString,
    required this.showTimer,
    required this.onClose,
  });

  final ResetContent session;
  final String timeString;
  final bool showTimer;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ReleafRoundIconButton(
          icon: Icons.close_rounded,
          tooltip: 'Exit reset',
          onPressed: onClose,
        ),
        const SizedBox(width: ReleafSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                session.level == ResetLevel.deep
                    ? 'DEEP RESET'
                    : 'QUICK RESET',
                style: ReleafTypography.eyebrow,
              ),
              const SizedBox(height: 2),
              Text(
                session.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: ReleafTypography.cardTitle.copyWith(
                  color: ReleafColors.textPrimary.withValues(alpha: 0.90),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: ReleafSpacing.sm),
        if (showTimer)
          DecoratedBox(
            decoration: BoxDecoration(
              color: ReleafColors.surfaceSoft.withValues(alpha: 0.78),
              borderRadius: BorderRadius.circular(ReleafRadii.pill),
              border: Border.all(color: ReleafColors.borderSoft),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              child: Text(
                timeString,
                key: const Key('reset-active-session-timer'),
                style: ReleafTypography.meta.copyWith(
                  color: ReleafColors.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.4,
                ),
              ),
            ),
          )
        else
          Text(
            session.title,
            key: const Key('reset-active-session-title'),
            style: const TextStyle(
              fontSize: 0,
              color: Colors.transparent,
            ),
          ),
      ],
    );
  }
}
