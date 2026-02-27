// FILE: lib/core/paywall/paywall_trigger.dart
import 'package:shared_preferences/shared_preferences.dart';
import '../storage/prefs_keys.dart';

class PaywallTrigger {
  final SharedPreferences _prefs;

  PaywallTrigger(this._prefs);

  // Tuning knobs:
  static const int _startsThreshold = 3;
  static const int _completesThreshold = 2;
  static const Duration _cooldown = Duration(hours: 24);

  // Internal key (we keep it in the same namespace)
  static const String _lastShownIsoKey = 'releaf.paywall.last_shown_iso';

  int get reliefStarts => _prefs.getInt(PrefKeys.reliefPaywallStarts) ?? 0;
  int get reliefCompletes => _prefs.getInt(PrefKeys.reliefPaywallCompletes) ?? 0;

  Future<void> incrementReliefStart() async {
    final next = reliefStarts + 1;
    await _prefs.setInt(PrefKeys.reliefPaywallStarts, next);
  }

  Future<void> incrementReliefComplete() async {
    final next = reliefCompletes + 1;
    await _prefs.setInt(PrefKeys.reliefPaywallCompletes, next);
  }

  bool shouldShowPaywall() {
    final startsOk = reliefStarts >= _startsThreshold;
    final completesOk = reliefCompletes >= _completesThreshold;

    if (!startsOk && !completesOk) return false;

    final lastShownIso = _prefs.getString(_lastShownIsoKey);
    if (lastShownIso == null || lastShownIso.isEmpty) return true;

    final lastShown = DateTime.tryParse(lastShownIso);
    if (lastShown == null) return true;

    final now = DateTime.now();
    return now.difference(lastShown) >= _cooldown;
  }

  Future<void> markPaywallShown() async {
    await _prefs.setString(_lastShownIsoKey, DateTime.now().toIso8601String());
  }

  /// Optional: call this after successful purchase/upgrade.
  Future<void> resetReliefCounters() async {
    await _prefs.setInt(PrefKeys.reliefPaywallStarts, 0);
    await _prefs.setInt(PrefKeys.reliefPaywallCompletes, 0);
  }
}