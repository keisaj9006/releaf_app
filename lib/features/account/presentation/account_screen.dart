import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/paywall/presentation/paywall_sheet.dart';
import '../../../core/providers.dart';
import '../../../routing/app_routes.dart';
import '../../../theme/app_theme.dart';
import '../../../theme/releaf_design_tokens.dart';
import '../application/account_auth_service.dart';

enum _AuthMode { signIn, createAccount }

class AccountScreen extends ConsumerStatefulWidget {
  const AccountScreen({super.key});

  @override
  ConsumerState<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends ConsumerState<AccountScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();

  _AuthMode _mode = _AuthMode.signIn;
  bool _working = false;
  bool _obscurePassword = true;
  String? _statusMessage;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _submitAuth() async {
    FocusScope.of(context).unfocus();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final name = _nameController.text.trim();

    if (!email.contains('@')) {
      setState(() => _errorMessage = 'Enter a valid email address.');
      return;
    }
    if (password.length < 8) {
      setState(() {
        _errorMessage = 'Use at least 8 characters for your password.';
      });
      return;
    }
    if (_mode == _AuthMode.createAccount && name.length < 2) {
      setState(() => _errorMessage = 'Add the name you want Releaf to use.');
      return;
    }

    setState(() {
      _working = true;
      _errorMessage = null;
      _statusMessage = null;
    });

    try {
      final service = ref.read(accountAuthServiceProvider);
      final result = _mode == _AuthMode.signIn
          ? await service.signIn(email: email, password: password)
          : await service.signUp(
              email: email,
              password: password,
              displayName: name,
            );

      if (result.user != null) {
        await _syncPremiumIdentity(result.user!.id);
        if (mounted) setState(() => _statusMessage = 'Signed in securely.');
      } else if (result.needsEmailConfirmation) {
        if (!mounted) return;
        setState(() {
          _statusMessage =
              'Account created. Check your email to confirm it, then sign in.';
          _mode = _AuthMode.signIn;
          _passwordController.clear();
        });
      }
    } catch (error) {
      if (mounted) setState(() => _errorMessage = _friendlyError(error));
    } finally {
      if (mounted) setState(() => _working = false);
    }
  }

  Future<void> _syncPremiumIdentity(String userId) async {
    await ref.read(revenueCatServiceProvider).identifyUser(userId);
    await ref.read(subscriptionControllerProvider.notifier).refresh();
  }

  Future<void> _signOut() async {
    setState(() {
      _working = true;
      _errorMessage = null;
      _statusMessage = null;
    });
    try {
      await ref.read(accountAuthServiceProvider).signOut();
      await ref.read(revenueCatServiceProvider).clearUserIdentity();
      await ref.read(subscriptionControllerProvider.notifier).refresh();
    } catch (error) {
      if (mounted) setState(() => _errorMessage = _friendlyError(error));
    } finally {
      if (mounted) setState(() => _working = false);
    }
  }

  Future<void> _deleteAccount() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: ReleafColors.surface,
        title: const Text('Delete account?'),
        content: const Text(
          'This permanently deletes your Releaf account and profile from the account service. Local Brain and Reset progress stored on this device is not erased by this action.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Keep account'),
          ),
          FilledButton(
            key: const Key('account-confirm-delete'),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete permanently'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() {
      _working = true;
      _errorMessage = null;
      _statusMessage = null;
    });

    try {
      await ref.read(accountAuthServiceProvider).deleteAccount();
      await ref.read(revenueCatServiceProvider).clearUserIdentity();
      await ref.read(subscriptionControllerProvider.notifier).refresh();
      if (!mounted) return;
      setState(() {
        _statusMessage =
            'Account deleted. Local on-device progress is still available.';
      });
    } catch (error) {
      if (mounted) setState(() => _errorMessage = _friendlyError(error));
    } finally {
      if (mounted) setState(() => _working = false);
    }
  }

  Future<void> _updateName(AccountUser user) async {
    final controller = TextEditingController(text: user.displayName);
    final next = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: ReleafColors.surface,
        title: const Text('Your name'),
        content: TextField(
          key: const Key('account-edit-name-field'),
          controller: controller,
          textCapitalization: TextCapitalization.words,
          autofocus: true,
          maxLength: 80,
          decoration: const InputDecoration(labelText: 'Display name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.of(dialogContext).pop(controller.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    controller.dispose();

    if (next == null || next.isEmpty || next == user.displayName) return;

    setState(() => _working = true);
    try {
      await ref.read(accountAuthServiceProvider).updateDisplayName(next);
      if (mounted) setState(() => _statusMessage = 'Profile updated.');
    } catch (error) {
      if (mounted) setState(() => _errorMessage = _friendlyError(error));
    } finally {
      if (mounted) setState(() => _working = false);
    }
  }

  Future<void> _restorePurchases() async {
    final ok = await ref.read(subscriptionControllerProvider.notifier).restore();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ok ? 'Premium restored.' : 'No active Premium purchase was found.',
        ),
      ),
    );
  }

  void _openPremium() {
    showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      backgroundColor: ReleafColors.background,
      barrierColor: Colors.black.withValues(alpha: 0.72),
      builder: (_) => const PaywallSheet(softOffer: true),
    );
  }

  String _friendlyError(Object error) {
    if (error is AuthException) return error.message;
    return 'Something went wrong. Please try again.';
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(accountUserProvider);
    final subscription = ref.watch(subscriptionControllerProvider);

    return Theme(
      data: AppTheme.premiumDark(),
      child: Scaffold(
        backgroundColor: ReleafColors.background,
        body: Stack(
          children: [
            const Positioned.fill(child: _AccountBackdrop()),
            SafeArea(
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 620),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(
                            ReleafSpacing.screen,
                            ReleafSpacing.sm,
                            ReleafSpacing.screen,
                            ReleafSpacing.xxl,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _AccountHeader(onBack: () => context.pop()),
                              const SizedBox(height: ReleafSpacing.xl),
                              _PremiumAccountCard(
                                isPremium: subscription.isPremium,
                                isLoading: subscription.isLoading,
                                onExplore: _openPremium,
                                onRestore: _restorePurchases,
                              ),
                              const SizedBox(height: ReleafSpacing.lg),
                              userAsync.when(
                                loading: () => const _AccountLoadingCard(),
                                error: (_, _) => _signedOutCard(),
                                data: (user) => user == null
                                    ? _signedOutCard()
                                    : _SignedInCard(
                                        user: user,
                                        working: _working,
                                        onEditName: () => _updateName(user),
                                        onSignOut: _signOut,
                                        onDeleteAccount: _deleteAccount,
                                      ),
                              ),
                              const SizedBox(height: ReleafSpacing.md),
                              OutlinedButton.icon(
                                key: const Key('account-privacy'),
                                onPressed: () => context.push(AppRoutes.privacy),
                                icon: const Icon(Icons.privacy_tip_outlined),
                                label: const Text('Privacy & data'),
                              ),
                              if (_statusMessage != null) ...[
                                const SizedBox(height: ReleafSpacing.md),
                                _AccountStatus(
                                  message: _statusMessage!,
                                  error: false,
                                ),
                              ],
                              if (_errorMessage != null) ...[
                                const SizedBox(height: ReleafSpacing.md),
                                _AccountStatus(
                                  message: _errorMessage!,
                                  error: true,
                                ),
                              ],
                              const SizedBox(height: ReleafSpacing.lg),
                              Text(
                                'Your account keeps identity and Premium access consistent across devices. Emergency support remains available without a paywall.',
                                textAlign: TextAlign.center,
                                style: ReleafTypography.meta.copyWith(
                                  color: ReleafColors.textMuted,
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _signedOutCard() {
    return _SignedOutCard(
      mode: _mode,
      working: _working,
      obscurePassword: _obscurePassword,
      emailController: _emailController,
      passwordController: _passwordController,
      nameController: _nameController,
      onModeChanged: (mode) {
        setState(() {
          _mode = mode;
          _errorMessage = null;
          _statusMessage = null;
        });
      },
      onTogglePassword: () {
        setState(() => _obscurePassword = !_obscurePassword);
      },
      onSubmit: _submitAuth,
    );
  }
}

class _AccountHeader extends StatelessWidget {
  const _AccountHeader({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          key: const Key('account-close'),
          tooltip: 'Back',
          onPressed: onBack,
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        const SizedBox(width: ReleafSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'YOUR RELEAF',
                style: ReleafTypography.eyebrow.copyWith(
                  color: ReleafColors.sage,
                ),
              ),
              Text(
                'Account',
                style: ReleafTypography.display.copyWith(fontSize: 30),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PremiumAccountCard extends StatelessWidget {
  const _PremiumAccountCard({
    required this.isPremium,
    required this.isLoading,
    required this.onExplore,
    required this.onRestore,
  });

  final bool isPremium;
  final bool isLoading;
  final VoidCallback onExplore;
  final VoidCallback onRestore;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('account-premium-card'),
      padding: const EdgeInsets.all(ReleafSpacing.lg),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF211D15), Color(0xFF121713)],
        ),
        borderRadius: BorderRadius.circular(ReleafRadii.extraLarge),
        border: Border.all(
          color: ReleafColors.premium.withValues(alpha: 0.28),
        ),
        boxShadow: const [
          BoxShadow(
            color: ReleafColors.glowPremium,
            blurRadius: 30,
            offset: Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isPremium
                    ? Icons.verified_rounded
                    : Icons.auto_awesome_rounded,
                color: ReleafColors.premium,
              ),
              const SizedBox(width: ReleafSpacing.sm),
              Expanded(
                child: Text(
                  isPremium ? 'PREMIUM ACTIVE' : 'RELEAF PREMIUM',
                  style: ReleafTypography.eyebrow.copyWith(
                    color: ReleafColors.premium,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: ReleafSpacing.sm),
          Text(
            isPremium
                ? 'Your deeper practices are unlocked.'
                : 'Preview what Premium unlocks.',
            style: ReleafTypography.sectionTitle.copyWith(fontSize: 22),
          ),
          const SizedBox(height: 5),
          Text(
            isPremium
                ? 'Your entitlement applies across supported Premium content.'
                : 'See deeper Reset protocols and meditation content before deciding.',
            style: ReleafTypography.body.copyWith(
              color: ReleafColors.textSecondary,
            ),
          ),
          const SizedBox(height: ReleafSpacing.md),
          Wrap(
            spacing: ReleafSpacing.sm,
            runSpacing: ReleafSpacing.sm,
            children: [
              FilledButton.icon(
                key: const Key('account-premium-explore'),
                onPressed: isLoading ? null : onExplore,
                icon: Icon(
                  isPremium
                      ? Icons.workspace_premium
                      : Icons.lock_open_rounded,
                ),
                label: Text(
                  isPremium ? 'Premium details' : 'Explore Premium',
                ),
              ),
              TextButton(
                key: const Key('account-premium-restore'),
                onPressed: isLoading ? null : onRestore,
                child: const Text('Restore purchase'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SignedOutCard extends StatelessWidget {
  const _SignedOutCard({
    required this.mode,
    required this.working,
    required this.obscurePassword,
    required this.emailController,
    required this.passwordController,
    required this.nameController,
    required this.onModeChanged,
    required this.onTogglePassword,
    required this.onSubmit,
  });

  final _AuthMode mode;
  final bool working;
  final bool obscurePassword;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController nameController;
  final ValueChanged<_AuthMode> onModeChanged;
  final VoidCallback onTogglePassword;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final creating = mode == _AuthMode.createAccount;

    return Container(
      key: const Key('account-auth-card'),
      padding: const EdgeInsets.all(ReleafSpacing.lg),
      decoration: BoxDecoration(
        color: ReleafColors.surface.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(ReleafRadii.extraLarge),
        border: Border.all(color: ReleafColors.borderSoft),
      ),
      child: AutofillGroup(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              creating ? 'Create your account' : 'Welcome back',
              style: ReleafTypography.sectionTitle.copyWith(fontSize: 24),
            ),
            const SizedBox(height: 5),
            Text(
              creating
                  ? 'Use one account across devices and keep Premium linked to you.'
                  : 'Sign in to restore your Releaf identity on this device.',
              style: ReleafTypography.body.copyWith(
                color: ReleafColors.textSecondary,
              ),
            ),
            const SizedBox(height: ReleafSpacing.lg),
            SegmentedButton<_AuthMode>(
              segments: const [
                ButtonSegment(
                  value: _AuthMode.signIn,
                  label: Text('Sign in'),
                  icon: Icon(Icons.login_rounded),
                ),
                ButtonSegment(
                  value: _AuthMode.createAccount,
                  label: Text('Register'),
                  icon: Icon(Icons.person_add_alt_1_rounded),
                ),
              ],
              selected: {mode},
              onSelectionChanged: working
                  ? null
                  : (selection) => onModeChanged(selection.first),
            ),
            const SizedBox(height: ReleafSpacing.lg),
            if (creating) ...[
              TextField(
                key: const Key('account-name-field'),
                controller: nameController,
                enabled: !working,
                textCapitalization: TextCapitalization.words,
                autofillHints: const [AutofillHints.name],
                decoration: const InputDecoration(
                  labelText: 'Name',
                  prefixIcon: Icon(Icons.badge_outlined),
                ),
              ),
              const SizedBox(height: ReleafSpacing.sm),
            ],
            TextField(
              key: const Key('account-email-field'),
              controller: emailController,
              enabled: !working,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.email],
              autocorrect: false,
              decoration: const InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.mail_outline_rounded),
              ),
            ),
            const SizedBox(height: ReleafSpacing.sm),
            TextField(
              key: const Key('account-password-field'),
              controller: passwordController,
              enabled: !working,
              obscureText: obscurePassword,
              textInputAction: TextInputAction.done,
              autofillHints: creating
                  ? const [AutofillHints.newPassword]
                  : const [AutofillHints.password],
              onSubmitted: (_) {
                if (!working) onSubmit();
              },
              decoration: InputDecoration(
                labelText: 'Password',
                helperText: creating ? 'Minimum 8 characters' : null,
                prefixIcon: const Icon(Icons.lock_outline_rounded),
                suffixIcon: IconButton(
                  tooltip:
                      obscurePassword ? 'Show password' : 'Hide password',
                  onPressed: onTogglePassword,
                  icon: Icon(
                    obscurePassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                  ),
                ),
              ),
            ),
            const SizedBox(height: ReleafSpacing.lg),
            SizedBox(
              height: 56,
              child: FilledButton(
                key: const Key('account-auth-submit'),
                onPressed: working ? null : onSubmit,
                child: working
                    ? const SizedBox(
                        width: 21,
                        height: 21,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(creating ? 'Create account' : 'Sign in'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SignedInCard extends StatelessWidget {
  const _SignedInCard({
    required this.user,
    required this.working,
    required this.onEditName,
    required this.onSignOut,
    required this.onDeleteAccount,
  });

  final AccountUser user;
  final bool working;
  final VoidCallback onEditName;
  final VoidCallback onSignOut;
  final VoidCallback onDeleteAccount;

  @override
  Widget build(BuildContext context) {
    final trimmed = user.displayName.trim();
    final initial = trimmed.isEmpty ? 'R' : trimmed[0].toUpperCase();

    return Container(
      key: const Key('account-signed-in-card'),
      padding: const EdgeInsets.all(ReleafSpacing.lg),
      decoration: BoxDecoration(
        color: ReleafColors.surface.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(ReleafRadii.extraLarge),
        border: Border.all(color: ReleafColors.borderSoft),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 54,
                height: 54,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: ReleafColors.sage.withValues(alpha: 0.12),
                  border: Border.all(
                    color: ReleafColors.sage.withValues(alpha: 0.28),
                  ),
                ),
                child: Text(
                  initial,
                  style: ReleafTypography.sectionTitle.copyWith(
                    color: ReleafColors.sage,
                  ),
                ),
              ),
              const SizedBox(width: ReleafSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(user.displayName, style: ReleafTypography.cardTitle),
                    if (user.email != null) ...[
                      const SizedBox(height: 3),
                      Text(
                        user.email!,
                        overflow: TextOverflow.ellipsis,
                        style: ReleafTypography.meta.copyWith(
                          color: ReleafColors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: ReleafSpacing.lg),
          OutlinedButton.icon(
            key: const Key('account-edit-profile'),
            onPressed: working ? null : onEditName,
            icon: const Icon(Icons.edit_outlined),
            label: const Text('Edit display name'),
          ),
          const SizedBox(height: ReleafSpacing.sm),
          TextButton.icon(
            key: const Key('account-sign-out'),
            onPressed: working ? null : onSignOut,
            icon: const Icon(Icons.logout_rounded),
            label: const Text('Sign out'),
          ),
          const SizedBox(height: ReleafSpacing.xs),
          TextButton.icon(
            key: const Key('account-delete'),
            onPressed: working ? null : onDeleteAccount,
            style: TextButton.styleFrom(
              foregroundColor: Colors.redAccent,
            ),
            icon: const Icon(Icons.delete_outline_rounded),
            label: const Text('Delete account'),
          ),
        ],
      ),
    );
  }
}

class _AccountStatus extends StatelessWidget {
  const _AccountStatus({
    required this.message,
    required this.error,
  });

  final String message;
  final bool error;

  @override
  Widget build(BuildContext context) {
    final accent = error ? Colors.redAccent : ReleafColors.sage;
    return Container(
      key: Key(error ? 'account-error' : 'account-status'),
      padding: const EdgeInsets.all(ReleafSpacing.md),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(ReleafRadii.medium),
        border: Border.all(color: accent.withValues(alpha: 0.24)),
      ),
      child: Row(
        children: [
          Icon(
            error ? Icons.error_outline_rounded : Icons.check_circle_outline,
            color: accent,
            size: 19,
          ),
          const SizedBox(width: ReleafSpacing.sm),
          Expanded(
            child: Text(
              message,
              style: ReleafTypography.meta.copyWith(
                color: ReleafColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AccountLoadingCard extends StatelessWidget {
  const _AccountLoadingCard();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 180,
      child: Center(
        child: CircularProgressIndicator(color: ReleafColors.sage),
      ),
    );
  }
}

class _AccountBackdrop extends StatelessWidget {
  const _AccountBackdrop();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0B1713),
            ReleafColors.background,
            Color(0xFF080B09),
          ],
        ),
      ),
    );
  }
}
