# Relief 1.0 RC automated checkpoint — 11 October 2026

## Candidate

- Branch: `releaf-development`
- App build-candidate SHA: `bf53e274136eef2d70c89cc0134be15b7cd7e4dc`
- Version/build: `1.0.0+20260913`
- Status: automated RC evidence complete; production signing, Play configuration,
  content approval and physical-device gates remain open.

This candidate supersedes the September `ecd3e97` pre-Play-upload candidate because
subsequent app-source changes materially affect the shipped build.

## Automated verification

Flutter P0 Validation run `38157339295`: **SUCCESS**.

Completed steps include:

- dependency lockfile verification,
- bundled sound audit,
- Android release-configuration audit,
- `flutter analyze`,
- focused Brain tests,
- Reset model, hub and access tests,
- full Flutter test suite,
- Relief Guide / Reset production-manifest export,
- RevenueCat configuration guard,
- standard Android debug APK build,
- Premium Preview Android debug APK build,
- release Android AAB smoke build,
- Android 16 KB compatibility verification.

Relief Web Release Smoke run `38157339291`: **SUCCESS** on the same SHA.

## Android artifacts

- Standard debug APK: artifact `11709835766`
- Premium Preview debug APK: artifact `11709621545`
- Release AAB smoke: artifact `11709032113`

The release AAB smoke artifact uses CI signing. It is **not** the production-signed
Google Play upload artifact.

## Product state captured by this candidate

- product branding is Relief in user-facing Android/iOS/web surfaces;
- Reset, Home, Sleep, Sound, Emergency and active Brain surfaces use the approved
  editorial-art system where integrated;
- all 15 canonical Brain games support persistent progression through level 50;
- eight approved dedicated Brain illustrations are mapped one-to-one to Memory, Labyrinth, Broken Mirror, Pattern Logic, Sequence Echo, Signal Scan, Trail Switch and Tower Plan; the remaining games retain their distinct procedural artwork;
- Emergency remains outside Premium and ordinary progress/sync semantics;
- Meditate remains parked outside the active 1.0 discovery/marketing surface;
- Sleep candidate `ST-DC-004` now references the existing Sleep Stories editorial artwork but remains unpromoted because production audio, measured duration/access decision, narrator provenance, rights/licence evidence and owner approval are still incomplete.

## Gates still open

This checkpoint does **not** close:

- production Android upload signing;
- real Google Play / RevenueCat product configuration and license-tester billing QA;
- final Sleep owner listening/content/rights approval;
- Google Play screenshots/feature graphic and console entry;
- Data Safety / health declaration submission;
- production-equivalent physical-device matrix;
- Play closed-testing requirements where applicable.

Do not report Relief 1.0 as release-ready until the canonical release gate records
those required external and device checks as closed.
