// FILE: lib/features/legal/disclaimer_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/di/providers.dart';
import '../../core/storage/prefs_keys.dart';
import '../../routing/routes.dart';
import 'package:go_router/go_router.dart';

class DisclaimerScreen extends ConsumerWidget {
  const DisclaimerScreen({super.key});

  Future<void> _openPrivacy(WidgetRef ref) async {
    final url = ref.read(privacyConfigProvider).privacyPolicyUrl;
    final uri = Uri.parse(url);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Disclaimer')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'Releaf is a wellbeing app.\n\n'
              '• It does NOT provide medical advice.\n'
              '• It does NOT diagnose or treat conditions.\n'
              '• If you feel unwell or unsafe, contact a healthcare professional.\n\n'
              'All data stays on your device (offline-first in MVP).',
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: () => _openPrivacy(ref),
                child: const Text('Open Privacy Policy'),
              ),
            ),
            const Spacer(),
            FilledButton(
              onPressed: () {
                final prefs = ref.read(sharedPreferencesProvider);
                prefs.setBool(PrefKeys.disclaimerAccepted, true);
                context.go(AppRoutes.home);
              },
              child: const Text('I understand and continue'),
            ),
          ],
        ),
      ),
    );
  }
}