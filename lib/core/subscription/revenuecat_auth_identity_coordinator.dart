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
    RevenueCatIdentityBoundary? completeIdentityChange,
    RevenueCatIdentityBoundary? failIdentityChange,
    String? initialUserId,
  }) : _identifyUser = identifyUser,
       _clearUser = clearUser,
       _refreshSubscriptions = refreshSubscriptions,
       _beginIdentityChange = beginIdentityChange ?? _noop,
       _completeIdentityChange = completeIdentityChange ?? _noop,
       _failIdentityChange = failIdentityChange ?? _noop,
       _activeUserId = _normalizeUserId(initialUserId);

  factory RevenueCatAuthIdentityCoordinator.forService({
    required RevenueCatService service,
    required RevenueCatSubscriptionRefresh refreshSubscriptions,
    RevenueCatIdentityBoundary? beginIdentityChange,
    RevenueCatIdentityBoundary? completeIdentityChange,
    RevenueCatIdentityBoundary? failIdentityChange,
    String? initialUserId,
  }) {
    return RevenueCatAuthIdentityCoordinator(
      identifyUser: (userId) async =>
          await service.identifyUser(userId) != null,
      clearUser: () async => await service.clearUserIdentity() != null,
      refreshSubscriptions: refreshSubscriptions,
      beginIdentityChange: beginIdentityChange,
      completeIdentityChange: completeIdentityChange,
      failIdentityChange: failIdentityChange,
      initialUserId: initialUserId,
    );
  }

  final RevenueCatIdentifyUser _identifyUser;
  final RevenueCatClearUser _clearUser;
  final RevenueCatSubscriptionRefresh _refreshSubscriptions;
  final RevenueCatIdentityBoundary _beginIdentityChange;
  final RevenueCatIdentityBoundary _completeIdentityChange;
  final RevenueCatIdentityBoundary _failIdentityChange;
  int _requestVersion = 0;
  bool _pending = false;

  String? _activeUserId;
  Future<void> _queue = Future<void>.value();

  String? get activeUserId => _activeUserId;

  Future<bool> syncUser(String? userId) {
    final normalized = _normalizeUserId(userId);
    if (normalized == _activeUserId && !_pending) return Future.value(true);
    final version = ++_requestVersion;
    _pending = true;
    // Close access immediately, even while an older mutation is awaiting the SDK.
    _beginIdentityChange();
    final result = _queue.then<bool>((_) => _sync(normalized, version));
    _queue = result.then<void>((_) {}, onError: (Object _, StackTrace _) {});
    return result;
  }

  Future<bool> _sync(String? nextUserId, int version) async {
    if (version != _requestVersion) return false;
    bool changed;
    try {
      changed =
          nextUserId == _activeUserId ||
          (nextUserId == null
              ? await _clearUser()
              : await _identifyUser(nextUserId));
    } catch (_) {
      changed = false;
    }

    if (!changed) {
      // The SDK may still hold the previous account. Never refresh its access.
      if (version == _requestVersion) _failIdentityChange();
      return false;
    }

    _activeUserId = nextUserId;
    if (version != _requestVersion) return false;
    _pending = false;
    _completeIdentityChange();

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
