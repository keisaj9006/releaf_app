import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:releaf_app/features/account/application/account_recovery_service.dart';
import 'package:releaf_app/features/account/presentation/password_reset_screen.dart';
import 'package:releaf_app/routing/app_routes.dart';

class _FakeRecoveryService implements AccountRecoveryService {
  String? requestedEmail;
  String? updatedPassword;

  @override
  Future<void> requestPasswordReset(String email) async {
    requestedEmail = email;
  }

  @override
  Future<void> updatePassword(String password) async {
    updatedPassword = password;
  }
}

void main() {
  test('Releaf recovery uses the registered native callback', () {
    expect(
      releafAuthCallbackUrl,
      'app.releaf.mobile://auth-callback',
    );
  });

  test('Android recovery deep link and reset route stay wired together', () {
    final callback = Uri.parse(releafAuthCallbackUrl);
    final manifest = File(
      'android/app/src/main/AndroidManifest.xml',
    ).readAsStringSync();
    final mainSource = File('lib/main.dart').readAsStringSync();
    final routerSource = File(
      'lib/routing/app_router.dart',
    ).readAsStringSync();

    expect(callback.scheme, 'app.releaf.mobile');
    expect(callback.host, 'auth-callback');
    expect(
      manifest,
      contains('android:scheme="${callback.scheme}"'),
    );
    expect(
      manifest,
      contains('android:host="${callback.host}"'),
    );

    expect(AppRoutes.passwordReset, '/account/reset-password');
    expect(mainSource, contains('AuthChangeEvent.passwordRecovery'));
    expect(
      mainSource,
      contains('appRouter.go(AppRoutes.passwordReset)'),
    );
    expect(
      routerSource,
      contains('path: AppRoutes.passwordReset'),
    );
    expect(routerSource, contains('PasswordResetScreen'));
  });

  testWidgets('Password reset validates and updates password', (
    WidgetTester tester,
  ) async {
    final recovery = _FakeRecoveryService();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          accountRecoveryServiceProvider.overrideWithValue(recovery),
        ],
        child: const MaterialApp(home: PasswordResetScreen()),
      ),
    );
    await tester.pump();

    await tester.enterText(
      find.byKey(const Key('password-reset-new')),
      'new-password-123',
    );
    await tester.enterText(
      find.byKey(const Key('password-reset-confirm')),
      'different-password',
    );
    await tester.tap(find.byKey(const Key('password-reset-submit')));
    await tester.pump();

    expect(find.text('The passwords do not match.'), findsOneWidget);
    expect(recovery.updatedPassword, isNull);

    await tester.enterText(
      find.byKey(const Key('password-reset-confirm')),
      'new-password-123',
    );
    await tester.tap(find.byKey(const Key('password-reset-submit')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(recovery.updatedPassword, 'new-password-123');
    expect(find.byKey(const Key('password-reset-success')), findsOneWidget);
    expect(find.text('Password updated'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
