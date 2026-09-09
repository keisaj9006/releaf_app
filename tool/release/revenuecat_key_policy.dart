import 'dart:io';

String? productionGoogleRevenueCatKeyError(String raw) {
  final key = raw.trim();

  if (key.isEmpty) {
    return 'REVENUECAT_ANDROID_API_KEY is required.';
  }
  if (key.startsWith('test_')) {
    return 'RevenueCat Test Store keys must never be shipped to Google Play.';
  }
  if (key.startsWith('sk_')) {
    return 'RevenueCat secret API keys must never be embedded in the app.';
  }
  if (key.startsWith('appl_')) {
    return 'An Apple RevenueCat SDK key cannot be used for the Android release.';
  }
  if (!key.startsWith('goog_')) {
    return 'Android Play releases require the platform-specific RevenueCat goog_ SDK key.';
  }
  if (RegExp(r'\s').hasMatch(key)) {
    return 'RevenueCat SDK keys cannot contain whitespace.';
  }
  if (key.length <= 'goog_'.length + 8) {
    return 'RevenueCat Google SDK key is unexpectedly short.';
  }

  return null;
}

bool isProductionGoogleRevenueCatKey(String raw) =>
    productionGoogleRevenueCatKeyError(raw) == null;

void main(List<String> args) {
  if (args.length != 1) {
    stderr.writeln(
      'Usage: dart run tool/release/revenuecat_key_policy.dart <android-sdk-key>',
    );
    exitCode = 64;
    return;
  }

  final error = productionGoogleRevenueCatKeyError(args.single);
  if (error != null) {
    stderr.writeln(error);
    exitCode = 2;
    return;
  }

  stdout.writeln('RevenueCat Android production SDK key shape is valid.');
}
