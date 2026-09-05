import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers.dart';
import '../../../routing/app_routes.dart';
import '../../../theme/app_theme.dart';
import '../../../theme/releaf_design_tokens.dart';
import '../../../theme/widgets/releaf_artwork.dart';
import '../../../theme/widgets/releaf_components.dart';
import '../../relief/application/relief_paywall_hooks.dart';
import '../data/meditation_catalog.dart';
import '../domain/meditation_content.dart';

class MeditationScreen extends ConsumerStatefulWidget {
  const MeditationScreen({super.key});

  @override
  ConsumerState<MeditationScreen> createState() => _MeditationScreenState();
}

class _MeditationScreenState extends ConsumerState<MeditationScreen> {
  MeditationCategory? _selectedCategory;

  @override
  Widget build(BuildContext context) {
    final catalog = ref.watch(meditationCatalogProvider);
    final all = catalog.getAll();
    final visible = _selectedCategory == null
        ? all
        : all.where((item) => item.category == _selectedCategory).toList();
    final isPremium = ref.watch(subscriptionControllerProvider).isPremium;

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
                  constraints: const BoxConstraints(maxWidth: 760),
                  child: CustomScrollView(
                    physics: const BouncingScrollPhysics(),
                    slivers: [
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(
                            ReleafSpacing.screen,
                            ReleafSpacing.lg,
                            ReleafSpacing.screen,
                            ReleafSpacing.xxl,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const _Header(),
                              const SizedBox(height: ReleafSpacing.xxl),
                              _FeaturedMeditation(
                                item: all.first,
                                onPressed: () =>
                                    _openMeditation(all.first, isPremium),
                              ),
                              const SizedBox(height: ReleafSpacing.section),
                              const ReleafSectionHeading(
                                title: 'Choose a Practice',
                                description:
                                    'Short, structured sessions without an endless library.',
                              ),
                              const SizedBox(height: ReleafSpacing.md),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  _FilterChip(
                                    label: 'All',
                                    selected: _selectedCategory == null,
                                    onTap: () =>
                                        setState(() => _selectedCategory = null),
                                  ),
                                  for (final category
                                      in MeditationCategory.values)
                                    _FilterChip(
                                      label: _categoryLabel(category),
                                      selected: _selectedCategory == category,
                                      onTap: () => setState(
                                        () => _selectedCategory = category,
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: ReleafSpacing.xl),
                              for (final item in visible) ...[
                                _MeditationCard(
                                  item: item,
                                  isLocked: item.isPremium && !isPremium,
                                  onPressed: () =>
                                      _openMeditation(item, isPremium),
                                ),
                                const SizedBox(height: ReleafSpacing.sm),
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

  Future<void> _openMeditation(
    MeditationContent item,
    bool isPremium,
  ) async {
    if (item.isPremium && !isPremium) {
      await maybeShowPaywall(context, ref, force: true);
      return;
    }
    if (!mounted) return;
    await context.push(AppRoutes.meditationSessionFor(item.id));
  }
}

class _MeditationBackdrop extends StatelessWidget {
  const _MeditationBackdrop();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF101615),
            ReleafColors.background,
            Color(0xFF070A09),
          ],
          stops: [0, 0.48, 1],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'MEDITATION',
                style: ReleafTypography.eyebrow.copyWith(
                  color: ReleafColors.sage,
                  letterSpacing: 1.9,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Meditate',
                style: ReleafTypography.display.copyWith(fontSize: 32),
              ),
              const SizedBox(height: 6),
              Text(
                'Practice attention without needing to empty your mind.',
                style: ReleafTypography.body.copyWith(
                  color: ReleafColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: ReleafSpacing.md),
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: ReleafColors.sage.withValues(alpha: 0.08),
            border: Border.all(
              color: ReleafColors.sage.withValues(alpha: 0.22),
            ),
            boxShadow: const [
              BoxShadow(
                color: ReleafColors.glowSage,
                blurRadius: 22,
              ),
            ],
          ),
          alignment: Alignment.center,
          child: const Icon(
            Icons.spa_outlined,
            color: ReleafColors.sage,
            size: 23,
          ),
        ),
      ],
    );
  }
}

class _FeaturedMeditation extends StatelessWidget {
  const _FeaturedMeditation({
    required this.item,
    required this.onPressed,
  });

  final MeditationContent item;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return ReleafPressableCard(
      onPressed: onPressed,
      padding: EdgeInsets.zero,
      child: SizedBox(
        height: 276,
        child: Stack(
          fit: StackFit.expand,
          children: [
            const ReleafArtwork(variant: ReleafArtworkVariant.focus),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0x08000000),
                    Color(0x42000000),
                    Color(0xE9000000),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(ReleafSpacing.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'START HERE',
                    style: ReleafTypography.eyebrow.copyWith(
                      color: ReleafColors.sage,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    item.title,
                    style: ReleafTypography.display.copyWith(
                      fontSize: 29,
                      letterSpacing: -0.8,
                    ),
                  ),
                  const SizedBox(height: ReleafSpacing.xs),
                  Text(
                    item.subtitle,
                    style: ReleafTypography.body.copyWith(
                      color: ReleafColors.textPrimary.withValues(alpha: 0.78),
                    ),
                  ),
                  const SizedBox(height: ReleafSpacing.lg),
                  FilledButton.icon(
                    onPressed: onPressed,
                    icon: const Icon(Icons.play_arrow_rounded),
                    label: const Text('Begin'),
                    style: FilledButton.styleFrom(
                      backgroundColor: ReleafColors.sage,
                      foregroundColor: ReleafColors.background,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MeditationCard extends StatelessWidget {
  const _MeditationCard({
    required this.item,
    required this.isLocked,
    required this.onPressed,
  });

  final MeditationContent item;
  final bool isLocked;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final minutes = (item.durationSeconds / 60).round();

    return ReleafPressableCard(
      onPressed: onPressed,
      warmAccent: item.isPremium,
      padding: EdgeInsets.zero,
      child: SizedBox(
        height: 138,
        child: Stack(
          fit: StackFit.expand,
          children: [
            ReleafArtwork(variant: _artworkFor(item.category)),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerRight,
                  end: Alignment.centerLeft,
                  colors: [
                    Color(0x32000000),
                    Color(0xE8000000),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(ReleafSpacing.md),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _categoryLabel(item.category).toUpperCase(),
                          style: ReleafTypography.eyebrow.copyWith(
                            color: item.isPremium
                                ? ReleafColors.premium
                                : ReleafColors.sage,
                            fontSize: 9,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          item.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: ReleafTypography.cardTitle,
                        ),
                        const SizedBox(height: 5),
                        Text(
                          '$minutes min • ${item.unguided ? 'Unguided' : 'Guided'}',
                          style: ReleafTypography.meta.copyWith(
                            color: ReleafColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: ReleafSpacing.md),
                  Icon(
                    isLocked
                        ? Icons.lock_outline_rounded
                        : Icons.play_circle_outline_rounded,
                    color: item.isPremium
                        ? ReleafColors.premium
                        : ReleafColors.sage,
                    size: 30,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
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
      selectedColor: ReleafColors.sage.withValues(alpha: 0.18),
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

String _categoryLabel(MeditationCategory category) {
  return switch (category) {
    MeditationCategory.startHere => 'Start Here',
    MeditationCategory.anxiety => 'Anxiety',
    MeditationCategory.mind => 'Mind',
    MeditationCategory.body => 'Body',
    MeditationCategory.everyday => 'Everyday',
    MeditationCategory.unguided => 'Unguided',
  };
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
