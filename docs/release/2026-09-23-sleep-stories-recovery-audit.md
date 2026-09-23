# Sleep / Stories recovery audit — 23 September 2026

## Checkpoint

### A. Implemented and working

- Repository: `C:\Users\joann\Releaf-Codex`, branch `releaf-development`, HEAD
  `8bf84e01396703c10ceba09fe5d75ce55a9be334`, synchronized with
  `origin/releaf-development` before this batch.
- The active app has four persistent destinations: Home, Reset, Sleep and Brain.
  The Meditate route and module remain present but parked from active 1.0
  discovery.
- Sleep currently presents ten canonical bundled sounds through the existing
  Sound catalog. Nature, tonal/noise and atmosphere sections route to the
  existing Sound player with Premium preview where required.
- The Sound player already provides loop playback, loading/error/retry states,
  exact clamped relative seeking, volume, favourites, recents, a deadline sleep
  timer with fade, interruption handling and Android background/lock-screen
  controls through `audio_service`.
- The Meditation player has separate narration and ambience layers, exact
  clamped ten-second seeking, captions, lifecycle handling and paused-session
  resume state.
- RevenueCat, authentication/account isolation, Emergency access/privacy and
  local-first progress safeguards remain implemented and covered by tests.

### B. Present but incomplete

- Sound playback is designed for indefinitely looping tracks. Its controller
  always selects loop release mode and therefore is not yet a correct long-form
  Story player.
- Sound favourites, recents and volume persist, but long-form position and
  completion do not persist across process restarts.
- The Sound mini player lives inside the legacy Sound screen; there is no one
  canonical now-playing surface across all Sleep destinations.
- Three existing meditation entries belong to the sleep-specific meditation
  series, but approved recorded narration remains unavailable for them.
- Sleep discovery is a manually assembled presentation over Sound IDs. It is
  not yet backed by a scalable Sleep taxonomy or editorial registry.

### C. Planned but absent

- No Sleep Story model, registry, collection, route, screen or player exists.
- `ST-DC-004` and the five approved Story collections are absent.
- There is no persistent Story progress, chapter state, Story completion,
  Story favourite state or offline/download implementation.
- There is no Sleep `All / Stories / Nature / Meditations / Sleep Music`
  discovery model, Continue Listening rail, Popular rail or collection See All
  route.
- No analytics SDK or product analytics event layer is present.

### D. Bugs and regressions found

- The full Windows test run exposed one portability defect: the Google Play
  listing contract test searched for LF-only headings while the checkout used
  CRLF. The content itself was correct. The test now normalizes CRLF before
  asserting headings.
- The same run logged a transient Dart worker-thread creation warning, but all
  tests after it continued. It did not add a second failed test. Resource
  pressure remains worth monitoring on later full-suite runs.

### E. Systems to consolidate incrementally

- Keep the existing Sound controller/background driver as the canonical base
  for Nature and Sleep Music.
- Reuse the existing Meditation catalog/player for sleep-specific guided
  practices while preserving its separate voice and ambience layers.
- Extend the playback boundary to support finite long-form media before adding
  Story UI. Do not create a parallel audio engine or a bespoke player per story.
- Keep the legacy Sound route for compatibility while Sleep gains its own
  catalog and discovery layer.

### F. Baseline verification

- `flutter pub get`: PASS.
- `flutter analyze --no-pub`: PASS, no issues (28.2 seconds).
- Initial `flutter test --no-pub --reporter expanded`: 582 tests executed,
  581 passed and one CRLF-sensitive listing test failed.
- Focused listing regression test after the portability fix: PASS, 1/1.
- Final full suite after the Sleep registry implementation: PASS, 591/591.
- Sleep/Sound/Meditation focused suite: PASS, 45/45. Release-gate,
  navigation and paywall follow-up suite after documentation/copy reconciliation:
  PASS, 59/59.
- Final `flutter analyze --no-pub`: PASS, no issues (11.4 seconds).
- `flutter build apk --debug --no-pub
  --dart-define-from-file=tool/local/revenuecat-test-store.json`: PASS. The
  ignored file was present and not tracked; its contents were not displayed.
- Build warnings: future Flutter support floors for Gradle/AGP/Kotlin and an
  Android SDK XML tool-version warning. None failed this build.

### G. Audited HEAD

The audit began at `8bf84e01396703c10ceba09fe5d75ce55a9be334` on
`releaf-development`.

### H. Highest-priority next task

Add a canonical Sleep domain model and registry that defines the four frozen
categories and five Story collections, references existing Sound and Meditation
content rather than copying it, and registers `ST-DC-004` honestly as awaiting
its production artwork/audio. This is the prerequisite for player hardening and
the new discovery UI.
