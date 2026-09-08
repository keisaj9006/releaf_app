# Releaf Guide — Narration Production Standard

Last reviewed: 2026-09-08

## Scope

This standard applies to guided Meditation narration and later guided
Reset/Emergency content that intentionally uses the same Releaf Guide.

It does **not** apply to Sleep. Sleep remains audio-only: music, noise and
nature soundscapes without narration.

## Locked voice direction

Use one narrator consistently across the guided library.

- female voice
- British-English feel
- natural, warm and calm
- intimate without whispering
- premium meditation delivery
- no ASMR treatment
- no obvious synthetic cadence
- reference pace: **0.75×**

The exact provider voice ID was not preserved in the project record. Do not
batch-render the remaining library until that exact voice is recovered or one
replacement voice is explicitly locked as the new canonical Releaf Guide.

## Audio layering

Narration and ambience are separate production layers.

Do:

- render dry narration to its own MP3 asset;
- use the Meditation session's `backgroundSoundId` for ambience;
- keep ambience controlled by the app so volume can be mixed independently;
- let the player prefer recorded Releaf Guide audio over device voice fallback.

Do not:

- bake music or soundscape audio into the narration file;
- use a different narrator for individual sessions;
- add narration to Sleep;
- label device TTS as recorded Releaf Guide.

## Canonical asset naming

Each recorded step uses:

`assets/narration/releaf-guide/<session-id>/<NN>-<step-label>.mp3`

Examples:

- `assets/narration/releaf-guide/mindfulness-basics-2/01-arrive.mp3`
- `assets/narration/releaf-guide/mindfulness-basics-2/02-notice.mp3`

The app stores the path without the leading `assets/` prefix.

## Production manifest

Every P0 build exports:

`releaf-guide-manifest.json`

The manifest is generated directly from `MeditationCatalog` and contains:

- all guided sessions;
- every spoken narration script;
- step duration;
- word count for production reference;
- canonical target MP3 path;
- currently recorded asset path;
- whether a step still needs rendering.

The manifest is the source package for narration production. Do not maintain a
second manual spreadsheet containing competing scripts.

## Script and timing QA

The written `spokenGuidance` is narration copy. The shorter `guidance`
field remains on-screen caption copy.

Recorded timing should be checked against the actual rendered MP3, not inferred
from word count alone. Delivery is intentionally slow and uses pauses.

For each step:

- narration must fit comfortably inside the step duration;
- leave useful silence after spoken guidance where the practice benefits from it;
- avoid rushing to force a long script into the allocated step;
- if the script does not fit naturally, edit the script or step timing before
  accepting the asset.

## Technical QA

Before an asset is declared recorded:

- file exists at the canonical path;
- MP3 decodes successfully;
- no clipping;
- no baked ambience;
- no abrupt cut at the final word;
- no excessive leading silence;
- pronunciation and British-English delivery are consistent;
- captions and spoken meaning remain aligned;
- voice source label in the app accurately reflects recorded vs fallback audio.

CI already verifies that any declared `narrationAssetPath` exists and contains
non-trivial audio.

## Current production state

- Guided meditation scripts: **20 / 20 complete**
- Fully recorded sessions: **Mindfulness Basics**
- Remaining sessions: script-ready, awaiting the canonical Releaf Guide voice
  identity before batch rendering
