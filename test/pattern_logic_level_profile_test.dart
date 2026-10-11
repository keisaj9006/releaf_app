import 'package:flutter_test/flutter_test.dart';
import 'package:releaf_app/games/pattern_logic/pattern_logic_level_profile.dart';

void main() {
  test('Pattern Logic preserves the exact legacy 1-12 progression shape', () {
    for (var level = 1; level <= 12; level++) {
      final profile = patternLogicProfileForLevel(level);
      expect(profile.level, level);
      expect(profile.extraRounds, level - 1, reason: 'level $level');
      expect(profile.supplementOffset, level - 1, reason: 'level $level');
      expect(profile.supplementStride, 1, reason: 'level $level');
      expect(profile.hardBias, 0, reason: 'level $level');
      expect(profile.showHint, level < 7, reason: 'level $level');
    }
  });

  test('Pattern Logic levels 13-50 are deterministic and bounded', () {
    PatternLogicLevelProfile? previous;

    for (var level = 13; level <= 50; level++) {
      final first = patternLogicProfileForLevel(level);
      final second = patternLogicProfileForLevel(level);

      expect(first.level, level);
      expect(first.extraRounds, inInclusiveRange(12, 19));
      expect(first.supplementOffset, inInclusiveRange(0, 10));
      expect(first.supplementStride, inInclusiveRange(1, 3));
      expect(first.hardBias, inInclusiveRange(1, 4));
      expect(first.showHint, isFalse);

      expect(first.extraRounds, second.extraRounds);
      expect(first.supplementOffset, second.supplementOffset);
      expect(first.supplementStride, second.supplementStride);
      expect(first.hardBias, second.hardBias);

      if (previous != null && level % 10 == 1) {
        expect(
          first.hardBias,
          greaterThan(previous.hardBias),
          reason: 'each ten-level band must increase challenge',
        );
      }
      previous = first;
    }
  });

  test('Pattern Logic profile clamps safely to the supported range', () {
    expect(patternLogicProfileForLevel(-5).level, 1);
    expect(patternLogicProfileForLevel(999).level, 50);
  });
}
