import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../routing/app_routes.dart';

import '../../../theme/app_theme.dart';
import '../../../theme/releaf_design_tokens.dart';
import '../data/story_catalog.dart';
import '../domain/relief_story.dart';

class StoriesPreviewScreen extends StatelessWidget {
  const StoriesPreviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme.premiumDark(),
      child: Scaffold(
        backgroundColor: ReleafColors.background,
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 760),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(
                  ReleafSpacing.screen,
                  ReleafSpacing.xl,
                  ReleafSpacing.screen,
                  48,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
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
                    ),
                    const SizedBox(height: ReleafSpacing.sm),
                    Text(
                      'OWNER PREVIEW',
                      style: ReleafTypography.eyebrow.copyWith(
                        color: ReleafColors.premium,
                      ),
                    ),
                    const SizedBox(height: ReleafSpacing.xs),
                    Text('Stories Preview', style: ReleafTypography.display),
                    const SizedBox(height: ReleafSpacing.sm),
                    Text(
                      'Narrated Stories are being prepared and tested here before any public release.',
                      style: ReleafTypography.body,
                    ),
                    const SizedBox(height: ReleafSpacing.section),
                    Text(
                      'TRUE STORIES OF COURAGE',
                      style: ReleafTypography.eyebrow.copyWith(
                        color: ReleafFeatureAccents.sleep,
                      ),
                    ),
                    const SizedBox(height: ReleafSpacing.md),
                    ...StoryCatalog.all.map(
                      (story) => Padding(
                        padding: const EdgeInsets.only(
                          bottom: ReleafSpacing.md,
                        ),
                        child: _StoryPreviewCard(story: story),
                      ),
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

class _StoryPreviewCard extends StatelessWidget {
  const _StoryPreviewCard({required this.story});

  final ReliefStory story;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '${story.title}. ${story.subtitle}',
      child: Container(
        key: Key('story-preview-${story.id}'),
        width: double.infinity,
        padding: const EdgeInsets.all(ReleafSpacing.lg),
        decoration: BoxDecoration(
          color: ReleafColors.surface,
          borderRadius: BorderRadius.circular(ReleafRadii.large),
          border: Border.all(color: ReleafColors.borderSoft),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _StoryArtworkPlaceholder(story: story),
            const SizedBox(height: ReleafSpacing.md),
            Wrap(
              spacing: ReleafSpacing.xs,
              runSpacing: ReleafSpacing.xs,
              children: story.labels
                  .map((label) => _StoryLabel(label: label))
                  .toList(growable: false),
            ),
            const SizedBox(height: ReleafSpacing.sm),
            Text(story.title, style: ReleafTypography.cardTitle),
            const SizedBox(height: ReleafSpacing.xs),
            Text(story.subtitle, style: ReleafTypography.body),
            const SizedBox(height: ReleafSpacing.sm),
            Text(
              story.description,
              style: ReleafTypography.body.copyWith(
                color: ReleafColors.textSecondary,
              ),
            ),
            const SizedBox(height: ReleafSpacing.md),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  story.isAudioAvailable
                      ? Icons.headphones_rounded
                      : Icons.schedule_rounded,
                  size: 18,
                  color: story.isAudioAvailable
                      ? ReleafColors.sage
                      : ReleafColors.premium,
                ),
                const SizedBox(width: ReleafSpacing.xs),
                Expanded(
                  child: Text(
                    story.isAudioAvailable
                        ? 'Narration ready for preview'
                        : 'Narration not imported yet',
                    style: ReleafTypography.meta.copyWith(
                      color: story.isAudioAvailable
                          ? ReleafColors.sage
                          : ReleafColors.premium,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StoryArtworkPlaceholder extends StatelessWidget {
  const _StoryArtworkPlaceholder({required this.story});

  final ReliefStory story;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 7,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(ReleafRadii.medium),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              ReleafColors.surfaceElevated,
              ReleafColors.backgroundRaised,
            ],
          ),
        ),
        child: Center(
          child: Icon(
            story.id == 'TS01_BEYOND_THE_GATE'
                ? Icons.directions_car_filled_rounded
                : Icons.terrain_rounded,
            size: 42,
            color: ReleafFeatureAccents.sleep.withValues(alpha: 0.72),
          ),
        ),
      ),
    );
  }
}

class _StoryLabel extends StatelessWidget {
  const _StoryLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: ReleafColors.backgroundRaised,
        borderRadius: BorderRadius.circular(ReleafRadii.pill),
        border: Border.all(color: ReleafColors.borderSoft),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: ReleafSpacing.sm,
          vertical: 6,
        ),
        child: Text(
          label,
          style: ReleafTypography.eyebrow.copyWith(
            color: ReleafColors.textSecondary,
            fontSize: 9,
            letterSpacing: 1.1,
          ),
        ),
      ),
    );
  }
}
