# Codex Workflow for Releaf

## 1. Session bootstrap

Run/inspect:

```bash
git status
git branch --show-current
git rev-parse --short HEAD
```

Expected branch: `releaf-development`.

Read the root `AGENTS.md` and canonical release gate before substantial work.

## 2. Choose work by priority

Priority order:

1. P0 regression.
2. Open canonical release gate.
3. External-release preparation that can be completed without secrets.
4. Content dependency blocking a finished flow.
5. QA/polish of current core flows.
6. Research-informed differentiation.
7. Optional expansion.

Never add optional scope while a higher-priority release regression is open.

## 3. Inspect before editing

Before changing a feature:
- find its canonical feature module,
- read its tests,
- read its relevant docs,
- distinguish current implementation from `legacy/`, `lib_backup/`, `_archive/` or stale tree dumps.

Do not “fix” a legacy file that is no longer routed.

## 4. Use Superpowers

### New behavior / changed product behavior
Use brainstorming first if the change is material.

### Feature / bugfix
Use TDD:
1. reproduce/specify expected behavior,
2. add/adjust failing test when practical,
3. implement smallest correct change,
4. run focused tests,
5. run broader regression checks.

### Failure / flake / unexpected behavior
Use systematic debugging:
- reproduce,
- isolate,
- identify root cause,
- avoid speculative patch chains.

### Completion
Use verification-before-completion.
Do not say PASS without running the command that proves it.

## 5. Verification ladder

Fast/local:
```bash
dart format --output=none --set-exit-if-changed <changed-dart-paths>
flutter analyze
flutter test <focused-test>
```

Broader:
```bash
flutter test
```

Release-related:
- use existing GitHub workflows/tooling/docs,
- verify Android build/AAB requirements,
- never fake production signing or store billing.

If formatting would modify files, format intentionally and include those changes rather than hiding them.

## 6. Audio changes

When touching Meditation/Reset/Sound/Sleep:
- verify session lifecycle,
- interruption/pause/resume,
- route/back behavior,
- mini/resume player state where relevant,
- independent narration/ambience semantics,
- timer/seek behavior,
- no accidental overlapping players,
- no Sleep narration.

For Releaf Guide:
- 0.82× reference,
- approved recorded voice only,
- no system TTS fallback,
- no guessed provider voice.

## 7. Brain changes

When touching a game:
- use canonical Brain host/result/registry,
- keep completion/progression integration,
- preserve result semantics and personal-best logic,
- test restart/back/lifecycle,
- test difficulty locking/reset behavior where applicable,
- do not create a separate competing game hub.

Do not add “Brain Age” or a pseudo-clinical global score.

## 8. Reset changes

Preserve:
- free Emergency-class access semantics,
- unknown-route guards,
- completion history,
- reduced-motion behavior,
- no unsafe default breathing patterns,
- no paywall before urgent basic relief.

Consumer copy can evolve independently of internal safety flags.

## 9. Backend / subscription

- never commit secrets,
- Supabase RLS/security remains mandatory,
- deletion must erase required external RevenueCat identity before Supabase auth deletion as current architecture specifies,
- progress sync stays inactive as a release claim until its hardened path is finished,
- RevenueCat production verification must happen through real Play-distributed billing.

## 10. Manual testing

The owner has deferred repetitive manual device testing during the build pass.

Do not interrupt every code batch with “please test this on your phone”.

Instead:
- keep automated tests strong,
- maintain a device-QA list,
- batch device checks at RC,
- call out only genuinely hardware-dependent risks.

## 11. Commit discipline

Prefer coherent small commits, for example:

- `fix(reset): ...`
- `fix(audio): ...`
- `feat(brain): ...`
- `feat(sleep): ...`
- `docs(release): ...`
- `test(meditation): ...`

Never mix unrelated refactors with a release-critical fix.

## 12. Batch report template

At the end of a batch:

### Completed
- exact behaviors/files changed.

### Verification
- commands run,
- exact pass/fail counts/results.

### Release impact
- gates closed/reopened/unchanged.

### External/manual dependencies
- only real dependencies.

### Next
- highest-priority next task.

## 13. When to stop

Stop for owner input only when:
- a secret/credential/account-specific action is required,
- a product conflict from `docs/DECISION_CONFLICTS.md` must be resolved,
- a destructive data/schema migration lacks evidence,
- an approved narrator/content asset decision is genuinely unavailable.

Do not ask questions whose answers already exist in code, docs or this context pack.
