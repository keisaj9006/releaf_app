# Releaf Public Web Release Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Publish the existing Releaf Flutter Web release and external account-deletion resource at a stable public HTTPS URL without duplicating account-deletion logic or reopening product scope.

**Architecture:** Build the existing Flutter Web app from `releaf-development` in GitHub Actions and deploy the generated `build/web` directory to GitHub Pages. Use the Pages-provided base path for the Flutter build, then make the generated external deletion resource link relatively to `#/account` so the same authenticated account flow works under a repository sub-path as well as a root host.

**Tech Stack:** Flutter 3.47.2, GitHub Actions, GitHub Pages, `actions/configure-pages`, `actions/upload-pages-artifact`, `actions/deploy-pages`.

**Spec:** `docs/release/releaf_1_0_release_gate.md`

## Global Constraints

- Work only on `releaf-development`.
- Releaf 1.0 remains `1.0.0+20260913` for the current RC.
- Do not create a second account-deletion implementation; reuse the existing authenticated `#/account` flow.
- Do not expose service-role keys, upload keystores, RevenueCat secrets, or other credentials.
- Do not reintroduce parked Meditate into the active 1.0 surface.
- Do not touch store graphics or add optional product scope.
- The public deletion resource must work without the Android app installed.

---

### Task 1: Public Flutter Web Pages deployment

**Files:**
- Create: `.github/workflows/flutter_web_pages.yml`
- Modify after successful deployment evidence: `docs/release/releaf_1_0_release_gate.md`

**Interfaces:**
- Consumes: existing Flutter web app and `web/delete-account.html`.
- Produces: a stable HTTPS Pages deployment where `delete-account.html` routes to the same Flutter `#/account` authenticated flow.

- [ ] **Step 1: Add deployment contract checks before deployment**

The workflow must verify after `flutter build web --release` that:

```bash
test -s build/web/index.html
test -s build/web/main.dart.js
test -s build/web/delete-account.html
grep -Fq 'href="./#/account"' build/web/delete-account.html
! grep -Fq 'SUPABASE_SERVICE_ROLE_KEY' build/web/delete-account.html
```

- [ ] **Step 2: Build with the GitHub Pages base path**

Use `actions/configure-pages@v5` and build with:

```bash
flutter build web --release --base-href "${{ steps.pages.outputs.base_path }}/"
```

- [ ] **Step 3: Make only the generated deletion link host-portable**

After the build, replace the build-output-only root link:

```bash
sed -i 's|href="/#/account"|href="./#/account"|' build/web/delete-account.html
```

Do not change the authenticated account-deletion implementation.

- [ ] **Step 4: Upload and deploy the exact verified build**

Use `actions/upload-pages-artifact@v4` for `build/web`, then `actions/deploy-pages@v4` in the `github-pages` environment with `pages: write` and `id-token: write` permissions.

- [ ] **Step 5: Verify the workflow result**

Expected: Pages build and deployment jobs both pass, and the deployment reports a public HTTPS URL.

- [ ] **Step 6: Live smoke the public resource**

Verify the public `delete-account.html` loads, its CTA resolves to the deployed Releaf `#/account` route, and the page does not expose secrets. Do not perform destructive account deletion during this hosting smoke; DQA-18 remains part of the final production-equivalent device matrix.

- [ ] **Step 7: Update canonical release-gate evidence**

Only after live verification, change the public-web gate from `CODE READY / PUBLIC DEPLOY REQUIRED` to the precise verified status and record the live HTTPS URL/evidence. Do not mark Privacy Policy, production signing, RevenueCat/Play billing, Store Assets, Play Console, or final device QA closed.
