// FILE: lib/features/bootstrap/bootstrap_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/storage/prefs_keys.dart';
import '../../core/di/providers.dart';
import '../../routing/routes.dart';
import 'package:go_router/go_router.dart';

class BootstrapScreen extends ConsumerStatefulWidget {
  const BootstrapScreen({super.key});

  @override
  ConsumerState<BootstrapScreen> createState() => _BootstrapScreenState();
}

class _BootstrapScreenState extends ConsumerState<BootstrapScreen> {
  @override
  void initState() {
    super.initState();
    // Minimal splash / routing decision.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final prefs = ref.read(sharedPreferencesProvider);
      final accepted = prefs.getBool(PrefKeys.disclaimerAccepted) ?? false;
      if (!accepted) {
        context.go(AppRoutes.disclaimer);
      } else {
        context.go(AppRoutes.home);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}