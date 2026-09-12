# Resumed programme verification — 12 September 2026

Code checkpoint: `b4ca786`, following `16a0f2c` exclusively on
`releaf-development`.

## Implemented checkpoints

- `1333340`: Reset cancels pending Sound on entry and lifecycle return.
- `9d316be`: Reset ambience cancellation on mute/background/exit; safe rapid return.
- `13f6ada`: Memory Mirror fifty-level profiles, progression and charts; pending
  pair reset/timeout protection. Legacy difficulty, save keys and rewards retained.
- `b4ca786`: subscription async results cannot cross an account identity boundary.

Latest complete suite: **467/467 passed**. Latest analyzer: **no issues**.
Independent reviews were completed; their identified gaps were fixed and tested.
See each dated milestone evidence file for red/green and focused test results.

## Local artifacts and release checks

`flutter build apk --debug
--dart-define-from-file=tool/local/revenuecat-test-store.json` passed.

APK: `build/app/outputs/flutter-apk/app-debug.apk`

- Bytes: **223813777**
- SHA-256: **9960C249B0EEF162F37396DB924DC7312EE3709FAA5D5258CB8FEFB8C47D0B94**
- Ignored local configuration retained; no key value printed or committed.
- Repeated `adb devices -l`: **no devices attached**. No APK installation or
  physical smoke test performed during these resumed milestones.

`flutter build web --release` passed (compilation 310.1s). Existing
`flutter_web_release_smoke.yml` resource assertions were reproduced locally:

- nonempty `index.html`, `main.dart.js`, `delete-account.html`;
- account route link and standalone web deletion guidance present;
- server-only service-role identifier absent from the public deletion page.

All six assertions passed. This is an artifact check, not deployment or account
deletion. Web compilation emitted Wasm dry-run warnings; the JavaScript release
artifact succeeded. Android toolchain future-support warnings remain unchanged.

`git diff --check` passed. Tracked-file checks found no `android/key.properties`,
JKS, keystore, P12 or `.env` files. No signing configuration was replaced.
Native/16 KB production packaging checks remain in existing CI/release workflows;
this debug build does not establish a production-signing or distribution PASS.

## Remaining work

Owner listening (including Atmosphere II), approved missing narration/breathing
content, long-duration playback and physical Memory/Labyrinth quality remain
pending. No audio approval is inferred from automated tests. The production
signing, Play billing/distribution, public resources, store declarations and
production-equivalent device matrix remain canonical external gates.

Bounded follow-on inspection found no additional demonstrable Sleep/Sound defect
or new local release blocker. Progress/personalisation/mascot and further polish
remain programme tracks, not a claim that every possible internal enhancement is
exhausted. Preserve existing identity and reward semantics when selecting further
concrete work. No purchases, real account operations, deployments or publication
were performed. Releaf 1.0 is not yet release-ready.

Final focused release contracts: flutter test --no-pub test/device_release_qa_contract_test.dart test/revenuecat_release_key_policy_test.dart — 5/5 passed.
