import 'reset_completion_store.dart';

class ResetProgressSummary {
  const ResetProgressSummary({
    required this.totalCompletions,
    required this.sessionsLast7Days,
    required this.activeDaysLast7Days,
    required this.distinctSessions,
  });

  final int totalCompletions;
  final int sessionsLast7Days;
  final int activeDaysLast7Days;
  final int distinctSessions;

  factory ResetProgressSummary.fromRecords(
    Iterable<ResetCompletionRecord> records, {
    DateTime? now,
  }) {
    final snapshot = records.toList(growable: false);
    final localNow = (now ?? DateTime.now()).toLocal();
    final today = DateTime(localNow.year, localNow.month, localNow.day);
    final firstIncludedDay = today.subtract(const Duration(days: 6));
    final activeDays = <DateTime>{};
    var sessionsLast7Days = 0;

    for (final record in snapshot) {
      final local = record.completedAt.toLocal();
      final day = DateTime(local.year, local.month, local.day);
      if (day.isBefore(firstIncludedDay) || day.isAfter(today)) continue;

      sessionsLast7Days += 1;
      activeDays.add(day);
    }

    return ResetProgressSummary(
      totalCompletions: snapshot.length,
      sessionsLast7Days: sessionsLast7Days,
      activeDaysLast7Days: activeDays.length,
      distinctSessions: snapshot.map((record) => record.sessionId).toSet().length,
    );
  }
}
