# Releaf Guide — Narration Production Standard

Last reviewed: 2026-09-09

## Scope

This standard applies to **all guided Meditation and Reset content**, including
Emergency Calm. Reset and Meditation use one Releaf Guide contract and one
runtime voice driver.

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
- reference pace: **0.82×**

The selected narration provider is **ElevenCreative**. The approved reference
generation is `d730719be8654c93bddd639a96da7417`.

The exact provider voice ID was not preserved in the project record. Do not
batch-render the remaining library until that exact voice is recovered or one
replacement voice is explicitly locked as the new canonical Releaf Guide.
Never present a newly selected voice as if it were the approved original.

## Runtime behaviour

Meditation and Reset share the same `FlutterMeditationVoiceDriver`.

- recorded Releaf Guide assets always take priority;
- where recorded studio audio is unavailable, the development/runtime fallback
  prefers a calm female English voice and British English where available;
- fallback pacing is derived from the same **0.82×** contract;
- Reset voice guidance is enabled by default for new installs;
- Reset starts voice at a deliberately quieter default volume of **0.72**;
- a user's explicit voice-off preference is preserved.

The device fallback is not the recorded Releaf Guide and must never be labelled
as such.

## Reset breathing standard

All active breathing methods must use the single
`ResetSessionProgram.breathing` + `BreathPattern` engine. The catalog
currently contains **10** breathing sessions.

This guarantees one source of truth for:

- inhale duration;
- optional hold after inhale;
- exhale duration;
- optional hold after exhale;
- visual breath phase;
- future recorded phase cues and haptics;
- session narration timing.

Every active Reset session has a scripted program. The same step guidance shown
on screen is currently the spoken Reset script, so the audible and visual
instruction cannot silently diverge.

## Audio layering

Narration and ambience are separate production layers.

Do:

- render dry narration to its own MP3 asset;
- keep ambience controlled by the app so volume can be mixed independently;
- let the player prefer recorded Releaf Guide audio over device voice fallback.

Do not:

- bake music or soundscape audio into the narration file;
- use a different narrator for individual sessions;
- add narration to Sleep;
- label device TTS as recorded Releaf Guide.

## Canonical asset naming

Meditation:

`assets/narration/releaf-guide/<session-id>/<NN>-<step-label>.mp3`

Reset:

`assets/narration/releaf-guide/reset/<session-id>/<main|simplified>/<NN>-<step-label>.mp3`

The app stores paths without the leading `assets/` prefix.

## Production manifests

Every P0 build exports two narration manifests:

- `releaf-guide-manifest.json` from `MeditationCatalog`;
- `reset-releaf-guide-manifest.json` from `ResetCatalog`.

The Reset manifest covers all **50** active Reset sessions, including Emergency,
and verifies that all **10** breathing methods use the canonical paced-breathing
engine.

The manifests contain the canonical script, timing, target asset path, recorded
asset path and render status. Do not maintain a second manual spreadsheet with
competing narration copy.

## Script and timing QA

Recorded timing must be checked against the actual rendered MP3, not inferred
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
- voice source label accurately distinguishes recorded audio from fallback.

## Current production state

- Guided Meditation scripts: **20 / 20 complete**
- Active Reset scripted sessions: **50 / 50 complete**
- Canonical Reset breathing sessions: **10 / 10**
- Fully recorded Meditation sessions: **Mindfulness Basics**
- Recorded Reset sessions: **0**
- Remaining studio rendering is blocked only by the missing exact provider voice
  identity; runtime fallback remains available for development and testing.
