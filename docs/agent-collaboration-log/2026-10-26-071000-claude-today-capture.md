# Today opens straight to capture

- Recorded: 2026-10-26 07:10:00 +11:00; Australia/Sydney
- Agent / role: Claude Code (implementer), on Mike's Mac
- Status: completed; merged under the auto-merge rule; phone check pending
- Base revision and branch: `codex/today-direct-write` from `main` at `c1d2701`
- Related record / task / PR: Mike: "for today tab, we can go directly to record or text"; [screenshots](../qa/screenshots/today-capture-2026-10-26)

## Work and outcome

- **Today is the capture screen:** "What’s on your mind?", one line, the big microphone and the text box, with Get a suggestion and Save only my words. The Pingu avatar and Settings are in the toolbar.
- **Removed:** the "Work through a moment" step, and Today's "Continue your draft", since the draft is simply there.
- **Unchanged:**
  - Save stops the mic, with no double saves.
  - The draft is kept across tabs and relaunch.
  - The reflection review is pushed on top, and the path is cleared after saving.
- Opening the avatar picker stops the microphone first (from Codex).
- The content guideline table is updated.

## Verification

- **Full local suite:** 244 passed, 0 failed, 1 skipped.
- **Out-of-repo XCUITests:** passed. They now check that Today opens with the text box and the microphone.
- **Not run:** a real microphone on the phone (Mike's check); CI (manual).

## Discussion and decisions

**Codex** ([log](2026-10-26-070000-codex-review-today-capture.md)): no blocker. Its one should-fix (the picker could leave the mic running) is fixed.

## Handoff

- Remaining work: Mike's 30-second phone check.
- Owner: Mike
- Risks / unresolved questions: leaving Today while dictation is "Finishing…" drops the last pending words. This is existing behaviour, noted by Codex.
