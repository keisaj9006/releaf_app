# Versioned What’s New Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Show a release-specific, accessible “What’s New” screen once on ordinary Home launch without intercepting explicit routes or Emergency access.

**Architecture:** Replace the permanent Home intro Boolean with a namespaced release acknowledgement controller. Keep routing intact and compose the gate at Home so non-Home initial locations and deep links bypass it automatically.

**Tech Stack:** Flutter, Dart, Riverpod, SharedPreferences, go_router, `flutter_test`.

**Spec:** `docs/superpowers/specs/2026-09-24-releaf-content-readiness-and-progression-design.md`

## Global Constraints

- Existing routes and navigation remain unchanged.
- Explicit deep links, auth recovery and Emergency access are never delayed.
- Preference read/write failure falls back safely and does not corrupt other settings.
- The screen works at 320 dp and 200% text scale with screen-reader semantics.
- Release copy does not make medical claims or lead with subscription marketing.

## Review Focus

- An old acknowledged release must not hide a newer release.
- A failed acknowledgement write must still enter Home during the current session.
- Direct `/relief`, player and auth routes must not render What’s New.
- Rebuilding Home in the same session must not reopen the screen after Continue.
- Large text must keep the Continue action reachable by scrolling.

---

### Task 1: Versioned acknowledgement controller

**Files:**
- Create: `lib/features/home/whats_new_content.dart`
- Create: `lib/features/home/whats_new_store.dart`
- Modify: `lib/features/home/home_personalization.dart`
- Test: `test/whats_new_controller_test.dart`

**Interfaces:**
- Produces: `WhatsNewContent.current`, `WhatsNewStore`, `SharedPreferencesWhatsNewStore`, `WhatsNewController`, `whatsNewProvider`, state `WhatsNewState(show: bool, releaseId: String)`.
- Consumes: existing `sharedPreferencesProvider`.

- [ ] **Step 1: Write failing persistence tests**

Test empty preferences, same release acknowledged, older release acknowledged, repeated `acknowledge()` and a write returning false through an injected `WhatsNewStore`.

```dart
expect(controller.state.show, isTrue);
await controller.acknowledge();
expect(controller.state.show, isFalse);
expect(store.lastAcknowledgedRelease, WhatsNewContent.current.releaseId);
```

- [ ] **Step 2: Run and observe missing types**

Run: `flutter test test/whats_new_controller_test.dart`

- [ ] **Step 3: Implement the release record and controller**

Use the key `releaf.whats_new.last_acknowledged.v1`. `acknowledge()` updates in-memory state first, then attempts persistence. Give `releaseId` one explicit value for this release; do not infer it at runtime from user-controlled data.

```dart
abstract interface class WhatsNewStore {
  String? readLastAcknowledgedRelease();
  Future<bool> writeLastAcknowledgedRelease(String releaseId);
}
```

- [ ] **Step 4: Retire the generic intro state without removing focus selection**

Remove `HomeIntroController` and `homeIntroProvider`. Keep `HomeFocusController`, its storage key and all focus values unchanged.

- [ ] **Step 5: Verify and commit**

Run: `dart format lib/features/home/whats_new_content.dart lib/features/home/whats_new_store.dart lib/features/home/home_personalization.dart test/whats_new_controller_test.dart`

Run: `flutter test test/whats_new_controller_test.dart test/home_hub_test.dart`

Commit: `feat(home): add versioned whats new state`

### Task 2: Accessible Home entry presentation

**Files:**
- Create: `lib/features/home/whats_new_screen.dart`
- Modify: `lib/features/home/home_screen.dart`
- Test: `test/whats_new_screen_test.dart`
- Modify: `test/home_hub_test.dart`

**Interfaces:**
- Consumes: `whatsNewProvider` and `WhatsNewContent.current`.
- Produces: `WhatsNewScreen(onContinue: Future<void> Function())`, key `whats-new-continue`.

- [ ] **Step 1: Write failing widget tests**

Assert first Home launch shows the heading and change items; Continue shows Home and persists acknowledgement; subsequent pump skips it. Add 320 dp/200% text and semantics assertions.

- [ ] **Step 2: Write direct-route bypass tests**

Create routers with `initialLocation` for Reset, Sleep, Brain, account and a session route. Assert `WhatsNewScreen` is absent and the requested destination is present.

- [ ] **Step 3: Run tests and confirm failure**

Run: `flutter test test/whats_new_screen_test.dart test/home_hub_test.dart`

- [ ] **Step 4: Implement the presentation and Home gate**

At the top of `HomeScreen.build`, return `WhatsNewScreen` only while `ref.watch(whatsNewProvider).show` is true. Build the screen with `SafeArea`, `SingleChildScrollView`, semantic headings and a full-width Continue button. Remove `_HomeWelcomeCard`; keep personalization reachable through its existing Home settings/action.

- [ ] **Step 5: Verify route, accessibility and full-suite behavior**

Run: `dart format lib/features/home test/whats_new_screen_test.dart test/home_hub_test.dart`

Run: `flutter test test/whats_new_screen_test.dart test/home_hub_test.dart test/primary_wellbeing_tabs_test.dart test/story_player_route_test.dart`

Run: `flutter analyze`

Run: `flutter test`

- [ ] **Step 6: Record evidence and commit**

Update `docs/CURRENT_STATE.md` and `docs/ROADMAP.md` with the release ID, bypass behavior and test result.

Commit: `feat(home): show release updates once`
