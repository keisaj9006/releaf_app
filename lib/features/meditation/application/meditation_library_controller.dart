import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/providers.dart';

class MeditationLibraryState {
  const MeditationLibraryState({
    this.favoriteIds = const <String>{},
    this.recentIds = const <String>[],
    this.completedIds = const <String>{},
  });

  final Set<String> favoriteIds;
  final List<String> recentIds;
  final Set<String> completedIds;

  bool isFavorite(String id) => favoriteIds.contains(id);
  bool isCompleted(String id) => completedIds.contains(id);

  int completedInSeries(Iterable<String> ids) {
    final seriesIds = ids.toSet();
    return completedIds.where(seriesIds.contains).length;
  }

  MeditationLibraryState copyWith({
    Set<String>? favoriteIds,
    List<String>? recentIds,
    Set<String>? completedIds,
  }) {
    return MeditationLibraryState(
      favoriteIds: favoriteIds ?? this.favoriteIds,
      recentIds: recentIds ?? this.recentIds,
      completedIds: completedIds ?? this.completedIds,
    );
  }
}

final meditationLibraryControllerProvider = StateNotifierProvider<
    MeditationLibraryController, MeditationLibraryState>((ref) {
  return MeditationLibraryController(
    ref.watch(sharedPreferencesProvider),
  );
});

class MeditationLibraryController extends StateNotifier<MeditationLibraryState> {
  MeditationLibraryController(this._prefs)
      : super(
          MeditationLibraryState(
            favoriteIds:
                (_prefs.getStringList(_favoritesKey) ?? const <String>[]).toSet(),
            recentIds:
                _prefs.getStringList(_recentsKey) ?? const <String>[],
            completedIds:
                (_prefs.getStringList(_completedKey) ?? const <String>[]).toSet(),
          ),
        );

  static const _favoritesKey = 'meditation.favorite_ids';
  static const _recentsKey = 'meditation.recent_ids';
  static const _completedKey = 'meditation.completed_ids';

  final SharedPreferences _prefs;

  Future<void> toggleFavorite(String id) async {
    final next = Set<String>.from(state.favoriteIds);
    if (!next.add(id)) {
      next.remove(id);
    }
    state = state.copyWith(favoriteIds: next);
    await _prefs.setStringList(_favoritesKey, next.toList(growable: false));
  }

  Future<void> markRecent(String id) async {
    final next = <String>[
      id,
      ...state.recentIds.where((existingId) => existingId != id),
    ].take(8).toList(growable: false);

    state = state.copyWith(recentIds: next);
    await _prefs.setStringList(_recentsKey, next);
  }

  Future<void> markCompleted(String id) async {
    if (state.completedIds.contains(id)) return;

    final next = Set<String>.from(state.completedIds)..add(id);
    state = state.copyWith(completedIds: next);
    await _prefs.setStringList(_completedKey, next.toList(growable: false));
  }
}
