# Meditate / Reset remediation

Authority: [owner-corrected master prompt](2026-09-12-releaf-master-prompt.md),
the canonical release gate and locked product decisions. Continue from current
`releaf-development`; do not repeat the completed repository audit.

## 1. Premium access propagation — committed as `f3a8795`

Already present: configured SDK, stable internal identity, exact `premium`
entitlement lookup, annual/monthly offerings and purchase/restore calls.
Package buttons invoke purchase directly; selecting one is not a separate
plan-selection step. Do not tap one on the device without transaction approval.

Reproduced defects: a valid CustomerInfo response waited for offerings before
updating access; a delayed refresh could overwrite a newer entitlement event;
all three premium session gates disposed entitled players during refresh.
Fix these with early CustomerInfo propagation, stale-response protection and
retention of the same entitled player during refresh. Account changes still
clear access immediately. Tests must exercise real gates and async ordering.

This does not establish the cause of the owner's reported transaction issue.
No purchase, entitlement grant or store configuration mutation is authorized.

## 2. Five primary destinations — verified

Exact order: Home / Reset / Meditate / Sleep / Brain. Reuse existing screen
implementations in the indexed stateful shell. Preserve `/meditate`, `/sleep`,
`/sound` and player deep links; retain the existing Sound collection as a
secondary destination so favourites/recent tracks remain reachable.

Before implementation add route/UI tests for exact tab order, selected state,
branch restoration, legacy links, back navigation, session resume and narrow
200% text layouts. Preserve account and Emergency access. Use existing feature
accents; do not create new visual identities or change session access rules.

Implemented: eight route/restoration/large-text tests, retained Sound library,
Emergency/account shortcuts, and targeted Sleep/Brain/Reset layout fixes exposed
by 320px/2x tests. Linear and nonlinear scaling plus nonzero readability overlays
are covered. Independent review findings were reproduced and corrected.
Final verification: 482 tests, clean analysis, Android debug build and Samsung
`adb install -r` passed; bounded five-screen smoke and SDK identity/Offering logs
confirmed. See [checkpoint evidence](../release/2026-09-12-five-primary-destinations.md).

## 3. Meditation completeness

Inventory existing cards against their actual scripts, caption timelines,
recording manifests, preview metadata and player controls. Extend existing
availability/caption tests rather than duplicating them. Missing approved
narration remains honestly labelled; do not substitute the narrator.

## 4. Reset flagship

Create the breathing-method evidence matrix and per-session blueprints from the
actual catalog/programs before changing presentation. Preserve every phase
duration, stable ID, order and reward/access rule. Prioritize immediate labelled
grounding progression, clarity, silent/reduced-motion modes and lifecycle safety.
Natural breathing candidates require documented provenance and owner listening;
hold/rest contain no breathing cue. No synthetic substitute is permitted.

## Checkpoint acceptance

For each coherent change: reproduce with tests, implement, focused tests,
formatting, clean analysis, complete suite, independent review and Android debug
build with the ignored local Test Store config. Inspect the diff, update evidence,
commit and push only `origin/releaf-development`. When connected, update Samsung
only with `adb install -r`; never uninstall. Record actual device observations
separately from automated evidence and owner listening approval.

## External dependencies that do not stop independent work

Approved narrator identity/recordings; at least three licensed/original human
breathing candidate recordings and owner audition on speaker/headphones;
Atmosphere II owner listening; long-duration and production-equivalent device
QA; production signing, Play billing/distribution, public legal resources and
store-console actions. Do not close these gates based on internal tests.
