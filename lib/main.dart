// FILE: lib/main.dart
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/providers.dart';
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

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    statusBarBrightness: Brightness.light,
    systemNavigationBarColor: Colors.transparent,
    systemNavigationBarIconBrightness: Brightness.dark,
  ));

  await Supabase.initialize(
    url: _releafSupabaseUrl,
    publishableKey: _releafSupabasePublishableKey,
  );

  final prefs = await SharedPreferences.getInstance();

  final container = ProviderContainer(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(prefs),
    ],
  );

  final revenueCatApiKey = _revenueCatApiKeyForCurrentPlatform();
  final revenueCat = container.read(revenueCatServiceProvider);
  await revenueCat.init(
    apiKey: revenueCatApiKey,
    debug: kDebugMode,
  );

  final restoredUser = Supabase.instance.client.auth.currentUser;
  if (restoredUser != null) {
    await revenueCat.identifyUser(restoredUser.id);
  }

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

class ReleafApp extends StatefulWidget {
  const ReleafApp({super.key});

  @override
  State<ReleafApp> createState() => _ReleafAppState();
}

class _ReleafAppState extends State<ReleafApp> {
  StreamSubscription<AuthState>? _authSubscription;

  @override
  void initState() {
    super.initState();

    try {
      _authSubscription =
          Supabase.instance.client.auth.onAuthStateChange.listen((state) {
        if (state.event == AuthChangeEvent.passwordRecovery) {
          appRouter.go(AppRoutes.passwordReset);
        }
      });
    } catch (_) {
      // Widget tests may intentionally build the app without Supabase.initialize.
    }
  }

  @override
  void dispose() {
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
