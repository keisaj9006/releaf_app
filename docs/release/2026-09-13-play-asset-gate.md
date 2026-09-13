# Google Play asset gate checkpoint — 13 September 2026

## Scope

This checkpoint adds a fail-closed structural gate for Releaf 1.0 Google Play
listing assets. It does not create, approve or upload the actual store graphics.

Final verified code commit: `3186cb1e8c5e604aeedd6d1978e2c342d6d310b2`.

## What is enforced

`tool/release/play_store_asset_policy.dart` validates the canonical pack under
`store/google-play/`:

- `app-icon.png`: exactly 512 × 512, 8-bit RGBA PNG (32-bit with alpha), no larger
  than 1,024 KB;
- exactly one feature graphic: PNG/JPG/JPEG, exactly 1,024 × 500; PNG must be
  8-bit RGB without alpha;
- phone screenshots from `screenshots/phone/`: portrait images; normal mode
  requires at least two, while `--strong-listing` requires at least four and each
  must be at least 1,080 × 1,920.

The validator reads PNG/JPEG metadata directly and reports actionable errors. Its
CLI exits non-zero when the pack is missing or invalid.

`tool/build_play_release.ps1` invokes:

```text
dart run tool/release/play_store_asset_policy.dart --root "$repoRoot" --strong-listing
```

before a production Play build can continue. A failed audit produces the stable
release error prefix `Google Play listing asset gate failed`.

## TDD evidence

The test was introduced before the implementation. The direct policy tests first
failed against an explicit not-implemented stub; after implementation they passed.
A second contract test then failed because the production build script did not yet
invoke the policy. After integration, the only remaining RED was the missing stable
failure-message contract; `3186cb1` corrected that wording without changing policy
logic.

Final automated evidence for `3186cb1`:

- Flutter P0 Validation run `34783149607`: **SUCCESS**;
- Releaf Web Release Smoke run `34783149590`: **SUCCESS**;
- analyzer: clean;
- full Flutter suite: **572 tests passed**;
- Brain and Reset targeted gates: passed;
- Releaf Guide / Reset Guide / Reset demo manifests: exported and uploaded;
- standard debug APK: built and uploaded;
- Premium Preview debug APK: built and uploaded;
- release AAB smoke artifact: built and uploaded;
- Android 16 KB ZIP/ELF compatibility: passed;
- web release build and account-deletion resource contract: passed.

## Deliberately still open

At this checkpoint the repository does not contain the real
`store/google-play/` asset pack. Therefore this checkpoint does **not** close:

- final app icon / feature graphic / current RC screenshots;
- owner creative review or rights/provenance review;
- real support/contact fields;
- Play Console listing entry or preview;
- production signing, Play Billing configuration, public legal URLs or device QA.

The canonical Store listing gate remains `COPY READY / ASSETS + PLAY ENTRY REQUIRED`.
No release-ready claim is made by this checkpoint.
