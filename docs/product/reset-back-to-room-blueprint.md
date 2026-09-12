# Back to the Room — current implementation and next acceptance

Source: `ResetCatalog`, `ResetSessionProgram`, `BreathingWidget`, 12 September 2026.
Stable ID `back-to-room`; free No-Breath grounding; not Emergency-class.
Purpose: orient attention toward available, comfortable details in the room.
This is a product description, not evidence of treatment efficacy.

## Preserved programme

| Full path step | Programmed seconds | User action |
|---|---:|---|
| Arrive | 15 | Look around the space |
| See | 45 | Notice five things |
| Feel | 40 | Notice four physical sensations |
| Hear | 30 | Notice three sounds |
| Smell | 25 | Notice or imagine two familiar scents |
| Taste | 15 | Notice or imagine one familiar taste |
| Return | 10 | Notice the room again |

Full duration: 180 seconds. Existing simplified path: See 20 seconds / three
things, Feel 20 seconds / two sensations, Hear 20 seconds / one sound. Total 60
seconds. Completing a sensory count advances early; these are existing maximum
step allocations, not imposed breathing rhythms. Breath phases and cycles/minute
are not applicable. No breathing pattern is changed by this milestone.

## Interaction and safety

The sensory halo counts notices. On reaching the target, advance immediately;
do not retain a delayed callback that could act on a different step or path.
Preserve the existing simplify control, pause/resume, exit and completion flow.
Copy already permits comfortable/available senses and skipping smell or taste.
Implemented: Arrive offers `Ready to begin`; sensory steps in both paths offer
`Skip this sense`; Return offers `Finish practice`. No-words mode exposes the
arrow with its screen-reader label but no visible instruction text. The sensory
session scrolls when needed, preserving access at narrow widths and large text.

No new audio is introduced. Approved narration only, no fallback voice. Breathing
cues are not applicable. Optional background sound remains an independent layer;
new music BPM, spectrum, loudness and voice WPM measurements are not established.
Do not infer approval, scientific advantage or audio measurements from this file.

## Acceptance

- Count completion changes the visible next instruction on the next frame.
- Two rapidly completed sensory steps do not queue a later extra transition.
- Existing simplified-path interaction, access, Emergency privacy and reward
  contracts continue passing.
- Skip controls pass full-path widget tests at 320px with 2x text and reduced
  motion, with and without visible guidance. Existing simplified-path tests pass.
- Remaining: physical screen-reader/interaction review and owner comfort review;
  broader per-card blueprints and interrupted progression checks remain open.
- Device observations are separate from owner comfort/listening approval.
