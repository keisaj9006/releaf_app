import 'dart:async';

import 'package:audio_session/audio_session.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/audio/releaf_audio_session.dart';
import '../../../core/providers.dart';
import '../../../routing/app_routes.dart';
import '../../../theme/app_theme.dart';
import '../../../theme/releaf_design_tokens.dart';
import '../../../theme/widgets/releaf_components.dart';
import '../../../theme/widgets/releaf_sleep_artwork.dart';
import '../../relief/application/relief_paywall_hooks.dart';
import '../../sound/application/sound_player_controller.dart';
import '../../stories/data/story_catalog.dart';
import '../../stories/domain/relief_story.dart';
import '../application/sleep_progress_store.dart';

bool canAccessSleepStory(ReliefStory story, {required bool isPremiumUser}) =>
    story.isPremium != true || isPremiumUser;

class SleepStoryPlayerGate extends ConsumerWidget {
  const SleepStoryPlayerGate({super.key, required this.storyId});

  final String storyId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final story = ref.watch(storyByIdProvider(storyId));
    if (story == null) {
      return const _StoryUnavailableScreen();
    }
    if (story.isPremium != true) {
      return SleepStoryPlayerScreen(storyId: storyId);
    }

    final subscription = ref.watch(subscriptionControllerProvider);
    if (subscription.isLoading && !subscription.isPremium) {
      return const _StoryLoadingScreen();
    }
    if (canAccessSleepStory(story, isPremiumUser: subscription.isPremium)) {
      return SleepStoryPlayerScreen(storyId: storyId);
    }
    return _PremiumStoryPreview(story: story);
  }
}

class SleepStoryPlayerScreen extends ConsumerStatefulWidget {
  const SleepStoryPlayerScreen({super.key, required this.storyId});

  final String storyId;

  @override
  ConsumerState<SleepStoryPlayerScreen> createState() =>
      _SleepStoryPlayerScreenState();
}

class _SleepStoryPlayerScreenState extends ConsumerState<SleepStoryPlayerScreen>
    with WidgetsBindingObserver {
  ProviderSubscription<SoundPlayerState>? _playerSubscription;
  StreamSubscription<AudioInterruptionEvent>? _interruptionSubscription;
  StreamSubscription<void>? _becomingNoisySubscription;
  SoundPlayerController? _playerController;
  SleepProgressStore? _progressStore;
  ReliefStory? _story;
  SoundPlayerState? _latestPlayerState;
  Duration _lastPersistedPosition = Duration.zero;
  bool _started = false;
  bool _completionPersisted = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _playerSubscription = ref.listenManual<SoundPlayerState>(
      soundPlayerControllerProvider,
      _onPlayerState,
    );
    unawaited(_configureAudioSession());
  }

  Future<void> _configureAudioSession() async {
    try {
      final session = await configureReleafAudioSession(ReleafAudioMode.sound);
      if (!mounted) return;
      await _interruptionSubscription?.cancel();
      await _becomingNoisySubscription?.cancel();
      _interruptionSubscription = session.interruptionEventStream.listen((
        event,
      ) {
        unawaited(
          ref
              .read(soundPlayerControllerProvider.notifier)
              .handleAudioInterruption(event),
        );
      });
      _becomingNoisySubscription = session.becomingNoisyEventStream.listen((_) {
        unawaited(
          ref
              .read(soundPlayerControllerProvider.notifier)
              .handleBecomingNoisy(),
        );
      });
    } catch (_) {
      // Playback itself will expose a recoverable error if native audio setup
      // is unavailable. The screen must remain usable in preview/tests.
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    _playerController = ref.read(soundPlayerControllerProvider.notifier);
    _latestPlayerState = ref.read(soundPlayerControllerProvider);
    _progressStore = ref.read(sleepProgressStoreProvider.notifier);
    _story = ref.read(storyByIdProvider(widget.storyId));
    Future<void>.microtask(_startPlayback);
  }

  Future<void> _startPlayback() async {
    if (!mounted) return;
    final story = _story;
    final assetPath = story?.audioAssetPath?.trim();
    if (story == null || assetPath == null || assetPath.isEmpty) return;

    final progress = _progressStore?.recordFor(story.id);
    final controller = _playerController;
    if (controller == null) return;
    await controller.playAsset(
      id: story.id,
      title: story.title,
      assetPath: assetPath,
      mode: ReleafPlaybackMode.finite,
    );
    if (!mounted) return;

    final player = ref.read(soundPlayerControllerProvider);
    if (player.currentTrackId != story.id || player.hasPlaybackError) return;
    final resumePosition = progress?.isCompleted == true
        ? Duration.zero
        : progress?.position ?? Duration.zero;
    if (resumePosition > Duration.zero) {
      await controller.seekTo(resumePosition);
      _lastPersistedPosition = resumePosition;
    }
  }

  void _onPlayerState(SoundPlayerState? previous, SoundPlayerState next) {
    _latestPlayerState = next;
    if (next.currentTrackId != widget.storyId) return;
    if (next.isCompleted && !_completionPersisted) {
      _completionPersisted = true;
      unawaited(
        _progressStore?.markCompleted(
          contentId: widget.storyId,
          duration: next.duration > Duration.zero ? next.duration : null,
          chapterId: _chapterIdAt(next.position),
        ),
      );
      return;
    }
    if (next.isPlaying) _completionPersisted = false;

    final moved = (next.position - _lastPersistedPosition).abs();
    final paused = previous?.isPlaying == true && !next.isPlaying;
    if (next.position > Duration.zero &&
        (moved >= const Duration(seconds: 5) || paused)) {
      _lastPersistedPosition = next.position;
      unawaited(_persistProgress(next));
    }
  }

  String? _chapterIdAt(Duration position) {
    return _story?.chapterAt(position)?.id;
  }

  Future<void> _persistProgress([SoundPlayerState? supplied]) async {
    final player = supplied ?? _latestPlayerState;
    if (player == null) return;
    if (player.currentTrackId != widget.storyId ||
        player.position <= Duration.zero ||
        player.isCompleted) {
      return;
    }
    await _progressStore?.updatePosition(
      contentId: widget.storyId,
      position: player.position,
      duration: player.duration > Duration.zero ? player.duration : null,
      chapterId: _chapterIdAt(player.position),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(
        ref.read(soundPlayerControllerProvider.notifier).syncSleepTimerNow(),
      );
      return;
    }
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached ||
        state == AppLifecycleState.hidden) {
      unawaited(_persistProgress());
    }
  }

  @override
  void dispose() {
    unawaited(_persistProgress());
    _playerSubscription?.close();
    _interruptionSubscription?.cancel();
    _becomingNoisySubscription?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final story = ref.watch(storyByIdProvider(widget.storyId));
    ref.watch(sleepProgressStoreProvider);
    if (story == null) return const _StoryUnavailableScreen();

    final player = ref.watch(soundPlayerControllerProvider);
    final isCurrent = player.currentTrackId == story.id;
    final position = isCurrent ? player.position : Duration.zero;
    final duration = isCurrent && player.duration > Duration.zero
        ? player.duration
        : story.estimatedDuration ?? Duration.zero;
    final currentChapter = story.chapterAt(position);

    return Theme(
      data: AppTheme.premiumDark(),
      child: Scaffold(
        backgroundColor: ReleafColors.background,
        body: Stack(
          children: [
            const Positioned.fill(child: _StoryBackdrop()),
            SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final compact = constraints.maxWidth < 360;
                  return SingleChildScrollView(
                    key: const Key('story-player-scroll'),
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.fromLTRB(
                      ReleafSpacing.screen,
                      compact ? ReleafSpacing.sm : ReleafSpacing.lg,
                      ReleafSpacing.screen,
                      ReleafSpacing.xl,
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 720),
                        child: Column(
                          children: [
                            _StoryHeader(onClose: () => _close(context)),
                            SizedBox(
                              height: compact
                                  ? ReleafSpacing.md
                                  : ReleafSpacing.xl,
                            ),
                            _StoryArtwork(story: story),
                            const SizedBox(height: ReleafSpacing.lg),
                            Text(
                              story.series.toUpperCase(),
                              style: ReleafTypography.eyebrow.copyWith(
                                color: ReleafFeatureAccents.sound,
                              ),
                            ),
                            const SizedBox(height: ReleafSpacing.xs),
                            Text(
                              story.title,
                              textAlign: TextAlign.center,
                              style: ReleafTypography.display.copyWith(
                                fontSize: compact ? 25 : 30,
                              ),
                            ),
                            const SizedBox(height: ReleafSpacing.xs),
                            if (story.narrator != null)
                              Text(
                                story.narrator!,
                                style: ReleafTypography.body.copyWith(
                                  color: ReleafColors.textSecondary,
                                ),
                              ),
                            const SizedBox(height: ReleafSpacing.lg),
                            if (!story.isAudioAvailable)
                              _AudioPending(story: story)
                            else ...[
                              _PlaybackStatus(
                                player: player,
                                isCurrent: isCurrent,
                              ),
                              const SizedBox(height: ReleafSpacing.md),
                              _Timeline(
                                position: position,
                                duration: duration,
                                onSeek: (value) => ref
                                    .read(
                                      soundPlayerControllerProvider.notifier,
                                    )
                                    .seekTo(value),
                              ),
                              const SizedBox(height: ReleafSpacing.sm),
                              _TransportControls(
                                player: player,
                                isCurrent: isCurrent,
                                onBack: () => ref
                                    .read(
                                      soundPlayerControllerProvider.notifier,
                                    )
                                    .seekRelative(const Duration(seconds: -10)),
                                onForward: () => ref
                                    .read(
                                      soundPlayerControllerProvider.notifier,
                                    )
                                    .seekRelative(const Duration(seconds: 10)),
                                onPlayPause: _togglePlayPause,
                                onRetry: _startPlayback,
                              ),
                              if (currentChapter != null) ...[
                                const SizedBox(height: ReleafSpacing.lg),
                                _ChapterStatus(
                                  story: story,
                                  current: currentChapter,
                                  onSelected: (chapter) => ref
                                      .read(
                                        soundPlayerControllerProvider.notifier,
                                      )
                                      .seekTo(chapter.start),
                                ),
                              ],
                              const SizedBox(height: ReleafSpacing.lg),
                              _StoryTimer(
                                selectedMinutes: player.sleepTimerMinutes,
                                remainingSeconds:
                                    player.sleepTimerRemainingSeconds,
                                onSelected: ref
                                    .read(
                                      soundPlayerControllerProvider.notifier,
                                    )
                                    .setSleepTimer,
                              ),
                            ],
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

  Future<void> _togglePlayPause() async {
    final controller = ref.read(soundPlayerControllerProvider.notifier);
    final state = ref.read(soundPlayerControllerProvider);
    if (state.isPlaying) {
      await controller.pause();
      await _persistProgress();
    } else {
      await controller.togglePlayPause();
    }
  }

  void _close(BuildContext context) {
    unawaited(_persistProgress());
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.sleep);
    }
  }
}

class _StoryHeader extends StatelessWidget {
  const _StoryHeader({required this.onClose});
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ReleafRoundIconButton(
          icon: Icons.keyboard_arrow_down_rounded,
          tooltip: 'Close Story player',
          accentColor: ReleafFeatureAccents.sound,
          onPressed: onClose,
        ),
        Expanded(
          child: Text(
            'SLEEP STORY',
            maxLines: 1,
            overflow: TextOverflow.fade,
            softWrap: false,
            textAlign: TextAlign.center,
            style: ReleafTypography.eyebrow.copyWith(
              color: ReleafFeatureAccents.sound,
              letterSpacing: 1.8,
            ),
          ),
        ),
        const SizedBox(width: 48),
      ],
    );
  }
}

class _StoryBackdrop extends StatelessWidget {
  const _StoryBackdrop();

  @override
  Widget build(BuildContext context) {
    return const Stack(
      fit: StackFit.expand,
      children: [
        ReleafSleepArtwork(
          variant: ReleafSleepArtworkVariant.night,
          intensity: 0.72,
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xA8060A12), Color(0xE9080C13), Color(0xFF071013)],
              stops: [0, 0.55, 1],
            ),
          ),
        ),
      ],
    );
  }
}

class _StoryArtwork extends StatelessWidget {
  const _StoryArtwork({required this.story});
  final ReliefStory story;

  @override
  Widget build(BuildContext context) {
    final artwork = story.artworkAssetPath?.trim();
    final fallback = const ReleafSleepArtwork(
      variant: ReleafSleepArtworkVariant.night,
      intensity: 1,
    );
    return Semantics(
      image: true,
      label: '${story.title} artwork',
      child: Container(
        key: const Key('story-artwork'),
        width: double.infinity,
        constraints: const BoxConstraints(maxWidth: 520),
        height: 230,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(ReleafRadii.extraLarge),
          border: Border.all(color: ReleafColors.borderSoft),
          boxShadow: const [
            BoxShadow(
              color: Color(0x52000000),
              blurRadius: 38,
              offset: Offset(0, 18),
            ),
          ],
        ),
        child: artwork == null || artwork.isEmpty
            ? fallback
            : Image.asset(
                artwork,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => fallback,
              ),
      ),
    );
  }
}

class _AudioPending extends StatelessWidget {
  const _AudioPending({required this.story});
  final ReliefStory story;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('story-audio-pending'),
      padding: const EdgeInsets.all(ReleafSpacing.lg),
      decoration: BoxDecoration(
        color: ReleafColors.surfaceSoft.withValues(alpha: 0.78),
        borderRadius: BorderRadius.circular(ReleafRadii.large),
        border: Border.all(color: ReleafColors.borderSoft),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.graphic_eq_rounded,
            color: ReleafFeatureAccents.sound,
          ),
          const SizedBox(height: ReleafSpacing.sm),
          Text('Audio in production', style: ReleafTypography.cardTitle),
          const SizedBox(height: ReleafSpacing.xs),
          Text(
            'This Story is registered in ${story.series}, but its final mastered audio is not available yet.',
            textAlign: TextAlign.center,
            style: ReleafTypography.body.copyWith(
              color: ReleafColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _PlaybackStatus extends StatelessWidget {
  const _PlaybackStatus({required this.player, required this.isCurrent});
  final SoundPlayerState player;
  final bool isCurrent;

  @override
  Widget build(BuildContext context) {
    final label = !isCurrent
        ? 'READY'
        : player.isLoading
        ? 'LOADING'
        : player.hasPlaybackError
        ? 'PLAYBACK PROBLEM'
        : player.isCompleted
        ? 'COMPLETED'
        : player.isPlaying
        ? 'PLAYING'
        : 'PAUSED';
    return Semantics(
      liveRegion: true,
      child: Text(
        label,
        key: const Key('story-player-state'),
        style: ReleafTypography.eyebrow.copyWith(
          color: ReleafFeatureAccents.sound,
        ),
      ),
    );
  }
}

class _Timeline extends StatelessWidget {
  const _Timeline({
    required this.position,
    required this.duration,
    required this.onSeek,
  });
  final Duration position;
  final Duration duration;
  final ValueChanged<Duration> onSeek;

  @override
  Widget build(BuildContext context) {
    final maxMs = duration.inMilliseconds;
    final value = maxMs <= 0
        ? 0.0
        : position.inMilliseconds.clamp(0, maxMs).toDouble();
    return Column(
      children: [
        Slider(
          key: const Key('story-scrubber'),
          value: value,
          max: maxMs <= 0 ? 1 : maxMs.toDouble(),
          onChanged: maxMs <= 0
              ? null
              : (value) => onSeek(Duration(milliseconds: value.round())),
        ),
        Row(
          children: [
            Expanded(
              child: Text(
                _formatDuration(position),
                key: const Key('story-elapsed'),
                maxLines: 1,
              ),
            ),
            Expanded(
              child: Text(
                maxMs <= 0
                    ? '--:--'
                    : '-${_formatDuration(duration - position)}',
                key: const Key('story-remaining'),
                maxLines: 1,
                textAlign: TextAlign.end,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _TransportControls extends StatelessWidget {
  const _TransportControls({
    required this.player,
    required this.isCurrent,
    required this.onBack,
    required this.onForward,
    required this.onPlayPause,
    required this.onRetry,
  });
  final SoundPlayerState player;
  final bool isCurrent;
  final VoidCallback onBack;
  final VoidCallback onForward;
  final VoidCallback onPlayPause;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    if (isCurrent && player.hasPlaybackError) {
      return Column(
        key: const Key('story-playback-error'),
        children: [
          Text(
            'There was a playback problem. Try again.',
            textAlign: TextAlign.center,
            style: ReleafTypography.body,
          ),
          const SizedBox(height: ReleafSpacing.sm),
          FilledButton.icon(
            key: const Key('story-retry'),
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Try again'),
          ),
        ],
      );
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          key: const Key('story-seek-back'),
          tooltip: 'Back 10 seconds',
          onPressed: onBack,
          icon: const Icon(Icons.replay_10_rounded),
          iconSize: 34,
        ),
        const SizedBox(width: ReleafSpacing.lg),
        FilledButton(
          key: const Key('story-play-pause'),
          onPressed: player.isLoading ? null : onPlayPause,
          style: FilledButton.styleFrom(
            shape: const CircleBorder(),
            padding: const EdgeInsets.all(22),
          ),
          child: player.isLoading
              ? const SizedBox.square(
                  dimension: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Icon(
                  isCurrent && player.isPlaying
                      ? Icons.pause_rounded
                      : Icons.play_arrow_rounded,
                  size: 34,
                ),
        ),
        const SizedBox(width: ReleafSpacing.lg),
        IconButton(
          key: const Key('story-seek-forward'),
          tooltip: 'Forward 10 seconds',
          onPressed: onForward,
          icon: const Icon(Icons.forward_10_rounded),
          iconSize: 34,
        ),
      ],
    );
  }
}

class _ChapterStatus extends StatelessWidget {
  const _ChapterStatus({
    required this.story,
    required this.current,
    required this.onSelected,
  });
  final ReliefStory story;
  final ReliefStoryChapter current;
  final ValueChanged<ReliefStoryChapter> onSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('story-current-chapter'),
      padding: const EdgeInsets.symmetric(
        horizontal: ReleafSpacing.md,
        vertical: ReleafSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: ReleafColors.surfaceSoft.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(ReleafRadii.medium),
      ),
      child: Row(
        children: [
          const Icon(Icons.menu_book_rounded, size: 20),
          const SizedBox(width: ReleafSpacing.sm),
          Expanded(child: Text(current.title, style: ReleafTypography.body)),
          if (story.chapters.length > 1)
            PopupMenuButton<ReliefStoryChapter>(
              tooltip: 'Choose chapter',
              onSelected: onSelected,
              itemBuilder: (_) => story.chapters
                  .map(
                    (chapter) => PopupMenuItem(
                      value: chapter,
                      child: Text(chapter.title),
                    ),
                  )
                  .toList(growable: false),
            ),
        ],
      ),
    );
  }
}

class _StoryTimer extends StatelessWidget {
  const _StoryTimer({
    required this.selectedMinutes,
    required this.remainingSeconds,
    required this.onSelected,
  });
  final int? selectedMinutes;
  final int? remainingSeconds;
  final ValueChanged<int?> onSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Sleep timer', style: ReleafTypography.cardTitle),
        if (remainingSeconds != null)
          Text(
            '${(remainingSeconds! / 60).ceil()} min remaining',
            style: ReleafTypography.meta,
          ),
        const SizedBox(height: ReleafSpacing.sm),
        Wrap(
          spacing: ReleafSpacing.xs,
          runSpacing: ReleafSpacing.xs,
          children: <int?>[null, 15, 30, 45, 60]
              .map(
                (minutes) => ChoiceChip(
                  label: Text(minutes == null ? 'Off' : '$minutes min'),
                  selected: selectedMinutes == minutes,
                  onSelected: (_) => onSelected(minutes),
                ),
              )
              .toList(growable: false),
        ),
      ],
    );
  }
}

class _PremiumStoryPreview extends ConsumerWidget {
  const _PremiumStoryPreview({required this.story});
  final ReliefStory story;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Theme(
      data: AppTheme.premiumDark(),
      child: Scaffold(
        backgroundColor: ReleafColors.background,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(ReleafSpacing.screen),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 620),
                child: Column(
                  children: [
                    _StoryHeader(onClose: () => _returnToSleep(context)),
                    const SizedBox(height: ReleafSpacing.xl),
                    _StoryArtwork(story: story),
                    const SizedBox(height: ReleafSpacing.lg),
                    Text('PREMIUM STORY', style: ReleafTypography.eyebrow),
                    const SizedBox(height: ReleafSpacing.xs),
                    Text(
                      story.title,
                      textAlign: TextAlign.center,
                      style: ReleafTypography.display,
                    ),
                    if (story.narrator != null) ...[
                      const SizedBox(height: ReleafSpacing.xs),
                      Text('Narrated by ${story.narrator}'),
                    ],
                    const SizedBox(height: ReleafSpacing.md),
                    Text(
                      story.description,
                      textAlign: TextAlign.center,
                      style: ReleafTypography.body,
                    ),
                    const SizedBox(height: ReleafSpacing.lg),
                    FilledButton.icon(
                      key: const Key('story-unlock-premium'),
                      onPressed: () =>
                          maybeShowPaywall(context, ref, force: true),
                      icon: const Icon(Icons.lock_open_rounded),
                      label: const Text('Unlock Premium'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StoryLoadingScreen extends StatelessWidget {
  const _StoryLoadingScreen();
  @override
  Widget build(BuildContext context) => const Scaffold(
    backgroundColor: ReleafColors.background,
    body: Center(child: CircularProgressIndicator()),
  );
}

class _StoryUnavailableScreen extends StatelessWidget {
  const _StoryUnavailableScreen();
  @override
  Widget build(BuildContext context) => Theme(
    data: AppTheme.premiumDark(),
    child: Scaffold(
      backgroundColor: ReleafColors.background,
      appBar: AppBar(title: const Text('Story unavailable')),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(ReleafSpacing.screen),
          child: Text('This Story is not available in the current catalogue.'),
        ),
      ),
    ),
  );
}

void _returnToSleep(BuildContext context) {
  if (context.canPop()) {
    context.pop();
  } else {
    context.go(AppRoutes.sleep);
  }
}

String _formatDuration(Duration value) {
  final safeSeconds = value.inSeconds.clamp(0, 359999);
  final hours = safeSeconds ~/ 3600;
  final minutes = (safeSeconds % 3600) ~/ 60;
  final seconds = safeSeconds % 60;
  if (hours > 0) {
    return '$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
  return '$minutes:${seconds.toString().padLeft(2, '0')}';
}
