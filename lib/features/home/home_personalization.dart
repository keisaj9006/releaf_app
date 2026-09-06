import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/providers.dart';

enum HomeFocus {
  steady,
  focus,
  mindfulness,
  sleep,
}

extension HomeFocusCopy on HomeFocus {
  String get label => switch (this) {
        HomeFocus.steady => 'Feel steadier',
        HomeFocus.focus => 'Focus better',
        HomeFocus.mindfulness => 'Build mindfulness',
        HomeFocus.sleep => 'Sleep easier',
      };

  String get description => switch (this) {
        HomeFocus.steady =>
          'Prioritise short grounding and regulation when there is no stronger right-now signal.',
        HomeFocus.focus =>
          'Bring cognitive training forward when it still fits your day.',
        HomeFocus.mindfulness =>
          'Surface meditation more often as your default practice.',
        HomeFocus.sleep =>
          'Shift recommendations toward the evening and night experience.',
      };
}

class HomeFocusController extends StateNotifier<HomeFocus?> {
  HomeFocusController(this._preferences)
      : super(_decode(_preferences.getString(_storageKey)));

  static const _storageKey = 'releaf.home.focus.v1';

  final SharedPreferences _preferences;

  Future<void> setFocus(HomeFocus? focus) async {
    state = focus;
    if (focus == null) {
      await _preferences.remove(_storageKey);
      return;
    }
    await _preferences.setString(_storageKey, focus.name);
  }

  static HomeFocus? _decode(String? raw) {
    if (raw == null) return null;
    for (final focus in HomeFocus.values) {
      if (focus.name == raw) return focus;
    }
    return null;
  }
}

final homeFocusProvider =
    StateNotifierProvider<HomeFocusController, HomeFocus?>((ref) {
  final preferences = ref.watch(sharedPreferencesProvider);
  return HomeFocusController(preferences);
});


class HomeIntroController extends StateNotifier<bool> {
  HomeIntroController(this._preferences)
      : super(
          !(_preferences.getBool(_storageKey) ?? false) &&
              _preferences.getString(HomeFocusController._storageKey) == null,
        );

  static const _storageKey = 'releaf.home.intro.dismissed.v1';

  final SharedPreferences _preferences;

  Future<void> dismiss() async {
    if (!state) return;
    state = false;
    await _preferences.setBool(_storageKey, true);
  }
}

final homeIntroProvider =
    StateNotifierProvider<HomeIntroController, bool>((ref) {
  final preferences = ref.watch(sharedPreferencesProvider);
  return HomeIntroController(preferences);
});
