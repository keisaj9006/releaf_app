import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sensors_plus/sensors_plus.dart';

import '../../features/brain/presentation/game_result_screen.dart';
import '../../theme/app_theme.dart';
import '../../theme/releaf_design_tokens.dart';

const double _labyrinthTiltMovementThreshold = 0.055;
const double _labyrinthAcceleration = 0.0115;
const double _labyrinthMovingDamping = 0.91;
const double _labyrinthIdleDamping = 0.88;
const double _labyrinthMaxSpeed = 0.058;
const double _labyrinthStopSpeed = 0.0012;
const double _labyrinthGoalRadius = 0.23;

@visibleForTesting
double labyrinthGoalCaptureRadiusForTesting() => _labyrinthGoalRadius;

@visibleForTesting
double labyrinthBallRadiusForLevel(int rawLevel) {
  final level = rawLevel.clamp(1, 12).toInt();
  final progress = (level - 1) / 11.0;
  return 0.19 - (0.05 * progress);
}

Offset _nextLabyrinthVelocity({
  required Offset velocity,
  required Offset tilt,
}) {
  var next = tilt.distance < _labyrinthTiltMovementThreshold
      ? velocity * _labyrinthIdleDamping
      : (velocity * _labyrinthMovingDamping) +
          (tilt * _labyrinthAcceleration);

  if (next.distance > _labyrinthMaxSpeed) {
    next = next / next.distance * _labyrinthMaxSpeed;
  }

  if (next.distance < _labyrinthStopSpeed) {
    return Offset.zero;
  }

  return next;
}

Offset _velocityAfterLabyrinthWallCollision(
  Offset velocity, {
  bool blockHorizontal = false,
  bool blockVertical = false,
}) {
  return Offset(
    blockHorizontal ? 0 : velocity.dx,
    blockVertical ? 0 : velocity.dy,
  );
}

@visibleForTesting
Offset labyrinthVelocityStepForTesting({
  required Offset velocity,
  required Offset tilt,
}) =>
    _nextLabyrinthVelocity(velocity: velocity, tilt: tilt);

@visibleForTesting
Offset labyrinthVelocityAfterWallCollisionForTesting(
  Offset velocity, {
  bool blockHorizontal = false,
  bool blockVertical = false,
}) =>
    _velocityAfterLabyrinthWallCollision(
      velocity,
      blockHorizontal: blockHorizontal,
      blockVertical: blockVertical,
    );

class LabirynthGameScreen extends StatefulWidget {
  const LabirynthGameScreen({
    super.key,
    this.onFinish,
    this.trainingLevel = 1,
    this.motionStream,
  });

  final ValueChanged<int>? onFinish;
  final int trainingLevel;

  /// Injectable for tests and future accessibility modes.
  final Stream<AccelerometerEvent>? motionStream;

  @override
  State<LabirynthGameScreen> createState() => _LabirynthGameScreenState();
}

class _LabirynthGameScreenState extends State<LabirynthGameScreen>
    with WidgetsBindingObserver {
  static const int _maxTrainingLevel = 12;
  static const double _wallThickness = 0.075;
  static const Duration _physicsStep = Duration(milliseconds: 16);
  static const int _motionCalibrationSampleTarget = 12;
  static const double _motionDeadZone = 0.08;

  late final _MazeLevel _level;
  late Offset _position;
  Offset _velocity = Offset.zero;
  Offset _tilt = Offset.zero;
  Offset _motionCalibrationSum = Offset.zero;
  Offset _motionBaseline = Offset.zero;
  int _motionCalibrationSamples = 0;

  Timer? _physicsTimer;
  Timer? _countdown;
  StreamSubscription<AccelerometerEvent>? _sensorSubscription;

  bool _started = false;
  bool _paused = false;
  bool _pausedByLifecycle = false;
  bool _finished = false;
  bool _motionAvailable = false;
  int _timeLeft = 0;
  int _wallHits = 0;
  DateTime _lastWallHaptic = DateTime.fromMillisecondsSinceEpoch(0);

  int get _levelNumber =>
      widget.trainingLevel.clamp(1, _maxTrainingLevel).toInt();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _level = _MazeLevel.generate(_levelNumber);
    _position = _level.start;
    _timeLeft = _level.timeLimitSeconds;
    _listenToMotion();
    _physicsTimer = Timer.periodic(_physicsStep, (_) => _tickPhysics());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _sensorSubscription?.cancel();
    _physicsTimer?.cancel();
    _countdown?.cancel();
    super.dispose();
  }

  void _listenToMotion() {
    if (kIsWeb) return;

    try {
      final stream = widget.motionStream ??
          accelerometerEventStream(
            samplingPeriod: SensorInterval.gameInterval,
          );

      _sensorSubscription = stream.listen(
        (event) {
          if (!mounted || _paused || _finished) return;

          final raw = Offset(event.x, event.y);
          if (_motionCalibrationSamples < _motionCalibrationSampleTarget) {
            _motionCalibrationSum += raw;
            _motionCalibrationSamples++;
            if (_motionCalibrationSamples == _motionCalibrationSampleTarget) {
              _motionBaseline = _motionCalibrationSum /
                  _motionCalibrationSampleTarget.toDouble();
              if (!_motionAvailable) {
                setState(() => _motionAvailable = true);
              }
            }
            return;
          }

          // Calibrate against the position in which the phone is naturally
          // held when the session opens. This prevents gravity/orientation
          // bias from starting the timer before an intentional tilt.
          final relative = raw - _motionBaseline;
          var next = Offset(
            (-relative.dx / 5.8).clamp(-1.0, 1.0).toDouble(),
            (relative.dy / 5.8).clamp(-1.0, 1.0).toDouble(),
          );

          if (next.distance < _motionDeadZone) {
            next = Offset.zero;
          }

          _tilt = Offset(
            (_tilt.dx * 0.68) + (next.dx * 0.32),
            (_tilt.dy * 0.68) + (next.dy * 0.32),
          );
          if (_tilt.distance < 0.025) {
            _tilt = Offset.zero;
          }
        },
        onError: (_) {
          _handleMotionFailure();
        },
      );
    } catch (_) {
      _handleMotionFailure();
    }
  }

  void _resetMotionCalibration() {
    _motionCalibrationSum = Offset.zero;
    _motionBaseline = Offset.zero;
    _motionCalibrationSamples = 0;
    _tilt = Offset.zero;
    _motionAvailable = false;
  }

  void _handleMotionFailure() {
    // Never keep applying a stale accelerometer vector after the sensor
    // stream fails. Touch control remains available and, if the stream later
    // recovers, fresh samples will calibrate a new neutral baseline.
    _velocity = Offset.zero;
    _resetMotionCalibration();
    if (mounted) {
      setState(() {});
    }
  }

  void _startTimerIfNeeded() {
    if (_started || _finished) return;

    _started = true;
    _countdown = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted || _paused || _finished) return;

      if (_timeLeft <= 1) {
        timer.cancel();
        setState(() => _timeLeft = 0);
        _showFailure();
        return;
      }

      setState(() => _timeLeft--);
    });

    if (mounted) setState(() {});
  }

  void _tickPhysics() {
    if (!mounted || _paused || _finished) return;

    final hasIntent = _tilt.distance >= _labyrinthTiltMovementThreshold;
    if (hasIntent) {
      _startTimerIfNeeded();
    }

    _velocity = _nextLabyrinthVelocity(
      velocity: _velocity,
      tilt: _tilt,
    );
    if (_velocity == Offset.zero) return;

    final moved = _attemptMove(_velocity);
    if (moved) {
      setState(() {});
      _checkGoal();
    }
  }

  bool _attemptMove(Offset delta) {
    if (delta.distance == 0) return false;

    final substeps = math.max(1, (delta.distance / 0.018).ceil()).toInt();
    final step = delta / substeps.toDouble();
    var moved = false;

    for (var i = 0; i < substeps; i++) {
      final horizontal = Offset(_position.dx + step.dx, _position.dy);
      if (_canOccupy(horizontal)) {
        _position = horizontal;
        moved = true;
      } else if (step.dx.abs() > 0.0001) {
        _registerWallHit();
        _velocity = _velocityAfterLabyrinthWallCollision(
          _velocity,
          blockHorizontal: true,
        );
      }

      final vertical = Offset(_position.dx, _position.dy + step.dy);
      if (_canOccupy(vertical)) {
        _position = vertical;
        moved = true;
      } else if (step.dy.abs() > 0.0001) {
        _registerWallHit();
        _velocity = _velocityAfterLabyrinthWallCollision(
          _velocity,
          blockVertical: true,
        );
      }
    }

    return moved;
  }

  void _onPanUpdate(DragUpdateDetails details, Size boardSize) {
    if (_paused || _finished) return;

    _startTimerIfNeeded();

    final delta = Offset(
      details.delta.dx / boardSize.width * _level.columns,
      details.delta.dy / boardSize.height * _level.rows,
    );

    _velocity = Offset.zero;
    if (_attemptMove(delta)) {
      setState(() {});
      _checkGoal();
    }
  }

  void _registerWallHit() {
    final now = DateTime.now();
    if (now.difference(_lastWallHaptic) < const Duration(milliseconds: 180)) {
      return;
    }

    _lastWallHaptic = now;
    _wallHits++;
    HapticFeedback.selectionClick();
    if (mounted) setState(() {});
  }

  bool _canOccupy(Offset point) {
    final r = labyrinthBallRadiusForLevel(_levelNumber) +
        (_wallThickness / 2);

    if (point.dx - r <= 0 ||
        point.dy - r <= 0 ||
        point.dx + r >= _level.columns ||
        point.dy + r >= _level.rows) {
      return false;
    }

    final minColumn = math.max(0, (point.dx - r).floor()).toInt();
    final maxColumn =
        math.min(_level.columns - 1, (point.dx + r).floor()).toInt();
    final minRow = math.max(0, (point.dy - r).floor()).toInt();
    final maxRow =
        math.min(_level.rows - 1, (point.dy + r).floor()).toInt();

    for (var row = minRow; row <= maxRow; row++) {
      for (var xLine = minColumn; xLine <= maxColumn + 1; xLine++) {
        if (!_level.hasVerticalWall(xLine, row)) continue;
        final distance = _distanceToVerticalSegment(
          point,
          xLine.toDouble(),
          row.toDouble(),
          row + 1.0,
        );
        if (distance < r) return false;
      }
    }

    for (var column = minColumn; column <= maxColumn; column++) {
      for (var yLine = minRow; yLine <= maxRow + 1; yLine++) {
        if (!_level.hasHorizontalWall(column, yLine)) continue;
        final distance = _distanceToHorizontalSegment(
          point,
          yLine.toDouble(),
          column.toDouble(),
          column + 1.0,
        );
        if (distance < r) return false;
      }
    }

    return true;
  }

  double _distanceToVerticalSegment(
    Offset point,
    double x,
    double y1,
    double y2,
  ) {
    final closestY = point.dy.clamp(y1, y2).toDouble();
    return (point - Offset(x, closestY)).distance;
  }

  double _distanceToHorizontalSegment(
    Offset point,
    double y,
    double x1,
    double x2,
  ) {
    final closestX = point.dx.clamp(x1, x2).toDouble();
    return (point - Offset(closestX, y)).distance;
  }

  void _checkGoal() {
    if (_finished) return;
    if ((_position - _level.goal).distance > _labyrinthGoalRadius) return;

    _finished = true;
    _countdown?.cancel();
    _velocity = Offset.zero;
    HapticFeedback.mediumImpact();

    final timeBonus = (_timeLeft / math.max(1, _level.timeLimitSeconds) * 40)
        .round();
    final precisionBonus = math.max(0, 30 - (_wallHits * 2)).toInt();
    final difficultyBonus = _levelNumber * 5;
    final score = 100 + timeBonus + precisionBonus + difficultyBonus;

    _showSuccess(score);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_finished) return;

    if (state == AppLifecycleState.resumed) {
      if (_pausedByLifecycle) {
        _pausedByLifecycle = false;
        _resetMotionCalibration();
        if (mounted) {
          setState(() => _paused = false);
        } else {
          _paused = false;
        }
      }
      return;
    }

    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden ||
        state == AppLifecycleState.detached) {
      if (!_paused) {
        _pausedByLifecycle = true;
        _velocity = Offset.zero;
        if (mounted) {
          setState(() => _paused = true);
        } else {
          _paused = true;
        }
      }
    }
  }

  void _togglePause() {
    if (_finished) return;

    final resuming = _paused;
    if (resuming) {
      _velocity = Offset.zero;
      _resetMotionCalibration();
    }

    setState(() {
      _paused = !_paused;
      if (_paused) _velocity = Offset.zero;
    });
  }

  void _restart() {
    Navigator.of(context).pop();
    _countdown?.cancel();
    _resetMotionCalibration();
    setState(() {
      _position = _level.start;
      _velocity = Offset.zero;
      _timeLeft = _level.timeLimitSeconds;
      _wallHits = 0;
      _started = false;
      _paused = false;
      _finished = false;
    });
  }

  void _showSuccess(int score) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _MazeResultDialog(
        title: 'Level $_levelNumber complete',
        subtitle: _levelNumber >= _maxTrainingLevel
            ? 'You completed the current Labyrinth progression.'
            : 'The next training level will generate a harder maze.',
        stats: [
          ('Time left', '${_timeLeft}s'),
          ('Wall touches', '$_wallHits'),
          ('Maze', '${_level.columns}×${_level.rows}'),
          ('Shortest route', '${_level.shortestPathMoves} moves'),
          ('Route turns', '${_level.shortestPathTurns}'),
          ('Score', '$score'),
        ],
        primaryLabel: 'Finish',
        onPrimary: () {
          Navigator.of(context).pop();
          if (widget.onFinish != null) {
            widget.onFinish!(score);
          } else {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (_) => GameResultScreen(
                  score: score,
                  completed: true,
                ),
              ),
            );
          }
        },
        secondaryLabel: 'Play again',
        onSecondary: _restart,
      ),
    );
  }

  void _showFailure() {
    if (_finished) return;
    _finished = true;
    _velocity = Offset.zero;
    HapticFeedback.mediumImpact();

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _MazeResultDialog(
        title: 'Time up',
        subtitle: 'Try the route again. The maze stays the same for this level.',
        stats: [
          ('Level', 'L$_levelNumber'),
          ('Wall touches', '$_wallHits'),
          ('Maze', '${_level.columns}×${_level.rows}'),
          ('Shortest route', '${_level.shortestPathMoves} moves'),
          ('Route turns', '${_level.shortestPathTurns}'),
        ],
        primaryLabel: 'Retry',
        onPrimary: _restart,
        secondaryLabel: 'Exit',
        onSecondary: () {
          Navigator.of(context).pop();
          Navigator.of(context).maybePop();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme.premiumDark(),
      child: Scaffold(
        backgroundColor: ReleafColors.background,
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 380;
              final hudHeight = compact ? 132.0 : 104.0;
              final availableHeight =
                  math.max(220.0, constraints.maxHeight - hudHeight).toDouble();
              final boardWidth = math
                  .min(
                    constraints.maxWidth - (ReleafSpacing.screen * 2),
                    availableHeight * (_level.columns / _level.rows),
                  )
                  .toDouble();
              final boardHeight =
                  boardWidth * (_level.rows / _level.columns);
              final boardSize = Size(boardWidth, boardHeight);

              return Stack(
                children: [
                  const Positioned.fill(child: _MazeBackdrop()),
                  Column(
                    children: [
                      _MazeHeader(
                        level: _levelNumber,
                        timeLeft: _timeLeft,
                        wallHits: _wallHits,
                        entryLabel: _level.entryLabel,
                        routeMoves: _level.shortestPathMoves,
                        started: _started,
                        paused: _paused,
                        motionAvailable: _motionAvailable,
                        onPause: _togglePause,
                        onExit: () => Navigator.of(context).maybePop(),
                      ),
                      const SizedBox(height: ReleafSpacing.sm),
                      Expanded(
                        child: Center(
                          child: Semantics(
                            label:
                                'Labyrinth board. Start ${_level.entryLabel.toLowerCase()} edge. Goal centre.',
                            child: GestureDetector(
                              key: const Key('labyrinth-board'),
                              behavior: HitTestBehavior.opaque,
                              onPanUpdate: (details) =>
                                  _onPanUpdate(details, boardSize),
                              child: SizedBox(
                                width: boardSize.width,
                                height: boardSize.height,
                                child: CustomPaint(
                                  painter: _MazeBoardPainter(
                                    level: _level,
                                    position: _position,
                                    paused: _paused,
                                    started: _started,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(
                          ReleafSpacing.screen,
                          ReleafSpacing.sm,
                          ReleafSpacing.screen,
                          ReleafSpacing.md,
                        ),
                        child: Text(
                          _motionAvailable
                              ? 'Start at the ${_level.entryLabel.toLowerCase()} edge and reach the centre. Tilt your phone to guide the light, or drag anywhere on the maze.'
                              : 'Start at the ${_level.entryLabel.toLowerCase()} edge and reach the centre. Drag anywhere on the maze; tilt control activates after sensor calibration.',
                          key: const Key('labyrinth-control-hint'),
                          textAlign: TextAlign.center,
                          style: ReleafTypography.meta.copyWith(
                            color: ReleafColors.textMuted,
                            height: 1.45,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (_paused)
                    Positioned.fill(
                      child: _PauseOverlay(
                        onResume: _togglePause,
                        onRestart: () {
                          setState(() => _paused = false);
                          showDialog<void>(
                            context: context,
                            barrierDismissible: false,
                            builder: (_) => _MazeResultDialog(
                              title: 'Restart level?',
                              subtitle:
                                  'Your current route and timer will reset.',
                              stats: [
                                ('Level', 'L$_levelNumber'),
                                ('Time left', '${_timeLeft}s'),
                              ],
                              primaryLabel: 'Restart',
                              onPrimary: _restart,
                              secondaryLabel: 'Keep playing',
                              onSecondary: () => Navigator.of(context).pop(),
                            ),
                          );
                        },
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

@visibleForTesting
class LabyrinthLevelProfile {
  const LabyrinthLevelProfile({
    required this.level,
    required this.columns,
    required this.rows,
    required this.shortestPathMoves,
    required this.shortestPathTurns,
    required this.deadEnds,
    required this.timeLimitSeconds,
    required this.ballRadius,
  });

  final int level;
  final int columns;
  final int rows;
  final int shortestPathMoves;
  final int shortestPathTurns;
  final int deadEnds;
  final int timeLimitSeconds;
  final double ballRadius;
}

@visibleForTesting
LabyrinthLevelProfile labyrinthLevelProfileForTesting(int level) {
  final maze = _MazeLevel.generate(level);
  return LabyrinthLevelProfile(
    level: maze.level,
    columns: maze.columns,
    rows: maze.rows,
    shortestPathMoves: maze.shortestPathMoves,
    shortestPathTurns: maze.shortestPathTurns,
    deadEnds: maze.deadEnds,
    timeLimitSeconds: maze.timeLimitSeconds,
    ballRadius: labyrinthBallRadiusForLevel(maze.level),
  );
}

class _MazeCandidate {
  const _MazeCandidate({
    required this.cells,
    required this.metrics,
  });

  final List<List<_MazeCell>> cells;
  final _MazeMetrics metrics;
}

class _MazeMetrics {
  const _MazeMetrics({
    required this.moves,
    required this.turns,
    required this.deadEnds,
  });

  final int moves;
  final int turns;
  final int deadEnds;
}

class _MazeLevel {
  const _MazeLevel({
    required this.level,
    required this.columns,
    required this.rows,
    required this.cells,
    required this.start,
    required this.goal,
    required this.timeLimitSeconds,
    required this.entrySide,
    required this.shortestPathMoves,
    required this.shortestPathTurns,
    required this.deadEnds,
  });

  final int level;
  final int columns;
  final int rows;
  final List<List<_MazeCell>> cells;
  final Offset start;
  final Offset goal;
  final int timeLimitSeconds;
  final _MazeEntrySide entrySide;
  final int shortestPathMoves;
  final int shortestPathTurns;
  final int deadEnds;

  String get entryLabel => switch (entrySide) {
        _MazeEntrySide.bottom => 'Bottom',
        _MazeEntrySide.left => 'Left',
        _MazeEntrySide.top => 'Top',
        _MazeEntrySide.right => 'Right',
      };

  factory _MazeLevel.generate(int rawLevel) {
    final level = rawLevel.clamp(1, 12).toInt();
    final columns = (5 + ((level - 1) ~/ 2)).clamp(5, 10).toInt();
    final rows = (7 + ((level - 1) ~/ 2)).clamp(7, 12).toInt();
    final entrySide = _MazeEntrySide.values[(level - 1) % 4];
    final (startColumn, startRow) = switch (entrySide) {
      _MazeEntrySide.bottom => (columns ~/ 2, rows - 1),
      _MazeEntrySide.left => (0, rows ~/ 2),
      _MazeEntrySide.top => (columns ~/ 2, 0),
      _MazeEntrySide.right => (columns - 1, rows ~/ 2),
    };
    final goalColumn = columns ~/ 2;
    final goalRow = rows ~/ 2;

    // Difficulty is selected from actual route complexity rather than from a
    // single random DFS result. Higher levels target a progressively larger
    // fraction of the board, while keeping physics calm and predictable.
    final cellCount = columns * rows;
    final targetRatio = 0.22 + (((level - 1) / 11.0) * 0.26);
    final targetPathMoves =
        (cellCount * targetRatio).round().clamp(6, cellCount - 1).toInt();
    final targetTurns = (2 + (level * 0.65)).round();

    _MazeCandidate? best;
    var bestScore = double.infinity;

    for (var candidateIndex = 0; candidateIndex < 72; candidateIndex++) {
      final candidate = _generateCandidate(
        columns: columns,
        rows: rows,
        startColumn: startColumn,
        startRow: startRow,
        goalColumn: goalColumn,
        goalRow: goalRow,
        seed: 4813 +
            (level * 7919) +
            (columns * 1009) +
            (rows * 9176) +
            (candidateIndex * 104729),
      );

      final pathGap = (candidate.metrics.moves - targetPathMoves).abs();
      final shortfall = math.max(
        0,
        ((targetPathMoves * 0.88).round() - candidate.metrics.moves),
      );
      final turnGap = (candidate.metrics.turns - targetTurns).abs();

      final score = (pathGap * 12.0) +
          (shortfall * 42.0) +
          (turnGap * 1.4) -
          (math.min(candidate.metrics.deadEnds, 18) * 0.12);

      if (score < bestScore) {
        best = candidate;
        bestScore = score;
      }
    }

    final selected = best!;
    final secondsPerMove = 2.9 - ((level - 1) * 0.035);
    final timeLimitSeconds =
        (28 + (selected.metrics.moves * secondsPerMove))
            .round()
            .clamp(50, 150)
            .toInt();

    return _MazeLevel(
      level: level,
      columns: columns,
      rows: rows,
      cells: selected.cells,
      start: Offset(startColumn + 0.5, startRow + 0.5),
      goal: Offset(goalColumn + 0.5, goalRow + 0.5),
      timeLimitSeconds: timeLimitSeconds,
      entrySide: entrySide,
      shortestPathMoves: selected.metrics.moves,
      shortestPathTurns: selected.metrics.turns,
      deadEnds: selected.metrics.deadEnds,
    );
  }

  static _MazeCandidate _generateCandidate({
    required int columns,
    required int rows,
    required int startColumn,
    required int startRow,
    required int goalColumn,
    required int goalRow,
    required int seed,
  }) {
    final cells = List<List<_MazeCell>>.generate(
      rows,
      (_) => List<_MazeCell>.generate(
        columns,
        (_) => _MazeCell(),
      ),
    );

    final random = math.Random(seed);
    final visited = List<List<bool>>.generate(
      rows,
      (_) => List<bool>.filled(columns, false),
    );
    final stack = <(int, int)>[(startColumn, startRow)];
    visited[startRow][startColumn] = true;

    while (stack.isNotEmpty) {
      final (column, row) = stack.last;
      final candidates = <(int, int, int)>[];

      if (row > 0 && !visited[row - 1][column]) {
        candidates.add((column, row - 1, 0));
      }
      if (column < columns - 1 && !visited[row][column + 1]) {
        candidates.add((column + 1, row, 1));
      }
      if (row < rows - 1 && !visited[row + 1][column]) {
        candidates.add((column, row + 1, 2));
      }
      if (column > 0 && !visited[row][column - 1]) {
        candidates.add((column - 1, row, 3));
      }

      if (candidates.isEmpty) {
        stack.removeLast();
        continue;
      }

      final next = candidates[random.nextInt(candidates.length)];
      final (nextColumn, nextRow, direction) = next;
      final cell = cells[row][column];
      final target = cells[nextRow][nextColumn];

      switch (direction) {
        case 0:
          cell.top = false;
          target.bottom = false;
        case 1:
          cell.right = false;
          target.left = false;
        case 2:
          cell.bottom = false;
          target.top = false;
        case 3:
          cell.left = false;
          target.right = false;
      }

      visited[nextRow][nextColumn] = true;
      stack.add((nextColumn, nextRow));
    }

    return _MazeCandidate(
      cells: cells,
      metrics: _pathMetrics(
        cells: cells,
        columns: columns,
        rows: rows,
        startColumn: startColumn,
        startRow: startRow,
        goalColumn: goalColumn,
        goalRow: goalRow,
      ),
    );
  }

  static _MazeMetrics _pathMetrics({
    required List<List<_MazeCell>> cells,
    required int columns,
    required int rows,
    required int startColumn,
    required int startRow,
    required int goalColumn,
    required int goalRow,
  }) {
    final distances = List<List<int>>.generate(
      rows,
      (_) => List<int>.filled(columns, -1),
    );
    final parentDirection = List<List<int>>.generate(
      rows,
      (_) => List<int>.filled(columns, -1),
    );
    final queue = <(int, int)>[(startColumn, startRow)];
    distances[startRow][startColumn] = 0;
    var head = 0;

    while (head < queue.length) {
      final (column, row) = queue[head++];
      if (column == goalColumn && row == goalRow) break;

      final cell = cells[row][column];
      final nextDistance = distances[row][column] + 1;

      void enqueue(int nextColumn, int nextRow, int direction) {
        if (nextColumn < 0 ||
            nextColumn >= columns ||
            nextRow < 0 ||
            nextRow >= rows ||
            distances[nextRow][nextColumn] != -1) {
          return;
        }

        distances[nextRow][nextColumn] = nextDistance;
        parentDirection[nextRow][nextColumn] = direction;
        queue.add((nextColumn, nextRow));
      }

      if (!cell.top) enqueue(column, row - 1, 0);
      if (!cell.right) enqueue(column + 1, row, 1);
      if (!cell.bottom) enqueue(column, row + 1, 2);
      if (!cell.left) enqueue(column - 1, row, 3);
    }

    final directions = <int>[];
    var column = goalColumn;
    var row = goalRow;

    while (column != startColumn || row != startRow) {
      final direction = parentDirection[row][column];
      if (direction < 0) break;
      directions.add(direction);

      switch (direction) {
        case 0:
          row += 1;
        case 1:
          column -= 1;
        case 2:
          row -= 1;
        case 3:
          column += 1;
      }
    }

    var turns = 0;
    for (var index = 1; index < directions.length; index++) {
      if (directions[index] != directions[index - 1]) turns++;
    }

    var deadEnds = 0;
    for (var r = 0; r < rows; r++) {
      for (var c = 0; c < columns; c++) {
        if ((c == startColumn && r == startRow) ||
            (c == goalColumn && r == goalRow)) {
          continue;
        }

        final cell = cells[r][c];
        var openings = 0;
        if (!cell.top) openings++;
        if (!cell.right) openings++;
        if (!cell.bottom) openings++;
        if (!cell.left) openings++;
        if (openings == 1) deadEnds++;
      }
    }

    final moves = distances[goalRow][goalColumn] >= 0
        ? distances[goalRow][goalColumn]
        : math.max(columns, rows).toInt();

    return _MazeMetrics(
      moves: moves,
      turns: turns,
      deadEnds: deadEnds,
    );
  }

  bool hasVerticalWall(int xLine, int row) {
    if (row < 0 || row >= rows) return true;
    if (xLine <= 0 || xLine >= columns) return true;

    return cells[row][xLine - 1].right || cells[row][xLine].left;
  }

  bool hasHorizontalWall(int column, int yLine) {
    if (column < 0 || column >= columns) return true;
    if (yLine <= 0 || yLine >= rows) return true;

    return cells[yLine - 1][column].bottom || cells[yLine][column].top;
  }
}

enum _MazeEntrySide { bottom, left, top, right }

class _MazeCell {
  bool top = true;
  bool right = true;
  bool bottom = true;
  bool left = true;
}

class _MazeBoardPainter extends CustomPainter {
  const _MazeBoardPainter({
    required this.level,
    required this.position,
    required this.paused,
    required this.started,
  });

  final _MazeLevel level;
  final Offset position;
  final bool paused;
  final bool started;

  @override
  void paint(Canvas canvas, Size size) {
    final cellWidth = size.width / level.columns;
    final cellHeight = size.height / level.rows;

    final boardRect = Offset.zero & size;
    final boardRadius = Radius.circular(
      math.min(cellWidth, cellHeight).toDouble() * 0.26,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(boardRect, boardRadius),
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0F1C17),
            Color(0xFF09130F),
            Color(0xFF07100D),
          ],
        ).createShader(boardRect),
    );

    final glowPaint = Paint()
      ..color = const Color(0xFF76D5B8).withValues(alpha: 0.035)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 24);
    canvas.drawCircle(
      Offset(size.width * 0.48, size.height * 0.52),
      size.shortestSide * 0.42,
      glowPaint,
    );

    final wallPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth =
          math.max(3.0, math.min(cellWidth, cellHeight) * 0.09).toDouble()
      ..strokeCap = StrokeCap.round
      ..color = const Color(0xFF557C68);

    final wallShadowPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = wallPaint.strokeWidth + 4
      ..strokeCap = StrokeCap.round
      ..color = const Color(0xFF020806).withValues(alpha: 0.68)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.4);

    final hedgeBodyPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(2.4, wallPaint.strokeWidth * 0.72).toDouble()
      ..strokeCap = StrokeCap.round
      ..color = const Color(0xFF426D59);

    final innerWallPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth =
          math.max(1.2, wallPaint.strokeWidth * 0.38).toDouble()
      ..strokeCap = StrokeCap.round
      ..color = const Color(0xFF9FC8B4).withValues(alpha: 0.35);

    void wall(Offset a, Offset b) {
      const shadowOffset = Offset(0, 1.4);
      canvas.drawLine(a + shadowOffset, b + shadowOffset, wallShadowPaint);
      canvas.drawLine(a, b, wallPaint);
      canvas.drawLine(a, b, hedgeBodyPaint);
      canvas.drawLine(a, b, innerWallPaint);
    }

    for (var row = 0; row < level.rows; row++) {
      for (var column = 0; column < level.columns; column++) {
        final cell = level.cells[row][column];
        final left = column * cellWidth;
        final top = row * cellHeight;
        final right = left + cellWidth;
        final bottom = top + cellHeight;

        if (cell.top) wall(Offset(left, top), Offset(right, top));
        if (cell.left) wall(Offset(left, top), Offset(left, bottom));
        if (row == level.rows - 1 && cell.bottom) {
          wall(Offset(left, bottom), Offset(right, bottom));
        }
        if (column == level.columns - 1 && cell.right) {
          wall(Offset(right, top), Offset(right, bottom));
        }
      }
    }

    final goal = Offset(
      level.goal.dx / level.columns * size.width,
      level.goal.dy / level.rows * size.height,
    );
    final goalRadius =
        math.min(cellWidth, cellHeight).toDouble() * _labyrinthGoalRadius;

    canvas.drawCircle(
      goal,
      goalRadius * 1.65,
      Paint()
        ..color = const Color(0xFFE7C77A).withValues(alpha: 0.14)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 16),
    );
    canvas.drawCircle(
      goal,
      goalRadius,
      Paint()..color = const Color(0xFFE7C77A),
    );
    canvas.drawCircle(
      goal,
      goalRadius * 0.45,
      Paint()..color = const Color(0xFFFFF0BE),
    );

    final goalLabel = TextPainter(
      text: const TextSpan(
        text: 'GOAL',
        style: TextStyle(
          color: Color(0xFFE7C77A),
          fontSize: 8,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.1,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    goalLabel.paint(
      canvas,
      Offset(
        goal.dx - (goalLabel.width / 2),
        goal.dy - goalRadius - goalLabel.height - 5,
      ),
    );

    final start = Offset(
      level.start.dx / level.columns * size.width,
      level.start.dy / level.rows * size.height,
    );
    final startRadius =
        math.min(cellWidth, cellHeight).toDouble() * 0.20;
    canvas.drawCircle(
      start,
      startRadius * 1.45,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = const Color(0xFF76D5B8).withValues(alpha: 0.22),
    );

    final ball = Offset(
      position.dx / level.columns * size.width,
      position.dy / level.rows * size.height,
    );
    final ballRadius =
        math.min(cellWidth, cellHeight).toDouble() *
            labyrinthBallRadiusForLevel(level.level);

    canvas.drawCircle(
      ball,
      ballRadius * 2.0,
      Paint()
        ..color = const Color(0xFF76D5B8).withValues(
          alpha: paused ? 0.08 : 0.20,
        )
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18),
    );
    canvas.drawCircle(
      ball,
      ballRadius,
      Paint()..color = paused ? const Color(0xFF69877A) : const Color(0xFFD7FFF2),
    );
    canvas.drawCircle(
      ball,
      ballRadius * 0.42,
      Paint()..color = const Color(0xFF3EAA88),
    );

    if (!started) {
      final textPainter = TextPainter(
        text: const TextSpan(
          text: 'START',
          style: TextStyle(
            color: Color(0xFFA9BDB4),
            fontSize: 9,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      textPainter.paint(
        canvas,
        Offset(
          ball.dx - (textPainter.width / 2),
          ball.dy + ballRadius + 9,
        ),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _MazeBoardPainter oldDelegate) =>
      oldDelegate.position != position ||
      oldDelegate.paused != paused ||
      oldDelegate.started != started ||
      oldDelegate.level.level != level.level;
}

class _MazeHeader extends StatelessWidget {
  const _MazeHeader({
    required this.level,
    required this.timeLeft,
    required this.wallHits,
    required this.entryLabel,
    required this.routeMoves,
    required this.started,
    required this.paused,
    required this.motionAvailable,
    required this.onPause,
    required this.onExit,
  });

  final int level;
  final int timeLeft;
  final int wallHits;
  final String entryLabel;
  final int routeMoves;
  final bool started;
  final bool paused;
  final bool motionAvailable;
  final VoidCallback onPause;
  final VoidCallback onExit;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        ReleafSpacing.screen,
        ReleafSpacing.md,
        ReleafSpacing.screen,
        0,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'SPATIAL PLANNING',
                      style: ReleafTypography.eyebrow.copyWith(
                        color: ReleafColors.sage,
                        letterSpacing: 1.6,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Labyrinth',
                      style: ReleafTypography.sectionTitle.copyWith(
                        fontSize: 24,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: paused ? 'Resume' : 'Pause',
                onPressed: onPause,
                icon: Icon(
                  paused ? Icons.play_arrow_rounded : Icons.pause_rounded,
                ),
              ),
              IconButton(
                tooltip: 'Exit Labyrinth',
                onPressed: onExit,
                icon: const Icon(Icons.close_rounded),
              ),
            ],
          ),
          const SizedBox(height: ReleafSpacing.sm),
          Wrap(
            spacing: 7,
            runSpacing: 7,
            children: [
              _MazeStat(label: 'LEVEL', value: 'L$level'),
              _MazeStat(
                label: 'TIME',
                value: started ? '${timeLeft}s' : 'Ready',
              ),
              _MazeStat(label: 'WALLS', value: '$wallHits'),
              _MazeStat(label: 'ENTRY', value: entryLabel),
              _MazeStat(label: 'ROUTE', value: '$routeMoves'),
              _MazeStat(
                label: 'CONTROL',
                value: motionAvailable ? 'Tilt + touch' : 'Touch',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MazeStat extends StatelessWidget {
  const _MazeStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFF14201B).withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(ReleafRadii.pill),
        border: Border.all(
          color: ReleafColors.sage.withValues(alpha: 0.16),
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
              letterSpacing: 0.8,
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

class _PauseOverlay extends StatelessWidget {
  const _PauseOverlay({
    required this.onResume,
    required this.onRestart,
  });

  final VoidCallback onResume;
  final VoidCallback onRestart;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.black.withValues(alpha: 0.68),
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(ReleafSpacing.screen),
          padding: const EdgeInsets.all(ReleafSpacing.xl),
          constraints: const BoxConstraints(maxWidth: 420),
          decoration: BoxDecoration(
            color: ReleafColors.backgroundRaised,
            borderRadius: BorderRadius.circular(ReleafRadii.extraLarge),
            border: Border.all(
              color: ReleafColors.sage.withValues(alpha: 0.18),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.pause_circle_outline_rounded,
                color: ReleafColors.sage,
                size: 42,
              ),
              const SizedBox(height: ReleafSpacing.sm),
              Text(
                'Paused',
                style: ReleafTypography.sectionTitle,
              ),
              const SizedBox(height: ReleafSpacing.lg),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: onResume,
                  child: const Text('Resume'),
                ),
              ),
              const SizedBox(height: ReleafSpacing.xs),
              TextButton(
                onPressed: onRestart,
                child: const Text('Restart level'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MazeResultDialog extends StatelessWidget {
  const _MazeResultDialog({
    required this.title,
    required this.subtitle,
    required this.stats,
    required this.primaryLabel,
    required this.onPrimary,
    this.secondaryLabel,
    this.onSecondary,
  });

  final String title;
  final String subtitle;
  final List<(String, String)> stats;
  final String primaryLabel;
  final VoidCallback onPrimary;
  final String? secondaryLabel;
  final VoidCallback? onSecondary;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: ReleafColors.backgroundRaised,
      surfaceTintColor: Colors.transparent,
      title: Text(title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            subtitle,
            style: ReleafTypography.body.copyWith(
              color: ReleafColors.textSecondary,
            ),
          ),
          const SizedBox(height: ReleafSpacing.md),
          for (final (label, value) in stats)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      label,
                      style: ReleafTypography.body.copyWith(
                        color: ReleafColors.textSecondary,
                      ),
                    ),
                  ),
                  Text(
                    value,
                    style: ReleafTypography.body.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
      actions: [
        if (secondaryLabel != null && onSecondary != null)
          TextButton(
            onPressed: onSecondary,
            child: Text(secondaryLabel!),
          ),
        FilledButton(
          onPressed: onPrimary,
          child: Text(primaryLabel),
        ),
      ],
    );
  }
}

class _MazeBackdrop extends StatelessWidget {
  const _MazeBackdrop();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF102019),
            ReleafColors.background,
            Color(0xFF070B09),
          ],
        ),
      ),
    );
  }
}
