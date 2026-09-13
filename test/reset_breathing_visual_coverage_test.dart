import 'package:flutter_test/flutter_test.dart';

import 'package:releaf_app/features/relief/data/reset_catalog.dart';
import 'package:releaf_app/features/relief/domain/models/reset_content.dart';
import 'package:releaf_app/features/relief/domain/models/reset_session_program.dart';

void main() {
  const catalog = ResetCatalog();

  const expectedBreathingSessionIds = <String>{
    'equal-rhythm',
    '90s-calm-down',
    'longer-exhale',
    'box-breathing',
    'sleep-downshift',
    'energy-up-breath',
    'focus-breath',
    'anxiety-slow-cycle',
    'wired-steady',
    '3min-breath',
  };

  test('all preserved breathing methods stay on the V01 lung visual family', () {
    final breathingSessions = catalog.getAll().where(
      (session) => session.program?.type == ResetProgramType.pacedBreathing,
    );

    expect(
      breathingSessions.map((session) => session.id).toSet(),
      expectedBreathingSessionIds,
    );

    for (final session in breathingSessions) {
      expect(
        session.modality,
        ResetModality.breathing,
        reason: session.id,
      );
      expect(
        session.visualType,
        ResetVisualType.livingForm,
        reason: '${session.id} must render through the V01 breathing Living Form',
      );
      expect(
        session.program?.breathPattern,
        isNotNull,
        reason: '${session.id} must keep its canonical BreathPattern',
      );
    }
  });

  test('the implemented 4–6 method remains 4 seconds in and 6 seconds out', () {
    final calm = catalog.getById('90s-calm-down')!;
    final pattern = calm.program!.breathPattern!;

    expect(pattern.inhaleSeconds, 4);
    expect(pattern.holdAfterInhaleSeconds, 0);
    expect(pattern.exhaleSeconds, 6);
    expect(pattern.holdAfterExhaleSeconds, 0);
  });
}
