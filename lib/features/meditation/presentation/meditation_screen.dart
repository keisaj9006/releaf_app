import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers.dart';
import '../../../routing/app_routes.dart';
import '../../../theme/app_theme.dart';
import '../../../theme/releaf_design_tokens.dart';
import '../../../theme/widgets/releaf_meditation_artwork.dart';
import '../../relief/application/relief_paywall_hooks.dart';
import '../application/meditation_library_controller.dart';
import '../data/meditation_catalog.dart';
import '../domain/meditation_content.dart';

class MeditationScreen extends ConsumerWidget {
  const MeditationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catalog = ref.watch(meditationCatalogProvider);
    final library = ref.watch(meditationLibraryControllerProvider);
    final isPremium = ref.watch(subscriptionControllerProvider).isPremium;
    final all = catalog.getAll();
    final foundations =
        catalog.getSeries(MeditationCatalog.foundationsSeriesId);
    final foundationIds = foundations.map((item) => item.id);
    final completedFoundations = library.completedInSeries(foundationIds);
    final nextFoundation = foundations.firstWhere(
      (item) => !library.isCompleted(item.id),
      orElse: () => foundations.first,
    );

    final featured = all.firstWhere(
      (item) => !library.isCompleted(item.id),
      orElse: () => all.first,
    );

    final quickPractices = all
        .where(
          (item) =>
              item.durationSeconds <= 240 &&
              item.category != MeditationCategory.startHere &&
              item.category != MeditationCategory.unguided,
        )
        .toList(growable: false);

    final recent = library.recentIds
        .map(catalog.getById)
        .whereType<MeditationContent>()
        .toList(growable: false);

    final favorites = all
        .where((item) => library.favoriteIds.contains(item.id))
        .toList(growable: false);

    final unguided = catalog.getById('unguided-5');

    Future<void> open(MeditationContent item) => _openMeditation(
          context: context,
          ref: ref,
          item: item,
          isPremium: isPremium,
        );

    return Theme(
      data: AppTheme.premiumDark(),
      child: Scaffold(
        backgroundColor: ReleafColors.background,
        body: Stack(
          children: [
            const Positioned.fill(child: _MeditationBackdrop()),
            SafeArea(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 780),
                  child: CustomScrollView(
                    physics: const BouncingScrollPhysics(),
                    slivers: [
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(
                            ReleafSpacing.screen,
                            ReleafSpacing.lg,
                            ReleafSpacing.screen,
                            124,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const _Header(),
                              const SizedBox(height: ReleafSpacing.xxl),
                              _FeaturedPractice(
                                item: featured,
                                isLocked: featured.isPremium && !isPremium,
                                isFavorite: library.isFavorite(featured.id),
                                onFavorite: () {
                                  unawaited(
                                    ref
                                        .read(
                                          meditationLibraryControllerProvider
                                              .notifier,
                                        )
                                        .toggleFavorite(featured.id),
                                  );
                                },
                                onPressed: () => open(featured),
                              ),
                              const SizedBox(height: ReleafSpacing.section),
                              _FoundationsCourseCard(
                                completed: completedFoundations,
                                total: foundations.length,
                                nextItem: nextFoundation,
                                isLocked:
                                    nextFoundation.isPremium && !isPremium,
                                onPressed: () => open(nextFoundation),
                              ),
                              if (recent.isNotEmpty) ...[
                                const SizedBox(height: ReleafSpacing.section),
                                const _EditorialHeading(
                                  eyebrow: 'RETURN TO',
                                  title: 'Recently played',
                                  description:
                                      'Pick up a practice you used before.',
                                ),
                                const SizedBox(height: ReleafSpacing.md),
                                _PracticeRail(
                                  items: recent,
                                  library: library,
                                  isPremium: isPremium,
                                  onOpen: open,
                                  onFavorite: (item) {
                                    unawaited(
                                      ref
                                          .read(
                                            meditationLibraryControllerProvider
                                                .notifier,
                                          )
                                          .toggleFavorite(item.id),
                                    );
                                  },
                                ),
                              ],
                              if (favorites.isNotEmpty) ...[
                                const SizedBox(height: ReleafSpacing.section),
                                const _EditorialHeading(
                                  eyebrow: 'YOUR LIBRARY',
                                  title: 'Favorites',
                                  description:
                                      'Practices you chose to keep close.',
                                ),
                                const SizedBox(height: ReleafSpacing.md),
                                _PracticeRail(
                                  items: favorites,
                                  library: library,
                                  isPremium: isPremium,
                                  onOpen: open,
                                  onFavorite: (item) {
                                    unawaited(
                                      ref
                                          .read(
                                            meditationLibraryControllerProvider
                                                .notifier,
                                          )
                                          .toggleFavorite(item.id),
                                    );
                                  },
                                ),
                              ],
                              const SizedBox(height: ReleafSpacing.section),
                              const _EditorialHeading(
                                eyebrow: 'QUICK PRACTICES',
                                title: 'A few minutes is enough to begin.',
                                description:
                                    'Short guided sessions for a pause in the middle of real life.',
                              ),
                              const SizedBox(height: ReleafSpacing.md),
                              _PracticeRail(
                                items: quickPractices,
                                library: library,
                                isPremium: isPremium,
                                onOpen: open,
                                onFavorite: (item) {
                                  unawaited(
                                    ref
                                        .read(
                                          meditationLibraryControllerProvider
                                              .notifier,
                                        )
                                        .toggleFavorite(item.id),
                                  );
                                },
                              ),
                              const SizedBox(height: ReleafSpacing.section),
                              const _EditorialHeading(
                                eyebrow: 'EXPLORE BY INTENTION',
                                title: 'Choose the kind of practice you need.',
                                description:
                                    'Browse a smaller collection instead of an endless feed.',
                              ),
                              const SizedBox(height: ReleafSpacing.md),
                              _IntentionGrid(
                                onTap: (category) {
                                  _showCategorySheet(
                                    context: context,
                                    category: category,
                                    items: catalog.getByCategory(category),
                                    library: library,
                                    isPremium: isPremium,
                                    onOpen: open,
                                    onFavorite: (item) {
                                      unawaited(
                                        ref
                                            .read(
                                              meditationLibraryControllerProvider
                                                  .notifier,
                                            )
                                            .toggleFavorite(item.id),
                                      );
                                    },
                                  );
                                },
                              ),
                              if (unguided != null) ...[
                                const SizedBox(height: ReleafSpacing.section),
                                _UnguidedTimerCard(
                                  item: unguided,
                                  isFavorite: library.isFavorite(unguided.id),
                                  onFavorite: () {
                                    unawaited(
                                      ref
                                          .read(
                                            meditationLibraryControllerProvider
                                                .notifier,
                                          )
                                          .toggleFavorite(unguided.id),
                                    );
                                  },
                                  onPressed: () => open(unguided),
                                ),
                              ],
                            ],
                          ),
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

Future<void> _openMeditation({
  required BuildContext context,
  required WidgetRef ref,
  required MeditationContent item,
  required bool isPremium,
}) async {
  if (item.isPremium && !isPremium) {
    await maybeShowPaywall(context, ref, force: true);
    return;
  }
  if (!context.mounted) return;
  await context.push(AppRoutes.meditationSessionFor(item.id));
}

class _MeditationBackdrop extends StatelessWidget {
  const _MeditationBackdrop();

  @override
  Widget build(BuildContext context) {
    return const Stack(
      fit: StackFit.expand,
      children: [
        ReleafMeditationArtwork(
          variant: ReleafMeditationArtworkVariant.editorial,
          intensity: 0.42,
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xD30A0E0D),
                Color(0xEB090D0B),
                ReleafColors.background,
              ],
              stops: [0, 0.48, 1],
            ),
          ),
        ),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'MEDITATION',
          style: TextStyle(
            fontFamily: 'Poppins',
            color: Color(0xFFB8AFC2),
            fontSize: 11,
            height: 1.3,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.9,
          ),
        ),
        SizedBox(height: 7),
        Text('Meditate', style: ReleafTypography.display),
        SizedBox(height: 6),
        Text(
          'Guided practice for attention, awareness and a less reactive relationship with your thoughts.',
          style: ReleafTypography.body,
        ),
      ],
    );
  }
}

class _FeaturedPractice extends StatelessWidget {
  const _FeaturedPractice({
    required this.item,
    required this.isLocked,
    required this.isFavorite,
    required this.onFavorite,
    required this.onPressed,
  });

  final MeditationContent item;
  final bool isLocked;
  final bool isFavorite;
  final VoidCallback onFavorite;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 360;

        return Semantics(
          container: true,
          label:
              'Featured meditation. ${item.title}. ${_durationLabel(item)}.',
          child: Container(
            key: const Key('meditation-featured-practice'),
            height: compact ? 350 : 318,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(ReleafRadii.extraLarge),
              border: Border.all(
                color: const Color(0xFFB5A8C0).withValues(alpha: 0.20),
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF8D7B9C).withValues(alpha: 0.10),
                  blurRadius: 34,
                  offset: const Offset(0, 18),
                ),
              ],
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                ReleafMeditationArtwork(
                  variant: _artworkFor(item.category),
                  intensity: 0.92,
                ),
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0x09000000),
                        Color(0x39000000),
                        Color(0xED080A09),
                      ],
                      stops: [0, 0.54, 1],
                    ),
                  ),
                ),
                Positioned(
                  top: ReleafSpacing.md,
                  right: ReleafSpacing.md,
                  child: _FavoriteButton(
                    itemId: item.id,
                    selected: isFavorite,
                    onPressed: onFavorite,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(
                    compact ? ReleafSpacing.lg : ReleafSpacing.xl,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'FEATURED PRACTICE',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          color: Color(0xFFD8CFE0),
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        item.title,
                        style: ReleafTypography.display.copyWith(
                          fontSize: compact ? 27 : 31,
                          letterSpacing: -0.8,
                        ),
                      ),
                      const SizedBox(height: ReleafSpacing.xs),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 500),
                        child: Text(
                          item.subtitle,
                          style: ReleafTypography.body.copyWith(
                            color:
                                ReleafColors.textPrimary.withValues(alpha: 0.78),
                          ),
                        ),
                      ),
                      const SizedBox(height: ReleafSpacing.md),
                      Row(
                        children: [
                          _MetaPill(
                            icon: Icons.schedule_rounded,
                            label: _durationLabel(item),
                          ),
                          const SizedBox(width: ReleafSpacing.xs),
                          _MetaPill(
                            icon: item.unguided
                                ? Icons.timer_outlined
                                : Icons.record_voice_over_outlined,
                            label: item.unguided ? 'Unguided' : 'Guided',
                          ),
                        ],
                      ),
                      const SizedBox(height: ReleafSpacing.lg),
                      SizedBox(
                        width: compact ? double.infinity : null,
                        height: ReleafControlSizes.standard,
                        child: FilledButton.icon(
                          onPressed: onPressed,
                          icon: Icon(
                            isLocked
                                ? Icons.lock_outline_rounded
                                : Icons.play_arrow_rounded,
                          ),
                          label: Text(isLocked ? 'Unlock practice' : 'Begin'),
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFFD8D0C7),
                            foregroundColor: const Color(0xFF151416),
                            padding: const EdgeInsets.symmetric(
                              horizontal: ReleafSpacing.lg,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _FoundationsCourseCard extends StatelessWidget {
  const _FoundationsCourseCard({
    required this.completed,
    required this.total,
    required this.nextItem,
    required this.isLocked,
    required this.onPressed,
  });

  final int completed;
  final int total;
  final MeditationContent nextItem;
  final bool isLocked;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final progress = total == 0 ? 0.0 : completed / total;

    return Container(
      key: const Key('meditation-foundations-course'),
      padding: const EdgeInsets.all(ReleafSpacing.lg),
      decoration: BoxDecoration(
        color: const Color(0xE7111614),
        borderRadius: BorderRadius.circular(ReleafRadii.large),
        border: Border.all(
          color: const Color(0xFF9C8FA6).withValues(alpha: 0.22),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'FOUNDATIONS',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        color: Color(0xFFB8AFC2),
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.5,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      'Learn the basics in sequence.',
                      style: ReleafTypography.sectionTitle,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: ReleafSpacing.md),
              Text(
                '$completed/$total',
                style: ReleafTypography.cardTitle.copyWith(
                  color: const Color(0xFFD7CDD9),
                ),
              ),
            ],
          ),
          const SizedBox(height: ReleafSpacing.md),
          ClipRRect(
            borderRadius: BorderRadius.circular(ReleafRadii.pill),
            child: LinearProgressIndicator(
              minHeight: 6,
              value: progress,
              backgroundColor: const Color(0xFF24232A),
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFF9C8FA6),
              ),
            ),
          ),
          const SizedBox(height: ReleafSpacing.md),
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: const Color(0xFF211E25),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.menu_book_rounded,
                  color: Color(0xFFB8AFC2),
                  size: 20,
                ),
              ),
              const SizedBox(width: ReleafSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      completed >= total ? 'Course complete' : 'Up next',
                      style: ReleafTypography.meta.copyWith(
                        color: ReleafColors.textMuted,
                        fontSize: 10,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      nextItem.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: ReleafTypography.cardTitle,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: ReleafSpacing.sm),
              IconButton.filledTonal(
                tooltip: isLocked ? 'Unlock next practice' : 'Open next practice',
                onPressed: onPressed,
                icon: Icon(
                  isLocked
                      ? Icons.lock_outline_rounded
                      : completed >= total
                          ? Icons.replay_rounded
                          : Icons.arrow_forward_rounded,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EditorialHeading extends StatelessWidget {
  const _EditorialHeading({
    required this.eyebrow,
    required this.title,
    required this.description,
  });

  final String eyebrow;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          eyebrow,
          style: ReleafTypography.eyebrow.copyWith(
            color: const Color(0xFFB8AFC2),
          ),
        ),
        const SizedBox(height: ReleafSpacing.xs),
        Text(title, style: ReleafTypography.sectionTitle),
        const SizedBox(height: 4),
        Text(description, style: ReleafTypography.body),
      ],
    );
  }
}

class _PracticeRail extends StatelessWidget {
  const _PracticeRail({
    required this.items,
    required this.library,
    required this.isPremium,
    required this.onOpen,
    required this.onFavorite,
  });

  final List<MeditationContent> items;
  final MeditationLibraryState library;
  final bool isPremium;
  final ValueChanged<MeditationContent> onOpen;
  final ValueChanged<MeditationContent> onFavorite;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 224,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: items.length,
        separatorBuilder: (_, _) => const SizedBox(width: ReleafSpacing.sm),
        itemBuilder: (context, index) {
          final item = items[index];
          final width = MediaQuery.sizeOf(context).width < 360 ? 226.0 : 250.0;

          return SizedBox(
            width: width,
            child: _PracticeCard(
              item: item,
              isLocked: item.isPremium && !isPremium,
              isFavorite: library.isFavorite(item.id),
              onFavorite: () => onFavorite(item),
              onPressed: () => onOpen(item),
            ),
          );
        },
      ),
    );
  }
}

class _PracticeCard extends StatefulWidget {
  const _PracticeCard({
    required this.item,
    required this.isLocked,
    required this.isFavorite,
    required this.onFavorite,
    required this.onPressed,
  });

  final MeditationContent item;
  final bool isLocked;
  final bool isFavorite;
  final VoidCallback onFavorite;
  final VoidCallback onPressed;

  @override
  State<_PracticeCard> createState() => _PracticeCardState();
}

class _PracticeCardState extends State<_PracticeCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final reducedMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;

    return AnimatedScale(
      scale: _pressed ? 0.988 : 1,
      duration: reducedMotion ? Duration.zero : ReleafMotion.quick,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(ReleafRadii.large),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: widget.onPressed,
          onHighlightChanged: (value) => setState(() => _pressed = value),
          child: Ink(
            decoration: BoxDecoration(
              color: const Color(0xFF111614),
              borderRadius: BorderRadius.circular(ReleafRadii.large),
              border: Border.all(
                color: const Color(0xFF7E7585).withValues(alpha: 0.24),
              ),
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: 112,
                  child: ReleafMeditationArtwork(
                    variant: _artworkFor(widget.item.category),
                    intensity: 0.82,
                  ),
                ),
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Color(0xA7111614),
                        Color(0xFF111614),
                      ],
                      stops: [0.12, 0.48, 0.70],
                    ),
                  ),
                ),
                Positioned(
                  top: 9,
                  right: 9,
                  child: _FavoriteButton(
                    itemId: widget.item.id,
                    selected: widget.isFavorite,
                    onPressed: widget.onFavorite,
                    compact: true,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(ReleafSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _CategoryPill(item: widget.item),
                      const Spacer(),
                      Text(
                        widget.item.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: ReleafTypography.cardTitle.copyWith(fontSize: 17),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _durationLabel(widget.item),
                        style: ReleafTypography.meta.copyWith(
                          color: ReleafColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: ReleafSpacing.sm),
                      Row(
                        children: [
                          Text(
                            widget.item.unguided ? 'Timer' : 'Guided',
                            style: ReleafTypography.meta.copyWith(
                              color: const Color(0xFFB8AFC2),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const Spacer(),
                          Icon(
                            widget.isLocked
                                ? Icons.lock_outline_rounded
                                : Icons.play_arrow_rounded,
                            size: 18,
                            color: widget.isLocked
                                ? ReleafColors.premium
                                : const Color(0xFFC9C0CD),
                          ),
                        ],
                      ),
                    ],
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

class _FavoriteButton extends StatelessWidget {
  const _FavoriteButton({
    required this.itemId,
    required this.selected,
    required this.onPressed,
    this.compact = false,
  });

  final String itemId;
  final bool selected;
  final VoidCallback onPressed;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: selected ? 'Remove from favorites' : 'Add to favorites',
      child: Material(
        color: const Color(0xB30A0D0C),
        shape: const CircleBorder(),
        child: IconButton(
          key: Key('meditation-favorite-$itemId'),
          tooltip: selected ? 'Remove from favorites' : 'Add to favorites',
          onPressed: onPressed,
          constraints: BoxConstraints.tightFor(
            width: compact ? 36 : 42,
            height: compact ? 36 : 42,
          ),
          padding: EdgeInsets.zero,
          iconSize: compact ? 17 : 19,
          icon: Icon(
            selected ? Icons.favorite_rounded : Icons.favorite_border_rounded,
            color:
                selected ? const Color(0xFFD8BEC8) : const Color(0xFFD9D4D9),
          ),
        ),
      ),
    );
  }
}

class _CategoryPill extends StatelessWidget {
  const _CategoryPill({required this.item});

  final MeditationContent item;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xB20A0D0C),
        borderRadius: BorderRadius.circular(ReleafRadii.pill),
        border: Border.all(
          color: const Color(0xFFCDC4CF).withValues(alpha: 0.14),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        child: Text(
          _categoryLabel(item.category).toUpperCase(),
          style: ReleafTypography.meta.copyWith(
            color: const Color(0xFFD1CAD4),
            fontSize: 8,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.7,
          ),
        ),
      ),
    );
  }
}

class _IntentionGrid extends StatelessWidget {
  const _IntentionGrid({required this.onTap});

  final ValueChanged<MeditationCategory> onTap;

  static const _categories = <MeditationCategory>[
    MeditationCategory.anxiety,
    MeditationCategory.focus,
    MeditationCategory.body,
    MeditationCategory.mind,
    MeditationCategory.everyday,
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const gap = ReleafSpacing.sm;
        final singleColumn = constraints.maxWidth < 330;
        final width = singleColumn
            ? constraints.maxWidth
            : (constraints.maxWidth - gap) / 2;

        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final category in _categories)
              SizedBox(
                width: width,
                child: _IntentionCard(
                  category: category,
                  onTap: () => onTap(category),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _IntentionCard extends StatelessWidget {
  const _IntentionCard({
    required this.category,
    required this.onTap,
  });

  final MeditationCategory category;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(ReleafRadii.medium),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Ink(
          height: 112,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(ReleafRadii.medium),
            border: Border.all(
              color: const Color(0xFF6F6974).withValues(alpha: 0.24),
            ),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              ReleafMeditationArtwork(
                variant: _artworkFor(category),
                intensity: 0.66,
              ),
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerRight,
                    end: Alignment.centerLeft,
                    colors: [
                      Color(0x1A000000),
                      Color(0xD90A0D0C),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(ReleafSpacing.md),
                child: Row(
                  children: [
                    Icon(
                      _categoryIcon(category),
                      color: const Color(0xFFD5CED7),
                      size: 22,
                    ),
                    const SizedBox(width: ReleafSpacing.sm),
                    Expanded(
                      child: Text(
                        _categoryLabel(category),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: ReleafTypography.cardTitle,
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 14,
                      color: ReleafColors.textSecondary,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _UnguidedTimerCard extends StatelessWidget {
  const _UnguidedTimerCard({
    required this.item,
    required this.isFavorite,
    required this.onFavorite,
    required this.onPressed,
  });

  final MeditationContent item;
  final bool isFavorite;
  final VoidCallback onFavorite;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('meditation-unguided-timer'),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(ReleafRadii.large),
        border: Border.all(
          color: const Color(0xFF71838B).withValues(alpha: 0.26),
        ),
      ),
      child: Stack(
        children: [
          const Positioned.fill(
            child: ReleafMeditationArtwork(
              variant: ReleafMeditationArtworkVariant.timer,
              intensity: 0.74,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(ReleafSpacing.lg),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xA30D1417),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.timer_outlined,
                    color: Color(0xFFD3DDE1),
                  ),
                ),
                const SizedBox(width: ReleafSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'UNGUIDED',
                        style: ReleafTypography.eyebrow.copyWith(
                          color: const Color(0xFF9EB0B7),
                          fontSize: 9,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(item.title, style: ReleafTypography.cardTitle),
                      const SizedBox(height: 2),
                      Text(
                        'Quiet timer with optional ambience.',
                        style: ReleafTypography.meta,
                      ),
                    ],
                  ),
                ),
                _FavoriteButton(
                  itemId: item.id,
                  selected: isFavorite,
                  onPressed: onFavorite,
                  compact: true,
                ),
                const SizedBox(width: ReleafSpacing.xs),
                IconButton.filled(
                  tooltip: 'Start unguided meditation',
                  onPressed: onPressed,
                  icon: const Icon(Icons.play_arrow_rounded),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MetaPill extends StatelessWidget {
  const _MetaPill({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0x9E090C0B),
        borderRadius: BorderRadius.circular(ReleafRadii.pill),
        border: Border.all(
          color: const Color(0xFFD7D1D9).withValues(alpha: 0.14),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13, color: const Color(0xFFD7D1D9)),
            const SizedBox(width: 5),
            Text(
              label,
              style: ReleafTypography.meta.copyWith(
                color: const Color(0xFFD7D1D9),
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void _showCategorySheet({
  required BuildContext context,
  required MeditationCategory category,
  required List<MeditationContent> items,
  required MeditationLibraryState library,
  required bool isPremium,
  required ValueChanged<MeditationContent> onOpen,
  required ValueChanged<MeditationContent> onFavorite,
}) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: const Color(0xFF0E1412),
    barrierColor: Colors.black.withValues(alpha: 0.58),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(ReleafRadii.extraLarge),
      ),
    ),
    builder: (sheetContext) {
      return SafeArea(
        top: false,
        child: DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.62,
          minChildSize: 0.42,
          maxChildSize: 0.88,
          builder: (context, scrollController) {
            return ListView(
              controller: scrollController,
              padding: const EdgeInsets.fromLTRB(
                ReleafSpacing.screen,
                ReleafSpacing.lg,
                ReleafSpacing.screen,
                ReleafSpacing.xxl,
              ),
              children: [
                Center(
                  child: Container(
                    width: 42,
                    height: 4,
                    decoration: BoxDecoration(
                      color: ReleafColors.textMuted.withValues(alpha: 0.46),
                      borderRadius: BorderRadius.circular(ReleafRadii.pill),
                    ),
                  ),
                ),
                const SizedBox(height: ReleafSpacing.lg),
                Text(
                  _categoryLabel(category),
                  style: ReleafTypography.display.copyWith(fontSize: 28),
                ),
                const SizedBox(height: 5),
                Text(
                  _categoryDescription(category),
                  style: ReleafTypography.body,
                ),
                const SizedBox(height: ReleafSpacing.xl),
                for (final item in items) ...[
                  _SheetPracticeRow(
                    item: item,
                    isLocked: item.isPremium && !isPremium,
                    isFavorite: library.isFavorite(item.id),
                    onFavorite: () => onFavorite(item),
                    onPressed: () {
                      Navigator.of(sheetContext).pop();
                      Future<void>.microtask(() async => onOpen(item));
                    },
                  ),
                  const SizedBox(height: ReleafSpacing.sm),
                ],
              ],
            );
          },
        ),
      );
    },
  );
}

class _SheetPracticeRow extends StatelessWidget {
  const _SheetPracticeRow({
    required this.item,
    required this.isLocked,
    required this.isFavorite,
    required this.onFavorite,
    required this.onPressed,
  });

  final MeditationContent item;
  final bool isLocked;
  final bool isFavorite;
  final VoidCallback onFavorite;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(ReleafSpacing.md),
      decoration: BoxDecoration(
        color: ReleafColors.surfaceSoft,
        borderRadius: BorderRadius.circular(ReleafRadii.medium),
        border: Border.all(color: ReleafColors.borderSoft),
      ),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: onPressed,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.title, style: ReleafTypography.cardTitle),
                  const SizedBox(height: 4),
                  Text(
                    '${_durationLabel(item)} · ${item.unguided ? 'Unguided' : 'Guided'}',
                    style: ReleafTypography.meta,
                  ),
                ],
              ),
            ),
          ),
          _FavoriteButton(
            itemId: item.id,
            selected: isFavorite,
            onPressed: onFavorite,
            compact: true,
          ),
          const SizedBox(width: ReleafSpacing.xs),
          IconButton(
            tooltip: isLocked ? 'Premium practice' : 'Open practice',
            onPressed: onPressed,
            icon: Icon(
              isLocked
                  ? Icons.lock_outline_rounded
                  : Icons.play_circle_outline_rounded,
              color: isLocked
                  ? ReleafColors.premium
                  : const Color(0xFFB8AFC2),
            ),
          ),
        ],
      ),
    );
  }
}

String _durationLabel(MeditationContent item) {
  final minutes = (item.durationSeconds / 60).round();
  return '$minutes min';
}

String _categoryLabel(MeditationCategory category) {
  return switch (category) {
    MeditationCategory.startHere => 'Start Here',
    MeditationCategory.anxiety => 'Anxiety & Worry',
    MeditationCategory.focus => 'Focus',
    MeditationCategory.mind => 'Mind & Self-Kindness',
    MeditationCategory.body => 'Body Awareness',
    MeditationCategory.everyday => 'Everyday',
    MeditationCategory.unguided => 'Unguided',
  };
}

String _categoryDescription(MeditationCategory category) {
  return switch (category) {
    MeditationCategory.startHere =>
      'Structured practices for learning the foundations.',
    MeditationCategory.anxiety =>
      'Practices for meeting anxious thoughts and anticipation with more space.',
    MeditationCategory.focus =>
      'Attention practices for returning after distraction.',
    MeditationCategory.mind =>
      'Practices for thoughts, self-talk, and a kinder mental stance.',
    MeditationCategory.body =>
      'Body awareness and noticing physical tension without forcing it away.',
    MeditationCategory.everyday =>
      'Short practices that fit around work and ordinary routines.',
    MeditationCategory.unguided =>
      'Simple timers when you want to practise without guidance.',
  };
}

IconData _categoryIcon(MeditationCategory category) {
  return switch (category) {
    MeditationCategory.startHere => Icons.school_outlined,
    MeditationCategory.anxiety => Icons.air_rounded,
    MeditationCategory.focus => Icons.center_focus_strong_rounded,
    MeditationCategory.mind => Icons.favorite_border_rounded,
    MeditationCategory.body => Icons.accessibility_new_rounded,
    MeditationCategory.everyday => Icons.wb_sunny_outlined,
    MeditationCategory.unguided => Icons.timer_outlined,
  };
}

ReleafMeditationArtworkVariant _artworkFor(MeditationCategory category) {
  return switch (category) {
    MeditationCategory.startHere =>
      ReleafMeditationArtworkVariant.editorial,
    MeditationCategory.anxiety => ReleafMeditationArtworkVariant.anxiety,
    MeditationCategory.focus => ReleafMeditationArtworkVariant.focus,
    MeditationCategory.mind => ReleafMeditationArtworkVariant.compassion,
    MeditationCategory.body => ReleafMeditationArtworkVariant.body,
    MeditationCategory.everyday => ReleafMeditationArtworkVariant.everyday,
    MeditationCategory.unguided => ReleafMeditationArtworkVariant.timer,
  };
}
