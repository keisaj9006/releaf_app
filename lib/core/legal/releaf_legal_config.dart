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

  bool get isProductionReady => productionProblems.isEmpty;

  List<String> get productionProblems {
    final problems = <String>[];
    if (!_looksLikeProductionIdentity(dataControllerName)) {
      problems.add('data controller name');
    }
    if (!_looksLikeProductionEmail(privacyContactEmail)) {
      problems.add('privacy contact email');
    }
    if (!_isPublicHttpsUrl(privacyPolicyUrl)) {
      problems.add('public HTTPS privacy policy URL');
    }
    if (!_isPublicHttpsUrl(accountDeletionUrl)) {
      problems.add('public HTTPS account deletion URL');
    }
    if (!_isIsoDate(privacyLastUpdated)) {
      problems.add('privacy last-updated date (YYYY-MM-DD)');
    }
    return List<String>.unmodifiable(problems);
  }

  List<String> get missingProductionFields => productionProblems;

  Uri? get privacyPolicyUri => _isPublicHttpsUrl(privacyPolicyUrl)
      ? Uri.parse(privacyPolicyUrl.trim())
      : null;

  Uri? get accountDeletionUri => _isPublicHttpsUrl(accountDeletionUrl)
      ? Uri.parse(accountDeletionUrl.trim())
      : null;

  static bool _looksLikeProductionIdentity(String raw) {
    final value = raw.trim();
    if (value.isEmpty) return false;

    final normalized = value.toLowerCase();
    const placeholders = <String>{
      'todo',
      'tbd',
      'placeholder',
      'example',
      'your company',
      'your name',
    };

    return !placeholders.contains(normalized) &&
        !normalized.contains('example') &&
        !value.contains('<') &&
        !value.contains('>');
  }

  static bool _looksLikeProductionEmail(String raw) {
    final value = raw.trim();
    final at = value.indexOf('@');
    final dot = value.lastIndexOf('.');
    if (at <= 0 || dot <= at + 1 || dot >= value.length - 1) {
      return false;
    }

    final host = value.substring(at + 1);
    return !_isReservedOrLocalHost(host);
  }

  static bool _isPublicHttpsUrl(String raw) {
    final uri = Uri.tryParse(raw.trim());
    if (uri == null ||
        uri.scheme.toLowerCase() != 'https' ||
        uri.host.trim().isEmpty) {
      return false;
    }
    return !_isReservedOrLocalHost(uri.host);
  }

  static bool _isReservedOrLocalHost(String rawHost) {
    var host = rawHost.trim().toLowerCase();
    if (host.endsWith('.')) {
      host = host.substring(0, host.length - 1);
    }

    return host == 'localhost' ||
        host.endsWith('.localhost') ||
        host == '127.0.0.1' ||
        host == '::1' ||
        host.endsWith('.local') ||
        host == 'example.com' ||
        host.endsWith('.example.com') ||
        host == 'example.org' ||
        host.endsWith('.example.org') ||
        host == 'example.net' ||
        host.endsWith('.example.net') ||
        host == 'example' ||
        host.endsWith('.example');
  }

  static bool _isIsoDate(String raw) {
    final value = raw.trim();
    final match = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$').firstMatch(value);
    if (match == null) return false;

    final year = int.parse(match.group(1)!);
    final month = int.parse(match.group(2)!);
    final day = int.parse(match.group(3)!);
    if (month < 1 || month > 12 || day < 1 || day > 31) return false;

    final parsed = DateTime.utc(year, month, day);
    return parsed.year == year && parsed.month == month && parsed.day == day;
  }
}

const releafLegalConfig = ReleafLegalConfig.fromEnvironment();
