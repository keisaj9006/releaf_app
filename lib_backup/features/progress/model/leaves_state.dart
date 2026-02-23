// lib/features/progress/model/leaves_state.dart

class LeavesState {
  final int totalLeaves;
  final String todayKey;
  final bool reliefDone;
  final bool habitDone;
  final bool brainDone;

  const LeavesState({
    required this.totalLeaves,
    required this.todayKey,
    required this.reliefDone,
    required this.habitDone,
    required this.brainDone,
  });

  LeavesState copyWith({
    int? totalLeaves,
    String? todayKey,
    bool? reliefDone,
    bool? habitDone,
    bool? brainDone,
  }) {
    return LeavesState(
      totalLeaves: totalLeaves ?? this.totalLeaves,
      todayKey: todayKey ?? this.todayKey,
      reliefDone: reliefDone ?? this.reliefDone,
      habitDone: habitDone ?? this.habitDone,
      brainDone: brainDone ?? this.brainDone,
    );
  }
}