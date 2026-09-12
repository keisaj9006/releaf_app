# Local release artifact checks — 12 September 2026

Code checkpoint `6610634`, branch `releaf-development`. This is a targeted
post-implementation artifact verification, not a new repository audit or a
production-release PASS.

## Existing release contracts

`flutter test --no-pub test/google_play_store_listing_contract_test.dart test/device_release_qa_contract_test.dart test/account_deletion_web_resource_test.dart test/privacy_screen_test.dart test/revenuecat_release_key_policy_test.dart`:
**11 passed**, exit 0. No deletion or account operation occurred.

The previous code checkpoint's complete suite remains **517 passed**, analyzer
clean; see [SDK initialization evidence](2026-09-12-sdk-single-initialization.md).
No runtime code changed during this artifact check.

## Android

Current debug APK: `build/app/outputs/flutter-apk/app-debug.apk`.

- Size: 223822918 bytes.
- SHA-256: `58CDAEE4E289AD961662DD52D6EFB9A633B777665624EC333603E9611AC67E82`.
- Local equivalents of existing CI source checks passed: compile/target API 36,
  NDK 28.2.13676358, Billing permission, singleTop launch mode, and no release
  debug-signing fallback.
- `git check-ignore android/key.properties` passed. The private file was not read.
- `git diff --quiet -- pubspec.lock` passed after dependency resolution.

This is a debug/Test Store artifact, not a production AAB, store download size,
performance measurement or proof of release ELF/ZIP 16 KB alignment. Existing CI
release packaging checks and final private production signing remain required.
Last installed Samsung checkpoint is `abb98f7`; no installation repeated here.

## Web

`flutter build web --release`: built `build/web`, exit 0 (compilation 194.0 seconds).
The JavaScript release succeeded with Wasm dry-run warnings; no Wasm support
claim is made. All six existing workflow resource assertions passed:

- nonempty `index.html`;
- nonempty `main.dart.js`;
- nonempty `delete-account.html`;
- `href="/#/account"` present in the deletion resource;
- standalone-browser guidance present;
- server-only service-role identifier absent from the deletion resource.

The assertion command, final lockfile check and `git diff --check` exited 0.

No deployment/public URL, Play operation, credential change or owner audio
approval is implied by local artifact checks. All canonical external gates remain
open until their specific evidence is obtained.
