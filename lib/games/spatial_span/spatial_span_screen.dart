import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../features/brain/presentation/widgets/brain_difficulty_selector.dart';
import '../../theme/app_theme.dart';
import '../../theme/releaf_design_tokens.dart';

enum _SpatialSpanPhase { ready, showing, input, feedback }

class SpatialSpanScreen extends StatefulWidget {
  const SpatialSpanScreen({
    super.key,
    required this.onFinish,
    this.trainingLevel = 1,
  });

  final ValueChanged<int?> onFinish;
  final int trainingLevel;

  @override
  State<SpatialSpanScreen> createState() => _SpatialSpanScreenState();
}

class _SpatialSpanScreenState extends State<SpatialSpanScreen> {
  static const _accent = Color(0xFF82C9E8);
  static const _roundsPerSession = 3;

  BrainDifficulty _difficulty = BrainDifficulty.medium;
  _SpatialSpanPhase _phase = _SpatialSpanPhase.ready;
  List<int> _sequence = const [];
  final List<int> _input = <int>[];

  int? _activeCell;
  int _round = 1;
  int _completedRounds = 0;
  int _correctTaps = 0;
  int _mistakes = 0;
  int _playbackToken = 0;
  String _feedback =
      'Watch the path light up, then reproduce the same spatial sequence.';

  int get _trainingLevel => widget.trainingLevel.clamp(1, 12).toInt();
  int get _levelIndex => _trainingLevel - 1;

  int get _gridSide {
    return switch (_difficulty) {
      BrainDifficulty.easy => _trainingLevel >= 10 ? 4 : 3,
      BrainDifficulty.medium => _trainingLevel >= 8 ? 5 : 4,
      BrainDifficulty.hard => _trainingLevel >= 7 ? 5 : 4,
    };
  }

  int get _sequenceLength {
    final difficultyOffset = switch (_difficulty) {
      BrainDifficulty.easy => 0,
      BrainDifficulty.medium => 1,
      BrainDifficulty.hard => 2,
    };
    final progression = _levelIndex ~/ 2;
    final roundGrowth = _round - 1;
    return (3 + difficultyOffset + progression + roundGrowth)
        .clamp(3, 11)
        .toInt();
  }

  Duration get _onDuration {
    final difficultyPenalty = switch (_difficulty) {
      BrainDifficulty.easy => 0,
      BrainDifficulty.medium => 55,
      BrainDifficulty.hard => 105,
    };
    final milliseconds =
        (620 - (_levelIndex * 20) - difficultyPenalty).clamp(260, 620).toInt();
    return Duration(milliseconds: milliseconds);
  }

  Duration get _gapDuration {
    final milliseconds =
        (210 - (_levelIndex * 8)).clamp(100, 210).toInt();
    return Duration(milliseconds: milliseconds);
  }

  int get _difficultyMultiplier => switch (_difficulty) {
        BrainDifficulty.easy => 1,
        BrainDifficulty.medium => 2,
        BrainDifficulty.hard => 3,
      };

  bool get _canChangeDifficulty => _phase == _SpatialSpanPhase.ready && _round == 1;

  @override
  void dispose() {
    _playbackToken++;
    super.dispose();
  }

  void _changeDifficulty(BrainDifficulty difficulty) {
    if (!_canChangeDifficulty) return;
    setState(() {
      _difficulty = difficulty;
      _feedback =
          '${difficulty.label} selected. The grid and span will scale with your Brain level.';
    });
  }

  List<int> _buildSequence() {
    final cellCount = _gridSide * _gridSide;
    final random = math.Random(
      1733 +
          (_trainingLevel * 1009) +
          (_difficulty.index * 4093) +
          (_round * 7919),
    );
    final result = <int>[];

    while (result.length < _sequenceLength) {
      final candidate = random.nextInt(cellCount);
      if (result.isNotEmpty && result.last == candidate) continue;
      result.add(candidate);
    }

    return result;
  }

  Future<void> _startRound() async {
    if (_phase == _SpatialSpanPhase.showing ||
        _phase == _SpatialSpanPhase.input) {
      return;
    }

    final token = ++_playbackToken;
    final sequence = _buildSequence();

    setState(() {
      _sequence = sequence;
      _input.clear();
      _activeCell = null;
      _phase = _SpatialSpanPhase.showing;
      _feedback = 'Watch the spatial path.';
    });

    await Future<void>.delayed(const Duration(milliseconds: 350));
    if (!mounted || token != _playbackToken) return;

    for (final cell in sequence) {
      if (!mounted || token != _playbackToken) return;
      setState(() => _activeCell = cell);
      await Future<void>.delayed(_onDuration);
      if (!mounted || token != _playbackToken) return;
      setState(() => _activeCell = null);
      await Future<void>.delayed(_gapDuration);
    }

    if (!mounted || token != _playbackToken) return;
    setState(() {
      _phase = _SpatialSpanPhase.input;
      _feedback = 'Your turn. Tap the same locations in the same order.';
    });
  }

  void _tapCell(int index) {
    if (_phase != _SpatialSpanPhase.input) return;

    final position = _input.length;
    if (position >= _sequence.length) return;

    if (_sequence[position] == index) {
      _input.add(index);
      _correctTaps++;
      HapticFeedback.selectionClick();

      if (_input.length == _sequence.length) {
        _completedRounds++;
        HapticFeedback.mediumImpact();
        _finishRound(success: true);
      } else {
        setState(() {
          _activeCell = index;
          _feedback =
              '${_input.length}/${_sequence.length} correct. Keep going.';
        });
        Future<void>.delayed(const Duration(milliseconds: 120), () {
          if (mounted && _phase == _SpatialSpanPhase.input) {
            setState(() => _activeCell = null);
          }
        });
      }
      return;
    }

    _mistakes++;
    HapticFeedback.lightImpact();
    _finishRound(success: false);
  }

  void _finishRound({required bool success}) {
    _playbackToken++;
    setState(() {
      _activeCell = null;
      _phase = _SpatialSpanPhase.feedback;
      _feedback = success
          ? 'Span complete. The next round is slightly longer.'
          : 'Sequence broken. Reset your attention and try the next round.';
    });

    if (_round >= _roundsPerSession) {
      Future<void>.delayed(const Duration(milliseconds: 650), () {
        if (mounted) _completeSession();
      });
    }
  }

  void _nextRound() {
    if (_phase != _SpatialSpanPhase.feedback ||
        _round >= _roundsPerSession) {
      return;
    }

    setState(() {
      _round++;
      _input.clear();
      _sequence = const [];
      _activeCell = null;
      _phase = _SpatialSpanPhase.ready;
      _feedback =
          'Round $_round is ready. The span increases as the session continues.';
    });
  }

  void _completeSession() {
    if (!mounted) return;
    final attempted = math.max(1, _correctTaps + _mistakes);
    final accuracy = _correctTaps / attempted;
    final score = math
        .max(
          0,
          (_correctTaps * 10 * _difficultyMultiplier) +
              (_completedRounds * 70) +
              (accuracy * 100).round() +
              (_trainingLevel * 6) -
              (_mistakes * 8),
        )
        .toInt();
    widget.onFinish(score);
  }

  @override
  Widget build(BuildContext context) {
    final cellCount = _gridSide * _gridSide;
    final showing = _phase == _SpatialSpanPhase.showing;
    final input = _phase == _SpatialSpanPhase.input;
    final feedback = _phase == _SpatialSpanPhase.feedback;

    return Theme(
      data: AppTheme.premiumDark(),
      child: Scaffold(
        backgroundColor: ReleafColors.background,
        appBar: AppBar(
          toolbarHeight: 72,
          backgroundColor: const Color(0xEA0A1017),
          surfaceTintColor: Colors.transparent,
          titleSpacing: 20,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'VISUOSPATIAL WORKING MEMORY',
                style: ReleafTypography.eyebrow.copyWith(
                  color: _accent,
                  letterSpacing: 1.5,
                ),
              ),
              Text(
                'Spatial Span',
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
                  key: const Key('spatial-span-training-level'),
                  style: ReleafTypography.meta.copyWith(
                    color: _accent,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
            IconButton(
              tooltip: 'Exit Spatial Span',
              onPressed: () {
                _playbackToken++;
                Navigator.of(context).maybePop();
              },
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
                      Color(0xFF0D1B24),
                      ReleafColors.background,
                      Color(0xFF060A0D),
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
                                _SpatialStat(
                                  label: 'ROUND',
                                  value: '$_round/$_roundsPerSession',
                                ),
                                _SpatialStat(
                                  label: 'SPAN',
                                  value: '$_sequenceLength',
                                ),
                                _SpatialStat(
                                  label: 'GRID',
                                  value: '${_gridSide}×$_gridSide',
                                ),
                              ],
                            ),
                            SizedBox(
                              height: compact
                                  ? ReleafSpacing.md
                                  : ReleafSpacing.xl,
                            ),
                            Container(
                              key: const Key('spatial-span-board'),
                              padding: EdgeInsets.all(
                                compact ? ReleafSpacing.md : ReleafSpacing.lg,
                              ),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Color(0xF013202A),
                                    Color(0xF00A1218),
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
                              child: AspectRatio(
                                aspectRatio: 1,
                                child: GridView.builder(
                                  physics:
                                      const NeverScrollableScrollPhysics(),
                                  itemCount: cellCount,
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: _gridSide,
                                    crossAxisSpacing:
                                        compact ? 8 : ReleafSpacing.sm,
                                    mainAxisSpacing:
                                        compact ? 8 : ReleafSpacing.sm,
                                  ),
                                  itemBuilder: (context, index) {
                                    final active = _activeCell == index;
                                    final selected =
                                        input && _input.contains(index);

                                    return Semantics(
                                      button: input,
                                      label: 'Spatial tile ${index + 1}',
                                      child: Material(
                                        color: Colors.transparent,
                                        borderRadius: BorderRadius.circular(
                                          ReleafRadii.medium,
                                        ),
                                        clipBehavior: Clip.antiAlias,
                                        child: InkWell(
                                          key: Key(
                                            'spatial-span-cell-$index',
                                          ),
                                          onTap: input
                                              ? () => _tapCell(index)
                                              : null,
                                          child: AnimatedContainer(
                                            duration: ReleafMotion.quick,
                                            decoration: BoxDecoration(
                                              color: active
                                                  ? _accent
                                                  : selected
                                                      ? _accent.withValues(
                                                          alpha: 0.22,
                                                        )
                                                      : const Color(
                                                          0xFF12242E,
                                                        ),
                                              borderRadius:
                                                  BorderRadius.circular(
                                                ReleafRadii.medium,
                                              ),
                                              border: Border.all(
                                                color: active
                                                    ? const Color(0xFFE4F7FF)
                                                    : _accent.withValues(
                                                        alpha: 0.18,
                                                      ),
                                                width: active ? 2 : 1,
                                              ),
                                              boxShadow: active
                                                  ? [
                                                      BoxShadow(
                                                        color: _accent
                                                            .withValues(
                                                          alpha: 0.36,
                                                        ),
                                                        blurRadius: 18,
                                                      ),
                                                    ]
                                                  : null,
                                            ),
                                            child: Center(
                                              child: AnimatedOpacity(
                                                opacity: active ? 1 : 0.22,
                                                duration: ReleafMotion.quick,
                                                child: Icon(
                                                  Icons.circle,
                                                  size: active ? 18 : 9,
                                                  color: active
                                                      ? const Color(0xFF0A202B)
                                                      : _accent,
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
                              _feedback,
                              key: const Key('spatial-span-feedback'),
                              textAlign: TextAlign.center,
                              style: ReleafTypography.body.copyWith(
                                color: ReleafColors.textSecondary,
                                height: 1.45,
                              ),
                            ),
                            const SizedBox(height: ReleafSpacing.md),
                            if (_phase == _SpatialSpanPhase.ready)
                              FilledButton.icon(
                                key: const Key('spatial-span-start'),
                                onPressed: _startRound,
                                icon: const Icon(Icons.play_arrow_rounded),
                                label: Text(
                                  _round == 1
                                      ? 'Show sequence'
                                      : 'Start round $_round',
                                ),
                                style: FilledButton.styleFrom(
                                  backgroundColor: _accent,
                                  foregroundColor: const Color(0xFF09202B),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 15,
                                  ),
                                ),
                              )
                            else if (showing)
                              const _SpatialStatusButton(
                                icon: Icons.visibility_outlined,
                                label: 'Watch carefully…',
                              )
                            else if (input)
                              const _SpatialStatusButton(
                                icon: Icons.touch_app_outlined,
                                label: 'Repeat the path',
                              )
                            else if (feedback && _round < _roundsPerSession)
                              FilledButton.icon(
                                key: const Key('spatial-span-next-round'),
                                onPressed: _nextRound,
                                icon: const Icon(Icons.arrow_forward_rounded),
                                label: const Text('Next round'),
                              )
                            else if (feedback)
                              const _SpatialStatusButton(
                                icon: Icons.check_circle_outline_rounded,
                                label: 'Finishing session…',
                              ),
                            const SizedBox(height: ReleafSpacing.md),
                            Text(
                              'Spatial Span practises holding and reproducing short location sequences. The score reflects this task only and is not an intelligence measure.',
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

class _SpatialStat extends StatelessWidget {
  const _SpatialStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xD9121A20),
        borderRadius: BorderRadius.circular(ReleafRadii.pill),
        border: Border.all(
          color: _SpatialSpanScreenState._accent.withValues(alpha: 0.18),
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

class _SpatialStatusButton extends StatelessWidget {
  const _SpatialStatusButton({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFF111A20),
        borderRadius: BorderRadius.circular(ReleafRadii.medium),
        border: Border.all(
          color: _SpatialSpanScreenState._accent.withValues(alpha: 0.16),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 18,
            color: _SpatialSpanScreenState._accent,
          ),
          const SizedBox(width: 8),
          Text(
            label,
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
