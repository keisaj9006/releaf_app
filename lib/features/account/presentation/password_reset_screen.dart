import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/providers.dart';
import '../../../routing/app_routes.dart';
import '../../../theme/app_theme.dart';
import '../../../theme/releaf_design_tokens.dart';
import '../application/account_recovery_service.dart';

class PasswordResetScreen extends ConsumerStatefulWidget {
  const PasswordResetScreen({super.key});

  @override
  ConsumerState<PasswordResetScreen> createState() =>
      _PasswordResetScreenState();
}

class _PasswordResetScreenState extends ConsumerState<PasswordResetScreen> {
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _working = false;
  bool _obscurePassword = true;
  bool _done = false;
  String? _error;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _savePassword() async {
    if (_working || _done) return;

    final password = _passwordController.text;
    final confirmation = _confirmController.text;

    if (password.length < 8) {
      setState(() => _error = 'Use at least 8 characters.');
      return;
    }
    if (password != confirmation) {
      setState(() => _error = 'The passwords do not match.');
      return;
    }

    setState(() {
      _working = true;
      _error = null;
    });

    try {
      await ref.read(accountRecoveryServiceProvider).updatePassword(password);

      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        await ref.read(revenueCatServiceProvider).identifyUser(user.id);
        await ref.read(subscriptionControllerProvider.notifier).refresh();
      }

      if (!mounted) return;
      setState(() => _done = true);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error is AuthException
            ? error.message
            : 'Unable to update your password. Request a new reset link and try again.';
      });
    } finally {
      if (mounted) setState(() => _working = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme.premiumDark(),
      child: Scaffold(
        backgroundColor: ReleafColors.background,
        appBar: AppBar(
          backgroundColor: ReleafColors.background,
          surfaceTintColor: Colors.transparent,
          title: const Text('Reset password'),
          leading: IconButton(
            tooltip: 'Back',
            onPressed: () => context.go(AppRoutes.account),
            icon: const Icon(Icons.arrow_back_rounded),
          ),
        ),
        body: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              ReleafSpacing.screen,
              ReleafSpacing.lg,
              ReleafSpacing.screen,
              ReleafSpacing.xxl,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: _done
                    ? _PasswordUpdatedCard(
                        onContinue: () => context.go(AppRoutes.account),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Container(
                            width: 58,
                            height: 58,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: ReleafColors.sage.withValues(alpha: 0.10),
                              border: Border.all(
                                color:
                                    ReleafColors.sage.withValues(alpha: 0.22),
                              ),
                            ),
                            child: const Icon(
                              Icons.lock_reset_rounded,
                              color: ReleafColors.sage,
                              size: 28,
                            ),
                          ),
                          const SizedBox(height: ReleafSpacing.lg),
                          Text(
                            'Choose a new password',
                            style: ReleafTypography.display.copyWith(
                              fontSize: 30,
                            ),
                          ),
                          const SizedBox(height: ReleafSpacing.xs),
                          Text(
                            'This link opened a secure recovery session. Set a new password for your Releaf account.',
                            style: ReleafTypography.body.copyWith(
                              color: ReleafColors.textSecondary,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: ReleafSpacing.xl),
                          TextField(
                            key: const Key('password-reset-new'),
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            enabled: !_working,
                            textInputAction: TextInputAction.next,
                            autofillHints: const [AutofillHints.newPassword],
                            decoration: InputDecoration(
                              labelText: 'New password',
                              helperText: 'At least 8 characters',
                              prefixIcon: const Icon(Icons.lock_outline_rounded),
                              suffixIcon: IconButton(
                                tooltip: _obscurePassword
                                    ? 'Show password'
                                    : 'Hide password',
                                onPressed: _working
                                    ? null
                                    : () => setState(
                                          () => _obscurePassword =
                                              !_obscurePassword,
                                        ),
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: ReleafSpacing.md),
                          TextField(
                            key: const Key('password-reset-confirm'),
                            controller: _confirmController,
                            obscureText: _obscurePassword,
                            enabled: !_working,
                            textInputAction: TextInputAction.done,
                            onSubmitted: (_) => _savePassword(),
                            autofillHints: const [AutofillHints.newPassword],
                            decoration: const InputDecoration(
                              labelText: 'Confirm new password',
                              prefixIcon: Icon(Icons.lock_outline_rounded),
                            ),
                          ),
                          if (_error != null) ...[
                            const SizedBox(height: ReleafSpacing.md),
                            Container(
                              key: const Key('password-reset-error'),
                              padding: const EdgeInsets.all(ReleafSpacing.md),
                              decoration: BoxDecoration(
                                color: const Color(0xFF5B2929)
                                    .withValues(alpha: 0.24),
                                borderRadius:
                                    BorderRadius.circular(ReleafRadii.medium),
                                border: Border.all(
                                  color: const Color(0xFFE39A9A)
                                      .withValues(alpha: 0.24),
                                ),
                              ),
                              child: Text(
                                _error!,
                                style: ReleafTypography.meta.copyWith(
                                  color: const Color(0xFFF0B5B5),
                                ),
                              ),
                            ),
                          ],
                          const SizedBox(height: ReleafSpacing.xl),
                          SizedBox(
                            height: 54,
                            child: FilledButton.icon(
                              key: const Key('password-reset-submit'),
                              onPressed: _working ? null : _savePassword,
                              icon: _working
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Icon(Icons.check_rounded),
                              label: Text(
                                _working ? 'Updating…' : 'Update password',
                              ),
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

class _PasswordUpdatedCard extends StatelessWidget {
  const _PasswordUpdatedCard({required this.onContinue});

  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('password-reset-success'),
      padding: const EdgeInsets.all(ReleafSpacing.xl),
      decoration: BoxDecoration(
        color: ReleafColors.backgroundRaised,
        borderRadius: BorderRadius.circular(ReleafRadii.extraLarge),
        border: Border.all(
          color: ReleafColors.sage.withValues(alpha: 0.22),
        ),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.verified_rounded,
            color: ReleafColors.sage,
            size: 44,
          ),
          const SizedBox(height: ReleafSpacing.md),
          Text(
            'Password updated',
            style: ReleafTypography.sectionTitle,
          ),
          const SizedBox(height: ReleafSpacing.xs),
          Text(
            'Your Releaf account is ready to use with the new password.',
            textAlign: TextAlign.center,
            style: ReleafTypography.body.copyWith(
              color: ReleafColors.textSecondary,
            ),
          ),
          const SizedBox(height: ReleafSpacing.lg),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: onContinue,
              child: const Text('Continue to account'),
            ),
          ),
        ],
      ),
    );
  }
}
