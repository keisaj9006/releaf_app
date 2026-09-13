# Releaf 1.0 RC version checkpoint — 13 September 2026

This evidence note records the first frozen Releaf 1.0 release-candidate version.

- Branch: `releaf-development`
- Version: `1.0.0+20260913`
- Version commit: `bda3184860b0e326aa438c8589ff05aba5adf088`
- Flutter P0 Validation: run `34785227381` — SUCCESS
- Releaf Web Release Smoke: run `34785227347` — SUCCESS
- Web artifact: `releaf-web-release-smoke`, artifact `10325849055`
- Web artifact digest: `sha256:c2698b1dcea3c08a1bd6c9a10b681f231190d01846e747755808ffd0c1b2dc41`

The P0 run passed analysis, the full Flutter test suite, targeted Brain and Reset gates, production-manifest exports, RevenueCat configuration policy checks, standard and Premium Preview debug APK builds, release AAB smoke build and Android 16 KB compatibility validation.

This checkpoint closes only the engineering version-freeze step. It does not close production signing, real Google Play/RevenueCat configuration, public legal hosting, Store listing assets/screenshots, owner audio review, physical-device RC QA or Play closed testing.

Subsequent code may retain version `1.0.0` while increasing the build number if another RC build is required before store upload.

## Current verification candidate

Home discovery was tightened after the version freeze so the parked Meditate surface is no longer suggested automatically from Home while its direct route and explicit active-session resume path remain available. Sound discovery is aligned with the same release boundary: Sound links to the active Sleep pillar but no longer advertises or routes users into parked Meditate. The Meditate module and direct route remain intact.

Current candidate code/test checkpoint: `3ac8bba29b73916880015d4837af2bffb4912c59`. Stale legacy Sound tests have been aligned with the approved parked-Meditate boundary. This note records the candidate only; the Home + Sound parking boundary is not considered fully verified until the fresh branch P0 and web smoke workflows complete successfully.
