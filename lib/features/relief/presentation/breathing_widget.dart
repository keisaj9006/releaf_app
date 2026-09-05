import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../progress/data/leaves_repository.dart';
import '../../../theme/releaf_design_tokens.dart';
import '../../../theme/widgets/releaf_artwork.dart';
import '../../../theme/widgets/releaf_body_release_visual.dart';
import '../../../theme/widgets/releaf_components.dart';
import '../../../theme/widgets/releaf_emergency_visual.dart';
import '../../../theme/widgets/releaf_session_living_form.dart';
import '../../../theme/widgets/releaf_sensory_halo.dart';
import '../../../theme/widgets/releaf_thought_unhook_visual.dart';
import '../../../theme/widgets/releaf_wave2_visuals.dart';
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
  int _activeDurationSeconds = 0;
  Timer? _timer;
  SessionPhase _phase = SessionPhase.running;
  bool _awarded = false;
  bool _usingSimplifiedProgram = false;
  final Map<int, int> _sensoryCompletedByStep = <int, int>{};

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
        _activeDurationSeconds = session.durationSeconds;
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

  void _activateSimplifiedPath() {
    final program = _session?.program;
    if (program == null ||
        !program.hasSimplifiedPath ||
        _usingSimplifiedProgram ||
        _phase != SessionPhase.running) {
      return;
    }

    final simplifiedDuration = program.simplifiedDurationSeconds;
    if (simplifiedDuration <= 0) return;

    HapticFeedback.selectionClick();
    setState(() {
      _usingSimplifiedProgram = true;
      _sensoryCompletedByStep.clear();
      _activeDurationSeconds = simplifiedDuration;
      _remainingSeconds = simplifiedDuration;
    });
    _startTimer();
  }

  void _registerSensoryNotice() {
    final session = _session;
    if (session == null ||
        session.visualType != ResetVisualType.sensoryHalo ||
        _phase != SessionPhase.running) {
      return;
    }

    final phaseLabel = _sessionPhaseLabel(session);
    final target = _sensoryTargetFor(phaseLabel);
    if (target <= 0) return;

    final stepIndex = _sessionStepIndex(session);
    final completed = _sensoryCompletedByStep[stepIndex] ?? 0;
    if (completed >= target) return;

    HapticFeedback.selectionClick();
    final nextCompleted = completed + 1;
    setState(() {
      _sensoryCompletedByStep[stepIndex] = nextCompleted;
    });

    if (nextCompleted >= target) {
      Future<void>.delayed(const Duration(milliseconds: 420), () {
        if (!mounted || _phase != SessionPhase.running) return;
        _advanceGuidedStep();
      });
    }
  }

  void _advanceGuidedStep() {
    final session = _session;
    final program = session?.program;
    if (session == null || program == null) return;

    final steps = program.stepsFor(simplified: _usingSimplifiedProgram);
    final currentIndex = _sessionStepIndex(session);

    if (currentIndex >= steps.length - 1) {
      _timer?.cancel();
      setState(() => _remainingSeconds = 0);
      _triggerFeedbackPhase();
      return;
    }

    final nextElapsed = steps
        .take(currentIndex + 1)
        .fold<int>(0, (sum, step) => sum + step.durationSeconds);
    final nextRemaining =
        (_activeDurationSeconds - nextElapsed).clamp(0, _activeDurationSeconds);

    HapticFeedback.lightImpact();
    setState(() => _remainingSeconds = nextRemaining);
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
                    ? _buildEmergencyRunningState(timeString)
                    : _buildEmergencyFeedbackState())
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
    final progress = _activeDurationSeconds <= 0
        ? 1.0
        : 1 - (_remainingSeconds / _activeDurationSeconds);
    final phaseLabel = _sessionPhaseLabel(session);
    final artwork = _artworkFor(session);
    final breathPattern = session.program?.breathPattern;
    final isPacedBreathing =
        session.program?.type == ResetProgramType.pacedBreathing &&
        breathPattern != null;
    final showBreathPath =
        isPacedBreathing &&
        (breathPattern.hasHolds ||
            breathPattern.inhaleSeconds != breathPattern.exhaleSeconds);

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
                  math.max(210.0, constraints.maxWidth * 0.62),
                  math.min(
                    350.0,
                    constraints.maxHeight * (isPacedBreathing ? 0.42 : 0.54),
                  ),
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
                            child: switch (session.visualType) {
                              ResetVisualType.sensoryHalo =>
                                ReleafSensoryHalo(
                                  progress: progress,
                                  targetCount: _sensoryTargetFor(phaseLabel),
                                  completedCount:
                                      _sensoryCompletedFor(session),
                                  phaseLabel: phaseLabel ?? 'Notice',
                                  onNotice: _sensoryTargetFor(phaseLabel) > 0
                                      ? _registerSensoryNotice
                                      : null,
                                  reducedMotion: reducedMotion,
                                ),
                              ResetVisualType.bodyRelease =>
                                ReleafBodyReleaseVisual(
                                  progress: progress,
                                  phaseLabel: phaseLabel ?? 'Notice',
                                  reducedMotion: reducedMotion,
                                ),
                              ResetVisualType.thoughtUnhook =>
                                ReleafThoughtUnhookVisual(
                                  progress: progress,
                                  phaseLabel: phaseLabel ?? 'Notice',
                                  reducedMotion: reducedMotion,
                                ),
                              ResetVisualType.objectFocus =>
                                ReleafObjectFocusVisual(
                                  progress: progress,
                                  phaseLabel: phaseLabel ?? 'Choose',
                                  reducedMotion: reducedMotion,
                                ),
                              ResetVisualType.soundRipple =>
                                ReleafSoundRippleVisual(
                                  progress: progress,
                                  phaseLabel: phaseLabel ?? 'Listen',
                                  reducedMotion: reducedMotion,
                                ),
                              ResetVisualType.acceptanceSpace =>
                                ReleafAcceptanceSpaceVisual(
                                  progress: progress,
                                  phaseLabel: phaseLabel ?? 'Notice',
                                  reducedMotion: reducedMotion,
                                ),
                              ResetVisualType.nextStep =>
                                ReleafNextStepVisual(
                                  progress: progress,
                                  phaseLabel: phaseLabel ?? 'Pause',
                                  reducedMotion: reducedMotion,
                                ),
                              ResetVisualType.livingForm =>
                                ReleafSessionLivingForm(
                                  variant: artwork,
                                  progress: progress,
                                  breathing: isPacedBreathing,
                                  phaseLabel: phaseLabel,
                                  inhaleSeconds:
                                      breathPattern?.inhaleSeconds ?? 4,
                                  holdAfterInhaleSeconds:
                                      breathPattern
                                              ?.holdAfterInhaleSeconds ??
                                          0,
                                  exhaleSeconds:
                                      breathPattern?.exhaleSeconds ?? 4,
                                  holdAfterExhaleSeconds:
                                      breathPattern
                                              ?.holdAfterExhaleSeconds ??
                                          0,
                                  showBreathPath: showBreathPath,
                                  reducedMotion: reducedMotion,
                                ),
                            },
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
                                    'guidance-${_sessionStepIndex(session)}-$_usingSimplifiedProgram',
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
                              if (session.visualType ==
                                      ResetVisualType.sensoryHalo &&
                                  _sensoryTargetFor(phaseLabel) > 0) ...[
                                const SizedBox(height: ReleafSpacing.xs),
                                Text(
                                  'Tap the halo each time you notice one.',
                                  key: const Key('reset-sensory-tap-hint'),
                                  textAlign: TextAlign.center,
                                  style: ReleafTypography.meta.copyWith(
                                    color: ReleafColors.sage.withValues(
                                      alpha: 0.82,
                                    ),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        )
                      else
                        const SizedBox(
                          key: Key('reset-active-session-guidance-hidden'),
                          height: 1,
                        ),
                      if (widget.launchOptions.showGuidanceText &&
                          _currentAdvanceActionLabel(session) != null) ...[
                        const SizedBox(height: ReleafSpacing.sm),
                        Center(
                          child: OutlinedButton.icon(
                            key: const Key('reset-step-advance-action'),
                            onPressed: _advanceGuidedStep,
                            icon: const Icon(
                              Icons.arrow_forward_rounded,
                              size: 17,
                            ),
                            label: Text(
                              _currentAdvanceActionLabel(session)!,
                              style: ReleafTypography.meta.copyWith(
                                color: ReleafColors.textPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: ReleafColors.sage,
                              side: BorderSide(
                                color: ReleafColors.sage.withValues(alpha: 0.30),
                              ),
                              backgroundColor: ReleafColors.sage.withValues(
                                alpha: 0.06,
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: ReleafSpacing.md,
                                vertical: 11,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(ReleafRadii.pill),
                              ),
                            ),
                          ),
                        ),
                      ],
                      if (session.program?.hasSimplifiedPath == true) ...[
                        const SizedBox(height: ReleafSpacing.sm),
                        if (!_usingSimplifiedProgram)
                          Center(
                            child: OutlinedButton.icon(
                              key: const Key('reset-simplify-action'),
                              onPressed: _activateSimplifiedPath,
                              icon: const Icon(
                                Icons.compress_rounded,
                                size: 17,
                              ),
                              label: Text(
                                session.program!.simplifyActionLabel ??
                                    'Try a simpler version',
                                style: ReleafTypography.meta.copyWith(
                                  color: ReleafColors.textPrimary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: ReleafColors.sage,
                                side: BorderSide(
                                  color: ReleafColors.sage.withValues(
                                    alpha: 0.34,
                                  ),
                                ),
                                backgroundColor: ReleafColors.sage.withValues(
                                  alpha: 0.07,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: ReleafSpacing.md,
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(ReleafRadii.pill),
                                ),
                              ),
                            ),
                          )
                        else
                          Center(
                            child: Text(
                              'SIMPLIFIED 3–2–1',
                              key: const Key('reset-simplified-active'),
                              style: ReleafTypography.eyebrow.copyWith(
                                color: ReleafColors.sage.withValues(alpha: 0.82),
                              ),
                            ),
                          ),
                      ],
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

  Widget _buildEmergencyRunningState(String timeString) {
    final session = _session!;
    final reducedMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    final progress = _activeDurationSeconds <= 0
        ? 1.0
        : 1 - (_remainingSeconds / _activeDurationSeconds);
    final phaseLabel = _sessionPhaseLabel(session) ?? 'Arrive';
    final guidance = _currentGuidance(session);
    final steps = session.program?.steps ?? const <ResetSessionStep>[];
    final stepIndex = _sessionStepIndex(session);

    return Stack(
      key: const ValueKey('running'),
      fit: StackFit.expand,
      children: [
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF0C1612),
                ReleafColors.background,
                Color(0xFF050907),
              ],
              stops: [0, 0.58, 1],
            ),
          ),
        ),
        Positioned(
          top: -90,
          right: -80,
          width: 300,
          height: 300,
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    ReleafColors.sage.withValues(alpha: 0.10),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ),
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 620),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final compactHeight = constraints.maxHeight < 620;
                final visualSize = math.min(
                  compactHeight ? 230.0 : 310.0,
                  math.max(205.0, constraints.maxWidth * 0.76),
                );

                return Padding(
                  padding: const EdgeInsets.fromLTRB(
                    ReleafSpacing.screen,
                    ReleafSpacing.sm,
                    ReleafSpacing.screen,
                    ReleafSpacing.lg,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          ReleafRoundIconButton(
                            icon: Icons.close_rounded,
                            tooltip: 'Exit Emergency Calm',
                            onPressed: _abortSession,
                          ),
                          const SizedBox(width: ReleafSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'EMERGENCY CALM',
                                  style: ReleafTypography.eyebrow.copyWith(
                                    color: ReleafColors.sage,
                                    letterSpacing: 1.9,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  'Stay with this screen.',
                                  style: ReleafTypography.cardTitle.copyWith(
                                    fontSize: 17,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (widget.launchOptions.showSessionTimer)
                            DecoratedBox(
                              decoration: BoxDecoration(
                                color: ReleafColors.surfaceSoft.withValues(
                                  alpha: 0.82,
                                ),
                                borderRadius: BorderRadius.circular(
                                  ReleafRadii.pill,
                                ),
                                border: Border.all(
                                  color: ReleafColors.borderSoft,
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                child: Text(
                                  timeString,
                                  key: const Key(
                                    'reset-active-session-timer',
                                  ),
                                  style: ReleafTypography.meta.copyWith(
                                    color: ReleafColors.textPrimary,
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
                      ),
                      SizedBox(
                        height: compactHeight
                            ? ReleafSpacing.md
                            : ReleafSpacing.xl,
                      ),
                      Expanded(
                        child: Center(
                          child: SizedBox(
                            width: visualSize,
                            height: visualSize,
                            child: ReleafEmergencyVisual(
                              progress: progress,
                              phaseLabel: phaseLabel,
                              reducedMotion: reducedMotion,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: compactHeight
                            ? ReleafSpacing.sm
                            : ReleafSpacing.lg,
                      ),
                      Center(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: ReleafColors.sage.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(
                              ReleafRadii.pill,
                            ),
                            border: Border.all(
                              color: ReleafColors.sage.withValues(alpha: 0.20),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 7,
                            ),
                            child: Text(
                              phaseLabel.toUpperCase(),
                              key: const Key('emergency-phase-label'),
                              style: ReleafTypography.eyebrow.copyWith(
                                fontSize: 10,
                                color: ReleafColors.sage,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: ReleafSpacing.sm),
                      if (widget.launchOptions.showGuidanceText)
                        Semantics(
                          key: const Key('reset-active-session-guidance'),
                          liveRegion: true,
                          label: guidance,
                          child: AnimatedSwitcher(
                            duration: reducedMotion
                                ? Duration.zero
                                : ReleafMotion.standard,
                            child: Text(
                              guidance,
                              key: ValueKey(
                                'emergency-guidance-$phaseLabel',
                              ),
                              textAlign: TextAlign.center,
                              style: ReleafTypography.body.copyWith(
                                color: ReleafColors.textPrimary.withValues(
                                  alpha: 0.90,
                                ),
                                fontSize: compactHeight ? 15 : 17,
                                height: 1.48,
                              ),
                            ),
                          ),
                        )
                      else
                        const SizedBox(
                          key: Key('reset-active-session-guidance-hidden'),
                          height: 1,
                        ),
                      const SizedBox(height: ReleafSpacing.md),
                      if (steps.isNotEmpty)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            for (var index = 0;
                                index < steps.length;
                                index++) ...[
                              AnimatedContainer(
                                duration: reducedMotion
                                    ? Duration.zero
                                    : ReleafMotion.standard,
                                width: index == stepIndex ? 22 : 7,
                                height: 7,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(
                                    ReleafRadii.pill,
                                  ),
                                  color: index <= stepIndex
                                      ? ReleafColors.sage.withValues(
                                          alpha:
                                              index == stepIndex ? 0.88 : 0.38,
                                        )
                                      : ReleafColors.border,
                                ),
                              ),
                              if (index != steps.length - 1)
                                const SizedBox(width: 6),
                            ],
                          ],
                        ),
                      const SizedBox(height: ReleafSpacing.sm),
                      Text(
                        'Go at your own pace. You can stop at any time.',
                        textAlign: TextAlign.center,
                        style: ReleafTypography.meta.copyWith(
                          color: ReleafColors.textMuted,
                        ),
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

  Widget _buildEmergencyFeedbackState() {
    final reducedMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;

    return Stack(
      key: const ValueKey('feedback'),
      fit: StackFit.expand,
      children: [
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF0E1914),
                ReleafColors.background,
                Color(0xFF060A08),
              ],
            ),
          ),
        ),
        Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: ReleafSpacing.screen,
              vertical: ReleafSpacing.xl,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: SizedBox(
                      width: 180,
                      height: 180,
                      child: ReleafEmergencyVisual(
                        progress: 1,
                        phaseLabel: 'Return',
                        reducedMotion: reducedMotion,
                      ),
                    ),
                  ),
                  const SizedBox(height: ReleafSpacing.xl),
                  Text(
                    'YOU STAYED WITH IT',
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
                      fontSize: 27,
                      height: 1.2,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.6,
                      color: ReleafColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: ReleafSpacing.sm),
                  Text(
                    'Choose the answer that feels closest. There is no score here.',
                    textAlign: TextAlign.center,
                    style: ReleafTypography.body.copyWith(
                      color: ReleafColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: ReleafSpacing.xxl),
                  SizedBox(
                    height: ReleafControlSizes.prominent,
                    child: FilledButton(
                      key: const Key('emergency-feedback-helped'),
                      onPressed: () => _submitFeedbackAndClose(true),
                      style: FilledButton.styleFrom(
                        backgroundColor: ReleafColors.sage,
                        foregroundColor: ReleafColors.background,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            ReleafRadii.pill,
                          ),
                        ),
                      ),
                      child: const Text(
                        'A little steadier',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: ReleafSpacing.sm),
                  SizedBox(
                    height: ReleafControlSizes.prominent,
                    child: OutlinedButton(
                      key: const Key('emergency-feedback-not-yet'),
                      onPressed: () => _submitFeedbackAndClose(false),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: ReleafColors.textSecondary,
                        side: const BorderSide(color: ReleafColors.border),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            ReleafRadii.pill,
                          ),
                        ),
                      ),
                      child: const Text(
                        'Not yet',
                        style: TextStyle(
                          fontFamily: 'Poppins',
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

    return program
        .stepAtElapsedSeconds(
          elapsed,
          simplified: _usingSimplifiedProgram,
        )
        .label;
  }

  int _sessionStepIndex(ResetContent session) {
    final program = session.program;
    if (program != null) {
      return program.stepIndexAtElapsedSeconds(
        _elapsedSeconds(session),
        simplified: _usingSimplifiedProgram,
      );
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
      return program
          .stepAtElapsedSeconds(
            _elapsedSeconds(session),
            simplified: _usingSimplifiedProgram,
          )
          .guidance;
    }

    if (session.instructions.isEmpty) return 'Settle in.';
    return session.instructions[_sessionStepIndex(session)];
  }

  String? _currentAdvanceActionLabel(ResetContent session) {
    final program = session.program;
    if (program == null || program.type != ResetProgramType.guidedSteps) {
      return null;
    }

    return program
        .stepAtElapsedSeconds(
          _elapsedSeconds(session),
          simplified: _usingSimplifiedProgram,
        )
        .advanceActionLabel;
  }

  int _elapsedSeconds(ResetContent session) {
    return (_activeDurationSeconds - _remainingSeconds)
        .clamp(0, _activeDurationSeconds);
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
    return switch (session.visualType) {
      ResetVisualType.sensoryHalo => 'GROUND WITH YOUR SENSES',
      ResetVisualType.bodyRelease => 'RELEASE BODY TENSION',
      ResetVisualType.thoughtUnhook => 'CREATE A LITTLE DISTANCE',
      ResetVisualType.objectFocus => 'FOCUS ON ONE REAL THING',
      ResetVisualType.soundRipple => 'LISTEN TO WHAT IS HERE',
      ResetVisualType.acceptanceSpace => 'MAKE ROOM WITHOUT FIGHTING',
      ResetVisualType.nextStep => 'ONLY THE NEXT STEP',
      ResetVisualType.livingForm => 'STAY WITH THE MOMENT',
    };
  }

  int _sensoryTargetFor(String? phaseLabel) {
    if (_usingSimplifiedProgram) {
      return switch (phaseLabel) {
        'See' => 3,
        'Feel' => 2,
        'Hear' => 1,
        _ => 0,
      };
    }

    return switch (phaseLabel) {
      'See' => 5,
      'Feel' => 4,
      'Hear' => 3,
      'Smell' => 2,
      'Taste' => 1,
      _ => 0,
    };
  }

  int _sensoryCompletedFor(ResetContent session) {
    final stepIndex = _sessionStepIndex(session);
    return _sensoryCompletedByStep[stepIndex] ?? 0;
  }

  ReleafArtworkVariant _artworkFor(ResetContent session) {
    return switch (session.id) {
      '60s-grounding' => ReleafArtworkVariant.grounding,
      'back-to-room' => ReleafArtworkVariant.noBreath,
      'jaw-shoulders' => ReleafArtworkVariant.grounding,
      'name-the-thought' => ReleafArtworkVariant.focus,
      'object-anchor' => ReleafArtworkVariant.grounding,
      'sound-anchor' => ReleafArtworkVariant.ambient,
      'press-release' => ReleafArtworkVariant.noBreath,
      'make-room' => ReleafArtworkVariant.focus,
      'one-small-next-step' => ReleafArtworkVariant.lifeUpgrade,
      'equal-rhythm' => ReleafArtworkVariant.breath,
      'before-interview' => ReleafArtworkVariant.situational,
      'before-presentation' => ReleafArtworkVariant.calm,
      'after-conflict' => ReleafArtworkVariant.focus,
      'panic-spike' => ReleafArtworkVariant.grounding,
      'overthinking-night' => ReleafArtworkVariant.focus,
      'social-pressure' => ReleafArtworkVariant.situational,
      'travel-stress' => ReleafArtworkVariant.ambient,
      'work-overwhelm' => ReleafArtworkVariant.lifeUpgrade,
      'wired-steady' => ReleafArtworkVariant.breath,
      'tension-body-scan' => ReleafArtworkVariant.grounding,
      'overwhelm-stability' => ReleafArtworkVariant.lifeUpgrade,
      'evening-unwind' => ReleafArtworkVariant.ambient,
      'anger-release' => ReleafArtworkVariant.noBreath,
      'overthinking-let-go' => ReleafArtworkVariant.focus,
      '90s-calm-down' => ReleafArtworkVariant.calm,
      'longer-exhale' => ReleafArtworkVariant.breath,
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
