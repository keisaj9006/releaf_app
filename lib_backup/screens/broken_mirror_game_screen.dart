// FILE: lib/screens/broken_mirror_game_screen.dart
import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show HapticFeedback;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/progress/data/leaves_repository.dart';

class BrokenMirrorGameScreen extends ConsumerStatefulWidget {
  const BrokenMirrorGameScreen({
    super.key,
    this.level = 1,
    this.enableTimer = false,
    this.seconds = 60,
  });

  final int level;
  final bool enableTimer;
  final int seconds;

  @override
  ConsumerState<BrokenMirrorGameScreen> createState() =>
      _BrokenMirrorGameScreenState();
}

class _BrokenMirrorGameScreenState extends ConsumerState<BrokenMirrorGameScreen>
    with TickerProviderStateMixin {
  final GlobalKey _boardKey = GlobalKey();

  late List<_Shard> _shards;
  late Size _boardSize;
  bool _won = false;
  int _timeLeft = 0;
  Timer? _timer;
  late AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _timeLeft = widget.seconds;
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    _initLevel();
    if (widget.enableTimer) _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulse.dispose();
    super.dispose();
  }

  // ---------- LEVEL SETUP ----------
  void _initLevel() {
    final shards = <_Shard>[
      _Shard(
        id: 0,
        polygon: const [
          Offset(0.10, 0.10),
          Offset(0.45, 0.08),
          Offset(0.40, 0.28),
          Offset(0.18, 0.25),
        ],
        targetCenter: const Offset(0.28, 0.18),
      ),
      _Shard(
        id: 1,
        polygon: const [
          Offset(0.46, 0.08),
          Offset(0.80, 0.12),
          Offset(0.72, 0.28),
          Offset(0.40, 0.28),
        ],
        targetCenter: const Offset(0.60, 0.20),
      ),
      _Shard(
        id: 2,
        polygon: const [
          Offset(0.15, 0.28),
          Offset(0.38, 0.30),
          Offset(0.34, 0.52),
          Offset(0.12, 0.48),
        ],
        targetCenter: const Offset(0.24, 0.40),
      ),
      _Shard(
        id: 3,
        polygon: const [
          Offset(0.40, 0.30),
          Offset(0.72, 0.30),
          Offset(0.68, 0.50),
          Offset(0.36, 0.52),
        ],
        targetCenter: const Offset(0.53, 0.41),
      ),
      _Shard(
        id: 4,
        polygon: const [
          Offset(0.10, 0.50),
          Offset(0.34, 0.54),
          Offset(0.30, 0.82),
          Offset(0.12, 0.78),
        ],
        targetCenter: const Offset(0.22, 0.66),
      ),
      _Shard(
        id: 5,
        polygon: const [
          Offset(0.36, 0.54),
          Offset(0.70, 0.52),
          Offset(0.78, 0.82),
          Offset(0.30, 0.82),
        ],
        targetCenter: const Offset(0.55, 0.68),
      ),
    ];

    _shards = shards
        .map((s) => s.copyWith(
      position: Offset(
        20 + math.Random().nextDouble() * 120,
        20 + math.Random().nextDouble() * 120,
      ),
    ))
        .toList();
  }

  void _startTimer() {
    _timer?.cancel();
    _timeLeft = widget.seconds;
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      setState(() => _timeLeft--);
      if (_timeLeft <= 0) {
        t.cancel();
        _onFail();
      }
    });
  }

  void _checkWin() {
    if (_shards.every((s) => s.placed)) _onWin();
  }

  Future<void> _onWin() async {
    if (_won) return;
    setState(() => _won = true);
    _timer?.cancel();

    await HapticFeedback.mediumImpact();

    // ✅ JEDYNY system nagród: Brain done (raz dziennie) + reward/bonus w repo
    final result = await ref.read(leavesNotifierProvider.notifier).markBrainDone();

    if (mounted && result != null) {
      final msg = result.hasBonus
          ? '+${result.totalAdded} leaves • Perfect day bonus!'
          : '+${result.totalAdded} leaves';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg)),
      );
    }

    if (!mounted) return;
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => _WinDialog(level: widget.level),
    );

    if (!mounted) return;
    Navigator.of(context).pop(); // wróć do listy gier / poprzedniego ekranu
  }

  void _onFail() async {
    await HapticFeedback.heavyImpact();
    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => _FailDialog(
        onRetry: () {
          Navigator.of(context).pop();
          setState(() {
            _won = false;
            _initLevel();
            if (widget.enableTimer) _startTimer();
          });
        },
        onExit: () => Navigator.of(context).maybePop(),
      ),
    );
  }

  Size _resolveBoardSize(BoxConstraints c) {
    final w = c.maxWidth;
    final h = c.maxHeight;
    final size = math.min(w, h - 170);
    return Size(size, size);
  }

  @override
  Widget build(BuildContext context) {
    final leaves = ref.watch(leavesNotifierProvider).totalLeaves;

    return LayoutBuilder(
      builder: (_, constraints) {
        _boardSize = _resolveBoardSize(constraints);

        return Scaffold(
          backgroundColor: const Color(0xFFEBF4EE),
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0.5,
            title: Row(
              children: [
                const Text(
                  "Broken Mirror",
                  style: TextStyle(color: Colors.black),
                ),
                const SizedBox(width: 10),

                // ✅ spójny licznik liści
                _LeavesPill(total: leaves),

                const Spacer(),
                if (widget.enableTimer) _TimerPill(secondsLeft: _timeLeft),
              ],
            ),
            iconTheme: const IconThemeData(color: Colors.black),
            actions: [
              // P0 “minimize” = na razie po prostu wyjdź (resume zrobimy później)
              IconButton(
                tooltip: 'Minimize',
                icon: const Icon(Icons.horizontal_rule),
                onPressed: () => Navigator.of(context).maybePop(),
              ),
              IconButton(
                tooltip: 'Close',
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).maybePop(),
              ),
            ],
          ),
          body: Center(
            child: Column(
              children: [
                const SizedBox(height: 12),
                _BoardFrame(
                  child: SizedBox(
                    key: _boardKey,
                    width: _boardSize.width,
                    height: _boardSize.height,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        // target board
                        Positioned.fill(
                          child: CustomPaint(
                            painter: _TargetPainter(_shards),
                          ),
                        ),

                        // draggable shards
                        for (final shard in _shards)
                          _DraggableShard(
                            shard: shard,
                            pulse: _pulse,
                            onUpdate: (updated) {
                              setState(() {
                                final idx =
                                _shards.indexWhere((s) => s.id == updated.id);
                                _shards[idx] = updated;
                              });
                              _checkWin();
                            },
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    widget.enableTimer
                        ? "Place all shards before time runs out."
                        : "Place all shards to fix the mirror.",
                    style: const TextStyle(color: Colors.black87),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ---------------- UI bits ----------------

class _LeavesPill extends StatelessWidget {
  final int total;
  const _LeavesPill({required this.total});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6EF),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFF1E4D2B).withOpacity(0.15)),
      ),
      child: Row(
        children: [
          const Icon(Icons.eco, size: 16, color: Color(0xFF1E4D2B)),
          const SizedBox(width: 6),
          Text(
            "$total",
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: Color(0xFF1E4D2B),
            ),
          ),
        ],
      ),
    );
  }
}

class _TimerPill extends StatelessWidget {
  const _TimerPill({required this.secondsLeft});
  final int secondsLeft;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3F3),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.black.withOpacity(0.08)),
      ),
      child: Text(
        "${secondsLeft}s",
        style: const TextStyle(fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _BoardFrame extends StatelessWidget {
  final Widget child;
  const _BoardFrame({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            blurRadius: 25,
            offset: const Offset(0, 10),
            color: Colors.black.withOpacity(0.08),
          ),
        ],
      ),
      child: child,
    );
  }
}

// ---------------- Game model & painters ----------------

class _Shard {
  final int id;
  final List<Offset> polygon; // normalized 0..1
  final Offset targetCenter; // normalized
  final Offset position; // px
  final bool placed;

  const _Shard({
    required this.id,
    required this.polygon,
    required this.targetCenter,
    this.position = Offset.zero,
    this.placed = false,
  });

  _Shard copyWith({
    Offset? position,
    bool? placed,
  }) {
    return _Shard(
      id: id,
      polygon: polygon,
      targetCenter: targetCenter,
      position: position ?? this.position,
      placed: placed ?? this.placed,
    );
  }
}

class _TargetPainter extends CustomPainter {
  final List<_Shard> shards;
  _TargetPainter(this.shards);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = Colors.black.withOpacity(0.08);

    for (final s in shards) {
      final path = Path();
      final first = s.polygon.first;
      path.moveTo(first.dx * size.width, first.dy * size.height);
      for (final p in s.polygon.skip(1)) {
        path.lineTo(p.dx * size.width, p.dy * size.height);
      }
      path.close();
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _TargetPainter oldDelegate) => true;
}

class _DraggableShard extends StatelessWidget {
  const _DraggableShard({
    required this.shard,
    required this.pulse,
    required this.onUpdate,
  });

  final _Shard shard;
  final AnimationController pulse;
  final void Function(_Shard) onUpdate;

  @override
  Widget build(BuildContext context) {
    if (shard.placed) return const SizedBox.shrink();

    return Positioned(
      left: shard.position.dx,
      top: shard.position.dy,
      child: GestureDetector(
        onPanUpdate: (d) {
          onUpdate(shard.copyWith(position: shard.position + d.delta));
        },
        onPanEnd: (_) {
          // prosta logika “snap” do targetu
          final snap = (shard.targetCenter - const Offset(0.5, 0.5));
          // real snap robimy porządnie w kolejnej iteracji — tu minimalnie:
          // zostawiamy jak było (nie psujemy Twojej logiki).
        },
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.98, end: 1.02).animate(
            CurvedAnimation(parent: pulse, curve: Curves.easeInOut),
          ),
          child: CustomPaint(
            painter: _ShardPainter(shard),
            size: const Size(120, 120),
          ),
        ),
      ),
    );
  }
}

class _ShardPainter extends CustomPainter {
  final _Shard shard;
  _ShardPainter(this.shard);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = const Color(0xFF1E4D2B).withOpacity(0.12);

    final border = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = const Color(0xFF1E4D2B).withOpacity(0.35);

    final path = Path();
    final first = shard.polygon.first;
    path.moveTo(first.dx * size.width, first.dy * size.height);
    for (final p in shard.polygon.skip(1)) {
      path.lineTo(p.dx * size.width, p.dy * size.height);
    }
    path.close();

    canvas.drawPath(path, paint);
    canvas.drawPath(path, border);
  }

  @override
  bool shouldRepaint(covariant _ShardPainter oldDelegate) => true;
}

class _WinDialog extends StatelessWidget {
  final int level;
  const _WinDialog({required this.level});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Great job!"),
      content: Text("Level $level complete."),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text("OK"),
        ),
      ],
    );
  }
}

class _FailDialog extends StatelessWidget {
  final VoidCallback onRetry;
  final VoidCallback onExit;

  const _FailDialog({
    required this.onRetry,
    required this.onExit,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Time's up"),
      content: const Text("Try again?"),
      actions: [
        TextButton(onPressed: onExit, child: const Text("Exit")),
        FilledButton(onPressed: onRetry, child: const Text("Retry")),
      ],
    );
  }
}