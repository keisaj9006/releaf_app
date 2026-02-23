// FILE: lib/features/brain/data/brain_repository.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/storage/prefs_keys.dart';

class BrainSessionResult {
  final String gameId;
  final int score;
  final int durationSeconds;
  final DateTime finishedAt;

  const BrainSessionResult({
    required this.gameId,
    required this.score,
    required this.durationSeconds,
    required this.finishedAt,
  });

  Map<String, dynamic> toJson() => {
        'gameId': gameId,
        'score': score,
        'durationSeconds': durationSeconds,
        'finishedAt': finishedAt.toIso8601String(),
      };

  static BrainSessionResult fromJson(Map<String, dynamic> json) {
    return BrainSessionResult(
      gameId: json['gameId'] as String,
      score: json['score'] as int,
      durationSeconds: json['durationSeconds'] as int,
      finishedAt: DateTime.parse(json['finishedAt'] as String),
    );
  }
}

class BrainRepository {
  BrainRepository(this._prefs);

  final SharedPreferences _prefs;

  List<BrainSessionResult> loadSessions() {
    final jsonStr = _prefs.getString(PrefKeys.brainSessionsJson);
    if (jsonStr == null || jsonStr.isEmpty) return const [];
    final decoded = json.decode(jsonStr) as List<dynamic>;
    return decoded.map((e) => BrainSessionResult.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> saveSession(BrainSessionResult result) async {
    final existing = loadSessions().toList();
    existing.insert(0, result);

    // MVP scaling guard: keep last 100 only
    final trimmed = existing.take(100).toList();

    final jsonStr = json.encode(trimmed.map((e) => e.toJson()).toList());
    await _prefs.setString(PrefKeys.brainSessionsJson, jsonStr);
  }
}