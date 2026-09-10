import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Google Play Data Safety release worksheet stays wired to the gate', () {
    final worksheet = File('docs/release/google_play_data_safety.md');
    final gate = File('docs/release/releaf_1_0_release_gate.md');

    expect(worksheet.existsSync(), isTrue);
    expect(gate.existsSync(), isTrue);

    final source = worksheet.readAsStringSync();
    final gateSource = gate.readAsStringSync();

    expect(source, contains('Personal info → Name'));
    expect(source, contains('Personal info → Email address'));
    expect(source, contains('Personal info → User IDs'));
    expect(source, contains('Financial info → Purchase history'));
    expect(source, contains('raw Labyrinth accelerometer readings'));
    expect(source, contains('local-only Leaves/progress values'));
    expect(
      source,
      contains('content mapping prepared; vendor/dashboard verification and Play Console submission required'),
    );
    expect(
      gateSource,
      contains('docs/release/google_play_data_safety.md'),
    );
  });

  test('audited RevenueCat assumptions require a Data Safety re-review if changed', () {
    final source = File(
      'lib/core/subscription/revenuecat_service.dart',
    ).readAsStringSync();

    // Releaf deliberately identifies signed-in customers with its account UUID.
    // This supports the worksheet's User IDs declaration.
    expect(source, contains('Purchases.logIn'));

    // RevenueCat says Device IDs may need declaration when integrations collect
    // advertising/device identifiers. If Releaf starts collecting them directly,
    // fail CI until the worksheet and Play answers are re-audited.
    expect(source, isNot(contains('collectDeviceIdentifiers')));
  });

  test('local-only progress and Labyrinth motion assumptions stay local', () {
    final leaves = File(
      'lib/features/progress/data/leaves_repository.dart',
    ).readAsStringSync();
    final labyrinth = File(
      'lib/games/labyrinth/labyrinth_game_screen.dart',
    ).readAsStringSync();

    expect(leaves, contains('sharedPreferencesProvider'));
    expect(leaves, isNot(contains('supabase_flutter')));
    expect(leaves, isNot(contains('http.')));

    expect(labyrinth, contains('sensors_plus/sensors_plus.dart'));
    expect(labyrinth, contains('accelerometerEventStream'));
    expect(labyrinth, isNot(contains('supabase_flutter')));
    expect(labyrinth, isNot(contains('package:http/')));
  });

  test('manifest does not silently add unaudited sensitive permissions', () {
    final manifest = File(
      'android/app/src/main/AndroidManifest.xml',
    ).readAsStringSync();

    const sensitivePermissionsThatRequireDataSafetyReview = <String>[
      'android.permission.ACCESS_FINE_LOCATION',
      'android.permission.ACCESS_COARSE_LOCATION',
      'android.permission.CAMERA',
      'android.permission.RECORD_AUDIO',
      'android.permission.READ_CONTACTS',
      'android.permission.WRITE_CONTACTS',
      'android.permission.READ_CALENDAR',
      'android.permission.WRITE_CALENDAR',
    ];

    for (final permission in sensitivePermissionsThatRequireDataSafetyReview) {
      expect(
        manifest,
        isNot(contains(permission)),
        reason: '$permission was added. Re-audit Google Play Data Safety before release.',
      );
    }
  });
}
