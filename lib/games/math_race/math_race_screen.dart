import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/brain/presentation/game_result_screen.dart';
import '../../theme/app_theme.dart';
import '../../theme/releaf_design_tokens.dart';
import '../../theme/widgets/releaf_brain_artwork.dart';
import 'math_puzzle_generator.dart';
import 'math_race_stats.dart';

class MathRaceScreen extends ConsumerStatefulWidget {
  final ValueChanged<int>? onFinish;

  const MathRaceScreen({super.key, this.onFinish});

  @override
  ConsumerState<MathRaceScreen> createState() => _MathRaceScreenState();
}

class _MathRaceScreenState extends ConsumerState<MathRaceScreen> {
  final _gen = MathPuzzleGenerator();

  static const int _sessionSeconds = 60;
  int _timeLeft = _sessionSeconds;
  Timer? _timer;

  int _level = 1;
  int _score = 0;

  Difficulty _difficulty = Difficulty.easy;
  MathPuzzle? _puzzle;
  bool _locked = false;
  String? _feedback;

  @override
  void initState() {
    super.initState();
    _startSession();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startSession() {
    _timer?.cancel();
    _timeLeft = _sessionSeconds;

    _locked = false;
    _feedback = null;
    _level = 1;
    _score = 0;

    _nextPuzzle();

    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      setState(() {
        _timeLeft--;
        if (_timeLeft <= 0) {
          t.cancel();
          _endSession();
        }
      });
    });
  }

  Future<void> _endSession() async {
    await MathRaceStats.saveBest(score: _score, level: _level);

    if (!mounted) return;
    if (widget.onFinish != null) {
      widget.onFinish!(_score);
      return;
    }
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => GameResultScreen(score: _score, completed: true),
      ),
    );
  }

  void _exitSession() {
    _timer?.cancel();
    Navigator.of(context).maybePop();
  }

  Difficulty _difficultyForLevel(int level) {
    if (level < 4) return Difficulty.easy;
    if (level < 8) return Difficulty.medium;
    return Difficulty.hard;
  }

  void _nextPuzzle() {
    _difficulty = _difficultyForLevel(_level);

    _puzzle = _gen.generateForLevel(level: _level);
    if (_puzzle!.correctAnswer <= 0) {
      _puzzle = _gen.generateForLevel(level: _level);
    }
    setState(() {});
  }

  Future<void> _answer(int value) async {
    if (_locked || _puzzle == null) return;
    _locked = true;

    final correct = value == _puzzle!.correctAnswer;
    if (correct) {
      final speedBonus = (_timeLeft ~/ 15);
      final diffBonus = switch (_difficulty) {
        Difficulty.easy => 1,
        Difficulty.medium => 2,
        Difficulty.hard => 3,
      };
      final gained = 1 + speedBonus + diffBonus;

      _score += gained;
      _feedback = 'Nice! +$gained';

      setState(() {});
      await Future.delayed(const Duration(milliseconds: 350));

      _level++;
      _locked = false;
      _feedback = null;
      _nextPuzzle();
    } else {
      _feedback = 'Try again';
      setState(() {});
      await Future.delayed(const Duration(milliseconds: 300));
      _locked = false;
      _feedback = null;
      setState(() {});
    }
  }

  void _restartSession() {
    _startSession();
  }

  String _expressionText(MathPuzzle p) {
    String a = p.a.toString();
    String b = p.b.toString();
    String r = p.res.toString();

    switch (p.missing) {
      case MissingSlot.a:
        a = '?';
        break;
      case MissingSlot.b:
        b = '?';
        break;
      case MissingSlot.res:
        r = '?';
        break;
    }

    if (p.op == '^') return '$a ^ $b = $r';
    if (p.op == '%') return '$a% of $b = $r';
    return '$a ${p.op} $b = $r';
  }

  Widget _statusChip({
    required IconData icon,
    required String label,
    Color accent = const Color(0xFFE3A66A),
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xD9151720),
        borderRadius: BorderRadius.circular(ReleafRadii.pill),
        border: Border.all(color: accent.withValues(alpha: 0.22)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: accent),
          const SizedBox(width: 6),
          Text(
            label,
            style: ReleafTypography.meta.copyWith(
              color: ReleafColors.textPrimary,
              fontWeight: FontWeight.w700,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionButton({
    required IconData icon,
    required String label,
    required VoidCallback? onTap,
  }) {
    return SizedBox(
      height: 48,
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 17),
        label: Text(label, overflow: TextOverflow.ellipsis),
        style: OutlinedButton.styleFrom(
          foregroundColor: ReleafColors.textPrimary,
          side: BorderSide(
            color: const Color(0xFFE3A66A).withValues(alpha: 0.20),
          ),
          backgroundColor:
              const Color(0xFF151720).withValues(alpha: 0.72),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = _puzzle;
    const accent = Color(0xFFE3A66A);

    return Theme(
      data: AppTheme.premiumDark(),
      child: Scaffold(
        backgroundColor: ReleafColors.background,
        appBar: AppBar(
          toolbarHeight: 72,
          backgroundColor: const Color(0xE90D0E15),
          surfaceTintColor: Colors.transparent,
          titleSpacing: 20,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'CALCULATION',
                style: ReleafTypography.eyebrow.copyWith(
                  color: accent,
                  letterSpacing: 1.8,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Math Race',
                style: ReleafTypography.cardTitle.copyWith(fontSize: 17),
              ),
            ],
          ),
          actions: [
            IconButton(
              tooltip: 'Exit Math Race',
              icon: const Icon(Icons.close_rounded),
              onPressed: _exitSession,
            ),
          ],
        ),
        body: Stack(
          children: [
            const Positioned.fill(
              child: ReleafBrainArtwork(
                variant: ReleafBrainArtworkVariant.mathRace,
                intensity: 0.38,
              ),
            ),
            const Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xB70C0C14),
                      Color(0xED0B0D12),
                      ReleafColors.background,
                    ],
                    stops: [0, 0.48, 1],
                  ),
                ),
              ),
            ),
            SafeArea(
              top: false,
              child: p == null
                  ? const Center(
                      child: CircularProgressIndicator(color: accent),
                    )
                  : LayoutBuilder(
                      builder: (context, constraints) {
                        final compact = constraints.maxHeight < 690;

                        return SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          padding: EdgeInsets.fromLTRB(
                            ReleafSpacing.screen,
                            compact ? ReleafSpacing.sm : ReleafSpacing.md,
                            ReleafSpacing.screen,
                            ReleafSpacing.lg,
                          ),
                          child: Center(
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 620),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Wrap(
                                    spacing: ReleafSpacing.xs,
                                    runSpacing: ReleafSpacing.xs,
                                    children: [
                                      _statusChip(
                                        icon: Icons.layers_outlined,
                                        label: 'Level $_level',
                                      ),
                                      _statusChip(
                                        icon: Icons.timer_outlined,
                                        label: '${_timeLeft}s',
                                        accent: _timeLeft <= 10
                                            ? const Color(0xFFE19A84)
                                            : accent,
                                      ),
                                      _statusChip(
                                        icon: Icons.bolt_rounded,
                                        label: 'Score $_score',
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: compact
                                        ? ReleafSpacing.md
                                        : ReleafSpacing.xl,
                                  ),
                                  Container(
                                    key: const Key('math-race-puzzle-card'),
                                    width: double.infinity,
                                    padding: EdgeInsets.symmetric(
                                      horizontal: ReleafSpacing.lg,
                                      vertical: compact ? 24 : 34,
                                    ),
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          Color(0xF01A1722),
                                          Color(0xF011151D),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(
                                        ReleafRadii.extraLarge,
                                      ),
                                      border: Border.all(
                                        color: accent.withValues(alpha: 0.24),
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: accent.withValues(alpha: 0.08),
                                          blurRadius: 32,
                                          offset: const Offset(0, 16),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          'FIND THE MISSING VALUE',
                                          style:
                                              ReleafTypography.eyebrow.copyWith(
                                            color: accent,
                                            fontSize: 9,
                                          ),
                                        ),
                                        const SizedBox(
                                          height: ReleafSpacing.lg,
                                        ),
                                        FittedBox(
                                          fit: BoxFit.scaleDown,
                                          child: Text(
                                            _expressionText(p),
                                            style: ReleafTypography.display
                                                .copyWith(
                                              fontSize: compact ? 42 : 52,
                                              fontWeight: FontWeight.w700,
                                              color:
                                                  const Color(0xFFFFF2E0),
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                        SizedBox(
                                          height: compact
                                              ? ReleafSpacing.sm
                                              : ReleafSpacing.lg,
                                        ),
                                        AnimatedSwitcher(
                                          duration: ReleafMotion.quick,
                                          child: _feedback == null
                                              ? Text(
                                                  'Choose one answer.',
                                                  key: const ValueKey(
                                                    'math-hint',
                                                  ),
                                                  style: ReleafTypography.meta
                                                      .copyWith(
                                                    color: ReleafColors
                                                        .textSecondary,
                                                  ),
                                                )
                                              : Text(
                                                  _feedback!,
                                                  key: ValueKey(_feedback),
                                                  style: ReleafTypography
                                                      .cardTitle
                                                      .copyWith(
                                                    color: _feedback!
                                                            .startsWith('Nice')
                                                        ? const Color(
                                                            0xFF80CDB7,
                                                          )
                                                        : const Color(
                                                            0xFFE1A184,
                                                          ),
                                                  ),
                                                ),
                                        ),
                                        const SizedBox(
                                          height: ReleafSpacing.lg,
                                        ),
                                        GridView.count(
                                          shrinkWrap: true,
                                          physics:
                                              const NeverScrollableScrollPhysics(),
                                          crossAxisCount: 2,
                                          mainAxisSpacing: ReleafSpacing.sm,
                                          crossAxisSpacing: ReleafSpacing.sm,
                                          childAspectRatio: 2.45,
                                          children: p.options.map((opt) {
                                            return Material(
                                              color: Colors.transparent,
                                              borderRadius:
                                                  BorderRadius.circular(
                                                ReleafRadii.medium,
                                              ),
                                              child: InkWell(
                                                onTap: _locked
                                                    ? null
                                                    : () => _answer(opt),
                                                borderRadius:
                                                    BorderRadius.circular(
                                                  ReleafRadii.medium,
                                                ),
                                                child: Ink(
                                                  decoration: BoxDecoration(
                                                    color: const Color(
                                                      0xFF111722,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                      ReleafRadii.medium,
                                                    ),
                                                    border: Border.all(
                                                      color: accent.withValues(
                                                        alpha: 0.22,
                                                      ),
                                                    ),
                                                  ),
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                    vertical: 10,
                                                    horizontal: 8,
                                                  ),
                                                  child: Center(
                                                    child: Text(
                                                      opt.toString(),
                                                      style: ReleafTypography
                                                          .sectionTitle
                                                          .copyWith(
                                                        fontSize: 21,
                                                        color: const Color(
                                                          0xFFF5EEE7,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            );
                                          }).toList(),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: ReleafSpacing.md),
                                  LayoutBuilder(
                                    builder: (context, actions) {
                                      final stacked =
                                          actions.maxWidth < 380;
                                      final restart = _actionButton(
                                        icon: Icons.refresh_rounded,
                                        label: 'Restart',
                                        onTap:
                                            _locked ? null : _restartSession,
                                      );
                                      final stats = _actionButton(
                                        icon: Icons.bar_chart_rounded,
                                        label: 'Stats',
                                        onTap: () async {
                                          final best =
                                              await MathRaceStats.load();
                                          if (!context.mounted) return;
                                          showDialog(
                                            context: context,
                                            builder: (_) => AlertDialog(
                                              title: const Text(
                                                'Math Race stats',
                                              ),
                                              content: Column(
                                                mainAxisSize:
                                                    MainAxisSize.min,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    'Best score: ${best.bestScore}',
                                                  ),
                                                  Text(
                                                    'Best level: ${best.bestLevel}',
                                                  ),
                                                ],
                                              ),
                                              actions: [
                                                TextButton(
                                                  onPressed: () =>
                                                      Navigator.of(context)
                                                          .pop(),
                                                  child: const Text('Close'),
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      );

                                      return Column(
                                        children: [
                                          if (stacked) ...[
                                            restart,
                                            const SizedBox(
                                              height: ReleafSpacing.xs,
                                            ),
                                            stats,
                                          ] else
                                            Row(
                                              children: [
                                                Expanded(child: restart),
                                                const SizedBox(
                                                  width: ReleafSpacing.xs,
                                                ),
                                                Expanded(child: stats),
                                              ],
                                            ),
                                          const SizedBox(
                                            height: ReleafSpacing.xs,
                                          ),
                                          _actionButton(
                                            icon:
                                                Icons.skip_next_rounded,
                                            label: 'Skip · −2 score',
                                            onTap: _locked
                                                ? null
                                                : () {
                                                    setState(() {
                                                      _score = (_score - 2)
                                                          .clamp(0, 999999);
                                                      _level++;
                                                      _feedback = null;
                                                      _locked = false;
                                                    });
                                                    _nextPuzzle();
                                                  },
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                  const SizedBox(height: ReleafSpacing.sm),
                                  Text(
                                    'Score reflects performance in this exercise only.',
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