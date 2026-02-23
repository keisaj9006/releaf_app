import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show HapticFeedback;

// Twoje ekrany (wg układu ze screenów)
import 'memory_game_screen.dart';
import 'labirynth_game_screen.dart';
import 'broken_mirror_game_screen.dart';

// Math Race trzymasz poza screens – zostawiam Twój import:
import 'package:releaf_app/games/math_race/math_race_screen.dart';

/// Prosty placeholder dla ekranów „Wkrótce…”
class ComingSoonScreen extends StatelessWidget {
  const ComingSoonScreen({super.key, required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title, style: const TextStyle(fontFamily: 'Poppins')),
        backgroundColor: const Color(0xFF154314),
        iconTheme: const IconThemeData(color: Color(0xFFFCF6DB)),
      ),
      body: const Center(
        child: Text(
          'Wkrótce…',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

class GamesScreen extends StatelessWidget {
  const GamesScreen({super.key});

  Future<void> _open(BuildContext context, Widget screen) async {
    await HapticFeedback.lightImpact();
    if (context.mounted) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
    }
  }

  void _showTemporarilyDisabledDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => const AlertDialog(
        title: Text('Coming soon'),
        content: Text('This game is temporarily disabled while we fix it.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text(
          "Choose a Game",
          style: TextStyle(
            fontFamily: 'Poppins',
            color: Color(0xFFFCF6DB),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF154314),
        iconTheme: const IconThemeData(color: Color(0xFFFCF6DB)),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/ui/background.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: GridView.count(
          crossAxisCount: 2,
          padding: const EdgeInsets.all(16),
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            // MEMORY (disabled for now - it crashes due to late init in legacy screen)
            GameTile(
              imagePath: 'assets/ui/memory.png',
              label: 'Memory',
              onTap: () => _showTemporarilyDisabledDialog(context),
            ),

            // LASER (placeholder)
            GameTile(
              imagePath: 'assets/ui/laser.png',
              label: 'Laser',
              onTap: () => _open(
                context,
                const ComingSoonScreen(title: 'Laser'),
              ),
            ),

            // MATH RACE
            GameTile(
              imagePath: 'assets/ui/mathrace.png',
              label: 'Math race',
              onTap: () => _open(context, const MathRaceScreen()),
            ),

            // LABYRINTH
            GameTile(
              imagePath: 'assets/ui/labirynth.png',
              label: 'Labyrinth',
              onTap: () => _open(context, const LabirynthGameScreen()),
            ),

            // BROKEN MIRROR — DZIAŁAJĄCA NAWIGACJA
            GameTile(
              imagePath: 'assets/ui/mirrow.png', // zostawiam Twoją nazwę pliku
              label: 'Broken Mirror',
              onTap: () => _open(context, const BrokenMirrorGameScreen()),
            ),

            // REACTIVATOR (placeholder)
            GameTile(
              imagePath: 'assets/ui/reactivator.png',
              label: 'Reactivator',
              onTap: () => _open(
                context,
                const ComingSoonScreen(title: 'Reactivator'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Kafelek z obrazkiem + ładny overlay i ripple
class GameTile extends StatelessWidget {
  final String imagePath;
  final String label;
  final VoidCallback? onTap;

  const GameTile({
    super.key,
    required this.imagePath,
    required this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            image: DecorationImage(
              image: AssetImage(imagePath),
              fit: BoxFit.cover,
            ),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 6,
                offset: Offset(2, 4),
              ),
            ],
          ),
          child: Stack(
            children: [
              // miękka, ciemna poświata na dole pod napis
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  height: 42,
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.vertical(
                      bottom: Radius.circular(20),
                    ),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Colors.black45],
                    ),
                  ),
                ),
              ),
              // etykieta gry
              Positioned(
                left: 12,
                right: 12,
                bottom: 10,
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.left,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    shadows: [
                      Shadow(
                        blurRadius: 6,
                        color: Colors.black54,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),
              // delikatne zaokrąglenie krawędzi (antyalias)
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: const SizedBox.shrink(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}