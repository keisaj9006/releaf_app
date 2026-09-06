import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'account_recovery_service.dart';

abstract class AccountEmailService {
  Future<void> resendSignupConfirmation(String email);
}

class SupabaseAccountEmailService implements AccountEmailService {
  SupabaseAccountEmailService(this._client);

  final SupabaseClient _client;

  @override
  Future<void> resendSignupConfirmation(String email) async {
    await _client.auth.resend(
      type: OtpType.signup,
      email: email.trim(),
      emailRedirectTo: releafAuthCallbackUrl,
    );
  }
}

final accountEmailServiceProvider = Provider<AccountEmailService>((ref) {
  return SupabaseAccountEmailService(Supabase.instance.client);
});
