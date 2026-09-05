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
        return;
      }
      setState(() => _remainingSeconds -= 1);
    });
  }

  void _togglePause() {
    HapticFeedback.selectionClick();
    setState(() => _running = !_running);
    if (_running) {
      _startTimer();
    } else {
      _timer?.cancel();
    }
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

    final elapsed = item.durationSeconds - _remainingSeconds;
    final step = _stepAt(item, elapsed);
    final progress = item.durationSeconds <= 0
        ? 1.0
        : 1 - (_remainingSeconds / item.durationSeconds);

    return Theme(
      data: AppTheme.premiumDark(),
      child: Scaffold(
        backgroundColor: ReleafColors.background,
        body: Stack(
          children: [
            Positioned.fill(
              child: ReleafArtwork(
                variant: _artworkFor(item.category),
              ),
            ),
            const Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xD6070D0B),
                      Color(0xE30A100E),
                      ReleafColors.background,
                    ],
                    stops: [0, 0.50, 1],
                  ),
                ),
              ),
            ),
            SafeArea(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 720),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      ReleafSpacing.screen,
                      ReleafSpacing.lg,
                      ReleafSpacing.screen,
                      ReleafSpacing.xl,
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            ReleafRoundIconButton(
                              icon: Icons.close_rounded,
                              tooltip: 'Exit meditation',
                              onPressed: context.pop,
                            ),
                            const SizedBox(width: ReleafSpacing.md),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'MEDITATION',
                                    style: ReleafTypography.eyebrow.copyWith(
                                      color: ReleafColors.sage,
                                    ),
                                  ),
                                  Text(
                                    item.title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: ReleafTypography.cardTitle,
                                  ),
                                ],
                              ),
                            ),
                            _TimerPill(seconds: _remainingSeconds),
                          ],
                        ),
                        const Spacer(),
                        _MeditationVisual(
                          progress: progress,
                          running: _running,
                          unguided: item.unguided,
                        ),
                        const Spacer(),
                        if (!item.unguided) ...[
                          Text(
                            step.label.toUpperCase(),
                            style: ReleafTypography.eyebrow.copyWith(
                              color: ReleafColors.sage,
                            ),
                          ),
                          const SizedBox(height: ReleafSpacing.sm),
                          AnimatedSwitcher(
                            duration: ReleafMotion.standard,
                            child: Text(
                              step.guidance,
                              key: ValueKey(step.label),
                              textAlign: TextAlign.center,
                              style: ReleafTypography.body.copyWith(
                                color: ReleafColors.textPrimary.withValues(
                                  alpha: 0.82,
                                ),
                                fontSize: 17,
                                height: 1.5,
                              ),
                            ),
                          ),
                        ] else
                          Text(
                            'Stay with the practice in your own way.',
                            textAlign: TextAlign.center,
                            style: ReleafTypography.body.copyWith(
                              color:
                                  ReleafColors.textPrimary.withValues(alpha: 0.72),
                            ),
                          ),
                        const SizedBox(height: ReleafSpacing.xl),
                        FilledButton.icon(
                          onPressed: _remainingSeconds == 0
                              ? context.pop
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
                            minimumSize: const Size.fromHeight(52),
                            backgroundColor: ReleafColors.sage,
                            foregroundColor: ReleafColors.background,
                          ),
                        ),
                      ],
                    ),
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
    var cursor = 0;
    for (final step in item.steps) {
      cursor += step.durationSeconds;
      if (elapsed < cursor) return step;
    }
    return item.steps.last;
  }
}

class _MeditationVisual extends StatelessWidget {
  const _MeditationVisual({
    required this.progress,
    required this.running,
    required this.unguided,
  });

  final double progress;
  final bool running;
  final bool unguided;

  @override
  Widget build(BuildContext context) {
    final size = math.min(
      MediaQuery.sizeOf(context).width * 0.62,
      320.0,
    );

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: running ? 1 : 0),
      duration: const Duration(milliseconds: 900),
      curve: Curves.easeInOut,
      builder: (context, active, child) {
        return SizedBox(
          width: size,
          height: size,
          child: Stack(
            fit: StackFit.expand,
            children: [
              CircularProgressIndicator(
                value: progress.clamp(0.0, 1.0).toDouble(),
                strokeWidth: 2.2,
                backgroundColor:
                    ReleafColors.borderSoft.withValues(alpha: 0.35),
                valueColor: const AlwaysStoppedAnimation(
                  ReleafColors.sage,
                ),
              ),
              Center(
                child: AnimatedScale(
                  scale: 0.95 + active * 0.05,
                  duration: const Duration(milliseconds: 900),
                  child: Container(
                    width: size * 0.68,
                    height: size * 0.68,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: ReleafColors.sage.withValues(alpha: 0.08),
                      border: Border.all(
                        color: ReleafColors.sage.withValues(alpha: 0.20),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: ReleafColors.sage.withValues(
                            alpha: 0.08 + active * 0.08,
                          ),
                          blurRadius: 34,
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      unguided
                          ? Icons.blur_on_rounded
                          : Icons.self_improvement_rounded,
                      size: 54,
                      color: ReleafColors.textPrimary.withValues(alpha: 0.74),
                    ),
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
