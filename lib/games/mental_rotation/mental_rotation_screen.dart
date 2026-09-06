import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../features/brain/presentation/widgets/brain_difficulty_selector.dart';
import '../../theme/app_theme.dart';
import '../../theme/releaf_design_tokens.dart';

class MentalRotationScreen extends StatefulWidget {
  const MentalRotationScreen({
    super.key,
    required this.onFinish,
    this.trainingLevel = 1,
  });

  final ValueChanged<int?> onFinish;
  final int trainingLevel;

  @override
  State<MentalRotationScreen> createState() => _MentalRotationScreenState();
}

class _MentalRotationScreenState extends State<MentalRotationScreen> {
  static const _accent = Color(0xFFE0A7D8);

  BrainDifficulty _difficulty = BrainDifficulty.medium;
  int _round = 1;
  int _correct = 0;
  int _mistakes = 0;
  bool _locked = false;
  String? _feedback;

  late _RotationPuzzle _puzzle;

  int get _trainingLevel => widget.trainingLevel.clamp(1, 12).toInt();
  int get _levelIndex => _trainingLevel - 1;

  int get _gridSide {
    if (_trainingLevel >= 9) return 5;
    if (_trainingLevel >= 5) return 4;
    return 3;
  }

  int get _roundCount {
    final base = switch (_difficulty) {
      BrainDifficulty.easy => 6,
      BrainDifficulty.medium => 8,
      BrainDifficulty.hard => 10,
    };
    return base + (_levelIndex ~/ 4);
  }

  int get _filledCells {
    final base = switch (_difficulty) {
      BrainDifficulty.easy => _gridSide + 1,
      BrainDifficulty.medium => _gridSide + 2,
      BrainDifficulty.hard => _gridSide + 3,
    };
    final maxUseful = (_gridSide * _gridSide) - 2;
    return base.clamp(4, maxUseful).toInt();
  }

  int get _difficultyMultiplier => switch (_difficulty) {
        BrainDifficulty.easy => 1,
        BrainDifficulty.medium => 2,
        BrainDifficulty.hard => 3,
      };

  bool get _canChangeDifficulty => _round == 1 && _correct == 0 && _mistakes == 0;

  @override
  void initState() {
    super.initState();
    _puzzle = _buildPuzzle();
  }

  void _changeDifficulty(BrainDifficulty difficulty) {
    if (!_canChangeDifficulty || _locked) return;
    setState(() {
      _difficulty = difficulty;
      _puzzle = _buildPuzzle();
      _feedback = null;
    });
  }

  _RotationPuzzle _buildPuzzle() {
    final random = math.Random(
      2243 +
          (_trainingLevel * 1877) +
          (_difficulty.index * 4591) +
          (_round * 7919),
    );

    Set<int> left = const <int>{};
    for (var attempt = 0; attempt < 100; attempt++) {
      final cells = <int>{};
      while (cells.length < _filledCells) {
        cells.add(random.nextInt(_gridSide * _gridSide));
      }

      if (!_isMirrorRotationEquivalent(cells, _gridSide)) {
        left = cells;
        break;
      }

      left = cells;
    }

    if (_isMirrorRotationEquivalent(left, _gridSide)) {
      left = _fallbackAsymmetricPattern(_gridSide);
    }

    final sameUnderRotation =
        (_round + _trainingLevel + _difficulty.index).isEven;
    final turns = random.nextInt(4);
    final transformed = sameUnderRotation
        ? _rotate(left, _gridSide, turns)
        : _rotate(_mirror(left, _gridSide), _gridSide, turns);

    return _RotationPuzzle(
      left: left,
      right: transformed,
      sameUnderRotation: sameUnderRotation,
    );
  }

  Set<int> _fallbackAsymmetricPattern(int side) {
    final candidates = <int>{
      0,
      1,
      side + 1,
      (side * 2) + 1,
      (side * 2) + 2,
    }.where((index) => index < side * side).toSet();

    if (!_isMirrorRotationEquivalent(candidates, side)) {
      return candidates;
    }

    return <int>{
      0,
      side,
      side + 1,
      (side * 2) + 1,
    }.where((index) => index < side * side).toSet();
  }

  bool _isMirrorRotationEquivalent(Set<int> pattern, int side) {
    final mirrored = _mirror(pattern, side);
    for (var turns = 0; turns < 4; turns++) {
      if (_sameSet(pattern, _rotate(mirrored, side, turns))) {
        return true;
      }
    }
    return false;
  }

  Set<int> _rotate(Set<int> pattern, int side, int turns) {
    var current = Set<int>.from(pattern);
    for (var turn = 0; turn < turns; turn++) {
      current = {
        for (final index in current)
          (index % side) * side + (side - 1 - (index ~/ side)),
      };
    }
    return current;
  }

  Set<int> _mirror(Set<int> pattern, int side) {
    return {
      for (final index in pattern)
        (index ~/ side) * side + (side - 1 - (index % side)),
    };
  }

  bool _sameSet(Set<int> a, Set<int> b) =>
      a.length == b.length && a.containsAll(b);

  Future<void> _answer(bool saysSame) async {
    if (_locked) return;
    _locked = true;

    final correct = saysSame == _puzzle.sameUnderRotation;
    if (correct) {
      _correct++;
      _feedback = _puzzle.sameUnderRotation
          ? 'Correct. Rotation preserves the shape.'
          : 'Correct. You spotted the mirror reflection.';
      HapticFeedback.selectionClick();
    } else {
      _mistakes++;
      _feedback = _puzzle.sameUnderRotation
          ? 'That was the same shape after rotation.'
          : 'That version was mirrored, not only rotated.';
      HapticFeedback.lightImpact();
    }

    setState(() {});

    if (_round >= _roundCount) {
      await Future<void>.delayed(const Duration(milliseconds: 420));
      if (mounted) _completeSession();
      return;
    }

    await Future<void>.delayed(const Duration(milliseconds: 420));
    if (!mounted) return;

    setState(() {
      _round++;
      _puzzle = _buildPuzzle();
      _feedback = null;
      _locked = false;
    });
  }

  void _completeSession() {
    final attempted = math.max(1, _correct + _mistakes);
    final accuracy = _correct / attempted;
    final score = math
        .max(
          0,
          (_correct * 18 * _difficultyMultiplier) +
              (accuracy * 120).round() +
              (_trainingLevel * 7) -
              (_mistakes * 6),
        )
        .toInt();
    HapticFeedback.mediumImpact();
    widget.onFinish(score);
  }

  @override
  Widget build(BuildContext context) {
    final attempted = _correct + _mistakes;
    final accuracy = attempted == 0 ? null : (_correct / attempted * 100).round();

    return Theme(
      data: AppTheme.premiumDark(),
      child: Scaffold(
        backgroundColor: ReleafColors.background,
        appBar: AppBar(
          toolbarHeight: 72,
          backgroundColor: const Color(0xEB140E18),
          surfaceTintColor: Colors.transparent,
          titleSpacing: 20,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'SPATIAL REASONING',
                style: ReleafTypography.eyebrow.copyWith(
                  color: _accent,
                  letterSpacing: 1.6,
                ),
              ),
              Text(
                'Mental Rotation',
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
                  key: const Key('mental-rotation-training-level'),
                  style: ReleafTypography.meta.copyWith(
                    color: _accent,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
            IconButton(
              tooltip: 'Exit Mental Rotation',
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
                      Color(0xFF1C111E),
                      ReleafColors.background,
                      Color(0xFF09070A),
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
                  final narrow = constraints.maxWidth < 380;

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
                        constraints: const BoxConstraints(maxWidth: 620),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            BrainDifficultySelector(
                              value: _difficulty,
                              enabled: _canChangeDifficulty && !_locked,
                              accent: _accent,
                              onChanged: _changeDifficulty,
                            ),
                            const SizedBox(height: ReleafSpacing.md),
                            Wrap(
                              spacing: ReleafSpacing.xs,
                              runSpacing: ReleafSpacing.xs,
                              children: [
                                _RotationStat(
                                  label: 'ROUND',
                                  value: '$_round/$_roundCount',
                                ),
                                _RotationStat(
                                  label: 'GRID',
                                  value: '$_gridSide×$_gridSide',
                                ),
                                _RotationStat(
                                  label: 'ACCURACY',
                                  value: accuracy == null ? '—' : '$accuracy%',
                                ),
                              ],
                            ),
                            SizedBox(
                              height: compact
                                  ? ReleafSpacing.md
                                  : ReleafSpacing.xl,
                            ),
                            Container(
                              key: const Key('mental-rotation-puzzle'),
                              padding: EdgeInsets.all(
                                compact ? ReleafSpacing.md : ReleafSpacing.lg,
                              ),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Color(0xF0251728),
                                    Color(0xF00F1218),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(
                                  ReleafRadii.extraLarge,
                                ),
                                border: Border.all(
                                  color: _accent.withValues(alpha: 0.24),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: _accent.withValues(alpha: 0.07),
                                    blurRadius: 34,
                                    offset: const Offset(0, 16),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    'SAME UNDER ROTATION OR MIRRORED?',
                                    style: ReleafTypography.eyebrow.copyWith(
                                      color: _accent,
                                      fontSize: 9,
                                    ),
                                  ),
                                  const SizedBox(height: ReleafSpacing.lg),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _PatternGrid(
                                          prefix: 'mental-left',
                                          side: _gridSide,
                                          pattern: _puzzle.left,
                                        ),
                                      ),
                                      const Padding(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 8,
                                        ),
                                        child: Icon(
                                          Icons.compare_arrows_rounded,
                                          color: ReleafColors.textMuted,
                                        ),
                                      ),
                                      Expanded(
                                        child: _PatternGrid(
                                          prefix: 'mental-right',
                                          side: _gridSide,
                                          pattern: _puzzle.right,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: ReleafSpacing.md),
                            AnimatedSwitcher(
                              duration: ReleafMotion.quick,
                              child: Text(
                                _feedback ??
                                    'Rotation is allowed. A mirror reflection counts as different.',
                                key: ValueKey(_feedback ?? 'mental-hint'),
                                textAlign: TextAlign.center,
                                style: ReleafTypography.body.copyWith(
                                  color: _feedback == null
                                      ? ReleafColors.textSecondary
                                      : ReleafColors.textPrimary,
                                  height: 1.45,
                                ),
                              ),
                            ),
                            const SizedBox(height: ReleafSpacing.md),
                            if (narrow) ...[
                              OutlinedButton.icon(
                                key: const Key('mental-rotation-mirrored'),
                                onPressed: _locked ? null : () => _answer(false),
                                icon: const Icon(Icons.flip_rounded),
                                label: const Text('Mirrored'),
                                style: OutlinedButton.styleFrom(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 15),
                                ),
                              ),
                              const SizedBox(height: ReleafSpacing.sm),
                              FilledButton.icon(
                                key: const Key('mental-rotation-same'),
                                onPressed: _locked ? null : () => _answer(true),
                                icon: const Icon(Icons.rotate_right_rounded),
                                label: const Text('Same shape'),
                                style: FilledButton.styleFrom(
                                  backgroundColor: _accent,
                                  foregroundColor: const Color(0xFF251126),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 15),
                                ),
                              ),
                            ] else
                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      key: const Key(
                                        'mental-rotation-mirrored',
                                      ),
                                      onPressed:
                                          _locked ? null : () => _answer(false),
                                      icon: const Icon(Icons.flip_rounded),
                                      label: const Text('Mirrored'),
                                      style: OutlinedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 15,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: ReleafSpacing.sm),
                                  Expanded(
                                    child: FilledButton.icon(
                                      key: const Key('mental-rotation-same'),
                                      onPressed:
                                          _locked ? null : () => _answer(true),
                                      icon: const Icon(
                                        Icons.rotate_right_rounded,
                                      ),
                                      label: const Text('Same shape'),
                                      style: FilledButton.styleFrom(
                                        backgroundColor: _accent,
                                        foregroundColor:
                                            const Color(0xFF251126),
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 15,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            const SizedBox(height: ReleafSpacing.md),
                            Text(
                              'Mental Rotation practises comparing spatial forms across orientation changes. This score reflects task performance only and is not an IQ measure.',
                              textAlign: TextAlign.center,
                              style: ReleafTypography.meta.copyWith(
                                color: ReleafColors.textMuted,
                                fontSize: 10,
                                height: 1.45,
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

class _RotationPuzzle {
  const _RotationPuzzle({
    required this.left,
    required this.right,
    required this.sameUnderRotation,
  });

  final Set<int> left;
  final Set<int> right;
  final bool sameUnderRotation;
}

class _PatternGrid extends StatelessWidget {
  const _PatternGrid({
    required this.prefix,
    required this.side,
    required this.pattern,
  });

  final String prefix;
  final int side;
  final Set<int> pattern;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        itemCount: side * side,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: side,
          crossAxisSpacing: 4,
          mainAxisSpacing: 4,
        ),
        itemBuilder: (context, index) {
          final active = pattern.contains(index);
          return Container(
            key: Key('$prefix-$index'),
            decoration: BoxDecoration(
              color: active
                  ? _MentalRotationScreenState._accent
                  : const Color(0xFF161B22),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: active
                    ? const Color(0xFFF8E8F5)
                    : _MentalRotationScreenState._accent.withValues(alpha: 0.10),
              ),
              boxShadow: active
                  ? [
                      BoxShadow(
                        color: _MentalRotationScreenState._accent.withValues(
                          alpha: 0.18,
                        ),
                        blurRadius: 8,
                      ),
                    ]
                  : null,
            ),
          );
        },
      ),
    );
  }
}

class _RotationStat extends StatelessWidget {
  const _RotationStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xD919131D),
        borderRadius: BorderRadius.circular(ReleafRadii.pill),
        border: Border.all(
          color: _MentalRotationScreenState._accent.withValues(alpha: 0.18),
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
