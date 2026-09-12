// FILE: lib/core/subscription/revenuecat_service.dart
import 'package:flutter/foundation.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class RevenueCatService {
  static const String _premiumEntitlementId = 'premium';

  bool _initialized = false;
  bool _debugLogging = false;
  bool get isInitialized => _initialized;

  /// Build-time SDK keys must be supplied outside source control. This accepts
  /// public SDK keys only by shape; release tooling separately enforces the
  /// production Google key policy.
  static bool hasConfiguredApiKey(String apiKey) {
    final trimmedKey = apiKey.trim();
    if (RegExp(r'\s').hasMatch(trimmedKey)) return false;
    return ['test_', 'goog_', 'appl_'].any(
      (prefix) =>
          trimmedKey.startsWith(prefix) &&
          trimmedKey.length > prefix.length + 8,
    );
  }

  Future<void> init({
    required String apiKey,
    required bool debug,
    String? appUserId,
  }) async {
    _debugLogging = debug;
    if (_initialized) {
      _debugLog('Initialization skipped; Purchases is already configured.');
      return;
    }

    final trimmedKey = apiKey.trim();
    _debugLog(
      'Initialization requested; public SDK key present='
      '${hasConfiguredApiKey(trimmedKey)}.',
    );
    if (!hasConfiguredApiKey(trimmedKey)) {
      _debugLog(
        'Initialization skipped; no usable public SDK key was supplied.',
      );
      return;
    }

    try {
      await Purchases.setLogLevel(debug ? LogLevel.debug : LogLevel.info);
      await Purchases.configure(
        buildConfiguration(apiKey: trimmedKey, appUserId: appUserId),
      );
      _initialized = true;
      _debugLog('Purchases.configure completed.');
      await _logCurrentAppUserId('after Purchases.configure');
    } on Object catch (error) {
      _initialized = false;
      _debugLog('Purchases.configure failed (${error.runtimeType}).');
    }
  }

  static PurchasesConfiguration buildConfiguration({
    required String apiKey,
    String? appUserId,
  }) {
    final configuration = PurchasesConfiguration(apiKey.trim());
    final safeAppUserId = appUserId?.trim();
    if (safeAppUserId != null && safeAppUserId.isNotEmpty) {
      configuration.appUserID = safeAppUserId;
    }
    return configuration;
  }

  Future<CustomerInfo?> identifyUser(String appUserId) async {
    if (!_initialized || appUserId.trim().isEmpty) {
      _debugLog(
        'Purchases.logIn skipped; Purchases is not configured or user ID is empty.',
      );
      return null;
    }
    try {
      final result = await Purchases.logIn(appUserId.trim());
      _debugLog('Purchases.logIn completed.');
      await _logCurrentAppUserId('after Purchases.logIn');
      return result.customerInfo;
    } on Object catch (error) {
      _debugLog('Purchases.logIn failed (${error.runtimeType}).');
      return null;
    }
  }

  Future<CustomerInfo?> clearUserIdentity() async {
    if (!_initialized) return null;
    try {
      return await Purchases.logOut();
    } catch (_) {
      return null;
    }
  }

  Future<CustomerInfo?> getCustomerInfoSafe() async {
    if (!_initialized) return null;
    try {
      return await Purchases.getCustomerInfo();
    } catch (_) {
      return null;
    }
  }

  Future<Offerings?> getOfferingsSafe() async {
    if (!_initialized) return null;
    try {
      final offerings = await Purchases.getOfferings();
      _debugLog(
        'Purchases.getOfferings completed; current offering present='
        '${offerings.current != null}.',
      );
      return offerings;
    } on Object catch (error) {
      _debugLog('Purchases.getOfferings failed (${error.runtimeType}).');
      return null;
    }
  }

  Future<void> _logCurrentAppUserId(String context) async {
    if (!_debugLogging) return;
    try {
      final appUserId = await Purchases.appUserID;
      _debugLog('$context; current appUserID=$appUserId.');
    } on Object catch (error) {
      _debugLog('$context; unable to read appUserID (${error.runtimeType}).');
    }
  }

  void _debugLog(String message) {
    if (_debugLogging) debugPrint('[RevenueCat] $message');
  }

  bool hasPremium(CustomerInfo customerInfo) {
    return customerInfo.entitlements.active.containsKey(_premiumEntitlementId);
  }

  void addCustomerInfoUpdateListener(CustomerInfoUpdateListener listener) {
    if (!_initialized) return;
    Purchases.addCustomerInfoUpdateListener(listener);
  }

  void removeCustomerInfoUpdateListener(CustomerInfoUpdateListener listener) {
    if (!_initialized) return;
    Purchases.removeCustomerInfoUpdateListener(listener);
  }

  Future<CustomerInfo> purchasePackage(Package package) async {
    if (!_initialized) {
      throw StateError('RevenueCat is not configured.');
    }
    final result = await Purchases.purchase(PurchaseParams.package(package));
    return result.customerInfo;
  }

  Future<CustomerInfo> restorePurchases() async {
    if (!_initialized) {
      throw StateError('RevenueCat is not configured.');
    }
    return Purchases.restorePurchases();
  }
}
