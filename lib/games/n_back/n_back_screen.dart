import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../features/brain/presentation/widgets/brain_difficulty_selector.dart';
import '../../theme/app_theme.dart';
import '../../theme/releaf_design_tokens.dart';

class NBackScreen extends StatefulWidget {
  const NBackScreen({
    super.key,
    required this.onFinish,
    this.trainingLevel = 1,
  });

  final ValueChanged<int?> onFinish;
  final int trainingLevel;

  @override
  State<NBackScreen> createState() => _NBackScreenState();
}

class _NBackScreenState extends State<NBackScreen> {
  static const _symbols = <String>['●', '▲', '■', '◆', '✦', '⬟'];
  static const _accent = Color(0xFFB8A5FF);

  BrainDifficulty _difficulty = BrainDifficulty.medium;
  late List<String> _sequence;
  int _index = 0;
  int _correct = 0;
  int _mistakes = 0;
  bool _started = false;
  bool _finished = false;
  String _feedback = 'Watch the first items, then compare each one with the item N steps back.';

  int get _levelIndex => (widget.trainingLevel - 1).clamp(0, 11).toInt();

  int get _nBack {
    final base = switch (_difficulty) {
      BrainDifficulty.easy => 1,
      BrainDifficulty.medium => 2,
      BrainDifficulty.hard => 3,
    };
    final extra = switch (_difficulty) {
      BrainDifficulty.easy => _levelIndex >= 9 ? 1 : 0,
      BrainDifficulty.medium => _levelIndex >= 7 ? 1 : 0,
      BrainDifficulty.hard => _levelIndex >= 8 ? 1 : 0,
    };
    return (base + extra).clamp(1, 4).toInt();
  }

  int get _trialCount {
    final base = switch (_difficulty) {
      BrainDifficulty.easy => 12,
      BrainDifficulty.medium => 15,
      BrainDifficulty.hard => 18,
    };
    return base + (_levelIndex ~/ 2);
  }

  int get _multiplier => switch (_difficulty) {
    BrainDifficulty.easy => 1,
    BrainDifficulty.medium => 2,
    BrainDifficulty.hard => 3,
  };

  @override
  void initState() {
    super.initState();
    _sequence = _buildSequence();
  }

  List<String> _buildSequence() {
    final random = math.Random(
      9049 + (widget.trainingLevel * 271) + (_difficulty.index * 991),
    );
    final result = <String>[];

    for (var i = 0; i < _trialCount; i++) {
      if (i >= _nBack && random.nextDouble() < 0.34) {
        result.add(result[i - _nBack]);
        continue;
      }

      final forbidden = i >= _nBack ? result[i - _nBack] : null;
      final choices = _symbols.where((symbol) => symbol != forbidden).toList();
      result.add(choices[random.nextInt(choices.length)]);
    }

    return result;
  }

  void _changeDifficulty(BrainDifficulty difficulty) {
    if (_started) return;
    setState(() {
      _difficulty = difficulty;
      _sequence = _buildSequence();
      _index = 0;
      _correct = 0;
      _mistakes = 0;
      _feedback =
          'Difficulty set to ${difficulty.label}. Watch the first items before answering.';
    });
  }

  void _continueWarmup() {
    if (_finished) return;
    _started = true;
    if (_index >= _sequence.length - 1) {
      _complete();
      return;
    }
    setState(() {
      _index++;
      _feedback = _index < _nBack
          ? 'Keep watching. You will answer after $_nBack reference items.'
          : 'Now compare this item with the one $_nBack step${_nBack == 1 ? '' : 's'} back.';
    });
  }

  void _answer(bool saysMatch) {
    if (_finished || _index < _nBack) return;
    _started = true;

    final actualMatch = _sequence[_index] == _sequence[_index - _nBack];
    final correct = saysMatch == actualMatch;

    if (correct) {
      _correct++;
      HapticFeedback.selectionClick();
    } else {
      _mistakes++;
      HapticFeedback.lightImpact();
    }

    if (_index >= _sequence.length - 1) {
      setState(() {
        _feedback = correct ? 'Correct.' : 'Not this time.';
      });
      _complete();
      return;
    }

    setState(() {
      _feedback = correct
          ? 'Correct. Keep updating the sequence.'
          : actualMatch
              ? 'That was a match. Update and continue.'
              : 'That one was different. Update and continue.';
      _index++;
    });
  }

  void _complete() {
    if (_finished) return;
    _finished = true;
    final answered = math.max(1, _correct + _mistakes).toInt();
    final accuracy = _correct / answered;
    final score = math
        .max(
          0,
          ((_correct * 12 * _multiplier) +
                  (accuracy * 100).round() +
                  (widget.trainingLevel * 5) -
                  (_mistakes * 4))
              .round(),
        )
        .toInt();
    HapticFeedback.mediumImpact();
    widget.onFinish(score);
  }

  @override
  Widget build(BuildContext context) {
    final warmup = _index < _nBack;
    final current = _sequence[_index.clamp(0, _sequence.length - 1).toInt()];
    final answered = _correct + _mistakes;
    final accuracy = answered == 0 ? null : (_correct / answered * 100).round();

    return Theme(
      data: AppTheme.premiumDark(),
      child: Scaffold(
        backgroundColor: ReleafColors.background,
        appBar: AppBar(
          backgroundColor: const Color(0xEB0C0D16),
          surfaceTintColor: Colors.transparent,
          toolbarHeight: 72,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'WORKING MEMORY UPDATE',
                style: ReleafTypography.eyebrow.copyWith(
                  color: _accent,
                  letterSpacing: 1.5,
                ),
              ),
              Text(
                'N-Back',
                style: ReleafTypography.cardTitle.copyWith(fontSize: 17),
              ),
            ],
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Center(
                child: Text(
                  'L${widget.trainingLevel}',
                  key: const Key('n-back-training-level'),
                  style: ReleafTypography.meta.copyWith(
                    color: _accent,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
            IconButton(
              tooltip: 'Exit N-Back',
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
                      Color(0xFF151327),
                      ReleafColors.background,
                      Color(0xFF07090E),
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
                              enabled: !_started,
                              accent: _accent,
                              onChanged: _changeDifficulty,
                            ),
                            const SizedBox(height: ReleafSpacing.md),
                            Wrap(
                              spacing: ReleafSpacing.xs,
                              runSpacing: ReleafSpacing.xs,
                              children: [
                                _Stat(label: 'N-BACK', value: '$_nBack-back'),
                                _Stat(
                                  label: 'TRIAL',
                                  value: '${_index + 1}/${_sequence.length}',
                                ),
                                _Stat(
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
                              key: const Key('n-back-stimulus-card'),
                              height: compact ? 220 : 270,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Color(0xF01B1830),
                                    Color(0xF00E1320),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(
                                  ReleafRadii.extraLarge,
                                ),
                                border: Border.all(
                                  color: _accent.withValues(alpha: 0.28),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: _accent.withValues(alpha: 0.09),
                                    blurRadius: 34,
                                    offset: const Offset(0, 16),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: AnimatedSwitcher(
                                  duration: ReleafMotion.quick,
                                  child: Text(
                                    current,
                                    key: ValueKey('n-back-$_index-$current'),
                                    style: ReleafTypography.display.copyWith(
                                      fontSize: compact ? 88 : 108,
                                      color: const Color(0xFFF2EEFF),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: ReleafSpacing.md),
                            Text(
                              _feedback,
                              key: const Key('n-back-feedback'),
                              textAlign: TextAlign.center,
                              style: ReleafTypography.body.copyWith(
                                color: ReleafColors.textSecondary,
                                height: 1.45,
                              ),
                            ),
                            const SizedBox(height: ReleafSpacing.md),
                            if (warmup)
                              FilledButton.icon(
                                key: const Key('n-back-continue'),
                                onPressed: _continueWarmup,
                                icon: const Icon(Icons.arrow_forward_rounded),
                                label: const Text('Continue'),
                                style: FilledButton.styleFrom(
                                  backgroundColor: _accent,
                                  foregroundColor: const Color(0xFF171225),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 15),
                                ),
                              )
                            else
                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton(
                                      key: const Key('n-back-different'),
                                      onPressed: () => _answer(false),
                                      style: OutlinedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 15,
                                        ),
                                      ),
                                      child: const Text('Different'),
                                    ),
                                  ),
                                  const SizedBox(width: ReleafSpacing.sm),
                                  Expanded(
                                    child: FilledButton(
                                      key: const Key('n-back-match'),
                                      onPressed: () => _answer(true),
                                      style: FilledButton.styleFrom(
                                        backgroundColor: _accent,
                                        foregroundColor:
                                            const Color(0xFF171225),
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 15,
                                        ),
                                      ),
                                      child: const Text('Match'),
                                    ),
                                  ),
                                ],
                              ),
                            const SizedBox(height: ReleafSpacing.md),
                            Text(
                              'N-back trains keeping recent information active and updating it as new information arrives. Releaf does not present this score as an IQ measure.',
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

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xD9151622),
        borderRadius: BorderRadius.circular(ReleafRadii.pill),
        border: Border.all(color: _NBackScreenState._accent.withValues(alpha: 0.18)),
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
