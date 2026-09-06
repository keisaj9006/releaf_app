import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../features/brain/presentation/widgets/brain_difficulty_selector.dart';
import '../../theme/app_theme.dart';
import '../../theme/releaf_design_tokens.dart';

class SymbolCodeScreen extends StatefulWidget {
  const SymbolCodeScreen({
    super.key,
    required this.onFinish,
    this.trainingLevel = 1,
  });

  final ValueChanged<int?> onFinish;
  final int trainingLevel;

  @override
  State<SymbolCodeScreen> createState() => _SymbolCodeScreenState();
}

class _SymbolCodeScreenState extends State<SymbolCodeScreen> {
  static const _accent = Color(0xFF8CC8FF);
  static const _symbols = <String>[
    '●',
    '▲',
    '■',
    '◆',
    '✦',
    '✚',
    '⬟',
    '◉',
    '⌁',
  ];

  BrainDifficulty _difficulty = BrainDifficulty.medium;
  late List<_CodePair> _key;
  late List<String> _targets;
  late List<int> _options;

  int _trial = 0;
  int _correct = 0;
  int _mistakes = 0;
  bool _locked = false;
  final Stopwatch _stopwatch = Stopwatch();
  String _feedback = 'Use the key to decode each symbol. Accuracy comes first.';

  int get _trainingLevel => widget.trainingLevel.clamp(1, 12).toInt();
  int get _levelIndex => _trainingLevel - 1;

  int get _mappingCount {
    final base = switch (_difficulty) {
      BrainDifficulty.easy => 4,
      BrainDifficulty.medium => 6,
      BrainDifficulty.hard => 7,
    };
    final growth = _levelIndex ~/ 3;
    return (base + growth).clamp(4, _symbols.length).toInt();
  }

  int get _trialCount {
    final base = switch (_difficulty) {
      BrainDifficulty.easy => 8,
      BrainDifficulty.medium => 10,
      BrainDifficulty.hard => 12,
    };
    return (base + (_levelIndex ~/ 2)).clamp(8, 18).toInt();
  }

  int get _optionCount => switch (_difficulty) {
        BrainDifficulty.easy => 3,
        BrainDifficulty.medium => 4,
        BrainDifficulty.hard => 5,
      };

  int get _difficultyMultiplier => switch (_difficulty) {
        BrainDifficulty.easy => 1,
        BrainDifficulty.medium => 2,
        BrainDifficulty.hard => 3,
      };

  bool get _canChangeDifficulty =>
      _trial == 0 && _correct == 0 && _mistakes == 0 && !_stopwatch.isRunning;

  String get _currentSymbol =>
      _targets[_trial.clamp(0, _targets.length - 1).toInt()];

  int get _correctValue {
    for (final pair in _key) {
      if (pair.symbol == _currentSymbol) return pair.value;
    }
    return 1;
  }

  @override
  void initState() {
    super.initState();
    _buildSession();
  }

  @override
  void dispose() {
    _stopwatch.stop();
    super.dispose();
  }

  void _changeDifficulty(BrainDifficulty difficulty) {
    if (!_canChangeDifficulty) return;
    setState(() {
      _difficulty = difficulty;
      _feedback =
          '${difficulty.label} selected. The code key and answer set are now larger.';
      _buildSession();
    });
  }

  void _buildSession() {
    final random = math.Random(
      4409 + (_trainingLevel * 2069) + (_difficulty.index * 6131),
    );

    final symbols = List<String>.from(_symbols)..shuffle(random);
    final values = List<int>.generate(9, (index) => index + 1)..shuffle(random);

    _key = List<_CodePair>.generate(
      _mappingCount,
      (index) => _CodePair(
        symbol: symbols[index],
        value: values[index],
      ),
    );

    _targets = <String>[];
    while (_targets.length < _trialCount) {
      final symbol = _key[random.nextInt(_key.length)].symbol;
      if (_targets.isNotEmpty && _targets.last == symbol) continue;
      _targets.add(symbol);
    }

    _trial = 0;
    _correct = 0;
    _mistakes = 0;
    _locked = false;
    _stopwatch
      ..stop()
      ..reset();
    _options = _buildOptions(random);
  }

  List<int> _buildOptions(math.Random random) {
    final correct = _correctValue;
    final values = <int>{correct};
    final candidates = _key.map((pair) => pair.value).toList()..shuffle(random);

    for (final value in candidates) {
      if (values.length >= _optionCount) break;
      values.add(value);
    }

    var fallback = 1;
    while (values.length < _optionCount) {
      values.add(fallback);
      fallback++;
    }

    final result = values.toList()..shuffle(random);
    return result;
  }

  Future<void> _answer(int value) async {
    if (_locked) return;
    _locked = true;
    if (!_stopwatch.isRunning) _stopwatch.start();

    final correct = value == _correctValue;
    if (correct) {
      _correct++;
      _feedback = 'Correct mapping.';
      HapticFeedback.selectionClick();
    } else {
      _mistakes++;
      _feedback = 'That symbol maps to $_correctValue.';
      HapticFeedback.lightImpact();
    }

    setState(() {});

    if (_trial >= _targets.length - 1) {
      _stopwatch.stop();
      await Future<void>.delayed(const Duration(milliseconds: 320));
      if (mounted) _completeSession();
      return;
    }

    await Future<void>.delayed(const Duration(milliseconds: 260));
    if (!mounted) return;

    setState(() {
      _trial++;
      _locked = false;
      _feedback = 'Decode the next symbol.';
      _options = _buildOptions(
        math.Random(
          9001 +
              (_trainingLevel * 397) +
              (_difficulty.index * 1009) +
              _trial,
        ),
      );
    });
  }

  void _completeSession() {
    final attempted = math.max(1, _correct + _mistakes);
    final accuracy = _correct / attempted;
    final elapsedSeconds =
        math.max(1, _stopwatch.elapsed.inMilliseconds ~/ 1000);
    final speedPenalty = math.max(0, elapsedSeconds - _trialCount);

    final score = math
        .max(
          0,
          (_correct * 16 * _difficultyMultiplier) +
              (accuracy * 120).round() +
              (_trainingLevel * 7) -
              (_mistakes * 8) -
              speedPenalty,
        )
        .toInt();

    HapticFeedback.mediumImpact();
    widget.onFinish(score);
  }

  @override
  Widget build(BuildContext context) {
    final attempted = _correct + _mistakes;
    final accuracy = attempted == 0 ? null : (_correct / attempted * 100).round();
    final progress = (_trial + 1) / _targets.length;

    return Theme(
      data: AppTheme.premiumDark(),
      child: Scaffold(
        backgroundColor: ReleafColors.background,
        appBar: AppBar(
          toolbarHeight: 72,
          backgroundColor: const Color(0xEA0C131B),
          surfaceTintColor: Colors.transparent,
          titleSpacing: 20,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'ASSOCIATIVE MAPPING',
                style: ReleafTypography.eyebrow.copyWith(
                  color: _accent,
                  letterSpacing: 1.5,
                ),
              ),
              Text(
                'Symbol Code',
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
                  key: const Key('symbol-code-training-level'),
                  style: ReleafTypography.meta.copyWith(
                    color: _accent,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
            IconButton(
              tooltip: 'Exit Symbol Code',
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
                      Color(0xFF0E1A25),
                      ReleafColors.background,
                      Color(0xFF07090C),
                    ],
                  ),
                ),
              ),
            ),
            SafeArea(
              top: false,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final compact = constraints.maxHeight < 720;

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
                              enabled: _canChangeDifficulty,
                              accent: _accent,
                              onChanged: _changeDifficulty,
                            ),
                            const SizedBox(height: ReleafSpacing.md),
                            Wrap(
                              spacing: ReleafSpacing.xs,
                              runSpacing: ReleafSpacing.xs,
                              children: [
                                _CodeStat(
                                  label: 'TRIAL',
                                  value: '${_trial + 1}/${_targets.length}',
                                ),
                                _CodeStat(
                                  label: 'KEY',
                                  value: '${_key.length} pairs',
                                ),
                                _CodeStat(
                                  label: 'ACCURACY',
                                  value: accuracy == null ? '—' : '$accuracy%',
                                ),
                              ],
                            ),
                            const SizedBox(height: ReleafSpacing.md),
                            Container(
                              key: const Key('symbol-code-key'),
                              padding: const EdgeInsets.all(ReleafSpacing.md),
                              decoration: BoxDecoration(
                                color: const Color(0xE914202A),
                                borderRadius: BorderRadius.circular(
                                  ReleafRadii.large,
                                ),
                                border: Border.all(
                                  color: _accent.withValues(alpha: 0.18),
                                ),
                              ),
                              child: Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                alignment: WrapAlignment.center,
                                children: [
                                  for (var index = 0;
                                      index < _key.length;
                                      index++)
                                    _CodeKeyItem(
                                      index: index,
                                      pair: _key[index],
                                    ),
                                ],
                              ),
                            ),
                            SizedBox(
                              height: compact
                                  ? ReleafSpacing.md
                                  : ReleafSpacing.xl,
                            ),
                            Container(
                              key: const Key('symbol-code-target'),
                              height: compact ? 170 : 210,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Color(0xF01C2A38),
                                    Color(0xF00D151E),
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
                                    color: _accent.withValues(alpha: 0.08),
                                    blurRadius: 32,
                                    offset: const Offset(0, 16),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: AnimatedSwitcher(
                                  duration: ReleafMotion.quick,
                                  child: Text(
                                    _currentSymbol,
                                    key: ValueKey(
                                      'symbol-code-target-$_trial-$_currentSymbol',
                                    ),
                                    style: ReleafTypography.display.copyWith(
                                      fontSize: compact ? 76 : 96,
                                      color: const Color(0xFFE8F5FF),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: ReleafSpacing.md),
                            Text(
                              _feedback,
                              key: const Key('symbol-code-feedback'),
                              textAlign: TextAlign.center,
                              style: ReleafTypography.body.copyWith(
                                color: ReleafColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: ReleafSpacing.md),
                            GridView.count(
                              key: const Key('symbol-code-options'),
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              crossAxisCount: _optionCount <= 3 ? 3 : 2,
                              mainAxisSpacing: ReleafSpacing.sm,
                              crossAxisSpacing: ReleafSpacing.sm,
                              childAspectRatio: _optionCount <= 3 ? 1.8 : 2.35,
                              children: [
                                for (final value in _options)
                                  FilledButton(
                                    key: Key('symbol-code-answer-$value'),
                                    onPressed:
                                        _locked ? null : () => _answer(value),
                                    style: FilledButton.styleFrom(
                                      backgroundColor:
                                          _accent.withValues(alpha: 0.15),
                                      foregroundColor:
                                          ReleafColors.textPrimary,
                                      side: BorderSide(
                                        color:
                                            _accent.withValues(alpha: 0.28),
                                      ),
                                    ),
                                    child: Text(
                                      '$value',
                                      style:
                                          ReleafTypography.sectionTitle.copyWith(
                                        fontSize: 22,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: ReleafSpacing.sm),
                            ClipRRect(
                              borderRadius:
                                  BorderRadius.circular(ReleafRadii.pill),
                              child: LinearProgressIndicator(
                                value: progress,
                                minHeight: 6,
                                backgroundColor:
                                    _accent.withValues(alpha: 0.10),
                                valueColor:
                                    const AlwaysStoppedAnimation(_accent),
                              ),
                            ),
                            const SizedBox(height: ReleafSpacing.md),
                            Text(
                              'Symbol Code practises reading a temporary mapping key and applying it accurately. Releaf does not interpret this score as intelligence or a clinical assessment.',
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

class _CodePair {
  const _CodePair({required this.symbol, required this.value});

  final String symbol;
  final int value;
}

class _CodeKeyItem extends StatelessWidget {
  const _CodeKeyItem({
    required this.index,
    required this.pair,
  });

  final int index;
  final _CodePair pair;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: Key('symbol-code-key-$index'),
      width: 58,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 9),
      decoration: BoxDecoration(
        color: const Color(0xFF101B24),
        borderRadius: BorderRadius.circular(ReleafRadii.medium),
        border: Border.all(
          color: _SymbolCodeScreenState._accent.withValues(alpha: 0.14),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            pair.symbol,
            style: ReleafTypography.sectionTitle.copyWith(fontSize: 20),
          ),
          const SizedBox(height: 3),
          Text(
            '${pair.value}',
            style: ReleafTypography.meta.copyWith(
              color: _SymbolCodeScreenState._accent,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _CodeStat extends StatelessWidget {
  const _CodeStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xD9101820),
        borderRadius: BorderRadius.circular(ReleafRadii.pill),
        border: Border.all(
          color: _SymbolCodeScreenState._accent.withValues(alpha: 0.18),
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
