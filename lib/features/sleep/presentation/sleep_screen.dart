import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers.dart';
import '../../../routing/app_routes.dart';
import '../../../routing/primary_destination_actions.dart';
import '../../../theme/app_theme.dart';
import '../../../theme/releaf_design_tokens.dart';
import '../../../theme/widgets/releaf_sleep_artwork.dart';
import '../../relief/application/relief_paywall_hooks.dart';
import '../../stories/domain/relief_story.dart';
import '../../stories/story_preview_config.dart';
import '../application/sleep_progress_store.dart';
import '../data/sleep_catalog.dart';
import '../domain/sleep_content.dart';

String? sleepRouteFor(SleepContent content) {
  final source = content.playbackSource;
  if (source == null) return null;
  return switch (source.type) {
    SleepPlaybackSourceType.story => AppRoutes.sleepStoryPlayerFor(
      source.reference,
    ),
    SleepPlaybackSourceType.sound => AppRoutes.soundPlayerFor(source.reference),
    SleepPlaybackSourceType.meditation => AppRoutes.meditationSessionFor(
      source.reference,
    ),
  };
}

class SleepScreen extends ConsumerStatefulWidget {
  const SleepScreen({
    super.key,
    this.showBack = false,
    this.storiesPreviewEnabled = StoryPreviewConfig.enabled,
  });

  final bool showBack;
  final bool storiesPreviewEnabled;

  @override
  ConsumerState<SleepScreen> createState() => _SleepScreenState();
}

class _SleepScreenState extends ConsumerState<SleepScreen> {
  SleepCategory? _selectedCategory;

  @override
  Widget build(BuildContext context) {
    final catalog = ref.watch(sleepCatalogProvider);
    final isPremium = ref.watch(subscriptionControllerProvider).isPremium;
    final progress = ref.watch(sleepProgressStoreProvider);
    final continueRecords = _resolveContinueListening(catalog, progress);

    Future<void> open(SleepContent content) async {
      final route = sleepRouteFor(content);
      if (!content.isPlayable || route == null) return;

      if (content.isPremium && !isPremium) {
        final unlock = await showModalBottomSheet<bool>(
          context: context,
          useSafeArea: true,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          barrierColor: Colors.black.withValues(alpha: 0.72),
          builder: (_) => _SleepPremiumPreview(content: content),
        );
        if (unlock != true || !context.mounted) return;
        await maybeShowPaywall(context, ref, force: true, softOffer: true);
        if (!context.mounted ||
            !ref.read(subscriptionControllerProvider).isPremium) {
          return;
        }
      }

      if (context.mounted) await context.push(route);
    }

    return Theme(
      data: AppTheme.premiumDark(),
      child: Scaffold(
        backgroundColor: ReleafColors.background,
        body: Stack(
          children: [
            const Positioned.fill(child: _SleepBackdrop()),
            SafeArea(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 780),
                  child: SingleChildScrollView(
                    key: const Key('sleep-discovery-scroll'),
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(
                      ReleafSpacing.screen,
                      ReleafSpacing.lg,
                      ReleafSpacing.screen,
                      124,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (widget.showBack) ...[
                          IconButton(
                            key: const Key('sleep-back'),
                            tooltip: 'Back',
                            onPressed: () => _close(context),
                            icon: const Icon(Icons.arrow_back_rounded),
                          ),
                          const SizedBox(height: ReleafSpacing.sm),
                        ],
                        const _Header(),
                        const PrimaryDestinationActions(),
                        TextButton.icon(
                          key: const Key('sleep-open-sound-library'),
                          onPressed: () => context.push(AppRoutes.sound),
                          icon: const Icon(Icons.library_music_outlined),
                          label: const Text('Your sound library'),
                        ),
                        if (widget.storiesPreviewEnabled) ...[
                          const SizedBox(height: ReleafSpacing.sm),
                          _OwnerPreviewEntry(
                            onPressed: () =>
                                context.push(AppRoutes.storiesPreview),
                          ),
                        ],
                        const SizedBox(height: ReleafSpacing.lg),
                        _CategoryFilters(
                          selected: _selectedCategory,
                          onSelected: (category) {
                            setState(() => _selectedCategory = category);
                          },
                        ),
                        const SizedBox(height: ReleafSpacing.xl),
                        if (_selectedCategory == null)
                          _AllDiscovery(
                            catalog: catalog,
                            continueRecords: continueRecords,
                            onOpen: open,
                            onSeeCategory: (category) {
                              setState(() => _selectedCategory = category);
                            },
                          )
                        else
                          _CategoryDiscovery(
                            category: _selectedCategory!,
                            catalog: catalog,
                            onOpen: open,
                          ),
                        const SizedBox(height: ReleafSpacing.section),
                        const _ResearchNote(),
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

  void _close(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.home);
    }
  }
}

List<({SleepContent content, SleepProgressRecord progress})>
_resolveContinueListening(
  SleepCatalog catalog,
  List<SleepProgressRecord> progress,
) {
  final sorted =
      progress
          .where(
            (record) => !record.isCompleted && record.position > Duration.zero,
          )
          .toList(growable: false)
        ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  return sorted
      .map((record) {
        final content = catalog.getById(record.contentId);
        return content == null || !content.isPlayable
            ? null
            : (content: content, progress: record);
      })
      .whereType<({SleepContent content, SleepProgressRecord progress})>()
      .toList(growable: false);
}

class _AllDiscovery extends StatelessWidget {
  const _AllDiscovery({
    required this.catalog,
    required this.continueRecords,
    required this.onOpen,
    required this.onSeeCategory,
  });

  final SleepCatalog catalog;
  final List<({SleepContent content, SleepProgressRecord progress})>
  continueRecords;
  final ValueChanged<SleepContent> onOpen;
  final ValueChanged<SleepCategory> onSeeCategory;

  @override
  Widget build(BuildContext context) {
    final featured = catalog.getFeatured();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (featured.isNotEmpty)
          _TonightCard(content: featured.first, onOpen: onOpen),
        if (continueRecords.isNotEmpty) ...[
          const SizedBox(height: ReleafSpacing.section),
          const _SectionTitle(title: 'Continue Listening'),
          const SizedBox(height: ReleafSpacing.md),
          _ContinueRail(records: continueRecords, onOpen: onOpen),
        ],
        const SizedBox(height: ReleafSpacing.section),
        const _SectionTitle(eyebrow: 'FAMILIAR FAVOURITES', title: 'Popular'),
        const SizedBox(height: ReleafSpacing.md),
        _ContentRail(
          items: catalog.getPopular(),
          keyPrefix: 'sleep-popular',
          onOpen: onOpen,
        ),
        const SizedBox(height: ReleafSpacing.section),
        _CategorySection(
          eyebrow: 'NATURE AT NIGHT',
          title: 'Nature for the night',
          items: catalog.getByCategory(SleepCategory.nature),
          onOpen: onOpen,
          onSeeAll: () => onSeeCategory(SleepCategory.nature),
        ),
        const SizedBox(height: ReleafSpacing.section),
        _CategorySection(
          eyebrow: 'SLEEP MEDITATIONS',
          title: 'Settle with gentle guidance',
          items: catalog.getByCategory(SleepCategory.meditations),
          onOpen: onOpen,
          onSeeAll: () => onSeeCategory(SleepCategory.meditations),
        ),
        const SizedBox(height: ReleafSpacing.section),
        _CategorySection(
          eyebrow: 'SLEEP MUSIC',
          title: 'Low-stimulation sound',
          items: catalog.getByCategory(SleepCategory.sleepMusic),
          onOpen: onOpen,
          onSeeAll: () => onSeeCategory(SleepCategory.sleepMusic),
        ),
        const SizedBox(height: ReleafSpacing.section),
        _StoryCollections(catalog: catalog, onOpen: onOpen),
      ],
    );
  }
}

class _CategoryDiscovery extends StatelessWidget {
  const _CategoryDiscovery({
    required this.category,
    required this.catalog,
    required this.onOpen,
  });

  final SleepCategory category;
  final SleepCatalog catalog;
  final ValueChanged<SleepContent> onOpen;

  @override
  Widget build(BuildContext context) {
    if (category == SleepCategory.stories) {
      return _StoryCollections(catalog: catalog, onOpen: onOpen);
    }
    final title = switch (category) {
      SleepCategory.nature => 'Nature for the night',
      SleepCategory.meditations => 'Sleep Meditations',
      SleepCategory.sleepMusic => 'Sleep Music',
      SleepCategory.stories => 'Stories',
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(title: title),
        const SizedBox(height: ReleafSpacing.md),
        _ContentWrap(items: catalog.getByCategory(category), onOpen: onOpen),
      ],
    );
  }
}

class _StoryCollections extends StatelessWidget {
  const _StoryCollections({required this.catalog, required this.onOpen});
  final SleepCatalog catalog;
  final ValueChanged<SleepContent> onOpen;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle(
          eyebrow: 'STORIES',
          title: 'Story collections',
          description:
              'Long-form listening will appear here only after its narration and artwork are approved.',
        ),
        const SizedBox(height: ReleafSpacing.md),
        for (final collection in SleepStoryCollection.values) ...[
          _StoryCollectionSection(
            collection: collection,
            items: catalog.getByStoryCollection(collection),
            onOpen: onOpen,
          ),
          if (collection != SleepStoryCollection.values.last)
            const SizedBox(height: ReleafSpacing.lg),
        ],
      ],
    );
  }
}

class _StoryCollectionSection extends StatelessWidget {
  const _StoryCollectionSection({
    required this.collection,
    required this.items,
    required this.onOpen,
  });
  final SleepStoryCollection collection;
  final List<SleepContent> items;
  final ValueChanged<SleepContent> onOpen;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(collection.label, style: ReleafTypography.cardTitle),
            ),
            TextButton(
              key: Key('sleep-story-collection-${collection.name}-see-all'),
              onPressed: () => _showCollection(context),
              child: const Text('See all'),
            ),
          ],
        ),
        const SizedBox(height: ReleafSpacing.sm),
        if (items.isEmpty)
          _EmptyCollection(collection: collection)
        else
          _ContentRail(
            items: items,
            keyPrefix: 'sleep-content',
            onOpen: onOpen,
          ),
      ],
    );
  }

  Future<void> _showCollection(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _StoryCollectionSheet(
        collection: collection,
        items: items,
        onOpen: onOpen,
      ),
    );
  }
}

class _StoryCollectionSheet extends StatelessWidget {
  const _StoryCollectionSheet({
    required this.collection,
    required this.items,
    required this.onOpen,
  });
  final SleepStoryCollection collection;
  final List<SleepContent> items;
  final ValueChanged<SleepContent> onOpen;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: Key('sleep-story-collection-${collection.name}-sheet'),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.82,
      ),
      decoration: const BoxDecoration(
        color: ReleafColors.surface,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(ReleafRadii.extraLarge),
        ),
      ),
      padding: EdgeInsets.fromLTRB(
        ReleafSpacing.screen,
        ReleafSpacing.lg,
        ReleafSpacing.screen,
        ReleafSpacing.lg + MediaQuery.paddingOf(context).bottom,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('STORIES', style: ReleafTypography.eyebrow),
            const SizedBox(height: ReleafSpacing.xs),
            Text(collection.label, style: ReleafTypography.display),
            const SizedBox(height: ReleafSpacing.lg),
            if (items.isEmpty)
              _EmptyCollection(collection: collection)
            else
              _ContentWrap(
                items: items,
                onOpen: (content) {
                  Navigator.of(context).pop();
                  onOpen(content);
                },
              ),
          ],
        ),
      ),
    );
  }
}

class _CategoryFilters extends StatelessWidget {
  const _CategoryFilters({required this.selected, required this.onSelected});
  final SleepCategory? selected;
  final ValueChanged<SleepCategory?> onSelected;

  @override
  Widget build(BuildContext context) {
    final entries = <(SleepCategory?, String)>[
      (null, 'All'),
      for (final category in SleepCategory.values) (category, category.label),
    ];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (var index = 0; index < entries.length; index++) ...[
            ChoiceChip(
              key: Key('sleep-filter-${entries[index].$1?.name ?? 'all'}'),
              label: Text(entries[index].$2),
              selected: selected == entries[index].$1,
              onSelected: (_) => onSelected(entries[index].$1),
            ),
            if (index != entries.length - 1)
              const SizedBox(width: ReleafSpacing.sm),
          ],
        ],
      ),
    );
  }
}

class _TonightCard extends StatelessWidget {
  const _TonightCard({required this.content, required this.onOpen});
  final SleepContent content;
  final ValueChanged<SleepContent> onOpen;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('sleep-featured-sound'),
      constraints: const BoxConstraints(minHeight: 280),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(ReleafRadii.extraLarge),
        border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
      ),
      child: Stack(
        children: [
          const Positioned.fill(
            child: ReleafSleepArtwork(
              variant: ReleafSleepArtworkVariant.sound,
              intensity: 1,
            ),
          ),
          const Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0x12000000), Color(0xF007090D)],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(ReleafSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'TONIGHT · NO VOICE',
                  style: ReleafTypography.eyebrow.copyWith(
                    color: const Color(0xFFD1D3DE),
                  ),
                ),
                const SizedBox(height: 110),
                Text('Tonight', style: ReleafTypography.eyebrow),
                const SizedBox(height: ReleafSpacing.xs),
                Text(content.title, style: ReleafTypography.display),
                const SizedBox(height: ReleafSpacing.xs),
                Text(content.subtitle, style: ReleafTypography.body),
                const SizedBox(height: ReleafSpacing.md),
                FilledButton.icon(
                  onPressed: () => onOpen(content),
                  icon: const Icon(Icons.play_arrow_rounded),
                  label: const Text('Play for sleep'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CategorySection extends StatelessWidget {
  const _CategorySection({
    required this.eyebrow,
    required this.title,
    required this.items,
    required this.onOpen,
    required this.onSeeAll,
  });
  final String eyebrow;
  final String title;
  final List<SleepContent> items;
  final ValueChanged<SleepContent> onOpen;
  final VoidCallback onSeeAll;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: _SectionTitle(eyebrow: eyebrow, title: title),
            ),
            TextButton(onPressed: onSeeAll, child: const Text('See all')),
          ],
        ),
        const SizedBox(height: ReleafSpacing.md),
        _ContentRail(items: items, keyPrefix: 'sleep-content', onOpen: onOpen),
      ],
    );
  }
}

class _ContentRail extends StatelessWidget {
  const _ContentRail({
    required this.items,
    required this.keyPrefix,
    required this.onOpen,
  });
  final List<SleepContent> items;
  final String keyPrefix;
  final ValueChanged<SleepContent> onOpen;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var index = 0; index < items.length; index++) ...[
            SizedBox(
              width: 242,
              child: _ContentCard(
                itemKey: Key('$keyPrefix-${items[index].id}'),
                content: items[index],
                onOpen: onOpen,
              ),
            ),
            if (index != items.length - 1)
              const SizedBox(width: ReleafSpacing.md),
          ],
        ],
      ),
    );
  }
}

class _ContentWrap extends StatelessWidget {
  const _ContentWrap({required this.items, required this.onOpen});
  final List<SleepContent> items;
  final ValueChanged<SleepContent> onOpen;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth >= 540
            ? (constraints.maxWidth - ReleafSpacing.md) / 2
            : constraints.maxWidth;
        return Wrap(
          spacing: ReleafSpacing.md,
          runSpacing: ReleafSpacing.md,
          children: [
            for (final item in items)
              SizedBox(
                width: width,
                child: _ContentCard(
                  itemKey: Key('sleep-content-${item.id}'),
                  content: item,
                  onOpen: onOpen,
                ),
              ),
          ],
        );
      },
    );
  }
}

class _ContentCard extends StatelessWidget {
  const _ContentCard({
    required this.itemKey,
    required this.content,
    required this.onOpen,
  });
  final Key itemKey;
  final SleepContent content;
  final ValueChanged<SleepContent> onOpen;

  @override
  Widget build(BuildContext context) {
    final status = switch (content.releaseStatus) {
      SleepReleaseStatus.assetPending => 'AUDIO IN PRODUCTION',
      SleepReleaseStatus.guidanceOnly => 'RECORDED VOICE PENDING',
      SleepReleaseStatus.ready => null,
    };
    return Semantics(
      button: content.isPlayable,
      label: content.accessibilityLabel,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          key: itemKey,
          onTap: content.isPlayable ? () => onOpen(content) : null,
          borderRadius: BorderRadius.circular(ReleafRadii.large),
          child: Ink(
            padding: const EdgeInsets.all(ReleafSpacing.md),
            decoration: BoxDecoration(
              color: ReleafColors.surface.withValues(alpha: 0.92),
              borderRadius: BorderRadius.circular(ReleafRadii.large),
              border: Border.all(
                color: content.isPremium
                    ? ReleafColors.premium.withValues(alpha: 0.28)
                    : Colors.white.withValues(alpha: 0.08),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _CategoryIcon(category: content.category),
                    if (content.isPremium)
                      const Expanded(
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerRight,
                            child: _PremiumTag(),
                          ),
                        ),
                      )
                    else
                      const Spacer(),
                  ],
                ),
                const SizedBox(height: ReleafSpacing.md),
                Text(content.title, style: ReleafTypography.cardTitle),
                const SizedBox(height: ReleafSpacing.xs),
                Text(content.subtitle, style: ReleafTypography.meta),
                if (status != null) ...[
                  const SizedBox(height: ReleafSpacing.sm),
                  Text(
                    status,
                    style: ReleafTypography.eyebrow.copyWith(
                      color: ReleafColors.textSecondary,
                    ),
                  ),
                ] else ...[
                  const SizedBox(height: ReleafSpacing.sm),
                  Row(
                    children: [
                      if (content.duration != null)
                        Text(
                          '${content.duration!.inMinutes} min',
                          style: ReleafTypography.meta,
                        ),
                      const Spacer(),
                      const Icon(Icons.play_arrow_rounded, size: 22),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ContinueRail extends StatelessWidget {
  const _ContinueRail({required this.records, required this.onOpen});
  final List<({SleepContent content, SleepProgressRecord progress})> records;
  final ValueChanged<SleepContent> onOpen;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final entry in records)
          Padding(
            padding: const EdgeInsets.only(bottom: ReleafSpacing.sm),
            child: ListTile(
              key: Key('sleep-continue-${entry.content.id}'),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(ReleafRadii.large),
              ),
              tileColor: ReleafColors.surface.withValues(alpha: 0.92),
              leading: _CategoryIcon(category: entry.content.category),
              title: Text(entry.content.title),
              subtitle: Text(
                '${entry.progress.position.inMinutes} min listened',
              ),
              trailing: const Icon(Icons.play_arrow_rounded),
              onTap: () => onOpen(entry.content),
            ),
          ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({this.eyebrow, required this.title, this.description});
  final String? eyebrow;
  final String title;
  final String? description;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (eyebrow != null) ...[
          Text(eyebrow!, style: ReleafTypography.eyebrow),
          const SizedBox(height: ReleafSpacing.xs),
        ],
        Text(title, style: ReleafTypography.sectionTitle),
        if (description != null) ...[
          const SizedBox(height: ReleafSpacing.xs),
          Text(description!, style: ReleafTypography.body),
        ],
      ],
    );
  }
}

class _CategoryIcon extends StatelessWidget {
  const _CategoryIcon({required this.category});
  final SleepCategory category;

  @override
  Widget build(BuildContext context) {
    final icon = switch (category) {
      SleepCategory.stories => Icons.auto_stories_rounded,
      SleepCategory.nature => Icons.park_outlined,
      SleepCategory.meditations => Icons.self_improvement_rounded,
      SleepCategory.sleepMusic => Icons.graphic_eq_rounded,
    };
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: const Color(0xFF202638),
        borderRadius: BorderRadius.circular(ReleafRadii.medium),
      ),
      child: Icon(icon, color: const Color(0xFFC7CAD8), size: 21),
    );
  }
}

class _EmptyCollection extends StatelessWidget {
  const _EmptyCollection({required this.collection});
  final SleepStoryCollection collection;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(ReleafSpacing.md),
      decoration: BoxDecoration(
        color: ReleafColors.surface.withValues(alpha: 0.56),
        borderRadius: BorderRadius.circular(ReleafRadii.medium),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Text(
        '${collection.label} is being prepared for a later content release.',
        style: ReleafTypography.meta,
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('NIGHT', style: ReleafTypography.eyebrow),
        const SizedBox(height: ReleafSpacing.xs),
        Text('Sleep', style: ReleafTypography.display.copyWith(fontSize: 34)),
        const SizedBox(height: ReleafSpacing.xs),
        Text(
          'Stories, nature, meditation and low-stimulation sound for a quieter night.',
          style: ReleafTypography.body.copyWith(
            color: ReleafColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _SleepBackdrop extends StatelessWidget {
  const _SleepBackdrop();

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
              colors: [Color(0x9E070A11), Color(0xE5080A0F), Color(0xFF071013)],
              stops: [0, 0.5, 1],
            ),
          ),
        ),
      ],
    );
  }
}

class _OwnerPreviewEntry extends StatelessWidget {
  const _OwnerPreviewEntry({required this.onPressed});
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      key: const Key('sleep-stories-preview'),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ReleafRadii.large),
      ),
      tileColor: ReleafColors.surface,
      leading: const Icon(Icons.auto_stories_rounded),
      title: const Text('Stories'),
      subtitle: const Text('OWNER PREVIEW'),
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: onPressed,
    );
  }
}

class _SleepPremiumPreview extends StatelessWidget {
  const _SleepPremiumPreview({required this.content});
  final SleepContent content;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('sleep-premium-preview'),
      decoration: const BoxDecoration(
        color: ReleafColors.surface,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(ReleafRadii.extraLarge),
        ),
      ),
      padding: EdgeInsets.fromLTRB(
        ReleafSpacing.screen,
        ReleafSpacing.lg,
        ReleafSpacing.screen,
        ReleafSpacing.lg + MediaQuery.paddingOf(context).bottom,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _PremiumTag(),
            const SizedBox(height: ReleafSpacing.md),
            Text(content.title, style: ReleafTypography.display),
            const SizedBox(height: ReleafSpacing.xs),
            Text(content.description, style: ReleafTypography.body),
            const SizedBox(height: ReleafSpacing.lg),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                key: const Key('sleep-premium-preview-unlock'),
                onPressed: () => Navigator.of(context).pop(true),
                icon: const Icon(Icons.lock_open_rounded),
                label: const Text('Unlock Premium'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PremiumTag extends StatelessWidget {
  const _PremiumTag();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: ReleafColors.premium.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(ReleafRadii.pill),
      ),
      child: Text(
        'PREMIUM',
        style: ReleafTypography.eyebrow.copyWith(color: ReleafColors.premium),
      ),
    );
  }
}

class _ResearchNote extends StatelessWidget {
  const _ResearchNote();

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('sleep-research-note'),
      padding: const EdgeInsets.all(ReleafSpacing.md),
      decoration: BoxDecoration(
        color: const Color(0xE6090C11),
        borderRadius: BorderRadius.circular(ReleafRadii.medium),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Text(
        'Sound and listening preferences vary. Keep playback comfortably low and stop if it feels intrusive. Releaf does not claim that one special frequency treats insomnia.',
        style: ReleafTypography.meta.copyWith(
          color: ReleafColors.textSecondary,
          height: 1.5,
        ),
      ),
    );
  }
}
