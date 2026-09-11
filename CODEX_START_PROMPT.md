# Paste this into Codex after opening `C:\Users\joann\Releaf-Codex`

Read `AGENTS.md` first, then read:

- `docs/release/releaf_1_0_release_gate.md`
- `docs/CURRENT_STATE.md`
- `docs/PRODUCT_DECISIONS.md`
- `docs/DECISION_CONFLICTS.md`
- `docs/ROADMAP.md`
- `docs/CODEX_WORKFLOW.md`
- `docs/RESEARCH_INSIGHTS.md`
- `docs/plans/2026-09-11-releaf-1.0-completion-plan.md`

Use Superpowers throughout this work.

You are taking over an existing Releaf Flutter application. Do not restart it, do not rewrite working architecture for style reasons, and do not touch `main`. Work only from `releaf-development` (or a feature branch deliberately based on it if isolation is useful).

First perform a read-only repository audit and verify the current HEAD, working tree, architecture, existing release gate, tests, docs and relevant feature implementations. Then run the full automated baseline (`flutter pub get`, `flutter analyze`, `flutter test`, plus existing repo release checks that do not require private external secrets). Compare reality with `docs/CURRENT_STATE.md` and update the context docs if the repo has moved.

After the audit, continue the Releaf 1.0 completion plan in priority order. Do not stop just to ask me to repeat information that already exists in the repo/docs. Work in small verified batches. Use TDD for behavior changes and systematic debugging for failures. Before claiming completion, run the relevant verification.

Important:
- `docs/release/releaf_1_0_release_gate.md` is the canonical 1.0 engineering gate.
- Deep Research is strategic evidence, not permission to rebuild working features.
- Resolve known research-vs-repo conflicts according to `docs/DECISION_CONFLICTS.md`.
- Do not add games just to increase game count; there are already 15 registered Brain games.
- Sleep must remain narration-free at its core.
- Meditation uses the approved recorded Releaf Guide direction at 0.82× and separate voice/ambience layers.
- Do not silently substitute a narrator/provider voice.
- Do not enable cloud progress sync or claim cloud backup prematurely.
- Do not weaken Emergency-class access/privacy behavior.
- Never commit secrets or production signing credentials.
- Avoid medical/diagnostic/treatment claims.
- Manual phone testing is intentionally deferred during the engineering pass; batch it near RC, while keeping automated verification strong.

Proceed automatically on code/documentation work that is unblocked. Stop only when:
1. a real external credential/secret or store-console action is required,
2. a product-scope conflict in `docs/DECISION_CONFLICTS.md` requires owner choice,
3. a destructive/migration decision cannot be made safely from existing evidence.

At the end of every work batch report:
- what changed,
- files changed,
- tests/checks run and exact result,
- release gates affected,
- what remains,
- the next highest-priority task.

Goal: reach the point where the canonical release gate permits the exact statement:
**“Releaf 1.0 is release-ready.”**
