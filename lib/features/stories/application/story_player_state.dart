import '../domain/relief_story.dart';

class StoryPlayerState {
  const StoryPlayerState({
    this.story,
    this.isPlaying = false,
    this.isLoading = false,
    this.warningRequired = false,
    this.isAudioUnavailable = false,
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.rate = 1.0,
    this.completed = false,
    this.sleepTimerRemainingSeconds,
    this.errorMessage,
  });

  final ReliefStory? story;
  final bool isPlaying;
  final bool isLoading;
  final bool warningRequired;
  final bool isAudioUnavailable;
  final Duration position;
  final Duration duration;
  final double rate;
  final bool completed;
  final int? sleepTimerRemainingSeconds;
  final String? errorMessage;

  StoryPlayerState copyWith({
    bool? isPlaying,
    bool? isLoading,
    bool? warningRequired,
    Duration? position,
    Duration? duration,
    double? rate,
    bool? completed,
    int? sleepTimerRemainingSeconds,
    bool clearSleepTimer = false,
    String? errorMessage,
    bool clearError = false,
  }) => StoryPlayerState(
    story: story,
    isPlaying: isPlaying ?? this.isPlaying,
    isLoading: isLoading ?? this.isLoading,
    warningRequired: warningRequired ?? this.warningRequired,
    isAudioUnavailable: isAudioUnavailable,
    position: position ?? this.position,
    duration: duration ?? this.duration,
    rate: rate ?? this.rate,
    completed: completed ?? this.completed,
    sleepTimerRemainingSeconds: clearSleepTimer
        ? null
        : (sleepTimerRemainingSeconds ?? this.sleepTimerRemainingSeconds),
    errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
  );
}
