// FILE: lib/main.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/providers.dart';
import 'routing/app_router.dart';

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

  // SharedPreferences -> Riverpod override.
  final prefs = await SharedPreferences.getInstance();

  final container = ProviderContainer(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(prefs),
    ],
  );

  // IMPORTANT: Init RevenueCat before UI starts using subscription state.
  // TODO: wstaw swój klucz (najlepiej z env/flavors, nie hardcode w repo).
  await container.read(revenueCatServiceProvider).init(
    apiKey: 'REVENUECAT_ANDROID_API_KEY',
    debug: kDebugMode,
  );

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const ReleafApp(),
    ),
  );
}

class ReleafApp extends StatelessWidget {
  const ReleafApp({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = ThemeData(
      useMaterial3: true,
      fontFamily: 'Poppins',
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF1E4D2B),
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: Colors.transparent,
      appBarTheme: const AppBarTheme(
        elevation: 0,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        foregroundColor: Color(0xFF1E4D2B),
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w700,
          fontSize: 20,
          color: Color(0xFF1E4D2B),
        ),
      ),
      cardTheme: const CardThemeData(
        elevation: 0,
        margin: EdgeInsets.zero,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(18)),
        ),
      ),
    );

    return MaterialApp.router(
      title: 'Releaf',
      debugShowCheckedModeBanner: false,
      theme: theme,
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
              color: const Color(0xFFF8F4E3).withOpacity(0.55),
            ),
          ),
        ),
        Positioned.fill(child: child),
      ],
    );
  }
}