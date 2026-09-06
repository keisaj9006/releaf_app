import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../routing/app_routes.dart';
import '../../../theme/app_theme.dart';
import '../../../theme/releaf_design_tokens.dart';
import '../../../theme/widgets/releaf_brain_artwork.dart';
import '../application/brain_training_controller.dart';
import '../data/game_registry.dart';
import 'game_host_screen.dart';

class BrainScreen extends ConsumerWidget {
  const BrainScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final training = ref.watch(brainTrainingControllerProvider);
    final enabledGames = brainGames
        .where((game) => game.enabled && isSupportedBrainGame(game.id))
        .toList(growable: false);
    final workoutGames = _selectWorkoutGames(
      enabledGames,
      training,
    );

    return Theme(
      data: AppTheme.premiumDark(),
      child: Scaffold(
        backgroundColor: ReleafColors.background,
        body: Stack(
          children: [
            const Positioned.fill(child: _BrainBackdrop()),
            SafeArea(
              child: Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 760),
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(
                      ReleafSpacing.screen,
                      ReleafSpacing.lg,
                      ReleafSpacing.screen,
                      120,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _BrainHeader(training: training),
                        const SizedBox(height: ReleafSpacing.xxl),
                        _DailyWorkoutPanel(
                          games: workoutGames,
                          training: training,
                        ),
                        const SizedBox(height: ReleafSpacing.section),
                        const _SectionLabel(
                          eyebrow: 'THIS WEEK',
                          title: 'Build a training rhythm.',
                          description:
                              'Real activity from completed games — no invented cognitive score.',
                        ),
                        const SizedBox(height: ReleafSpacing.md),
                        _WeeklyActivity(training: training),
                        const SizedBox(height: ReleafSpacing.section),
                        const _SectionLabel(
                          eyebrow: 'TRAIN BY SKILL',
                          title: 'Choose what to practise.',
                          description:
                              'Each game targets a different task type and keeps its own visual identity.',
                        ),
                        const SizedBox(height: ReleafSpacing.md),
                        for (final group in BrainGameGroup.values) ...[
                          _SkillGroupSection(
                            group: group,
                            games: enabledGames
                                .where((game) => game.group == group)
                                .toList(growable: false),
                            training: training,
                          ),
                          if (group != BrainGameGroup.values.last)
                            const SizedBox(height: ReleafSpacing.lg),
                        ],
                        const SizedBox(height: ReleafSpacing.section),
                        const _EvidenceNote(),
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
}

class _BrainBackdrop extends StatelessWidget {
  const _BrainBackdrop();

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: const [
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF070B12),
                Color(0xFF0B1118),
                ReleafColors.background,
              ],
              stops: [0, 0.52, 1],
            ),
          ),
        ),
        CustomPaint(painter: _BrainBackdropPainter()),
      ],
    );
  }
}

class _BrainBackdropPainter extends CustomPainter {
  const _BrainBackdropPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = const Color(0xFF8D9CE8).withValues(alpha: 0.035)
      ..strokeWidth = 1;

    const step = 46.0;
    for (double x = -step; x < size.width + step; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x + 150, size.height), linePaint);
    }
    for (double y = 60; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), linePaint);
    }

    final glow = Paint()
      ..shader = const RadialGradient(
        colors: [
          Color(0x225F72D8),
          Color(0x1056B6A8),
          Colors.transparent,
        ],
        stops: [0, 0.42, 1],
      ).createShader(
        Rect.fromCircle(
          center: Offset(size.width * 0.78, size.height * 0.10),
          radius: size.width * 0.75,
        ),
      );

    canvas.drawRect(Offset.zero & size, glow);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _BrainHeader extends StatelessWidget {
  const _BrainHeader({required this.training});

  final BrainTrainingState training;

  @override
  Widget build(BuildContext context) {
    final copy = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'COGNITIVE TRAINING',
          style: ReleafTypography.eyebrow.copyWith(
            color: const Color(0xFF91A4EF),
            letterSpacing: 1.9,
          ),
        ),
        const SizedBox(height: 7),
        Text(
          'Brain',
          style: ReleafTypography.display.copyWith(fontSize: 34),
        ),
        const SizedBox(height: 6),
        Text(
          'Short, focused challenges across memory, attention, reasoning and spatial skills.',
          style: ReleafTypography.body.copyWith(
            color: ReleafColors.textSecondary,
          ),
        ),
      ],
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 360;

        if (compact) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              copy,
              const SizedBox(height: ReleafSpacing.md),
              _SevenDayBadge(
                sessions: training.sessionsLast7Days,
                compact: true,
              ),
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: copy),
            const SizedBox(width: ReleafSpacing.md),
            _SevenDayBadge(
              sessions: training.sessionsLast7Days,
              compact: false,
            ),
          ],
        );
      },
    );
  }
}

class _SevenDayBadge extends StatelessWidget {
  const _SevenDayBadge({
    required this.sessions,
    required this.compact,
  });

  final int sessions;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: compact ? null : 60,
      height: compact ? 38 : 60,
      padding: compact
          ? const EdgeInsets.symmetric(horizontal: 12)
          : EdgeInsets.zero,
      decoration: BoxDecoration(
        color: const Color(0xFF161C2B),
        borderRadius: BorderRadius.circular(compact ? 14 : 20),
        border: Border.all(
          color: const Color(0xFF91A4EF).withValues(alpha: 0.28),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7187E8).withValues(alpha: 0.12),
            blurRadius: 28,
          ),
        ],
      ),
      child: compact
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$sessions',
                  style: ReleafTypography.cardTitle.copyWith(
                    color: const Color(0xFFD8DEFF),
                  ),
                ),
                const SizedBox(width: 7),
                Flexible(
                  child: Text(
                    'SESSIONS · 7 DAYS',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: ReleafTypography.meta.copyWith(
                      color: const Color(0xFF91A4EF),
                      fontSize: 8,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.7,
                    ),
                  ),
                ),
              ],
            )
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '$sessions',
                  style: ReleafTypography.sectionTitle.copyWith(
                    color: const Color(0xFFD8DEFF),
                    fontSize: 20,
                  ),
                ),
                Text(
                  '7 DAYS',
                  style: ReleafTypography.meta.copyWith(
                    color: const Color(0xFF91A4EF),
                    fontSize: 8,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),
    );
  }
}

class _DailyWorkoutPanel extends StatelessWidget {
  const _DailyWorkoutPanel({
    required this.games,
    required this.training,
  });

  final List<BrainGameMeta> games;
  final BrainTrainingState training;

  @override
  Widget build(BuildContext context) {
    if (games.isEmpty) return const SizedBox.shrink();

    final completed = games.where((game) => training.playedToday(game.id)).length;
    final nextGame = games.firstWhere(
      (game) => !training.playedToday(game.id),
      orElse: () => games.first,
    );
    final completeForToday = completed == games.length;

    return Semantics(
      container: true,
      label:
          'Today\'s workout. $completed of ${games.length} challenges completed.',
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 430;

          return Container(
            key: const Key('brain-daily-workout-hero'),
            padding: EdgeInsets.all(
              compact ? ReleafSpacing.lg : ReleafSpacing.xl,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(ReleafRadii.extraLarge),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF1A2034),
                  Color(0xFF101B21),
                ],
              ),
              border: Border.all(
                color: const Color(0xFF8EA2F1).withValues(alpha: 0.22),
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF6479DA).withValues(alpha: 0.12),
                  blurRadius: 34,
                  offset: const Offset(0, 16),
                ),
              ],
            ),
            child: Stack(
              children: [
                const Positioned(
                  right: -30,
                  top: -54,
                  child: _WorkoutOrb(),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'TODAY\'S WORKOUT',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: ReleafTypography.eyebrow.copyWith(
                              color: const Color(0xFF9FB0F4),
                            ),
                          ),
                        ),
                        const SizedBox(width: ReleafSpacing.sm),
                        _ProgressBadge(
                          completed: completed,
                          total: games.length,
                        ),
                      ],
                    ),
                    const SizedBox(height: ReleafSpacing.lg),
                    Text(
                      completeForToday
                          ? 'Workout complete.'
                          : 'Three focused challenges.',
                      style: ReleafTypography.display.copyWith(
                        fontSize: compact ? 25 : 29,
                        letterSpacing: -0.7,
                      ),
                    ),
                    const SizedBox(height: ReleafSpacing.xs),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 500),
                      child: Text(
                        completeForToday
                            ? 'You can repeat a game or choose a different skill below.'
                            : 'A short sequence that favours skills you have used less recently.',
                        style: ReleafTypography.body.copyWith(
                          color: ReleafColors.textPrimary.withValues(alpha: 0.70),
                        ),
                      ),
                    ),
                    const SizedBox(height: ReleafSpacing.lg),
                    for (var index = 0; index < games.length; index++) ...[
                      _WorkoutStep(
                        index: index + 1,
                        game: games[index],
                        completed: training.playedToday(games[index].id),
                      ),
                      if (index != games.length - 1)
                        const SizedBox(height: ReleafSpacing.xs),
                    ],
                    const SizedBox(height: ReleafSpacing.lg),
                    SizedBox(
                      width: compact ? double.infinity : null,
                      child: FilledButton.icon(
                        key: const Key('brain-start-workout'),
                        onPressed: () => context.push(
                          AppRoutes.brainGameFor(nextGame.id),
                        ),
                        icon: Icon(
                          completeForToday
                              ? Icons.replay_rounded
                              : Icons.play_arrow_rounded,
                        ),
                        label: Text(
                          completeForToday
                              ? 'Train again'
                              : completed == 0
                                  ? 'Start workout'
                                  : 'Continue workout',
                        ),
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFFD4DBFF),
                          foregroundColor: const Color(0xFF101526),
                          minimumSize: const Size(0, 50),
                          padding: const EdgeInsets.symmetric(
                            horizontal: ReleafSpacing.lg,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(ReleafRadii.pill),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _WorkoutOrb extends StatelessWidget {
  const _WorkoutOrb();

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: SizedBox(
        width: 190,
        height: 190,
        child: CustomPaint(
          painter: _WorkoutOrbPainter(),
        ),
      ),
    );
  }
}

class _WorkoutOrbPainter extends CustomPainter {
  const _WorkoutOrbPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    for (var i = 0; i < 4; i++) {
      final radius = 24.0 + i * 22;
      canvas.drawCircle(
        center,
        radius,
        Paint()
          ..color = const Color(0xFF9AAAF0).withValues(
            alpha: 0.13 - i * 0.022,
          )
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2,
      );
    }

    final points = <Offset>[
      center + const Offset(-42, -18),
      center + const Offset(-8, -42),
      center + const Offset(34, -24),
      center + const Offset(48, 18),
      center + const Offset(3, 42),
      center + const Offset(-38, 30),
    ];

    final line = Paint()
      ..color = const Color(0xFFB6C2FF).withValues(alpha: 0.23)
      ..strokeWidth = 1;

    for (var i = 0; i < points.length; i++) {
      canvas.drawLine(points[i], points[(i + 1) % points.length], line);
      canvas.drawCircle(
        points[i],
        2.5,
        Paint()
          ..color = const Color(0xFFE2E6FF).withValues(alpha: 0.56),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ProgressBadge extends StatelessWidget {
  const _ProgressBadge({
    required this.completed,
    required this.total,
  });

  final int completed;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF0D1322).withValues(alpha: 0.74),
        borderRadius: BorderRadius.circular(ReleafRadii.pill),
        border: Border.all(
          color: const Color(0xFF9FB0F4).withValues(alpha: 0.18),
        ),
      ),
      child: Text(
        '$completed/$total',
        style: ReleafTypography.meta.copyWith(
          color: const Color(0xFFDDE3FF),
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _WorkoutStep extends StatelessWidget {
  const _WorkoutStep({
    required this.index,
    required this.game,
    required this.completed,
  });

  final int index;
  final BrainGameMeta game;
  final bool completed;

  @override
  Widget build(BuildContext context) {
    final presentation = _presentationFor(game.id);

    return Row(
      children: [
        AnimatedContainer(
          duration: ReleafMotion.standard,
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: completed
                ? presentation.accent.withValues(alpha: 0.22)
                : const Color(0xFF0D1322).withValues(alpha: 0.72),
            borderRadius: BorderRadius.circular(11),
            border: Border.all(
              color: completed
                  ? presentation.accent.withValues(alpha: 0.72)
                  : const Color(0xFF9FB0F4).withValues(alpha: 0.14),
            ),
          ),
          alignment: Alignment.center,
          child: completed
              ? Icon(
                  Icons.check_rounded,
                  size: 18,
                  color: presentation.accent,
                )
              : Text(
                  '$index',
                  style: ReleafTypography.meta.copyWith(
                    color: ReleafColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
        ),
        const SizedBox(width: ReleafSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(game.title, style: ReleafTypography.cardTitle),
              const SizedBox(height: 1),
              Text(
                presentation.skill,
                style: ReleafTypography.meta.copyWith(
                  color: presentation.accent,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({
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
            color: const Color(0xFF91A4EF),
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

class _WeeklyActivity extends StatelessWidget {
  const _WeeklyActivity({required this.training});

  final BrainTrainingState training;

  @override
  Widget build(BuildContext context) {
    final values = training.activityLast7Days;
    final days = training.activityDaysLast7Days;
    final maxValue = values.fold<int>(
      1,
      (best, value) => value > best ? value : best,
    );

    return Container(
      key: const Key('brain-weekly-activity'),
      padding: const EdgeInsets.all(ReleafSpacing.lg),
      decoration: BoxDecoration(
        color: const Color(0xFF101620).withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(ReleafRadii.large),
        border: Border.all(
          color: const Color(0xFF56647E).withValues(alpha: 0.28),
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 360;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (compact) ...[
                _ActivitySummary(training: training),
                const SizedBox(height: ReleafSpacing.lg),
                _ActivityBars(
                  values: values,
                  days: days,
                  maxValue: maxValue,
                ),
              ] else
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    SizedBox(
                      width: 150,
                      child: _ActivitySummary(training: training),
                    ),
                    const SizedBox(width: ReleafSpacing.lg),
                    Expanded(
                      child: _ActivityBars(
                        values: values,
                        days: days,
                        maxValue: maxValue,
                      ),
                    ),
                  ],
                ),
            ],
          );
        },
      ),
    );
  }
}

class _ActivitySummary extends StatelessWidget {
  const _ActivitySummary({required this.training});

  final BrainTrainingState training;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${training.sessionsLast7Days}',
          style: ReleafTypography.display.copyWith(
            fontSize: 31,
            color: const Color(0xFFDDE3FF),
          ),
        ),
        Text(
          training.sessionsLast7Days == 1
              ? 'completed session'
              : 'completed sessions',
          style: ReleafTypography.meta.copyWith(
            color: ReleafColors.textSecondary,
          ),
        ),
        if (training.totalSessions == 0) ...[
          const SizedBox(height: ReleafSpacing.xs),
          Text(
            'Your activity will appear here after your first game.',
            style: ReleafTypography.meta.copyWith(fontSize: 10),
          ),
        ] else ...[
          const SizedBox(height: ReleafSpacing.xs),
          Text(
            '${training.activeDaysLast7Days} active days · '
            '${training.distinctGamesLast7Days} skills',
            style: ReleafTypography.meta.copyWith(
              color: const Color(0xFF91A4EF),
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ],
    );
  }
}

class _ActivityBars extends StatelessWidget {
  const _ActivityBars({
    required this.values,
    required this.days,
    required this.maxValue,
  });

  final List<int> values;
  final List<DateTime> days;
  final int maxValue;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 92,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (var index = 0; index < values.length; index++) ...[
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  AnimatedContainer(
                    duration: ReleafMotion.standard,
                    height: values[index] == 0
                        ? 8
                        : 14 + 42 * (values[index] / maxValue),
                    width: 16,
                    decoration: BoxDecoration(
                      color: values[index] == 0
                          ? const Color(0xFF273042)
                          : const Color(0xFF8FA2ED),
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: values[index] == 0
                          ? null
                          : [
                              BoxShadow(
                                color: const Color(0xFF7187E8)
                                    .withValues(alpha: 0.20),
                                blurRadius: 12,
                              ),
                            ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _weekdayLabel(days[index].weekday),
                    style: ReleafTypography.meta.copyWith(
                      color: index == values.length - 1
                          ? const Color(0xFFDDE3FF)
                          : ReleafColors.textMuted,
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            if (index != values.length - 1) const SizedBox(width: 4),
          ],
        ],
      ),
    );
  }
}

class _SkillGroupSection extends StatelessWidget {
  const _SkillGroupSection({
    required this.group,
    required this.games,
    required this.training,
  });

  final BrainGameGroup group;
  final List<BrainGameMeta> games;
  final BrainTrainingState training;

  @override
  Widget build(BuildContext context) {
    if (games.isEmpty) return const SizedBox.shrink();

    final (title, description) = switch (group) {
      BrainGameGroup.memory => (
          'Memory',
          'Hold, recall and reproduce information.',
        ),
      BrainGameGroup.attention => (
          'Attention & control',
          'Filter distractions, switch rules and stay selective.',
        ),
      BrainGameGroup.reasoning => (
          'Logic & reasoning',
          'Work with calculation, patterns and changing rules.',
        ),
      BrainGameGroup.spatial => (
          'Spatial & visual',
          'Plan routes and reconstruct visual information.',
        ),
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: ReleafTypography.cardTitle.copyWith(fontSize: 16),
        ),
        const SizedBox(height: 3),
        Text(
          description,
          style: ReleafTypography.meta.copyWith(
            color: ReleafColors.textMuted,
          ),
        ),
        const SizedBox(height: ReleafSpacing.sm),
        _SkillGameGrid(
          games: games,
          training: training,
        ),
      ],
    );
  }
}

class _SkillGameGrid extends StatelessWidget {
  const _SkillGameGrid({
    required this.games,
    required this.training,
  });

  final List<BrainGameMeta> games;
  final BrainTrainingState training;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 360 ? 2 : 1;
        final gap = ReleafSpacing.sm;
        final width = columns == 1
            ? constraints.maxWidth
            : (constraints.maxWidth - gap) / 2;

        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final game in games)
              SizedBox(
                width: width,
                child: _SkillGameCard(
                  key: Key('brain-game-card-${game.id}'),
                  game: game,
                  presentation: _presentationFor(game.id),
                  bestScore: training.bestScoreFor(game.id),
                  hasCompleted: training.hasCompleted(game.id),
                  onPressed: () => context.push(
                    AppRoutes.brainGameFor(game.id),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _SkillGameCard extends StatefulWidget {
  const _SkillGameCard({
    super.key,
    required this.game,
    required this.presentation,
    required this.bestScore,
    required this.hasCompleted,
    required this.trainingLevel,
    required this.onPressed,
  });

  final BrainGameMeta game;
  final _BrainGamePresentation presentation;
  final int? bestScore;
  final bool hasCompleted;
  final int? trainingLevel;
  final VoidCallback onPressed;

  @override
  State<_SkillGameCard> createState() => _SkillGameCardState();
}

class _SkillGameCardState extends State<_SkillGameCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final reducedMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;

    return Semantics(
      button: true,
      label:
          '${widget.game.title}. ${widget.presentation.skill}. ${widget.presentation.benefit}.',
      child: AnimatedScale(
        scale: _pressed ? 0.985 : 1,
        duration: reducedMotion ? Duration.zero : ReleafMotion.quick,
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(ReleafRadii.large),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: widget.onPressed,
            onHighlightChanged: (value) => setState(() => _pressed = value),
            child: Ink(
              height: 214,
              decoration: BoxDecoration(
                color: const Color(0xFF0F151D),
                borderRadius: BorderRadius.circular(ReleafRadii.large),
                border: Border.all(
                  color: widget.presentation.accent.withValues(alpha: 0.25),
                ),
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    height: 102,
                    child: ReleafBrainArtwork(
                      variant: widget.presentation.artwork,
                      intensity: 0.78,
                    ),
                  ),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Color(0xBA0F151D),
                          Color(0xFF0F151D),
                        ],
                        stops: [0.08, 0.45, 0.72],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(ReleafSpacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: _SkillBadge(
                                label: widget.presentation.skill,
                                accent: widget.presentation.accent,
                              ),
                            ),
                            if (widget.trainingLevel != null) ...[
                              const SizedBox(width: 6),
                              _SkillBadge(
                                label:
                                    'LEVEL ${widget.trainingLevel}/$maxBrainTrainingLevel',
                                accent: widget.presentation.accent,
                              ),
                            ] else if (widget.game.hasDifficultyLevels) ...[
                              const SizedBox(width: 6),
                              _SkillBadge(
                                label: '3 LEVELS',
                                accent: ReleafColors.textSecondary,
                              ),
                            ],
                          ],
                        ),
                        const Spacer(),
                        Text(
                          widget.game.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: ReleafTypography.sectionTitle.copyWith(
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.presentation.benefit,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: ReleafTypography.meta.copyWith(
                            color: ReleafColors.textSecondary,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: ReleafSpacing.sm),
                        Row(
                          children: [
                            if (widget.bestScore != null)
                              Text(
                                'Best ${widget.bestScore}',
                                style: ReleafTypography.meta.copyWith(
                                  color: widget.presentation.accent,
                                  fontWeight: FontWeight.w700,
                                ),
                              )
                            else if (widget.hasCompleted)
                              Text(
                                'Completed',
                                style: ReleafTypography.meta.copyWith(
                                  color: widget.presentation.accent,
                                  fontWeight: FontWeight.w700,
                                ),
                              )
                            else
                              Text(
                                'Not played yet',
                                style: ReleafTypography.meta.copyWith(
                                  color: ReleafColors.textMuted,
                                ),
                              ),
                            const Spacer(),
                            Icon(
                              Icons.arrow_forward_rounded,
                              size: 18,
                              color: widget.presentation.accent,
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
    );
  }
}

class _SkillBadge extends StatelessWidget {
  const _SkillBadge({
    required this.label,
    required this.accent,
  });

  final String label;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFF090D14).withValues(alpha: 0.76),
        borderRadius: BorderRadius.circular(ReleafRadii.pill),
        border: Border.all(color: accent.withValues(alpha: 0.32)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
        child: Text(
          label,
          style: ReleafTypography.meta.copyWith(
            color: accent,
            fontSize: 9,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _EvidenceNote extends StatelessWidget {
  const _EvidenceNote();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(ReleafSpacing.md),
      decoration: BoxDecoration(
        color: const Color(0xFF0C1218),
        borderRadius: BorderRadius.circular(ReleafRadii.medium),
        border: Border.all(
          color: const Color(0xFF52606F).withValues(alpha: 0.22),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline_rounded,
            size: 18,
            color: Color(0xFF8FA2ED),
          ),
          const SizedBox(width: ReleafSpacing.sm),
          Expanded(
            child: Text(
              'Game results describe performance inside these exercises. Releaf does not present them as IQ, diagnosis or a medical measure.',
              style: ReleafTypography.meta.copyWith(
                color: ReleafColors.textSecondary,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BrainGamePresentation {
  const _BrainGamePresentation({
    required this.skill,
    required this.benefit,
    required this.artwork,
    required this.accent,
  });

  final String skill;
  final String benefit;
  final ReleafBrainArtworkVariant artwork;
  final Color accent;
}

_BrainGamePresentation _presentationFor(String gameId) {
  return switch (gameId) {
    'memory' => const _BrainGamePresentation(
        skill: 'MEMORY',
        benefit: 'Recall positions and recognise visual patterns.',
        artwork: ReleafBrainArtworkVariant.memory,
        accent: Color(0xFF91A4EF),
      ),
    'labyrinth' => const _BrainGamePresentation(
        skill: 'SPATIAL PLANNING',
        benefit: 'Navigate routes and keep spatial goals in mind.',
        artwork: ReleafBrainArtworkVariant.labyrinth,
        accent: Color(0xFF6DC8B8),
      ),
    'math_race' => const _BrainGamePresentation(
        skill: 'CALCULATION',
        benefit: 'Practise quick mental arithmetic under time pressure.',
        artwork: ReleafBrainArtworkVariant.mathRace,
        accent: Color(0xFFE3A66A),
      ),
    'broken_mirror' => const _BrainGamePresentation(
        skill: 'VISUAL RECONSTRUCTION',
        benefit: 'Rebuild a fragmented image from visual information.',
        artwork: ReleafBrainArtworkVariant.brokenMirror,
        accent: Color(0xFFD490B9),
      ),
    'rule_shift' => const _BrainGamePresentation(
        skill: 'ATTENTION SWITCHING',
        benefit:
            'Switch simple rules and respond without carrying the last one forward.',
        artwork: ReleafBrainArtworkVariant.ruleShift,
        accent: Color(0xFFB59AF4),
      ),
    'sequence_echo' => const _BrainGamePresentation(
        skill: 'WORKING MEMORY',
        benefit: 'Hold and reproduce increasingly demanding visual sequences.',
        artwork: ReleafBrainArtworkVariant.sequenceEcho,
        accent: Color(0xFF8FA8E8),
      ),
    'color_conflict' => const _BrainGamePresentation(
        skill: 'INHIBITORY CONTROL',
        benefit: 'Ignore conflicting word information and respond to ink color.',
        artwork: ReleafBrainArtworkVariant.colorConflict,
        accent: Color(0xFFE099B5),
      ),
    'pattern_logic' => const _BrainGamePresentation(
        skill: 'PATTERN REASONING',
        benefit: 'Detect repeating and interleaved rules in visual sequences.',
        artwork: ReleafBrainArtworkVariant.patternLogic,
        accent: Color(0xFFA9A0E8),
      ),
    'signal_scan' => const _BrainGamePresentation(
        skill: 'SELECTIVE ATTENTION',
        benefit: 'Find a target quickly among increasingly similar distractors.',
        artwork: ReleafBrainArtworkVariant.signalScan,
        accent: Color(0xFF69C1B8),
      ),
    _ => const _BrainGamePresentation(
        skill: 'TRAINING',
        benefit: 'A focused cognitive challenge.',
        artwork: ReleafBrainArtworkVariant.hero,
        accent: Color(0xFF91A4EF),
      ),
  };
}

List<BrainGameMeta> _selectWorkoutGames(
  List<BrainGameMeta> games,
  BrainTrainingState training,
) {
  if (games.length <= 3 || training.records.isEmpty) {
    return games.take(3).toList(growable: false);
  }

  final originalOrder = <String, int>{
    for (var index = 0; index < games.length; index++) games[index].id: index,
  };
  final sorted = [...games]
    ..sort((a, b) {
      final aLast = training.lastPlayedFor(a.id);
      final bLast = training.lastPlayedFor(b.id);

      if (aLast == null && bLast != null) return -1;
      if (aLast != null && bLast == null) return 1;
      if (aLast != null && bLast != null) {
        final recency = aLast.compareTo(bLast);
        if (recency != 0) return recency;
      }

      return originalOrder[a.id]!.compareTo(originalOrder[b.id]!);
    });

  return sorted.take(3).toList(growable: false);
}

String _weekdayLabel(int weekday) {
  return switch (weekday) {
    DateTime.monday => 'M',
    DateTime.tuesday => 'T',
    DateTime.wednesday => 'W',
    DateTime.thursday => 'T',
    DateTime.friday => 'F',
    DateTime.saturday => 'S',
    DateTime.sunday => 'S',
    _ => '',
  };
}
