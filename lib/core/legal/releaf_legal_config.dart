class ReleafLegalConfig {
  const ReleafLegalConfig({
    required this.dataControllerName,
    required this.privacyContactEmail,
    required this.privacyPolicyUrl,
    required this.accountDeletionUrl,
    required this.privacyLastUpdated,
  });

  const ReleafLegalConfig.fromEnvironment()
      : dataControllerName = const String.fromEnvironment(
          'RELEAF_DATA_CONTROLLER_NAME',
        ),
        privacyContactEmail = const String.fromEnvironment(
          'RELEAF_PRIVACY_CONTACT_EMAIL',
        ),
        privacyPolicyUrl = const String.fromEnvironment(
          'RELEAF_PRIVACY_POLICY_URL',
        ),
        accountDeletionUrl = const String.fromEnvironment(
          'RELEAF_ACCOUNT_DELETION_URL',
        ),
        privacyLastUpdated = const String.fromEnvironment(
          'RELEAF_PRIVACY_LAST_UPDATED',
        );

  final String dataControllerName;
  final String privacyContactEmail;
  final String privacyPolicyUrl;
  final String accountDeletionUrl;
  final String privacyLastUpdated;

  bool get isProductionReady =>
      dataControllerName.trim().isNotEmpty &&
      _looksLikeEmail(privacyContactEmail) &&
      _isHttpsUrl(privacyPolicyUrl) &&
      _isHttpsUrl(accountDeletionUrl) &&
      privacyLastUpdated.trim().isNotEmpty;

  List<String> get missingProductionFields {
    final missing = <String>[];
    if (dataControllerName.trim().isEmpty) {
      missing.add('data controller name');
    }
    if (!_looksLikeEmail(privacyContactEmail)) {
      missing.add('privacy contact email');
    }
    if (!_isHttpsUrl(privacyPolicyUrl)) {
      missing.add('HTTPS privacy policy URL');
    }
    if (!_isHttpsUrl(accountDeletionUrl)) {
      missing.add('HTTPS account deletion URL');
    }
    if (privacyLastUpdated.trim().isEmpty) {
      missing.add('privacy last-updated date');
    }
    return List<String>.unmodifiable(missing);
  }

  Uri? get privacyPolicyUri =>
      _isHttpsUrl(privacyPolicyUrl) ? Uri.parse(privacyPolicyUrl.trim()) : null;

  Uri? get accountDeletionUri => _isHttpsUrl(accountDeletionUrl)
      ? Uri.parse(accountDeletionUrl.trim())
      : null;

  static bool _looksLikeEmail(String raw) {
    final value = raw.trim();
    final at = value.indexOf('@');
    final dot = value.lastIndexOf('.');
    return at > 0 && dot > at + 1 && dot < value.length - 1;
  }

  static bool _isHttpsUrl(String raw) {
    final uri = Uri.tryParse(raw.trim());
    return uri != null &&
        uri.scheme.toLowerCase() == 'https' &&
        uri.host.trim().isNotEmpty;
  }
}

const releafLegalConfig = ReleafLegalConfig.fromEnvironment();
