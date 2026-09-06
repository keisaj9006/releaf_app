# Releaf Meditate — Audio & Voice Quality Bar

## Product target

Meditate must feel like a premium audio-led practice, not a timer with text-to-speech layered on top.

The screen supports the session, but the session must remain usable with eyes closed.

## Benchmark principles

### Voice
- One recognisable Releaf Guide voice should anchor the core meditation library.
- Default production voice: female, warm, grounded, calm, non-performative.
- No rushed delivery, radio-style emphasis, sales tone, exaggerated breathiness, or robotic cadence.
- The delivery should prioritise phrasing and silence over continuous speech.
- Silence is part of the instruction. Do not fill every second with narration.
- Short sessions may be more guided; longer/deeper practices should progressively allow more silence.
- Narration should be mastered consistently across sessions.

### Current implementation vs production target
- Current Android/iOS TTS remains a temporary fallback.
- Releaf must not depend on whichever system voice a user's device happens to select.
- Production target: pre-rendered Releaf narration assets with one approved female guide voice.
- The player architecture should allow a recorded track to replace TTS without changing session UX.
- TTS fallback should still prioritise an English female high-quality/network voice when one exists.

### Pace
- Spoken guidance must be materially slower than conversational speech.
- Prefer short sentences and natural phrase boundaries.
- Use deliberate pauses between sentences.
- After an instruction, leave enough quiet time for the user to actually perform it.
- Session pacing should eventually support profiles such as:
  - settle / beginner
  - standard
  - deep practice
  - sleep / lying down
- Posture and session intent may later influence pause length and guidance density.

## Background audio

### Non-negotiable rules
- No vocals.
- No lyrical content.
- No obvious song structure.
- No abrupt intros/outros.
- No sharp transients, notification-like sounds, sudden percussion, or dramatic drops.
- No unverified third-party audio.
- Audio must be owned, licensed, or generated specifically for Releaf.
- Loops must be seamless enough that repetition is not obvious during a meditation.

### Default hierarchy
1. Narration is always primary.
2. Background audio is supportive and low in the mix.
3. Users may independently control guide volume and ambience volume.
4. Background audio should continue smoothly through narration pauses.
5. Pausing a meditation should pause/fade both layers gracefully.

### Current safe fallback beds
- Deep Drift — slow tonal pad, suitable as the default neutral meditation bed.
- Night Air — sleep/evening sessions.
- Soft Rain — optional environmental alternative, not the universal default.
- Noise tracks — optional user-selected layers, not the main meditation identity.

The legacy Releaf Atmosphere I/II tracks must not be used as automatic meditation defaults until their content is re-audited.

## Session writing

- Write for listening, not reading.
- One instruction at a time.
- Avoid dense multi-clause sentences.
- Avoid explaining theory while the user is meant to practise.
- Use permissive language where appropriate: “if it feels comfortable”, “notice”, “allow”, “return”.
- Do not promise clinical outcomes.
- For eyes-closed use, important instructions must be audible and must not depend on captions.

## Visual support

- Every meditation player must have a subtle living visual layer.
- Motion must be slow and low-stimulation.
- Reduced Motion must remain respected.
- Visuals should not compete with the voice.
- Avoid dashboard-like density during an active session.

## QA before a meditation is considered premium-ready

### Voice QA
- female voice confirmed
- no male fallback selected when a female English option exists
- calm pace on a real Android device
- sentence pauses feel intentional
- no clipped phrases
- no unexpected TTS engine switching
- pronunciation reviewed

### Audio QA
- correct bundled asset is playing
- no vocals / song-like material
- narration remains intelligible
- loop seam is not distracting
- pause/resume does not restart abruptly
- ambience does not continue after session exit

### Experience QA
- usable with eyes closed
- session instructions match session length
- sufficient silence exists after instructions
- visual motion appears on every meditation category
- captions remain optional
- seek/resume behaviour remains coherent

## Daily Insight continuity

Daily Insight remains a separate Home benefit:
- exactly one evidence-informed insight per day
- visible on the first Home screen
- no archive/history feed of previous daily insights
- sources and evidence notes remain accessible
- it stays secondary to the core “Right Now” wellbeing actions
