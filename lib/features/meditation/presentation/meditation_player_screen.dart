import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/session/session_manager.dart';
import '../../../routing/app_routes.dart';
import '../../../theme/app_theme.dart';
import '../../../theme/releaf_design_tokens.dart';
import '../../../theme/widgets/releaf_components.dart';
import '../../../theme/widgets/releaf_meditation_artwork.dart';
import '../../sound/application/sound_player_controller.dart';
import '../application/meditation_audio_controller.dart';
import '../application/meditation_library_controller.dart';
import '../application/meditation_voice_controller.dart';
import '../data/meditation_catalog.dart';
import '../domain/meditation_content.dart';
import '../domain/meditation_resume_state.dart';

class MeditationPlayerScreen extends ConsumerStatefulWidget {
  const MeditationPlayerScreen({
    super.key,
    required this.meditationId,
    this.resumeState,
  });

  final String meditationId;
  final MeditationResumeState? resumeState;

  @override
  ConsumerState<MeditationPlayerScreen> createState() =>
      _MeditationPlayerScreenState();
}

class _MeditationPlayerScreenState
    extends ConsumerState<MeditationPlayerScreen> {
  Timer? _timer;
  int _remainingSeconds = 0;
  bool _running = true;
  int _lastSpokenStepIndex = -1;

  @override
  void initState() {
    super.initState();

    final item =
        ref.read(meditationCatalogProvider).getById(widget.meditationId);
    final fullDuration = item?.durationSeconds ?? 0;
    final resumed = widget.resumeState?.remainingSeconds;

    _remainingSeconds = resumed == null
        ? fullDuration
        : resumed.clamp(1, fullDuration).toInt();
    _running = widget.resumeState == null;
    _startTimer();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted || item == null) return;

      final soundState = ref.read(soundPlayerControllerProvider);
      if (soundState.isPlaying) {
        await ref.read(soundPlayerControllerProvider.notifier).pause();
        if (!mounted) return;
      }

      unawaited(
        ref
            .read(meditationLibraryControllerProvider.notifier)
            .markRecent(item.id),
      );

      if (widget.resumeState != null) {
        ref.read(sessionManagerProvider.notifier).clear();
      }

      unawaited(
        ref.read(meditationAudioControllerProvider.notifier).start(
              soundId: item.backgroundSoundId,
              volume: item.backgroundSoundVolume,
              playImmediately: _running,
            ),
      );

      if (_running) {
        unawaited(_announceCurrentStep(force: true));
      }
    });
  }

  void _startTimer() {
    _timer?.cancel();
    if (!_running || _remainingSeconds <= 0) return;

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted || !_running) return;

      final item =
          ref.read(meditationCatalogProvider).getById(widget.meditationId);
      final previousStepIndex = item == null
          ? -1
          : _stepIndexAt(
              item,
              item.durationSeconds - _remainingSeconds,
            );

      if (_remainingSeconds <= 1) {
        timer.cancel();
        HapticFeedback.mediumImpact();

        setState(() {
          _remainingSeconds = 0;
          _running = false;
        });

        unawaited(
          ref.read(meditationAudioControllerProvider.notifier).stop(),
        );
        unawaited(
          ref.read(meditationVoiceControllerProvider.notifier).stop(),
        );

        if (item != null) {
          ref.read(sessionManagerProvider.notifier).clear();
          unawaited(
            ref
                .read(meditationLibraryControllerProvider.notifier)
                .markCompleted(item.id),
          );
        }
        return;
      }

      setState(() => _remainingSeconds -= 1);

      if (item != null && !item.unguided) {
        final nextStepIndex = _stepIndexAt(
          item,
          item.durationSeconds - _remainingSeconds,
        );
        if (nextStepIndex != previousStepIndex) {
          unawaited(_announceCurrentStep(force: true));
        }
      }
    });
  }

  Future<void> _togglePause() async {
    if (_remainingSeconds <= 0) {
      await _exitMeditation();
      return;
    }

    HapticFeedback.selectionClick();
    setState(() => _running = !_running);

    final ambience =
        ref.read(meditationAudioControllerProvider.notifier);
    final voice = ref.read(meditationVoiceControllerProvider.notifier);

    if (_running) {
      _startTimer();
      unawaited(ambience.resumeForSession());
      unawaited(_announceCurrentStep(force: true));
    } else {
      _timer?.cancel();
      unawaited(ambience.pauseForSession());
      unawaited(voice.stop());
    }
  }

  void _seekBy(int seconds) {
    if (_remainingSeconds <= 0) return;

    final item =
        ref.read(meditationCatalogProvider).getById(widget.meditationId);
    if (item == null || item.durationSeconds <= 1) return;

    final elapsed = item.durationSeconds - _remainingSeconds;
    final maxElapsed = item.durationSeconds - 1;
    final nextElapsed =
        (elapsed + seconds).clamp(0, maxElapsed).toInt();

    HapticFeedback.selectionClick();

    setState(() {
      _remainingSeconds = item.durationSeconds - nextElapsed;
    });

    _lastSpokenStepIndex = -1;
    if (_running && !item.unguided) {
      unawaited(_announceCurrentStep(force: true));
    }
  }

  Future<void> _announceCurrentStep({bool force = false}) async {
    if (!_running || _remainingSeconds <= 0) return;

    final item =
        ref.read(meditationCatalogProvider).getById(widget.meditationId);
    if (item == null || item.unguided || item.steps.isEmpty) return;

    final elapsed = item.durationSeconds - _remainingSeconds;
    final stepIndex = _stepIndexAt(item, elapsed);

    if (!force && _lastSpokenStepIndex == stepIndex) return;

    _lastSpokenStepIndex = stepIndex;
    await ref
        .read(meditationVoiceControllerProvider.notifier)
        .speakGuidance(
          item.steps[stepIndex].spokenGuidance ??
              item.steps[stepIndex].guidance,
        );
  }

  Future<void> _toggleGuideVoice() async {
    final controller =
        ref.read(meditationVoiceControllerProvider.notifier);
    await controller.toggleEnabled();

    if (!mounted) return;

    final enabled = ref.read(meditationVoiceControllerProvider).enabled;
    if (enabled && _running) {
      _lastSpokenStepIndex = -1;
      unawaited(_announceCurrentStep(force: true));
    }
  }

  Future<void> _exitMeditation() async {
    _timer?.cancel();

    final item =
        ref.read(meditationCatalogProvider).getById(widget.meditationId);

    if (item != null &&
        _remainingSeconds > 0 &&
        _remainingSeconds < item.durationSeconds) {
      ref.read(sessionManagerProvider.notifier).setPausedSession(
            title: item.title,
            subtitle:
                'Meditation · ${_resumeTimeLabel(_remainingSeconds)} remaining',
            resumeRoute: AppRoutes.meditationSessionFor(item.id),
            extra: MeditationResumeState(
              remainingSeconds: _remainingSeconds,
            ),
          );
    } else if (_remainingSeconds == 0) {
      ref.read(sessionManagerProvider.notifier).clear();
    }

    await Future.wait([
      ref.read(meditationAudioControllerProvider.notifier).stop(),
      ref.read(meditationVoiceControllerProvider.notifier).stop(),
    ]);

    if (mounted) context.pop();
  }

  Future<void> _showControls(MeditationContent item) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF0A100E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) {
        return Consumer(
          builder: (context, sheetRef, _) {
            final voice = sheetRef.watch(meditationVoiceControllerProvider);
            final ambience = sheetRef.watch(meditationAudioControllerProvider);

            return SafeArea(
              top: false,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  ReleafSpacing.screen,
                  ReleafSpacing.xl,
                  ReleafSpacing.screen,
                  ReleafSpacing.xl,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'MEDITATION AUDIO',
                                style: ReleafTypography.eyebrow.copyWith(
                                  color: ReleafFeatureAccents.meditation,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Make the session comfortable with your eyes closed.',
                                style: ReleafTypography.sectionTitle.copyWith(
                                  fontSize: 21,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          tooltip: 'Close controls',
                          onPressed: () => Navigator.of(sheetContext).pop(),
                          icon: const Icon(Icons.close_rounded),
                        ),
                      ],
                    ),
                    const SizedBox(height: ReleafSpacing.xl),
                    if (!item.unguided) ...[
                      _ControlSection(
                        key: const Key('meditation-voice-control'),
                        icon: Icons.record_voice_over_outlined,
                        title: 'Guide voice',
                        subtitle:
                            'Releaf Guide · female English voice · slow pace',
                        trailing: Switch.adaptive(
                          key: const Key('meditation-voice-toggle'),
                          value: voice.enabled,
                          onChanged: (_) {
                            unawaited(_toggleGuideVoice());
                          },
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Narration volume · ${(voice.volume * 100).round()}%',
                              style: ReleafTypography.meta.copyWith(
                                color: ReleafColors.textSecondary,
                              ),
                            ),
                            Slider(
                              key: const Key('meditation-voice-volume'),
                              value: voice.volume,
                              onChanged: voice.enabled
                                  ? (value) {
                                      unawaited(
                                        sheetRef
                                            .read(
                                              meditationVoiceControllerProvider
                                                  .notifier,
                                            )
                                            .setVolume(value),
                                      );
                                    }
                                  : null,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: ReleafSpacing.sm),
                      _ControlSection(
                        icon: Icons.closed_caption_outlined,
                        title: 'On-screen guidance',
                        subtitle:
                            'Off by default so the practice works with closed eyes.',
                        trailing: Switch.adaptive(
                          key: const Key('meditation-captions-toggle'),
                          value: voice.showCaptions,
                          onChanged: (_) {
                            unawaited(
                              sheetRef
                                  .read(
                                    meditationVoiceControllerProvider.notifier,
                                  )
                                  .toggleCaptions(),
                            );
                          },
                        ),
                      ),
                    ],
                    if (item.backgroundSoundId != null) ...[
                      const SizedBox(height: ReleafSpacing.sm),
                      _ControlSection(
                        key: const Key('meditation-sound-control'),
                        icon: Icons.graphic_eq_rounded,
                        title: 'Ambience',
                        subtitle:
                            ambience.trackTitle ?? 'Background sound',
                        trailing: Switch.adaptive(
                          key: const Key('meditation-sound-toggle'),
                          value: ambience.enabled,
                          onChanged: (_) {
                            unawaited(
                              sheetRef
                                  .read(
                                    meditationAudioControllerProvider.notifier,
                                  )
                                  .toggleEnabled(),
                            );
                          },
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Background mix · ${(ambience.mix * 100).round()}%',
                              style: ReleafTypography.meta.copyWith(
                                color: ReleafColors.textSecondary,
                              ),
                            ),
                            Slider(
                              key: const Key('meditation-sound-mix'),
                              value: ambience.mix,
                              onChanged: ambience.enabled
                                  ? (value) {
                                      unawaited(
                                        sheetRef
                                            .read(
                                              meditationAudioControllerProvider
                                                  .notifier,
                                            )
                                            .setMix(value),
                                      );
                                    }
                                  : null,
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: ReleafSpacing.lg),
                    Text(
                      'Releaf currently prioritises a female English system voice and a deliberately slow meditation pace. This remains a temporary narration layer; the production target is a dedicated recorded Releaf Guide so every device sounds identical.',
                      style: ReleafTypography.meta.copyWith(
                        color: ReleafColors.textMuted,
                        fontSize: 9.5,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    // The autoDispose voice provider owns platform cleanup. ConsumerState.ref
    // must not be read once teardown has started.
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final item =
        ref.watch(meditationCatalogProvider).getById(widget.meditationId);

    if (item == null) {
      return Theme(
        data: AppTheme.premiumDark(),
        child: Scaffold(
          backgroundColor: ReleafColors.background,
          appBar: AppBar(title: const Text('Meditation unavailable')),
        ),
      );
    }

    final voiceState = ref.watch(meditationVoiceControllerProvider);
    final audioState = ref.watch(meditationAudioControllerProvider);
    final elapsed = item.durationSeconds - _remainingSeconds;
    final step = _stepAt(item, elapsed);
    final stepIndex = _stepIndexAt(item, elapsed);
    final progress = item.durationSeconds <= 0
        ? 1.0
        : 1 - (_remainingSeconds / item.durationSeconds);
    final reducedMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;

    return Theme(
      data: AppTheme.premiumDark(),
      child: Scaffold(
        backgroundColor: ReleafColors.background,
        body: Stack(
          children: [
            Positioned.fill(
              child: _SlowMeditationBackdrop(
                key: const Key('meditation-ambient-visual'),
                reducedMotion: reducedMotion,
                child: ReleafMeditationArtwork(
                  variant: _meditationArtworkFor(item.category),
                  intensity: 0.96,
                ),
              ),
            ),
            Positioned.fill(
              child: _MeditationAtmosphereMotion(
                key: const Key('meditation-atmosphere-motion'),
                reducedMotion: reducedMotion,
                variant: _meditationArtworkFor(item.category),
              ),
            ),
            const Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0x50050A08),
                      Color(0x66070C0A),
                      Color(0xE9080C0A),
                    ],
                    stops: [0, 0.54, 1],
                  ),
                ),
              ),
            ),
            SafeArea(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 720),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final compactHeight = constraints.maxHeight < 680;
                      final compactWidth = constraints.maxWidth < 360;
                      final compact = compactHeight || compactWidth;

                      return Padding(
                        padding: EdgeInsets.fromLTRB(
                          ReleafSpacing.screen,
                          compact ? ReleafSpacing.sm : ReleafSpacing.lg,
                          ReleafSpacing.screen,
                          compact ? ReleafSpacing.sm : ReleafSpacing.lg,
                        ),
                        child: Column(
                          children: [
                            _MeditationHeader(
                              item: item,
                              remainingSeconds: _remainingSeconds,
                              compact: compact,
                              onClose: _exitMeditation,
                              onControls: () => _showControls(item),
                            ),
                            const SizedBox(height: ReleafSpacing.sm),
                            Expanded(
                              child: _MeditationStage(
                                phaseLabel: item.unguided
                                    ? 'UNGUIDED'
                                    : step.label.toUpperCase(),
                                guidance: item.unguided
                                    ? 'Stay with the practice in your own way.'
                                    : step.guidance,
                                showCaptions:
                                    !item.unguided && voiceState.showCaptions,
                                running: _running,
                                completed: _remainingSeconds == 0,
                                voiceEnabled:
                                    !item.unguided && voiceState.enabled,
                                compact: compact,
                              ),
                            ),
                            const SizedBox(height: ReleafSpacing.sm),
                            _MeditationPlaybackDock(
                              progress: progress,
                              elapsedSeconds: elapsed,
                              remainingSeconds: _remainingSeconds,
                              running: _running,
                              completed: _remainingSeconds == 0,
                              stepIndex: stepIndex,
                              stepCount: item.steps.length,
                              voiceEnabled:
                                  !item.unguided && voiceState.enabled,
                              captionsEnabled:
                                  !item.unguided && voiceState.showCaptions,
                              hasVoice: !item.unguided,
                              hasAmbience: item.backgroundSoundId != null,
                              ambienceEnabled: audioState.enabled,
                              compact: compact,
                              onBack15: () => _seekBy(-15),
                              onForward15: () => _seekBy(15),
                              onPrimary: () {
                                unawaited(_togglePause());
                              },
                              onVoice: _toggleGuideVoice,
                              onCaptions: () {
                                unawaited(
                                  ref
                                      .read(
                                        meditationVoiceControllerProvider
                                            .notifier,
                                      )
                                      .toggleCaptions(),
                                );
                              },
                              onAmbience: () {
                                unawaited(
                                  ref
                                      .read(
                                        meditationAudioControllerProvider
                                            .notifier,
                                      )
                                      .toggleEnabled(),
                                );
                              },
                              onControls: () => _showControls(item),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  MeditationStep _stepAt(MeditationContent item, int elapsed) {
    return item.steps[_stepIndexAt(item, elapsed)];
  }

  int _stepIndexAt(MeditationContent item, int elapsed) {
    var cursor = 0;
    for (var index = 0; index < item.steps.length; index++) {
      cursor += item.steps[index].durationSeconds;
      if (elapsed < cursor) return index;
    }
    return item.steps.length - 1;
  }
}

class _MeditationHeader extends StatelessWidget {
  const _MeditationHeader({
    required this.item,
    required this.remainingSeconds,
    required this.compact,
    required this.onClose,
    required this.onControls,
  });

  final MeditationContent item;
  final int remainingSeconds;
  final bool compact;
  final VoidCallback onClose;
  final VoidCallback onControls;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ReleafRoundIconButton(
          icon: Icons.close_rounded,
          tooltip: 'Exit meditation',
          accentColor: ReleafFeatureAccents.meditation,
          onPressed: onClose,
        ),
        const SizedBox(width: ReleafSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.unguided
                    ? 'UNGUIDED MEDITATION'
                    : 'GUIDED · RELEAF VOICE',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: ReleafTypography.eyebrow.copyWith(
                  color: ReleafFeatureAccents.meditation,
                  fontSize: compact ? 8.5 : 9.5,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                item.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: ReleafTypography.cardTitle.copyWith(
                  fontSize: compact ? 15 : 17,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: ReleafSpacing.xs),
        _TimerPill(seconds: remainingSeconds),
        const SizedBox(width: 4),
        IconButton(
          key: const Key('meditation-controls-button'),
          tooltip: 'Meditation audio controls',
          onPressed: onControls,
          icon: const Icon(
            Icons.tune_rounded,
            size: 20,
            color: ReleafColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _MeditationStage extends StatelessWidget {
  const _MeditationStage({
    required this.phaseLabel,
    required this.guidance,
    required this.showCaptions,
    required this.running,
    required this.completed,
    required this.voiceEnabled,
    required this.compact,
  });

  final String phaseLabel;
  final String guidance;
  final bool showCaptions;
  final bool running;
  final bool completed;
  final bool voiceEnabled;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final status = completed
        ? 'Practice complete'
        : !running
            ? 'Paused'
            : voiceEnabled
                ? 'Close your eyes and follow the voice.'
                : 'Voice is off. Use captions or continue in silence.';

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 520,
          maxHeight: compact ? 330 : 460,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _MeditationFocusGlow(
              running: running,
              completed: completed,
              compact: compact,
            ),
            SizedBox(
              height: compact ? ReleafSpacing.sm : ReleafSpacing.lg,
            ),
            AnimatedSwitcher(
              duration: ReleafMotion.standard,
              child: Text(
                completed ? 'COMPLETE' : phaseLabel,
                key: ValueKey(completed ? 'complete' : phaseLabel),
                textAlign: TextAlign.center,
                style: ReleafTypography.eyebrow.copyWith(
                  color: ReleafFeatureAccents.meditation,
                  fontSize: 10,
                  letterSpacing: 2.0,
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              status,
              textAlign: TextAlign.center,
              style: ReleafTypography.meta.copyWith(
                color: ReleafColors.textPrimary.withValues(alpha: 0.78),
                fontSize: compact ? 11 : 12,
                height: 1.4,
              ),
            ),
            AnimatedSize(
              duration: ReleafMotion.standard,
              child: showCaptions && !completed
                  ? Padding(
                      padding: const EdgeInsets.only(top: ReleafSpacing.md),
                      child: Container(
                        key: const Key('meditation-caption-panel'),
                        constraints: const BoxConstraints(maxWidth: 480),
                        padding: EdgeInsets.symmetric(
                          horizontal: compact
                              ? ReleafSpacing.md
                              : ReleafSpacing.lg,
                          vertical: compact
                              ? ReleafSpacing.sm
                              : ReleafSpacing.md,
                        ),
                        decoration: BoxDecoration(
                          color: ReleafColors.background.withValues(alpha: 0.58),
                          borderRadius:
                              BorderRadius.circular(ReleafRadii.large),
                          border: Border.all(
                            color: ReleafFeatureAccents.meditation
                                .withValues(alpha: 0.18),
                          ),
                        ),
                        child: Text(
                          guidance,
                          textAlign: TextAlign.center,
                          style: ReleafTypography.body.copyWith(
                            color:
                                ReleafColors.textPrimary.withValues(alpha: 0.88),
                            fontSize: compact ? 13 : 15,
                            height: 1.5,
                          ),
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}

class _MeditationFocusGlow extends StatefulWidget {
  const _MeditationFocusGlow({
    required this.running,
    required this.completed,
    required this.compact,
  });

  final bool running;
  final bool completed;
  final bool compact;

  @override
  State<_MeditationFocusGlow> createState() => _MeditationFocusGlowState();
}

class _MeditationFocusGlowState extends State<_MeditationFocusGlow>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 8),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reducedMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    final size = widget.compact ? 112.0 : 158.0;

    if (reducedMotion || !widget.running || widget.completed) {
      return _glow(size, widget.completed ? 1 : 0.35);
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final value = Curves.easeInOut.transform(_controller.value);
        return Transform.scale(
          scale: 0.96 + (value * 0.08),
          child: _glow(size, value),
        );
      },
    );
  }

  Widget _glow(double size, double value) {
    final accent = ReleafFeatureAccents.meditation;

    return Container(
      key: const Key('meditation-focus-glow'),
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            accent.withValues(alpha: 0.22 + (value * 0.08)),
            accent.withValues(alpha: 0.06),
            Colors.transparent,
          ],
          stops: const [0, 0.52, 1],
        ),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: 0.10 + (value * 0.08)),
            blurRadius: 54,
            spreadRadius: 12,
          ),
        ],
      ),
      alignment: Alignment.center,
      child: AnimatedSwitcher(
        duration: ReleafMotion.standard,
        child: Icon(
          widget.completed
              ? Icons.check_rounded
              : widget.running
                  ? Icons.headphones_rounded
                  : Icons.pause_rounded,
          key: ValueKey((widget.completed, widget.running)),
          size: widget.compact ? 27 : 32,
          color: accent.withValues(alpha: 0.90),
        ),
      ),
    );
  }
}

class _MeditationPlaybackDock extends StatelessWidget {
  const _MeditationPlaybackDock({
    required this.progress,
    required this.elapsedSeconds,
    required this.remainingSeconds,
    required this.running,
    required this.completed,
    required this.stepIndex,
    required this.stepCount,
    required this.voiceEnabled,
    required this.captionsEnabled,
    required this.hasVoice,
    required this.hasAmbience,
    required this.ambienceEnabled,
    required this.compact,
    required this.onBack15,
    required this.onForward15,
    required this.onPrimary,
    required this.onVoice,
    required this.onCaptions,
    required this.onAmbience,
    required this.onControls,
  });

  final double progress;
  final int elapsedSeconds;
  final int remainingSeconds;
  final bool running;
  final bool completed;
  final int stepIndex;
  final int stepCount;
  final bool voiceEnabled;
  final bool captionsEnabled;
  final bool hasVoice;
  final bool hasAmbience;
  final bool ambienceEnabled;
  final bool compact;
  final VoidCallback onBack15;
  final VoidCallback onForward15;
  final VoidCallback onPrimary;
  final VoidCallback onVoice;
  final VoidCallback onCaptions;
  final VoidCallback onAmbience;
  final VoidCallback onControls;

  @override
  Widget build(BuildContext context) {
    final accent = ReleafFeatureAccents.meditation;

    return Container(
      padding: EdgeInsets.fromLTRB(
        compact ? ReleafSpacing.md : ReleafSpacing.lg,
        compact ? 12 : ReleafSpacing.md,
        compact ? ReleafSpacing.md : ReleafSpacing.lg,
        compact ? 10 : ReleafSpacing.md,
      ),
      decoration: BoxDecoration(
        color: const Color(0xE80A0F0D),
        borderRadius: BorderRadius.circular(ReleafRadii.extraLarge),
        border: Border.all(
          color: accent.withValues(alpha: 0.18),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x5A000000),
            blurRadius: 32,
            offset: Offset(0, 16),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(ReleafRadii.pill),
            child: LinearProgressIndicator(
              key: const Key('meditation-progress'),
              value: progress.clamp(0.0, 1.0).toDouble(),
              minHeight: 3,
              backgroundColor: ReleafColors.borderSoft,
              valueColor: AlwaysStoppedAnimation<Color>(accent),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Text(
                _clockLabel(elapsedSeconds),
                style: ReleafTypography.meta.copyWith(
                  color: ReleafColors.textMuted,
                  fontSize: 9,
                ),
              ),
              const Spacer(),
              Text(
                stepCount <= 1
                    ? 'Practice'
                    : 'Part ${math.min(stepIndex + 1, stepCount)} of $stepCount',
                style: ReleafTypography.meta.copyWith(
                  color: ReleafColors.textMuted,
                  fontSize: 9,
                ),
              ),
              const Spacer(),
              Text(
                '-${_clockLabel(remainingSeconds)}',
                style: ReleafTypography.meta.copyWith(
                  color: ReleafColors.textMuted,
                  fontSize: 9,
                ),
              ),
            ],
          ),
          SizedBox(height: compact ? 7 : ReleafSpacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _SeekControl(
                key: const Key('meditation-back-15'),
                icon: Icons.replay_10_rounded,
                label: '15',
                onPressed: completed ? null : onBack15,
              ),
              SizedBox(width: compact ? 22 : 34),
              Material(
                color: completed ? accent.withValues(alpha: 0.90) : accent,
                shape: const CircleBorder(),
                child: InkWell(
                  key: const Key('meditation-primary-control'),
                  customBorder: const CircleBorder(),
                  onTap: onPrimary,
                  child: SizedBox(
                    width: compact ? 58 : 68,
                    height: compact ? 58 : 68,
                    child: Icon(
                      completed
                          ? Icons.check_rounded
                          : running
                              ? Icons.pause_rounded
                              : Icons.play_arrow_rounded,
                      size: compact ? 28 : 32,
                      color: ReleafColors.background,
                    ),
                  ),
                ),
              ),
              SizedBox(width: compact ? 22 : 34),
              _SeekControl(
                key: const Key('meditation-forward-15'),
                icon: Icons.forward_10_rounded,
                label: '15',
                onPressed: completed ? null : onForward15,
              ),
            ],
          ),
          SizedBox(height: compact ? 7 : ReleafSpacing.sm),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 6,
            runSpacing: 6,
            children: [
              if (hasVoice)
                _UtilityChip(
                  key: const Key('meditation-voice-chip'),
                  icon: voiceEnabled
                      ? Icons.record_voice_over_rounded
                      : Icons.voice_over_off_rounded,
                  label: voiceEnabled ? 'Voice' : 'Voice off',
                  active: voiceEnabled,
                  onPressed: onVoice,
                ),
              if (hasVoice)
                _UtilityChip(
                  key: const Key('meditation-captions-chip'),
                  icon: Icons.closed_caption_outlined,
                  label: captionsEnabled ? 'Captions' : 'Captions off',
                  active: captionsEnabled,
                  onPressed: onCaptions,
                ),
              if (hasAmbience)
                _UtilityChip(
                  key: const Key('meditation-ambience-chip'),
                  icon: ambienceEnabled
                      ? Icons.graphic_eq_rounded
                      : Icons.volume_off_rounded,
                  label: ambienceEnabled ? 'Ambience' : 'Ambience off',
                  active: ambienceEnabled,
                  onPressed: onAmbience,
                ),
              _UtilityChip(
                key: const Key('meditation-more-controls'),
                icon: Icons.tune_rounded,
                label: 'Mix',
                active: false,
                onPressed: onControls,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SeekControl extends StatelessWidget {
  const _SeekControl({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: onPressed == null ? null : '$label seconds',
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(
          icon,
          size: 27,
          color: onPressed == null
              ? ReleafColors.textMuted
              : ReleafColors.textPrimary.withValues(alpha: 0.78),
        ),
      ),
    );
  }
}

class _UtilityChip extends StatelessWidget {
  const _UtilityChip({
    super.key,
    required this.icon,
    required this.label,
    required this.active,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final accent = ReleafFeatureAccents.meditation;

    return Material(
      color: active
          ? accent.withValues(alpha: 0.10)
          : ReleafColors.surfaceSoft.withValues(alpha: 0.76),
      borderRadius: BorderRadius.circular(ReleafRadii.pill),
      child: InkWell(
        borderRadius: BorderRadius.circular(ReleafRadii.pill),
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 7,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 15,
                color: active ? accent : ReleafColors.textSecondary,
              ),
              const SizedBox(width: 5),
              Text(
                label,
                style: ReleafTypography.meta.copyWith(
                  color: active ? accent : ReleafColors.textSecondary,
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ControlSection extends StatelessWidget {
  const _ControlSection({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.trailing,
    this.child,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Widget trailing;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final accent = ReleafFeatureAccents.meditation;

    return Container(
      padding: const EdgeInsets.all(ReleafSpacing.md),
      decoration: BoxDecoration(
        color: ReleafColors.surfaceSoft.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(ReleafRadii.large),
        border: Border.all(
          color: accent.withValues(alpha: 0.14),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: accent.withValues(alpha: 0.10),
                ),
                alignment: Alignment.center,
                child: Icon(icon, size: 18, color: accent),
              ),
              const SizedBox(width: ReleafSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: ReleafTypography.meta.copyWith(
                        color: ReleafColors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: ReleafTypography.meta.copyWith(
                        color: ReleafColors.textSecondary,
                        fontSize: 10,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: ReleafSpacing.sm),
              trailing,
            ],
          ),
          if (child != null) ...[
            const SizedBox(height: ReleafSpacing.sm),
            child!,
          ],
        ],
      ),
    );
  }
}

class _SlowMeditationBackdrop extends StatefulWidget {
  const _SlowMeditationBackdrop({
    super.key,
    required this.reducedMotion,
    required this.child,
  });

  final bool reducedMotion;
  final Widget child;

  @override
  State<_SlowMeditationBackdrop> createState() =>
      _SlowMeditationBackdropState();
}

class _SlowMeditationBackdropState extends State<_SlowMeditationBackdrop>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 18),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.reducedMotion) return widget.child;

    return ClipRect(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final value = Curves.easeInOut.transform(_controller.value);
          return Transform.translate(
            offset: Offset(
              (value - 0.5) * 8,
              (0.5 - value) * 5,
            ),
            child: Transform.scale(
              scale: 1.025 + (value * 0.02),
              child: child,
            ),
          );
        },
        child: widget.child,
      ),
    );
  }
}

class _MeditationAtmosphereMotion extends StatefulWidget {
  const _MeditationAtmosphereMotion({
    super.key,
    required this.reducedMotion,
    required this.variant,
  });

  final bool reducedMotion;
  final ReleafMeditationArtworkVariant variant;

  @override
  State<_MeditationAtmosphereMotion> createState() =>
      _MeditationAtmosphereMotionState();
}

class _MeditationAtmosphereMotionState
    extends State<_MeditationAtmosphereMotion>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 20),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.reducedMotion) {
      return _buildAtmosphere(0.5);
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final value = Curves.easeInOutSine.transform(_controller.value);
        return _buildAtmosphere(value);
      },
    );
  }

  Widget _buildAtmosphere(double value) {
    final accent = ReleafFeatureAccents.meditation;
    final phase = widget.variant.index.isEven ? value : 1 - value;

    return IgnorePointer(
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned(
            left: -80 + (phase * 54),
            top: 70 + (phase * 28),
            child: _AtmosphereGlow(
              size: 270,
              opacity: 0.10 + (phase * 0.045),
              color: accent,
            ),
          ),
          Positioned(
            right: -105 + ((1 - phase) * 42),
            bottom: 110 + ((1 - phase) * 36),
            child: _AtmosphereGlow(
              size: 310,
              opacity: 0.07 + ((1 - phase) * 0.035),
              color: Colors.white,
            ),
          ),
          Align(
            alignment: Alignment(
              -0.20 + (phase * 0.34),
              -0.72 + (phase * 0.18),
            ),
            child: Container(
              width: 170,
              height: 2,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(ReleafRadii.pill),
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    accent.withValues(alpha: 0.12),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AtmosphereGlow extends StatelessWidget {
  const _AtmosphereGlow({
    required this.size,
    required this.opacity,
    required this.color,
  });

  final double size;
  final double opacity;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            color.withValues(alpha: opacity),
            color.withValues(alpha: opacity * 0.32),
            Colors.transparent,
          ],
          stops: const [0, 0.48, 1],
        ),
      ),
    );
  }
}

class _TimerPill extends StatelessWidget {
  const _TimerPill({required this.seconds});

  final int seconds;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(ReleafRadii.pill),
        color: ReleafColors.surfaceSoft.withValues(alpha: 0.72),
        border: Border.all(color: ReleafColors.borderSoft),
      ),
      child: Text(
        _clockLabel(seconds),
        style: ReleafTypography.meta.copyWith(
          color: ReleafColors.textPrimary,
          fontWeight: FontWeight.w700,
          fontSize: 10,
        ),
      ),
    );
  }
}

String _clockLabel(int seconds) {
  final safe = math.max(0, seconds);
  final minutes = safe ~/ 60;
  final secs = safe % 60;
  return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
}

String _resumeTimeLabel(int seconds) {
  final minutes = seconds ~/ 60;
  final remainder = seconds % 60;
  if (minutes == 0) return '${remainder}s';
  if (remainder == 0) return '${minutes}m';
  return '${minutes}m ${remainder}s';
}

ReleafMeditationArtworkVariant _meditationArtworkFor(
  MeditationCategory category,
) {
  return switch (category) {
    MeditationCategory.startHere => ReleafMeditationArtworkVariant.editorial,
    MeditationCategory.anxiety => ReleafMeditationArtworkVariant.anxiety,
    MeditationCategory.focus => ReleafMeditationArtworkVariant.focus,
    MeditationCategory.mind => ReleafMeditationArtworkVariant.compassion,
    MeditationCategory.body => ReleafMeditationArtworkVariant.body,
    MeditationCategory.everyday => ReleafMeditationArtworkVariant.everyday,
    MeditationCategory.unguided => ReleafMeditationArtworkVariant.timer,
  };
}
