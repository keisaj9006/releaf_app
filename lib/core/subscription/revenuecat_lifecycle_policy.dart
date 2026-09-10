import 'package:flutter/widgets.dart';

bool shouldRefreshRevenueCatOnLifecycle({
  required AppLifecycleState state,
  required bool isRevenueCatInitialized,
}) {
  return isRevenueCatInitialized && state == AppLifecycleState.resumed;
}
