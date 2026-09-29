import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/providers.dart';
import 'whats_new_content.dart';

abstract interface class WhatsNewStore {
  String? readLastAcknowledgedRelease();
  Future<bool> writeLastAcknowledgedRelease(String releaseId);
}

class SharedPreferencesWhatsNewStore implements WhatsNewStore {
  const SharedPreferencesWhatsNewStore(this._preferences);
  static const storageKey = 'releaf.whats_new.last_acknowledged.v1';
  final SharedPreferences _preferences;

  @override
  String? readLastAcknowledgedRelease() => _preferences.getString(storageKey);

  @override
  Future<bool> writeLastAcknowledgedRelease(String releaseId) =>
      _preferences.setString(storageKey, releaseId);
}

class WhatsNewState {
  const WhatsNewState({required this.show, required this.releaseId});
  final bool show;
  final String releaseId;
}

class WhatsNewController extends StateNotifier<WhatsNewState> {
  WhatsNewController(
    this._store, {
    WhatsNewContent content = WhatsNewContent.current,
  }) : super(_initialState(_store, content));

  final WhatsNewStore _store;

  static WhatsNewState _initialState(
    WhatsNewStore store,
    WhatsNewContent content,
  ) {
    try {
      return WhatsNewState(
        show: store.readLastAcknowledgedRelease() != content.releaseId,
        releaseId: content.releaseId,
      );
    } catch (_) {
      return WhatsNewState(show: false, releaseId: content.releaseId);
    }
  }

  Future<void> acknowledge() async {
    if (!state.show) return;
    final releaseId = state.releaseId;
    state = WhatsNewState(show: false, releaseId: releaseId);
    try {
      await _store.writeLastAcknowledgedRelease(releaseId);
    } catch (_) {
      // Home remains accessible; a later launch may show this release again.
    }
  }
}

final whatsNewProvider =
    StateNotifierProvider<WhatsNewController, WhatsNewState>((ref) {
      final preferences = ref.watch(sharedPreferencesProvider);
      return WhatsNewController(SharedPreferencesWhatsNewStore(preferences));
    });
