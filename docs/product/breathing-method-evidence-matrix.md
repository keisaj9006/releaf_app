# Breathing-method evidence matrix

Verified repository inventory, 12 September 2026, parent `0a43fdf`.
Source: `ResetCatalog` and its existing Reset narration manifest export.
This table records programmed timing, not measured user respiration or evidence
that a particular ratio is clinically effective. No methods are added or changed.

| Stable ID | Current title | Session seconds | Inhale s | Hold after inhale s | Exhale s | Rest after exhale s | Cycle s | Cycles/min |
|---|---|---:|---:|---:|---:|---:|---:|---:|
| equal-rhythm | 5–5 Balanced | 120 | 5 | 0 | 5 | 0 | 10 | 6.00 |
| 90s-calm-down | 4–6 Calm Rhythm | 90 | 4 | 0 | 6 | 0 | 10 | 6.00 |
| longer-exhale | Long Exhale Reset | 120 | 3 | 0 | 6 | 0 | 9 | 6.67 |
| box-breathing | Box Breathing | 120 | 4 | 4 | 4 | 4 | 16 | 3.75 |
| sleep-downshift | Sleep Downshift 4–7–8 | 120 | 4 | 7 | 8 | 0 | 19 | 3.16 |
| energy-up-breath | Energy Up Breath | 90 | 3 | 0 | 3 | 0 | 6 | 10.00 |
| focus-breath | Focus Breath | 120 | 4 | 0 | 4 | 0 | 8 | 7.50 |
| anxiety-slow-cycle | Anxiety Slow Cycle | 150 | 5 | 0 | 7 | 0 | 12 | 5.00 |
| wired-steady | Wired → Steady | 480 | 4 | 0 | 5 | 0 | 9 | 6.67 |
| 3min-breath | 3 min Deep Reset | 180 | 4 | 4 | 4 | 4 | 16 | 3.75 |

Cycles/min = 60 / sum of all four programmed phases, rounded to two decimals.
These are breathing cycles/minute, not music BPM or acoustic Hz. Session length
need not be a whole number of cycles; do not round or stretch it to fit a recording.

## Source discrepancy that must not change the app

The owner prompt mentions preserving 6–4. The actual ten-method catalogue has
**4–6**, with four-second inhale and six-second exhale, and no 6–4 method.
Preserve the implemented 4–6. Do not reverse it, relabel it as 6–4, or silently
create an additional method. Any deliberate new 6–4 method would require a
separate owner product decision; this does not block current methods.

## Audio, comfort and evidence status

- All ten methods retain exact phase timing, IDs and existing safety copy.
- Inhale and exhale require approved natural human recordings matched to each
  actual phase duration. The direction “slow exhale” cannot override this table.
- Hold/rest phases have no breathing cue. Optional ambience is separate; no
  synthetic hold sound, bell or tone is approved.
- Rejected existing cue assets remain ineligible for runtime playback. At least
  three original/licensed human candidates and owner listening on Samsung speaker
  and headphones remain open dependencies. No new recording is approved here.
- Per-method scientific evidence strength, measured narration WPM, music BPM,
  acoustic spectrum, LUFS/true peak and subjective comfort have not been newly
  established by this inventory. Retain existing research as contextual evidence;
  do not infer superiority of human recordings or clinical outcomes from timing.
- Keep stop/return-to-natural-breath guidance, silent mode and reduced-motion
  alternatives. Physical listening and production-equivalent QA remain required.

## Verification and maintenance

`test/reset_catalog_test.dart` and `test/reset_narration_manifest_export_test.dart`
verify the current catalogue/manifest contracts. The manifest at
`build/qa-manifests/reset-releaf-guide-manifest.json` supplies all ten timing rows.
When intentionally updating metadata, compare this table with a freshly exported
manifest. Existing method timing is locked; a documentation discrepancy is not
permission to change the breathing engine.
