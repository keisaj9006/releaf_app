import 'package:flutter_test/flutter_test.dart';

import 'package:releaf_app/features/relief/application/reset_completion_store.dart';
import 'package:releaf_app/features/relief/application/reset_progress_summary.dart';

ResetCompletionRecord _record(
  String id,
  String sessionId,
  DateTime completedAt,
) {
  return ResetCompletionRecord(
    id: id,
    sessionId: sessionId,
    completedAt: completedAt.toUtc(),
    durationSeconds: 120,
  );
}

void main() {
  test('Reset progress summary uses a seven-day local calendar window', () {
    final now = DateTime(2026, 9, 9, 12);
    final summary = ResetProgressSummary.fromRecords(
      <ResetCompletionRecord>[
        _record('1', 'equal-rhythm', DateTime(2026, 9, 9, 8)),
        _record('2', 'equal-rhythm', DateTime(2026, 9, 9, 9)),
        _record('3', 'back-to-room', DateTime(2026, 9, 3, 18)),
        _record('4', 'jaw-shoulders', DateTime(2026, 9, 2, 23)),
      ],
      now: now,
    );

    expect(summary.totalCompletions, 4);
    expect(summary.sessionsLast7Days, 3);
    expect(summary.activeDaysLast7Days, 2);
    expect(summary.distinctSessions, 3);
  });

  test('Future-dated records do not inflate current seven-day activity', () {
    final now = DateTime(2026, 9, 9, 12);
    final summary = ResetProgressSummary.fromRecords(
      <ResetCompletionRecord>[
        _record('1', 'equal-rhythm', DateTime(2026, 9, 10, 8)),
      ],
      now: now,
    );

    expect(summary.totalCompletions, 1);
    expect(summary.sessionsLast7Days, 0);
    expect(summary.activeDaysLast7Days, 0);
  });
}
