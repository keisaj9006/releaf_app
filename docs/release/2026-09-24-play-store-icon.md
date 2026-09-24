# Google Play app icon checkpoint — 24 September 2026

Scope: prepare the required 512 × 512 Google Play icon from the existing Releaf
launcher mark. No new identity, illustration or product claim was introduced.

## Result

- source: `assets/icon/app_icon.png`, 1024 × 1024, 24-bit RGB;
- source SHA-256:
  `9D44B42A62268FA2B9ED79C92C3F245A5DC451F1B8DFAFC1BD3648D77029CAB2`;
- output: `store/google-play/app-icon.png`, 512 × 512, 32-bit RGBA;
- output SHA-256:
  `664DB6910FBEB90AB849389204BD98A9521FF9F56E45D7BCF4018FA3726400AE`;
- output size: 165,458 bytes.

The conversion used high-quality bicubic scaling and an opaque alpha channel.
The source hash is pinned by `tool/release/build_play_store_icon.ps1`, so a future
launcher change cannot silently regenerate a different Store mark.

## Verification

`test/google_play_store_asset_gate_test.dart` copies the canonical icon into an
otherwise complete fixture and runs the real strong-listing policy. This proves
the icon meets the existing dimensions, PNG colour-type, alpha and file-size
contract. The image was also inspected at original resolution after generation.

The complete Store pack remains open: feature graphic, current release-candidate
screenshots, owner creative review and Play Console preview are still required.
No Play Console upload or publication occurred.

## Automated results

- `flutter test test/google_play_store_asset_gate_test.dart test/google_play_store_listing_contract_test.dart test/google_play_store_listing_active_pillars_test.dart --no-pub --reporter expanded`
  — **8/8 passed**;
- `flutter analyze --no-pub` — **no issues found**;
- `flutter test --no-pub --reporter expanded` — **641/641 passed**;
- strong listing policy — expected **FAIL** only for the missing feature graphic
  and four current phone screenshots; it reports no app-icon error.
