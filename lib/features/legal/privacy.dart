import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/legal/releaf_legal_config.dart';
import '../../theme/app_theme.dart';
import '../../theme/releaf_design_tokens.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  Future<void> _openExternal(BuildContext context, Uri uri) async {
    final opened = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );
    if (!opened && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to open this link right now.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final legal = releafLegalConfig;

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
                    legal.privacyLastUpdated.trim().isEmpty
                        ? 'This development build does not yet contain the final public legal metadata.'
                        : 'Privacy information last updated ${legal.privacyLastUpdated.trim()}.',
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
                        'Brain history, Reset preferences, leaves and other lightweight progress are stored locally on this device. Creating an account does not automatically turn that local wellbeing history into a cloud backup.',
                  ),
                  const SizedBox(height: ReleafSpacing.md),
                  const _PrivacySection(
                    icon: Icons.person_outline_rounded,
                    title: 'Releaf account',
                    body:
                        'If you register, Supabase processes your email address, authentication identifier and the display name you choose so that Releaf can provide account access. Releaf does not store your password in plain text.',
                  ),
                  const SizedBox(height: ReleafSpacing.md),
                  const _PrivacySection(
                    icon: Icons.workspace_premium_outlined,
                    title: 'Premium access',
                    body:
                        'RevenueCat and the app-store provider are used to determine subscription and entitlement status. Payment-card details are handled by the store provider rather than by Releaf.',
                  ),
                  const SizedBox(height: ReleafSpacing.md),
                  const _PrivacySection(
                    icon: Icons.delete_outline_rounded,
                    title: 'Deleting your account',
                    body:
                        'A signed-in user can permanently delete their Releaf account from the Account screen. Remote account data associated through Releaf is deleted through the account service. Local progress on this device remains unless app data is cleared or the app is uninstalled.',
                  ),
                  const SizedBox(height: ReleafSpacing.md),
                  const _PrivacySection(
                    icon: Icons.health_and_safety_outlined,
                    title: 'Emergency remains separate',
                    body:
                        'Emergency support is not gated by Premium and does not require an account. Emergency use is excluded from standard Releaf progress sync and must not be used as a marketing trigger.',
                  ),
                  if (legal.isProductionReady) ...[
                    const SizedBox(height: ReleafSpacing.xl),
                    _LegalIdentityCard(config: legal),
                    const SizedBox(height: ReleafSpacing.md),
                    FilledButton.icon(
                      key: const Key('privacy-open-policy'),
                      onPressed: () => _openExternal(
                        context,
                        legal.privacyPolicyUri!,
                      ),
                      icon: const Icon(Icons.open_in_new_rounded),
                      label: const Text('Read full privacy policy'),
                    ),
                    const SizedBox(height: ReleafSpacing.sm),
                    OutlinedButton.icon(
                      key: const Key('privacy-open-deletion'),
                      onPressed: () => _openExternal(
                        context,
                        legal.accountDeletionUri!,
                      ),
                      icon: const Icon(Icons.delete_outline_rounded),
                      label: const Text('Account deletion on the web'),
                    ),
                  ] else ...[
                    const SizedBox(height: ReleafSpacing.xl),
                    Container(
                      key: const Key('privacy-development-legal-warning'),
                      padding: const EdgeInsets.all(ReleafSpacing.md),
                      decoration: BoxDecoration(
                        color: ReleafColors.surfaceSoft,
                        borderRadius: BorderRadius.circular(ReleafRadii.large),
                        border: Border.all(color: ReleafColors.borderSoft),
                      ),
                      child: Text(
                        'Release legal metadata is not configured in this development build. A Play release is blocked until the public privacy-policy URL, web account-deletion URL, data-controller identity, privacy contact and last-updated date are supplied.',
                        style: ReleafTypography.meta.copyWith(
                          color: ReleafColors.textMuted,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LegalIdentityCard extends StatelessWidget {
  const _LegalIdentityCard({required this.config});

  final ReleafLegalConfig config;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('privacy-legal-identity'),
      padding: const EdgeInsets.all(ReleafSpacing.lg),
      decoration: BoxDecoration(
        color: ReleafColors.surface.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(ReleafRadii.extraLarge),
        border: Border.all(color: ReleafColors.borderSoft),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Privacy contact', style: ReleafTypography.cardTitle),
          const SizedBox(height: 8),
          Text(
            'Data controller: ${config.dataControllerName.trim()}',
            style: ReleafTypography.body.copyWith(
              color: ReleafColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          SelectableText(
            config.privacyContactEmail.trim(),
            style: ReleafTypography.body.copyWith(
              color: ReleafColors.textSecondary,
            ),
          ),
        ],
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
