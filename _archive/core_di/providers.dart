// FILE: lib/core/di/providers.dart
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/brain/data/brain_repository.dart';
import '../../features/habits/data/habits_repository.dart';
import '../../features/habits/presentation/habits_controller.dart';
import '../../features/legal/privacy.dart';
import '../../routing/app_router.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('sharedPreferencesProvider must be overridden in main()');
});

final privacyConfigProvider = Provider<PrivacyConfig>((ref) {
  // TODO: podmień na swój prawdziwy URL privacy policy (wymóg Play Console/App Store).
  return const PrivacyConfig(
    privacyPolicyUrl: 'https://example.com/privacy',
  );
});

final audioPlayerProvider = Provider<AudioPlayer>((ref) {
  final player = AudioPlayer();
  ref.onDispose(player.dispose);
  return player;
});

final habitsRepositoryProvider = Provider<HabitsRepository>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return HabitsRepository(prefs);
});

final habitsControllerProvider =
    NotifierProvider<HabitsController, HabitsState>(() => HabitsController());

final brainRepositoryProvider = Provider<BrainRepository>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return BrainRepository(prefs);
});

final disclaimerAcceptedProvider = Provider<bool>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return prefs.getBool('disclaimerAccepted') ?? false;
});

final goRouterProvider = Provider((ref) {
  // Router nie zależy od Riverpod-state (poza tym providerem, który go tworzy).
  return buildRouter(ref);
});