from pathlib import Path

path = Path('lib/games/labyrinth/labyrinth_game_screen.dart')
text = path.read_text(encoding='utf-8')

# Idempotent: subsequent CI runs must not try to re-apply the migration.
if (
    'rawTrainingLevel.clamp(1, 50)' in text
    and 'static const int _maxTrainingLevel = 50;' in text
    and 'final level = rawLevel.clamp(1, 50).toInt();' in text
):
    print('Labyrinth L50 gameplay patch is already present.')
    raise SystemExit(0)


def replace_once(old: str, new: str, label: str) -> None:
    global text
    count = text.count(old)
    if count != 1:
        raise SystemExit(f'{label}: expected exactly one match, got {count}')
    text = text.replace(old, new, 1)


replace_once(
    """/// Keeps the persistent Brain level as the medium baseline while allowing a
/// player to choose a calmer or more demanding maze before the timer starts.
/// The public progression model remains unchanged.
@visibleForTesting
int labyrinthProfileLevelForDifficulty(
  int rawTrainingLevel,
  BrainDifficulty difficulty,
) {
  final trainingLevel = rawTrainingLevel.clamp(1, 12).toInt();
  final offset = switch (difficulty) {
    BrainDifficulty.easy => -2,
    BrainDifficulty.medium => 0,
    BrainDifficulty.hard => 2,
  };
  return (trainingLevel + offset).clamp(1, 12).toInt();
}
""",
    """/// Keeps the persistent Brain level as the medium baseline while allowing a
/// player to choose a calmer or more demanding maze before the timer starts.
/// Legacy L1-L12 difficulty stays exact; the extended path continues to L50.
@visibleForTesting
int labyrinthProfileLevelForDifficulty(
  int rawTrainingLevel,
  BrainDifficulty difficulty,
) {
  final trainingLevel = rawTrainingLevel.clamp(1, 50).toInt();
  final offset = switch (difficulty) {
    BrainDifficulty.easy => -2,
    BrainDifficulty.medium => 0,
    BrainDifficulty.hard => 2,
  };

  if (trainingLevel <= 12) {
    return (trainingLevel + offset).clamp(1, 12).toInt();
  }
  return (trainingLevel + offset).clamp(1, 50).toInt();
}
""",
    'difficulty resolver',
)

replace_once(
    """@visibleForTesting
double labyrinthBallRadiusForLevel(int rawLevel) {
  final level = rawLevel.clamp(1, 12).toInt();
  final progress = (level - 1) / 11.0;
  return 0.19 - (0.05 * progress);
}
""",
    """@visibleForTesting
double labyrinthBallRadiusForLevel(int rawLevel) {
  final level = rawLevel.clamp(1, 50).toInt();
  if (level <= 12) {
    final progress = (level - 1) / 11.0;
    return 0.19 - (0.05 * progress);
  }

  final extendedProgress = (level - 12) / 38.0;
  return 0.14 - (0.04 * extendedProgress);
}
""",
    'ball radius',
)

replace_once(
    '  static const int _maxTrainingLevel = 12;',
    '  static const int _maxTrainingLevel = 50;',
    'screen max level',
)

replace_once(
    """    final level = rawLevel.clamp(1, 12).toInt();
    final stage = mazeStage.clamp(1, maxLabyrinthMazeStages).toInt();
    final columns = (5 + ((level - 1) ~/ 2)).clamp(5, 10).toInt();
    final rows = (7 + ((level - 1) ~/ 2)).clamp(7, 12).toInt();
""",
    """    final level = rawLevel.clamp(1, 50).toInt();
    final stage = mazeStage.clamp(1, maxLabyrinthMazeStages).toInt();
    final int columns;
    final int rows;
    if (level <= 12) {
      columns = (5 + ((level - 1) ~/ 2)).clamp(5, 10).toInt();
      rows = (7 + ((level - 1) ~/ 2)).clamp(7, 12).toInt();
    } else {
      final expansionBand = 1 + ((level - 13) ~/ 10);
      columns = (10 + expansionBand).clamp(11, 14).toInt();
      rows = (12 + expansionBand).clamp(13, 16).toInt();
    }
""",
    'maze dimensions',
)

replace_once(
    """    final cellCount = columns * rows;
    final targetRatio = 0.22 + (((level - 1) / 11.0) * 0.26);
    final targetPathMoves =
        (cellCount * targetRatio).round().clamp(6, cellCount - 1).toInt();
    final targetTurns = (2 + (level * 0.65)).round();

    _MazeCandidate? best;
    var bestScore = double.infinity;

    for (var candidateIndex = 0; candidateIndex < 72; candidateIndex++) {
""",
    """    final cellCount = columns * rows;
    final targetRatio = level <= 12
        ? 0.22 + (((level - 1) / 11.0) * 0.26)
        : 0.48 + (((level - 12) / 38.0) * 0.10);
    final targetPathMoves =
        (cellCount * targetRatio).round().clamp(6, cellCount - 1).toInt();
    final targetTurns = level <= 12
        ? (2 + (level * 0.65)).round()
        : 10 + (((level - 12) / 38.0) * 7).round();

    _MazeCandidate? best;
    var bestScore = double.infinity;
    final candidateCount = level <= 12 ? 72 : 96;

    for (var candidateIndex = 0;
        candidateIndex < candidateCount;
        candidateIndex++) {
""",
    'route complexity',
)

replace_once(
    """    final selected = best!;
    final secondsPerMove = 2.9 - ((level - 1) * 0.035);
    final timeLimitSeconds =
        (28 + (selected.metrics.moves * secondsPerMove))
            .round()
            .clamp(50, 150)
            .toInt();
""",
    """    final selected = best!;
    final secondsPerMove = level <= 12
        ? 2.9 - ((level - 1) * 0.035)
        : 2.515 - (((level - 12) / 38.0) * 0.515);
    final rawTimeLimit =
        (28 + (selected.metrics.moves * secondsPerMove)).round();
    final timeLimitSeconds = level <= 12
        ? rawTimeLimit.clamp(50, 150).toInt()
        : rawTimeLimit.clamp(55, 180).toInt();
""",
    'timer scaling',
)

path.write_text(text, encoding='utf-8')
print('Applied Labyrinth L50 gameplay patch.')
