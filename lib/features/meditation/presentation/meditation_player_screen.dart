import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../theme/app_theme.dart';
import '../../../theme/releaf_design_tokens.dart';
import '../../../theme/widgets/releaf_artwork.dart';
import '../../../theme/widgets/releaf_components.dart';
import '../../../theme/widgets/releaf_session_living_form.dart';
import '../application/meditation_audio_controller.dart';
import '../data/meditation_catalog.dart';
import '../domain/meditation_content.dart';

class MeditationPlayerScreen extends ConsumerStatefulWidget {
  const MeditationPlayerScreen({
    super.key,
    required this.meditationId,
  });

  final String meditationId;

  @override
  ConsumerState<MeditationPlayerScreen> createState() =>
      _MeditationPlayerScreenState();
}

class _MeditationPlayerScreenState
    extends ConsumerState<MeditationPlayerScreen> {
  Timer? _timer;
  int _remainingSeconds = 0;
  bool _running = true;

  @override
  void initState() {
    super.initState();
    final item =
        ref.read(meditationCatalogProvider).getById(widget.meditationId);
    _remainingSeconds = item?.durationSeconds ?? 0;
    _startTimer();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || item == null) return;
      unawaited(
        ref.read(meditationAudioControllerProvider.notifier).start(
              soundId: item.backgroundSoundId,
              volume: item.backgroundSoundVolume,
            ),
      );
    });
  }

  void _startTimer() {
    _timer?.cancel();
    if (!_running || _remainingSeconds <= 0) return;

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted || !_running) return;
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
        return;
      }
      setState(() => _remainingSeconds -= 1);
    });
  }

  void _togglePause() {
    HapticFeedback.selectionClick();
    setState(() => _running = !_running);

    final audioController =
        ref.read(meditationAudioControllerProvider.notifier);

    if (_running) {
      _startTimer();
      unawaited(audioController.resumeForSession());
    } else {
      _timer?.cancel();
      unawaited(audioController.pauseForSession());
    }
  }

  Future<void> _exitMeditation() async {
    _timer?.cancel();
    await ref.read(meditationAudioControllerProvider.notifier).stop();
    if (mounted) context.pop();
  }

  @override
  void dispose() {
    _timer?.cancel();
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

    final audioState = ref.watch(meditationAudioControllerProvider);

    final elapsed = item.durationSeconds - _remainingSeconds;
    final step = _stepAt(item, elapsed);
    final stepIndex = _stepIndexAt(item, elapsed);
    final progress = item.durationSeconds <= 0
        ? 1.0
        : 1 - (_remainingSeconds / item.durationSeconds);
    final reducedMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    final artwork = _artworkFor(item.category);

    return Theme(
      data: AppTheme.premiumDark(),
      child: Scaffold(
        backgroundColor: ReleafColors.background,
        body: Stack(
          children: [
            Positioned.fill(
              child: ReleafArtwork(
                variant: artwork,
                intensity: 0.34,
              ),
            ),
            const Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xC8070D0B),
                      Color(0xE50A100E),
                      ReleafColors.background,
                    ],
                    stops: [0, 0.46, 1],
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
                          compact ? ReleafSpacing.md : ReleafSpacing.xl,
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                ReleafRoundIconButton(
                                  icon: Icons.close_rounded,
                                  tooltip: 'Exit meditation',
                                  onPressed: _exitMeditation,
                                ),
                                const SizedBox(width: ReleafSpacing.md),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'MEDITATION',
                                        style:
                                            ReleafTypography.eyebrow.copyWith(
                                          color: ReleafColors.sage,
                                          letterSpacing: 1.8,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        item.title,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style:
                                            ReleafTypography.cardTitle.copyWith(
                                          fontSize: compact ? 14 : 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: ReleafSpacing.sm),
                                _TimerPill(seconds: _remainingSeconds),
                              ],
                            ),
                            SizedBox(
                              height: compact
                                  ? ReleafSpacing.sm
                                  : ReleafSpacing.lg,
                            ),
                            Expanded(
                              child: Center(
                                child: _MeditationVisual(
                                  progress: progress,
                                  running: _running,
                                  unguided: item.unguided,
                                  variant: artwork,
                                  phaseLabel:
                                      item.unguided ? null : step.label,
                                  reducedMotion: reducedMotion,
                                  maxSize: compact ? 205 : 320,
                                ),
                              ),
                            ),
                            SizedBox(
                              height: compact
                                  ? ReleafSpacing.sm
                                  : ReleafSpacing.lg,
                            ),
                            DecoratedBox(
                              decoration: BoxDecoration(
                                color: ReleafColors.surfaceSoft.withValues(
                                  alpha: 0.78,
                                ),
                                borderRadius: BorderRadius.circular(
                                  ReleafRadii.large,
                                ),
                                border: Border.all(
                                  color: ReleafColors.borderSoft,
                                ),
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(
                                  compact
                                      ? ReleafSpacing.md
                                      : ReleafSpacing.lg,
                                ),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        for (var index = 0;
                                            index < item.steps.length;
                                            index++) ...[
                                          AnimatedContainer(
                                            duration: reducedMotion
                                                ? Duration.zero
                                                : ReleafMotion.standard,
                                            width:
                                                index == stepIndex ? 22 : 7,
                                            height: 7,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                ReleafRadii.pill,
                                              ),
                                              color: index <= stepIndex
                                                  ? ReleafColors.sage
                                                      .withValues(
                                                      alpha:
                                                          index == stepIndex
                                                              ? 0.88
                                                              : 0.36,
                                                    )
                                                  : ReleafColors.border,
                                            ),
                                          ),
                                          if (index != item.steps.length - 1)
                                            const SizedBox(width: 6),
                                        ],
                                      ],
                                    ),
                                    const SizedBox(height: ReleafSpacing.sm),
                                    if (!item.unguided) ...[
                                      Text(
                                        step.label.toUpperCase(),
                                        style:
                                            ReleafTypography.eyebrow.copyWith(
                                          color: ReleafColors.sage,
                                          fontSize: 10,
                                        ),
                                      ),
                                      const SizedBox(
                                        height: ReleafSpacing.xs,
                                      ),
                                      AnimatedSwitcher(
                                        duration: reducedMotion
                                            ? Duration.zero
                                            : ReleafMotion.standard,
                                        child: Text(
                                          step.guidance,
                                          key: ValueKey(step.label),
                                          textAlign: TextAlign.center,
                                          style:
                                              ReleafTypography.body.copyWith(
                                            color: ReleafColors.textPrimary
                                                .withValues(alpha: 0.84),
                                            fontSize: compact ? 14 : 16,
                                            height: 1.48,
                                          ),
                                        ),
                                      ),
                                    ] else
                                      Text(
                                        'Stay with the practice in your own way.',
                                        textAlign: TextAlign.center,
                                        style:
                                            ReleafTypography.body.copyWith(
                                          color: ReleafColors.textPrimary
                                              .withValues(alpha: 0.72),
                                          fontSize: compact ? 14 : 16,
                                        ),
                                      ),
                                    if (item.backgroundSoundId != null) ...[
                                      SizedBox(
                                        height: compact
                                            ? ReleafSpacing.xs
                                            : ReleafSpacing.sm,
                                      ),
                                      _MeditationSoundControl(
                                        enabled: audioState.enabled,
                                        onPressed: () {
                                          unawaited(
                                            ref
                                                .read(
                                                  meditationAudioControllerProvider
                                                      .notifier,
                                                )
                                                .toggleEnabled(),
                                          );
                                        },
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(
                              height: compact
                                  ? ReleafSpacing.sm
                                  : ReleafSpacing.lg,
                            ),
                            SizedBox(
                              height: ReleafControlSizes.prominent,
                              width: double.infinity,
                              child: FilledButton.icon(
                                key: const Key('meditation-primary-control'),
                                onPressed: _remainingSeconds == 0
                                    ? _exitMeditation
                                    : _togglePause,
                                icon: Icon(
                                  _remainingSeconds == 0
                                      ? Icons.check_rounded
                                      : _running
                                          ? Icons.pause_rounded
                                          : Icons.play_arrow_rounded,
                                ),
                                label: Text(
                                  _remainingSeconds == 0
                                      ? 'Finish'
                                      : _running
                                          ? 'Pause'
                                          : 'Continue',
                                ),
                                style: FilledButton.styleFrom(
                                  backgroundColor: ReleafColors.sage,
                                  foregroundColor: ReleafColors.background,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      ReleafRadii.pill,
                                    ),
                                  ),
                                ),
                              ),
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

class _MeditationVisual extends StatelessWidget {
  const _MeditationVisual({
    required this.progress,
    required this.running,
    required this.unguided,
    required this.variant,
    required this.phaseLabel,
    required this.reducedMotion,
    required this.maxSize,
  });

  final double progress;
  final bool running;
  final bool unguided;
  final ReleafArtworkVariant variant;
  final String? phaseLabel;
  final bool reducedMotion;
  final double maxSize;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final available = math.min(
          constraints.maxWidth,
          constraints.maxHeight,
        );
        final size = math.min(maxSize, available).clamp(0.0, maxSize).toDouble();

        return SizedBox(
          key: const Key('meditation-living-form'),
          width: size,
          height: size,
          child: Stack(
            fit: StackFit.expand,
            alignment: Alignment.center,
            children: [
              ReleafSessionLivingForm(
                variant: variant,
                progress: progress,
                breathing: false,
                phaseLabel: phaseLabel,
                reducedMotion: reducedMotion || !running,
              ),
              if (!running && progress < 1)
                Center(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: ReleafColors.background.withValues(alpha: 0.78),
                      borderRadius: BorderRadius.circular(ReleafRadii.pill),
                      border: Border.all(
                        color: ReleafColors.sage.withValues(alpha: 0.28),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 7,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.pause_rounded,
                            size: 15,
                            color: ReleafColors.sage,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            'PAUSED',
                            style: ReleafTypography.eyebrow.copyWith(
                              fontSize: 9,
                              color: ReleafColors.sage,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              if (unguided)
                Positioned(
                  bottom: size * 0.10,
                  child: Text(
                    'UNGUIDED',
                    style: ReleafTypography.eyebrow.copyWith(
                      color: ReleafColors.textSecondary,
                      fontSize: 9,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _MeditationSoundControl extends StatelessWidget {
  const _MeditationSoundControl({
    required this.enabled,
    required this.onPressed,
  });

  final bool enabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final semanticLabel =
        enabled ? 'Mute ambient sound' : 'Play ambient sound';

    return Semantics(
      button: true,
      label: semanticLabel,
      child: Material(
        color: ReleafColors.sage.withValues(alpha: enabled ? 0.09 : 0.035),
        shape: StadiumBorder(
          side: BorderSide(
            color: ReleafColors.sage.withValues(alpha: enabled ? 0.28 : 0.14),
          ),
        ),
        child: InkWell(
          key: const Key('meditation-sound-control'),
          customBorder: const StadiumBorder(),
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 11,
              vertical: 7,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  enabled
                      ? Icons.graphic_eq_rounded
                      : Icons.volume_off_rounded,
                  size: 15,
                  color: enabled
                      ? ReleafColors.sage
                      : ReleafColors.textSecondary,
                ),
                const SizedBox(width: 6),
                Text(
                  'AMBIENCE',
                  style: ReleafTypography.eyebrow.copyWith(
                    color: enabled
                        ? ReleafColors.sage
                        : ReleafColors.textSecondary,
                    fontSize: 9,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  enabled ? 'ON' : 'OFF',
                  style: ReleafTypography.meta.copyWith(
                    color: enabled
                        ? ReleafColors.textPrimary.withValues(alpha: 0.78)
                        : ReleafColors.textSecondary,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
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
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    final label =
        '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(ReleafRadii.pill),
        color: ReleafColors.surfaceSoft,
        border: Border.all(color: ReleafColors.borderSoft),
      ),
      child: Text(
        label,
        style: ReleafTypography.meta.copyWith(
          color: ReleafColors.textPrimary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

ReleafArtworkVariant _artworkFor(MeditationCategory category) {
  return switch (category) {
    MeditationCategory.startHere => ReleafArtworkVariant.focus,
    MeditationCategory.anxiety => ReleafArtworkVariant.calm,
    MeditationCategory.mind => ReleafArtworkVariant.focus,
    MeditationCategory.body => ReleafArtworkVariant.grounding,
    MeditationCategory.everyday => ReleafArtworkVariant.lifeUpgrade,
    MeditationCategory.unguided => ReleafArtworkVariant.ambient,
  };
}
