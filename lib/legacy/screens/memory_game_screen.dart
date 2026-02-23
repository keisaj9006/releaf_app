import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math' show pi, max;
import 'package:shared_preferences/shared_preferences.dart';
import 'memory_stats_screen.dart';

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

  late List<String> _shuffledCards;
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

    // Jeśli uruchomione jako część Brain session → wołamy callback.
    if (widget.onFinish != null) {
      widget.onFinish!(score);
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

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF154314),
        title: const Text("Memory Game", style: TextStyle(color: Colors.white, fontFamily: 'Poppins')),
        centerTitle: true,
        actions: [
          if (embedded)
            IconButton(
              tooltip: 'Finish session',
              icon: const Icon(Icons.check_circle_outline, color: Colors.white),
              onPressed: () => _finishSession(completed: _gameCompleted),
            ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),
          Text("⏱️ Time Left: $timeLeft sec", style: const TextStyle(fontSize: 18)),
          const SizedBox(height: 10),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: _shuffledCards.length,
              itemBuilder: (context, index) {
                if (_shuffledCards[index] == '') return const SizedBox.shrink();

                final isFlipped = _cardFlipped[index];

                return GestureDetector(
                  onTap: () => _handleTap(index),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder: (Widget child, Animation<double> animation) {
                      final rotate = Tween(begin: pi, end: 0.0).animate(animation);
                      return AnimatedBuilder(
                        animation: rotate,
                        child: child,
                        builder: (context, child) {
                          final isUnder = (ValueKey(isFlipped) != child!.key);
                          final tilt = isUnder ? pi : 0.0;
                          return Transform(
                            transform: Matrix4.rotationY(tilt + rotate.value),
                            alignment: Alignment.center,
                            child: child,
                          );
                        },
                      );
                    },
                    child: Card(
                      key: ValueKey(isFlipped),
                      color: isFlipped ? Colors.green.shade100 : Colors.grey.shade300,
                      child: Center(
                        child: Text(
                          isFlipped ? _shuffledCards[index] : '',
                          style: const TextStyle(fontSize: 28),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        color: Colors.grey.shade100,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Level $currentLevel', style: const TextStyle(fontSize: 16, fontFamily: 'Poppins')),
            Row(
              children: [
                IconButton(
                  tooltip: 'Reset Level',
                  icon: const Icon(Icons.restart_alt),
                  onPressed: () {
                    countdownTimer?.cancel();
                    _startLevel();
                  },
                ),
                IconButton(
                  tooltip: 'Stats',
                  icon: const Icon(Icons.bar_chart),
                  onPressed: () async {
                    countdownTimer?.cancel();
                    await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const MemoryStatsScreen()),
                    );
                    _startTimer();
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}