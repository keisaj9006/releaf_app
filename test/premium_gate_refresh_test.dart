import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:releaf_app/core/providers.dart';
import 'package:releaf_app/core/subscription/revenuecat_service.dart';
import 'package:releaf_app/core/subscription/subscription_controller.dart';
import 'package:releaf_app/core/subscription/subscription_state.dart';
import 'package:releaf_app/features/meditation/data/meditation_catalog.dart';
import 'package:releaf_app/features/meditation/presentation/meditation_session_gate.dart';
import 'package:releaf_app/features/meditation/presentation/meditation_player_screen.dart';
import 'package:releaf_app/features/relief/presentation/relief_session_gate.dart';
import 'package:releaf_app/features/relief/presentation/breathing_widget.dart';
import 'package:releaf_app/features/sound/presentation/sound_player_gate.dart';
import 'package:releaf_app/features/sound/presentation/sound_player_screen.dart';

class _Subscription extends SubscriptionController {
  _Subscription() : super(RevenueCatService()) {
    state = const SubscriptionState(isPremium: true);
  }
  @override
  Future<void> initAndRefresh() async {}
  void startRefresh() => state = state.copyWith(isLoading: true);
}

void main() {
  final meditation = const MeditationCatalog().getAll().firstWhere(
    (item) => item.isPremium,
  );
  for (final entry in <(String, Widget, Type)>[
    (
      'Meditation',
      MeditationSessionGate(meditationId: meditation.id),
      MeditationPlayerScreen,
    ),
    (
      'Reset',
      const ReliefSessionGate(sessionId: '3min-breath'),
      BreathingWidget,
    ),
    (
      'Sound',
      const SoundPlayerGate(trackId: 'releaf-atmosphere-02'),
      SoundPlayerScreen,
    ),
  ]) {
    testWidgets(
      '${entry.$1} retains entitled player during refresh but closes at identity boundary',
      (tester) async {
        SharedPreferences.setMockInitialValues({});
        final prefs = await SharedPreferences.getInstance();
        final subscription = _Subscription();
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              sharedPreferencesProvider.overrideWithValue(prefs),
              subscriptionControllerProvider.overrideWith(
                (ref) => subscription,
              ),
            ],
            child: MaterialApp(home: entry.$2),
          ),
        );
        await tester.pump();
        final player = find.byType(entry.$3);
        expect(player, findsOneWidget);
        final beforeRefresh = tester.state(player);
        subscription.startRefresh();
        await tester.pump();
        expect(player, findsOneWidget);
        expect(identical(tester.state(player), beforeRefresh), isTrue);
        subscription.beginIdentityChange();
        await tester.pump();
        expect(player, findsNothing);
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox.shrink());
      },
    );
  }
}
