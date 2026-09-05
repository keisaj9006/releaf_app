import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/session/session_manager.dart';
import '../../routing/app_routes.dart';
import '../../theme/app_theme.dart';
import '../../theme/releaf_design_tokens.dart';
import '../../theme/widgets/releaf_artwork.dart';
import '../../theme/widgets/releaf_brain_artwork.dart';
import '../../theme/widgets/releaf_components.dart';
import '../progress/data/leaves_repository.dart';
import '../sound/application/sound_player_controller.dart';
import '../sound/data/sound_catalog.dart';

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
    final currentSound = soundCatalog.getById(soundState.currentTrackId ?? '');

    final now = DateTime.now();
    final recommendation = _recommendationFor(
      need: _selectedNeed,
      hour: now.hour,
      reliefDone: leaves.reliefDone,
      brainDone: leaves.brainDone,
    );

    final completedToday = [
      leaves.reliefDone,
      leaves.habitDone,
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
                              _HomeHeader(hour: now.hour),
                              const SizedBox(height: ReleafSpacing.xxl),
                              const ReleafSectionHeading(
                                title: 'Right Now',
                                description: 'What would help most in this moment?',
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
                                selectedNeed: _selectedNeed,
                                onPressed: () =>
                                    context.push(recommendation.route),
                              ),
                              if (activeSession.hasActive ||
                                  currentSound != null) ...[
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
                                habitDone: leaves.habitDone,
                                brainDone: leaves.brainDone,
                                onHabit: () => context.push(AppRoutes.habits),
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

class _HomeHeader extends StatelessWidget {
  const _HomeHeader({required this.hour});

  final int hour;

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
          child: const Icon(
            Icons.eco_outlined,
            color: ReleafColors.sage,
            size: 25,
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
    return LayoutBuilder(
      builder: (context, constraints) {
        final twoColumns = constraints.maxWidth >= 520;
        final gap = ReleafSpacing.sm;
        final width = twoColumns
            ? (constraints.maxWidth - gap) / 2
            : constraints.maxWidth;

        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            _NeedCard(
              width: width,
              need: _HomeNeed.calm,
              icon: Icons.waves_rounded,
              title: 'Calm down',
              subtitle: 'Ground or slow the pace.',
              selected: selectedNeed == _HomeNeed.calm,
              onPressed: onSelected,
            ),
            _NeedCard(
              width: width,
              need: _HomeNeed.clearMind,
              icon: Icons.blur_on_rounded,
              title: 'Clear my head',
              subtitle: 'Step back from looping thoughts.',
              selected: selectedNeed == _HomeNeed.clearMind,
              onPressed: onSelected,
            ),
            _NeedCard(
              width: width,
              need: _HomeNeed.focus,
              icon: Icons.center_focus_strong_rounded,
              title: 'Focus',
              subtitle: 'Shift into deliberate attention.',
              selected: selectedNeed == _HomeNeed.focus,
              onPressed: onSelected,
            ),
            _NeedCard(
              width: width,
              need: _HomeNeed.windDown,
              icon: Icons.bedtime_outlined,
              title: 'Wind down',
              subtitle: 'Make the evening quieter.',
              selected: selectedNeed == _HomeNeed.windDown,
              onPressed: onSelected,
            ),
          ],
        );
      },
    );
  }
}

class _NeedCard extends StatelessWidget {
  const _NeedCard({
    required this.width,
    required this.need,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onPressed,
  });

  final double width;
  final _HomeNeed need;
  final IconData icon;
  final String title;
  final String subtitle;
  final bool selected;
  final ValueChanged<_HomeNeed> onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Semantics(
        button: true,
        selected: selected,
        label: '$title. $subtitle',
        child: AnimatedContainer(
          duration: ReleafMotion.standard,
          curve: ReleafMotion.entranceCurve,
          decoration: BoxDecoration(
            color: selected
                ? ReleafColors.sage.withValues(alpha: 0.10)
                : ReleafColors.surfaceSoft.withValues(alpha: 0.86),
            borderRadius: BorderRadius.circular(ReleafRadii.large),
            border: Border.all(
              color: selected
                  ? ReleafColors.sage.withValues(alpha: 0.48)
                  : ReleafColors.borderSoft,
            ),
            boxShadow: selected
                ? const [
                    BoxShadow(
                      color: ReleafColors.glowSage,
                      blurRadius: 24,
                      offset: Offset(0, 10),
                    ),
                  ]
                : null,
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(ReleafRadii.large),
            child: InkWell(
              borderRadius: BorderRadius.circular(ReleafRadii.large),
              onTap: () => onPressed(need),
              child: Padding(
                padding: const EdgeInsets.all(ReleafSpacing.md),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: ReleafColors.sage.withValues(alpha: 0.09),
                        border: Border.all(
                          color: ReleafColors.sage.withValues(alpha: 0.20),
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        icon,
                        color: ReleafColors.sage,
                        size: 21,
                      ),
                    ),
                    const SizedBox(width: ReleafSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(title, style: ReleafTypography.cardTitle),
                          const SizedBox(height: 3),
                          Text(
                            subtitle,
                            style: ReleafTypography.meta.copyWith(
                              color: ReleafColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (selected)
                      const Icon(
                        Icons.check_circle_rounded,
                        color: ReleafColors.sage,
                        size: 20,
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
  required int hour,
  required bool reliefDone,
  required bool brainDone,
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

  return const _HomeRecommendation(
    eyebrow: 'SUGGESTED NOW',
    title: 'Mindfulness Basics',
    description:
        'Two quiet minutes of noticing and returning, without trying to empty the mind.',
    reason: 'Reset and Brain are already complete today.',
    meta: '2 min • Free • Meditation',
    route: '/meditate/mindfulness-basics-2',
    artwork: ReleafArtworkVariant.focus,
    icon: Icons.spa_outlined,
  );
}

class _RecommendationHero extends StatelessWidget {
  const _RecommendationHero({
    required this.recommendation,
    required this.selectedNeed,
    required this.onPressed,
  });

  final _HomeRecommendation recommendation;
  final _HomeNeed? selectedNeed;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return ReleafPressableCard(
      key: const Key('home-recommendation-card'),
      onPressed: onPressed,
      warmAccent: recommendation.warm,
      padding: EdgeInsets.zero,
      child: SizedBox(
        height: 318,
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
            Padding(
              padding: const EdgeInsets.all(ReleafSpacing.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recommendation.eyebrow,
                    style: ReleafTypography.eyebrow.copyWith(
                      color: recommendation.warm
                          ? ReleafColors.premium
                          : ReleafColors.sage,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    recommendation.title,
                    style: ReleafTypography.display.copyWith(
                      fontSize: 28,
                      letterSpacing: -0.7,
                    ),
                  ),
                  const SizedBox(height: ReleafSpacing.xs),
                  Text(
                    recommendation.description,
                    style: ReleafTypography.body.copyWith(
                      color: ReleafColors.textPrimary.withValues(alpha: 0.80),
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
                          style: ReleafTypography.meta.copyWith(
                            color: ReleafColors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: ReleafSpacing.lg),
                  Row(
                    children: [
                      FilledButton.icon(
                        onPressed: onPressed,
                        icon: const Icon(Icons.play_arrow_rounded),
                        label: const Text('Start'),
                        style: FilledButton.styleFrom(
                          backgroundColor: recommendation.warm
                              ? ReleafColors.premium
                              : ReleafColors.sage,
                          foregroundColor: ReleafColors.background,
                        ),
                      ),
                      const SizedBox(width: ReleafSpacing.md),
                      Expanded(
                        child: Text(
                          recommendation.reason,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: ReleafTypography.meta.copyWith(
                            color: ReleafColors.textMuted,
                          ),
                        ),
                      ),
                    ],
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
    required this.habitDone,
    required this.brainDone,
    required this.onHabit,
  });

  final int totalLeaves;
  final int completedToday;
  final bool reliefDone;
  final bool habitDone;
  final bool brainDone;
  final VoidCallback onHabit;

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
                  value: completedToday / 3,
                  strokeWidth: 6,
                  backgroundColor:
                      ReleafColors.borderSoft.withValues(alpha: 0.55),
                  valueColor: const AlwaysStoppedAnimation(
                    ReleafColors.sage,
                  ),
                ),
                Center(
                  child: Text(
                    '$completedToday/3',
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
                  _ProgressPill(
                    label: 'Habit',
                    done: habitDone,
                    onPressed: habitDone ? null : onHabit,
                  ),
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
    this.onPressed,
  });

  final String label;
  final bool done;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final content = Container(
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

    if (onPressed == null) return content;

    return Semantics(
      button: true,
      label: 'Open $label',
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(ReleafRadii.pill),
        child: content,
      ),
    );
  }
}
