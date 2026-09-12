import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../routing/app_routes.dart';
import '../../../theme/app_theme.dart';
import '../../../theme/releaf_design_tokens.dart';
import '../../../theme/widgets/releaf_brain_artwork.dart';
import '../../progress/data/leaves_repository.dart';
import '../application/brain_training_controller.dart';

class BrainGameResult {
  final String gameId;
  final int? score;

  const BrainGameResult({required this.gameId, this.score});
}

class GameResultScreen extends ConsumerStatefulWidget {
  final String? gameId;
  final int? score;
  final bool completed;

  const GameResultScreen({
    super.key,
    this.gameId,
    this.score,
    this.completed = false,
  });

  @override
  ConsumerState<GameResultScreen> createState() => _GameResultScreenState();
}

class _GameResultScreenState extends ConsumerState<GameResultScreen> {
  bool _awardHandled = false;
  String? _rewardMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _handleCompletion();
    });
  }

  Future<void> _handleCompletion() async {
    if (_awardHandled || !mounted || !widget.completed) return;
    _awardHandled = true;

    if (widget.gameId != null) {
      await ref
          .read(brainTrainingControllerProvider.notifier)
          .recordCompletion(gameId: widget.gameId!, score: widget.score);
    }

    if (!mounted) return;

    final result = await ref
        .read(leavesNotifierProvider.notifier)
        .markBrainDone();

    if (!mounted || result == null) return;

    HapticFeedback.lightImpact();

    final message = result.hasBonus
        ? '+${result.totalAdded} leaves · Perfect day bonus'
        : '+${result.totalAdded} leaves';

    setState(() {
      _rewardMessage = message;
    });
  }

  @override
  Widget build(BuildContext context) {
    final training = ref.watch(brainTrainingControllerProvider);
    final bestScore = widget.gameId == null
        ? null
        : training.bestScoreFor(widget.gameId!);
    final isPersonalBest =
        widget.score != null && bestScore != null && widget.score == bestScore;
    final trainingLevel =
        widget.gameId != null && usesProgressiveBrainLevel(widget.gameId!)
        ? training.trainingLevelFor(widget.gameId!)
        : null;
    final sessionsUntilNextLevel =
        widget.gameId != null && trainingLevel != null
        ? training.sessionsUntilNextTrainingLevelFor(widget.gameId!)
        : 0;

    return Theme(
      data: AppTheme.premiumDark(),
      child: Scaffold(
        backgroundColor: ReleafColors.background,
        body: Stack(
          children: [
            Positioned.fill(
              child: ReleafBrainArtwork(
                variant: _artworkForGame(widget.gameId),
                intensity: 0.55,
              ),
            ),
            const Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xB8070B12),
                      Color(0xE7080D12),
                      ReleafColors.background,
                    ],
                    stops: [0, 0.46, 1],
                  ),
                ),
              ),
            ),
            SafeArea(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 620),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(
                      ReleafSpacing.screen,
                      ReleafSpacing.lg,
                      ReleafSpacing.screen,
                      ReleafSpacing.xl,
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            IconButton.filledTonal(
                              tooltip: 'Back to Brain',
                              onPressed: () => context.go(AppRoutes.brain),
                              icon: const Icon(Icons.close_rounded),
                            ),
                            const Spacer(),
                            Text(
                              'BRAIN TRAINING',
                              style: ReleafTypography.eyebrow.copyWith(
                                color: const Color(0xFF9FB0F4),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 72),
                        Container(
                          width: 82,
                          height: 82,
                          decoration: BoxDecoration(
                            color: const Color(0xFF171E31),
                            borderRadius: BorderRadius.circular(28),
                            border: Border.all(
                              color: const Color(
                                0xFF9FB0F4,
                              ).withValues(alpha: 0.34),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(
                                  0xFF7187E8,
                                ).withValues(alpha: 0.20),
                                blurRadius: 34,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.check_rounded,
                            size: 38,
                            color: Color(0xFFDCE2FF),
                          ),
                        ),
                        const SizedBox(height: ReleafSpacing.lg),
                        Text(
                          widget.completed
                              ? 'Session complete'
                              : 'Training summary',
                          textAlign: TextAlign.center,
                          style: ReleafTypography.display.copyWith(
                            fontSize: 30,
                          ),
                        ),
                        const SizedBox(height: ReleafSpacing.xs),
                        Text(
                          _skillLabel(widget.gameId),
                          style: ReleafTypography.eyebrow.copyWith(
                            color: _accentForGame(widget.gameId),
                          ),
                        ),
                        const SizedBox(height: ReleafSpacing.lg),
                        Container(
                          key: const Key('brain-training-value'),
                          width: double.infinity,
                          padding: const EdgeInsets.all(ReleafSpacing.lg),
                          decoration: BoxDecoration(
                            color: const Color(0xB8121822),
                            borderRadius: BorderRadius.circular(
                              ReleafRadii.large,
                            ),
                            border: Border.all(
                              color: _accentForGame(
                                widget.gameId,
                              ).withValues(alpha: 0.18),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'WHAT YOU TRAINED',
                                style: ReleafTypography.eyebrow.copyWith(
                                  color: _accentForGame(widget.gameId),
                                  fontSize: 9,
                                ),
                              ),
                              const SizedBox(height: ReleafSpacing.xs),
                              Text(
                                _trainingBenefit(widget.gameId),
                                style: ReleafTypography.body.copyWith(
                                  color: ReleafColors.textPrimary.withValues(
                                    alpha: 0.88,
                                  ),
                                  height: 1.45,
                                ),
                              ),
                              const SizedBox(height: ReleafSpacing.xs),
                              Text(
                                _progressionNote(widget.gameId),
                                style: ReleafTypography.meta.copyWith(
                                  color: ReleafColors.textSecondary,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (widget.score != null) ...[
                          const SizedBox(height: ReleafSpacing.xxl),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(ReleafSpacing.xl),
                            decoration: BoxDecoration(
                              color: const Color(0xE9121822),
                              borderRadius: BorderRadius.circular(
                                ReleafRadii.large,
                              ),
                              border: Border.all(
                                color: _accentForGame(
                                  widget.gameId,
                                ).withValues(alpha: 0.24),
                              ),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  'GAME SCORE',
                                  style: ReleafTypography.eyebrow.copyWith(
                                    color: ReleafColors.textMuted,
                                    fontSize: 9,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  '${widget.score}',
                                  style: ReleafTypography.display.copyWith(
                                    fontSize: 44,
                                    color: const Color(0xFFF0F2FF),
                                  ),
                                ),
                                if (isPersonalBest) ...[
                                  const SizedBox(height: ReleafSpacing.xs),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.auto_awesome_rounded,
                                        size: 15,
                                        color: _accentForGame(widget.gameId),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        'Personal best',
                                        style: ReleafTypography.meta.copyWith(
                                          color: _accentForGame(widget.gameId),
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                        if (_rewardMessage != null) ...[
                          const SizedBox(height: ReleafSpacing.md),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: ReleafColors.sage.withValues(alpha: 0.10),
                              borderRadius: BorderRadius.circular(
                                ReleafRadii.pill,
                              ),
                              border: Border.all(
                                color: ReleafColors.sage.withValues(
                                  alpha: 0.22,
                                ),
                              ),
                            ),
                            child: Text(
                              _rewardMessage!,
                              style: ReleafTypography.meta.copyWith(
                                color: ReleafColors.sage,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                        if (trainingLevel != null) ...[
                          const SizedBox(height: ReleafSpacing.sm),
                          Container(
                            key: const Key('brain-next-training-level'),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 9,
                            ),
                            decoration: BoxDecoration(
                              color: _accentForGame(
                                widget.gameId,
                              ).withValues(alpha: 0.10),
                              borderRadius: BorderRadius.circular(
                                ReleafRadii.pill,
                              ),
                              border: Border.all(
                                color: _accentForGame(
                                  widget.gameId,
                                ).withValues(alpha: 0.22),
                              ),
                            ),
                            child: Text(
                              trainingLevel >=
                                      maxBrainTrainingLevelFor(widget.gameId!)
                                  ? 'TRAINING LEVEL ${maxBrainTrainingLevelFor(widget.gameId!)} · MAX'
                                  : 'TRAINING LEVEL $trainingLevel',
                              style: ReleafTypography.meta.copyWith(
                                color: _accentForGame(widget.gameId),
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          if (trainingLevel <
                              maxBrainTrainingLevelFor(widget.gameId!)) ...[
                            const SizedBox(height: ReleafSpacing.xs),
                            Text(
                              sessionsUntilNextLevel == 1
                                  ? '1 more completed session at this training level before the next step.'
                                  : '$sessionsUntilNextLevel more completed sessions at this training level before the next step.',
                              textAlign: TextAlign.center,
                              style: ReleafTypography.meta.copyWith(
                                color: ReleafColors.textSecondary,
                              ),
                            ),
                          ],
                        ],
                        const SizedBox(height: 64),
                        if (widget.gameId != null)
                          SizedBox(
                            width: double.infinity,
                            height: ReleafControlSizes.prominent,
                            child: FilledButton.icon(
                              onPressed: () => context.go(
                                AppRoutes.brainGameFor(widget.gameId!),
                              ),
                              icon: const Icon(Icons.replay_rounded),
                              label: const Text('Play again'),
                              style: FilledButton.styleFrom(
                                backgroundColor: const Color(0xFFD4DBFF),
                                foregroundColor: const Color(0xFF101526),
                              ),
                            ),
                          ),
                        if (widget.gameId != null)
                          const SizedBox(height: ReleafSpacing.sm),
                        SizedBox(
                          width: double.infinity,
                          height: ReleafControlSizes.standard,
                          child: OutlinedButton(
                            onPressed: () => context.go(AppRoutes.brain),
                            child: const Text('Back to Brain'),
                          ),
                        ),
                        const SizedBox(height: ReleafSpacing.md),
                        Text(
                          'Training levels increase task load gradually. Scores reflect performance in this game only and are not an IQ or clinical measure.',
                          textAlign: TextAlign.center,
                          style: ReleafTypography.meta.copyWith(
                            color: ReleafColors.textMuted,
                            fontSize: 10,
                          ),
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
    );
  }
}

ReleafBrainArtworkVariant _artworkForGame(String? gameId) {
  return switch (gameId) {
    'memory' => ReleafBrainArtworkVariant.memory,
    'labyrinth' => ReleafBrainArtworkVariant.labyrinth,
    'math_race' => ReleafBrainArtworkVariant.mathRace,
    'broken_mirror' => ReleafBrainArtworkVariant.brokenMirror,
    'rule_shift' => ReleafBrainArtworkVariant.ruleShift,
    'sequence_echo' => ReleafBrainArtworkVariant.sequenceEcho,
    'color_conflict' => ReleafBrainArtworkVariant.colorConflict,
    'pattern_logic' => ReleafBrainArtworkVariant.patternLogic,
    'signal_scan' => ReleafBrainArtworkVariant.signalScan,
    _ => ReleafBrainArtworkVariant.hero,
  };
}

Color _accentForGame(String? gameId) {
  return switch (gameId) {
    'memory' => const Color(0xFF91A4EF),
    'labyrinth' => const Color(0xFF6DC8B8),
    'math_race' => const Color(0xFFE3A66A),
    'broken_mirror' => const Color(0xFFD490B9),
    'rule_shift' => const Color(0xFFB59AF4),
    'sequence_echo' => const Color(0xFF8FA8E8),
    'color_conflict' => const Color(0xFFE099B5),
    'pattern_logic' => const Color(0xFFA9A0E8),
    'signal_scan' => const Color(0xFF69C1B8),
    _ => const Color(0xFF91A4EF),
  };
}

String _trainingBenefit(String? gameId) {
  return switch (gameId) {
    'memory' =>
      'Recall locations and recognise visual pairs while keeping recent information active.',
    'labyrinth' =>
      'Plan a route, monitor position and update a spatial goal as you move.',
    'math_race' =>
      'Practise mental arithmetic and response selection under limited time.',
    'broken_mirror' =>
      'Reconstruct spatial relationships from separate visual fragments.',
    'rule_shift' =>
      'Switch between simple rules without automatically carrying the previous rule forward.',
    'sequence_echo' =>
      'Hold a short visual sequence in working memory and reproduce it in order.',
    'n_back' =>
      'Continuously update working memory as each new item changes what must be compared.',
    'spatial_span' =>
      'Hold and reproduce a sequence of locations in visuospatial working memory.',
    'mental_rotation' =>
      'Compare shapes across orientation changes and distinguish rotation from reflection.',
    'trail_switch' =>
      'Scan visually while maintaining an ordered rule and switching between target types.',
    'tower_plan' =>
      'Plan several legal moves ahead while respecting constraints.',
    'symbol_code' =>
      'Use a temporary mapping key accurately across repeated decisions.',
    'color_conflict' =>
      'Inhibit a competing word response and select the relevant colour information.',
    'pattern_logic' =>
      'Detect rules across sequences and reject plausible but incorrect alternatives.',
    'signal_scan' =>
      'Select a target among increasingly similar visual distractors.',
    _ => 'Practise a focused cognitive task with repeatable feedback.',
  };
}

String _progressionNote(String? gameId) {
  return switch (gameId) {
    'labyrinth' =>
      'Later levels increase route length, turns and maze complexity rather than simply making the ball faster.',
    'broken_mirror' =>
      'Later levels add more fragments and gradually increase placement precision.',
    'rule_shift' =>
      'Later levels add more rules and shorten the time you stay with one rule before switching.',
    'sequence_echo' =>
      'Later levels lengthen sequences and reduce presentation time.',
    'n_back' =>
      'Later levels increase how far back you must compare and extend the sequence.',
    'spatial_span' =>
      'Later levels increase span length, grid size and presentation pressure.',
    'mental_rotation' =>
      'Later levels increase shape complexity and the number of comparisons.',
    'trail_switch' =>
      'Later levels lengthen the ordered trail and add stronger distractors.',
    'tower_plan' =>
      'Later levels add planning depth through larger constrained move sequences.',
    'symbol_code' =>
      'Later levels expand the mapping load, trials and competing options.',
    'color_conflict' =>
      'Later levels add colour choices and reduce the available response window.',
    'pattern_logic' =>
      'Later levels use more interacting rules, stronger distractors and fewer hints.',
    'signal_scan' =>
      'Later levels expand the grid and make distractors more similar to the target.',
    'memory' =>
      'Later levels increase the number of pairs and the amount of information to keep track of.',
    'math_race' =>
      'Later levels begin with more demanding arithmetic and continue escalating from there.',
    _ => 'Later levels gradually increase the task load.',
  };
}

String _skillLabel(String? gameId) {
  return switch (gameId) {
    'memory' => 'MEMORY',
    'labyrinth' => 'SPATIAL PLANNING',
    'math_race' => 'CALCULATION',
    'broken_mirror' => 'VISUAL RECONSTRUCTION',
    'rule_shift' => 'ATTENTION SWITCHING',
    'sequence_echo' => 'WORKING MEMORY',
    'color_conflict' => 'INHIBITORY CONTROL',
    'pattern_logic' => 'PATTERN REASONING',
    'signal_scan' => 'SELECTIVE ATTENTION',
    _ => 'COGNITIVE PRACTICE',
  };
}
