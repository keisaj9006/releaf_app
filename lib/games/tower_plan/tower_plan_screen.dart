import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../features/brain/presentation/widgets/brain_difficulty_selector.dart';
import '../../theme/app_theme.dart';
import '../../theme/releaf_design_tokens.dart';

class TowerPlanScreen extends StatefulWidget {
  const TowerPlanScreen({
    super.key,
    required this.onFinish,
    this.trainingLevel = 1,
  });

  final ValueChanged<int?> onFinish;
  final int trainingLevel;

  @override
  State<TowerPlanScreen> createState() => _TowerPlanScreenState();
}

class _TowerPlanScreenState extends State<TowerPlanScreen> {
  static const _accent = Color(0xFF78D0A8);

  BrainDifficulty _difficulty = BrainDifficulty.medium;
  late List<List<int>> _pegs;

  int? _selectedPeg;
  int _moves = 0;
  int _invalidMoves = 0;
  bool _started = false;
  bool _finished = false;
  String _feedback =
      'Move the whole tower to the target peg. A larger disc can never sit on a smaller one.';

  int get _trainingLevel => widget.trainingLevel.clamp(1, 12).toInt();
  int get _levelIndex => _trainingLevel - 1;

  int get _discCount {
    final base = switch (_difficulty) {
      BrainDifficulty.easy => 3,
      BrainDifficulty.medium => 4,
      BrainDifficulty.hard => 5,
    };
    final progression = _levelIndex >= 8
        ? 1
        : _levelIndex >= 4
            ? (_difficulty == BrainDifficulty.easy ? 1 : 0)
            : 0;
    return (base + progression).clamp(3, 6).toInt();
  }

  int get _targetPeg => _trainingLevel.isEven ? 2 : 1;

  int get _optimalMoves => (math.pow(2, _discCount).toInt()) - 1;

  int get _difficultyMultiplier => switch (_difficulty) {
        BrainDifficulty.easy => 1,
        BrainDifficulty.medium => 2,
        BrainDifficulty.hard => 3,
      };

  bool get _canChangeDifficulty => !_started && !_finished;

  @override
  void initState() {
    super.initState();
    _resetPuzzle();
  }

  void _changeDifficulty(BrainDifficulty difficulty) {
    if (!_canChangeDifficulty) return;
    setState(() {
      _difficulty = difficulty;
      _resetPuzzle();
      _feedback =
          '${difficulty.label} selected. Plan a legal route before making your first move.';
    });
  }

  void _resetPuzzle() {
    _pegs = <List<int>>[
      List<int>.generate(_discCount, (index) => _discCount - index),
      <int>[],
      <int>[],
    ];
    _selectedPeg = null;
    _moves = 0;
    _invalidMoves = 0;
    _started = false;
    _finished = false;
  }

  void _tapPeg(int pegIndex) {
    if (_finished) return;

    if (_selectedPeg == null) {
      if (_pegs[pegIndex].isEmpty) {
        _registerInvalid('Choose a peg that has a disc.');
        return;
      }

      setState(() {
        _selectedPeg = pegIndex;
        _feedback = 'Now choose where to place the top disc.';
      });
      HapticFeedback.selectionClick();
      return;
    }

    final source = _selectedPeg!;
    if (source == pegIndex) {
      setState(() {
        _selectedPeg = null;
        _feedback = 'Selection cleared.';
      });
      return;
    }

    final disc = _pegs[source].last;
    final target = _pegs[pegIndex];
    final valid = target.isEmpty || target.last > disc;

    if (!valid) {
      _selectedPeg = null;
      _registerInvalid('A larger disc cannot sit on a smaller one.');
      return;
    }

    setState(() {
      _started = true;
      _pegs[source].removeLast();
      target.add(disc);
      _moves++;
      _selectedPeg = null;
      _feedback = 'Legal move. Keep planning ahead.';
    });
    HapticFeedback.selectionClick();

    if (_pegs[_targetPeg].length == _discCount) {
      _completePuzzle();
    }
  }

  void _registerInvalid(String message) {
    setState(() {
      _invalidMoves++;
      _feedback = message;
    });
    HapticFeedback.lightImpact();
  }

  void _completePuzzle() {
    if (_finished) return;
    _finished = true;
    HapticFeedback.mediumImpact();

    final efficiencyPenalty = math.max(0, _moves - _optimalMoves);
    final score = math
        .max(
          0,
          (_discCount * 70 * _difficultyMultiplier) +
              (_trainingLevel * 8) +
              180 -
              (efficiencyPenalty * 8) -
              (_invalidMoves * 14),
        )
        .toInt();

    setState(() {
      _feedback = _moves == _optimalMoves
          ? 'Optimal solution. Every move was necessary.'
          : 'Tower complete in $_moves moves. Optimal: $_optimalMoves.';
    });

    Future<void>.delayed(const Duration(milliseconds: 550), () {
      if (mounted) widget.onFinish(score);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme.premiumDark(),
      child: Scaffold(
        backgroundColor: ReleafColors.background,
        appBar: AppBar(
          toolbarHeight: 72,
          backgroundColor: const Color(0xEA0C1712),
          surfaceTintColor: Colors.transparent,
          titleSpacing: 20,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'PLANNING & PROBLEM SOLVING',
                style: ReleafTypography.eyebrow.copyWith(
                  color: _accent,
                  letterSpacing: 1.5,
                ),
              ),
              Text(
                'Tower Plan',
                style: ReleafTypography.cardTitle.copyWith(fontSize: 17),
              ),
            ],
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Center(
                child: Text(
                  'L$_trainingLevel',
                  key: const Key('tower-plan-training-level'),
                  style: ReleafTypography.meta.copyWith(
                    color: _accent,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
            IconButton(
              tooltip: 'Exit Tower Plan',
              onPressed: () => Navigator.of(context).maybePop(),
              icon: const Icon(Icons.close_rounded),
            ),
          ],
        ),
        body: Stack(
          children: [
            const Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF102018),
                      ReleafColors.background,
                      Color(0xFF060A08),
                    ],
                  ),
                ),
              ),
            ),
            SafeArea(
              top: false,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final compact = constraints.maxHeight < 700;

                  return SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.fromLTRB(
                      ReleafSpacing.screen,
                      compact ? ReleafSpacing.sm : ReleafSpacing.md,
                      ReleafSpacing.screen,
                      ReleafSpacing.xl,
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 660),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            BrainDifficultySelector(
                              value: _difficulty,
                              enabled: _canChangeDifficulty,
                              accent: _accent,
                              onChanged: _changeDifficulty,
                            ),
                            const SizedBox(height: ReleafSpacing.md),
                            Wrap(
                              spacing: ReleafSpacing.xs,
                              runSpacing: ReleafSpacing.xs,
                              children: [
                                _TowerStat(
                                  label: 'DISCS',
                                  value: '$_discCount',
                                ),
                                _TowerStat(
                                  label: 'MOVES',
                                  value: '$_moves',
                                ),
                                _TowerStat(
                                  label: 'OPTIMAL',
                                  value: '$_optimalMoves',
                                ),
                                _TowerStat(
                                  label: 'TARGET',
                                  value: 'Peg ${_targetPeg + 1}',
                                ),
                              ],
                            ),
                            SizedBox(
                              height: compact
                                  ? ReleafSpacing.md
                                  : ReleafSpacing.xl,
                            ),
                            Container(
                              key: const Key('tower-plan-board'),
                              height: compact ? 300 : 350,
                              padding: const EdgeInsets.all(ReleafSpacing.md),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Color(0xF0162920),
                                    Color(0xF00B1410),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(
                                  ReleafRadii.extraLarge,
                                ),
                                border: Border.all(
                                  color: _accent.withValues(alpha: 0.24),
                                ),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  for (var peg = 0; peg < 3; peg++) ...[
                                    if (peg > 0)
                                      const SizedBox(
                                        width: ReleafSpacing.xs,
                                      ),
                                    Expanded(
                                      child: _PegView(
                                        pegIndex: peg,
                                        discs: _pegs[peg],
                                        discCount: _discCount,
                                        selected: _selectedPeg == peg,
                                        target: _targetPeg == peg,
                                        onTap: () => _tapPeg(peg),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            const SizedBox(height: ReleafSpacing.md),
                            Text(
                              _feedback,
                              key: const Key('tower-plan-feedback'),
                              textAlign: TextAlign.center,
                              style: ReleafTypography.body.copyWith(
                                color: ReleafColors.textSecondary,
                                height: 1.45,
                              ),
                            ),
                            const SizedBox(height: ReleafSpacing.md),
                            OutlinedButton.icon(
                              key: const Key('tower-plan-restart'),
                              onPressed: () {
                                setState(() {
                                  _resetPuzzle();
                                  _feedback =
                                      'Puzzle restarted. Plan before moving.';
                                });
                              },
                              icon: const Icon(Icons.refresh_rounded),
                              label: const Text('Restart puzzle'),
                            ),
                            const SizedBox(height: ReleafSpacing.sm),
                            Text(
                              'Tower Plan practises planning legal moves toward a goal. Its score reflects this puzzle only and is not an intelligence measure.',
                              textAlign: TextAlign.center,
                              style: ReleafTypography.meta.copyWith(
                                color: ReleafColors.textMuted,
                                height: 1.45,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PegView extends StatelessWidget {
  const _PegView({
    required this.pegIndex,
    required this.discs,
    required this.discCount,
    required this.selected,
    required this.target,
    required this.onTap,
  });

  final int pegIndex;
  final List<int> discs;
  final int discCount;
  final bool selected;
  final bool target;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      key: Key('tower-plan-peg-$pegIndex'),
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(ReleafRadii.large),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            color: selected
                ? _TowerPlanScreenState._accent.withValues(alpha: 0.10)
                : const Color(0xFF101A16),
            borderRadius: BorderRadius.circular(ReleafRadii.large),
            border: Border.all(
              color: selected || target
                  ? _TowerPlanScreenState._accent.withValues(
                      alpha: selected ? 0.56 : 0.26,
                    )
                  : ReleafColors.borderSoft,
            ),
          ),
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              Positioned(
                top: 38,
                bottom: 32,
                child: Container(
                  width: 5,
                  decoration: BoxDecoration(
                    color: const Color(0xFF607E70),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
              Positioned(
                left: 10,
                right: 10,
                bottom: 28,
                child: Container(
                  height: 5,
                  decoration: BoxDecoration(
                    color: const Color(0xFF607E70),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
              Positioned(
                top: 10,
                left: 0,
                right: 0,
                child: Text(
                  target ? 'TARGET' : 'PEG ${pegIndex + 1}',
                  textAlign: TextAlign.center,
                  style: ReleafTypography.eyebrow.copyWith(
                    color: target
                        ? _TowerPlanScreenState._accent
                        : ReleafColors.textMuted,
                    fontSize: 8,
                  ),
                ),
              ),
              Positioned(
                left: 8,
                right: 8,
                bottom: 34,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (final disc in discs.reversed)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: FractionallySizedBox(
                          widthFactor:
                              (0.36 + (disc / discCount) * 0.58)
                                  .clamp(0.36, 0.94)
                                  .toDouble(),
                          child: Container(
                            key: Key('tower-plan-disc-$pegIndex-$disc'),
                            height: 22,
                            decoration: BoxDecoration(
                              color: _discColor(disc),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.16),
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
      ),
    );
  }

  Color _discColor(int disc) {
    const palette = <Color>[
      Color(0xFF9EE4C5),
      Color(0xFF7FCFAF),
      Color(0xFF64B895),
      Color(0xFF84B8D7),
      Color(0xFFC6A5D6),
      Color(0xFFD5B477),
    ];
    return palette[(disc - 1) % palette.length];
  }
}

class _TowerStat extends StatelessWidget {
  const _TowerStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xD9111A15),
        borderRadius: BorderRadius.circular(ReleafRadii.pill),
        border: Border.all(
          color: _TowerPlanScreenState._accent.withValues(alpha: 0.18),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: ReleafTypography.meta.copyWith(
              color: ReleafColors.textMuted,
              fontSize: 9,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            value,
            style: ReleafTypography.meta.copyWith(
              color: ReleafColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
