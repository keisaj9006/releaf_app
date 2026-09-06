import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../theme/releaf_design_tokens.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme.premiumDark(),
      child: Scaffold(
        backgroundColor: ReleafColors.background,
        appBar: AppBar(
          backgroundColor: ReleafColors.background,
          surfaceTintColor: Colors.transparent,
          title: const Text('Privacy & data'),
        ),
        body: SafeArea(
          top: false,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 680),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  ReleafSpacing.screen,
                  ReleafSpacing.lg,
                  ReleafSpacing.screen,
                  ReleafSpacing.xxl,
                ),
                children: [
                  Text(
                    'YOUR DATA',
                    style: ReleafTypography.eyebrow.copyWith(
                      color: ReleafColors.sage,
                    ),
                  ),
                  const SizedBox(height: ReleafSpacing.xs),
                  Text(
                    'Clear, minimal data use.',
                    style: ReleafTypography.display.copyWith(fontSize: 30),
                  ),
                  const SizedBox(height: ReleafSpacing.sm),
                  Text(
                    'Last updated 6 September 2026. This page describes the current Releaf development build and must be reviewed again before public release.',
                    style: ReleafTypography.body.copyWith(
                      color: ReleafColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: ReleafSpacing.xl),
                  const _PrivacySection(
                    icon: Icons.phone_android_rounded,
                    title: 'On-device progress',
                    body:
                        'Brain history, Reset preferences, leaves and other lightweight progress are stored locally on your device using app storage. Creating an account does not automatically upload that local wellbeing history.',
                  ),
                  const SizedBox(height: ReleafSpacing.md),
                  const _PrivacySection(
                    icon: Icons.person_outline_rounded,
                    title: 'Releaf account',
                    body:
                        'If you register, Supabase processes your email address, authentication identifier and the display name you choose so that you can sign in. Releaf does not store your password in plain text.',
                  ),
                  const SizedBox(height: ReleafSpacing.md),
                  const _PrivacySection(
                    icon: Icons.workspace_premium_outlined,
                    title: 'Premium access',
                    body:
                        'RevenueCat and your app-store provider are used to determine subscription and entitlement status. Payment-card details are handled by the store provider rather than by the Releaf app.',
                  ),
                  const SizedBox(height: ReleafSpacing.md),
                  const _PrivacySection(
                    icon: Icons.delete_outline_rounded,
                    title: 'Deleting your account',
                    body:
                        'A signed-in user can permanently delete their Releaf account from the Account screen. This deletes the remote account/profile. Local progress on the device is kept unless you remove the app data or uninstall the app.',
                  ),
                  const SizedBox(height: ReleafSpacing.md),
                  const _PrivacySection(
                    icon: Icons.health_and_safety_outlined,
                    title: 'Emergency remains separate',
                    body:
                        'Emergency support is not gated by Premium and does not require an account. Releaf should not use an emergency interaction as a marketing trigger.',
                  ),
                  const SizedBox(height: ReleafSpacing.xl),
                  Container(
                    padding: const EdgeInsets.all(ReleafSpacing.md),
                    decoration: BoxDecoration(
                      color: ReleafColors.surfaceSoft,
                      borderRadius: BorderRadius.circular(ReleafRadii.large),
                      border: Border.all(color: ReleafColors.borderSoft),
                    ),
                    child: Text(
                      'Before public release we still need the final legal privacy notice, data-controller contact details, retention periods and any store-specific disclosures. Those details are not invented here.',
                      style: ReleafTypography.meta.copyWith(
                        color: ReleafColors.textMuted,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PrivacySection extends StatelessWidget {
  const _PrivacySection({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(ReleafSpacing.lg),
      decoration: BoxDecoration(
        color: ReleafColors.surface.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(ReleafRadii.extraLarge),
        border: Border.all(color: ReleafColors.borderSoft),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: ReleafColors.sage, size: 22),
          const SizedBox(width: ReleafSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: ReleafTypography.cardTitle),
                const SizedBox(height: 6),
                Text(
                  body,
                  style: ReleafTypography.body.copyWith(
                    color: ReleafColors.textSecondary,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
