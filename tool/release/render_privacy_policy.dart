import 'dart:convert';
import 'dart:io';

import 'package:releaf_app/core/legal/releaf_legal_config.dart';

void main(List<String> args) {
  final env = Platform.environment;
  final config = ReleafLegalConfig(
    dataControllerName: env['RELEAF_DATA_CONTROLLER_NAME'] ?? '',
    privacyContactEmail: env['RELEAF_PRIVACY_CONTACT_EMAIL'] ?? '',
    privacyPolicyUrl: env['RELEAF_PRIVACY_POLICY_URL'] ?? '',
    accountDeletionUrl: env['RELEAF_ACCOUNT_DELETION_URL'] ?? '',
    privacyLastUpdated: env['RELEAF_PRIVACY_LAST_UPDATED'] ?? '',
  );

  final problems = config.productionProblems;
  if (problems.isNotEmpty) {
    stderr.writeln(
      'Cannot render Releaf Privacy Policy: invalid production legal metadata: '
      '${problems.join(', ')}.',
    );
    exitCode = 2;
    return;
  }

  final outputPath = args.isEmpty ? 'build/web/privacy-policy.html' : args.first;
  final output = File(outputPath);
  output.parent.createSync(recursive: true);
  output.writeAsStringSync(_render(config));

  stdout.writeln('Rendered Releaf Privacy Policy to $outputPath.');
}

String _render(ReleafLegalConfig config) {
  final controller = _escape(config.dataControllerName.trim());
  final email = _escape(config.privacyContactEmail.trim());
  final privacyUrl = _escape(config.privacyPolicyUrl.trim());
  final deletionUrl = _escape(config.accountDeletionUrl.trim());
  final updated = _escape(config.privacyLastUpdated.trim());

  return '''<!doctype html>
<html lang="en-GB">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <meta name="robots" content="index,follow">
  <meta name="description" content="Releaf Privacy Policy: how account, subscription and local app data are handled.">
  <link rel="canonical" href="$privacyUrl">
  <title>Releaf Privacy Policy</title>
  <style>
    :root {
      color-scheme: dark;
      font-family: Inter, ui-sans-serif, system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif;
      background: #111915;
      color: #f4f4ec;
    }
    * { box-sizing: border-box; }
    body {
      margin: 0;
      min-height: 100vh;
      background: linear-gradient(180deg, #111915 0%, #0b100e 100%);
    }
    main {
      width: min(820px, calc(100% - 32px));
      margin: 0 auto;
      padding: 48px 0 72px;
    }
    article {
      padding: clamp(24px, 5vw, 48px);
      border: 1px solid rgba(255,255,255,.10);
      border-radius: 28px;
      background: rgba(24,35,29,.94);
      box-shadow: 0 24px 80px rgba(0,0,0,.26);
    }
    .brand {
      margin: 0 0 14px;
      color: #a9c6a9;
      font-size: .82rem;
      font-weight: 800;
      letter-spacing: .14em;
      text-transform: uppercase;
    }
    h1 {
      margin: 0;
      font-size: clamp(2rem, 7vw, 3.5rem);
      line-height: 1.04;
      letter-spacing: -.04em;
    }
    h2 {
      margin: 36px 0 12px;
      font-size: 1.35rem;
    }
    p, li {
      color: #d8ddd8;
      line-height: 1.72;
    }
    ul { padding-left: 1.3rem; }
    a { color: #c7dec6; }
    .meta {
      margin: 18px 0 30px;
      color: #aeb9b1;
      font-size: .94rem;
    }
    .notice {
      margin: 24px 0;
      padding: 18px 20px;
      border-radius: 18px;
      background: rgba(169,198,169,.09);
    }
  </style>
</head>
<body>
  <main>
    <article>
      <p class="brand">Releaf privacy</p>
      <h1>Privacy Policy</h1>
      <p class="meta">Last updated: $updated</p>

      <p>
        This policy explains how <strong>$controller</strong> ("Releaf", "we", "us")
        handles personal data when you use the Releaf app and its account, Premium,
        support and deletion services. For privacy questions, contact
        <a href="mailto:$email">$email</a>.
      </p>

      <h2>What data we process</h2>
      <ul>
        <li><strong>Account data:</strong> if you create or use an account, Supabase processes your email address, display name, account/user ID and authentication data needed for sign-in, confirmation and password recovery.</li>
        <li><strong>Premium and purchase data:</strong> RevenueCat and Google Play process subscription/purchase history and identifiers needed to provide, restore and manage Premium access. Releaf can associate a signed-in RevenueCat customer with the Releaf account user ID.</li>
        <li><strong>Local progress:</strong> Releaf 1.0 keeps Leaves, completion history, game progress, preferences and similar wellbeing/training progress local on your device unless a feature explicitly says otherwise. Releaf 1.0 does not claim cloud backup for this progress.</li>
        <li><strong>Labyrinth motion input:</strong> accelerometer readings are used locally and transiently to control the Labyrinth game. The audited Releaf 1.0 flow does not send those raw readings to Supabase or RevenueCat.</li>
        <li><strong>Health measurements:</strong> the audited Releaf 1.0 release does not upload sleep measurements, heart rate, medical records, diagnoses or other measured health data.</li>
      </ul>

      <h2>Purposes and lawful basis</h2>
      <p>
        We process account and subscription information where it is necessary to provide
        the services you request, including account access, recovery, Premium entitlement,
        purchases and restoration. We may also process limited information where necessary
        for our legitimate interests in keeping Releaf secure, reliable and preventing misuse,
        provided those interests are not overridden by your rights. Where the law requires us
        to keep or disclose information, the lawful basis may be compliance with a legal obligation.
      </p>

      <h2>Service providers and recipients</h2>
      <p>
        Releaf uses service providers to operate the product. These currently include
        <strong>Supabase</strong> for account/authentication and related server data,
        <strong>RevenueCat</strong> for subscription entitlement management, and
        <strong>Google Play</strong> for Android billing and subscription management.
        We do not sell personal data. The audited Releaf 1.0 release does not include an advertising SDK.
      </p>

      <h2>International processing</h2>
      <p>
        Some service providers may process information outside the United Kingdom. Where
        international transfers of personal data require safeguards, we rely on the applicable
        legal transfer mechanism used for that provider and processing relationship. Provider
        locations and safeguards can change, so current provider documentation and contractual
        terms apply alongside this policy.
      </p>

      <h2>Data retention</h2>
      <p>
        Account/profile data is kept while the account is active and is removed through the
        Releaf account-deletion flow, subject to limited retention that may be required by law,
        security/fraud obligations or provider backup cycles. Subscription and transaction
        records may also remain with Google Play or other payment/subscription providers for
        periods they are required or permitted to retain them under their own legal obligations.
      </p>
      <p>
        Data that Releaf stores only on your device remains there until you clear the app's
        storage, uninstall/reset the app or otherwise remove it through your device controls.
        Because that local data is not held on Releaf's server, Releaf cannot remotely erase it.
      </p>

      <h2>Delete your account</h2>
      <div class="notice">
        You can request permanent deletion without having the Android app installed. Open
        <a href="$deletionUrl">the Releaf account-deletion page</a>, sign in to the account
        you want to delete and follow the deletion steps. The authenticated deletion flow
        removes the Releaf account and associated Releaf server-side account data handled by
        the account service and requests deletion of the matching RevenueCat customer where applicable.
      </div>
      <p>
        Cancelling a Google Play subscription and deleting a Releaf account are separate actions.
        If a subscription is still active, manage or cancel it through Google Play as appropriate.
      </p>

      <h2>Your data-protection rights</h2>
      <p>
        Depending on the circumstances, UK data-protection law may give you rights to ask for
        access to your personal data, correction, erasure, restriction, portability or to object
        to certain processing. Some rights depend on the lawful basis and may have legal exceptions.
        Contact <a href="mailto:$email">$email</a> to exercise a right or ask a privacy question.
      </p>

      <h2>Complaints</h2>
      <p>
        Please contact us first if you have a privacy concern. You also have the right to complain
        to the UK <strong>Information Commissioner's Office</strong> if you believe your personal
        data has been handled unlawfully. Current complaint and contact information is available
        from the Information Commissioner.
      </p>

      <h2>Changes to this policy</h2>
      <p>
        We may update this policy when Releaf's features, providers or legal obligations change.
        The date at the top identifies the version currently published for this release.
      </p>
    </article>
  </main>
</body>
</html>
''';
}

String _escape(String value) => const HtmlEscape(HtmlEscapeMode.attribute).convert(value);
