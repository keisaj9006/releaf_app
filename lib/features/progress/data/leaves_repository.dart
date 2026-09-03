import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';
import '../model/leaves_state.dart';

final leavesNotifierProvider =
StateNotifierProvider<LeavesNotifier, LeavesState>(
      (ref) => LeavesNotifier(ref),
);

/// Zwracamy to do UI, żeby móc pokazać SnackBar / Haptic / “Perfect day”.
class RewardResult {
  final int added; // baza (np. Brain=2)
  final int bonusAdded; // bonus za 3/3 (np. +2)
  final int newTotal;
  final int completedToday; // 0..3

  const RewardResult({
    required this.added,
    required this.bonusAdded,
    required this.newTotal,
    required this.completedToday,
  });

  bool get hasBonus => bonusAdded > 0;
  int get totalAdded => added + bonusAdded;
}

class LeavesNotifier extends StateNotifier<LeavesState> {
  final Ref ref;
  late final Future<void> _ready;
  Future<void> _operationQueue = Future<void>.value();

  LeavesNotifier(this.ref)
      : super(
    LeavesState(
      totalLeaves: 0,
      todayKey: _currentDateString(),
      reliefDone: false,
      habitDone: false,
      brainDone: false,
    ),
  ) {
    _ready = _load();
  }

  // ---- Rewards (P0) ----
  static const int _habitReward = 1;
  static const int _reliefReward = 1;
  static const int _brainReward = 2;

  // “podwójnie za trzeci filar” = bonus równy bazie trzeciego filaru
  static int _bonusForThird(int base) => base;

  // ---- Pref keys (z migracją) ----
  static const String _kTotalLeaves = 'totalLeaves';
  static const String _kOldLeavesTotal = 'leaves_total'; // legacy
  static const String _kTodayKey = 'todayKey';
  static const String _kReliefDone = 'reliefDone';
  static const String _kHabitDone = 'habitDone';
  static const String _kBrainDone = 'brainDone';

  static String _currentDateString() {
    final now = DateTime.now();
    final y = now.year.toString().padLeft(4, '0');
    final m = now.month.toString().padLeft(2, '0');
    final d = now.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  /// ✅ Normalizacja: dzisiejszy key zawsze jako NON-null String.
  String _todayKey() {
    final fromProvider = ref.read(todayProvider);
    if (fromProvider.isNotEmpty) return fromProvider;
    return _currentDateString();
  }

  int _completedCount(LeavesState s) {
    var c = 0;
    if (s.habitDone) c++;
    if (s.reliefDone) c++;
    if (s.brainDone) c++;
    return c;
  }

  Future<void> _load() async {
    final prefs = ref.read(sharedPreferencesProvider);

    // migracja: jeśli ktoś ma stary klucz, przenieś do nowego
    final oldTotal = prefs.getInt(_kOldLeavesTotal);
    final storedTotal = prefs.getInt(_kTotalLeaves);
    final total = storedTotal ?? oldTotal ?? 0;

    if (oldTotal != null && storedTotal == null) {
      await prefs.setInt(_kTotalLeaves, oldTotal);
    }

    // ✅ TU gwarantujemy String (nigdy null)
    final date = prefs.getString(_kTodayKey) ?? _todayKey();

    final reliefDone = prefs.getBool(_kReliefDone) ?? false;
    final habitDone = prefs.getBool(_kHabitDone) ?? false;
    final brainDone = prefs.getBool(_kBrainDone) ?? false;

    state = LeavesState(
      totalLeaves: total,
      todayKey: date,
      reliefDone: reliefDone,
      habitDone: habitDone,
      brainDone: brainDone,
    );

    await _resetIfNewDay();
  }

  Future<void> _resetIfNewDay() async {
    final current = _todayKey();
    if (state.todayKey == current) return;

    final prefs = ref.read(sharedPreferencesProvider);
    final resetState = state.copyWith(
      todayKey: current,
      reliefDone: false,
      habitDone: false,
      brainDone: false,
    );

    await prefs.setString(_kTodayKey, current);
    await prefs.setBool(_kReliefDone, false);
    await prefs.setBool(_kHabitDone, false);
    await prefs.setBool(_kBrainDone, false);
    state = resetState;
  }

  Future<void> _persistTotal(int total) async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setInt(_kTotalLeaves, total);
  }

  Future<void> _persistFlag(String key, bool value) async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setBool(key, value);
  }

  /// Narzędzie ogólne – UI nie powinno tego wołać zamiast "markXDone".
  Future<void> addLeaves(int amount) => _runExclusive(() async {
    await _resetIfNewDay();
    final newTotal = state.totalLeaves + amount;
    await _persistTotal(newTotal);
    state = state.copyWith(totalLeaves: newTotal);
  });

  /// Relief: raz dziennie +1 (i bonus jeśli to 3/3)
  Future<RewardResult?> markReliefDone() {
    return _runExclusive(() => _complete(
      baseReward: _reliefReward,
      isDone: (current) => current.reliefDone,
      markDone: (current) => current.copyWith(reliefDone: true),
      flagKey: _kReliefDone,
    ));
  }

  /// Habits: raz dziennie +1 (i bonus jeśli to 3/3)
  Future<RewardResult?> markHabitDone() {
    return _runExclusive(() => _complete(
      baseReward: _habitReward,
      isDone: (current) => current.habitDone,
      markDone: (current) => current.copyWith(habitDone: true),
      flagKey: _kHabitDone,
    ));
  }

  /// Brain: raz dziennie +2 (i bonus jeśli to 3/3)
  Future<RewardResult?> markBrainDone() {
    return _runExclusive(() => _complete(
      baseReward: _brainReward,
      isDone: (current) => current.brainDone,
      markDone: (current) => current.copyWith(brainDone: true),
      flagKey: _kBrainDone,
    ));
  }

  Future<RewardResult?> _complete({
    required int baseReward,
    required bool Function(LeavesState) isDone,
    required LeavesState Function(LeavesState) markDone,
    required String flagKey,
  }) async {
    await _resetIfNewDay();
    if (isDone(state)) return null;

    final completedState = markDone(state);
    final completedNow = _completedCount(completedState);
    final isThird = completedNow == 3;
    final bonus = isThird ? _bonusForThird(baseReward) : 0;

    final newTotal = completedState.totalLeaves + baseReward + bonus;
    final nextState = completedState.copyWith(totalLeaves: newTotal);

    await _persistFlag(flagKey, true);
    await _persistTotal(newTotal);
    state = nextState;

    return RewardResult(
      added: baseReward,
      bonusAdded: bonus,
      newTotal: newTotal,
      completedToday: completedNow,
    );
  }

  Future<T> _runExclusive<T>(Future<T> Function() operation) {
    final result = _operationQueue.then<T>((_) async {
      await _ready;
      return operation();
    });

    _operationQueue = result.then<void>(
      (_) {},
      onError: (Object _, StackTrace _) {},
    );
    return result;
  }
}
