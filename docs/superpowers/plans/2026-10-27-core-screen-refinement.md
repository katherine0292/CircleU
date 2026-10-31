# Core screen refinement implementation plan

> Use `superpowers:executing-plans` for this bounded UI pass. The owner's request to continue refining each screen authorizes this reversible native pass; the wider upgrade roadmap remains separate.

**Goal:** Make the three core screens feel coherent and leave more room for the person's words.

**Architecture:** Presentation-only edits in existing SwiftUI views. Keep ViewModels, storage, Firebase and navigation destinations unchanged.

**Tech stack:** SwiftUI, existing GuestBrand/Pingu resources, XCTest/XCUITest.

**Spec:** [Frontend review, batches 1–2](../../design/competition-frontend-review-2026-10-27.md), [content guidelines](../../design/screen-content-guidelines.md), and the owner's current request.

## Constraints and decisions

- Keep Today / Journal / Practice, Plus Jakarta Sans, blue/ice/ink and native tab geometry.
- Today: use a shallower 2.2:1 crop of existing art, preserving the penguin and microphone. Keep listening art unchanged. Use an ice-toned nudge with ink text and blue controls so Save leads.
- Journal: fill available background in every state; inline entry date with full timestamp available as secondary accessible metadata.
- Practice: a quiet illustrated card with a blue action strip, one hit target, decorative art omitted at accessibility sizes. Use the same card for empty and populated states. Editing Save is pinned above the keyboard; saved Copy stays as it is.
- Keep original assets for this native pass; new poster mockups do not establish production UI or approve extra features.
- Do not change Welcome/privacy/recovery copy or behavior merely for consistency. Review them in the regression suite.
- Preserve 44-point controls, wrapping text, reduced-motion behavior, save failures and independent Copy/Save semantics.

## Steps

- [x] Add a meaningful Practice keyboard regression before changing the action placement: while writing with expanded situation and goal, Save's full bounds must stay above the software keyboard, stay stable when scrolling, and save the actual message. Exercise default and largest text.
- [x] Run the new test against the baseline and record the result; distinguish a test/environment failure from the expected layout failure.
- [x] Refine `GuestJournalScreens.swift`: shallow Today art, quieter nudge, full Journal background, compact detail date and readable timestamp.
- [x] Refine `GuestPracticeScreens.swift`: unified start card, large-text art omission, pinned editing Save preserving its existing operation and disabled state.
- [x] Update affected stories and content descriptions. No style-only unit tests; visually inspect screenshots for artwork crop and hierarchy.
- [x] Run the unit and UI suites sequentially on the existing iPhone Simulator. Inspect default/large-text captures; hardware validation remains separate.
- [x] Obtain an independent review, resolve material findings, save a screen-review set and record evidence in a dated log. No merge/push/release included.

## Review focus

Software keyboard with long content; largest-text action reachability; successful save closes keyboard; empty/loading/error background coverage; date/year semantics and accessible full timestamp. Existing save/edit/copy/discard, dictation and onboarding UI tests cover the surrounding paths.

## Progress

Pre-flight: the two view files share only existing tokens and models; no new cross-file API. Existing isolated worktree confirmed on `codex/app-upgrade-plan` at `9967a10`; prior artwork/docs preserved. Historical baseline: 256 unit passes and 19 UI passes/1 skipped; not rerun yet in this pass.

27 October execution: baseline default-size keyboard regression failed because Save was not hittable. Both initial focused checks passed after pinning Save (normal and AX5, software keyboard visible). Reviewer identified offscreen failure feedback and an ambiguous scroll gesture. Moved editing failure feedback beside Save, dismissing focus and announcing the error; changed the test to drag the outer form and assert a content anchor moved. Reviewer rechecked these changes with no remaining material source findings. Full-suite verification is in progress.

Visual ruling: reduced the proposed Today crop from 2.4:1 to 2.2:1 after native screenshot inspection; the initial crop left Pingu’s tuft too close to the top edge. The gentler crop preserves headroom while still exposing more writing area than the original 1.95:1 scene.

Completed: final unit suite 256 passed; all 21 runnable UI cases passed across full and targeted runs, 1 live-Firebase skip. The full run’s two gesture failures and successful correction are retained in the agent evidence log. Gallery saved and native iPhone 17 review build launched. No release qualification or commit performed.
