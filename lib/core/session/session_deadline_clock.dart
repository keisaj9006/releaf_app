/// Wall-clock helper for timed wellbeing sessions.
///
/// Flutter timers can be throttled while the app is backgrounded. Session
/// progress should therefore be derived from a real deadline instead of from
/// the number of timer callbacks that happened to run.
abstract final class SessionDeadlineClock {
  static DateTime deadlineFor(
    int remainingSeconds, {
    DateTime? now,
  }) {
    final safeSeconds = remainingSeconds < 0 ? 0 : remainingSeconds;
    return (now ?? DateTime.now()).add(Duration(seconds: safeSeconds));
  }

  static int remainingSeconds(
    DateTime deadline, {
    DateTime? now,
  }) {
    final milliseconds =
        deadline.difference(now ?? DateTime.now()).inMilliseconds;
    if (milliseconds <= 0) return 0;

    // Round up so the UI never completes a session early because a periodic
    // callback arrived a few milliseconds after the exact second boundary.
    return (milliseconds + 999) ~/ 1000;
  }
}
