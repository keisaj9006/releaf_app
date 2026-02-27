// FILE: lib/features/paywall/presentation/paywall_sheet.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../../../core/providers.dart';

class PaywallSheet extends ConsumerWidget {
  final bool softOffer;
  const PaywallSheet({super.key, this.softOffer = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sub = ref.watch(subscriptionControllerProvider);
    final controller = ref.read(subscriptionControllerProvider.notifier);
    final packages = controller.getOrderedPackages();

    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: 16 + MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 44,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.25),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Text(
                    softOffer ? 'Unlock Premium (recommended)' : 'Unlock Premium',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.of(context).maybePop(),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              softOffer
                  ? 'You just completed a session — keep the streak going with Premium.'
                  : 'Get unlimited access and support the app.',
              style: TextStyle(color: Colors.white.withOpacity(0.85)),
            ),
            const SizedBox(height: 16),

            if (sub.error != null) ...[
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  sub.error!,
                  style: const TextStyle(color: Colors.redAccent),
                ),
              ),
              const SizedBox(height: 12),
            ],

            if (sub.isLoading) ...[
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: CircularProgressIndicator(),
              ),
            ] else if (packages.isEmpty) ...[
              const Text(
                'No packages available right now.',
                style: TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => controller.refresh(),
                child: const Text('Refresh'),
              ),
            ] else ...[
              for (final pkg in packages) ...[
                _PackageButton(
                  package: pkg,
                  onPressed: () async {
                    final ok = await controller.purchase(pkg);
                    if (ok && context.mounted) {
                      Navigator.of(context).maybePop();
                    }
                  },
                ),
                const SizedBox(height: 10),
              ],
            ],

            const SizedBox(height: 8),
            TextButton(
              onPressed: () async {
                final ok = await controller.restore();
                if (ok && context.mounted) {
                  Navigator.of(context).maybePop();
                }
              },
              child: const Text(
                'Restore purchases',
                style: TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(height: 4),
          ],
        ),
      ),
    );
  }
}

class _PackageButton extends StatelessWidget {
  final Package package;
  final VoidCallback onPressed;

  const _PackageButton({
    required this.package,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final price = package.storeProduct.priceString;
    final title = package.storeProduct.title;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF1C1F24),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              price,
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
          ],
        ),
      ),
    );
  }
}