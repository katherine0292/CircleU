# Write, Journal and edit screens — first slice step 4

- Recorded: 2026-10-25 19:46:49 +11:00; Australia/Sydney.
- Agent / role: Claude (Claude Code).
- Status: PR open for Codex review and owner approval; not merged.
- Base revision and branch: `codex/guest-write-journal` on main `99910f5`.
- Related record: [first-slice plan](../superpowers/plans/2026-10-25-first-slice-typed-capture-local-journal.md), [walkthrough decisions](../design/prototype-review-results.md#walkthrough-summary--25-october).

## Request and scope

Step 4, behind the hidden switch only:
- Today → "Work through a moment" → Write ("What happened?") with a full-width "Save only my words";
- save through the store;
- Journal list (latest first);
- entry detail with edit and reopen;
- "Keep editing / Discard" on leaving unsaved edits;
- "Couldn't save. Try again." with the text kept;
- unit and UI tests and an accessibility audit.

## Work and outcome

- `GuestJournalScreens.swift`:
  - Today/Journal tabs.
  - Today ("What's on your mind?", PinguMascot, "Work through a moment"; "Continue your draft" only when a draft exists).
  - Write screen: scrolls, with Save pinned above the keyboard.
  - Journal list: loading / error with Try again / "Nothing saved yet." / entries.
  - Entry detail: reads the current entry by ID, so a saved edit shows at once.
  - Editor: alert with Keep editing / Discard.
- `GuestEntryEditorViewModel`: saves with the opened revision. Failures keep the text, with messages for stale, deleted and failed saves.
- Uses the app's existing Pingu colours and illustrations. The prototype's Plus Jakarta Sans font and brand artwork aren't in the app target yet; that's a separate branding step.
- Not done: the draft survives leaving Write within a launch, but **not relaunch** (the plan listed it). It's a follow-up for the next step.

## Verification

- `xcodebuild test` with the CI signing config (Xcode 27.1, iPhone 17 / iOS 26.5): 131 passed, 1 device-only skipped. New editor tests cover save, failure keeping text, stale/deleted messages, unsaved-change detection, and save → relaunch → edit → relaunch through the real store.
- Out-of-repo XCUITest (iPhone 18 Pro / iOS 27.0, CI build with `-CircleUGuestMode`): write → save → Journal → relaunch → open → edit → Back shows the discard alert → Keep editing → Save → shown → relaunch → edit still there. Passed.
- `performAccessibilityAudit()` on Today, Write, Journal, Detail, Edit, run during that UI test (default text size only). Write-screen clipping was found and fixed. Remaining:
  - system keyboard suggestion slots;
  - contrast and text-size findings on the system navigation-bar buttons (Edit, Back);
  - intentional three-line truncation of long entries in the Journal list.
- Two bugs were found by the UI test and fixed: the detail showed stale text after an edit, and the discard dialog's cancel button was hidden on iOS 26 (now an alert).
- Not run: phone (after review), largest-text audit of these screens.

## Discussion and decisions

Codex review requested (read-only).

## Handoff

- Remaining work: Codex review; owner merge; phone check (separate bundle ID, switch on); draft persistence across relaunch; brand font pass.
- Owner: Mike.
