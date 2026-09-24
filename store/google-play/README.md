# Releaf Google Play asset pack

## App icon provenance

`app-icon.png` is a mechanical derivative of the existing Releaf launcher source:

- source: `assets/icon/app_icon.png`;
- source SHA-256: `9D44B42A62268FA2B9ED79C92C3F245A5DC451F1B8DFAFC1BD3648D77029CAB2`;
- transformation: high-quality 2:1 resize from 1024 × 1024 to 512 × 512 and
  conversion from 24-bit RGB to 32-bit RGBA;
- output SHA-256: `664DB6910FBEB90AB849389204BD98A9521FF9F56E45D7BCF4018FA3726400AE`;
- output size: 165,458 bytes.

The transformation does not introduce new artwork, wording, claims, badges or
third-party material. `tool/release/build_play_store_icon.ps1` refuses to derive
the icon if the source hash changes without review.

This file records technical provenance and structural readiness. It does not
approve the remaining Store pack or replace owner review of the Play listing.

## Still required

- final 1024 × 500 feature graphic;
- at least four current portrait screenshots from the exact release candidate;
- owner creative review and Play Console preview.
