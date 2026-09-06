import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/providers.dart';
import '../../core/session/session_manager.dart';
import '../../routing/app_routes.dart';
import '../../theme/app_theme.dart';
import '../../theme/releaf_design_tokens.dart';
import '../../theme/widgets/releaf_artwork.dart';
import '../../theme/widgets/releaf_brain_artwork.dart';
import '../../theme/widgets/releaf_components.dart';
import '../meditation/application/meditation_library_controller.dart';
import '../meditation/data/meditation_catalog.dart';
import '../meditation/domain/meditation_content.dart';
import '../progress/data/leaves_repository.dart';
import '../sound/application/sound_player_controller.dart';
import '../sound/data/sound_catalog.dart';
import 'daily_insight.dart';
import 'home_personalization.dart';

final homeNowProvider = Provider<DateTime>((ref) => DateTime.now());

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  _HomeNeed? _selectedNeed;

  @override
  Widget build(BuildContext context) {
    final leaves = ref.watch(leavesNotifierProvider);
    final activeSession = ref.watch(sessionManagerProvider);
    final soundState = ref.watch(soundPlayerControllerProvider);
    final soundCatalog = ref.watch(soundCatalogProvider);
    final meditationCatalog = ref.watch(meditationCatalogProvider);
    final meditationLibrary = ref.watch(meditationLibraryControllerProvider);
    final focus = ref.watch(homeFocusProvider);
    final showIntro = ref.watch(homeIntroProvider);
    final hasPremiumEntitlement =
        ref.watch(subscriptionControllerProvider).isPremium;
    final currentSound = soundCatalog.getById(soundState.currentTrackId ?? '');
    final recentMeditation = _recentAccessibleMeditation(
      catalog: meditationCatalog,
      library: meditationLibrary,
      isPremium: hasPremiumEntitlement,
    );

    final now = ref.watch(homeNowProvider);
    final dailyInsight = DailyInsightCatalog.forDate(now);
    final suggestedMeditation = _suggestedMeditation(
      catalog: meditationCatalog,
      library: meditationLibrary,
      isPremium: hasPremiumEntitlement,
    );
    final recommendation = _recommendationFor(
      need: _selectedNeed,
      focus: focus,
      hour: now.hour,
      reliefDone: leaves.reliefDone,
      brainDone: leaves.brainDone,
      isPremium: hasPremiumEntitlement,
      suggestedMeditation: suggestedMeditation,
    );

    final completedToday = [
      leaves.reliefDone,
      leaves.brainDone,
    ].where((done) => done).length;

    return Theme(
      data: AppTheme.premiumDark(),
      child: Scaffold(
        backgroundColor: ReleafColors.background,
        body: Stack(
          children: [
            const Positioned.fill(child: _HomeBackdrop()),
            SafeArea(
              bottom: false,
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 820),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(
                            ReleafSpacing.screen,
                            ReleafSpacing.xl,
                            ReleafSpacing.screen,
                            140,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _HomeHeader(
                                hour: now.hour,
                                onAccount: () => context.push(AppRoutes.account),
                              ),
                              if (showIntro) ...[
                                const SizedBox(height: ReleafSpacing.xl),
                                _HomeWelcomeCard(
                                  onPersonalize: () => _showHomeFocusSheet(
                                    context,
                                    ref,
                                    focus,
                                  ),
                                  onDismiss: () {
                                    ref
                                        .read(homeIntroProvider.notifier)
                                        .dismiss();
                                  },
                                ),
                              ],
                              const SizedBox(height: ReleafSpacing.xxl),
                              const ReleafSectionHeading(
                                title: 'Right Now',
                                description:
                                    'Choose what would help. Releaf will narrow it to one next step.',
                              ),
                              const SizedBox(height: ReleafSpacing.md),
                              _NeedGrid(
                                selectedNeed: _selectedNeed,
                                onSelected: (need) {
                                  setState(() {
                                    _selectedNeed =
                                        _selectedNeed == need ? null : need;
                                  });
                                },
                              ),
                              const SizedBox(height: ReleafSpacing.lg),
                              _RecommendationHero(
                                recommendation: recommendation,
                                onPressed: () =>
                                    context.push(recommendation.route),
                              ),
                              const SizedBox(height: ReleafSpacing.section),
                              const ReleafSectionHeading(
                                title: 'Daily Insight',
                                description:
                                    'One surprising, evidence-backed idea. Tap to reveal the full story.',
                              ),
                              const SizedBox(height: ReleafSpacing.md),
                              _DailyInsightCard(
                                insight: dailyInsight,
                                onOpen: () => _showDailyInsightSheet(
                                  context,
                                  dailyInsight,
                                ),
                              ),
                              const SizedBox(height: ReleafSpacing.sm),
                              _HomeFocusStrip(
                                focus: focus,
                                onPressed: () => _showHomeFocusSheet(
                                  context,
                                  ref,
                                  focus,
                                ),
                              ),
                              if (activeSession.hasActive ||
                                  currentSound != null ||
                                  recentMeditation != null) ...[
                                const SizedBox(height: ReleafSpacing.section),
                                const ReleafSectionHeading(
                                  title: 'Continue',
                                  description:
                                      'Pick up without searching for it again.',
                                ),
                                const SizedBox(height: ReleafSpacing.md),
                                if (activeSession.hasActive)
                                  _ContinueCard(
                                    eyebrow: 'PAUSED SESSION',
                                    title: activeSession.title,
                                    subtitle: activeSession.subtitle,
                                    icon: Icons.play_arrow_rounded,
                                    onPressed: () => context.push(
                                      activeSession.resumeRoute,
                                      extra: activeSession.extra,
                                    ),
                                  )
                                else if (currentSound != null)
                                  _ContinueCard(
                                    eyebrow: soundState.isPlaying
                                        ? 'PLAYING'
                                        : 'PAUSED SOUND',
                                    title: currentSound.title,
                                    subtitle: 'Continue your Sound Space.',
                                    icon: Icons.graphic_eq_rounded,
                                    onPressed: () => context.push(
                                      AppRoutes.soundPlayerFor(currentSound.id),
                                    ),
                                  )
                                else if (recentMeditation != null)
                                  _ContinueCard(
                                    eyebrow: 'RECENT MEDITATION',
                                    title: recentMeditation.title,
                                    subtitle:
                                        'Return to a practice you used recently.',
                                    icon: Icons.spa_outlined,
                                    onPressed: () => context.push(
                                      AppRoutes.meditationSessionFor(
                                        recentMeditation.id,
                                      ),
                                    ),
                                  ),
                              ],
                              const SizedBox(height: ReleafSpacing.section),
                              const ReleafSectionHeading(
                                title: 'Daily Essentials',
                                description:
                                    'A small amount of structure, without turning wellbeing into a checklist.',
                              ),
                              const SizedBox(height: ReleafSpacing.md),
                              _DailyEssentials(
                                brainDone: leaves.brainDone,
                                onBrain: () => context.go(AppRoutes.brain),
                                onTonight: () => context.go(AppRoutes.sleep),
                              ),
                              const SizedBox(height: ReleafSpacing.section),
                              _ProgressCard(
                                totalLeaves: leaves.totalLeaves,
                                completedToday: completedToday,
                                reliefDone: leaves.reliefDone,
                                brainDone: leaves.brainDone,
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
          ],
        ),
      ),
    );
  }
}

class _HomeWelcomeCard extends StatelessWidget {
  const _HomeWelcomeCard({
    required this.onPersonalize,
    required this.onDismiss,
  });

  final VoidCallback onPersonalize;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('home-welcome-card'),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(ReleafRadii.extraLarge),
        border: Border.all(
          color: ReleafColors.sage.withValues(alpha: 0.22),
        ),
        boxShadow: const [
          BoxShadow(
            color: ReleafColors.glowSage,
            blurRadius: 28,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Stack(
        children: [
          const Positioned.fill(
            child: ReleafArtwork(
              variant: ReleafArtworkVariant.lifeUpgrade,
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    ReleafColors.backgroundRaised.withValues(alpha: 0.90),
                    ReleafColors.background.withValues(alpha: 0.84),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(ReleafSpacing.lg),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final compact = constraints.maxWidth < 360;

                final actions = [
                  FilledButton.icon(
                    key: const Key('home-welcome-personalize'),
                    onPressed: onPersonalize,
                    icon: const Icon(Icons.tune_rounded, size: 18),
                    label: const Text('Choose my focus'),
                    style: FilledButton.styleFrom(
                      backgroundColor: ReleafColors.sage,
                      foregroundColor: ReleafColors.background,
                    ),
                  ),
                  TextButton(
                    key: const Key('home-welcome-dismiss'),
                    onPressed: onDismiss,
                    child: const Text('Not now'),
                  ),
                ];

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'WELCOME TO RELEAF',
                      style: ReleafTypography.eyebrow.copyWith(
                        color: ReleafColors.sage,
                        letterSpacing: 1.7,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Text(
                      'Make the next suggestion feel more like yours.',
                      style: ReleafTypography.sectionTitle.copyWith(
                        fontSize: compact ? 21 : 24,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Text(
                      'Choose one focus and Releaf will tune default recommendations around it. You can still choose something different at any time.',
                      style: ReleafTypography.body.copyWith(
                        color: ReleafColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: ReleafSpacing.md),
                    if (compact)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          actions[0],
                          const SizedBox(height: ReleafSpacing.xs),
                          actions[1],
                        ],
                      )
                    else
                      Row(
                        children: [
                          actions[0],
                          const SizedBox(width: ReleafSpacing.xs),
                          actions[1],
                        ],
                      ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader({
    required this.hour,
    required this.onAccount,
  });

  final int hour;
  final VoidCallback onAccount;

  @override
  Widget build(BuildContext context) {
    final daypart = switch (hour) {
      < 12 => 'Good morning',
      < 18 => 'Good afternoon',
      _ => 'Good evening',
    };

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'RELEAF',
                style: ReleafTypography.eyebrow.copyWith(
                  color: ReleafColors.sage,
                  letterSpacing: 2.2,
                ),
              ),
              const SizedBox(height: 7),
              Text(
                daypart,
                style: ReleafTypography.display.copyWith(
                  fontSize: 32,
                ),
              ),
              const SizedBox(height: 7),
              Text(
                'Start with what you need, not with what you should do.',
                style: ReleafTypography.body.copyWith(
                  color: ReleafColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: ReleafSpacing.md),
        Container(
          width: 54,
          height: 54,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: ReleafColors.sage.withValues(alpha: 0.08),
            border: Border.all(
              color: ReleafColors.sage.withValues(alpha: 0.22),
            ),
            boxShadow: const [
              BoxShadow(
                color: ReleafColors.glowSage,
                blurRadius: 24,
                spreadRadius: 1,
              ),
            ],
          ),
          alignment: Alignment.center,
          child: IconButton(
            key: const Key('home-account-button'),
            tooltip: 'Account and Premium',
            onPressed: onAccount,
            icon: const Icon(
              Icons.person_outline_rounded,
              color: ReleafColors.sage,
              size: 25,
            ),
          ),
        ),
      ],
    );
  }
}

class _HomeBackdrop extends StatelessWidget {
  const _HomeBackdrop();

  @override
  Widget build(BuildContext context) {
    return const Stack(
      fit: StackFit.expand,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF0B1713),
                ReleafColors.background,
                Color(0xFF070B09),
              ],
              stops: [0, 0.52, 1],
            ),
          ),
        ),
        Opacity(
          opacity: 0.22,
          child: ReleafArtwork(
            variant: ReleafArtworkVariant.lifeUpgrade,
          ),
        ),
      ],
    );
  }
}

enum _HomeNeed {
  calm,
  clearMind,
  focus,
  windDown,
}

class _NeedGrid extends StatelessWidget {
  const _NeedGrid({
    required this.selectedNeed,
    required this.onSelected,
  });

  final _HomeNeed? selectedNeed;
  final ValueChanged<_HomeNeed> onSelected;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label: 'Choose what you need right now.',
      child: Wrap(
        spacing: ReleafSpacing.xs,
        runSpacing: ReleafSpacing.xs,
        children: [
          _NeedChip(
            need: _HomeNeed.calm,
            icon: Icons.waves_rounded,
            title: 'Calm down',
            selected: selectedNeed == _HomeNeed.calm,
            onPressed: onSelected,
          ),
          _NeedChip(
            need: _HomeNeed.clearMind,
            icon: Icons.blur_on_rounded,
            title: 'Clear my head',
            selected: selectedNeed == _HomeNeed.clearMind,
            onPressed: onSelected,
          ),
          _NeedChip(
            need: _HomeNeed.focus,
            icon: Icons.center_focus_strong_rounded,
            title: 'Focus',
            selected: selectedNeed == _HomeNeed.focus,
            onPressed: onSelected,
          ),
          _NeedChip(
            need: _HomeNeed.windDown,
            icon: Icons.bedtime_outlined,
            title: 'Wind down',
            selected: selectedNeed == _HomeNeed.windDown,
            onPressed: onSelected,
          ),
        ],
      ),
    );
  }
}

class _NeedChip extends StatelessWidget {
  const _NeedChip({
    required this.need,
    required this.icon,
    required this.title,
    required this.selected,
    required this.onPressed,
  });

  final _HomeNeed need;
  final IconData icon;
  final String title;
  final bool selected;
  final ValueChanged<_HomeNeed> onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: title,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(ReleafRadii.pill),
        child: InkWell(
          borderRadius: BorderRadius.circular(ReleafRadii.pill),
          onTap: () => onPressed(need),
          child: AnimatedContainer(
            duration: ReleafMotion.standard,
            curve: ReleafMotion.entranceCurve,
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 11,
            ),
            decoration: BoxDecoration(
              color: selected
                  ? ReleafColors.sage.withValues(alpha: 0.13)
                  : ReleafColors.surfaceSoft.withValues(alpha: 0.72),
              borderRadius: BorderRadius.circular(ReleafRadii.pill),
              border: Border.all(
                color: selected
                    ? ReleafColors.sage.withValues(alpha: 0.46)
                    : ReleafColors.borderSoft,
              ),
              boxShadow: selected
                  ? const [
                      BoxShadow(
                        color: ReleafColors.glowSage,
                        blurRadius: 20,
                        spreadRadius: 1,
                      ),
                    ]
                  : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: 17,
                  color: selected
                      ? ReleafColors.textPrimary
                      : ReleafColors.sage,
                ),
                const SizedBox(width: 7),
                Text(
                  title,
                  style: ReleafTypography.meta.copyWith(
                    color: selected
                        ? ReleafColors.textPrimary
                        : ReleafColors.textSecondary,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                  ),
                ),
                if (selected) ...[
                  const SizedBox(width: 7),
                  const Icon(
                    Icons.check_rounded,
                    size: 15,
                    color: ReleafColors.sage,
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

class _HomeRecommendation {
  const _HomeRecommendation({
    required this.eyebrow,
    required this.title,
    required this.description,
    required this.reason,
    required this.meta,
    required this.route,
    required this.artwork,
    required this.icon,
    this.warm = false,
  });

  final String eyebrow;
  final String title;
  final String description;
  final String reason;
  final String meta;
  final String route;
  final ReleafArtworkVariant artwork;
  final IconData icon;
  final bool warm;
}

_HomeRecommendation _recommendationFor({
  required _HomeNeed? need,
  required HomeFocus? focus,
  required int hour,
  required bool reliefDone,
  required bool brainDone,
  required bool isPremium,
  required MeditationContent suggestedMeditation,
}) {
  if (need != null) {
    return switch (need) {
      _HomeNeed.calm => const _HomeRecommendation(
          eyebrow: 'SUGGESTED FOR CALM',
          title: 'Back to the Room',
          description:
              'Use your senses to reconnect with what is actually around you.',
          reason: 'You chose calm down.',
          meta: '3 min • Free • Grounding',
          route: '/relief/session/back-to-room',
          artwork: ReleafArtworkVariant.grounding,
          icon: Icons.explore_outlined,
        ),
      _HomeNeed.clearMind => const _HomeRecommendation(
          eyebrow: 'SUGGESTED FOR A BUSY MIND',
          title: 'Name the Thought',
          description:
              'Create a little distance from a thought that keeps pulling you back in.',
          reason: 'You chose clear my head.',
          meta: '2 min • Free • Mind',
          route: '/relief/session/name-the-thought',
          artwork: ReleafArtworkVariant.focus,
          icon: Icons.blur_on_rounded,
        ),
      _HomeNeed.focus => const _HomeRecommendation(
          eyebrow: 'SUGGESTED FOR FOCUS',
          title: 'Daily Brain Workout',
          description:
              'Move into a short, deliberate cognitive training set.',
          reason: 'You chose focus.',
          meta: 'Memory • Spatial • Calculation',
          route: AppRoutes.brain,
          artwork: ReleafArtworkVariant.lifeUpgrade,
          icon: Icons.extension_outlined,
        ),
      _HomeNeed.windDown => const _HomeRecommendation(
          eyebrow: 'SUGGESTED FOR WINDING DOWN',
          title: 'Tonight',
          description:
              'Reduce stimulation and choose a calmer path into the evening.',
          reason: 'You chose wind down.',
          meta: 'Sleep • Reset • Sound',
          route: AppRoutes.sleep,
          artwork: ReleafArtworkVariant.ambient,
          icon: Icons.bedtime_outlined,
          warm: true,
        ),
    };
  }

  if (hour >= 20 || hour < 5) {
    if (!isPremium) {
      return _HomeRecommendation(
        eyebrow: 'SUGGESTED NOW',
        title: 'Let the Day Go',
        description:
            'A free night practice for setting down unfinished tasks and moving into a quieter part of the day.',
        reason: 'Suggested from the time of day.',
        meta: '6 min • Free • Sleep meditation',
        route: AppRoutes.meditationSessionFor('let-the-day-go-6'),
        artwork: ReleafArtworkVariant.ambient,
        icon: Icons.bedtime_outlined,
        warm: true,
      );
    }

    return const _HomeRecommendation(
      eyebrow: 'SUGGESTED NOW',
      title: 'Evening Unwind',
      description:
          'Set down the unfinished day and make the next part of the evening simpler.',
      reason: 'Suggested from the time of day.',
      meta: 'Sleep • 8 min protocol',
      route: AppRoutes.sleep,
      artwork: ReleafArtworkVariant.ambient,
      icon: Icons.bedtime_outlined,
      warm: true,
    );
  }

  if (focus == HomeFocus.steady && !reliefDone) {
    return const _HomeRecommendation(
      eyebrow: 'SUGGESTED FOR YOUR FOCUS',
      title: 'Back to the Room',
      description:
          'A short sensory reset before you decide what else you need.',
      reason: 'Matches your focus: Feel steadier.',
      meta: '3 min • Free • Grounding',
      route: '/relief/session/back-to-room',
      artwork: ReleafArtworkVariant.grounding,
      icon: Icons.explore_outlined,
    );
  }

  if (focus == HomeFocus.focus && !brainDone) {
    return const _HomeRecommendation(
      eyebrow: 'SUGGESTED FOR YOUR FOCUS',
      title: 'Daily Brain Workout',
      description:
          'Bring a short cognitive training set forward while it still fits your day.',
      reason: 'Matches your focus: Focus better.',
      meta: 'Memory • Spatial • Calculation',
      route: AppRoutes.brain,
      artwork: ReleafArtworkVariant.lifeUpgrade,
      icon: Icons.extension_outlined,
    );
  }

  if (focus == HomeFocus.mindfulness) {
    return _meditationRecommendation(
      item: suggestedMeditation,
      eyebrow: 'SUGGESTED FOR YOUR FOCUS',
      reason: 'Matches your focus: Build mindfulness.',
    );
  }

  if (focus == HomeFocus.sleep && hour >= 17) {
    if (isPremium) {
      return const _HomeRecommendation(
        eyebrow: 'SUGGESTED FOR YOUR FOCUS',
        title: 'Tonight',
        description:
            'Move into the full Sleep space with guided wind-down, meditation and long-form sound.',
        reason: 'Matches your focus: Sleep easier.',
        meta: 'Sleep • Guided • Sound',
        route: AppRoutes.sleep,
        artwork: ReleafArtworkVariant.ambient,
        icon: Icons.bedtime_outlined,
        warm: true,
      );
    }

    return _HomeRecommendation(
      eyebrow: 'SUGGESTED FOR YOUR FOCUS',
      title: 'Let the Day Go',
      description:
          'Use the free night practice before choosing anything longer.',
      reason: 'Matches your focus: Sleep easier.',
      meta: '6 min • Free • Sleep meditation',
      route: AppRoutes.meditationSessionFor('let-the-day-go-6'),
      artwork: ReleafArtworkVariant.ambient,
      icon: Icons.bedtime_outlined,
      warm: true,
    );
  }

  if (!reliefDone) {
    return const _HomeRecommendation(
      eyebrow: 'SUGGESTED NOW',
      title: 'Back to the Room',
      description:
          'A short sensory reset before you decide what else you need.',
      reason: 'Reset is still open in today’s rhythm.',
      meta: '3 min • Free • Grounding',
      route: '/relief/session/back-to-room',
      artwork: ReleafArtworkVariant.grounding,
      icon: Icons.explore_outlined,
    );
  }

  if (!brainDone) {
    return const _HomeRecommendation(
      eyebrow: 'SUGGESTED NOW',
      title: 'Daily Brain Workout',
      description:
          'Your Reset is done. Shift into a short cognitive training set.',
      reason: 'Brain is still open in today’s rhythm.',
      meta: 'Memory • Spatial • Calculation',
      route: AppRoutes.brain,
      artwork: ReleafArtworkVariant.lifeUpgrade,
      icon: Icons.extension_outlined,
    );
  }

  return _meditationRecommendation(
    item: suggestedMeditation,
    eyebrow: 'SUGGESTED NOW',
    reason: 'Reset and Brain are already complete today.',
  );
}

MeditationContent? _recentAccessibleMeditation({
  required MeditationCatalog catalog,
  required MeditationLibraryState library,
  required bool isPremium,
}) {
  for (final id in library.recentIds) {
    final item = catalog.getById(id);
    if (item == null) continue;
    if (item.isPremium && !isPremium) continue;
    return item;
  }
  return null;
}

MeditationContent _suggestedMeditation({
  required MeditationCatalog catalog,
  required MeditationLibraryState library,
  required bool isPremium,
}) {
  bool accessible(MeditationContent item) => !item.isPremium || isPremium;

  final foundations = catalog
      .getSeries(MeditationCatalog.foundationsSeriesId)
      .where(accessible)
      .toList(growable: false);

  for (final item in foundations) {
    if (!library.isCompleted(item.id)) return item;
  }

  final available = catalog
      .getAll()
      .where(accessible)
      .where((item) => item.category != MeditationCategory.unguided)
      .toList(growable: false);

  for (final item in available) {
    if (!library.isCompleted(item.id)) return item;
  }

  if (foundations.isNotEmpty) return foundations.first;
  return available.first;
}

_HomeRecommendation _meditationRecommendation({
  required MeditationContent item,
  required String eyebrow,
  required String reason,
}) {
  final minutes = item.durationSeconds ~/ 60;
  final access = item.isPremium ? 'Premium' : 'Free';

  return _HomeRecommendation(
    eyebrow: eyebrow,
    title: item.title,
    description: item.subtitle,
    reason: reason,
    meta: '$minutes min • $access • Meditation',
    route: AppRoutes.meditationSessionFor(item.id),
    artwork: _homeArtworkForMeditation(item.category),
    icon: Icons.spa_outlined,
  );
}

ReleafArtworkVariant _homeArtworkForMeditation(MeditationCategory category) {
  return switch (category) {
    MeditationCategory.anxiety => ReleafArtworkVariant.calm,
    MeditationCategory.body => ReleafArtworkVariant.grounding,
    MeditationCategory.everyday => ReleafArtworkVariant.lifeUpgrade,
    MeditationCategory.unguided => ReleafArtworkVariant.ambient,
    MeditationCategory.startHere ||
    MeditationCategory.focus ||
    MeditationCategory.mind => ReleafArtworkVariant.focus,
  };
}

class _DailyInsightCard extends StatelessWidget {
  const _DailyInsightCard({
    required this.insight,
    required this.onOpen,
  });

  final DailyInsight insight;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final accent = _dailyInsightAccent(insight.category);
    final compact = MediaQuery.sizeOf(context).width < 360;

    return Material(
      key: const Key('home-daily-insight'),
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(ReleafRadii.extraLarge),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        borderRadius: BorderRadius.circular(ReleafRadii.extraLarge),
        onTap: onOpen,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(ReleafRadii.extraLarge),
            border: Border.all(
              color: accent.withValues(alpha: 0.24),
            ),
            boxShadow: [
              BoxShadow(
                color: accent.withValues(alpha: 0.07),
                blurRadius: 28,
                offset: const Offset(0, 14),
              ),
            ],
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: compact ? 270 : 236,
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  child: ReleafArtwork(
                    variant: _dailyInsightArtwork(insight.category),
                    intensity: 0.62,
                  ),
                ),
                const Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color(0x42070C09),
                          Color(0xA80A100D),
                          Color(0xF2070B09),
                        ],
                        stops: [0, 0.48, 1],
                      ),
                    ),
                  ),
                ),
                Padding(
                padding: const EdgeInsets.all(ReleafSpacing.lg),
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
                            color: accent.withValues(alpha: 0.12),
                            borderRadius:
                                BorderRadius.circular(ReleafRadii.pill),
                            border: Border.all(
                              color: accent.withValues(alpha: 0.24),
                            ),
                          ),
                          child: Text(
                            'DID YOU KNOW?',
                            style: ReleafTypography.eyebrow.copyWith(
                              color: accent,
                              fontSize: 8,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _dailyInsightCategoryLabel(insight.category)
                                .toUpperCase(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: ReleafTypography.eyebrow.copyWith(
                              color: ReleafColors.textSecondary,
                              fontSize: 8,
                              letterSpacing: 1.15,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 36,
                          height: 36,
                          child: IconButton(
                            key: const Key('home-daily-insight-info'),
                            tooltip: 'About today’s insight',
                            onPressed: onOpen,
                            padding: EdgeInsets.zero,
                            icon: Icon(
                              Icons.info_outline_rounded,
                              size: 19,
                              color: accent,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: compact ? 34 : 42),
                    Text(
                      insight.teaser,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: ReleafTypography.sectionTitle.copyWith(
                        fontSize: 20,
                        height: 1.28,
                        letterSpacing: -0.25,
                      ),
                    ),
                    const SizedBox(height: ReleafSpacing.sm),
                    Wrap(
                      spacing: 7,
                      runSpacing: 6,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        _DailyInsightEvidencePill(
                          label: insight.evidenceLabel,
                          accent: accent,
                        ),
                        if (!compact)
                          Text(
                            insight.sourcePublisher,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: ReleafTypography.meta.copyWith(
                              color: ReleafColors.textMuted,
                              fontSize: 9,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: ReleafSpacing.md),
                    Row(
                      children: [
                        Icon(
                          Icons.auto_stories_outlined,
                          color: accent,
                          size: 17,
                        ),
                        const SizedBox(width: 7),
                        Expanded(
                          child: Text(
                            'Reveal today’s insight',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: ReleafTypography.meta.copyWith(
                              color: ReleafColors.textPrimary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '1 min',
                          style: ReleafTypography.meta.copyWith(
                            color: ReleafColors.textMuted,
                            fontSize: 9,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Icon(
                          Icons.arrow_forward_rounded,
                          color: accent,
                          size: 17,
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

class _DailyInsightEvidencePill extends StatelessWidget {
  const _DailyInsightEvidencePill({
    required this.label,
    required this.accent,
  });

  final String label;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 180),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(ReleafRadii.pill),
        border: Border.all(
          color: accent.withValues(alpha: 0.20),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.verified_outlined,
            size: 13,
            color: accent,
          ),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: ReleafTypography.meta.copyWith(
                color: ReleafColors.textSecondary,
                fontSize: 8.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}


Future<void> _showDailyInsightSheet(
  BuildContext context,
  DailyInsight insight,
) async {
  final accent = _dailyInsightAccent(insight.category);

  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: const Color(0xFF0D1512),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (sheetContext) {
      return SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            ReleafSpacing.screen,
            ReleafSpacing.xl,
            ReleafSpacing.screen,
            ReleafSpacing.xl,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.10),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      _dailyInsightIcon(insight.category),
                      color: accent,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: ReleafSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'TODAY’S INSIGHT',
                          style: ReleafTypography.eyebrow.copyWith(
                            color: accent,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _dailyInsightCategoryLabel(insight.category),
                          style: ReleafTypography.meta.copyWith(
                            color: ReleafColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Close',
                    onPressed: () => Navigator.of(sheetContext).pop(),
                    icon: const Icon(
                      Icons.close_rounded,
                      color: ReleafColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: ReleafSpacing.lg),
              Text(
                insight.headline,
                style: ReleafTypography.sectionTitle.copyWith(
                  fontSize: 24,
                  height: 1.22,
                ),
              ),
              const SizedBox(height: ReleafSpacing.md),
              Text(
                insight.detail,
                style: ReleafTypography.body.copyWith(
                  color: ReleafColors.textPrimary.withValues(alpha: 0.84),
                  height: 1.55,
                ),
              ),
              const SizedBox(height: ReleafSpacing.lg),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(ReleafSpacing.md),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(ReleafRadii.medium),
                  border: Border.all(
                    color: accent.withValues(alpha: 0.18),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'EVIDENCE',
                      style: ReleafTypography.eyebrow.copyWith(
                        color: accent,
                        fontSize: 9,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      insight.evidenceLabel,
                      style: ReleafTypography.meta.copyWith(
                        color: ReleafColors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      insight.evidenceNote,
                      style: ReleafTypography.meta.copyWith(
                        color: ReleafColors.textSecondary,
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: ReleafSpacing.lg),
              Text(
                'SOURCE',
                style: ReleafTypography.eyebrow.copyWith(
                  color: ReleafColors.textMuted,
                  fontSize: 8.5,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                insight.sourcePublisher,
                style: ReleafTypography.meta.copyWith(
                  color: ReleafColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                insight.sourceTitle,
                style: ReleafTypography.meta.copyWith(
                  color: ReleafColors.textSecondary,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: ReleafSpacing.md),
              OutlinedButton.icon(
                key: const Key('home-daily-insight-source'),
                onPressed: () async {
                  final uri = Uri.parse(insight.sourceUrl);
                  final opened = await launchUrl(
                    uri,
                    mode: LaunchMode.externalApplication,
                  );
                  if (!opened && sheetContext.mounted) {
                    ScaffoldMessenger.of(sheetContext).showSnackBar(
                      const SnackBar(
                        content: Text('Source link could not be opened.'),
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.open_in_new_rounded, size: 17),
                label: const Text('Open original source'),
              ),
              const SizedBox(height: ReleafSpacing.md),
              Text(
                'Educational wellbeing information. Releaf does not use Daily Insights to diagnose, prescribe or replace professional care.',
                style: ReleafTypography.meta.copyWith(
                  color: ReleafColors.textMuted,
                  fontSize: 9,
                  height: 1.45,
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

String _dailyInsightCategoryLabel(DailyInsightCategory category) {
  return switch (category) {
    DailyInsightCategory.movement => 'Movement',
    DailyInsightCategory.sleep => 'Sleep',
    DailyInsightCategory.mind => 'Mind',
    DailyInsightCategory.connection => 'Connection',
    DailyInsightCategory.nutrition => 'Nutrition',
    DailyInsightCategory.nature => 'Nature',
  };
}

IconData _dailyInsightIcon(DailyInsightCategory category) {
  return switch (category) {
    DailyInsightCategory.movement => Icons.directions_walk_rounded,
    DailyInsightCategory.sleep => Icons.bedtime_outlined,
    DailyInsightCategory.mind => Icons.psychology_outlined,
    DailyInsightCategory.connection => Icons.people_alt_outlined,
    DailyInsightCategory.nutrition => Icons.wb_sunny_outlined,
    DailyInsightCategory.nature => Icons.park_outlined,
  };
}

ReleafArtworkVariant _dailyInsightArtwork(
  DailyInsightCategory category,
) {
  return switch (category) {
    DailyInsightCategory.movement => ReleafArtworkVariant.lifeUpgrade,
    DailyInsightCategory.sleep => ReleafArtworkVariant.ambient,
    DailyInsightCategory.mind => ReleafArtworkVariant.focus,
    DailyInsightCategory.connection => ReleafArtworkVariant.calm,
    DailyInsightCategory.nutrition => ReleafArtworkVariant.situational,
    DailyInsightCategory.nature => ReleafArtworkVariant.grounding,
  };
}

Color _dailyInsightAccent(DailyInsightCategory category) {
  return switch (category) {
    DailyInsightCategory.movement => const Color(0xFF9EC9AE),
    DailyInsightCategory.sleep => const Color(0xFFB8B9D7),
    DailyInsightCategory.mind => const Color(0xFFC7B6D5),
    DailyInsightCategory.connection => const Color(0xFFD3B8A6),
    DailyInsightCategory.nutrition => const Color(0xFFD4C28E),
    DailyInsightCategory.nature => const Color(0xFFAFC5A2),
  };
}

class _HomeFocusStrip extends StatelessWidget {
  const _HomeFocusStrip({
    required this.focus,
    required this.onPressed,
  });

  final HomeFocus? focus;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      key: const Key('home-focus-strip'),
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(ReleafRadii.medium),
      child: InkWell(
        borderRadius: BorderRadius.circular(ReleafRadii.medium),
        onTap: onPressed,
        child: Ink(
          padding: const EdgeInsets.symmetric(
            horizontal: ReleafSpacing.md,
            vertical: 12,
          ),
          decoration: BoxDecoration(
            color: ReleafColors.surfaceSoft.withValues(alpha: 0.56),
            borderRadius: BorderRadius.circular(ReleafRadii.medium),
            border: Border.all(color: ReleafColors.borderSoft),
          ),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: ReleafColors.sage.withValues(alpha: 0.10),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.tune_rounded,
                  size: 17,
                  color: ReleafColors.sage,
                ),
              ),
              const SizedBox(width: ReleafSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      focus == null ? 'MAKE RELEAF YOURS' : 'YOUR FOCUS',
                      style: ReleafTypography.eyebrow.copyWith(
                        color: ReleafColors.sage,
                        fontSize: 9,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      focus?.label ?? 'Personalize recommendations',
                      style: ReleafTypography.meta.copyWith(
                        color: ReleafColors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: ReleafSpacing.sm),
              Icon(
                focus == null ? Icons.arrow_forward_rounded : Icons.edit_outlined,
                size: 18,
                color: ReleafColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<void> _showHomeFocusSheet(
  BuildContext context,
  WidgetRef ref,
  HomeFocus? selected,
) async {
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: const Color(0xFF0D1512),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (sheetContext) {
      return SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            ReleafSpacing.screen,
            ReleafSpacing.xl,
            ReleafSpacing.screen,
            ReleafSpacing.xl,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'YOUR FOCUS',
                style: ReleafTypography.eyebrow.copyWith(
                  color: ReleafColors.sage,
                ),
              ),
              const SizedBox(height: ReleafSpacing.xs),
              Text(
                'What should Releaf help you with most?',
                style: ReleafTypography.sectionTitle.copyWith(fontSize: 24),
              ),
              const SizedBox(height: 6),
              Text(
                'This tunes default suggestions. Your “Right Now” choice always takes priority.',
                style: ReleafTypography.body.copyWith(
                  color: ReleafColors.textSecondary,
                ),
              ),
              const SizedBox(height: ReleafSpacing.lg),
              for (final focus in HomeFocus.values) ...[
                _HomeFocusOption(
                  focus: focus,
                  selected: focus == selected,
                  onPressed: () async {
                    await ref
                        .read(homeFocusProvider.notifier)
                        .setFocus(focus);
                    await ref
                        .read(homeIntroProvider.notifier)
                        .dismiss();
                    if (sheetContext.mounted) {
                      Navigator.of(sheetContext).pop();
                    }
                  },
                ),
                const SizedBox(height: ReleafSpacing.xs),
              ],
              if (selected != null) ...[
                const SizedBox(height: ReleafSpacing.sm),
                TextButton(
                  onPressed: () async {
                    await ref.read(homeFocusProvider.notifier).setFocus(null);
                    if (sheetContext.mounted) {
                      Navigator.of(sheetContext).pop();
                    }
                  },
                  child: const Text('Use Releaf without a saved focus'),
                ),
              ],
            ],
          ),
        ),
      );
    },
  );
}

class _HomeFocusOption extends StatelessWidget {
  const _HomeFocusOption({
    required this.focus,
    required this.selected,
    required this.onPressed,
  });

  final HomeFocus focus;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final icon = switch (focus) {
      HomeFocus.steady => Icons.waves_rounded,
      HomeFocus.focus => Icons.center_focus_strong_rounded,
      HomeFocus.mindfulness => Icons.spa_outlined,
      HomeFocus.sleep => Icons.bedtime_outlined,
    };

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(ReleafRadii.medium),
      child: InkWell(
        key: Key('home-focus-${focus.name}'),
        onTap: onPressed,
        borderRadius: BorderRadius.circular(ReleafRadii.medium),
        child: Ink(
          padding: const EdgeInsets.all(ReleafSpacing.md),
          decoration: BoxDecoration(
            color: selected
                ? ReleafColors.sage.withValues(alpha: 0.10)
                : ReleafColors.surfaceSoft.withValues(alpha: 0.72),
            borderRadius: BorderRadius.circular(ReleafRadii.medium),
            border: Border.all(
              color: selected
                  ? ReleafColors.sage.withValues(alpha: 0.42)
                  : ReleafColors.borderSoft,
            ),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: selected
                    ? ReleafColors.sage
                    : ReleafColors.textSecondary,
              ),
              const SizedBox(width: ReleafSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      focus.label,
                      style: ReleafTypography.meta.copyWith(
                        color: ReleafColors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      focus.description,
                      style: ReleafTypography.meta.copyWith(
                        color: ReleafColors.textSecondary,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              if (selected) ...[
                const SizedBox(width: ReleafSpacing.sm),
                const Icon(
                  Icons.check_circle_rounded,
                  size: 19,
                  color: ReleafColors.sage,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _RecommendationHero extends StatelessWidget {
  const _RecommendationHero({
    required this.recommendation,
    required this.onPressed,
  });

  final _HomeRecommendation recommendation;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return ReleafPressableCard(
      key: const Key('home-recommendation-card'),
      onPressed: onPressed,
      warmAccent: recommendation.warm,
      padding: EdgeInsets.zero,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 360;
          final accent = recommendation.warm
              ? ReleafColors.premium
              : ReleafColors.sage;

          final startButton = FilledButton.icon(
            onPressed: onPressed,
            icon: const Icon(Icons.play_arrow_rounded),
            label: const Text('Start'),
            style: FilledButton.styleFrom(
              backgroundColor: accent,
              foregroundColor: ReleafColors.background,
              minimumSize: Size(
                compact ? double.infinity : 0,
                ReleafControlSizes.standard,
              ),
            ),
          );

          final reason = Text(
            recommendation.reason,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: compact ? TextAlign.center : TextAlign.start,
            style: ReleafTypography.meta.copyWith(
              color: ReleafColors.textMuted,
            ),
          );

          return SizedBox(
            height: compact ? 374 : 318,
            child: Stack(
              fit: StackFit.expand,
              children: [
                ReleafArtwork(variant: recommendation.artwork),
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0x08000000),
                        Color(0x34000000),
                        Color(0xEF000000),
                      ],
                      stops: [0, 0.50, 1],
                    ),
                  ),
                ),
                Positioned(
                  top: compact ? ReleafSpacing.lg : ReleafSpacing.xl,
                  left: compact ? ReleafSpacing.lg : ReleafSpacing.xl,
                  right: compact ? ReleafSpacing.lg : ReleafSpacing.xl,
                  child: Text(
                    recommendation.eyebrow,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: ReleafTypography.eyebrow.copyWith(
                      color: accent,
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
                        recommendation.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: ReleafTypography.display.copyWith(
                          fontSize: compact ? 25 : 28,
                          letterSpacing: -0.7,
                        ),
                      ),
                      const SizedBox(height: ReleafSpacing.xs),
                      Text(
                        recommendation.description,
                        maxLines: compact ? 3 : 2,
                        overflow: TextOverflow.ellipsis,
                        style: ReleafTypography.body.copyWith(
                          color: ReleafColors.textPrimary.withValues(
                            alpha: 0.80,
                          ),
                        ),
                      ),
                      const SizedBox(height: ReleafSpacing.sm),
                      Row(
                        children: [
                          Icon(
                            recommendation.icon,
                            size: 15,
                            color: ReleafColors.textSecondary,
                          ),
                          const SizedBox(width: 7),
                          Expanded(
                            child: Text(
                              recommendation.meta,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: ReleafTypography.meta.copyWith(
                                color: ReleafColors.textSecondary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: ReleafSpacing.md),
                      if (compact)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            startButton,
                            const SizedBox(height: ReleafSpacing.xs),
                            reason,
                          ],
                        )
                      else
                        Row(
                          children: [
                            startButton,
                            const SizedBox(width: ReleafSpacing.md),
                            Expanded(child: reason),
                          ],
                        ),
                    ],
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

class _ContinueCard extends StatelessWidget {
  const _ContinueCard({
    required this.eyebrow,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onPressed,
  });

  final String eyebrow;
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return ReleafPressableCard(
      key: const Key('home-continue-card'),
      onPressed: onPressed,
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: ReleafColors.sage.withValues(alpha: 0.10),
              border: Border.all(
                color: ReleafColors.sage.withValues(alpha: 0.24),
              ),
            ),
            alignment: Alignment.center,
            child: Icon(icon, color: ReleafColors.sage),
          ),
          const SizedBox(width: ReleafSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  eyebrow,
                  style: ReleafTypography.eyebrow.copyWith(fontSize: 9),
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: ReleafTypography.cardTitle,
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: ReleafTypography.meta.copyWith(
                    color: ReleafColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right_rounded,
            color: ReleafColors.textSecondary,
          ),
        ],
      ),
    );
  }
}

class _DailyEssentials extends StatelessWidget {
  const _DailyEssentials({
    required this.brainDone,
    required this.onBrain,
    required this.onTonight,
  });

  final bool brainDone;
  final VoidCallback onBrain;
  final VoidCallback onTonight;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final sideBySide = constraints.maxWidth >= 620;

        final brain = _EditorialShortcut(
          key: const Key('home-daily-brain'),
          eyebrow: brainDone ? 'DONE TODAY' : 'DAILY BRAIN',
          title: brainDone ? 'Brain complete' : 'Train your mind',
          subtitle: brainDone
              ? 'Your Brain reward is already counted today.'
              : 'Open the focused 3-game workout.',
          onPressed: onBrain,
          child: const ReleafBrainArtwork(
            variant: ReleafBrainArtworkVariant.hero,
          ),
        );

        final tonight = _EditorialShortcut(
          key: const Key('home-tonight'),
          eyebrow: 'TONIGHT',
          title: 'Wind down',
          subtitle: 'Sleep resets and Sound Space in one place.',
          warm: true,
          onPressed: onTonight,
          child: const ReleafArtwork(
            variant: ReleafArtworkVariant.ambient,
          ),
        );

        if (sideBySide) {
          return Row(
            children: [
              Expanded(child: brain),
              const SizedBox(width: ReleafSpacing.sm),
              Expanded(child: tonight),
            ],
          );
        }

        return Column(
          children: [
            brain,
            const SizedBox(height: ReleafSpacing.sm),
            tonight,
          ],
        );
      },
    );
  }
}

class _EditorialShortcut extends StatelessWidget {
  const _EditorialShortcut({
    super.key,
    required this.eyebrow,
    required this.title,
    required this.subtitle,
    required this.child,
    required this.onPressed,
    this.warm = false,
  });

  final String eyebrow;
  final String title;
  final String subtitle;
  final Widget child;
  final VoidCallback onPressed;
  final bool warm;

  @override
  Widget build(BuildContext context) {
    return ReleafPressableCard(
      onPressed: onPressed,
      warmAccent: warm,
      padding: EdgeInsets.zero,
      child: SizedBox(
        height: 220,
        child: Stack(
          fit: StackFit.expand,
          children: [
            child,
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0x0A000000),
                    Color(0x4C000000),
                    Color(0xEF000000),
                  ],
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
                      color: warm
                          ? ReleafColors.premium
                          : ReleafColors.sage,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    title,
                    style: ReleafTypography.sectionTitle.copyWith(
                      fontSize: 21,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: ReleafTypography.meta.copyWith(
                      color: ReleafColors.textPrimary.withValues(alpha: 0.72),
                      height: 1.45,
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

class _ProgressCard extends StatelessWidget {
  const _ProgressCard({
    required this.totalLeaves,
    required this.completedToday,
    required this.reliefDone,
    required this.brainDone,
  });

  final int totalLeaves;
  final int completedToday;
  final bool reliefDone;
  final bool brainDone;

  @override
  Widget build(BuildContext context) {
    return ReleafPressableCard(
      padding: const EdgeInsets.all(ReleafSpacing.lg),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 520;

          final ring = SizedBox(
            width: 94,
            height: 94,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CircularProgressIndicator(
                  value: completedToday / 2,
                  strokeWidth: 6,
                  backgroundColor:
                      ReleafColors.borderSoft.withValues(alpha: 0.55),
                  valueColor: const AlwaysStoppedAnimation(
                    ReleafColors.sage,
                  ),
                ),
                Center(
                  child: Text(
                    '$completedToday/2',
                    style: ReleafTypography.sectionTitle.copyWith(
                      fontSize: 18,
                    ),
                  ),
                ),
              ],
            ),
          );

          final details = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'TODAY',
                style: ReleafTypography.eyebrow.copyWith(
                  color: ReleafColors.sage,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                'Your daily rhythm',
                style: ReleafTypography.sectionTitle.copyWith(fontSize: 22),
              ),
              const SizedBox(height: 5),
              Text(
                '$totalLeaves Leaves collected',
                style: ReleafTypography.meta.copyWith(
                  color: ReleafColors.textSecondary,
                ),
              ),
              const SizedBox(height: ReleafSpacing.md),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _ProgressPill(label: 'Reset', done: reliefDone),
                  _ProgressPill(label: 'Brain', done: brainDone),
                ],
              ),
            ],
          );

          if (compact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                details,
                const SizedBox(height: ReleafSpacing.lg),
                Align(alignment: Alignment.centerLeft, child: ring),
              ],
            );
          }

          return Row(
            children: [
              Expanded(child: details),
              const SizedBox(width: ReleafSpacing.xl),
              ring,
            ],
          );
        },
      ),
    );
  }
}

class _ProgressPill extends StatelessWidget {
  const _ProgressPill({
    required this.label,
    required this.done,
  });

  final String label;
  final bool done;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(ReleafRadii.pill),
        color: done
            ? ReleafColors.sage.withValues(alpha: 0.12)
            : ReleafColors.surfaceSoft,
        border: Border.all(
          color: done
              ? ReleafColors.sage.withValues(alpha: 0.30)
              : ReleafColors.borderSoft,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            done ? Icons.check_rounded : Icons.circle_outlined,
            size: 14,
            color: done ? ReleafColors.sage : ReleafColors.textMuted,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: ReleafTypography.meta.copyWith(
              color: done
                  ? ReleafColors.textPrimary
                  : ReleafColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
