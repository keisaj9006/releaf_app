# Sleep content intake checkpoint — 29 September 2026

The intake manifest records candidate Sleep material separately from the existing runtime catalogs. It validates local media paths, formats, duration, access, source mapping, provenance, rights, owner approval and narrator identity when narration is required. Promotion is explicit. Existing playable Sound tracks retain their current catalog contract until a reviewed migration.

Run the repository gate with:

```powershell
flutter test --no-pub --reporter expanded test/sleep_content_release_gate_test.dart
```

Current report: **one candidate, zero promoted, zero candidate bytes, zero promoted bytes**. `ST-DC-004` remains pending audio, artwork, measured duration, access decision, licence record, owner approval, rights clearance and narrator provenance. It cannot open an empty player. The gate passes because no pending item is promoted; it fails for invalid approved or promoted content.

Controlled-asset tests reject missing or unsupported media, unsafe paths, duplicate IDs, unknown or mismatched player sources, access conflicts and promotion without a ready record. These checks do not authenticate a licence or owner approval. Final rights evidence and listening review remain open.

The gate runs under `flutter test` because the canonical source catalogs import Flutter. A plain `dart run` cannot load `dart:ui`.

Verification: `flutter analyze --no-pub` reported **No issues found**; `flutter test --no-pub --reporter compact` passed **658/658**. The existing AAB measured 93,375,235 / 105,000,000 bytes and the unchanged local asset tree 56,348,319 / 63,000,000 bytes with `dart run tool/release/release_size_budget_policy.dart --aab build/app/outputs/bundle/release/app-release.aab --assets assets`. The AAB predates this metadata-only batch; no new media was bundled.
