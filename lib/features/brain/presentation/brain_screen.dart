// FILE: lib/features/brain/presentation/brain_screen.dart
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../routing/app_routes.dart';
import '../../../theme/releaf_design_tokens.dart';
import '../../../theme/widgets/releaf_brain_artwork.dart';
import '../../../theme/widgets/releaf_components.dart';
import '../data/game_registry.dart';
import 'game_host_screen.dart';

class BrainScreen extends StatelessWidget {
  const BrainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final enabledGames = brainGames
        .where((game) => game.enabled && isSupportedBrainGame(game.id))
        .toList(growable: false);
    final workoutGames = enabledGames.take(3).toList(growable: false);

    return Scaffold(
      backgroundColor: ReleafColors.background,
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                ReleafSpacing.screen,
                ReleafSpacing.xl,
                ReleafSpacing.screen,
                120,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _BrainHeader(),
                  const SizedBox(height: ReleafSpacing.xxl),
                  _DailyWorkoutHero(games: workoutGames),
                  const SizedBox(height: ReleafSpacing.section),
                  const ReleafSectionHeading(
                    title: 'Your training',
                    description:
                        'Focused practice across the skills your current games actually train.',
                  ),
                  const SizedBox(height: ReleafSpacing.md),
                  const Wrap(
                    spacing: ReleafSpacing.xs,
                    runSpacing: ReleafSpacing.xs,
                    children: [
                      _TrainingAreaChip(
                        icon: Icons.grid_view_rounded,
                        label: 'Memory',
                      ),
                      _TrainingAreaChip(
                        icon: Icons.route_rounded,
                        label: 'Spatial focus',
                      ),
                      _TrainingAreaChip(
                        icon: Icons.calculate_rounded,
                        label: 'Mental calculation',
                      ),
                      _TrainingAreaChip(
                        icon: Icons.auto_fix_high_rounded,
                        label: 'Visual patterns',
                      ),
                    ],
                  ),
                  const SizedBox(height: ReleafSpacing.section),
                  const ReleafSectionHeading(
                    title: 'Games',
                    description:
                        'Choose a focused challenge. Every game below is live and playable.',
                  ),
                  const SizedBox(height: ReleafSpacing.md),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final cardWidth = math.min(
                        420.0,
                        math.max(244.0, constraints.maxWidth * 0.78),
                      );

                      return SingleChildScrollView(
                        key: const Key('brain-games-rail'),
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            for (var index = 0;
                                index < enabledGames.length;
                                index++) ...[
                              SizedBox(
                                width: cardWidth,
                                child: _BrainGameCard(
                                  key: Key(
                                    'brain-game-card-${enabledGames[index].id}',
                                  ),
                                  game: enabledGames[index],
                                  presentation:
                                      _presentationFor(enabledGames[index].id),
                                  onPressed: () => context.push(
                                    AppRoutes.brainGameFor(
                                      enabledGames[index].id,
                                    ),
                                  ),
                                ),
                              ),
                              if (index != enabledGames.length - 1)
                                const SizedBox(width: ReleafSpacing.sm),
                            ],
                            SizedBox(
                              width: math.max(
                                ReleafSpacing.screen,
                                constraints.maxWidth - cardWidth - 20,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: ReleafSpacing.lg),
                  Text(
                    'Scores and richer skill progress will appear only when they can be calculated from real persisted game history.',
                    style: ReleafTypography.meta,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BrainHeader extends StatelessWidget {
  const _BrainHeader();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Brain', style: ReleafTypography.display),
        SizedBox(height: ReleafSpacing.xs),
        Text(
          'Train your mind with focused, repeatable challenges.',
          style: ReleafTypography.body,
        ),
      ],
    );
  }
}

class _DailyWorkoutHero extends StatelessWidget {
  const _DailyWorkoutHero({required this.games});

  final List<BrainGameMeta> games;

  @override
  Widget build(BuildContext context) {
    if (games.isEmpty) return const SizedBox.shrink();

    final first = games.first;
    final reducedMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;

    return Semantics(
      container: true,
      label:
          'Daily Brain Workout. A focused three-game set using current playable games.',
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 360;
          return ClipRRect(
            borderRadius: BorderRadius.circular(ReleafRadii.extraLarge),
            child: Container(
              key: const Key('brain-daily-workout-hero'),
              height: compact ? 330 : 305,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(ReleafRadii.extraLarge),
                border: Border.all(
                  color: ReleafColors.sage.withValues(alpha: 0.18),
                ),
                boxShadow: [
                  BoxShadow(
                    color: ReleafColors.glowSage.withValues(alpha: 0.42),
                    blurRadius: 34,
                    offset: const Offset(0, 16),
                  ),
                ],
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  const ReleafBrainArtwork(
                    variant: ReleafBrainArtworkVariant.hero,
                  ),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          ReleafColors.background.withValues(alpha: 0.16),
                          ReleafColors.background.withValues(alpha: 0.88),
                        ],
                        stops: const [0.08, 0.52, 1],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(ReleafSpacing.xl),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'DAILY BRAIN WORKOUT',
                          style: ReleafTypography.eyebrow,
                        ),
                        const Spacer(),
                        Text(
                          'Train your mind today.',
                          style: ReleafTypography.display.copyWith(
                            fontSize: compact ? 27 : 30,
                          ),
                        ),
                        const SizedBox(height: ReleafSpacing.xs),
                        Text(
                          'A focused 3-game set built only from your current training library.',
                          style: ReleafTypography.body.copyWith(
                            color: ReleafColors.textPrimary.withValues(
                              alpha: 0.78,
                            ),
                          ),
                        ),
                        const SizedBox(height: ReleafSpacing.md),
                        Wrap(
                          spacing: ReleafSpacing.xs,
                          runSpacing: ReleafSpacing.xs,
                          children: [
                            for (final game in games)
                              _WorkoutGamePill(title: game.title),
                          ],
                        ),
                        const SizedBox(height: ReleafSpacing.md),
                        FilledButton.icon(
                          onPressed: () => context.push(
                            AppRoutes.brainGameFor(first.id),
                          ),
                          icon: const Icon(Icons.play_arrow_rounded, size: 20),
                          label: Text('Start with ${first.title}'),
                          style: FilledButton.styleFrom(
                            backgroundColor: ReleafColors.sage,
                            foregroundColor: ReleafColors.background,
                            minimumSize: const Size(0, 48),
                            padding: const EdgeInsets.symmetric(
                              horizontal: ReleafSpacing.lg,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                ReleafRadii.pill,
                              ),
                            ),
                            animationDuration:
                                reducedMotion ? Duration.zero : ReleafMotion.quick,
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
      ),
    );
  }
}

class _WorkoutGamePill extends StatelessWidget {
  const _WorkoutGamePill({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: ReleafColors.background.withValues(alpha: 0.50),
        borderRadius: BorderRadius.circular(ReleafRadii.pill),
        border: Border.all(
          color: ReleafColors.textPrimary.withValues(alpha: 0.12),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Text(
          title,
          style: ReleafTypography.meta.copyWith(
            color: ReleafColors.textPrimary.withValues(alpha: 0.84),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _TrainingAreaChip extends StatelessWidget {
  const _TrainingAreaChip({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Training area: $label',
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: ReleafColors.surfaceSoft,
          borderRadius: BorderRadius.circular(ReleafRadii.pill),
          border: Border.all(color: ReleafColors.borderSoft),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: ReleafSpacing.sm,
            vertical: 10,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: ReleafColors.sage),
              const SizedBox(width: 7),
              Text(
                label,
                style: ReleafTypography.meta.copyWith(
                  color: ReleafColors.textSecondary,
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

class _BrainGameCard extends StatefulWidget {
  const _BrainGameCard({
    super.key,
    required this.game,
    required this.presentation,
    required this.onPressed,
  });

  final BrainGameMeta game;
  final _BrainGamePresentation presentation;
  final VoidCallback onPressed;

  @override
  State<_BrainGameCard> createState() => _BrainGameCardState();
}

class _BrainGameCardState extends State<_BrainGameCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final reducedMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;

    return Semantics(
      button: true,
      label:
          '${widget.game.title}. ${widget.presentation.benefit}. Play game.',
      child: AnimatedScale(
        scale: _pressed ? 0.988 : 1,
        duration: reducedMotion ? Duration.zero : ReleafMotion.quick,
        curve: ReleafMotion.emphasisCurve,
        child: SizedBox(
          height: 258,
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(ReleafRadii.extraLarge),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: widget.onPressed,
              onHighlightChanged: (value) => setState(() => _pressed = value),
              child: Ink(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(ReleafRadii.extraLarge),
                  border: Border.all(
                    color: ReleafColors.borderSoft.withValues(alpha: 0.92),
                  ),
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    ReleafBrainArtwork(
                      variant: widget.presentation.artwork,
                    ),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            ReleafColors.background.withValues(alpha: 0.10),
                            ReleafColors.background.withValues(alpha: 0.94),
                          ],
                          stops: const [0.18, 0.55, 1],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(ReleafSpacing.md),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _SkillLabel(label: widget.presentation.skill),
                          const Spacer(),
                          Text(
                            widget.game.title,
                            style: ReleafTypography.sectionTitle.copyWith(
                              fontSize: 21,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            widget.presentation.benefit,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: ReleafTypography.body.copyWith(
                              color: ReleafColors.textPrimary.withValues(
                                alpha: 0.72,
                              ),
                            ),
                          ),
                          const SizedBox(height: ReleafSpacing.sm),
                          Row(
                            children: [
                              const Text(
                                'Play',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  color: ReleafColors.textPrimary,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const Spacer(),
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: ReleafColors.sage.withValues(
                                    alpha: 0.11,
                                  ),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: ReleafColors.sage.withValues(
                                      alpha: 0.24,
                                    ),
                                  ),
                                ),
                                child: const Icon(
                                  Icons.play_arrow_rounded,
                                  color: ReleafColors.sage,
                                  size: 22,
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
            ),
          ),
        ),
      ),
    );
  }
}

class _SkillLabel extends StatelessWidget {
  const _SkillLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: ReleafColors.background.withValues(alpha: 0.58),
        borderRadius: BorderRadius.circular(ReleafRadii.pill),
        border: Border.all(
          color: ReleafColors.textPrimary.withValues(alpha: 0.10),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
        child: Text(
          label,
          style: ReleafTypography.meta.copyWith(
            color: ReleafColors.textPrimary.withValues(alpha: 0.82),
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _BrainGamePresentation {
  const _BrainGamePresentation({
    required this.skill,
    required this.benefit,
    required this.artwork,
  });

  final String skill;
  final String benefit;
  final ReleafBrainArtworkVariant artwork;
}

_BrainGamePresentation _presentationFor(String gameId) {
  return switch (gameId) {
    'memory' => const _BrainGamePresentation(
        skill: 'Memory',
        benefit: 'Train recall and pattern recognition.',
        artwork: ReleafBrainArtworkVariant.memory,
      ),
    'labyrinth' => const _BrainGamePresentation(
        skill: 'Spatial focus',
        benefit: 'Strengthen spatial focus and route planning.',
        artwork: ReleafBrainArtworkVariant.labyrinth,
      ),
    'math_race' => const _BrainGamePresentation(
        skill: 'Mental calculation',
        benefit: 'Practice speed and mental calculation.',
        artwork: ReleafBrainArtworkVariant.mathRace,
      ),
    'broken_mirror' => const _BrainGamePresentation(
        skill: 'Visual patterns',
        benefit: 'Rebuild visual patterns under pressure.',
        artwork: ReleafBrainArtworkVariant.brokenMirror,
      ),
    _ => const _BrainGamePresentation(
        skill: 'Training',
        benefit: 'Focused cognitive practice.',
        artwork: ReleafBrainArtworkVariant.hero,
      ),
  };
}
