import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../features/brain/presentation/widgets/brain_difficulty_selector.dart';
import '../../theme/app_theme.dart';
import '../../theme/releaf_design_tokens.dart';
import '../../theme/widgets/releaf_brain_artwork.dart';

class PatternLogicScreen extends StatefulWidget {
  const PatternLogicScreen({
    super.key,
    this.onFinish,
  });

  final ValueChanged<int?>? onFinish;

  @override
  State<PatternLogicScreen> createState() => _PatternLogicScreenState();
}

class _PatternLogicScreenState extends State<PatternLogicScreen> {
  static const _accent = Color(0xFFA9A0E8);

  BrainDifficulty _difficulty = BrainDifficulty.easy;
  int _round = 0;
  int _score = 0;
  bool? _lastCorrect;
  bool _finished = false;

  List<_PatternPuzzle> get _puzzles => switch (_difficulty) {
        BrainDifficulty.easy => _easyPuzzles,
        BrainDifficulty.medium => _mediumPuzzles,
        BrainDifficulty.hard => _hardPuzzles,
      };

  int get _multiplier => switch (_difficulty) {
        BrainDifficulty.easy => 1,
        BrainDifficulty.medium => 2,
        BrainDifficulty.hard => 3,
      };

  _PatternPuzzle get _puzzle => _puzzles[_round.clamp(0, _puzzles.length - 1)];

  void _answer(String answer) {
    if (_finished) return;

    final correct = answer == _puzzle.answer;
    HapticFeedback.selectionClick();
    final nextRound = _round + 1;

    setState(() {
      _lastCorrect = correct;
      if (correct) {
        _score += 100 * _multiplier;
      } else {
        _score = (_score - (10 * _multiplier)).clamp(0, 999999);
      }
      _round = nextRound;
    });

    if (nextRound >= _puzzles.length) {
      _finished = true;
      widget.onFinish?.call(_score);
    }
  }

  @override
  Widget build(BuildContext context) {
    final puzzle = _puzzle;
    final displayRound = (_round + 1).clamp(1, _puzzles.length);

    return Theme(
      data: AppTheme.premiumDark(),
      child: Scaffold(
        backgroundColor: ReleafColors.background,
        appBar: AppBar(
          toolbarHeight: 72,
          backgroundColor: const Color(0xEA0D0D17),
          surfaceTintColor: Colors.transparent,
          titleSpacing: 20,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'PATTERN REASONING',
                style: ReleafTypography.eyebrow.copyWith(
                  color: _accent,
                  letterSpacing: 1.7,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Pattern Logic',
                style: ReleafTypography.cardTitle.copyWith(fontSize: 17),
              ),
            ],
          ),
          actions: [
            IconButton(
              tooltip: 'Exit Pattern Logic',
              onPressed: () => Navigator.of(context).maybePop(),
              icon: const Icon(Icons.close_rounded),
            ),
          ],
        ),
        body: Stack(
          children: [
            const Positioned.fill(
              child: ReleafBrainArtwork(
                variant: ReleafBrainArtworkVariant.patternLogic,
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
                      Color(0xC70C0C16),
                      Color(0xEC0B0B14),
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
                              _lastCorrect = null;
                              _finished = false;
                            });
                          },
                        ),
                        const SizedBox(height: ReleafSpacing.md),
                        Row(
                          children: [
                            _PatternStat(
                              label: 'ROUND',
                              value: '$displayRound/${_puzzles.length}',
                            ),
                            const SizedBox(width: ReleafSpacing.xs),
                            _PatternStat(
                              label: 'RULES',
                              value: _difficulty == BrainDifficulty.easy
                                  ? '1'
                                  : _difficulty == BrainDifficulty.medium
                                      ? '2'
                                      : '2–3',
                            ),
                            const SizedBox(width: ReleafSpacing.xs),
                            _PatternStat(label: 'SCORE', value: '$_score'),
                          ],
                        ),
                        const SizedBox(height: ReleafSpacing.lg),
                        Container(
                          key: const Key('pattern-logic-prompt'),
                          padding: const EdgeInsets.fromLTRB(
                            ReleafSpacing.md,
                            32,
                            ReleafSpacing.md,
                            30,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xE9141420),
                            borderRadius:
                                BorderRadius.circular(ReleafRadii.extraLarge),
                            border: Border.all(
                              color: _accent.withValues(alpha: 0.22),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: _accent.withValues(alpha: 0.08),
                                blurRadius: 34,
                                offset: const Offset(0, 16),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Text(
                                'WHAT COMES NEXT?',
                                style: ReleafTypography.eyebrow.copyWith(
                                  color: _accent,
                                  fontSize: 9,
                                ),
                              ),
                              const SizedBox(height: ReleafSpacing.xl),
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    for (final token in puzzle.sequence) ...[
                                      _PatternTile(
                                        token: token,
                                        accent: _accent,
                                      ),
                                      const SizedBox(width: 7),
                                    ],
                                    const _PatternTile(
                                      token: '?',
                                      accent: _accent,
                                      question: true,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: ReleafSpacing.lg),
                              AnimatedSwitcher(
                                duration: ReleafMotion.quick,
                                child: Text(
                                  _lastCorrect == null
                                      ? puzzle.hint
                                      : _lastCorrect!
                                          ? 'Pattern found'
                                          : 'Different rule — keep looking',
                                  key: ValueKey(_lastCorrect),
                                  textAlign: TextAlign.center,
                                  style: ReleafTypography.meta.copyWith(
                                    color: _lastCorrect == null
                                        ? ReleafColors.textSecondary
                                        : _lastCorrect!
                                            ? const Color(0xFF80CDB7)
                                            : const Color(0xFFE1A184),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: ReleafSpacing.md),
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: puzzle.options.length,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 10,
                            crossAxisSpacing: 10,
                            childAspectRatio: 2.25,
                          ),
                          itemBuilder: (context, index) {
                            final option = puzzle.options[index];
                            return OutlinedButton(
                              key: Key('pattern-logic-answer-$index'),
                              onPressed: _finished ? null : () => _answer(option),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: ReleafColors.textPrimary,
                                backgroundColor:
                                    _accent.withValues(alpha: 0.06),
                                side: BorderSide(
                                  color: _accent.withValues(alpha: 0.22),
                                ),
                              ),
                              child: Text(
                                option,
                                style: const TextStyle(
                                  fontSize: 28,
                                  height: 1,
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: ReleafSpacing.md),
                        Text(
                          'Difficulty increases the number of interacting rules and plausible distractors.',
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

class _PatternTile extends StatelessWidget {
  const _PatternTile({
    required this.token,
    required this.accent,
    this.question = false,
  });

  final String token;
  final Color accent;
  final bool question;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 50,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: question
            ? accent.withValues(alpha: 0.16)
            : const Color(0xFF1A1A28),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: accent.withValues(alpha: question ? 0.50 : 0.18),
        ),
      ),
      child: Text(
        token,
        style: TextStyle(
          fontSize: question ? 23 : 24,
          color: question ? accent : ReleafColors.textPrimary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _PatternStat extends StatelessWidget {
  const _PatternStat({
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
          color: const Color(0xC9141420),
          borderRadius: BorderRadius.circular(ReleafRadii.medium),
          border: Border.all(
            color: const Color(0xFFA9A0E8).withValues(alpha: 0.15),
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

class _PatternPuzzle {
  const _PatternPuzzle({
    required this.sequence,
    required this.options,
    required this.answer,
    required this.hint,
  });

  final List<String> sequence;
  final List<String> options;
  final String answer;
  final String hint;
}

const _easyPuzzles = <_PatternPuzzle>[
  _PatternPuzzle(
    sequence: ['●', '○', '●', '○'],
    options: ['●', '○', '▲'],
    answer: '●',
    hint: 'One feature alternates.',
  ),
  _PatternPuzzle(
    sequence: ['▲', '■', '▲', '■'],
    options: ['■', '▲', '◆'],
    answer: '▲',
    hint: 'Look for a repeating pair.',
  ),
  _PatternPuzzle(
    sequence: ['◆', '◆', '○', '◆', '◆', '○'],
    options: ['○', '◆', '▲'],
    answer: '◆',
    hint: 'A group repeats.',
  ),
  _PatternPuzzle(
    sequence: ['●', '▲', '●', '▲'],
    options: ['▲', '■', '●'],
    answer: '●',
    hint: 'Track the position in the cycle.',
  ),
  _PatternPuzzle(
    sequence: ['○', '○', '●', '○', '○', '●'],
    options: ['○', '●', '◆'],
    answer: '○',
    hint: 'The separator stays regular.',
  ),
];

const _mediumPuzzles = <_PatternPuzzle>[
  _PatternPuzzle(
    sequence: ['●', '○', '○', '●', '○', '○'],
    options: ['●', '○', '▲', '◆'],
    answer: '●',
    hint: 'Think in groups of three.',
  ),
  _PatternPuzzle(
    sequence: ['▲', '■', '●', '▲', '■', '●'],
    options: ['■', '●', '▲', '◆'],
    answer: '▲',
    hint: 'Three positions repeat.',
  ),
  _PatternPuzzle(
    sequence: ['●', '▲', '●', '■', '●', '◆'],
    options: ['◆', '●', '■', '▲'],
    answer: '●',
    hint: 'One item stays fixed while the other changes.',
  ),
  _PatternPuzzle(
    sequence: ['○', '●', '▲', '○', '●', '▲'],
    options: ['●', '■', '○', '▲'],
    answer: '○',
    hint: 'Track the full cycle, not the last pair.',
  ),
  _PatternPuzzle(
    sequence: ['◆', '○', '◆', '▲', '◆', '■'],
    options: ['◆', '○', '■', '▲'],
    answer: '◆',
    hint: 'Odd and even positions follow different rules.',
  ),
  _PatternPuzzle(
    sequence: ['●', '●', '○', '▲', '▲', '○'],
    options: ['■', '○', '▲', '●'],
    answer: '■',
    hint: 'Pairs change; the separator does not.',
  ),
];

const _hardPuzzles = <_PatternPuzzle>[
  _PatternPuzzle(
    sequence: ['●', '○', '▲', '●', '○', '▲', '●'],
    options: ['▲', '◆', '○', '●', '■'],
    answer: '○',
    hint: 'Continue the longer cycle.',
  ),
  _PatternPuzzle(
    sequence: ['◆', '○', '◆', '▲', '◆', '■', '◆'],
    options: ['◆', '▲', '○', '■', '●'],
    answer: '○',
    hint: 'Two interleaved patterns are running.',
  ),
  _PatternPuzzle(
    sequence: ['●', '●', '○', '▲', '▲', '○', '■', '■', '○'],
    options: ['◆', '○', '■', '▲', '●'],
    answer: '◆',
    hint: 'The repeated pair advances while one marker stays fixed.',
  ),
  _PatternPuzzle(
    sequence: ['○', '▲', '●', '▲', '○', '▲', '●'],
    options: ['○', '●', '▲', '■', '◆'],
    answer: '▲',
    hint: 'One position is constant; the other alternates.',
  ),
  _PatternPuzzle(
    sequence: ['●', '○', '●', '▲', '●', '■', '●'],
    options: ['◆', '○', '●', '■', '▲'],
    answer: '◆',
    hint: 'Fixed anchors can hide the changing sequence.',
  ),
  _PatternPuzzle(
    sequence: ['▲', '○', '■', '○', '◆', '○'],
    options: ['●', '○', '◆', '■', '▲'],
    answer: '●',
    hint: 'Every second position is fixed.',
  ),
  _PatternPuzzle(
    sequence: ['●', '▲', '▲', '●', '■', '■', '●'],
    options: ['◆', '●', '■', '▲', '○'],
    answer: '◆',
    hint: 'The anchor returns before each changing pair.',
  ),
];
