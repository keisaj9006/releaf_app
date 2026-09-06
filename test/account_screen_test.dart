import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:releaf_app/features/account/application/account_auth_service.dart';
import 'package:releaf_app/features/account/presentation/account_screen.dart';

class _FakeAccountAuthService implements AccountAuthService {
  _FakeAccountAuthService({this.user});

  AccountUser? user;

  @override
  AccountUser? get currentUser => user;

  @override
  Stream<AccountUser?> watchUser() => Stream.value(user);

  @override
  Future<AccountAuthResult> signIn({
    required String email,
    required String password,
  }) async {
    user = AccountUser(
      id: 'test-user',
      email: email,
      displayName: 'Test member',
    );
    return AccountAuthResult(user: user, needsEmailConfirmation: false);
  }

  @override
  Future<AccountAuthResult> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    return const AccountAuthResult(
      user: null,
      needsEmailConfirmation: true,
    );
  }

  @override
  Future<void> updateDisplayName(String displayName) async {}

  @override
  Future<void> deleteAccount() async {
    user = null;
  }

  @override
  Future<void> signOut() async {
    user = null;
  }
}

Future<void> _pumpAccount(
  WidgetTester tester, {
  AccountUser? user,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        accountAuthServiceProvider.overrideWithValue(
          _FakeAccountAuthService(user: user),
        ),
      ],
      child: const MaterialApp(home: AccountScreen()),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 200));
}

void main() {
  testWidgets('Account exposes auth and Premium preview', (
    WidgetTester tester,
  ) async {
    await _pumpAccount(tester);

    expect(find.byKey(const Key('account-premium-card')), findsOneWidget);
    expect(find.byKey(const Key('account-premium-explore')), findsOneWidget);
    expect(find.text('Explore Premium'), findsOneWidget);
    expect(find.byKey(const Key('account-auth-card')), findsOneWidget);
    expect(find.byKey(const Key('account-email-field')), findsOneWidget);
    expect(find.byKey(const Key('account-password-field')), findsOneWidget);

    await tester.tap(find.text('Register'));
    await tester.pump();

    expect(find.byKey(const Key('account-name-field')), findsOneWidget);
    expect(find.text('Create account'), findsWidgets);
  });

  testWidgets('Signed in account shows identity and profile actions', (
    WidgetTester tester,
  ) async {
    await _pumpAccount(
      tester,
      user: const AccountUser(
        id: 'member-1',
        email: 'member@example.com',
        displayName: 'Jo',
      ),
    );

    expect(find.byKey(const Key('account-signed-in-card')), findsOneWidget);
    expect(find.text('Jo'), findsOneWidget);
    expect(find.text('member@example.com'), findsOneWidget);
    expect(find.byKey(const Key('account-edit-profile')), findsOneWidget);
    expect(find.byKey(const Key('account-sign-out')), findsOneWidget);
    expect(find.byKey(const Key('account-delete')), findsOneWidget);
    expect(find.byKey(const Key('account-privacy')), findsOneWidget);
  });
}
