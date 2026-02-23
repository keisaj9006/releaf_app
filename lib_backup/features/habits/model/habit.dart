// FILE: lib/features/habits/model/habit.dart
/// Represents a single habit with its identifier, title and completion
/// status for the current day.
class Habit {
  final String id;
  final String title;
  final bool isDone;

  const Habit({
    required this.id,
    required this.title,
    this.isDone = false,
  });

  Habit copyWith({bool? isDone}) {
    return Habit(
      id: id,
      title: title,
      isDone: isDone ?? this.isDone,
    );
  }
}