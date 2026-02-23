// FILE: lib/features/brain/data/game_registry.dart
import 'package:flutter/material.dart';

// Twoje realne ekrany gier (zgodnie z games_screen.dart)
import 'package:releaf_app/screens/memory_game_screen.dart';
import 'package:releaf_app/screens/labirynth_game_screen.dart';
import 'package:releaf_app/screens/broken_mirror_game_screen.dart';
import 'package:releaf_app/games/math_race/math_race_screen.dart';

typedef GameFinishCallback = void Function(int score);

class GameEntry {
  final String id;
  final String title;
  final String subtitle;
  final Widget Function(BuildContext context, GameFinishCallback onFinish) builder;

  const GameEntry({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.builder,
  });
}

class GameRegistry {
  GameRegistry._();

  // MVP: 4 gry, które faktycznie masz
  static final List<GameEntry> _games = <GameEntry>[
    GameEntry(
      id: 'memory',
      title: 'Memory',
      subtitle: 'Pairs & focus',
      builder: (context, onFinish) => SessionFinishOverlay(
        title: 'Memory',
        onFinish: onFinish,
        // Twoja gra nie ma jeszcze onFinish -> wrapper daje przycisk "Finish session"
        child: const MemoryGameScreen(),
        fallbackScore: 100,
      ),
    ),
    GameEntry(
      id: 'labirynth',
      title: 'Labyrinth',
      subtitle: '1-minute calm mode',
      builder: (context, onFinish) => SessionFinishOverlay(
        title: 'Labyrinth',
        onFinish: onFinish,
        child: const LabirynthGameScreen(),
        fallbackScore: 100,
      ),
    ),
    GameEntry(
      id: 'math_race',
      title: 'Math Race',
      subtitle: 'Flow difficulty',
      builder: (context, onFinish) => SessionFinishOverlay(
        title: 'Math Race',
        onFinish: onFinish,
        child: const MathRaceScreen(),
        fallbackScore: 100,
      ),
    ),
    GameEntry(
      id: 'broken_mirror',
      title: 'Broken Mirror',
      subtitle: 'Rebuild & breathe',
      builder: (context, onFinish) => SessionFinishOverlay(
        title: 'Broken Mirror',
        onFinish: onFinish,
        child: const BrokenMirrorGameScreen(),
        fallbackScore: 100,
      ),
    ),
  ];

  static List<GameEntry> all() => List.unmodifiable(_games);

  static GameEntry byId(String id) {
    return _games.firstWhere(
          (e) => e.id == id,
      orElse: () => GameEntry(
        id: 'unknown',
        title: 'Unknown game',
        subtitle: 'Not registered',
        builder: (context, onFinish) => _unknownGame(context, id),
      ),
    );
  }

  static GameEntry suggest({required int seed}) {
    final index = seed.abs() % _games.length;
    return _games[index];
  }

  static Widget _unknownGame(BuildContext context, String id) {
    return Scaffold(
      appBar: AppBar(title: const Text('Unknown game')),
      body: Center(
        child: Text(
          'Game "$id" is not registered in GameRegistry.\n\n'
              'Fix: add it to GameRegistry._games',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

/// Wrapper na MVP:
/// - nie rusza Twojej gry
/// - dodaje mały przycisk "Finish session" w prawym górnym rogu
/// - woła onFinish(score) → dzięki temu Brain session może zapisać wynik
class SessionFinishOverlay extends StatelessWidget {
  const SessionFinishOverlay({
    super.key,
    required this.title,
    required this.child,
    required this.onFinish,
    this.fallbackScore = 100,
  });

  final String title;
  final Widget child;
  final GameFinishCallback onFinish;

  /// MVP: dopóki gry nie zwracają realnego score → dajemy stały wynik.
  /// Potem to zastąpisz realnym score z gry.
  final int fallbackScore;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Twoja gra (często ma własny Scaffold) – OK
        Positioned.fill(child: child),

        // Finish session button
        SafeArea(
          child: Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: FilledButton.icon(
                onPressed: () => onFinish(fallbackScore),
                icon: const Icon(Icons.check_circle_outline),
                label: const Text('Finish session'),
              ),
            ),
          ),
        ),
      ],
    );
  }
}