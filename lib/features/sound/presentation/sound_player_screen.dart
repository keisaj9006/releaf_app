import 'dart:async';
import 'dart:math' as math;

import 'package:audio_session/audio_session.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/audio/releaf_audio_session.dart';
import '../../../core/audio/relief_shared_audio_handler.dart';
import '../../../routing/app_routes.dart';
import '../../../theme/app_theme.dart';
import '../application/sound_player_controller.dart';
import '../data/sound_catalog.dart';

class SoundPlayerScreen extends ConsumerStatefulWidget {
  const SoundPlayerScreen({super.key, required this.trackId, this.fromSleep = false});

  final String trackId;
  final bool fromSleep;

  @override
  ConsumerState<SoundPlayerScreen> createState() => _SoundPlayerScreenState();
}

class _SoundPlayerScreenState extends ConsumerState<SoundPlayerScreen>
    with WidgetsBindingObserver {
  bool _started = false;
  StreamSubscription<AudioInterruptionEvent>? _interruptionSubscription;
  StreamSubscription<void>? _becomingNoisySubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    unawaited(_configureAudioSession());
  }

  Future<void> _configureAudioSession() async {
    if (ref.read(soundPlayerControllerProvider.notifier)
        is ReliefManagedSoundController) {
      // The application root owns managed events; the driver sets content mode.
      return;
    }
    try {
      final session = await configureReleafAudioSession(ReleafAudioMode.sound);
      if (!mounted) return;
      _interruptionSubscription = session.interruptionEventStream.listen((event) {
        if (!mounted) return;
        ref
            .read(soundPlayerControllerProvider.notifier)
            .handleAudioInterruption(event);
      });
      _becomingNoisySubscription = session.becomingNoisyEventStream.listen((_) {
        if (!mounted) return;
        ref
            .read(soundPlayerControllerProvider.notifier)
            .handleBecomingNoisy();
      });
    } catch (_) {
      // Keep playback available on platforms without native audio-session hooks.
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _interruptionSubscription?.cancel();
    _becomingNoisySubscription?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!mounted || state != AppLifecycleState.resumed) return;
    if (ref.read(soundPlayerControllerProvider.notifier)
        is ReliefManagedSoundController) {
      return;
    }

    unawaited(
      ref.read(soundPlayerControllerProvider.notifier).syncSleepTimerNow(),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;

    final track = ref.read(soundCatalogProvider).getById(widget.trackId);
    if (track == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) context.go(widget.fromSleep ? AppRoutes.sleep : AppRoutes.sound);
      });
      return;
    }

    Future.microtask(() {
      if (!mounted) return;
      ref.read(soundPlayerControllerProvider.notifier).play(track);
    });
  }

  @override
  Widget build(BuildContext context) {
    final track = ref.watch(soundCatalogProvider).getById(widget.trackId);
    if (track == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final state = ref.watch(soundPlayerControllerProvider);
    final controller = ref.read(soundPlayerControllerProvider.notifier);
    final active = state.currentTrackId == track.id;
    final isPlaying = active && state.isPlaying;
    final isLoading = active && state.isLoading;
    final hasPlaybackError = active && state.hasPlaybackError;
    final favorite = state.favoriteIds.contains(track.id);
    final position = active ? state.position : Duration.zero;
    final duration = active ? state.duration : Duration.zero;
    final progress = duration.inMilliseconds <= 0
        ? 0.0
        : (position.inMilliseconds / duration.inMilliseconds).clamp(0.0, 1.0);

    final playbackStatus = isLoading
        ? 'Preparing your sound...'
        : hasPlaybackError
        ? 'Sound could not start. Try again.'
        : isPlaying
        ? (widget.fromSleep ? 'Settling in' : 'Playing')
        : 'Paused';
    final playbackAction = isLoading
        ? 'Cancel loading'
        : hasPlaybackError
        ? 'Retry sound'
        : isPlaying
        ? 'Pause'
        : 'Play';

    return Scaffold(
      backgroundColor: AppTheme.deepGreen,
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF173C35), Color(0xFF071D1A)],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final maxWidth = math.min(constraints.maxWidth, 520.0).toDouble();
              final compact =
                  constraints.maxHeight < 650 || constraints.maxWidth < 350;
              final orbSize = compact ? 170.0 : 242.0;

              return Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxWidth),
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(22, 12, 22, compact ? 22 : 34),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            IconButton(
                              onPressed: () {
                                if (context.canPop()) {
                                  context.pop();
                                } else {
                                  context.go(widget.fromSleep ? AppRoutes.sleep : AppRoutes.sound);
                                }
                              },
                              icon: const Icon(
                                Icons.keyboard_arrow_down_rounded,
                              ),
                              color: Colors.white.withValues(alpha: 0.92),
                              tooltip: 'Close',
                            ),
                            const Spacer(),
                            Text(
                              widget.fromSleep ? 'SLEEP SOUNDS' : 'SOUND SPACE',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.58),
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 2.0,
                              ),
                            ),
                            const Spacer(),
                            IconButton(
                              onPressed: () =>
                                  controller.toggleFavorite(track.id),
                              icon: Icon(
                                favorite
                                    ? Icons.favorite_rounded
                                    : Icons.favorite_border_rounded,
                              ),
                              tooltip: favorite ? 'Unfavorite' : 'Favorite',
                              color: favorite
                                  ? AppTheme.leafGreenLight
                                  : Colors.white.withValues(alpha: 0.92),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        AnimatedOpacity(
                          duration: const Duration(milliseconds: 280),
                          opacity: 1,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 7,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.07),
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.1),
                              ),
                            ),
                            child: Text(
                              playbackStatus,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: hasPlaybackError
                                    ? const Color(0xFFF3CBBE)
                                    : isPlaying
                                    ? AppTheme.leafGreenLight
                                    : Colors.white.withValues(alpha: 0.68),
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.35,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: compact ? 26 : 34),
                        SoundOrb(
                          size: orbSize,
                          isPlaying: isPlaying,
                          seed: track.id.hashCode,
                          sleepMode: widget.fromSleep,
                        ),
                        SizedBox(height: compact ? 26 : 40),
                        Text(
                          track.title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 30,
                            fontWeight: FontWeight.w600,
                            letterSpacing: -1.0,
                            height: 1.08,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          track.subtitle,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.58),
                            fontSize: 14,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          widget.fromSleep
                              ? 'Audio only. Your screen can rest too.'
                              : track.description,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.4),
                            fontSize: 12,
                            height: 1.5,
                          ),
                        ),
                        SizedBox(height: compact ? 22 : 34),
                        SliderTheme(
                          data: SliderThemeData(
                            trackHeight: 2,
                            activeTrackColor: AppTheme.leafGreenLight,
                            inactiveTrackColor: Colors.white.withValues(
                              alpha: 0.12,
                            ),
                            thumbColor: AppTheme.leafGreenLight,
                            thumbShape: const RoundSliderThumbShape(
                              enabledThumbRadius: 4,
                            ),
                            overlayShape: const RoundSliderOverlayShape(
                              overlayRadius: 14,
                            ),
                          ),
                          child: Slider(
                            value: progress,
                            onChanged: duration == Duration.zero
                                ? null
                                : (value) {
                                    controller.seekTo(
                                      Duration(
                                        milliseconds:
                                            (duration.inMilliseconds * value)
                                                .round(),
                                      ),
                                    );
                                  },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 18),
                          child: Row(
                            children: [
                              Text(
                                _formatDuration(position),
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.42),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const Spacer(),
                              Icon(
                                Icons.repeat_rounded,
                                size: 13,
                                color: Colors.white.withValues(alpha: 0.38),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'CONTINUOUS',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.38),
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.0,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: compact ? 18 : 26),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _RoundControl(
                              icon: Icons.replay_10_rounded,
                              tooltip: 'Back 10 seconds',
                              onTap: () => controller.seekRelative(
                                const Duration(seconds: -10),
                              ),
                            ),
                            const SizedBox(width: 28),
                            Semantics(
                              button: true,
                              label: playbackAction,
                              child: Material(
                                color: AppTheme.leafGreenLight,
                                shape: const CircleBorder(),
                                child: InkWell(
                                  customBorder: const CircleBorder(),
                                  onTap: controller.togglePlayPause,
                                  child: SizedBox(
                                    width: 78,
                                    height: 78,
                                    child: isLoading
                                        ? Stack(
                                            alignment: Alignment.center,
                                            children: [
                                              SizedBox(
                                                width: 35,
                                                height: 35,
                                                child:
                                                    CircularProgressIndicator(
                                                      strokeWidth: 2.5,
                                                      color:
                                                          AppTheme.deepGreen,
                                                    ),
                                              ),
                                              const Icon(
                                                Icons.close_rounded,
                                                color: AppTheme.deepGreen,
                                                size: 21,
                                              ),
                                            ],
                                          )
                                        : Icon(
                                            hasPlaybackError
                                                ? Icons.refresh_rounded
                                                : isPlaying
                                                ? Icons.pause_rounded
                                                : Icons.play_arrow_rounded,
                                            color: AppTheme.deepGreen,
                                            size: 38,
                                          ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 28),
                            _RoundControl(
                              icon: Icons.forward_10_rounded,
                              tooltip: 'Forward 10 seconds',
                              onTap: () => controller.seekRelative(
                                const Duration(seconds: 10),
                              ),
                            ),
                          ],
                        ),
                        if (hasPlaybackError) ...[
                          const SizedBox(height: 12),
                          TextButton.icon(
                            onPressed: controller.togglePlayPause,
                            icon: const Icon(Icons.refresh_rounded, size: 16),
                            label: const Text('Retry sound'),
                            style: TextButton.styleFrom(
                              foregroundColor: const Color(0xFFF3CBBE),
                            ),
                          ),
                        ],
                        SizedBox(height: compact ? 16 : 24),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.08),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                state.volume <= 0
                                    ? Icons.volume_off_rounded
                                    : Icons.volume_down_rounded,
                                color: Colors.white.withValues(alpha: 0.6),
                                size: 19,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: SliderTheme(
                                  data: SliderThemeData(
                                    trackHeight: 2,
                                    activeTrackColor: AppTheme.leafGreenLight,
                                    inactiveTrackColor: Colors.white.withValues(
                                      alpha: 0.12,
                                    ),
                                    thumbColor: AppTheme.leafGreenLight,
                                    thumbShape: const RoundSliderThumbShape(
                                      enabledThumbRadius: 4,
                                    ),
                                    overlayShape:
                                        const RoundSliderOverlayShape(
                                          overlayRadius: 14,
                                        ),
                                  ),
                                  child: Slider(
                                    label:
                                        'Volume ${(state.volume * 100).round()}%',
                                    value: state.volume,
                                    onChanged: controller.setVolume,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              ConstrainedBox(
                                constraints: const BoxConstraints(
                                  minWidth: 42,
                                ),
                                child: Text(
                                  '${(state.volume * 100).round()}%',
                                  textAlign: TextAlign.right,
                                  style: TextStyle(
                                    color: Colors.white.withValues(
                                      alpha: 0.6,
                                    ),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: compact ? 18 : 28),
                        Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 12,
                          runSpacing: 10,
                          children: [
                            _PillControl(
                              icon: Icons.bedtime_outlined,
                              label: state.sleepTimerRemainingSeconds == null
                                  ? 'Sleep timer'
                                  : _formatCountdown(
                                      state.sleepTimerRemainingSeconds!,
                                    ),
                              active: state.sleepTimerMinutes != null,
                              onTap: () =>
                                  _showSleepTimerSheet(context, controller),
                            ),
                            _PillControl(
                              icon: Icons.stop_rounded,
                              label: 'Stop',
                              onTap: () async {
                                await controller.stop();
                                if (!context.mounted) return;
                                if (context.canPop()) {
                                  context.pop();
                                } else {
                                  context.go(widget.fromSleep ? AppRoutes.sleep : AppRoutes.sound);
                                }
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'A softer space for your nervous system.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.24),
                            fontSize: 11,
                            height: 1.6,
                            letterSpacing: 0.1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> _showSleepTimerSheet(
    BuildContext context,
    SoundPlayerController controller,
  ) async {
    final selected = await showModalBottomSheet<int>(
      context: context,
      backgroundColor: const Color(0xFFF6F1E5),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 12, 22, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 34,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.deepGreen.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Let the sound fade into rest',
                style: TextStyle(
                  color: AppTheme.deepGreen,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Choose when your sound space should become quiet.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppTheme.deepGreen.withValues(alpha: 0.55),
                  fontSize: 13,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 22),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                alignment: WrapAlignment.center,
                children: [
                  for (final minutes in [15, 30, 45, 60, 90])
                    ActionChip(
                      label: Text('$minutes min'),
                      onPressed: () => Navigator.of(context).pop(minutes),
                    ),
                  ActionChip(
                    label: const Text('No timer'),
                    onPressed: () => Navigator.of(context).pop(0),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (selected == null) return;
    await controller.setSleepTimer(selected == 0 ? null : selected);
  }

  static String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.toString();
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  static String _formatCountdown(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds left';
  }
}

class SoundOrb extends StatefulWidget {
  const SoundOrb({
    super.key,
    required this.size,
    required this.isPlaying,
    required this.seed,
    this.sleepMode = false,
  });

  final double size;
  final bool isPlaying;
  final int seed;
  final bool sleepMode;

  @override
  State<SoundOrb> createState() => _SoundOrbState();
}

class _SoundOrbState extends State<SoundOrb>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animation = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 11),
  )..repeat();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncAnimation();
  }

  @override
  void didUpdateWidget(covariant SoundOrb oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isPlaying != widget.isPlaying) {
      _syncAnimation();
    }
  }

  void _syncAnimation() {
    final reduceMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    if (widget.isPlaying && !reduceMotion) {
      _animation.repeat();
    } else {
      _animation.stop();
    }
  }

  @override
  void dispose() {
    _animation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, _) {
          return CustomPaint(
            painter: _SoundOrbPainter(
              phase: _animation.value,
              active: widget.isPlaying,
              seed: widget.seed,
              sleepMode: widget.sleepMode,
            ),
          );
        },
      ),
    );
  }
}

class _SoundOrbPainter extends CustomPainter {
  const _SoundOrbPainter({
    required this.phase,
    required this.active,
    required this.seed,
    required this.sleepMode,
  });

  final double phase;
  final bool active;
  final int seed;
  final bool sleepMode;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.34;
    final time = phase * math.pi * 2;
    final seedShift = (seed.abs() % 100) / 100;
    final breathing = active ? math.sin(time) * 0.018 : 0.0;
    final outer = radius * (1.12 + breathing);

    canvas.drawCircle(
      center,
      outer * 1.24,
      Paint()
        ..shader = RadialGradient(
          colors: [
            const Color(0xFFB7CCA4).withValues(alpha: 0.13),
            const Color(0xFFB7CCA4).withValues(alpha: 0),
          ],
        ).createShader(
          Rect.fromCircle(center: center, radius: outer * 1.24),
        ),
    );

    for (var ring = 0; ring < 4; ring++) {
      final path = Path();
      final baseRadius = radius * (0.76 + ring * 0.125);
      for (var degree = 0; degree <= 360; degree += 3) {
        final angle = degree * math.pi / 180;
        final wave =
            math.sin(angle * (3 + ring) + time + seedShift * 5) * 0.018 +
            math.cos(angle * 5 - time * 0.8 + ring) * 0.012;
        final currentRadius =
            baseRadius * (1 + wave + breathing * (ring + 1));
        final point = center +
            Offset(
              math.cos(angle) * currentRadius,
              math.sin(angle) * currentRadius,
            );
        if (degree == 0) {
          path.moveTo(point.dx, point.dy);
        } else {
          path.lineTo(point.dx, point.dy);
        }
      }
      path.close();
      canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = ring == 0 ? 1.2 : 0.75
          ..color = Color.lerp(
            const Color(0xFFF4F1D7),
            const Color(0xFFAACB97),
            ring / 4,
          )!.withValues(alpha: 0.55 - ring * 0.09),
      );
    }

    for (var line = 0; line < 9; line++) {
      final lineY = center.dy - radius * 0.43 + line * radius * 0.107;
      final distance = (lineY - center.dy).abs() / radius;
      final halfWidth = math.sqrt(1 - distance * distance) * radius * 0.6;
      final path = Path();
      for (var step = 0; step <= 40; step++) {
        final fraction = step / 40;
        final x = center.dx - halfWidth + fraction * halfWidth * 2;
        final amp = (active ? 4.0 : 2.0) *
            math.sin(fraction * math.pi) *
            (1 - distance * 0.35);
        final y = lineY +
            math.sin(fraction * math.pi * 3 + time + line * 0.7) * amp;
        if (step == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      canvas.drawPath(
        path,
        Paint()
          ..color = Colors.white.withValues(alpha: 0.2)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.7,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _SoundOrbPainter oldDelegate) {
    return oldDelegate.phase != phase ||
        oldDelegate.active != active ||
        oldDelegate.seed != seed ||
        oldDelegate.sleepMode != sleepMode;
  }
}

class _RoundControl extends StatelessWidget {
  const _RoundControl({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: tooltip,
      onPressed: onTap,
      icon: Icon(icon, size: 31),
      color: Colors.white.withValues(alpha: 0.75),
    );
  }
}

class _PillControl extends StatelessWidget {
  const _PillControl({
    required this.icon,
    required this.label,
    required this.onTap,
    this.active = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: active
          ? AppTheme.leafGreenLight.withValues(alpha: 0.13)
          : Colors.white.withValues(alpha: 0.06),
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 17,
                color: active
                    ? AppTheme.leafGreenLight
                    : Colors.white.withValues(alpha: 0.55),
              ),
              const SizedBox(width: 7),
              Text(
                label,
                style: TextStyle(
                  color: active
                      ? AppTheme.leafGreenLight
                      : Colors.white.withValues(alpha: 0.62),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
