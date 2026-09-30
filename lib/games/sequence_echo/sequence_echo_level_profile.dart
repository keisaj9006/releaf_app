import '../../features/brain/domain/brain_level.dart';
import '../../features/brain/presentation/widgets/brain_difficulty_selector.dart';

class SequenceEchoLevelProfile {
  const SequenceEchoLevelProfile({
    required this.totalRounds,
    required this.sequenceLength,
    required this.flashMs,
    required this.sequence,
  });

  final int totalRounds;
  final int sequenceLength;
  final int flashMs;
  final List<int> sequence;
}

const _legacySequence = <int>[
  0,
  4,
  8,
  2,
  6,
  1,
  7,
  3,
  5,
  0,
  8,
  4,
  2,
  7,
  1,
  6,
  3,
  5,
];

SequenceEchoLevelProfile sequenceEchoProfileForLevel(
  int rawLevel,
  BrainDifficulty difficulty,
  int round,
) {
  final level = rawLevel.clamp(1, maxBrainProfileLevel).toInt();
  if (level <= 12) {
    final index = level - 1;
    final baseRounds = switch (difficulty) {
      BrainDifficulty.easy => 5,
      BrainDifficulty.medium => 6,
      BrainDifficulty.hard => 7,
    };
    final baseLength = switch (difficulty) {
      BrainDifficulty.easy => 3,
      BrainDifficulty.medium => 4,
      BrainDifficulty.hard => 5,
    };
    final baseFlash = switch (difficulty) {
      BrainDifficulty.easy => 560,
      BrainDifficulty.medium => 410,
      BrainDifficulty.hard => 290,
    };
    final roundPenalty = switch (difficulty) {
      BrainDifficulty.easy => 35,
      BrainDifficulty.medium => 30,
      BrainDifficulty.hard => 18,
    };
    final length = baseLength + round + index ~/ 2;
    final offset = (round * 3 + difficulty.index * 2) % _legacySequence.length;
    return SequenceEchoLevelProfile(
      totalRounds: baseRounds + index ~/ 3,
      sequenceLength: length,
      flashMs: (baseFlash - round * roundPenalty - index * 12).clamp(145, 560),
      sequence: List<int>.unmodifiable(
        List<int>.generate(
          length,
          (i) => _legacySequence[(offset + i) % _legacySequence.length],
        ),
      ),
    );
  }

  final context = BrainLevelContext(level);
  final difficultyOffset = switch (difficulty) {
    BrainDifficulty.easy => -1,
    BrainDifficulty.medium => 0,
    BrainDifficulty.hard => 1,
  };
  final safeRound = round < 0 ? 0 : round;
  final totalRounds = (8 + context.bandIndex ~/ 2 + difficultyOffset).clamp(
    7,
    12,
  );
  final length =
      (7 +
              context.bandIndex +
              context.stepInBand ~/ 4 +
              difficultyOffset +
              safeRound)
          .clamp(7, 18);
  final flashMs =
      (320 -
              context.bandIndex * 25 -
              context.stepInBand * 5 -
              safeRound * 9 -
              difficultyOffset * 50)
          .clamp(145, 560);
  var seed =
      level * 73856093 ^ difficulty.index * 19349663 ^ safeRound * 83492791;
  final sequence = <int>[];
  for (var i = 0; i < length; i++) {
    seed = (seed * 1664525 + 1013904223) & 0x7fffffff;
    var cell = seed % 9;
    if (sequence.isNotEmpty && cell == sequence.last) {
      cell = (cell + 1 + (seed ~/ 9) % 8) % 9;
    }
    sequence.add(cell);
  }
  return SequenceEchoLevelProfile(
    totalRounds: totalRounds,
    sequenceLength: length,
    flashMs: flashMs,
    sequence: List<int>.unmodifiable(sequence),
  );
}
