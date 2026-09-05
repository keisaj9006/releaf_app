import 'package:flutter_test/flutter_test.dart';

import 'package:releaf_app/core/subscription/revenuecat_service.dart';
import 'package:releaf_app/core/subscription/subscription_controller.dart';

void main() {
  test('owner Premium preview keeps entitlement active without RevenueCat', () async {
    final controller = SubscriptionController(
      RevenueCatService(),
      premiumPreview: true,
    );
    addTearDown(controller.dispose);

    expect(controller.state.isPremium, isTrue);

    await controller.refresh();

    expect(controller.state.isPremium, isTrue);
    expect(controller.state.isLoading, isFalse);
    expect(controller.state.error, isNull);
  });
}
