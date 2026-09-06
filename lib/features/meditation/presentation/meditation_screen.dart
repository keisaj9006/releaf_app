import 'dart:async';
import 'dart:math' as math;

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

    final deeperPractice =
        catalog.getSeries(MeditationCatalog.deeperPracticeSeriesId);
    final deeperIds = deeperPractice.map((item) => item.id);
    final completedDeeper = library.completedInSeries(deeperIds);
    final nextDeeper = deeperPractice.isEmpty
        ? null
        : deeperPractice.firstWhere(
            (item) => !library.isCompleted(item.id),
            orElse: () => deeperPractice.first,
          );

    final sleepPractice =
        catalog.getSeries(MeditationCatalog.sleepSeriesId);
    final sleepIds = sleepPractice.map((item) => item.id);
    final completedSleep = library.completedInSeries(sleepIds);
    final nextSleep = sleepPractice.isEmpty
        ? null
        : sleepPractice.firstWhere(
            (item) => !library.isCompleted(item.id),
            orElse: () => sleepPractice.first,
          );

    final recent = library.recentIds
        .map(catalog.getById)
        .whereType<MeditationContent>()
        .where((item) => !item.isPremium || isPremium)
        .toList(growable: false);

    final accessible = all
        .where((item) => !item.isPremium || isPremium)
        .where((item) => item.category != MeditationCategory.unguided)
        .toList(growable: false);

    final featured = recent.isNotEmpty
        ? recent.first
        : (!nextFoundation.isPremium || isPremium)
            ? nextFoundation
            : accessible.first;

    final quickPractices = accessible
        .where(
          (item) =>
              item.durationSeconds <= 240 &&
              item.category != MeditationCategory.startHere,
        )
        .toList(growable: false);

    MeditationContent? quickByDuration({
      required int minSeconds,
      required int maxSeconds,
    }) {
      for (final item in accessible) {
        if (item.durationSeconds >= minSeconds &&
            item.durationSeconds <= maxSeconds) {
          return item;
        }
      }
      return null;
    }

    final quickTwo = quickByDuration(minSeconds: 0, maxSeconds: 150);
    final quickFour = quickByDuration(minSeconds: 151, maxSeconds: 300);
    final quickLong = quickByDuration(minSeconds: 301, maxSeconds: 900);

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
                              const SizedBox(height: ReleafSpacing.xl),
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
                              if (quickTwo != null ||
                                  quickFour != null ||
                                  quickLong != null) ...[
                                const SizedBox(height: ReleafSpacing.md),
                                _TimeQuickStart(
                                  twoMinute: quickTwo,
                                  fourMinute: quickFour,
                                  longer: quickLong,
                                  onOpen: open,
                                ),
                              ],
                              if (recent.isNotEmpty) ...[
                                const SizedBox(height: ReleafSpacing.section),
                                const _EditorialHeading(
                                  eyebrow: 'CONTINUE',
                                  title: 'Return without searching.',
                                  description:
                                      'Your most recent practices stay close at hand.',
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
                              const SizedBox(height: ReleafSpacing.section),
                              const _EditorialHeading(
                                eyebrow: 'PROGRAMS',
                                title: 'Build a practice over time.',
                                description:
                                    'Follow a short sequence instead of choosing from the whole library every day.',
                              ),
                              const SizedBox(height: ReleafSpacing.md),
                              _ProgramRail(
                                foundationsCompleted: completedFoundations,
                                foundationsTotal: foundations.length,
                                foundationsNext: nextFoundation,
                                foundationsLocked:
                                    nextFoundation.isPremium && !isPremium,
                                onFoundations: () => open(nextFoundation),
                                deeperCompleted: completedDeeper,
                                deeperTotal: deeperPractice.length,
                                deeperNext: nextDeeper,
                                deeperLocked:
                                    nextDeeper?.isPremium == true && !isPremium,
                                onDeeper: nextDeeper == null
                                    ? null
                                    : () => open(nextDeeper),
                                sleepCompleted: completedSleep,
                                sleepTotal: sleepPractice.length,
                                sleepNext: nextSleep,
                                sleepLocked:
                                    nextSleep?.isPremium == true && !isPremium,
                                onSleep: nextSleep == null
                                    ? null
                                    : () => open(nextSleep),
                              ),
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
                                    'Short audio-guided sessions for a pause in the middle of real life.',
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
                              _IntentionRail(
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
    final unlock = await showModalBottomSheet<bool>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.70),
      builder: (_) => _MeditationPremiumPreviewSheet(item: item),
    );

    if (unlock != true || !context.mounted) return;

    await maybeShowPaywall(
      context,
      ref,
      force: true,
      softOffer: true,
    );
    if (!context.mounted) return;

    final nowPremium = ref.read(subscriptionControllerProvider).isPremium;
    if (!nowPremium) return;
  }

  if (!context.mounted) return;
  await context.push(AppRoutes.meditationSessionFor(item.id));
}

class _MeditationPremiumPreviewSheet extends StatelessWidget {
  const _MeditationPremiumPreviewSheet({required this.item});

  final MeditationContent item;

  @override
  Widget build(BuildContext context) {
    final minutes = math.max(1, (item.durationSeconds / 60).round());
    final sample = item.steps.isEmpty ? null : item.steps.first.guidance;

    return Align(
      alignment: Alignment.bottomCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 700),
        child: Material(
          key: const Key('meditation-premium-preview'),
          color: ReleafColors.backgroundRaised,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(ReleafRadii.extraLarge),
          ),
          clipBehavior: Clip.antiAlias,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              ReleafSpacing.screen,
              ReleafSpacing.lg,
              ReleafSpacing.screen,
              ReleafSpacing.xl,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: ReleafColors.premium.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(ReleafRadii.pill),
                        border: Border.all(
                          color: ReleafColors.premium.withValues(alpha: 0.26),
                        ),
                      ),
                      child: Text(
                        'PREMIUM PREVIEW',
                        style: ReleafTypography.eyebrow.copyWith(
                          color: ReleafColors.premium,
                          fontSize: 8,
                        ),
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      tooltip: 'Close preview',
                      onPressed: () => Navigator.of(context).pop(false),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
                const SizedBox(height: ReleafSpacing.md),
                Container(
                  height: 180,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(ReleafRadii.large),
                  ),
                  clipBehavior: Clip.antiAlias,
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
                              Color(0x12000000),
                              Color(0xD7090D0B),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: ReleafSpacing.lg),
                Text(
                  item.title,
                  style: ReleafTypography.display.copyWith(fontSize: 28),
                ),
                const SizedBox(height: ReleafSpacing.xs),
                Text(
                  item.subtitle,
                  style: ReleafTypography.body.copyWith(
                    color: ReleafColors.textSecondary,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: ReleafSpacing.sm),
                Wrap(
                  spacing: ReleafSpacing.xs,
                  runSpacing: ReleafSpacing.xs,
                  children: [
                    _MetaPill(
                      icon: Icons.timer_outlined,
                      label: '$minutes min',
                    ),
                    _MetaPill(
                      icon: Icons.spa_outlined,
                      label: _categoryLabel(item.category),
                    ),
                  ],
                ),
                if (sample != null && sample.trim().isNotEmpty) ...[
                  const SizedBox(height: ReleafSpacing.lg),
                  Text(
                    'A GLIMPSE INSIDE',
                    style: ReleafTypography.eyebrow.copyWith(
                      color: ReleafColors.premium,
                    ),
                  ),
                  const SizedBox(height: ReleafSpacing.xs),
                  Text(
                    sample,
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                    style: ReleafTypography.body.copyWith(
                      color: ReleafColors.textPrimary.withValues(alpha: 0.84),
                      height: 1.5,
                    ),
                  ),
                ],
                const SizedBox(height: ReleafSpacing.lg),
                Text(
                  'You can review the practice before deciding. Starting the full guided session requires Releaf Premium.',
                  style: ReleafTypography.meta.copyWith(
                    color: ReleafColors.textMuted,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: ReleafSpacing.lg),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    key: const Key('meditation-premium-preview-unlock'),
                    onPressed: () => Navigator.of(context).pop(true),
                    icon: const Icon(Icons.lock_open_rounded),
                    label: const Text('Unlock Premium'),
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
          'Press play, get comfortable, then let the voice carry the practice.',
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
                Positioned(
                  top: compact ? ReleafSpacing.lg : ReleafSpacing.xl,
                  left: compact ? ReleafSpacing.lg : ReleafSpacing.xl,
                  right: 72,
                  child: const Text(
                    'TODAY’S PRACTICE · RELEAF GUIDE',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      color: Color(0xFFD8CFE0),
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
                Positioned(
                  left: compact ? ReleafSpacing.lg : ReleafSpacing.xl,
                  right: compact ? ReleafSpacing.lg : ReleafSpacing.xl,
                  bottom: compact ? ReleafSpacing.lg : ReleafSpacing.xl,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: ReleafTypography.display.copyWith(
                          fontSize: compact ? 27 : 31,
                          letterSpacing: -0.8,
                        ),
                      ),
                      const SizedBox(height: ReleafSpacing.xs),
                      Text(
                        item.subtitle,
                        maxLines: compact ? 3 : 2,
                        overflow: TextOverflow.ellipsis,
                        style: ReleafTypography.body.copyWith(
                          color:
                              ReleafColors.textPrimary.withValues(alpha: 0.78),
                        ),
                      ),
                      const SizedBox(height: ReleafSpacing.md),
                      Wrap(
                        spacing: ReleafSpacing.xs,
                        runSpacing: ReleafSpacing.xs,
                        children: [
                          _MetaPill(
                            icon: Icons.schedule_rounded,
                            label: _durationLabel(item),
                          ),
                          _MetaPill(
                            icon: item.unguided
                                ? Icons.timer_outlined
                                : Icons.record_voice_over_outlined,
                            label: item.unguided ? 'Unguided' : 'Releaf Guide',
                          ),
                          if (!item.unguided)
                            const _MetaPill(
                              icon: Icons.visibility_off_outlined,
                              label: 'Eyes-closed ready',
                            ),
                        ],
                      ),
                      const SizedBox(height: ReleafSpacing.md),
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
                          label: Text(
                            isLocked ? 'Unlock practice' : 'Start practice',
                          ),
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

class _TimeQuickStart extends StatelessWidget {
  const _TimeQuickStart({
    required this.twoMinute,
    required this.fourMinute,
    required this.longer,
    required this.onOpen,
  });

  final MeditationContent? twoMinute;
  final MeditationContent? fourMinute;
  final MeditationContent? longer;
  final Future<void> Function(MeditationContent item) onOpen;

  @override
  Widget build(BuildContext context) {
    final options = <({String label, String sublabel, MeditationContent item})>[
      if (twoMinute != null)
        (
          label: '2 min',
          sublabel: 'Reset attention',
          item: twoMinute!,
        ),
      if (fourMinute != null)
        (
          label: '4 min',
          sublabel: 'Settle in',
          item: fourMinute!,
        ),
      if (longer != null)
        (
          label: '5+ min',
          sublabel: 'Go deeper',
          item: longer!,
        ),
    ];

    return Container(
      key: const Key('meditation-time-quick-start'),
      padding: const EdgeInsets.fromLTRB(
        ReleafSpacing.md,
        ReleafSpacing.sm,
        ReleafSpacing.md,
        ReleafSpacing.md,
      ),
      decoration: BoxDecoration(
        color: ReleafColors.surfaceSoft.withValues(alpha: 0.56),
        borderRadius: BorderRadius.circular(ReleafRadii.large),
        border: Border.all(
          color: const Color(0xFFB5A8C0).withValues(alpha: 0.15),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'HOW MUCH TIME DO YOU HAVE?',
            style: ReleafTypography.eyebrow.copyWith(
              color: const Color(0xFFC9BBCF),
              fontSize: 8.5,
              letterSpacing: 1.25,
            ),
          ),
          const SizedBox(height: ReleafSpacing.sm),
          Row(
            children: [
              for (var index = 0; index < options.length; index++) ...[
                if (index > 0) const SizedBox(width: ReleafSpacing.xs),
                Expanded(
                  child: _TimeQuickStartButton(
                    label: options[index].label,
                    sublabel: options[index].sublabel,
                    onPressed: () => onOpen(options[index].item),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _TimeQuickStartButton extends StatelessWidget {
  const _TimeQuickStartButton({
    required this.label,
    required this.sublabel,
    required this.onPressed,
  });

  final String label;
  final String sublabel;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.045),
      borderRadius: BorderRadius.circular(ReleafRadii.medium),
      child: InkWell(
        borderRadius: BorderRadius.circular(ReleafRadii.medium),
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 11,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: ReleafTypography.meta.copyWith(
                  color: ReleafColors.textPrimary,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                sublabel,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: ReleafTypography.meta.copyWith(
                  color: ReleafColors.textMuted,
                  fontSize: 8.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProgramRail extends StatelessWidget {
  const _ProgramRail({
    required this.foundationsCompleted,
    required this.foundationsTotal,
    required this.foundationsNext,
    required this.foundationsLocked,
    required this.onFoundations,
    required this.deeperCompleted,
    required this.deeperTotal,
    required this.deeperNext,
    required this.deeperLocked,
    required this.onDeeper,
    required this.sleepCompleted,
    required this.sleepTotal,
    required this.sleepNext,
    required this.sleepLocked,
    required this.onSleep,
  });

  final int foundationsCompleted;
  final int foundationsTotal;
  final MeditationContent foundationsNext;
  final bool foundationsLocked;
  final VoidCallback onFoundations;
  final int deeperCompleted;
  final int deeperTotal;
  final MeditationContent? deeperNext;
  final bool deeperLocked;
  final VoidCallback? onDeeper;
  final int sleepCompleted;
  final int sleepTotal;
  final MeditationContent? sleepNext;
  final bool sleepLocked;
  final VoidCallback? onSleep;

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 360;

    return SizedBox(
      height: compact ? 238 : 222,
      child: ListView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        children: [
          SizedBox(
            width: compact ? 270 : 310,
            child: _ProgramCard(
              cardKey: const Key('meditation-foundations-course'),
              eyebrow: 'FOUNDATIONS',
              title: 'Learn the basics',
              description: 'Four audio-guided sessions that build one skill at a time.',
              artwork: ReleafMeditationArtworkVariant.editorial,
              accent: const Color(0xFFC9BBCF),
              completed: foundationsCompleted,
              total: foundationsTotal,
              nextItem: foundationsNext,
              isLocked: foundationsLocked,
              onPressed: onFoundations,
            ),
          ),
          const SizedBox(width: ReleafSpacing.sm),
          if (deeperNext != null)
            SizedBox(
              width: compact ? 270 : 310,
              child: _ProgramCard(
                cardKey: const Key('meditation-deeper-course'),
                eyebrow: 'DEEPER PRACTICE',
                title: 'Stay a little longer',
                description:
                    'Longer sessions for attention, uncertainty and whole-body awareness.',
                artwork: ReleafMeditationArtworkVariant.body,
                accent: const Color(0xFFD1B09E),
                completed: deeperCompleted,
                total: deeperTotal,
                nextItem: deeperNext!,
                isLocked: deeperLocked,
                onPressed: onDeeper!,
              ),
            ),
          if (sleepNext != null) ...[
            const SizedBox(width: ReleafSpacing.sm),
            SizedBox(
              width: compact ? 270 : 310,
              child: _ProgramCard(
                cardKey: const Key('meditation-sleep-course'),
                eyebrow: 'NIGHT PRACTICE',
                title: 'End the day more quietly',
                description:
                    'Three evening practices for letting go, body stillness and a quieter mind.',
                artwork: ReleafMeditationArtworkVariant.everyday,
                accent: const Color(0xFFB8B9D7),
                completed: sleepCompleted,
                total: sleepTotal,
                nextItem: sleepNext!,
                isLocked: sleepLocked,
                onPressed: onSleep!,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ProgramCard extends StatelessWidget {
  const _ProgramCard({
    required this.cardKey,
    required this.eyebrow,
    required this.title,
    required this.description,
    required this.artwork,
    required this.accent,
    required this.completed,
    required this.total,
    required this.nextItem,
    required this.isLocked,
    required this.onPressed,
  });

  final Key cardKey;
  final String eyebrow;
  final String title;
  final String description;
  final ReleafMeditationArtworkVariant artwork;
  final Color accent;
  final int completed;
  final int total;
  final MeditationContent nextItem;
  final bool isLocked;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final progress = total == 0 ? 0.0 : completed / total;

    return Material(
      key: cardKey,
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(ReleafRadii.extraLarge),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onPressed,
        child: Ink(
          child: Stack(
            fit: StackFit.expand,
            children: [
              ReleafMeditationArtwork(
                variant: artwork,
                intensity: 0.90,
              ),
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0x18000000),
                      Color(0x5C000000),
                      Color(0xF00A0C0B),
                    ],
                    stops: [0, 0.50, 1],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(ReleafSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      eyebrow,
                      style: ReleafTypography.eyebrow.copyWith(
                        color: accent,
                        fontSize: 9,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: ReleafTypography.sectionTitle.copyWith(
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: ReleafTypography.meta.copyWith(
                        color: ReleafColors.textPrimary.withValues(alpha: 0.72),
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: ReleafSpacing.md),
                    Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius:
                                BorderRadius.circular(ReleafRadii.pill),
                            child: LinearProgressIndicator(
                              minHeight: 4,
                              value: progress,
                              backgroundColor:
                                  Colors.white.withValues(alpha: 0.10),
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(accent),
                            ),
                          ),
                        ),
                        const SizedBox(width: ReleafSpacing.sm),
                        Text(
                          '$completed/$total',
                          style: ReleafTypography.meta.copyWith(
                            color: accent,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: ReleafSpacing.sm),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            completed >= total
                                ? 'Replay ${nextItem.title}'
                                : 'Next · ${nextItem.title}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: ReleafTypography.meta.copyWith(
                              color: ReleafColors.textSecondary,
                            ),
                          ),
                        ),
                        Icon(
                          isLocked
                              ? Icons.lock_outline_rounded
                              : Icons.arrow_forward_rounded,
                          size: 18,
                          color:
                              isLocked ? ReleafColors.premium : accent,
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
                Positioned(
                  top: ReleafSpacing.md,
                  left: ReleafSpacing.md,
                  child: _CategoryPill(item: widget.item),
                ),
                Positioned(
                  left: ReleafSpacing.md,
                  right: ReleafSpacing.md,
                  bottom: ReleafSpacing.md,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.item.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: ReleafTypography.cardTitle.copyWith(fontSize: 17),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        _durationLabel(widget.item),
                        style: ReleafTypography.meta.copyWith(
                          color: ReleafColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: ReleafSpacing.xs),
                      Row(
                        children: [
                          Text(
                            widget.item.unguided ? 'Timer' : 'Releaf Guide',
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

class _IntentionRail extends StatelessWidget {
  const _IntentionRail({required this.onTap});

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
    final compact = MediaQuery.sizeOf(context).width < 360;

    return SizedBox(
      height: compact ? 152 : 164,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: _categories.length,
        separatorBuilder: (_, _) => const SizedBox(width: ReleafSpacing.sm),
        itemBuilder: (context, index) {
          final category = _categories[index];
          return SizedBox(
            width: compact ? 146 : 164,
            child: _IntentionTile(
              category: category,
              onTap: () => onTap(category),
            ),
          );
        },
      ),
    );
  }
}

class _IntentionTile extends StatelessWidget {
  const _IntentionTile({
    required this.category,
    required this.onTap,
  });

  final MeditationCategory category;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(ReleafRadii.large),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Ink(
          child: Stack(
            fit: StackFit.expand,
            children: [
              ReleafMeditationArtwork(
                variant: _artworkFor(category),
                intensity: 0.84,
              ),
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0x10000000),
                      Color(0xC70A0C0B),
                    ],
                    stops: [0.20, 1],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(ReleafSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      _categoryIcon(category),
                      color: const Color(0xFFE0D8E2),
                      size: 20,
                    ),
                    const Spacer(),
                    Text(
                      _categoryLabel(category),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: ReleafTypography.cardTitle.copyWith(
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Explore',
                      style: ReleafTypography.meta.copyWith(
                        color: const Color(0xFFB8AFC2),
                        fontWeight: FontWeight.w700,
                      ),
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
                    '${_durationLabel(item)} · ${item.unguided ? 'Unguided' : 'Releaf Guide'}',
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
