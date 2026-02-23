// FILE: lib/features/brain/presentation/session_contract.dart
/// Defines the signature for a callback that is invoked when a brain
/// session is complete. It can provide the game identifier along with
/// optional score and duration values.
typedef OnSessionComplete = void Function({
  required String gameId,
  int? score,
  Duration? duration,
});