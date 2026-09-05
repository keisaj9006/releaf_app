// FILE: lib/screens/broken_mirror_game_screen.dart
import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show HapticFeedback;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/progress/data/leaves_repository.dart';
import '../../theme/app_theme.dart';
import '../../theme/releaf_design_tokens.dart';
import '../../theme/widgets/releaf_brain_artwork.dart';

class BrokenMirrorGameScreen extends ConsumerStatefulWidget {
  const BrokenMirrorGameScreen({
    super.key,
    this.level = 1,
    this.enableTimer = false,
    this.seconds = 60,
    this.onFinish,
  });

  final int level;
  final bool enableTimer;
  final int seconds;
  final VoidCallback? onFinish;

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

    // Legacy entry points keep their existing reward. The canonical Brain host
    // delegates the reward to GameResultScreen.
    if (widget.onFinish == null) {
      final result =
          await ref.read(leavesNotifierProvider.notifier).markBrainDone();

      if (mounted && result != null) {
        final msg = result.hasBonus
            ? '+${result.totalAdded} leaves • Perfect day bonus!'
            : '+${result.totalAdded} leaves';

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg)),
        );
      }
    }

    if (!mounted) return;
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => _WinDialog(level: widget.level),
    );

    if (!mounted) return;
    if (widget.onFinish != null) {
      widget.onFinish!();
    } else {
      Navigator.of(context).pop();
    }
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
    final availableWidth = math.max(
      180.0,
      c.maxWidth - (ReleafSpacing.screen * 2) - 24,
    );
    final availableHeight = math.max(180.0, c.maxHeight - 220);
    final size = math.min(
      620.0,
      math.min(availableWidth, availableHeight),
    );
    return Size(size, size);
  }

  @override
  Widget build(BuildContext context) {
    final embedded = widget.onFinish != null;
    final leaves = ref.watch(leavesNotifierProvider).totalLeaves;
    const accent = Color(0xFFD490B9);

    return Theme(
      data: AppTheme.premiumDark(),
      child: LayoutBuilder(
        builder: (_, constraints) {
          _boardSize = _resolveBoardSize(constraints);

          return Scaffold(
            backgroundColor: ReleafColors.background,
            appBar: AppBar(
              toolbarHeight: 72,
              backgroundColor: const Color(0xE90E0C12),
              surfaceTintColor: Colors.transparent,
              titleSpacing: 20,
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'VISUAL RECONSTRUCTION',
                    style: ReleafTypography.eyebrow.copyWith(
                      color: accent,
                      letterSpacing: 1.7,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Broken Mirror',
                    style: ReleafTypography.cardTitle.copyWith(fontSize: 17),
                  ),
                ],
              ),
              actions: [
                if (!embedded) _LeavesPill(total: leaves),
                if (widget.enableTimer) ...[
                  const SizedBox(width: 6),
                  _TimerPill(secondsLeft: _timeLeft),
                ],
                IconButton(
                  tooltip: 'Exit Broken Mirror',
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.of(context).maybePop(),
                ),
              ],
            ),
            body: Stack(
              children: [
                const Positioned.fill(
                  child: ReleafBrainArtwork(
                    variant: ReleafBrainArtworkVariant.brokenMirror,
                    intensity: 0.36,
                  ),
                ),
                const Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color(0xB80E0C12),
                          Color(0xEC0B0D0E),
                          ReleafColors.background,
                        ],
                        stops: [0, 0.48, 1],
                      ),
                    ),
                  ),
                ),
                SafeArea(
                  top: false,
                  child: Center(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(
                        ReleafSpacing.screen,
                        ReleafSpacing.md,
                        ReleafSpacing.screen,
                        ReleafSpacing.xl,
                      ),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 680),
                        child: Column(
                          children: [
                            _BoardFrame(
                              accent: accent,
                              child: KeyedSubtree(
                                key: const Key('broken-mirror-board'),
                                child: SizedBox(
                                  key: _boardKey,
                                  width: _boardSize.width,
                                  height: _boardSize.height,
                                  child: Stack(
                                    clipBehavior: Clip.none,
                                    children: [
                                      Positioned.fill(
                                        child: CustomPaint(
                                          painter: _TargetPainter(_shards),
                                        ),
                                      ),
                                      for (final shard in _shards)
                                        _DraggableShard(
                                          shard: shard,
                                          pulse: _pulse,
                                          boardSize: _boardSize,
                                          onUpdate: (updated) {
                                            setState(() {
                                              final idx = _shards.indexWhere(
                                                (s) => s.id == updated.id,
                                              );
                                              _shards[idx] = updated;
                                            });
                                            _checkWin();
                                          },
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: ReleafSpacing.lg),
                            Text(
                              widget.enableTimer
                                  ? 'Place every fragment before time runs out.'
                                  : 'Drag each fragment into its matching place.',
                              textAlign: TextAlign.center,
                              style: ReleafTypography.body.copyWith(
                                color: ReleafColors.textPrimary.withValues(
                                  alpha: 0.82,
                                ),
                              ),
                            ),
                            const SizedBox(height: ReleafSpacing.xs),
                            Text(
                              'Fragments lock into place when you are close enough.',
                              textAlign: TextAlign.center,
                              style: ReleafTypography.meta.copyWith(
                                color: ReleafColors.textMuted,
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
          );
        },
      ),
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
      margin: const EdgeInsets.symmetric(vertical: 12),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: ReleafColors.sage.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(ReleafRadii.pill),
        border: Border.all(
          color: ReleafColors.sage.withValues(alpha: 0.18),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.eco_outlined, size: 15, color: ReleafColors.sage),
          const SizedBox(width: 5),
          Text(
            '$total',
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

class _TimerPill extends StatelessWidget {
  const _TimerPill({required this.secondsLeft});
  final int secondsLeft;

  @override
  Widget build(BuildContext context) {
    final urgent = secondsLeft <= 10;
    final accent =
        urgent ? const Color(0xFFE1A184) : const Color(0xFFD490B9);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(ReleafRadii.pill),
        border: Border.all(color: accent.withValues(alpha: 0.20)),
      ),
      child: Text(
        '${secondsLeft}s',
        style: ReleafTypography.meta.copyWith(
          color: accent,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _BoardFrame extends StatelessWidget {
  final Widget child;
  final Color accent;

  const _BoardFrame({
    required this.child,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xF0151319),
        borderRadius: BorderRadius.circular(ReleafRadii.extraLarge),
        border: Border.all(color: accent.withValues(alpha: 0.22)),
        boxShadow: [
          BoxShadow(
            blurRadius: 32,
            offset: const Offset(0, 14),
            color: accent.withValues(alpha: 0.08),
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
    for (final s in shards) {
      final path = Path();
      final first = s.polygon.first;
      path.moveTo(first.dx * size.width, first.dy * size.height);
      for (final p in s.polygon.skip(1)) {
        path.lineTo(p.dx * size.width, p.dy * size.height);
      }
      path.close();

      if (s.placed) {
        canvas.drawPath(
          path,
          Paint()
            ..style = PaintingStyle.fill
            ..color = const Color(0xFFD490B9).withValues(alpha: 0.18),
        );
      }

      canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = s.placed ? 2.4 : 1.4
          ..color = const Color(0xFFD490B9).withValues(
            alpha: s.placed ? 0.62 : 0.16,
          ),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _TargetPainter oldDelegate) => true;
}

class _DraggableShard extends StatefulWidget {
  const _DraggableShard({
    required this.shard,
    required this.pulse,
    required this.boardSize,
    required this.onUpdate,
  });

  final _Shard shard;
  final AnimationController pulse;
  final Size boardSize;
  final void Function(_Shard) onUpdate;

  @override
  State<_DraggableShard> createState() => _DraggableShardState();
}

class _DraggableShardState extends State<_DraggableShard> {
  static const _shardSize = 120.0;

  late Offset _position;
  bool _dragging = false;

  @override
  void initState() {
    super.initState();
    _position = widget.shard.position;
  }

  @override
  void didUpdateWidget(covariant _DraggableShard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_dragging && oldWidget.shard.position != widget.shard.position) {
      _position = widget.shard.position;
    }
  }

  void _updatePosition(Offset delta) {
    final next = _position + delta;
    setState(() => _position = next);
    widget.onUpdate(widget.shard.copyWith(position: next));
  }

  void _finishDrag() {
    _dragging = false;

    const half = _shardSize / 2;
    final target = Offset(
      widget.shard.targetCenter.dx * widget.boardSize.width,
      widget.shard.targetCenter.dy * widget.boardSize.height,
    );
    final currentCenter = _position + const Offset(half, half);
    final snapDistance =
        math.max(38.0, widget.boardSize.shortestSide * 0.12);

    if ((currentCenter - target).distance <= snapDistance) {
      HapticFeedback.selectionClick();
      widget.onUpdate(
        widget.shard.copyWith(
          position: target - const Offset(half, half),
          placed: true,
        ),
      );
      return;
    }

    widget.onUpdate(widget.shard.copyWith(position: _position));
  }

  @override
  Widget build(BuildContext context) {
    if (widget.shard.placed) return const SizedBox.shrink();

    return Positioned(
      left: _position.dx,
      top: _position.dy,
      child: GestureDetector(
        key: ValueKey('broken-mirror-shard-${widget.shard.id}'),
        onPanStart: (_) => _dragging = true,
        onPanUpdate: (details) => _updatePosition(details.delta),
        onPanEnd: (_) => _finishDrag(),
        onPanCancel: _finishDrag,
        child: AnimatedBuilder(
          animation: widget.pulse,
          builder: (_, child) {
            final glow = 0.10 + widget.pulse.value * 0.14;
            return DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFD490B9).withValues(alpha: glow),
                    blurRadius: 18,
                  ),
                ],
              ),
              child: child,
            );
          },
          child: CustomPaint(
            size: const Size.square(_shardSize),
            painter: _ShardPainter(widget.shard),
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
      ..color = const Color(0xFFD490B9).withValues(alpha: 0.16);

    final border = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = const Color(0xFFD490B9).withValues(alpha: 0.54);

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
