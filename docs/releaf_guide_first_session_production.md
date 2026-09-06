# Releaf Guide — First Production Session

## Status

Prepared for production on 6 September 2026.

Session: `mindfulness-basics-2` — **Mindfulness Basics**  
Duration: 2 minutes  
Access: Free  
Guide: owner-selected Releaf Guide voice  
Canonical generation speed: **0.75x**  
Ambience: `deep-drift` at in-app mix level `0.18`

The voice and ambience must remain separate assets. Do not bake ambience into the narration files.

## Generation settings

Locked:
- selected Releaf Guide voice
- speed: **0.75x**

Starting QA baseline:
- stability: around 0.50–0.60
- similarity: around 0.75
- style exaggeration: 0
- speaker boost: on when it improves clarity without making the voice sound processed

Only speed is product-locked here. The remaining values may be tuned slightly per generation to preserve the same natural voice identity.

## Asset contract

Generate four isolated narration files:

1. `assets/narration/releaf-guide/mindfulness-basics-2/01-arrive.mp3`
2. `assets/narration/releaf-guide/mindfulness-basics-2/02-notice.mp3`
3. `assets/narration/releaf-guide/mindfulness-basics-2/03-return.mp3`
4. `assets/narration/releaf-guide/mindfulness-basics-2/04-finish.mp3`

The Flutter `AssetSource` path stored in content data omits the leading `assets/` prefix.

## Narration script

### 01 — Arrive

Let your eyes close if that feels comfortable.

Notice the places where your body is already supported by the surface beneath you.

There is nothing to fix right now.

Give yourself a few moments simply to arrive.

### 02 — Notice

Bring your attention to one simple sensation.

It might be the feeling of your feet, your hands, or the breath moving naturally.

Stay with that one sensation for a little while, without trying to make it stronger or calmer.

### 03 — Return

At some point your attention will move away.

That is part of the practice, not a mistake.

When you notice that you are thinking, planning, or listening to something else, gently return to the sensation you chose.

### 04 — Finish

Now let your attention widen again.

Notice the whole body, the sounds around you, and the room you are in.

There is no need to decide whether the meditation went well.

Just notice that you took these two minutes for yourself.

## Delivery direction

- warm, grounded British-English female delivery
- slow and intimate, but not whispering
- no advertising or podcast cadence
- no exaggerated emotion
- sentence endings should fall naturally
- do not rush commas or lists
- leave the session timer to create longer practice silence
- do not add spoken countdowns or filler that are absent from the script

## QA gate

Reject/regenerate any segment if:
- the voice identity noticeably changes between segments
- 0.75x introduces slurring, metallic stretching, or unnatural vowels
- a sentence becomes sing-song or obviously synthetic
- consonants disappear at low volume
- the delivery sounds parental, clinical, dramatic, sleepy, or ASMR-like
- any word is mispronounced
- the final file contains ambience, music, UI sounds, or clipping

Once all four MP3s pass QA, the app should use them automatically and retain system TTS only as a fault-tolerant fallback.
