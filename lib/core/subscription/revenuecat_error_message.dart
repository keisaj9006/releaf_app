import 'package:purchases_flutter/purchases_flutter.dart';

enum RevenueCatBillingAction { purchase, restore }

/// Converts RevenueCat/Google Play error codes into stable, user-facing copy.
///
/// Keep raw PlatformException messages out of the UI: they may contain
/// implementation detail and they are not written for end users. Returning
/// null means the action ended normally and should not surface an error (for
/// example, when the customer closes the purchase sheet).
String? revenueCatBillingMessage(
  PurchasesErrorCode code, {
  required RevenueCatBillingAction action,
}) {
  switch (code.name) {
    case 'purchaseCancelledError':
      return null;
    case 'paymentPendingError':
      return 'Your payment is pending in Google Play. Premium will unlock automatically after the payment is confirmed.';
    case 'networkError':
    case 'offlineConnectionError':
    case 'productRequestTimedOutError':
      return 'Google Play cannot be reached right now. Check your connection and try again.';
    case 'purchaseNotAllowedError':
      return 'Google Play is not allowing purchases on this device or account.';
    case 'productNotAvailableForPurchaseError':
      return 'This Premium plan is not available from Google Play right now. Refresh the plans and try again.';
    case 'productAlreadyPurchasedError':
      return 'This Google Play account may already own Premium. Try Restore purchases.';
    case 'operationAlreadyInProgressError':
      return 'Another store action is already in progress. Finish it, then try again.';
    case 'receiptAlreadyInUseError':
    case 'receiptInUseByOtherSubscriberError':
      return 'This purchase is linked to another Releaf account. Sign in to the account that owns it, then restore the purchase.';
    case 'configurationError':
    case 'invalidCredentialsError':
      return 'Premium store setup is unavailable in this build.';
    case 'storeProblemError':
    case 'unexpectedBackendResponseError':
    case 'unknownBackendError':
    case 'customerInfoError':
    case 'systemInfoError':
      return 'Google Play is having trouble confirming Premium right now. Try again shortly.';
    default:
      return action == RevenueCatBillingAction.restore
          ? 'Unable to restore purchases right now. Please try again.'
          : 'Unable to complete the purchase right now. Please try again.';
  }
}
