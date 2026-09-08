import 'package:flutter_test/flutter_test.dart';
import 'package:releaf_app/features/meditation/presentation/meditation_player_screen.dart';

void main() {
  test('Meditation seek controls move by exactly ten seconds', () {
    expect(
      meditationRemainingAfterSeek(
        durationSeconds: 240,
        remainingSeconds: 200,
        deltaSeconds: 10,
      ),
      190,
    );
    expect(
      meditationRemainingAfterSeek(
        durationSeconds: 240,
        remainingSeconds: 200,
        deltaSeconds: -10,
      ),
      210,
    );
  });

  test('Meditation seek clamps safely at both ends', () {
    expect(
      meditationRemainingAfterSeek(
        durationSeconds: 240,
        remainingSeconds: 5,
        deltaSeconds: 10,
      ),
      1,
    );
    expect(
      meditationRemainingAfterSeek(
        durationSeconds: 240,
        remainingSeconds: 238,
        deltaSeconds: -10,
      ),
      240,
    );
  });
}
