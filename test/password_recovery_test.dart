import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:releaf_app/features/account/application/account_recovery_service.dart';
import 'package:releaf_app/features/account/presentation/password_reset_screen.dart';

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
