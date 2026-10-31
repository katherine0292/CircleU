# Message-first Practice Implementation Plan

> **For agentic workers:** Use superpowers:executing-plans to implement this bounded prototype task in the existing worktree. Track completion here.

**Goal:** Update the disposable Practice browser specimen to demonstrate direct wording and optional intent-led preparation.

**Architecture:** Keep the existing HTML/CSS and browser state machine. Add a guidance state and distinguish intent-only input from original wording; reuse consent, clarification, result and Undo. No native or provider implementation.

**Tech Stack:** Plain HTML, CSS, JavaScript; existing Pingu resources.

**Spec:** [Approved short design](../specs/2026-10-30-message-first-practice-design.md).

## Global constraints

- Preserve guest access, Today/Journal specimens, branding and native source.
- One filled primary; optional tone/context; exact selected-text consent; no automatic upload or generated reply presented as received.
- Fixed fixtures and temporary Save remain clearly disclosed outside the phone. No real microphone/provider added; voice and durable history remain in the existing native implementation for separate integration.
- No commit/push or unrelated dirty-file changes.

## Review focus

- Blank input must not produce or save a message; intent-only output must not invent original words.
- Guidance Back/Continue must retain existing wording, and the user must be able to clear intent.
- New request/cancel/failure must preserve words while invalidating old Undo.
- Applying a suggestion must not save/copy; copied text must report only successful clipboard operations.
- Larger text must keep guidance and actions reachable.

## Task 1 — Message-first entry and guidance

Files: `Prototypes/CircleUVisualPrototype/PracticeFeedbackReview/{index.html,feedback.css,feedback.js}`.
Interfaces: `show(next)`, `confirm()`, `submit()`, `result()` remain the state transitions; add a separate guidance intent value, optional context fields and editor action refresh.

- [x] Observe current UI baseline: no guidance action and Save is primary.
- [x] Start blank on initial load; keep an external populated fixture reset. Make Review wording primary, Save/Copy secondary. Collapse optional tone/context.
- [x] Add Help me get started → required outcome + optional context → Continue back to editor. No request on Continue. Back retains words; clear action removes intent.
- [x] Label intent-only consent/result as Your intent, retain independent reply intent, and avoid draft-specific canned feedback on the blank-start route.
- [x] Preserve existing clarification, failure, cancellation, manual Save and Undo; refresh disabled actions after Use/Undo/input.
- [x] Browser check both routes, blank validation, guidance Back, selected context, Use/Undo, cancellation and failure, reply attribution and larger text. Inspect screenshots.

## Task 2 — Evidence and review

Files: prototype README/screenshots, product stories/checklist, content guideline and new dated agent log.

- [x] Run script syntax, local resources/IDs, changed Markdown links and whitespace checks.
- [x] Review scoped diff against pre-edit copies; record findings and limitations.
- [x] Update P9 evidence without claiming native completion; mark browser tab deliverable.

Execution decision: proceed inline under the owner's approval to update this reversible prototype; no additional permission round. Manual browser checks are proportionate for a disposable specimen; no production test suite or mirrored unit tests added. The native voice and durable saved-conversation flows are deliberately not rebuilt here.

Verification record: scoped independent static review by message_first_review found one larger-text specificity issue. Treated as an accessibility fix: browser reproduced 12px Edit intent, CSS override added, browser verified Edit/Clear at 20px. No other findings. Browser walkthrough and static checks passed as recorded in review 08 README. Existing worktree reused; manual fixture checks used for this reversible prototype. Native tests/voice/history/provider integration remain outside this plan.
