# Shared paced-breathing clock

This follows the approved canonical master's actual-phase visual requirement.
It does not select botanical art or authorize audio. The existing countdown-only
checkpoint does not satisfy shared timing.

## Evidence and scope

BreathingWidget `_startTimer` decrements remaining seconds while Living Form
repeats its own AnimationController. Lifecycle pause preserves the latter's
fractional value but recreates a whole-second session deadline. Phase text and
motion can consequently diverge. Keep guided sensory/movement timing unchanged;
limit the new clock to `ResetProgramType.pacedBreathing`.

## Implementation sequence

1. Reproduce fractional lifecycle pause/resume divergence in the actual widget.
   Cover unequal phases and holds, no-background-frame delivery, and completion.
2. Give the parent paced-breathing session one elapsed-time source, retaining
   fractional progress across pause. A Flutter ticker/controller is viable only
   with `AnimationBehavior.preserve`: system reduced motion must never accelerate
   the session clock. Drive countdown and existing phase frame from that source.
3. Pass canonical cycle progress to Living Form; it must stop its independent
   breathing clock when external progress is supplied. Preserve non-breathing
   visuals. Avoid whole-screen rebuilding at display frequency where practical.
4. Derive visible shape, phase label, phase countdown and cue dispatch from the
   same elapsed state. Preserve all ten ratios, IDs, held-phase stability and
   disabled unapproved cue policy. Do not claim sample-accurate audio scheduling.
5. Test normal/reduced/no-words modes, lifecycle, duration/completion, silent
   holds and cancellation. Independently review. Run analysis, full suite and
   configured Android build; install only if Samsung is available, using `-r`.
6. Document actual evidence, unresolved hardware behavior and owner-selection
   dependencies, then commit/push only releaf-development.

Do not change rewards, Emergency access or production credentials. No new
breathing method, duration, narration or audio asset is part of this work.
