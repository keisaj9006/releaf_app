import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../../../core/providers.dart';
import '../../../theme/app_theme.dart';
import '../../../theme/releaf_design_tokens.dart';

class PaywallSheet extends ConsumerWidget {
  final bool softOffer;

  const PaywallSheet({super.key, this.softOffer = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sub = ref.watch(subscriptionControllerProvider);
    final controller = ref.read(subscriptionControllerProvider.notifier);
    final packages = controller.getOrderedPackages();

    return Theme(
      data: AppTheme.premiumDark(),
      child: SafeArea(
        top: false,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(context).height * 0.88,
          ),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.fromLTRB(
              ReleafSpacing.screen,
              ReleafSpacing.md,
              ReleafSpacing.screen,
              ReleafSpacing.lg + MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Center(
                      child: Container(
                        width: 42,
                        height: 4,
                        decoration: BoxDecoration(
                          color: ReleafColors.textPrimary.withValues(alpha: 0.22),
                          borderRadius: BorderRadius.circular(ReleafRadii.pill),
                        ),
                      ),
                    ),
                    const SizedBox(height: ReleafSpacing.lg),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'RELEAF PREMIUM',
                                style: ReleafTypography.eyebrow.copyWith(
                                  color: ReleafColors.premium,
                                  letterSpacing: 1.9,
                                ),
                              ),
                              const SizedBox(height: 7),
                              Text(
                                'Unlock Premium',
                                style: ReleafTypography.display.copyWith(
                                  fontSize: 30,
                                ),
                              ),
                              const SizedBox(height: ReleafSpacing.xs),
                              Text(
                                softOffer
                                    ? 'Keep going with the deeper practices available across Releaf.'
                                    : 'Open the premium practices already built into Releaf.',
                                style: ReleafTypography.body.copyWith(
                                  color: ReleafColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: ReleafSpacing.md),
                        IconButton(
                          tooltip: 'Close Premium',
                          onPressed: () => Navigator.of(context).maybePop(),
                          icon: const Icon(Icons.close_rounded),
                        ),
                      ],
                    ),
                    const SizedBox(height: ReleafSpacing.xl),
                    Container(
                      padding: const EdgeInsets.all(ReleafSpacing.lg),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFF211D15),
                            Color(0xFF161711),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(
                          ReleafRadii.extraLarge,
                        ),
                        border: Border.all(
                          color: ReleafColors.premium.withValues(alpha: 0.24),
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: ReleafColors.glowPremium,
                            blurRadius: 34,
                            offset: Offset(0, 14),
                          ),
                        ],
                      ),
                      child: const Column(
                        children: [
                          _PremiumBenefit(
                            icon: Icons.layers_outlined,
                            title: 'Deeper Reset protocols',
                            description:
                                'Access premium regulation sessions beyond the free quick tools.',
                          ),
                          SizedBox(height: ReleafSpacing.md),
                          _PremiumBenefit(
                            icon: Icons.spa_outlined,
                            title: 'Premium meditation sessions',
                            description:
                                'Continue beyond the free foundations into the wider meditation library.',
                          ),
                          SizedBox(height: ReleafSpacing.md),
                          _PremiumBenefit(
                            icon: Icons.graphic_eq_rounded,
                            title: 'Expanded Sound & Sleep library',
                            description:
                                'Unlock additional ambient and coloured-noise tracks while keeping Sleep narration-free.',
                          ),
                          SizedBox(height: ReleafSpacing.md),
                          _PremiumBenefit(
                            icon: Icons.auto_awesome_outlined,
                            title: 'One premium entitlement',
                            description:
                                'Your active entitlement unlocks supported premium content across Releaf.',
                          ),
                        ],
                      ),
                    ),
                    if (sub.error != null) ...[
                      const SizedBox(height: ReleafSpacing.md),
                      _StatusMessage(
                        icon: Icons.info_outline_rounded,
                        message: sub.error!,
                      ),
                    ],
                    const SizedBox(height: ReleafSpacing.xl),
                    if (sub.isPremium)
                      const _PremiumActiveCard()
                    else if (sub.isLoading)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: ReleafSpacing.lg,
                          ),
                          child: CircularProgressIndicator(
                            color: ReleafColors.premium,
                          ),
                        ),
                      )
                    else if (packages.isEmpty)
                      _UnavailablePackages(onRefresh: controller.refresh)
                    else
                      for (var index = 0;
                          index < packages.length;
                          index++) ...[
                        _PackageButton(
                          package: packages[index],
                          recommended: index == 0 && packages.length > 1,
                          onPressed: () async {
                            final ok = await controller.purchase(packages[index]);
                            if (ok && context.mounted) {
                              Navigator.of(context).maybePop();
                            }
                          },
                        ),
                        if (index != packages.length - 1)
                          const SizedBox(height: ReleafSpacing.sm),
                      ],
                    const SizedBox(height: ReleafSpacing.md),
                    if (!sub.isPremium)
                      TextButton(
                        onPressed: sub.isLoading
                            ? null
                            : () async {
                                final ok = await controller.restore();
                                if (ok && context.mounted) {
                                  Navigator.of(context).maybePop();
                                }
                              },
                        child: const Text('Restore purchases'),
                      ),
                    const SizedBox(height: ReleafSpacing.xs),
                    Text(
                      'Purchases and restoration are handled through the app store linked to this device.',
                      textAlign: TextAlign.center,
                      style: ReleafTypography.meta.copyWith(
                        color: ReleafColors.textMuted,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PremiumBenefit extends StatelessWidget {
  const _PremiumBenefit({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: ReleafColors.premium.withValues(alpha: 0.10),
            border: Border.all(
              color: ReleafColors.premium.withValues(alpha: 0.22),
            ),
          ),
          alignment: Alignment.center,
          child: Icon(
            icon,
            size: 20,
            color: ReleafColors.premium,
          ),
        ),
        const SizedBox(width: ReleafSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: ReleafTypography.cardTitle),
              const SizedBox(height: 3),
              Text(
                description,
                style: ReleafTypography.meta.copyWith(
                  color: ReleafColors.textSecondary,
                  height: 1.45,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PremiumActiveCard extends StatelessWidget {
  const _PremiumActiveCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('premium-active-card'),
      padding: const EdgeInsets.all(ReleafSpacing.lg),
      decoration: BoxDecoration(
        color: ReleafColors.premium.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(ReleafRadii.large),
        border: Border.all(
          color: ReleafColors.premium.withValues(alpha: 0.24),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.verified_rounded,
            color: ReleafColors.premium,
          ),
          const SizedBox(width: ReleafSpacing.sm),
          Expanded(
            child: Text(
              'Premium is active on this device.',
              style: ReleafTypography.cardTitle.copyWith(fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }
}

class _UnavailablePackages extends StatelessWidget {
  const _UnavailablePackages({required this.onRefresh});

  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('premium-packages-unavailable'),
      padding: const EdgeInsets.all(ReleafSpacing.lg),
      decoration: BoxDecoration(
        color: ReleafColors.surfaceSoft,
        borderRadius: BorderRadius.circular(ReleafRadii.large),
        border: Border.all(color: ReleafColors.borderSoft),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.storefront_outlined,
            color: ReleafColors.textSecondary,
          ),
          const SizedBox(height: ReleafSpacing.sm),
          Text(
            'Premium packages are not available in this build yet.',
            textAlign: TextAlign.center,
            style: ReleafTypography.cardTitle.copyWith(fontSize: 15),
          ),
          const SizedBox(height: 5),
          Text(
            'If store configuration has just changed, refresh the offering.',
            textAlign: TextAlign.center,
            style: ReleafTypography.meta.copyWith(
              color: ReleafColors.textSecondary,
            ),
          ),
          const SizedBox(height: ReleafSpacing.md),
          OutlinedButton.icon(
            onPressed: onRefresh,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Refresh'),
          ),
        ],
      ),
    );
  }
}

class _StatusMessage extends StatelessWidget {
  const _StatusMessage({
    required this.icon,
    required this.message,
  });

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(ReleafSpacing.md),
      decoration: BoxDecoration(
        color: ReleafColors.surfaceSoft,
        borderRadius: BorderRadius.circular(ReleafRadii.medium),
        border: Border.all(color: ReleafColors.borderSoft),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: ReleafColors.textSecondary),
          const SizedBox(width: ReleafSpacing.sm),
          Expanded(
            child: Text(
              message,
              style: ReleafTypography.meta.copyWith(
                color: ReleafColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PackageButton extends StatelessWidget {
  const _PackageButton({
    required this.package,
    required this.onPressed,
    required this.recommended,
  });

  final Package package;
  final VoidCallback onPressed;
  final bool recommended;

  @override
  Widget build(BuildContext context) {
    final price = package.storeProduct.priceString;
    final title = package.storeProduct.title;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(ReleafRadii.large),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        key: ValueKey('premium-package-${package.identifier}'),
        onTap: onPressed,
        child: Ink(
          padding: const EdgeInsets.all(ReleafSpacing.lg),
          decoration: BoxDecoration(
            color: recommended
                ? ReleafColors.premium.withValues(alpha: 0.10)
                : ReleafColors.surface,
            borderRadius: BorderRadius.circular(ReleafRadii.large),
            border: Border.all(
              color: recommended
                  ? ReleafColors.premium.withValues(alpha: 0.38)
                  : ReleafColors.borderSoft,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (recommended) ...[
                      Text(
                        'RECOMMENDED',
                        style: ReleafTypography.eyebrow.copyWith(
                          color: ReleafColors.premium,
                          fontSize: 9,
                        ),
                      ),
                      const SizedBox(height: 4),
                    ],
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: ReleafTypography.cardTitle,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: ReleafSpacing.md),
              Text(
                price,
                style: ReleafTypography.cardTitle.copyWith(
                  color: ReleafColors.premium,
                ),
              ),
              const SizedBox(width: ReleafSpacing.xs),
              const Icon(
                Icons.arrow_forward_rounded,
                size: 19,
                color: ReleafColors.premium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
