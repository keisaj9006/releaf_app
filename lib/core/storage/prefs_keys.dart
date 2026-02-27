// FILE: lib/core/storage/prefs_keys.dart
//
// Releaf — SharedPreferences key contract.
// Cel: jeden spójny namespace, zero losowych stringów w UI/grach.
//
// Zasady:
// - Wszystko ma prefix "releaf."
// - Klucze są pogrupowane per feature
// - Mamy wersję schematu do migracji (kiedyś się przyda, serio).

class PrefKeys {
  PrefKeys._();

  /// Zmieniaj tylko, gdy robisz migrację danych.
  static const String schemaVersion = 'releaf.schema_version';

  /// Globalny prefix dla całej apki.
  static const String _p = 'releaf.';

  // -----------------------
  // PROGRESS / LEAVES
  // -----------------------
  static const String leavesTotal = '${_p}progress.leaves.total';

  /// Flagi "czy dziś zaliczone" (Home -> Today)
  static const String todayHabitDone = '${_p}progress.today.habit_done';
  static const String todayReliefDone = '${_p}progress.today.relief_done';
  static const String todayBrainDone = '${_p}progress.today.brain_done';

  /// Dzień referencyjny dla resetu daily (format: YYYY-MM-DD)
  static const String todayKey = '${_p}progress.today.key';

  // -----------------------
  // HABITS
  // -----------------------
  static const String habitsListJson = '${_p}habits.list_json';
  static const String habitsLastCompletedIso = '${_p}habits.last_completed_iso';

  // -----------------------
  // RELIEF
  // -----------------------
  static const String reliefSessionsTotal = '${_p}relief.sessions_total';
  static const String reliefLastSessionIso = '${_p}relief.last_session_iso';

  /// Paywall counters (non-premium only)
  static const String reliefPaywallStarts = '${_p}relief.paywall.starts';
  static const String reliefPaywallCompletes = '${_p}relief.paywall.completes';

  // -----------------------
  // BRAIN — meta (wspólne)
  // -----------------------
  static const String brainSessionsTotal = '${_p}brain.sessions_total';
  static const String brainLastSessionIso = '${_p}brain.last_session_iso';

  // -----------------------
  // BRAIN — Memory
  // -----------------------
  static const String memoryCurrentLevel = '${_p}brain.memory.current_level';

  /// Best score per level (int) — np. releaf.brain.memory.best_score.12
  static String memoryBestScore(int level) => '${_p}brain.memory.best_score.$level';

  /// Statystyki per level (czas/mistakes)
  static String memoryStatsTime(int level) => '${_p}brain.memory.stats.time.$level';
  static String memoryStatsMistakes(int level) => '${_p}brain.memory.stats.mistakes.$level';

  // -----------------------
  // BRAIN — Math Race (przykład)
  // -----------------------
  static const String mathRaceBestScore = '${_p}brain.math_race.best_score';
  static const String mathRaceLastScore = '${_p}brain.math_race.last_score';

  // -----------------------
  // BRAIN — Labyrinth (przykład)
  // -----------------------
  static const String labyrinthBestTimeMs = '${_p}brain.labyrinth.best_time_ms';
  static const String labyrinthLastTimeMs = '${_p}brain.labyrinth.last_time_ms';

  // -----------------------
  // LEGACY KEYS (do odczytu / migracji)
  // -----------------------
  //
  // To są stare klucze, które istnieją już u Ciebie w działających ekranach (screens/*).
  // Nie używamy ich do zapisu w nowym kodzie — tylko do:
  // - odczytu, jeśli nowe klucze są puste
  // - jednorazowej migracji do nowych kluczy
  //
  // Dzięki temu nie tracisz progresu usera po aktualizacji.
  static const String legacyMemoryCurrentLevel = 'memory_current_level';
  static String legacyMemoryStatsTime(int level) => 'memory_stats_time_$level';
  static String legacyMemoryStatsMistakes(int level) => 'memory_stats_mistakes_$level';
}