# Registry-driven Sleep discovery — 24 September 2026

## Implemented

- Replaced the earlier sound-only Sleep page with one canonical registry-driven
  discovery surface.
- Added `All`, `Stories`, `Nature`, `Meditations` and `Sleep Music` filters.
- Added Tonight, Popular and local Continue Listening surfaces.
- Added the five approved Story collection rails and collection-level See all
  sheets.
- Routes ready Sound, Meditation and Story entries to their existing player or
  entitlement boundary; no playback service was duplicated.
- Keeps the legacy Sound library reachable.
- Shows Premium state before the paywall and keeps missing production audio or
  recorded guidance visible but disabled.
- Preserves the separate owner-only Stories preview flag.

No Story audio, narrator, artwork, duration or access decision was fabricated.
Nature and Sleep Music remain narration-free. Guided Sleep Meditation cards with
missing approved voice recordings remain unavailable rather than substituting a
voice.

## Verification

- `dart format ...` — passed.
- `flutter analyze --no-pub` — passed, no issues.
- Focused Sleep/navigation regression — **90/90 passed**.
- `flutter test --no-pub --reporter compact` — **636/636 passed**.
- `flutter build apk --debug --dart-define-from-file=tool/local/revenuecat-test-store.json`
  — passed without reading or printing the ignored configuration contents.
- `adb devices -l` — exited 0 and reported `List of devices attached` with no
  attached device; no installation was attempted.

Artifact:

- `build/app/outputs/flutter-apk/app-debug.apk`
- size: `224,014,412` bytes
- SHA-256: `125F0C9E3EF4C52AC21ABBF0A932DB1DA79752B6406E397195B697E75C099F92`

## Open dependencies

- Approved production Story narration, ambience/music, artwork, duration,
  provenance and explicit access assignment.
- Physical Samsung review of the new discovery layout and long-form background,
  Bluetooth, interruption, notification, screen-off and timer behavior.
- Owner listening remains open. No audio was approved or promoted here.
