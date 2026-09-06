import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../features/brain/presentation/widgets/brain_difficulty_selector.dart';
import '../../theme/app_theme.dart';
import '../../theme/releaf_design_tokens.dart';
import '../../theme/widgets/releaf_brain_artwork.dart';

class ColorConflictScreen extends StatefulWidget {
  const ColorConflictScreen({
    super.key,
    this.onFinish,
    this.trainingLevel = 1,
  });

  final ValueChanged<int?>? onFinish;
  final int trainingLevel;

  @override
  State<ColorConflictScreen> createState() => _ColorConflictScreenState();
}

class _ColorConflictScreenState extends State<ColorConflictScreen> {
  static const _accent = Color(0xFFE099B5);
  static const _colors = <_ConflictColor>[
    _ConflictColor('BLUE', Color(0xFF7AA7FF)),
    _ConflictColor('PINK', Color(0xFFE88FB7)),
    _ConflictColor('GREEN', Color(0xFF76C7A5)),
    _ConflictColor('ORANGE', Color(0xFFE8A06B)),
    _ConflictColor('PURPLE', Color(0xFFAA91EA)),
  ];

  BrainDifficulty _difficulty = BrainDifficulty.medium;
  Timer? _timer;
  int _round = 0;
  int _score = 0;
  int _timeLeft = 0;
  bool _started = false;
  bool _finished = false;
  bool? _lastCorrect;

  int get _levelIndex => (widget.trainingLevel - 1).clamp(0, 11).toInt();

  int get _colorCount => switch (_difficulty) {
        BrainDifficulty.easy => _round < 3 ? 3 : 4,
        BrainDifficulty.medium => _round < 4 ? 4 : 5,
        BrainDifficulty.hard => 5,
      };

  int get _totalRounds {
    final base = switch (_difficulty) {
      BrainDifficulty.easy => 9,
      BrainDifficulty.medium => 11,
      BrainDifficulty.hard => 13,
    };
    return base + (_levelIndex ~/ 3);
  }

  int get _sessionSeconds {
    final base = switch (_difficulty) {
      BrainDifficulty.easy => 38,
      BrainDifficulty.medium => 30,
      BrainDifficulty.hard => 24,
    };
    return (base - _levelIndex).clamp(12, 38).toInt();
  }

  int get _multiplier => switch (_difficulty) {
        BrainDifficulty.easy => 1,
        BrainDifficulty.medium => 2,
        BrainDifficulty.hard => 3,
      };

  _ConflictTrial get _trial {
    final wordIndex = (_round * 2 + _difficulty.index) % _colorCount;
    final shift = switch (_difficulty) {
      BrainDifficulty.easy => _round % 3 == 0 ? 0 : 1,
      BrainDifficulty.medium => 1 + (_round % 2),
      BrainDifficulty.hard => 1 + ((_round * 2 + 1) % (_colorCount - 1)),
    };
    final inkIndex = (wordIndex + shift) % _colorCount;
    return _ConflictTrial(
      word: _colors[wordIndex],
      ink: _colors[inkIndex],
      answerIndex: inkIndex,
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startSession() {
    _timer?.cancel();
    setState(() {
      _round = 0;
      _score = 0;
      _timeLeft = _sessionSeconds;
      _started = true;
      _finished = false;
      _lastCorrect = null;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted || _finished) return;
      if (_timeLeft <= 1) {
        setState(() => _timeLeft = 0);
        _finish();
        return;
      }
      setState(() => _timeLeft -= 1);
    });
  }

  void _answer(int index) {
    if (!_started || _finished) return;

    final correct = index == _trial.answerIndex;
    HapticFeedback.selectionClick();

    final nextRound = _round + 1;
    setState(() {
      _lastCorrect = correct;
      if (correct) {
        _score += 100 * _multiplier;
      }
      _round = nextRound;
    });

    if (nextRound >= _totalRounds) {
      _finish();
    }
  }

  void _finish() {
    if (_finished) return;
    _finished = true;
    _timer?.cancel();
    widget.onFinish?.call(_score);
  }

  @override
  Widget build(BuildContext context) {
    final trial = _trial;
    final displayRound = (_round + 1).clamp(1, _totalRounds);

    return Theme(
      data: AppTheme.premiumDark(),
      child: Scaffold(
        backgroundColor: ReleafColors.background,
        appBar: AppBar(
          toolbarHeight: 72,
          backgroundColor: const Color(0xEA120C13),
          surfaceTintColor: Colors.transparent,
          titleSpacing: 20,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'INHIBITORY CONTROL',
                style: ReleafTypography.eyebrow.copyWith(
                  color: _accent,
                  letterSpacing: 1.7,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Color Conflict',
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
                  key: const Key('color-conflict-training-level'),
                  style: ReleafTypography.eyebrow.copyWith(color: _accent),
                ),
              ),
            ),
            IconButton(
              tooltip: 'Exit Color Conflict',
              onPressed: () => Navigator.of(context).maybePop(),
              icon: const Icon(Icons.close_rounded),
            ),
          ],
        ),
        body: Stack(
          children: [
            const Positioned.fill(
              child: ReleafBrainArtwork(
                variant: ReleafBrainArtworkVariant.colorConflict,
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
                      Color(0xC7100A11),
                      Color(0xEB100B11),
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
                          enabled: !_started,
                          onChanged: (value) {
                            setState(() {
                              _difficulty = value;
                              _round = 0;
                              _score = 0;
                              _lastCorrect = null;
                            });
                          },
                        ),
                        const SizedBox(height: ReleafSpacing.md),
                        Row(
                          children: [
                            _ConflictStat(
                              label: 'ROUND',
                              value: '$displayRound/$_totalRounds',
                            ),
                            const SizedBox(width: ReleafSpacing.xs),
                            _ConflictStat(
                              label: 'TIME',
                              value: _started ? '${_timeLeft}s' : '—',
                            ),
                            const SizedBox(width: ReleafSpacing.xs),
                            _ConflictStat(
                              label: 'SCORE',
                              value: '$_score',
                            ),
                          ],
                        ),
                        const SizedBox(height: ReleafSpacing.lg),
                        Container(
                          key: const Key('color-conflict-prompt'),
                          padding: const EdgeInsets.symmetric(
                            horizontal: ReleafSpacing.lg,
                            vertical: 42,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xE9171119),
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
                                'TAP THE INK COLOR',
                                style: ReleafTypography.eyebrow.copyWith(
                                  color: _accent,
                                  fontSize: 9,
                                ),
                              ),
                              const SizedBox(height: ReleafSpacing.xl),
                              Text(
                                _started ? trial.word.label : 'READY',
                                textAlign: TextAlign.center,
                                style: ReleafTypography.display.copyWith(
                                  fontSize: 48,
                                  color: _started
                                      ? trial.ink.color
                                      : ReleafColors.textPrimary,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: ReleafSpacing.md),
                              AnimatedSwitcher(
                                duration: ReleafMotion.quick,
                                child: Text(
                                  _lastCorrect == null
                                      ? 'Ignore the word. Answer only the color you see.'
                                      : _lastCorrect!
                                          ? 'Correct'
                                          : 'Conflict won that round',
                                  key: ValueKey(_lastCorrect),
                                  textAlign: TextAlign.center,
                                  style: ReleafTypography.meta.copyWith(
                                    color: _lastCorrect == null
                                        ? ReleafColors.textSecondary
                                        : _lastCorrect!
                                            ? const Color(0xFF80CDB7)
                                            : const Color(0xFFE1A184),
                                    fontWeight: _lastCorrect == null
                                        ? FontWeight.w500
                                        : FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: ReleafSpacing.md),
                        if (_started && !_finished)
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _colorCount,
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: 10,
                              crossAxisSpacing: 10,
                              childAspectRatio: 2.55,
                            ),
                            itemBuilder: (context, index) {
                              final item = _colors[index];
                              return OutlinedButton(
                                key: Key('color-conflict-answer-$index'),
                                onPressed: () => _answer(index),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: item.color,
                                  backgroundColor:
                                      item.color.withValues(alpha: 0.08),
                                  side: BorderSide(
                                    color: item.color.withValues(alpha: 0.30),
                                  ),
                                ),
                                child: Text(
                                  item.label,
                                  style: ReleafTypography.cardTitle.copyWith(
                                    fontSize: 14,
                                    color: item.color,
                                  ),
                                ),
                              );
                            },
                          )
                        else
                          SizedBox(
                            height: ReleafControlSizes.prominent,
                            child: FilledButton.icon(
                              key: const Key('color-conflict-start'),
                              onPressed: _finished ? null : _startSession,
                              icon: const Icon(Icons.play_arrow_rounded),
                              label: const Text('Start session'),
                              style: FilledButton.styleFrom(
                                backgroundColor: const Color(0xFFFFDDE9),
                                foregroundColor: const Color(0xFF2A141D),
                              ),
                            ),
                          ),
                        const SizedBox(height: ReleafSpacing.md),
                        Text(
                          'Harder levels add more color choices and reduce the session time. Score reflects this exercise only.',
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

class _ConflictColor {
  const _ConflictColor(this.label, this.color);

  final String label;
  final Color color;
}

class _ConflictTrial {
  const _ConflictTrial({
    required this.word,
    required this.ink,
    required this.answerIndex,
  });

  final _ConflictColor word;
  final _ConflictColor ink;
  final int answerIndex;
}

class _ConflictStat extends StatelessWidget {
  const _ConflictStat({
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
          color: const Color(0xC917121A),
          borderRadius: BorderRadius.circular(ReleafRadii.medium),
          border: Border.all(
            color: const Color(0xFFE099B5).withValues(alpha: 0.15),
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
