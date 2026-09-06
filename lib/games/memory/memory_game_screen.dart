import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math' show pi, max;
import 'package:shared_preferences/shared_preferences.dart';
import 'memory_stats_screen.dart';
import '../../theme/app_theme.dart';
import '../../theme/releaf_design_tokens.dart';
import '../../theme/widgets/releaf_brain_artwork.dart';

class MemoryGameScreen extends StatefulWidget {
  /// Jeśli ten ekran jest uruchamiany jako “Brain session”
  /// (czyli z GameHost), podajesz callback.
  final void Function(int score)? onFinish;

  const MemoryGameScreen({super.key, this.onFinish});

  @override
  State<MemoryGameScreen> createState() => _MemoryGameScreenState();
}

class _MemoryGameScreenState extends State<MemoryGameScreen> {
  final List<String> _emojis = [
    '🍀', '🌸', '🍄', '🌞', '🌻', '🪴', '🍎', '🥕', '🎈', '🚗', '🏀', '🎮',
  ];

  List<String> _shuffledCards = [];
  List<bool> _cardFlipped = [];
  final List<int> _selectedIndices = [];

  bool _canTap = true;
  bool _gameCompleted = false;
  bool _timeExpired = false;

  int currentLevel = 1;
  int maxLevels = 50;

  int timeLeft = 60;
  Timer? countdownTimer;

  int startTime = 0; // startowy czas na poziom
  int mistakes = 0;

  @override
  void initState() {
    super.initState();
    _loadSavedLevel();
  }

  @override
  void dispose() {
    countdownTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadSavedLevel() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      currentLevel = prefs.getInt('memory_current_level') ?? 1;
    });
    _startLevel();
  }

  Future<void> _saveCurrentLevel() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('memory_current_level', currentLevel);
  }

  Future<void> _saveStats(int level, int timeSpent, int mistakeCount) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('memory_stats_time_$level', timeSpent);
    await prefs.setInt('memory_stats_mistakes_$level', mistakeCount);
  }

  void _startLevel() {
    final pairs = _calculatePairsForLevel(currentLevel);

    timeLeft = _calculateTimeForLevel(currentLevel);
    startTime = timeLeft;
    mistakes = 0;

    final cards = _emojis.sublist(0, pairs);
    _shuffledCards = [...cards, ...cards]..shuffle();

    _cardFlipped = List.filled(pairs * 2, false);
    _selectedIndices.clear();

    _gameCompleted = false;
    _timeExpired = false;
    _canTap = true;

    _startTimer();
    if (mounted) setState(() {});
  }

  int _calculatePairsForLevel(int level) {
    if (level <= 10) return 2 + (level ~/ 3);
    if (level <= 20) return 4 + ((level - 10) ~/ 2);
    if (level <= 30) return 6 + ((level - 20) ~/ 2);
    if (level <= 40) return 8 + ((level - 30) ~/ 2);
    return 10 + ((level - 40) ~/ 2);
  }

  int _calculateTimeForLevel(int level) {
    if (level <= 10) return 60 - (level * 2);
    if (level <= 20) return 50 - ((level - 10) * 2);
    if (level <= 30) return 40 - ((level - 20) * 2);
    if (level <= 40) return 30 - ((level - 30) * 2);
    return 25 - ((level - 40));
  }

  void _startTimer() {
    countdownTimer?.cancel();
    countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;

      setState(() {
        timeLeft--;
      });

      if (timeLeft <= 0) {
        timer.cancel();
        if (!mounted) return;
        setState(() {
          _timeExpired = true;
          _canTap = false;
        });
        _showLoseDialog();
      }
    });
  }

  int _timeSpentSoFar() {
    final raw = startTime - timeLeft;
    if (raw < 0) return 0;
    if (raw > startTime) return startTime;
    return raw;
  }

  int _calculateSessionScore({required bool completed}) {
    // Prosty, stabilny scoring do MVP (żeby Brain mógł zapisać wynik).
    final timeSpent = _timeSpentSoFar();
    final pairs = _calculatePairsForLevel(currentLevel);

    final base = currentLevel * 100;
    final bonusPairs = pairs * 10;
    final penalty = (mistakes * 15) + timeSpent;

    final completedBonus = completed ? 100 : 0; // mała nagroda za ukończenie poziomu
    return max(0, base + bonusPairs + completedBonus - penalty);
  }

  void _finishSession({required bool completed}) {
    countdownTimer?.cancel();
    final score = _calculateSessionScore(completed: completed);

    // Host Brain nagradza tylko faktycznie ukończoną sesję.
    if (widget.onFinish != null) {
      if (completed) {
        widget.onFinish!(score);
      } else if (mounted) {
        Navigator.of(context).maybePop();
      }
      return;
    }

    // Jeśli standalone (bez hosta) – tylko komunikat.
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Session finished. Score: $score')),
      );
    }
  }

  void _handleTap(int index) {
    if (_cardFlipped[index] ||
        !_canTap ||
        _gameCompleted ||
        _selectedIndices.contains(index) ||
        _timeExpired ||
        _shuffledCards[index] == '') {
      return;
    }

    setState(() {
      _cardFlipped[index] = true;
      _selectedIndices.add(index);
    });

    if (_selectedIndices.length == 2) {
      _canTap = false;

      Future.delayed(const Duration(milliseconds: 800), () {
        if (!mounted) return;

        final first = _selectedIndices[0];
        final second = _selectedIndices[1];

        setState(() {
          if (_shuffledCards[first] != _shuffledCards[second]) {
            _cardFlipped[first] = false;
            _cardFlipped[second] = false;
            mistakes++;
          } else {
            _shuffledCards[first] = '';
            _shuffledCards[second] = '';
            _cardFlipped[first] = false;
            _cardFlipped[second] = false;
          }

          _selectedIndices.clear();
          _canTap = true;

          if (_shuffledCards.every((card) => card == '')) {
            _gameCompleted = true;
            countdownTimer?.cancel();

            final timeSpent = _timeSpentSoFar();
            _saveStats(currentLevel, timeSpent, mistakes);

            _showWinDialog();
          }
        });
      });
    }
  }

  void _showLoseDialog() {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Next time you'll succeed!", style: TextStyle(fontFamily: 'Poppins')),
        content: const Text("Time's up. Try again.", style: TextStyle(fontFamily: 'Poppins')),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _startLevel();
            },
            child: const Text('Retry', style: TextStyle(fontFamily: 'Poppins')),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _finishSession(completed: false);
            },
            child: const Text('Finish session', style: TextStyle(fontFamily: 'Poppins')),
          ),
        ],
      ),
    );
  }

  void _showWinDialog() {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("🎉 Good job!", style: TextStyle(fontFamily: 'Poppins')),
        content: const Text("You've matched all cards.", style: TextStyle(fontFamily: 'Poppins')),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _finishSession(completed: true);
            },
            child: const Text('Finish session', style: TextStyle(fontFamily: 'Poppins')),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                if (currentLevel < maxLevels) {
                  currentLevel++;
                  _saveCurrentLevel();
                  _startLevel();
                }
              });
            },
            child: const Text('Next Level', style: TextStyle(fontFamily: 'Poppins')),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final embedded = widget.onFinish != null;
    const accent = Color(0xFF91A4EF);

    return Theme(
      data: AppTheme.premiumDark(),
      child: Scaffold(
        backgroundColor: ReleafColors.background,
        appBar: AppBar(
          toolbarHeight: 72,
          backgroundColor: const Color(0xE90A1018),
          surfaceTintColor: Colors.transparent,
          titleSpacing: 20,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'MEMORY',
                style: ReleafTypography.eyebrow.copyWith(
                  color: accent,
                  letterSpacing: 1.8,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Pattern Match',
                style: ReleafTypography.cardTitle.copyWith(fontSize: 17),
              ),
            ],
          ),
          actions: [
            if (embedded)
              IconButton(
                tooltip: 'Finish session',
                icon: const Icon(Icons.close_rounded),
                onPressed: () => _finishSession(completed: _gameCompleted),
              ),
          ],
        ),
        body: Stack(
          children: [
            const Positioned.fill(
              child: ReleafBrainArtwork(
                variant: ReleafBrainArtworkVariant.memory,
                intensity: 0.30,
              ),
            ),
            const Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xC5080E16),
                      Color(0xEE09100D),
                      ReleafColors.background,
                    ],
                    stops: [0, 0.45, 1],
                  ),
                ),
              ),
            ),
            SafeArea(
              top: false,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final compact = constraints.maxWidth < 360;

                  return Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.fromLTRB(
                          ReleafSpacing.screen,
                          compact ? ReleafSpacing.sm : ReleafSpacing.md,
                          ReleafSpacing.screen,
                          ReleafSpacing.sm,
                        ),
                        child: Wrap(
                          spacing: ReleafSpacing.xs,
                          runSpacing: ReleafSpacing.xs,
                          children: [
                            _MemoryStatusPill(
                              icon: Icons.layers_outlined,
                              label: 'Level $currentLevel',
                              accent: accent,
                            ),
                            _MemoryStatusPill(
                              icon: Icons.timer_outlined,
                              label: '${timeLeft}s',
                              accent: timeLeft <= 10
                                  ? const Color(0xFFE1A184)
                                  : accent,
                            ),
                            _MemoryStatusPill(
                              icon: Icons.refresh_rounded,
                              label: '$mistakes mistakes',
                              accent: ReleafColors.textSecondary,
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 620),
                            child: GridView.builder(
                              padding: const EdgeInsets.fromLTRB(
                                ReleafSpacing.screen,
                                ReleafSpacing.sm,
                                ReleafSpacing.screen,
                                ReleafSpacing.lg,
                              ),
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 4,
                                crossAxisSpacing: compact ? 7 : 10,
                                mainAxisSpacing: compact ? 7 : 10,
                              ),
                              itemCount: _shuffledCards.length,
                              itemBuilder: (context, index) {
                                if (_shuffledCards[index] == '') {
                                  return DecoratedBox(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: accent.withValues(alpha: 0.07),
                                      ),
                                    ),
                                  );
                                }

                                final isFlipped = _cardFlipped[index];

                                return Semantics(
                                  button: true,
                                  label: isFlipped
                                      ? 'Revealed memory card'
                                      : 'Hidden memory card',
                                  child: GestureDetector(
                                    onTap: () => _handleTap(index),
                                    child: AnimatedSwitcher(
                                      duration:
                                          const Duration(milliseconds: 260),
                                      transitionBuilder: (
                                        Widget child,
                                        Animation<double> animation,
                                      ) {
                                        final rotate =
                                            Tween(begin: pi, end: 0.0)
                                                .animate(animation);
                                        return AnimatedBuilder(
                                          animation: rotate,
                                          child: child,
                                          builder: (context, child) {
                                            final isUnder =
                                                ValueKey(isFlipped) != child!.key;
                                            final tilt = isUnder ? pi : 0.0;
                                            return Transform(
                                              transform: Matrix4.rotationY(
                                                tilt + rotate.value,
                                              ),
                                              alignment: Alignment.center,
                                              child: child,
                                            );
                                          },
                                        );
                                      },
                                      child: Container(
                                        key: ValueKey(isFlipped),
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(16),
                                          color: isFlipped
                                              ? const Color(0xFF202A46)
                                              : const Color(0xFF121A27),
                                          border: Border.all(
                                            color: isFlipped
                                                ? accent.withValues(alpha: 0.68)
                                                : accent.withValues(alpha: 0.18),
                                          ),
                                          boxShadow: isFlipped
                                              ? [
                                                  BoxShadow(
                                                    color: accent.withValues(
                                                      alpha: 0.15,
                                                    ),
                                                    blurRadius: 18,
                                                  ),
                                                ]
                                              : null,
                                        ),
                                        alignment: Alignment.center,
                                        child: isFlipped
                                            ? Text(
                                                _shuffledCards[index],
                                                style: TextStyle(
                                                  fontSize:
                                                      compact ? 24 : 28,
                                                ),
                                              )
                                            : Icon(
                                                Icons.blur_on_rounded,
                                                size: compact ? 19 : 22,
                                                color: accent.withValues(
                                                  alpha: 0.42,
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
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
        bottomNavigationBar: SafeArea(
          top: false,
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xF50B1119),
              border: Border(
                top: BorderSide(
                  color: accent.withValues(alpha: 0.14),
                ),
              ),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: ReleafSpacing.screen,
              vertical: ReleafSpacing.xs,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Match every pair before the timer ends.',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: ReleafTypography.meta.copyWith(
                      color: ReleafColors.textSecondary,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Reset level',
                  icon: const Icon(Icons.restart_alt_rounded),
                  onPressed: () {
                    countdownTimer?.cancel();
                    _startLevel();
                  },
                ),
                IconButton(
                  tooltip: 'Stats',
                  icon: const Icon(Icons.bar_chart_rounded),
                  onPressed: () async {
                    countdownTimer?.cancel();
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const MemoryStatsScreen(),
                      ),
                    );
                    _startTimer();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MemoryStatusPill extends StatelessWidget {
  const _MemoryStatusPill({
    required this.icon,
    required this.label,
    required this.accent,
  });

  final IconData icon;
  final String label;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xD9111823),
        borderRadius: BorderRadius.circular(ReleafRadii.pill),
        border: Border.all(color: accent.withValues(alpha: 0.20)),
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
}