import 'revenuecat_service.dart';

typedef RevenueCatIdentifyUser = Future<bool> Function(String userId);
typedef RevenueCatClearUser = Future<bool> Function();
typedef RevenueCatSubscriptionRefresh = Future<void> Function();
typedef RevenueCatIdentityBoundary = void Function();

/// Serializes Supabase identity changes into RevenueCat identity changes.
///
/// Auth transitions can happen outside the Account screen (restored sessions,
/// confirmation/deep links, password recovery, token refresh and server-side
/// account deletion). Keeping this coordinator at app scope prevents Premium
/// ownership from depending on a particular screen interaction.
class RevenueCatAuthIdentityCoordinator {
  RevenueCatAuthIdentityCoordinator({
    required RevenueCatIdentifyUser identifyUser,
    required RevenueCatClearUser clearUser,
    required RevenueCatSubscriptionRefresh refreshSubscriptions,
    RevenueCatIdentityBoundary? beginIdentityChange,
    String? initialUserId,
  })  : _identifyUser = identifyUser,
        _clearUser = clearUser,
        _refreshSubscriptions = refreshSubscriptions,
        _beginIdentityChange = beginIdentityChange ?? _noop,
        _activeUserId = _normalizeUserId(initialUserId);

  factory RevenueCatAuthIdentityCoordinator.forService({
    required RevenueCatService service,
    required RevenueCatSubscriptionRefresh refreshSubscriptions,
    RevenueCatIdentityBoundary? beginIdentityChange,
    String? initialUserId,
  }) {
    return RevenueCatAuthIdentityCoordinator(
      identifyUser: (userId) async =>
          await service.identifyUser(userId) != null,
      clearUser: () async =>
          await service.clearUserIdentity() != null,
      refreshSubscriptions: refreshSubscriptions,
      beginIdentityChange: beginIdentityChange,
      initialUserId: initialUserId,
    );
  }

  final RevenueCatIdentifyUser _identifyUser;
  final RevenueCatClearUser _clearUser;
  final RevenueCatSubscriptionRefresh _refreshSubscriptions;
  final RevenueCatIdentityBoundary _beginIdentityChange;

  String? _activeUserId;
  Future<void> _queue = Future<void>.value();

  String? get activeUserId => _activeUserId;

  Future<bool> syncUser(String? userId) {
    final normalized = _normalizeUserId(userId);
    final result = _queue.then<bool>((_) => _sync(normalized));
    _queue = result.then<void>(
      (_) {},
      onError: (Object _, StackTrace _) {},
    );
    return result;
  }

  Future<bool> _sync(String? nextUserId) async {
    if (nextUserId == _activeUserId) return true;

    // Fail closed before mutating the store identity. Without this boundary a
    // transient CustomerInfo refresh failure could leave the previous user's
    // Premium entitlement visible after a Supabase account switch.
    _beginIdentityChange();

    final changed = nextUserId == null
        ? await _clearUser()
        : await _identifyUser(nextUserId);

    if (!changed) {
      // Try to recover the authoritative entitlement for whichever RevenueCat
      // identity is still active. If this also fails, the boundary remains
      // safely non-Premium and a later lifecycle refresh can recover it.
      try {
        await _refreshSubscriptions();
      } catch (_) {}
      return false;
    }

    _activeUserId = nextUserId;

    try {
      await _refreshSubscriptions();
    } catch (_) {
      // Identity is already synchronized. A later normal subscription refresh
      // can recover UI state without repeating the store identity mutation.
    }

    return true;
  }

  static String? _normalizeUserId(String? raw) {
    final value = raw?.trim();
    return value == null || value.isEmpty ? null : value;
  }

  static void _noop() {}
}
