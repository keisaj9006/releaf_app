import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AccountUser {
  const AccountUser({
    required this.id,
    required this.email,
    required this.displayName,
  });

  final String id;
  final String? email;
  final String displayName;
}

class AccountAuthResult {
  const AccountAuthResult({
    required this.user,
    required this.needsEmailConfirmation,
  });

  final AccountUser? user;
  final bool needsEmailConfirmation;
}

abstract class AccountAuthService {
  AccountUser? get currentUser;
  Stream<AccountUser?> watchUser();

  Future<AccountAuthResult> signIn({
    required String email,
    required String password,
  });

  Future<AccountAuthResult> signUp({
    required String email,
    required String password,
    required String displayName,
  });

  Future<void> updateDisplayName(String displayName);
  Future<void> signOut();
}

class SupabaseAccountAuthService implements AccountAuthService {
  SupabaseAccountAuthService(this._client);

  final SupabaseClient _client;

  AccountUser? _mapUser(User? user) {
    if (user == null) return null;
    final metadataName = user.userMetadata?['display_name']?.toString().trim();
    return AccountUser(
      id: user.id,
      email: user.email,
      displayName: metadataName == null || metadataName.isEmpty
          ? 'Releaf member'
          : metadataName,
    );
  }

  @override
  AccountUser? get currentUser => _mapUser(_client.auth.currentUser);

  @override
  Stream<AccountUser?> watchUser() async* {
    yield currentUser;
    await for (final authState in _client.auth.onAuthStateChange) {
      yield _mapUser(authState.session?.user);
    }
  }

  @override
  Future<AccountAuthResult> signIn({
    required String email,
    required String password,
  }) async {
    final response = await _client.auth.signInWithPassword(
      email: email.trim(),
      password: password,
    );
    return AccountAuthResult(
      user: _mapUser(response.user),
      needsEmailConfirmation: false,
    );
  }

  @override
  Future<AccountAuthResult> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    final cleanName = displayName.trim();
    final response = await _client.auth.signUp(
      email: email.trim(),
      password: password,
      data: {
        if (cleanName.isNotEmpty) 'display_name': cleanName,
      },
    );

    return AccountAuthResult(
      user: response.session == null ? null : _mapUser(response.user),
      needsEmailConfirmation: response.session == null,
    );
  }

  @override
  Future<void> updateDisplayName(String displayName) async {
    final user = _client.auth.currentUser;
    if (user == null) throw AuthException('You are not signed in.');

    final cleanName = displayName.trim();
    if (cleanName.isEmpty) {
      throw AuthException('Display name cannot be empty.');
    }

    await _client.auth.updateUser(
      UserAttributes(data: {'display_name': cleanName}),
    );
    await _client
        .from('profiles')
        .update({'display_name': cleanName})
        .eq('id', user.id);
  }

  @override
  Future<void> signOut() => _client.auth.signOut();
}

final accountAuthServiceProvider = Provider<AccountAuthService>((ref) {
  return SupabaseAccountAuthService(Supabase.instance.client);
});

final accountUserProvider = StreamProvider<AccountUser?>((ref) {
  return ref.watch(accountAuthServiceProvider).watchUser();
});
