import 'package:shared_preferences/shared_preferences.dart';

class MathRaceStats {
  final int bestScore;
  final int bestLevel;

  MathRaceStats({required this.bestScore, required this.bestLevel});

  static const _kBestScore = 'math_race_best_score';
  static const _kBestLevel = 'math_race_best_level';

  static Future<MathRaceStats> load() async {
    final prefs = await SharedPreferences.getInstance();
    final score = prefs.getInt(_kBestScore) ?? 0;
    final level = prefs.getInt(_kBestLevel) ?? 0;
    return MathRaceStats(bestScore: score, bestLevel: level);
    }

  static Future<void> saveBest({required int score, required int level}) async {
    final prefs = await SharedPreferences.getInstance();
    final prevScore = prefs.getInt(_kBestScore) ?? 0;
    final prevLevel = prefs.getInt(_kBestLevel) ?? 0;

    if (score > prevScore) {
      await prefs.setInt(_kBestScore, score);
    }
    if (level > prevLevel) {
      await prefs.setInt(_kBestLevel, level);
    }
  }
}
