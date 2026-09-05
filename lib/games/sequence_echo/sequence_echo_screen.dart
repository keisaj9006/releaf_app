import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../features/brain/presentation/widgets/brain_difficulty_selector.dart';
import '../../theme/app_theme.dart';
import '../../theme/releaf_design_tokens.dart';
import '../../theme/widgets/releaf_brain_artwork.dart';

class SequenceEchoScreen extends StatefulWidget {
  const SequenceEchoScreen({
    super.key,
    this.onFinish,
  });

  final ValueChanged<int?>? onFinish;

  @override
  State<SequenceEchoScreen> createState() => _SequenceEchoScreenState();
}

class _SequenceEchoScreenState extends State<SequenceEchoScreen> {
  static const _accent = Color(0xFF8FA8E8);
  static const _baseSequence = <int>[
    0, 4, 8, 2, 6, 1, 7, 3, 5, 0, 8, 4, 2, 7, 1, 6, 3, 5,
  ];

  BrainDifficulty _difficulty = BrainDifficulty.easy;
  int _round = 0;
  int _score = 0;
  int? _litCell;
  int _inputIndex = 0;
  bool _showing = false;
  bool _accepting = false;
  bool _finished = false;
  String _status = 'Choose a difficulty, then watch the sequence.';

  int get _totalRounds => switch (_difficulty) {
        BrainDifficulty.easy => 5,
        BrainDifficulty.medium => 5,
        BrainDifficulty.hard => 6,
      };

  int get _sequenceLength {
    return switch (_difficulty) {
      BrainDifficulty.easy => 3 + (_round ~/ 2),
      BrainDifficulty.medium => 4 + (_round ~/ 2),
      BrainDifficulty.hard => 5 + (_round ~/ 2),
    };
  }

  int get _flashMs => switch (_difficulty) {
        BrainDifficulty.easy => 620,
        BrainDifficulty.medium => 430,
        BrainDifficulty.hard => 290,
      };

  int get _multiplier => switch (_difficulty) {
        BrainDifficulty.easy => 1,
        BrainDifficulty.medium => 2,
        BrainDifficulty.hard => 3,
      };

  List<int> get _sequence {
    final offset = (_round * 3 + _difficulty.index * 2) % _baseSequence.length;
    return List<int>.generate(
      _sequenceLength,
      (index) => _baseSequence[(offset + index) % _baseSequence.length],
      growable: false,
    );
  }

  Future<void> _showSequence() async {
    if (_showing || _accepting || _finished) return;

    setState(() {
      _showing = true;
      _inputIndex = 0;
      _status = 'Watch carefully.';
    });

    final sequence = _sequence;
    for (final cell in sequence) {
      if (!mounted) return;
      setState(() => _litCell = cell);
      HapticFeedback.selectionClick();
      await Future<void>.delayed(Duration(milliseconds: _flashMs));
      if (!mounted) return;
      setState(() => _litCell = null);
      await Future<void>.delayed(const Duration(milliseconds: 120));
    }

    if (!mounted) return;
    setState(() {
      _showing = false;
      _accepting = true;
      _status = 'Repeat the sequence.';
    });
  }

  Future<void> _tapCell(int index) async {
    if (!_accepting || _finished) return;

    final sequence = _sequence;
    final expected = sequence[_inputIndex];
    HapticFeedback.selectionClick();

    if (index != expected) {
      setState(() {
        _accepting = false;
        _inputIndex = 0;
        _score = (_score - (20 * _multiplier)).clamp(0, 999999);
        _status = 'Sequence lost. Watch it once more.';
      });
      return;
    }

    final nextIndex = _inputIndex + 1;
    if (nextIndex < sequence.length) {
      setState(() {
        _inputIndex = nextIndex;
        _status = 'Good. Keep going.';
      });
      return;
    }

    final completedRound = _round + 1;
    final nextScore = _score + (100 * _multiplier);

    setState(() {
      _accepting = false;
      _inputIndex = 0;
      _score = nextScore;
      _round = completedRound;
      _status = completedRound >= _totalRounds
          ? 'Sequence complete.'
          : 'Round complete. Ready for the next one.';
    });

    if (completedRound >= _totalRounds) {
      _finished = true;
      await Future<void>.delayed(const Duration(milliseconds: 260));
      if (!mounted) return;
      widget.onFinish?.call(_score);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentRound = (_round + 1).clamp(1, _totalRounds);
    final lockedDifficulty = _round > 0 || _showing || _accepting;

    return Theme(
      data: AppTheme.premiumDark(),
      child: Scaffold(
        backgroundColor: ReleafColors.background,
        appBar: AppBar(
          toolbarHeight: 72,
          backgroundColor: const Color(0xEA0A101A),
          surfaceTintColor: Colors.transparent,
          titleSpacing: 20,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'WORKING MEMORY',
                style: ReleafTypography.eyebrow.copyWith(
                  color: _accent,
                  letterSpacing: 1.7,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Sequence Echo',
                style: ReleafTypography.cardTitle.copyWith(fontSize: 17),
              ),
            ],
          ),
          actions: [
            IconButton(
              tooltip: 'Exit Sequence Echo',
              onPressed: () => Navigator.of(context).maybePop(),
              icon: const Icon(Icons.close_rounded),
            ),
          ],
        ),
        body: Stack(
          children: [
            const Positioned.fill(
              child: ReleafBrainArtwork(
                variant: ReleafBrainArtworkVariant.sequenceEcho,
                intensity: 0.42,
              ),
            ),
            const Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xC7080E18),
                      Color(0xEC091018),
                      ReleafColors.background,
                    ],
                    stops: [0, 0.48, 1],
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
                          enabled: !lockedDifficulty,
                          onChanged: (value) {
                            setState(() {
                              _difficulty = value;
                              _round = 0;
                              _score = 0;
                              _status =
                                  'Difficulty set to ${value.label}. Watch the sequence.';
                            });
                          },
                        ),
                        const SizedBox(height: ReleafSpacing.md),
                        Row(
                          children: [
                            _SequenceStat(
                              label: 'ROUND',
                              value: '$currentRound/$_totalRounds',
                            ),
                            const SizedBox(width: ReleafSpacing.xs),
                            _SequenceStat(
                              label: 'LENGTH',
                              value: '$_sequenceLength',
                            ),
                            const SizedBox(width: ReleafSpacing.xs),
                            _SequenceStat(
                              label: 'SCORE',
                              value: '$_score',
                            ),
                          ],
                        ),
                        const SizedBox(height: ReleafSpacing.lg),
                        Container(
                          key: const Key('sequence-echo-board'),
                          padding: const EdgeInsets.all(ReleafSpacing.md),
                          decoration: BoxDecoration(
                            color: const Color(0xE9111824),
                            borderRadius:
                                BorderRadius.circular(ReleafRadii.extraLarge),
                            border: Border.all(
                              color: _accent.withValues(alpha: 0.22),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: _accent.withValues(alpha: 0.08),
                                blurRadius: 32,
                                offset: const Offset(0, 16),
                              ),
                            ],
                          ),
                          child: AspectRatio(
                            aspectRatio: 1,
                            child: GridView.builder(
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: 9,
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                crossAxisSpacing: 10,
                                mainAxisSpacing: 10,
                              ),
                              itemBuilder: (context, index) {
                                final lit = _litCell == index;
                                return Semantics(
                                  button: true,
                                  enabled: _accepting,
                                  label: 'Sequence cell ${index + 1}',
                                  child: Material(
                                    color: Colors.transparent,
                                    borderRadius: BorderRadius.circular(20),
                                    child: InkWell(
                                      key: Key('sequence-echo-cell-$index'),
                                      onTap:
                                          _accepting ? () => _tapCell(index) : null,
                                      borderRadius: BorderRadius.circular(20),
                                      child: AnimatedContainer(
                                        duration: const Duration(
                                          milliseconds: 120,
                                        ),
                                        decoration: BoxDecoration(
                                          color: lit
                                              ? const Color(0xFFDDE7FF)
                                              : const Color(0xFF151E2D),
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          border: Border.all(
                                            color: lit
                                                ? _accent
                                                : _accent.withValues(alpha: 0.18),
                                          ),
                                          boxShadow: lit
                                              ? [
                                                  BoxShadow(
                                                    color: _accent.withValues(
                                                      alpha: 0.32,
                                                    ),
                                                    blurRadius: 24,
                                                  ),
                                                ]
                                              : null,
                                        ),
                                        child: Center(
                                          child: Icon(
                                            Icons.circle_rounded,
                                            size: lit ? 22 : 12,
                                            color: lit
                                                ? const Color(0xFF1A2440)
                                                : _accent.withValues(alpha: 0.34),
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
                        const SizedBox(height: ReleafSpacing.lg),
                        Text(
                          _status,
                          key: const Key('sequence-echo-status'),
                          textAlign: TextAlign.center,
                          style: ReleafTypography.body.copyWith(
                            color: ReleafColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: ReleafSpacing.md),
                        SizedBox(
                          height: ReleafControlSizes.prominent,
                          child: FilledButton.icon(
                            key: const Key('sequence-echo-start'),
                            onPressed:
                                _showing || _accepting || _finished
                                    ? null
                                    : _showSequence,
                            icon: Icon(
                              _round == 0
                                  ? Icons.play_arrow_rounded
                                  : Icons.replay_rounded,
                            ),
                            label: Text(
                              _round == 0 ? 'Start round' : 'Show sequence',
                            ),
                            style: FilledButton.styleFrom(
                              backgroundColor: const Color(0xFFDCE6FF),
                              foregroundColor: const Color(0xFF121A2C),
                            ),
                          ),
                        ),
                        const SizedBox(height: ReleafSpacing.sm),
                        Text(
                          'Difficulty changes sequence length and display speed. Score reflects this exercise only.',
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

class _SequenceStat extends StatelessWidget {
  const _SequenceStat({
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
          color: const Color(0xC9111722),
          borderRadius: BorderRadius.circular(ReleafRadii.medium),
          border: Border.all(
            color: const Color(0xFF8FA8E8).withValues(alpha: 0.15),
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
