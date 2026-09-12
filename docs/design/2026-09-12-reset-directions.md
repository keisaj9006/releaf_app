# Reset visual direction review

Six original vector studies are in [the contact sheet](2026-09-12-reset-directions.svg).
Status: **awaiting owner selection**, not runtime assets or approved production art.
Created directly as SVG paths for this project; no downloaded art, stock footage,
paid generation, audio, external fonts or linked resources. Colours follow
`lib/theme/releaf_design_tokens.dart`. These are central-visual studies, not
complete player screens or substitutes for the existing session shell.

| Direction | Intended character | Tradeoff |
| --- | --- | --- |
| L1 Botanical veins | Two leaf-like lobes, restrained vein detail | Recommended organic base; inspect for unwanted clinical associations |
| L2 Layered canopy | Nested contours express volume | More depth, but may look busy while moving |
| L3 Quiet outline | Outline with restrained fill | Least detail; useful reduced-motion base |
| G1 Window of attention | Prompts attention to the actual room | Recommended; illustration must never become the object-counting task |
| G2 Supported here | Contact at feet and ground | Appropriate for body-contact phases, not every sensory instruction |
| G3 Sensory stepping stones | Explicit count and completion marks | Appropriate for counting phases; taps must map to noticed items |

The depicted inhale countdown is an illustrative frame, not a new breathing
method. Implementation must consume the actual existing phase engine, retain all
ten methods and exact durations, keep holds stable/silent and freeze with the
session lifecycle. Initial envelope change should be 12–18%, tuned on device.
Reduced motion must retain a static outline, phase/time and non-moving progress.
No standalone decorative timer may drive the final breathing visual.

Grounding captions in this sheet illustrate different intervention states;
choosing a visual does not authorize replacing the current protocol. Preserve
immediate Continue/Skip and accessible semantics. The full shell retains exit,
audio controls and safety guidance. Final native touch targets must be at least
48 logical pixels, including secondary actions; the SVG is not interactive.

## Verification and next work

- SVG XML parsed; all six labels present; no scripts or linked resources.
- Browser rendered both rows; no clipping observed at the review viewport.
- Independent source review requested countdown, distinct Skip and larger primary
  buttons. All addressed; source review is not physical accessibility approval.
- No Dart, assets, breathing timings, narration or account data changed.
- `flutter analyze`: no issues, exit 0 (13.4 seconds); `git diff --check` passed.
  No new APK or full-suite rerun for this documentation-only batch.
- Owner chooses one L and one G direction (or requests revisions). Runtime
  implementation, motion/reduced-motion examples and Samsung review remain open.
- Existing 518-test application checkpoint is not new evidence for these visuals.

No audio approval is implied. Licensed natural breathing candidates, approved
narrator recovery and owner speaker/headphone listening remain separate gates.
