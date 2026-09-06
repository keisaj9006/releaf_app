import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const releafAuthCallbackUrl = 'app.releaf.mobile://auth-callback';

abstract class AccountRecoveryService {
  Future<void> requestPasswordReset(String email);
  Future<void> updatePassword(String password);
}

class SupabaseAccountRecoveryService implements AccountRecoveryService {
  SupabaseAccountRecoveryService(this._client);

  final SupabaseClient _client;

  @override
  Future<void> requestPasswordReset(String email) async {
    await _client.auth.resetPasswordForEmail(
      email.trim(),
      redirectTo: releafAuthCallbackUrl,
    );
  }

  @override
  Future<void> updatePassword(String password) async {
    await _client.auth.updateUser(
      UserAttributes(password: password),
    );
  }
}

final accountRecoveryServiceProvider = Provider<AccountRecoveryService>((ref) {
  return SupabaseAccountRecoveryService(Supabase.instance.client);
});
