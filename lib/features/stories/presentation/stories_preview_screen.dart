import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../routing/app_routes.dart';
import '../../../theme/app_theme.dart';
import '../../../theme/releaf_design_tokens.dart';
import '../../../theme/widgets/releaf_sleep_artwork.dart';
import '../../../theme/widgets/relief_editorial_image.dart';
import '../../sleep/application/sleep_progress_store.dart';
import '../data/story_catalog.dart';
import '../domain/relief_story.dart';

class StoriesPreviewScreen extends ConsumerWidget {
  const StoriesPreviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stories = StoryCatalog.ownerPreview;
    final progressRecords = ref.watch(sleepProgressStoreProvider);
    final continueListening = _latestStoryProgress(stories, progressRecords);

    return Theme(
      data: AppTheme.premiumDark(),
      child: Scaffold(
        backgroundColor: ReleafColors.background,
        body: Stack(
          children: [
            const Positioned.fill(child: _StoriesBackdrop()),
            SafeArea(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 760),
                  child: CustomScrollView(
                    key: const Key('stories-screen-scroll'),
                    physics: const BouncingScrollPhysics(),
                    slivers: [
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(
                          ReleafSpacing.screen,
                          ReleafSpacing.sm,
                          ReleafSpacing.screen,
                          48,
                        ),
                        sliver: SliverList.list(
                          children: [
                            Row(
                              children: [
                                IconButton.filledTonal(
                                  key: const Key('stories-preview-back'),
                                  tooltip: 'Back to Sleep',
                                  onPressed: () {
                                    if (context.canPop()) {
                                      context.pop();
                                    } else {
                                      context.go(AppRoutes.sleep);
                                    }
                                  },
                                  icon: const Icon(Icons.arrow_back_rounded),
                                ),
                                const Spacer(),
                                _StoryCount(count: stories.length),
                              ],
                            ),
                            const SizedBox(height: ReleafSpacing.lg),
                            Text(
                              'STORIES FOR THE NIGHT',
                              style: ReleafTypography.eyebrow.copyWith(
                                color: ReleafFeatureAccents.sleep,
                                letterSpacing: 1.8,
                              ),
                            ),
                            const SizedBox(height: ReleafSpacing.xs),
                            Text('Stories', style: ReleafTypography.display),
                            const SizedBox(height: ReleafSpacing.xs),
                            Text(
                              'Settle in with one thoughtful, long-form story.',
                              style: ReleafTypography.body.copyWith(
                                color: ReleafColors.textSecondary,
                                height: 1.45,
                              ),
                            ),
                            if (continueListening != null) ...[
                              const SizedBox(height: ReleafSpacing.lg),
                              _ContinueListeningCard(
                                story: continueListening.story,
                                progress: continueListening.progress,
                              ),
                            ],
                            const SizedBox(height: ReleafSpacing.xl),
                            for (final story in stories) ...[
                              _StoryCard(story: story),
                              if (story != stories.last)
                                const SizedBox(height: ReleafSpacing.lg),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

({ReliefStory story, SleepProgressRecord progress})? _latestStoryProgress(
  List<ReliefStory> stories,
  List<SleepProgressRecord> records,
) {
  final storiesById = <String, ReliefStory>{
    for (final story in stories) story.id: story,
  };
  final candidates = records
      .where(
        (record) =>
            storiesById.containsKey(record.contentId) &&
            !record.isCompleted &&
            record.position > Duration.zero,
      )
      .toList(growable: false)
    ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

  if (candidates.isEmpty) return null;
  final progress = candidates.first;
  return (story: storiesById[progress.contentId]!, progress: progress);
}

class _StoriesBackdrop extends StatelessWidget {
  const _StoriesBackdrop();

  @override
  Widget build(BuildContext context) {
    return const Stack(
      fit: StackFit.expand,
      children: [
        ReleafSleepArtwork(
          variant: ReleafSleepArtworkVariant.night,
          intensity: 0.52,
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xB8070A11), Color(0xEE080A0F), Color(0xFF071013)],
              stops: [0, 0.46, 1],
            ),
          ),
        ),
      ],
    );
  }
}

class _StoryCount extends StatelessWidget {
  const _StoryCount({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xB7121A21),
        borderRadius: BorderRadius.circular(ReleafRadii.pill),
        border: Border.all(
          color: ReleafFeatureAccents.sleep.withValues(alpha: 0.24),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.auto_stories_rounded, size: 17),
          const SizedBox(width: 7),
          Text(
            '$count stories',
            style: ReleafTypography.meta.copyWith(
              color: ReleafColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _ContinueListeningCard extends StatelessWidget {
  const _ContinueListeningCard({
    required this.story,
    required this.progress,
  });

  final ReliefStory story;
  final SleepProgressRecord progress;

  @override
  Widget build(BuildContext context) {
    final duration = progress.duration ?? story.estimatedDuration;
    final progressValue = duration == null || duration <= Duration.zero
        ? null
        : (progress.position.inMilliseconds / duration.inMilliseconds)
              .clamp(0.0, 1.0)
              .toDouble();
    final listenedMinutes = progress.position.inMinutes;
    final listenedLabel = listenedMinutes <= 0
        ? 'Started'
        : '$listenedMinutes min listened';

    return KeyedSubtree(
      key: const Key('stories-continue-listening'),
      child: Semantics(
        button: true,
        label: 'Continue listening to ${story.title}. $listenedLabel.',
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            key: Key('stories-continue-${story.id}'),
            onTap: () => context.push(
              AppRoutes.sleepStoryPlayerFor(story.id),
            ),
            borderRadius: BorderRadius.circular(ReleafRadii.large),
            child: Ink(
              padding: const EdgeInsets.all(ReleafSpacing.md),
              decoration: BoxDecoration(
                color: const Color(0xE0131C21),
                borderRadius: BorderRadius.circular(ReleafRadii.large),
                border: Border.all(
                  color: ReleafFeatureAccents.sleep.withValues(alpha: 0.38),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.20),
                    blurRadius: 24,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: ReleafFeatureAccents.sleep.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(ReleafRadii.medium),
                    ),
                    child: Icon(
                      _storyIcon(story.id),
                      color: ReleafColors.textPrimary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: ReleafSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'CONTINUE LISTENING',
                          style: ReleafTypography.eyebrow.copyWith(
                            color: ReleafFeatureAccents.sleep,
                            letterSpacing: 1.35,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          story.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: ReleafTypography.cardTitle.copyWith(
                            fontSize: 17,
                            height: 1.18,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          listenedLabel,
                          style: ReleafTypography.meta.copyWith(
                            color: ReleafColors.textSecondary,
                          ),
                        ),
                        if (progressValue != null) ...[
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(
                              ReleafRadii.pill,
                            ),
                            child: LinearProgressIndicator(
                              value: progressValue,
                              minHeight: 4,
                              backgroundColor: Colors.white.withValues(
                                alpha: 0.08,
                              ),
                              color: ReleafFeatureAccents.sleep,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: ReleafSpacing.sm),
                  const Icon(Icons.play_arrow_rounded, size: 30),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StoryCard extends StatelessWidget {
  const _StoryCard({required this.story});

  final ReliefStory story;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label: '${story.title}. ${story.subtitle}',
      child: Container(
        key: Key('story-preview-${story.id}'),
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: const Color(0xF20E1718),
          borderRadius: BorderRadius.circular(ReleafRadii.extraLarge),
          border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.26),
              blurRadius: 28,
              offset: const Offset(0, 16),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _StoryArtwork(story: story),
            Padding(
              padding: const EdgeInsets.all(ReleafSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    story.series.toUpperCase(),
                    style: ReleafTypography.eyebrow.copyWith(
                      color: ReleafFeatureAccents.sleep,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: ReleafSpacing.xs),
                  Text(
                    story.title,
                    style: ReleafTypography.cardTitle.copyWith(
                      fontSize: 22,
                      height: 1.14,
                    ),
                  ),
                  const SizedBox(height: ReleafSpacing.sm),
                  Text(
                    story.description,
                    style: ReleafTypography.body.copyWith(
                      color: ReleafColors.textSecondary,
                      height: 1.48,
                    ),
                  ),
                  const SizedBox(height: ReleafSpacing.md),
                  if (story.isAudioAvailable)
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        key: Key('story-preview-play-${story.id}'),
                        onPressed: () => context.push(
                          AppRoutes.sleepStoryPlayerFor(story.id),
                        ),
                        icon: const Icon(Icons.play_arrow_rounded),
                        label: const Text('Play story'),
                      ),
                    )
                  else
                    _MissingAudioNotice(storyId: story.id),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StoryArtwork extends StatelessWidget {
  const _StoryArtwork({required this.story});

  final ReliefStory story;

  @override
  Widget build(BuildContext context) {
    final duration = story.estimatedDuration;

    return AspectRatio(
      aspectRatio: 16 / 8.5,
      child: Stack(
        fit: StackFit.expand,
        children: [
          const ReliefEditorialImage(
            asset: ReliefEditorialAsset.sleepStories,
            fallback: ReleafSleepArtwork(
              variant: ReleafSleepArtworkVariant.night,
            ),
            intensity: 0.94,
          ),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0x05000000), Color(0x25000000), Color(0xC9091014)],
                stops: [0, 0.55, 1],
              ),
            ),
          ),
          Positioned(
            top: ReleafSpacing.md,
            left: ReleafSpacing.md,
            child: _ArtworkBadge(
              icon: _storyIcon(story.id),
              label: duration == null
                  ? 'Story'
                  : '${duration.inMinutes} min',
            ),
          ),
          Positioned(
            right: ReleafSpacing.md,
            bottom: ReleafSpacing.md,
            child: Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: const Color(0xC70B1116),
                borderRadius: BorderRadius.circular(ReleafRadii.pill),
                border: Border.all(color: Colors.white24),
              ),
              child: Icon(
                _storyIcon(story.id),
                color: ReleafColors.textPrimary,
                size: 22,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

IconData _storyIcon(String id) => switch (id) {
  'TS01_BEYOND_THE_GATE' => Icons.directions_run_rounded,
  'TS02_KRYSTYNA_SKARBEK' => Icons.explore_rounded,
  'ST_L05_COMPUTER' => Icons.memory_rounded,
  _ => Icons.auto_stories_rounded,
};

class _ArtworkBadge extends StatelessWidget {
  const _ArtworkBadge({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xC70B1116),
        borderRadius: BorderRadius.circular(ReleafRadii.pill),
        border: Border.all(color: Colors.white24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16),
          const SizedBox(width: 6),
          Text(
            label,
            style: ReleafTypography.meta.copyWith(
              color: ReleafColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _MissingAudioNotice extends StatelessWidget {
  const _MissingAudioNotice({required this.storyId});

  final String storyId;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: Key('story-preview-audio-missing-$storyId'),
      width: double.infinity,
      padding: const EdgeInsets.all(ReleafSpacing.md),
      decoration: BoxDecoration(
        color: ReleafColors.premium.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(ReleafRadii.medium),
        border: Border.all(
          color: ReleafColors.premium.withValues(alpha: 0.24),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.headphones_off_rounded, size: 21),
          const SizedBox(width: ReleafSpacing.sm),
          Expanded(
            child: Text(
              'Audio is not included in this test build.',
              style: ReleafTypography.meta.copyWith(
                color: ReleafColors.textSecondary,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
