# Batch A: opt-in suggestions, reflection review and next step

- Recorded: 2026-10-25 23:22:00 +11:00; Australia/Sydney
- Agent / role: Claude Code (implementer), on Mike's Mac
- Status: completed; merged under Mike's auto-merge-when-green rule
- Base revision and branch: `codex/guest-suggestions` from `main` at `4879f01`
- Related record / task / PR: [gap analysis](../product/original-vs-mvp-gap-2026-10-25.md); MVP M03–M05; flows F06, F13, F17, F19

## Request and scope

Mike asked me to check the original app against the refining plan, then code in big batches. This is batch A of the gap analysis. Guest journal only; nothing leaves the phone.

## Work and outcome

- **Gap analysis:** [original-vs-mvp-gap-2026-10-25.md](../product/original-vs-mvp-gap-2026-10-25.md).
- **Write screen:** an opt-in **Get a suggestion** opens a Reflection review.
  - It shows "My words" read-only, plus a suggestion: what happened, a feeling, and something to consider. Each part can be edited or cleared.
  - A possible next step is shown with **Add this step**. It is never kept by default.
  - Buttons: **Save with reflection** and **Save only my words**.
  - Fields are read-only while saving, and Back asks before discarding edits.
- **Engines:** the original `AppleIntelligenceReflectionEngine` runs on-device when available (iOS 26 with Apple Intelligence), wrapped so it can't silently fall back. Otherwise the original `LocalReflectionEngine` is used. The original cloud engine and its UserDefaults factory are never used. Every suggestion carries its source label, e.g. "Guided prompts, not a personal analysis".
- **Practice:** **Get a suggestion** offers Gentle, Clear and Firm options, from the model or from guided templates. **Use this** fills the wording, with Undo. The options are marked as outdated when the situation, goal or wording changes after they were made.
- **Entry detail:** shows the reflection apart from the words. After the words are edited, it says "Based on an earlier version of your words". The next step can be marked done or not done, or removed, and the reflection can be removed.
- **Schema V3:** adds optional fields, including the words the reflection was based on, with a lightweight V2 → V3 stage.

## Verification

- **Full local suite:** 199 passed, 0 failed, 1 skipped (device-only). The new tests cover the store, the V2 and V1 migrations keeping everything, rollback, the review and Practice view models, and the guided engine.
- **Out-of-repo XCUITests** (iPhone 18 Pro / iOS 27.0, guided mode through the Debug launch argument `-CircleUGuidedSuggestions`), six passed:
  - suggestion → Add this step → Save with reflection → entry shows Reflection and Next step → Mark done, then Mark not done;
  - Practice options → Use this → Undo;
  - the existing guest flows.
- **Accessibility:** after the fixes there are no hit-area findings. The remaining contrast flags are on ink-on-white and muted-on-ice text, which measure at least 6:1, so they look like audit artifacts from content scrolled under the bars.
- **Not run:**
  - live Apple Intelligence: the simulator and Mike's iPhone 11 Pro Max use the guided path;
  - suspended-generation tests;
  - CI (manual by owner decision).

## Discussion and decisions

- **Codex round 1** ([log](2026-10-25-230500-codex-review-guest-suggestions.md)): one blocker and eight should-fixes.
  - Fixed: 1, 2, 3, 6 and 8, plus most of 5 and 9.
  - Not changed, by decision: 4 (a step is adopted explicitly, so it's the person's own) and 7 (trimming outer whitespace is existing tested behaviour).
- **Codex round 2** ([log](2026-10-25-231800-codex-review-guest-suggestions-round-2.md)): no blocker, and it accepted both decisions. I then made wording a Practice suggestion input; the remaining test gaps are listed below.

## Handoff

- Remaining work:
  - batch B: search, calendar, Settings, export, delete all, Practice draft;
  - batch C: needs Mike's OK.
- Owner: Claude
- Risks / unresolved questions:
  - quality of the on-device model output is unverified on a real Apple Intelligence device;
  - tests for suspended suggestion generation are missing.
