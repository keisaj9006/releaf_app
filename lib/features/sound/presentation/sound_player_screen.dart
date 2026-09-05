import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../theme/app_theme.dart';
import '../../../theme/releaf_design_tokens.dart';
import '../../../theme/widgets/releaf_sound_artwork.dart';
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
              child: LayoutBuilder(
                builder: (context, viewport) {
                  final compact = viewport.maxHeight < 760 ||
                      viewport.maxWidth < 360;
                  final artSize = math.min(
                    compact ? 190.0 : 320.0,
                    viewport.maxWidth * (compact ? 0.68 : 0.62),
                  );

                  return SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.fromLTRB(
                      ReleafSpacing.screen,
                      compact ? ReleafSpacing.sm : ReleafSpacing.lg,
                      ReleafSpacing.screen,
                      compact ? ReleafSpacing.md : ReleafSpacing.xl,
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 720),
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
                                  'SOUND SPACE',
                                  style: ReleafTypography.eyebrow.copyWith(
                                    color: ReleafColors.sage,
                                    letterSpacing: 1.8,
                                  ),
                                ),
                                const Spacer(),
                                ReleafRoundIconButton(
                                  icon: favorite
                                      ? Icons.favorite_rounded
                                      : Icons.favorite_border_rounded,
                                  tooltip: favorite
                                      ? 'Remove favorite'
                                      : 'Add favorite',
                                  onPressed: () =>
                                      controller.toggleFavorite(track.id),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: compact
                                  ? ReleafSpacing.md
                                  : ReleafSpacing.xxl,
                            ),
                            SizedBox(
                              width: artSize,
                              height: artSize,
                              child: _SoundArtworkDisc(
                                isPlaying: isPlaying,
                                progress: _progress(position, duration),
                                variant: _artworkForTrack(track.id),
                                reducedMotion: MediaQuery.maybeOf(context)
                                        ?.disableAnimations ??
                                    false,
                              ),
                            ),
                            SizedBox(
                              height: compact
                                  ? ReleafSpacing.md
                                  : ReleafSpacing.xl,
                            ),
                            DecoratedBox(
                              decoration: BoxDecoration(
                                color: ReleafColors.sage.withValues(alpha: 0.08),
                                borderRadius:
                                    BorderRadius.circular(ReleafRadii.pill),
                                border: Border.all(
                                  color: ReleafColors.sage.withValues(
                                    alpha: 0.20,
                                  ),
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 11,
                                  vertical: 6,
                                ),
                                child: Text(
                                  isPlaying ? 'PLAYING' : 'PAUSED',
                                  key: const Key('sound-player-state'),
                                  style: ReleafTypography.eyebrow.copyWith(
                                    fontSize: 9,
                                    color: ReleafColors.sage,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: ReleafSpacing.sm),
                            Text(
                              track.title,
                              textAlign: TextAlign.center,
                              style: ReleafTypography.display.copyWith(
                                fontSize: compact ? 25 : 28,
                                letterSpacing: -0.7,
                              ),
                            ),
                            const SizedBox(height: ReleafSpacing.xs),
                            ConstrainedBox(
                              constraints:
                                  const BoxConstraints(maxWidth: 460),
                              child: Text(
                                track.subtitle,
                                textAlign: TextAlign.center,
                                style: ReleafTypography.meta.copyWith(
                                  color: ReleafColors.textSecondary,
                                  height: 1.45,
                                ),
                              ),
                            ),
                            SizedBox(
                              height: compact
                                  ? ReleafSpacing.md
                                  : ReleafSpacing.xl,
                            ),
                            _PositionSlider(
                              position: position,
                              duration: duration,
                              onChanged: (value) {
                                if (duration.inMilliseconds <= 0) return;
                                controller.seekTo(
                                  Duration(
                                    milliseconds:
                                        (duration.inMilliseconds * value)
                                            .round(),
                                  ),
                                );
                              },
                            ),
                            SizedBox(
                              height: compact
                                  ? ReleafSpacing.xs
                                  : ReleafSpacing.md,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                IconButton(
                                  tooltip: 'Back 15 seconds',
                                  onPressed: () => controller.seekRelative(
                                    const Duration(seconds: -15),
                                  ),
                                  icon: const Icon(Icons.replay_10_rounded),
                                  iconSize: compact ? 26 : 30,
                                ),
                                SizedBox(
                                  width: compact
                                      ? ReleafSpacing.md
                                      : ReleafSpacing.lg,
                                ),
                                _PrimaryPlayButton(
                                  isPlaying: isPlaying,
                                  compact: compact,
                                  onPressed: isCurrent
                                      ? controller.togglePlayPause
                                      : () => controller.play(track),
                                ),
                                SizedBox(
                                  width: compact
                                      ? ReleafSpacing.md
                                      : ReleafSpacing.lg,
                                ),
                                IconButton(
                                  tooltip: 'Forward 15 seconds',
                                  onPressed: () => controller.seekRelative(
                                    const Duration(seconds: 15),
                                  ),
                                  icon: const Icon(Icons.forward_10_rounded),
                                  iconSize: compact ? 26 : 30,
                                ),
                              ],
                            ),
                            SizedBox(
                              height: compact
                                  ? ReleafSpacing.md
                                  : ReleafSpacing.xl,
                            ),
                            _VolumeControl(
                              volume: state.volume,
                              onChanged: controller.setVolume,
                            ),
                            SizedBox(
                              height: compact
                                  ? ReleafSpacing.md
                                  : ReleafSpacing.lg,
                            ),
                            _SleepTimer(
                              selectedMinutes: state.sleepTimerMinutes,
                              onSelected: controller.setSleepTimer,
                            ),
                            const SizedBox(height: ReleafSpacing.sm),
                          ],
                        ),
                      ),
                    ),
                  );
                },
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
        ReleafSoundArtwork(
          variant: ReleafSoundArtworkVariant.field,
          intensity: 0.80,
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xB8061014),
                Color(0xE5070E12),
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

class _SoundArtworkDisc extends StatefulWidget {
  const _SoundArtworkDisc({
    required this.isPlaying,
    required this.progress,
    required this.variant,
    required this.reducedMotion,
  });

  final bool isPlaying;
  final double progress;
  final ReleafSoundArtworkVariant variant;
  final bool reducedMotion;

  @override
  State<_SoundArtworkDisc> createState() => _SoundArtworkDiscState();
}

class _SoundArtworkDiscState extends State<_SoundArtworkDisc>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    );
    _sync();
  }

  @override
  void didUpdateWidget(covariant _SoundArtworkDisc oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isPlaying != widget.isPlaying ||
        oldWidget.reducedMotion != widget.reducedMotion) {
      _sync();
    }
  }

  void _sync() {
    if (widget.reducedMotion || !widget.isPlaying) {
      _controller
        ..stop()
        ..value = 0.28;
      return;
    }
    if (!_controller.isAnimating) {
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
    final progress = widget.progress.clamp(0.0, 1.0).toDouble();

    return Semantics(
      container: true,
      label: widget.isPlaying
          ? 'Ambient sound is playing.'
          : 'Ambient sound is paused.',
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final pulse = widget.isPlaying && !widget.reducedMotion
              ? (math.sin(_controller.value * math.pi * 2) + 1) / 2
              : 0.28;

          return CustomPaint(
            key: const Key('sound-immersive-visual'),
            painter: _SoundPulsePainter(
              t: _controller.value,
              active: widget.isPlaying && !widget.reducedMotion,
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: ReleafColors.sage.withValues(
                          alpha: 0.10 + pulse * 0.11,
                        ),
                        blurRadius: 38 + pulse * 24,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
                ClipOval(
                  child: ReleafSoundArtwork(
                    variant: widget.variant,
                    intensity: 0.92,
                  ),
                ),
                const ClipOval(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        center: Alignment(-0.20, -0.25),
                        radius: 0.95,
                        colors: [
                          Color(0x12000000),
                          Color(0x32000000),
                          Color(0x8C000000),
                        ],
                        stops: [0, 0.62, 1],
                      ),
                    ),
                  ),
                ),
                CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 2.5,
                  backgroundColor:
                      ReleafColors.borderSoft.withValues(alpha: 0.42),
                  valueColor: const AlwaysStoppedAnimation(
                    ReleafColors.sage,
                  ),
                ),
                Center(
                  child: AnimatedScale(
                    scale: 0.98 + pulse * 0.035,
                    duration: widget.reducedMotion
                        ? Duration.zero
                        : ReleafMotion.standard,
                    child: FractionallySizedBox(
                      widthFactor: 0.32,
                      heightFactor: 0.32,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color:
                              ReleafColors.background.withValues(alpha: 0.62),
                          border: Border.all(
                            color: ReleafColors.textPrimary.withValues(
                              alpha: 0.16,
                            ),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: ReleafColors.sage.withValues(
                                alpha: 0.08 + pulse * 0.08,
                              ),
                              blurRadius: 22,
                            ),
                          ],
                        ),
                        child: Icon(
                          widget.isPlaying
                              ? Icons.graphic_eq_rounded
                              : Icons.music_note_rounded,
                          size: 34,
                          color: ReleafColors.textPrimary.withValues(
                            alpha: 0.86,
                          ),
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
    );
  }
}

class _SoundPulsePainter extends CustomPainter {
  const _SoundPulsePainter({
    required this.t,
    required this.active,
  });

  final double t;
  final bool active;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;

    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.shortestSide * 0.47;

    for (var index = 0; index < 3; index++) {
      final phase = active ? (t + index * 0.29) % 1.0 : index * 0.24 + 0.18;
      final radius = maxRadius * (0.68 + phase * 0.28);
      final alpha = active ? (1 - phase) * 0.18 : 0.06;

      canvas.drawCircle(
        center,
        radius,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2
          ..color = ReleafColors.sage.withValues(alpha: alpha),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _SoundPulsePainter oldDelegate) {
    return oldDelegate.t != t || oldDelegate.active != active;
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
    this.compact = false,
  });

  final bool isPlaying;
  final VoidCallback onPressed;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      key: const Key('sound-primary-play'),
      button: true,
      label: isPlaying ? 'Pause sound' : 'Play sound',
      child: InkResponse(
        onTap: onPressed,
        radius: 42,
        child: Container(
          width: compact ? 66 : 76,
          height: compact ? 66 : 76,
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
          size: compact ? 33 : 38,
          color: ReleafColors.background,
        ),
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


ReleafSoundArtworkVariant _artworkForTrack(String id) {
  return id.endsWith('02')
      ? ReleafSoundArtworkVariant.atmosphereTwo
      : ReleafSoundArtworkVariant.atmosphereOne;
}
