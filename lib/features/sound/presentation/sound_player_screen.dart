import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../theme/app_theme.dart';
import '../../../theme/releaf_design_tokens.dart';
import '../../../theme/widgets/releaf_artwork.dart';
import '../../../theme/widgets/releaf_components.dart';
import '../application/sound_player_controller.dart';
import '../data/sound_catalog.dart';

class SoundPlayerScreen extends ConsumerStatefulWidget {
  const SoundPlayerScreen({
    super.key,
    required this.trackId,
  });

  final String trackId;

  @override
  ConsumerState<SoundPlayerScreen> createState() => _SoundPlayerScreenState();
}

class _SoundPlayerScreenState extends ConsumerState<SoundPlayerScreen> {
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;

    final track = ref.read(soundCatalogProvider).getById(widget.trackId);
    if (track != null) {
      Future<void>.microtask(
        () => ref.read(soundPlayerControllerProvider.notifier).play(track),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final catalog = ref.watch(soundCatalogProvider);
    final track = catalog.getById(widget.trackId);
    final state = ref.watch(soundPlayerControllerProvider);
    final controller = ref.read(soundPlayerControllerProvider.notifier);

    if (track == null) {
      return Theme(
        data: AppTheme.premiumDark(),
        child: Scaffold(
          backgroundColor: ReleafColors.background,
          appBar: AppBar(title: const Text('Sound unavailable')),
          body: const Center(child: Text('This sound is not available.')),
        ),
      );
    }

    final isCurrent = state.currentTrackId == track.id;
    final isPlaying = isCurrent && state.isPlaying;
    final duration = isCurrent ? state.duration : Duration.zero;
    final position = isCurrent ? state.position : Duration.zero;
    final favorite = state.favoriteIds.contains(track.id);

    return Theme(
      data: AppTheme.premiumDark(),
      child: Scaffold(
        backgroundColor: ReleafColors.background,
        body: Stack(
          children: [
            const Positioned.fill(child: _PlayerBackdrop()),
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
                              icon: Icons.keyboard_arrow_down_rounded,
                              tooltip: 'Close player',
                              onPressed: context.pop,
                            ),
                            const Spacer(),
                            Text(
                              'SOUND',
                              style: ReleafTypography.eyebrow.copyWith(
                                color: ReleafColors.sage,
                              ),
                            ),
                            const Spacer(),
                            ReleafRoundIconButton(
                              icon: favorite
                                  ? Icons.favorite_rounded
                                  : Icons.favorite_border_rounded,
                              tooltip:
                                  favorite ? 'Remove favorite' : 'Add favorite',
                              onPressed: () =>
                                  controller.toggleFavorite(track.id),
                            ),
                          ],
                        ),
                        const SizedBox(height: ReleafSpacing.xl),
                        Expanded(
                          child: Center(
                            child: _SoundArtworkDisc(
                              isPlaying: isPlaying,
                              progress: _progress(position, duration),
                              variant: track.id.endsWith('02')
                                  ? ReleafArtworkVariant.focus
                                  : ReleafArtworkVariant.ambient,
                            ),
                          ),
                        ),
                        const SizedBox(height: ReleafSpacing.lg),
                        Text(
                          track.title,
                          textAlign: TextAlign.center,
                          style: ReleafTypography.display.copyWith(
                            fontSize: 28,
                            letterSpacing: -0.7,
                          ),
                        ),
                        const SizedBox(height: ReleafSpacing.xs),
                        Text(
                          track.subtitle,
                          textAlign: TextAlign.center,
                          style: ReleafTypography.meta.copyWith(
                            color: ReleafColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: ReleafSpacing.xl),
                        _PositionSlider(
                          position: position,
                          duration: duration,
                          onChanged: (value) {
                            if (duration.inMilliseconds <= 0) return;
                            controller.seekTo(
                              Duration(
                                milliseconds:
                                    (duration.inMilliseconds * value).round(),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: ReleafSpacing.md),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              tooltip: 'Back 15 seconds',
                              onPressed: () => controller.seekRelative(
                                const Duration(seconds: -15),
                              ),
                              icon: const Icon(Icons.replay_10_rounded),
                              iconSize: 30,
                            ),
                            const SizedBox(width: ReleafSpacing.lg),
                            _PrimaryPlayButton(
                              isPlaying: isPlaying,
                              onPressed: isCurrent
                                  ? controller.togglePlayPause
                                  : () => controller.play(track),
                            ),
                            const SizedBox(width: ReleafSpacing.lg),
                            IconButton(
                              tooltip: 'Forward 15 seconds',
                              onPressed: () => controller.seekRelative(
                                const Duration(seconds: 15),
                              ),
                              icon: const Icon(Icons.forward_10_rounded),
                              iconSize: 30,
                            ),
                          ],
                        ),
                        const SizedBox(height: ReleafSpacing.xl),
                        _VolumeControl(
                          volume: state.volume,
                          onChanged: controller.setVolume,
                        ),
                        const SizedBox(height: ReleafSpacing.lg),
                        _SleepTimer(
                          selectedMinutes: state.sleepTimerMinutes,
                          onSelected: controller.setSleepTimer,
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

  double _progress(Duration position, Duration duration) {
    if (duration.inMilliseconds <= 0) return 0;
    return (position.inMilliseconds / duration.inMilliseconds)
        .clamp(0.0, 1.0)
        .toDouble();
  }
}

class _PlayerBackdrop extends StatelessWidget {
  const _PlayerBackdrop();

  @override
  Widget build(BuildContext context) {
    return const Stack(
      fit: StackFit.expand,
      children: [
        ReleafArtwork(variant: ReleafArtworkVariant.ambient),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xC4070D0B),
                Color(0xE90A100E),
                ReleafColors.background,
              ],
              stops: [0, 0.52, 1],
            ),
          ),
        ),
      ],
    );
  }
}

class _SoundArtworkDisc extends StatelessWidget {
  const _SoundArtworkDisc({
    required this.isPlaying,
    required this.progress,
    required this.variant,
  });

  final bool isPlaying;
  final double progress;
  final ReleafArtworkVariant variant;

  @override
  Widget build(BuildContext context) {
    final size = math.min(
      MediaQuery.sizeOf(context).width * 0.70,
      MediaQuery.sizeOf(context).height * 0.40,
    ).clamp(220.0, 360.0).toDouble();

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: isPlaying ? 1 : 0),
      duration: const Duration(milliseconds: 900),
      curve: Curves.easeInOut,
      builder: (context, active, child) {
        return SizedBox(
          width: size,
          height: size,
          child: Stack(
            fit: StackFit.expand,
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: ReleafColors.sage.withValues(
                        alpha: 0.10 + active * 0.12,
                      ),
                      blurRadius: 36 + active * 24,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              ),
              ClipOval(
                child: ReleafArtwork(variant: variant),
              ),
              CircularProgressIndicator(
                value: progress,
                strokeWidth: 2.4,
                backgroundColor:
                    ReleafColors.borderSoft.withValues(alpha: 0.35),
                valueColor: const AlwaysStoppedAnimation(
                  ReleafColors.sage,
                ),
              ),
              Center(
                child: Container(
                  width: size * 0.31,
                  height: size * 0.31,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: ReleafColors.background.withValues(alpha: 0.50),
                    border: Border.all(
                      color: ReleafColors.textPrimary.withValues(alpha: 0.16),
                    ),
                  ),
                  child: Icon(
                    isPlaying
                        ? Icons.graphic_eq_rounded
                        : Icons.graphic_eq_outlined,
                    size: size * 0.13,
                    color: ReleafColors.textPrimary.withValues(alpha: 0.84),
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

class _PositionSlider extends StatelessWidget {
  const _PositionSlider({
    required this.position,
    required this.duration,
    required this.onChanged,
  });

  final Duration position;
  final Duration duration;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    final value = duration.inMilliseconds <= 0
        ? 0.0
        : (position.inMilliseconds / duration.inMilliseconds)
            .clamp(0.0, 1.0)
            .toDouble();

    return Column(
      children: [
        Slider(
          value: value,
          onChanged: duration.inMilliseconds <= 0 ? null : onChanged,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Row(
            children: [
              Text(_formatDuration(position), style: ReleafTypography.meta),
              const Spacer(),
              Text(_formatDuration(duration), style: ReleafTypography.meta),
            ],
          ),
        ),
      ],
    );
  }
}

class _PrimaryPlayButton extends StatelessWidget {
  const _PrimaryPlayButton({
    required this.isPlaying,
    required this.onPressed,
  });

  final bool isPlaying;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      onTap: onPressed,
      radius: 42,
      child: Container(
        width: 76,
        height: 76,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: ReleafColors.sage,
          boxShadow: [
            BoxShadow(
              color: ReleafColors.glowSage,
              blurRadius: 26,
              spreadRadius: 2,
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Icon(
          isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
          size: 38,
          color: ReleafColors.background,
        ),
      ),
    );
  }
}

class _VolumeControl extends StatelessWidget {
  const _VolumeControl({
    required this.volume,
    required this.onChanged,
  });

  final double volume;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(
          Icons.volume_down_rounded,
          size: 20,
          color: ReleafColors.textSecondary,
        ),
        Expanded(
          child: Slider(
            value: volume,
            onChanged: onChanged,
          ),
        ),
        const Icon(
          Icons.volume_up_rounded,
          size: 20,
          color: ReleafColors.textSecondary,
        ),
      ],
    );
  }
}

class _SleepTimer extends StatelessWidget {
  const _SleepTimer({
    required this.selectedMinutes,
    required this.onSelected,
  });

  final int? selectedMinutes;
  final ValueChanged<int?> onSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'SLEEP TIMER',
          style: ReleafTypography.eyebrow.copyWith(
            color: ReleafColors.textSecondary,
          ),
        ),
        const SizedBox(height: ReleafSpacing.sm),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 8,
          runSpacing: 8,
          children: [
            _TimerChip(
              label: 'Off',
              selected: selectedMinutes == null,
              onTap: () => onSelected(null),
            ),
            for (final minutes in const [15, 30, 60])
              _TimerChip(
                label: '$minutes min',
                selected: selectedMinutes == minutes,
                onTap: () => onSelected(minutes),
              ),
          ],
        ),
      ],
    );
  }
}

class _TimerChip extends StatelessWidget {
  const _TimerChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      selected: selected,
      label: Text(label),
      onSelected: (_) => onTap(),
      selectedColor: ReleafColors.sage.withValues(alpha: 0.20),
      backgroundColor: ReleafColors.surfaceSoft,
      side: BorderSide(
        color: selected ? ReleafColors.sage : ReleafColors.borderSoft,
      ),
      labelStyle: ReleafTypography.meta.copyWith(
        color: selected ? ReleafColors.textPrimary : ReleafColors.textSecondary,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

String _formatDuration(Duration duration) {
  final minutes = duration.inMinutes;
  final seconds = duration.inSeconds.remainder(60);
  return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
}
