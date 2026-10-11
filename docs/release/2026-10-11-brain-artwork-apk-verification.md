# Brain per-game artwork APK verification — 11 October 2026

## Scope

This checkpoint verifies that the eight existing approved per-game Brain illustrations
are not only referenced by Flutter source but are physically bundled in the Android
standard debug APK produced from app build candidate
`bf53e274136eef2d70c89cc0134be15b7cd7e4dc`.

Source workflow evidence:

- Flutter P0 Validation run: `38157339295` — **SUCCESS**
- Standard debug APK artifact: `11709835766`
- Artifact file inspected: `releaf-debug-standard.apk`

The same successful run also built the Premium Preview APK and release AAB smoke.

## Bundled Brain artwork

All eight expected files are present under
`assets/flutter_assets/assets/art/brain/` in the APK:

| Game | APK asset | SHA-256 |
| --- | --- | --- |
| Memory | `memory.webp` | `9d7cbd61b2de7df11be369837ac3d8ffb5ae05edc4504dc30459809711c3d006` |
| Labyrinth | `labyrinth.webp` | `e79f031ce518375c0313992c22e3cd4f189b1e032c50443f22895cd9c965c055` |
| Broken Mirror | `broken_mirror.webp` | `54be0f8b07f0f0584f6650a36754a23f898c51025696d0bde5d1741b4cf735b7` |
| Pattern Logic | `pattern_logic.webp` | `9a322ef14b9c86e58ea14d7699f3c4b95670893ffb93dd8461458d3ff7e56bea` |
| Sequence Echo | `sequence_echo.webp` | `0c579b9ebc5a32d4bb2854d9ffcbb3f7456ea1b5a53cd5cc57bb86ab4732b3bf` |
| Signal Scan | `signal_scan.webp` | `0f7f7cd2969acb2d7c9c05620b641ba5aef4ed180645011f6b18b5a84344d25f` |
| Trail Switch | `trail_switch.webp` | `012a95eb36372ce6d435c4a540a8159fdb5fb8142c86a766fcd72a5e6889a460` |
| Tower Plan | `tower_plan.webp` | `d252dc975dde7d8b2e523eecfe36b32d3cf3bda9c50d22b096c152d0545f2aad` |

Each APK entry was byte-compared with the optimized source asset used for the
repository upload. All eight comparisons returned **MATCH**.

## Main Relief editorial artwork

The APK inspection also confirmed all ten approved category illustrations are
bundled under `assets/flutter_assets/assets/art/relief/`:

`body_scan.webp`, `brain_games.webp`, `breathe.webp`,
`emergency_calm.webp`, `meditate.webp`, `reset.webp`, `sleep.webp`,
`sleep_stories.webp`, `soundscapes.webp`, and `tension_relief.webp`.

## Runtime mapping

The dedicated Brain map remains intentionally partial rather than duplicating art.
Memory, Labyrinth, Broken Mirror, Pattern Logic, Sequence Echo, Signal Scan,
Trail Switch and Tower Plan use their own approved bitmap. Math Race, Rule Shift,
N-Back, Spatial Span, Mental Rotation, Symbol Code and Color Conflict retain
their distinct procedural Brain artwork until a dedicated approved bitmap exists.

This checkpoint verifies packaging and mapping evidence. Final visual composition,
crop quality and physical-device rendering remain part of the consolidated Android
device QA matrix.
