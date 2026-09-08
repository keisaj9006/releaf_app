import 'package:flutter_test/flutter_test.dart';

import 'package:releaf_app/core/session/session_deadline_clock.dart';

void main() {
  test('deadline clock follows wall time instead of timer callback count', () {
    final start = DateTime.utc(2026, 9, 8, 9);
    final deadline = SessionDeadlineClock.deadlineFor(
      120,
      now: start,
    );

    expect(
      SessionDeadlineClock.remainingSeconds(
        deadline,
        now: start.add(const Duration(seconds: 1)),
      ),
      119,
    );
    expect(
      SessionDeadlineClock.remainingSeconds(
        deadline,
        now: start.add(const Duration(seconds: 47)),
      ),
      73,
    );
    expect(
      SessionDeadlineClock.remainingSeconds(
        deadline,
        now: start.add(const Duration(seconds: 121)),
      ),
      0,
    );
  });

  test('deadline clock rounds partial final seconds up', () {
    final start = DateTime.utc(2026, 9, 8, 9);
    final deadline = start.add(const Duration(milliseconds: 1500));

    expect(
      SessionDeadlineClock.remainingSeconds(deadline, now: start),
      2,
    );
    expect(
      SessionDeadlineClock.remainingSeconds(
        deadline,
        now: start.add(const Duration(milliseconds: 600)),
      ),
      1,
    );
  });
}
