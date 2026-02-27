import 'dart:async';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle, HapticFeedback;
import 'package:lottie/lottie.dart';

// ✅ Spójny result flow aplikacji (nagroda + powrót)
import '../../features/brain/presentation/game_result_screen.dart';

class LabirynthGameScreen extends StatefulWidget {
  const LabirynthGameScreen({super.key});
  @override
  State<LabirynthGameScreen> createState() => _LabirynthGameScreenState();
}

class _LabirynthGameScreenState extends State<LabirynthGameScreen>
    with SingleTickerProviderStateMixin {
  // ====== Poziomy ======
  final List<String> _prettyPaths = [
    'assets/games/labyrinth/level1.png',
    'assets/games/labyrinth/level2.png',
    'assets/games/labyrinth/level3.png',
    'assets/games/labyrinth/level4.png',
  ];
  final List<String> _maskPaths = [
    'assets/games/labyrinth/level1_mask.png',
    'assets/games/labyrinth/level2_mask.png',
    'assets/games/labyrinth/level3_mask.png',
    'assets/games/labyrinth/level4_mask.png',
  ];
  int _levelIndex = 0;
  int get _levelsCount => _prettyPaths.length;

  // Start/Meta (bazowe)
  static const Offset _startNorm = Offset(0.52, 0.92);
  static const Offset _finishNorm = Offset(0.49, 0.11);

  // ====== Rozmiary ======
  // Wizualny listek (duży – to co widzisz)
  static const double _leafVisualRadiusFrac = 0.035;
  // Kolizyjny promień (mniejszy – do przejścia korytarzami)
  static const double _leafHitRadiusFrac = 0.018;
  // Meta
  static const double _goalRadiusScreenFrac = 0.028;
  // Krok interpolacji ruchu
  static const double _stepScreenPx = 3.0;

  // Czas i statystyki
  static const int _levelSeconds = 60;
  int _timeLeft = _levelSeconds;
  int get _timeSpent => _levelSeconds - _timeLeft;
  int _wallHits = 0;

  // ✅ To jest lokalny wynik gry (NIE globalne Leaves)
  int _score = 0;

  bool _paused = false;

  Timer? _countdown;
  Timer? _ticker;

  // Obrazy/kolizje
  ui.Image? _mazePretty;
  ui.Image? _mazeMask;
  ByteData? _maskBytes;

  late Offset _ballImg;
  late Offset _finishImg;

  Rect _imageDstRect = Rect.zero;
  Size _lastCanvasSize = Size.zero;

  // Lottie – tempo „kroku”
  late final AnimationController _walkCtrl;
  static const int _walkBaseMs = 800;
  Offset? _dragLastImg;
  Offset _lastVelocityImg = Offset.zero;

  String? _loadError;

  @override
  void initState() {
    super.initState();
    assert(
    _prettyPaths.length == _maskPaths.length,
    'prettyPaths i maskPaths muszą mieć tę samą długość',
    );
    _walkCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: _walkBaseMs),
    )..repeat();
    _loadLevel();
  }

  @override
  void dispose() {
    _walkCtrl.dispose();
    _ticker?.cancel();
    _countdown?.cancel();
    super.dispose();
  }

  Future<void> _loadLevel() async {
    _countdown?.cancel();
    _ticker?.cancel();
    _paused = false;
    _timeLeft = _levelSeconds;
    _wallHits = 0;
    _lastVelocityImg = Offset.zero;
    _updateWalkSpeed();

    final prettyPath = _prettyPaths[_levelIndex];
    final maskPath = _maskPaths[_levelIndex];

    try {
      final prettyData = await rootBundle.load(prettyPath);
      final maskData = await rootBundle.load(maskPath);

      final prettyImg = await decodeImageFromList(
        prettyData.buffer.asUint8List(),
      );
      final maskImg = await decodeImageFromList(maskData.buffer.asUint8List());
      final bytes = await maskImg.toByteData(
        format: ui.ImageByteFormat.rawRgba,
      );

      _mazePretty = prettyImg;
      _mazeMask = maskImg;
      _maskBytes = bytes;

      _ballImg = Offset(
        _startNorm.dx * maskImg.width,
        _startNorm.dy * maskImg.height,
      );
      _finishImg = Offset(
        _finishNorm.dx * maskImg.width,
        _finishNorm.dy * maskImg.height,
      );

      _ballImg = _snapToNearestWalkable(
        _ballImg,
        searchRadius: (maskImg.width * 0.06).toInt(),
      );
      _finishImg = _snapToNearestWalkable(
        _finishImg,
        searchRadius: (maskImg.width * 0.06).toInt(),
      );
      _finishImg = _alignFinishToTopOpening(_finishImg);

      if ((_ballImg - _finishImg).distance < maskImg.width * 0.05) {
        _ballImg = _shiftAlongFreeSpace(
          _ballImg,
          preferredDir: const Offset(0, -1),
          pixels: (maskImg.width * 0.08).toInt(),
        );
      }

      _ticker = Timer.periodic(const Duration(milliseconds: 16), (_) {
        if (mounted && !_paused) setState(() {});
      });

      _countdown = Timer.periodic(const Duration(seconds: 1), (t) {
        if (!mounted || _paused) return;
        if (_timeLeft <= 0) {
          t.cancel();
          _onTimeUp();
        } else {
          setState(() => _timeLeft--);
        }
      });

      _loadError = null;
      if (mounted) setState(() {});
    } catch (e) {
      _loadError =
      'Nie wczytałem grafik dla L${_levelIndex + 1}:\n$prettyPath / $maskPath\n$e';
      if (mounted) setState(() {});
    }
  }

  // ====== Kolizje ======
  bool _isWalkable(Offset p) {
    if (_mazeMask == null || _maskBytes == null) return false;
    final w = _mazeMask!.width, h = _mazeMask!.height;
    final x = p.dx.round(), y = p.dy.round();
    if (x < 0 || x >= w || y < 0 || y >= h) return false;

    final idx = (y * w + x) * 4;
    final r = _maskBytes!.getUint8(idx);
    final g = _maskBytes!.getUint8(idx + 1);
    final b = _maskBytes!.getUint8(idx + 2);
    return (r + g + b) > 600; // białe = przejście
  }

  Offset _snapToNearestWalkable(Offset seed, {int searchRadius = 40}) {
    if (_isWalkable(seed)) return seed;
    final w = _mazeMask!.width, h = _mazeMask!.height;
    double best = double.infinity;
    Offset bestP = seed;
    final sx = seed.dx.round(), sy = seed.dy.round();

    for (int ry = -searchRadius; ry <= searchRadius; ry++) {
      final y = sy + ry;
      if (y < 0 || y >= h) continue;
      for (int rx = -searchRadius; rx <= searchRadius; rx++) {
        final x = sx + rx;
        if (x < 0 || x >= w) continue;
        final p = Offset(x.toDouble(), y.toDouble());
        if (_isWalkable(p)) {
          final d2 = (p - seed).distanceSquared;
          if (d2 < best) {
            best = d2;
            bestP = p;
          }
        }
      }
    }
    return bestP;
  }

  Offset _alignFinishToTopOpening(Offset nearTop) {
    final w = _mazeMask!.width;
    final x0 = nearTop.dx.round().clamp(0, w - 1);
    int bestX = x0, bestSpan = 0;
    for (int dx = -40; dx <= 40; dx++) {
      final xx = (x0 + dx).clamp(0, w - 1);
      if (_isWalkable(Offset(xx.toDouble(), 1))) {
        int span = 0, xxx = xx;
        while (xxx < w && _isWalkable(Offset(xxx.toDouble(), 1))) {
          span++;
          xxx++;
        }
        if (span > bestSpan) {
          bestSpan = span;
          bestX = xx + span ~/ 2;
        }
      }
    }
    return Offset(bestX.toDouble(), 8); // 8 px pod górą
  }

  Offset _shiftAlongFreeSpace(
      Offset from, {
        required Offset preferredDir,
        int pixels = 60,
      }) {
    final dir =
        preferredDir / (preferredDir.distance == 0 ? 1 : preferredDir.distance);
    var p = from;
    for (int i = 0; i < pixels; i++) {
      final np = p + dir;
      if (_isWalkable(np)) {
        p = np;
      } else {
        final a = math.pi / 8;
        final alt1 = p + _rot(dir, a);
        final alt2 = p + _rot(dir, -a);
        if (_isWalkable(alt1)) {
          p = alt1;
          continue;
        }
        if (_isWalkable(alt2)) {
          p = alt2;
          continue;
        }
        break;
      }
    }
    return p;
  }

  Offset _rot(Offset v, double ang) {
    final c = math.cos(ang), s = math.sin(ang);
    return Offset(v.dx * c - v.dy * s, v.dx * s + v.dy * c);
  }

  bool _canMoveBallTo(Offset imgP, double ballRadiusImgPx) {
    const samples = 10;
    for (int i = 0; i < samples; i++) {
      final a = (i / samples) * 2 * math.pi;
      final edge =
          imgP +
              Offset(ballRadiusImgPx * math.cos(a), ballRadiusImgPx * math.sin(a));
      if (!_isWalkable(edge)) return false;
    }
    return _isWalkable(imgP);
  }

  // ====== obraz ↔ ekran ======
  void _updateDstRect(Size canvasSize) {
    if (_mazePretty == null) return;
    if (_lastCanvasSize == canvasSize && _imageDstRect != Rect.zero) return;

    _lastCanvasSize = canvasSize;
    final imgW = _mazePretty!.width.toDouble(),
        imgH = _mazePretty!.height.toDouble();
    final cw = canvasSize.width, ch = canvasSize.height;
    final imgAspect = imgW / imgH, canvasAspect = cw / ch;

    if (canvasAspect > imgAspect) {
      final drawH = ch, drawW = drawH * imgAspect;
      _imageDstRect = Rect.fromLTWH((cw - drawW) / 2, 0, drawW, drawH);
    } else {
      final drawW = cw, drawH = drawW / imgAspect;
      _imageDstRect = Rect.fromLTWH(0, (ch - drawH) / 2, drawW, drawH);
    }
  }

  Offset _imgToScreen(Offset img) {
    final r = _imageDstRect;
    return Offset(
      r.left + (img.dx / _mazePretty!.width) * r.width,
      r.top + (img.dy / _mazePretty!.height) * r.height,
    );
  }

  Offset _screenToImg(Offset screen) {
    final r = _imageDstRect;
    return Offset(
      ((screen.dx - r.left) / r.width) * _mazePretty!.width,
      ((screen.dy - r.top) / r.height) * _mazePretty!.height,
    );
  }

  // ====== Gesty ======
  void _onPanStart(DragStartDetails d) {
    if (_mazePretty == null || _paused) return;

    final ballScreen = _imgToScreen(_ballImg);
    final start = d.localPosition;

    final captureRadius =
        (_leafVisualRadiusFrac * _imageDstRect.shortestSide) * 3.0;

    if ((start - ballScreen).distance > captureRadius) {
      _dragLastImg = null;
      return;
    }
    _dragLastImg = _ballImg;
  }

  void _onPanUpdate(DragUpdateDetails d) {
    if (_mazePretty == null || _paused) return;
    if (_dragLastImg == null) return;

    final scale = _imageDstRect.width / _mazePretty!.width;
    final imgStep = _stepScreenPx / scale;

    final nextImg = _screenToImg(d.localPosition);
    final delta = nextImg - _dragLastImg!;
    final steps = (delta.distance / imgStep).clamp(1, 100).ceil();

    final ballHitRScreen = _leafHitRadiusFrac * _imageDstRect.shortestSide;
    final ballRadiusImg = ballHitRScreen / scale;

    bool hitWallThisUpdate = false;
    for (int i = 1; i <= steps; i++) {
      final p = _dragLastImg! + delta * (i / steps);
      if (_canMoveBallTo(p, ballRadiusImg)) {
        _ballImg = p;
      } else {
        HapticFeedback.lightImpact();
        hitWallThisUpdate = true;
        break;
      }
    }
    if (hitWallThisUpdate) _wallHits++;

    _lastVelocityImg = delta / math.max(1, steps).toDouble();
    _dragLastImg = _ballImg;

    _updateWalkSpeed();
    setState(() {});
    _checkWin();
  }

  void _onPanEnd(DragEndDetails d) {
    _dragLastImg = null;
    _lastVelocityImg = Offset.zero;
    _updateWalkSpeed();
  }

  // ====== Sterowanie tempem kroków Lottie ======
  void _updateWalkSpeed() {
    if (_paused) {
      _walkCtrl.stop();
      return;
    }
    final v = _lastVelocityImg.distance;
    final factor = (1 + v * 0.6);
    final ms = (_walkBaseMs / factor).clamp(280, 1200).toInt();
    _walkCtrl.duration = Duration(milliseconds: ms);
    if (!_walkCtrl.isAnimating) _walkCtrl.repeat();
  }

  // ====== Pauza ======
  void _togglePause() {
    setState(() => _paused = !_paused);
    _updateWalkSpeed();
  }

  // ====== Win / Fail ======
  void _checkWin() {
    if (_mazePretty == null || _paused) return;

    final scale = _imageDstRect.width / _mazePretty!.width;

    final ballRadiusImg =
        (_leafHitRadiusFrac * _imageDstRect.shortestSide) / scale;
    final goalRadiusImg =
        (_goalRadiusScreenFrac * _imageDstRect.shortestSide) / scale;

    final dist = (_ballImg - _finishImg).distance;
    final touches = dist <= (goalRadiusImg + ballRadiusImg) * 1.10;

    if (touches) {
      _countdown?.cancel();
      HapticFeedback.mediumImpact();

      final timeBonus = (_timeLeft ~/ 10);
      final accuracyBonus = math.max(0, 3 - (_wallHits ~/ 5));
      final earned = 5 + timeBonus + accuracyBonus;

      // ✅ Score zamiast “leaves”
      _score += earned;

      _showLevelCompleteDialog(earned: earned);
    }
  }

  void _onTimeUp() {
    HapticFeedback.mediumImpact();
    _showFailDialog();
  }

  // ====== Dialogi ======
  void _showLevelCompleteDialog({required int earned}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => _PauseOrResultCard(
        title: 'Level Complete',
        subtitle: 'Great job!',
        stats: [
          _StatRow(label: 'Time', value: '${_timeSpent}s'),
          _StatRow(label: 'Wall hits', value: '$_wallHits'),
          _StatRow(label: 'Score earned', value: '+$earned'),
        ],
        primaryText: (_levelIndex < _levelsCount - 1) ? 'Next' : 'Finish',
        onPrimary: () {
          Navigator.of(context).pop();
          if (_levelIndex < _levelsCount - 1) {
            setState(() => _levelIndex++);
            _loadLevel();
          } else {
            // ✅ KONIEC SESJI — spójny result flow aplikacji
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (_) => GameResultScreen(score: _score),
              ),
            );
          }
        },
        secondaryText: 'Retry',
        onSecondary: () {
          Navigator.of(context).pop();
          _loadLevel();
        },
        tertiaryText: 'Home',
        onTertiary: () {
          Navigator.of(context).pop();      // zamknij dialog
          Navigator.of(context).maybePop(); // wyjdź z gry
        },
      ),
    );
  }

  void _showFailDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => _PauseOrResultCard(
        title: 'Time up',
        subtitle: 'Spróbuj jeszcze raz.',
        stats: [
          _StatRow(label: 'Time', value: '${_timeSpent}s'),
          _StatRow(label: 'Wall hits', value: '$_wallHits'),
        ],
        primaryText: 'Retry',
        onPrimary: () {
          Navigator.of(context).pop();
          _loadLevel();
        },
        secondaryText: 'Home',
        onSecondary: () {
          Navigator.of(context).pop();      // zamknij dialog
          Navigator.of(context).maybePop(); // wyjdź z gry
        },
      ),
    );
  }

  // ====== UI ======
  @override
  Widget build(BuildContext context) {
    if (_loadError != null) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              _loadError!,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ),
      );
    }

    final ready = _mazePretty != null && _mazeMask != null;

    return Scaffold(
      backgroundColor: const Color(0xFF0E0F11),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, c) {
            if (!ready) return const Center(child: CircularProgressIndicator());

            final canvasSize = Size(c.maxWidth, c.maxHeight);
            _updateDstRect(canvasSize);

            final leafVisualR =
                _leafVisualRadiusFrac * _imageDstRect.shortestSide;
            final goalRScreen =
                _goalRadiusScreenFrac * _imageDstRect.shortestSide;

            final ballScreen = _imgToScreen(_ballImg);
            final finishScreen = _imgToScreen(_finishImg);

            final isCompact = MediaQuery.sizeOf(context).width < 380;

            return Stack(
              children: [
                // Maze
                CustomPaint(
                  size: canvasSize,
                  painter: _MazePainter(
                    image: _mazePretty!,
                    dstRect: _imageDstRect,
                  ),
                ),

                // Gradient pod HUD
                Positioned(
                  left: 0,
                  right: 0,
                  top: 0,
                  child: IgnorePointer(
                    child: Container(
                      height: 88,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Color(0xCC0E0F11), Color(0x000E0F11)],
                        ),
                      ),
                    ),
                  ),
                ),

                // HUD
                Positioned(
                  left: 12,
                  right: 12,
                  top: 8,
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    alignment: WrapAlignment.spaceBetween,
                    children: [
                      _HudPill(
                        icon: Icons.eco,
                        label: 'Score',
                        value: '$_score',
                        compact: isCompact,
                      ),
                      _HudPill(
                        icon: Icons.timer_outlined,
                        label: 'Time',
                        value: '$_timeLeft s',
                        compact: isCompact,
                      ),
                      _HudPill(
                        icon: Icons.flag_outlined,
                        label: 'Level',
                        value: 'L${_levelIndex + 1}/$_levelsCount',
                        compact: isCompact,
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _CircleIconBtn(
                            icon: _paused ? Icons.play_arrow : Icons.pause,
                            size: isCompact ? 34 : 36,
                            onTap: () {
                              _togglePause();
                              if (_paused) {
                                showDialog(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (_) => _PauseOrResultCard(
                                    title: 'Paused',
                                    subtitle: 'Zatrzymano grę',
                                    stats: [
                                      _StatRow(
                                        label: 'Time',
                                        value: '${_timeSpent}s',
                                      ),
                                      _StatRow(
                                        label: 'Wall hits',
                                        value: '$_wallHits',
                                      ),
                                    ],
                                    primaryText: 'Resume',
                                    onPrimary: () {
                                      Navigator.of(context).pop();
                                      _togglePause();
                                    },
                                    secondaryText: 'Retry',
                                    onSecondary: () {
                                      Navigator.of(context).pop();
                                      _loadLevel();
                                    },
                                    tertiaryText: 'Home',
                                    onTertiary: () {
                                      Navigator.of(context).pop();
                                      Navigator.of(context).maybePop();
                                    },
                                  ),
                                ).then((_) {
                                  if (_paused) _paused = false;
                                });
                              }
                            },
                          ),
                          const SizedBox(width: 6),
                          _CircleIconBtn(
                            icon: Icons.close,
                            size: isCompact ? 34 : 36,
                            onTap: () => Navigator.of(context).maybePop(),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // META
                Positioned(
                  left: finishScreen.dx - goalRScreen,
                  top: finishScreen.dy - goalRScreen,
                  child: Container(
                    width: goalRScreen * 2,
                    height: goalRScreen * 2,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.orangeAccent.withOpacity(0.95),
                      border: Border.all(width: 3, color: Colors.white),
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 14,
                          spreadRadius: 5,
                          color: Colors.orangeAccent.withOpacity(0.55),
                        ),
                      ],
                    ),
                  ),
                ),

                // Gracz
                Positioned(
                  left: ballScreen.dx - leafVisualR,
                  top: ballScreen.dy - leafVisualR,
                  child: IgnorePointer(
                    child: _WalkerMarker(
                      size: leafVisualR * 2,
                      controller: _walkCtrl,
                      dimmed: _paused,
                    ),
                  ),
                ),

                // Gesty
                Positioned.fill(
                  child: IgnorePointer(
                    ignoring: _paused,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onPanStart: _onPanStart,
                      onPanUpdate: _onPanUpdate,
                      onPanEnd: _onPanEnd,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

// ====== Painter ======
class _MazePainter extends CustomPainter {
  final ui.Image image;
  final Rect dstRect;
  const _MazePainter({required this.image, required this.dstRect});

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = const Color(0xFF0E0F11),
    );
    final src = Rect.fromLTWH(
      0,
      0,
      image.width.toDouble(),
      image.height.toDouble(),
    );
    final paint = Paint()
      ..isAntiAlias = true
      ..filterQuality = FilterQuality.high;
    canvas.drawImageRect(image, src, dstRect, paint);
  }

  @override
  bool shouldRepaint(covariant _MazePainter old) =>
      old.image != image || old.dstRect != dstRect;
}

// ====== HUD ======
class _HudPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool compact;
  const _HudPill({
    required this.icon,
    required this.label,
    required this.value,
    this.compact = false,
  });
  @override
  Widget build(BuildContext context) {
    final padV = compact ? 6.0 : 8.0;
    final padH = compact ? 10.0 : 12.0;
    final labelSize = compact ? 12.0 : 13.0;
    final valueSize = compact ? 13.0 : 14.0;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: padH, vertical: padV),
      decoration: BoxDecoration(
        color: const Color(0xE016191D),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withOpacity(0.12)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.35),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: compact ? 14 : 16, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: Colors.white,
              fontSize: labelSize,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            value,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontWeight: FontWeight.w800,
              color: Colors.white,
              fontSize: valueSize,
            ),
          ),
        ],
      ),
    );
  }
}

class _CircleIconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final double size;
  const _CircleIconBtn({
    required this.icon,
    required this.onTap,
    this.size = 36,
  });
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: const Color(0xE016191D),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withOpacity(0.12)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.35),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, size: size * 0.5, color: Colors.white),
      ),
    );
  }
}

// ====== Marker gracza (Lottie) ======
class _WalkerMarker extends StatelessWidget {
  final double size;
  final AnimationController controller;
  final bool dimmed;

  const _WalkerMarker({
    required this.size,
    required this.controller,
    this.dimmed = false,
  });

  @override
  Widget build(BuildContext context) {
    final shadowOpacity = dimmed ? 0.25 : 0.35;
    final glowOpacity = dimmed ? 0.25 : 0.45;
    final lottieSize = size * 1.18;

    return Opacity(
      opacity: dimmed ? 0.6 : 1,
      child: SizedBox(
        width: size,
        height: size,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            Container(
              width: size * 0.95,
              height: size * 0.95,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF000000).withOpacity(0.01),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(shadowOpacity),
                    blurRadius: size * 0.24,
                    spreadRadius: size * 0.02,
                    offset: Offset(0, size * 0.06),
                  ),
                  BoxShadow(
                    color: const Color(0xFF7CFF78).withOpacity(glowOpacity),
                    blurRadius: size * 0.30,
                    spreadRadius: size * 0.02,
                    offset: const Offset(0, 0),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: lottieSize,
              height: lottieSize,
              child: Lottie.asset(
                'assets/animations/leaf_walk.json',
                controller: controller,
                repeat: true,
                fit: BoxFit.contain,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ====== Karta: Pauza / Wynik ======
class _PauseOrResultCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<_StatRow> stats;
  final String primaryText;
  final VoidCallback onPrimary;
  final String? secondaryText;
  final VoidCallback? onSecondary;
  final String? tertiaryText;
  final VoidCallback? onTertiary;

  const _PauseOrResultCard({
    required this.title,
    required this.subtitle,
    required this.stats,
    required this.primaryText,
    required this.onPrimary,
    this.secondaryText,
    this.onSecondary,
    this.tertiaryText,
    this.onTertiary,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF111214),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            subtitle,
            style: TextStyle(color: Colors.white.withOpacity(0.8)),
          ),
          const SizedBox(height: 12),
          ...stats.map(
                (s) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: s,
            ),
          ),
        ],
      ),
      actions: [
        if (tertiaryText != null && onTertiary != null)
          TextButton(onPressed: onTertiary, child: Text(tertiaryText!)),
        if (secondaryText != null && onSecondary != null)
          TextButton(onPressed: onSecondary, child: Text(secondaryText!)),
        FilledButton(onPressed: onPrimary, child: Text(primaryText)),
      ],
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final String value;
  const _StatRow({required this.label, required this.value});
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w800)),
      ],
    );
  }
}