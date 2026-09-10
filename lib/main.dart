// FILE: lib/main.dart
import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/providers.dart';
import 'core/subscription/revenuecat_auth_identity_coordinator.dart';
import 'core/subscription/revenuecat_lifecycle_policy.dart';
import 'features/sound/application/releaf_background_sound_driver.dart';
import 'features/sound/application/sound_player_controller.dart';
import 'routing/app_router.dart';
import 'routing/app_routes.dart';
import 'theme/app_theme.dart';

const _releafSupabaseUrl = String.fromEnvironment(
  'RELEAF_SUPABASE_URL',
  defaultValue: 'https://mgajdbdzflspypxhgmaw.supabase.co',
);

const _releafSupabasePublishableKey = String.fromEnvironment(
  'RELEAF_SUPABASE_PUBLISHABLE_KEY',
  defaultValue: 'sb_publishable_PQqPVW1Q-0xszH4dWIG4bA_nltwXQYJ',
);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SoundPlaybackDriver? backgroundSoundDriver;
  try {
    backgroundSoundDriver =
        await AudioService.init<ReleafBackgroundSoundDriver>(
      builder: ReleafBackgroundSoundDriver.new,
      config: const AudioServiceConfig(
        androidNotificationChannelId: 'app.releaf.mobile.audio',
        androidNotificationChannelName: 'Releaf audio',
        androidNotificationOngoing: true,
      ),
    );
  } catch (error, stackTrace) {
    debugPrint(
      'Background audio service unavailable; using foreground playback. '
      '$error\n$stackTrace',
    );
  }

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    statusBarBrightness: Brightness.dark,
    systemNavigationBarColor: Colors.transparent,
    systemNavigationBarIconBrightness: Brightness.light,
  ));

  await Supabase.initialize(
    url: _releafSupabaseUrl,
    publishableKey: _releafSupabasePublishableKey,
  );

  final prefs = await SharedPreferences.getInstance();

  final overrides = [
    sharedPreferencesProvider.overrideWithValue(prefs),
    if (backgroundSoundDriver != null)
      soundPlaybackDriverProvider.overrideWithValue(backgroundSoundDriver),
  ];

  final container = ProviderContainer(
    overrides: overrides,
  );

  final revenueCatApiKey = _revenueCatApiKeyForCurrentPlatform();
  final revenueCat = container.read(revenueCatServiceProvider);
  final restoredUser = Supabase.instance.client.auth.currentUser;
  await revenueCat.init(
    apiKey: revenueCatApiKey,
    debug: kDebugMode,
    appUserId: restoredUser?.id,
  );

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const ReleafApp(),
    ),
  );
}

String _revenueCatApiKeyForCurrentPlatform() {
  if (kIsWeb) return '';

  switch (defaultTargetPlatform) {
    case TargetPlatform.android:
      return const String.fromEnvironment('REVENUECAT_ANDROID_API_KEY');
    case TargetPlatform.iOS:
      return const String.fromEnvironment('REVENUECAT_IOS_API_KEY');
    default:
      return '';
  }
}

class ReleafApp extends ConsumerStatefulWidget {
  const ReleafApp({super.key});

  @override
  ConsumerState<ReleafApp> createState() => _ReleafAppState();
}

class _ReleafAppState extends ConsumerState<ReleafApp>
    with WidgetsBindingObserver {
  StreamSubscription<AuthState>? _authSubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    try {
      final auth = Supabase.instance.client.auth;
      final premiumIdentity =
          RevenueCatAuthIdentityCoordinator.forService(
        service: ref.read(revenueCatServiceProvider),
        beginIdentityChange: () =>
            ref.read(subscriptionControllerProvider.notifier).beginIdentityChange(),
        refreshSubscriptions: () =>
            ref.read(subscriptionControllerProvider.notifier).refresh(),
        initialUserId: auth.currentUser?.id,
      );

      _authSubscription = auth.onAuthStateChange.listen((state) {
        if (state.event == AuthChangeEvent.passwordRecovery) {
          appRouter.go(AppRoutes.passwordReset);
        }

        unawaited(
          premiumIdentity.syncUser(state.session?.user.id),
        );
      });
    } catch (_) {
      // Widget tests may intentionally build the app without Supabase.initialize.
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final revenueCat = ref.read(revenueCatServiceProvider);
    if (!shouldRefreshRevenueCatOnLifecycle(
      state: state,
      isRevenueCatInitialized: revenueCat.isInitialized,
    )) {
      return;
    }

    unawaited(
      ref.read(subscriptionControllerProvider.notifier).refresh(),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _authSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Releaf',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      routerConfig: appRouter,
      builder: (context, child) {
        return _AppBackground(child: child ?? const SizedBox.shrink());
      },
    );
  }
}

class _AppBackground extends StatelessWidget {
  const _AppBackground({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: Image.asset(
            'assets/ui/background.png',
            fit: BoxFit.cover,
          ),
        ),
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: const Color(0xFFF8F4E3).withValues(alpha: 0.55),
            ),
          ),
        ),
        Positioned.fill(child: child),
      ],
    );
  }
}
