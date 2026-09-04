import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:releaf_app/features/relief/data/audio_catalog.dart';
import 'package:releaf_app/features/relief/data/relief_repository.dart';
import 'package:releaf_app/features/relief/data/reset_catalog.dart';
import 'package:releaf_app/features/relief/domain/models/reset_content.dart';
import 'package:releaf_app/features/relief/domain/reset_access_policy.dart';

void main() {
  const catalog = ResetCatalog();
  const policy = ResetAccessPolicy();
  const currentSessionIds = <String>{
    'emergency-grounding',
    '60s-grounding',
    '90s-calm-down',
    '3min-breath',
    '5min-focus',
  };

  test('every active and current session ID resolves uniquely', () {
    final content = catalog.getAll();
    final ids = content.map((item) => item.id).toSet();

    expect(content, hasLength(currentSessionIds.length));
    expect(ids, currentSessionIds);
    for (final id in currentSessionIds) {
      expect(catalog.getById(id)?.id, id);
    }
  });

  test('Emergency is classified as always-free emergency content', () {
    final emergency = catalog.getById(ResetCatalog.emergencySessionId)!;

    expect(emergency.level, ResetLevel.emergency);
    expect(emergency.quickCategory, isNull);
    expect(emergency.modality, ResetModality.grounding);
    expect(emergency.accessTier, ResetAccessTier.free);
    expect(emergency.isEmergency, isTrue);
    expect(policy.requiresEntitlement(emergency), isFalse);
  });

  test('current free Quick Reset sessions keep typed category mappings', () {
    final grounding = catalog.getById('60s-grounding')!;
    final calmDown = catalog.getById('90s-calm-down')!;

    expect(grounding.level, ResetLevel.quick);
    expect(grounding.quickCategory, QuickResetCategory.noBreath);
    expect(grounding.modality, ResetModality.grounding);
    expect(grounding.accessTier, ResetAccessTier.free);

    expect(calmDown.level, ResetLevel.quick);
    expect(calmDown.quickCategory, QuickResetCategory.breath);
    expect(calmDown.modality, ResetModality.breathing);
    expect(calmDown.accessTier, ResetAccessTier.free);
  });

  test('3-minute Deep Reset remains a legacy-compatible premium mapping', () {
    final deepReset = catalog.getById('3min-breath')!;

    expect(deepReset.level, ResetLevel.deep);
    expect(deepReset.quickCategory, isNull);
    expect(deepReset.modality, ResetModality.breathing);
    expect(deepReset.accessTier, ResetAccessTier.premium);
    expect(deepReset.taxonomyStatus, ResetTaxonomyStatus.legacyCompatible);
    expect(deepReset.durationSeconds, 180);
    expect(deepReset.durationSeconds, isNot(480));
  });

  test('Focus Anchor remains a legacy-compatible premium Quick Reset', () {
    final focus = catalog.getById('5min-focus')!;

    expect(focus.level, ResetLevel.quick);
    expect(focus.quickCategory, QuickResetCategory.noBreath);
    expect(focus.modality, ResetModality.grounding);
    expect(focus.accessTier, ResetAccessTier.premium);
    expect(focus.taxonomyStatus, ResetTaxonomyStatus.legacyCompatible);
    expect(focus.durationSeconds, 300);
  });

  test('canonical access policy covers free and premium entitlement states', () {
    final free = catalog.getById('60s-grounding')!;
    final premium = catalog.getById('3min-breath')!;

    expect(
      policy.canAccess(free, hasPremiumEntitlement: false),
      isTrue,
    );
    expect(
      policy.canAccess(premium, hasPremiumEntitlement: false),
      isFalse,
    );
    expect(
      policy.canAccess(premium, hasPremiumEntitlement: true),
      isTrue,
    );
  });

  test('unknown session ID returns null from the canonical catalog', () {
    expect(catalog.getById('missing-session'), isNull);
  });

  test('legacy AudioCatalog resolves the canonical IDs and content', () {
    const legacyCatalog = AudioCatalog();

    expect(
      legacyCatalog.getSessions().map((item) => item.id).toSet(),
      currentSessionIds,
    );
    for (final id in currentSessionIds) {
      expect(legacyCatalog.getById(id), same(catalog.getById(id)));
    }
  });

  test('legacy repository delegates to the canonical catalog', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final legacyItems = await container.read(reliefRepositoryProvider.future);

    expect(
      legacyItems.map((item) => item.id).toSet(),
      currentSessionIds,
    );
    expect(legacyItems, same(catalog.getAll()));
  });
}
