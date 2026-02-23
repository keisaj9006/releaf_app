import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/session/session_manager.dart';
import '../../features/brain/presentation/game_result_screen.dart';
import 'math_puzzle_generator.dart';
import 'math_race_stats.dart';

class MathRaceScreen extends ConsumerStatefulWidget {
  const MathRaceScreen({super.key});

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
  int _streak = 0;

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
    _streak = 0;

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
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => GameResultScreen(score: _score),
      ),
    );
  }

  void _pauseAndMinimize() {
    // PAUSE = stop timer + leave screen + show resume pill
    _timer?.cancel();

    ref.read(sessionManagerProvider.notifier).setPausedSession(
      title: 'Math Race',
      subtitle: 'Paused • $_timeLeft s left',
      resumeRoute: '/brain', // P0: resume leads to Brain hub
      extra: null,
    );

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
      _streak++;

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
      _streak = 0;
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

  Widget _statusChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.92),
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontWeight: FontWeight.w700,
          color: Color(0xFF1E4D2B),
        ),
      ),
    );
  }

  Widget _actionButton({
    required IconData icon,
    required String label,
    required VoidCallback? onTap,
  }) {
    return SizedBox(
      height: 54,
      child: FilledButton.tonalIcon(
        onPressed: onTap,
        icon: Icon(icon, size: 18),
        label: Text(label, overflow: TextOverflow.ellipsis),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = _puzzle;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Math Race'),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Minimize',
            icon: const Icon(Icons.horizontal_rule),
            onPressed: _pauseAndMinimize,
          ),
          IconButton(
            tooltip: 'Close',
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).maybePop(),
          ),
        ],
      ),
      body: SafeArea(
        child: p == null
            ? const Center(child: CircularProgressIndicator())
            : Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _statusChip('Lvl: $_level'),
                  _statusChip('Time: $_timeLeft s'),
                  _statusChip('Score: $_score'),
                ],
              ),
              const SizedBox(height: 16),

              Expanded(
                child: Center(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 22,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(.95),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 14,
                          offset: Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            _expressionText(p),
                            style: const TextStyle(
                              fontSize: 44,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF154314),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 14),
                        if (_feedback != null)
                          Text(
                            _feedback!,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: _feedback!.startsWith('Nice')
                                  ? Colors.green[700]
                                  : Colors.red[700],
                            ),
                          ),
                        const SizedBox(height: 18),

                        GridView.count(
                          shrinkWrap: true,
                          crossAxisCount: 2,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 2.6,
                          children: p.options.map((opt) {
                            final isDisabled = _locked;
                            return InkWell(
                              onTap: isDisabled ? null : () => _answer(opt),
                              borderRadius: BorderRadius.circular(18),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(18),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Colors.black12,
                                      blurRadius: 8,
                                      offset: Offset(0, 4),
                                    ),
                                  ],
                                ),
                                alignment: Alignment.center,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 10,
                                  horizontal: 8,
                                ),
                                child: Text(
                                  opt.toString(),
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  SizedBox(
                    width: (MediaQuery.of(context).size.width - 42) / 2,
                    child: _actionButton(
                      icon: Icons.refresh,
                      label: 'Restart',
                      onTap: _locked ? null : _restartSession,
                    ),
                  ),
                  SizedBox(
                    width: (MediaQuery.of(context).size.width - 42) / 2,
                    child: _actionButton(
                      icon: Icons.bar_chart,
                      label: 'Stats',
                      onTap: () async {
                        final best = await MathRaceStats.load();
                        if (!mounted) return;
                        showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: const Text('Stats'),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Best score: ${best.bestScore}'),
                                Text('Best level: ${best.bestLevel}'),
                              ],
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: const Text('OK'),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(
                    width: (MediaQuery.of(context).size.width - 42),
                    child: _actionButton(
                      icon: Icons.skip_next,
                      label: 'Skip (−2 score)',
                      onTap: _locked
                          ? null
                          : () {
                        setState(() {
                          _score = (_score - 2).clamp(0, 999999);
                          _level++;
                          _feedback = null;
                          _locked = false;
                        });
                        _nextPuzzle();
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}