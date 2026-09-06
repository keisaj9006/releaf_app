import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../features/brain/presentation/widgets/brain_difficulty_selector.dart';
import '../../theme/app_theme.dart';
import '../../theme/releaf_design_tokens.dart';
import '../../theme/widgets/releaf_brain_artwork.dart';

class SignalScanScreen extends StatefulWidget {
  const SignalScanScreen({
    super.key,
    this.onFinish,
    this.trainingLevel = 1,
  });

  final ValueChanged<int?>? onFinish;
  final int trainingLevel;

  @override
  State<SignalScanScreen> createState() => _SignalScanScreenState();
}

class _SignalScanScreenState extends State<SignalScanScreen> {
  static const _accent = Color(0xFF69C1B8);

  BrainDifficulty _difficulty = BrainDifficulty.medium;
  int _round = 0;
  int _score = 0;
  int? _wrongIndex;
  bool _finished = false;

  int get _levelIndex => (widget.trainingLevel - 1).clamp(0, 11).toInt();

  BrainDifficulty get _effectiveDifficulty {
    final pressureRound = _round + (_levelIndex ~/ 3);
    if (_difficulty == BrainDifficulty.easy && pressureRound >= 4) {
      return BrainDifficulty.medium;
    }
    if (_difficulty == BrainDifficulty.medium && pressureRound >= 4) {
      return BrainDifficulty.hard;
    }
    return _difficulty;
  }

  int get _gridSize {
    final base = switch (_effectiveDifficulty) {
      BrainDifficulty.easy => _round < 2 ? 4 : 5,
      BrainDifficulty.medium => _round < 3 ? 5 : 6,
      BrainDifficulty.hard => _round < 4 ? 6 : 7,
    };
    return (base + (_levelIndex ~/ 4)).clamp(4, 8).toInt();
  }

  int get _totalRounds {
    final base = switch (_difficulty) {
      BrainDifficulty.easy => 6,
      BrainDifficulty.medium => 8,
      BrainDifficulty.hard => 10,
    };
    return base + (_levelIndex ~/ 2);
  }

  double get _symbolSize {
    final base = _gridSize >= 6 ? 21.0 : 27.0;
    return (base - (_levelIndex * 0.55)).clamp(14.0, 27.0).toDouble();
  }

  int get _multiplier => switch (_effectiveDifficulty) {
        BrainDifficulty.easy => 1,
        BrainDifficulty.medium => 2,
        BrainDifficulty.hard => 3,
      };

  _ScanSet get _set => switch (_effectiveDifficulty) {
        BrainDifficulty.easy => const _ScanSet(
            target: '●',
            distractors: ['○', '■', '▲'],
          ),
        BrainDifficulty.medium => const _ScanSet(
            target: '◇',
            distractors: ['◆', '□', '○', '△'],
          ),
        BrainDifficulty.hard => const _ScanSet(
            target: '↗',
            distractors: ['→', '↑', '↖', '↘', '↙'],
          ),
      };

  int get _targetIndex {
    final count = _gridSize * _gridSize;
    return (_round * 7 + 3 + _effectiveDifficulty.index * 2) % count;
  }

  String _symbolFor(int index) {
    if (index == _targetIndex) return _set.target;
    final distractors = _set.distractors;
    return distractors[(index * 3 + _round) % distractors.length];
  }

  void _tap(int index) {
    if (_finished) return;
    HapticFeedback.selectionClick();

    if (index != _targetIndex) {
      setState(() {
        _wrongIndex = index;
        _score = (_score - (10 * _multiplier)).clamp(0, 999999);
      });
      return;
    }

    final nextRound = _round + 1;
    setState(() {
      _wrongIndex = null;
      _score += 100 * _multiplier;
      _round = nextRound;
    });

    if (nextRound >= _totalRounds) {
      _finished = true;
      widget.onFinish?.call(_score);
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayRound = (_round + 1).clamp(1, _totalRounds);
    final gridCount = _gridSize * _gridSize;

    return Theme(
      data: AppTheme.premiumDark(),
      child: Scaffold(
        backgroundColor: ReleafColors.background,
        appBar: AppBar(
          toolbarHeight: 72,
          backgroundColor: const Color(0xEA081315),
          surfaceTintColor: Colors.transparent,
          titleSpacing: 20,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'SELECTIVE ATTENTION',
                style: ReleafTypography.eyebrow.copyWith(
                  color: _accent,
                  letterSpacing: 1.7,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Signal Scan',
                style: ReleafTypography.cardTitle.copyWith(fontSize: 17),
              ),
            ],
          ),
          actions: [
            Center(
              child: Padding(
                padding: const EdgeInsets.only(right: 4),
                child: Text(
                  'L${widget.trainingLevel}',
                  key: const Key('signal-scan-training-level'),
                  style: ReleafTypography.eyebrow.copyWith(color: _accent),
                ),
              ),
            ),
            IconButton(
              tooltip: 'Exit Signal Scan',
              onPressed: () => Navigator.of(context).maybePop(),
              icon: const Icon(Icons.close_rounded),
            ),
          ],
        ),
        body: Stack(
          children: [
            const Positioned.fill(
              child: ReleafBrainArtwork(
                variant: ReleafBrainArtworkVariant.signalScan,
                intensity: 0.44,
              ),
            ),
            const Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xC7071214),
                      Color(0xEC081214),
                      ReleafColors.background,
                    ],
                    stops: [0, 0.46, 1],
                  ),
                ),
              ),
            ),
            SafeArea(
              top: false,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(
                  ReleafSpacing.screen,
                  ReleafSpacing.md,
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
                          accent: _accent,
                          enabled: _round == 0,
                          onChanged: (value) {
                            setState(() {
                              _difficulty = value;
                              _round = 0;
                              _score = 0;
                              _wrongIndex = null;
                              _finished = false;
                            });
                          },
                        ),
                        const SizedBox(height: ReleafSpacing.md),
                        Row(
                          children: [
                            _ScanStat(
                              label: 'ROUND',
                              value: '$displayRound/$_totalRounds',
                            ),
                            const SizedBox(width: ReleafSpacing.xs),
                            _ScanStat(
                              label: 'GRID',
                              value: '$_gridSize×$_gridSize',
                            ),
                            const SizedBox(width: ReleafSpacing.xs),
                            _ScanStat(label: 'SCORE', value: '$_score'),
                          ],
                        ),
                        const SizedBox(height: ReleafSpacing.md),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: ReleafSpacing.md,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xD9101A1C),
                            borderRadius: BorderRadius.circular(
                              ReleafRadii.large,
                            ),
                            border: Border.all(
                              color: _accent.withValues(alpha: 0.18),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'FIND',
                                style: ReleafTypography.eyebrow.copyWith(
                                  color: ReleafColors.textSecondary,
                                  fontSize: 9,
                                ),
                              ),
                              const SizedBox(width: ReleafSpacing.sm),
                              Text(
                                _set.target,
                                key: const Key('signal-scan-target'),
                                style: const TextStyle(
                                  fontSize: 32,
                                  color: Color(0xFFD9FFF8),
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: ReleafSpacing.md),
                        Container(
                          key: const Key('signal-scan-grid'),
                          padding: const EdgeInsets.all(ReleafSpacing.sm),
                          decoration: BoxDecoration(
                            color: const Color(0xE90D1719),
                            borderRadius:
                                BorderRadius.circular(ReleafRadii.extraLarge),
                            border: Border.all(
                              color: _accent.withValues(alpha: 0.20),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: _accent.withValues(alpha: 0.07),
                                blurRadius: 32,
                                offset: const Offset(0, 16),
                              ),
                            ],
                          ),
                          child: AspectRatio(
                            aspectRatio: 1,
                            child: GridView.builder(
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: gridCount,
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: _gridSize,
                                mainAxisSpacing: _gridSize >= 6 ? 5 : 7,
                                crossAxisSpacing: _gridSize >= 6 ? 5 : 7,
                              ),
                              itemBuilder: (context, index) {
                                final wrong = _wrongIndex == index;
                                return Semantics(
                                  button: true,
                                  label: 'Scan item ${index + 1}',
                                  child: Material(
                                    color: Colors.transparent,
                                    borderRadius: BorderRadius.circular(12),
                                    child: InkWell(
                                      key: Key('signal-scan-cell-$index'),
                                      onTap: _finished ? null : () => _tap(index),
                                      borderRadius: BorderRadius.circular(12),
                                      child: AnimatedContainer(
                                        duration: ReleafMotion.quick,
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          color: wrong
                                              ? const Color(0xFFE1A184)
                                                  .withValues(alpha: 0.14)
                                              : const Color(0xFF132022),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          border: Border.all(
                                            color: wrong
                                                ? const Color(0xFFE1A184)
                                                : _accent.withValues(alpha: 0.12),
                                          ),
                                        ),
                                        child: FittedBox(
                                          fit: BoxFit.scaleDown,
                                          child: Text(
                                            _symbolFor(index),
                                            style: TextStyle(
                                              fontSize: _symbolSize,
                                              color: wrong
                                                  ? const Color(0xFFE1A184)
                                                  : const Color(0xFFD8E9E6),
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: ReleafSpacing.md),
                        Text(
                          _wrongIndex == null
                              ? 'Find the single target as efficiently as you can.'
                              : 'That was a distractor. Keep scanning.',
                          textAlign: TextAlign.center,
                          style: ReleafTypography.body.copyWith(
                            color: _wrongIndex == null
                                ? ReleafColors.textSecondary
                                : const Color(0xFFE1A184),
                          ),
                        ),
                        const SizedBox(height: ReleafSpacing.sm),
                        Text(
                          'Difficulty increases grid size and makes distractors more visually similar to the target.',
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

class _ScanSet {
  const _ScanSet({
    required this.target,
    required this.distractors,
  });

  final String target;
  final List<String> distractors;
}

class _ScanStat extends StatelessWidget {
  const _ScanStat({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xC9101A1C),
          borderRadius: BorderRadius.circular(ReleafRadii.medium),
          border: Border.all(
            color: const Color(0xFF69C1B8).withValues(alpha: 0.15),
          ),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: ReleafTypography.meta.copyWith(
                color: ReleafColors.textMuted,
                fontSize: 8,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: ReleafTypography.cardTitle.copyWith(fontSize: 15),
            ),
          ],
        ),
      ),
    );
  }
}
