// FILE: lib/features/brain/data/brain_repository.dart
import '../model/brain_game.dart';

/// Repository providing the list of brain games.
/// MVP: tylko 1 gra (Math Race).
class BrainRepository {
  const BrainRepository();

  List<BrainGame> getGames() {
    return const [
      BrainGame(id: 'math-race', title: 'Math Race'),
    ];
  }
}