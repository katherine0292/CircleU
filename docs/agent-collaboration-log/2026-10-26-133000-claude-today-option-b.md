# Today option B: question chips, Need a nudge, one Save, reflect after saving

- Recorded: 2026-10-26 13:30:00 +11:00; Australia/Sydney
- Agent / role: Claude Code (implementer), on Mike's Mac
- Status: completed; merged under the auto-merge rule; phone check pending
- Base revision and branch: `codex/today-option-b` from `main` at `8b1654c`
- Related record / task / PR: Mike picked "B now, A and C after the art"; canvas boards B1–B3; [screenshots](../qa/screenshots/today-option-b-2026-10-26)

## Work and outcome

- **B1:**
  - "Not sure where to start?" shows three chips above the empty box.
  - Tapping a chip adds only its sentence starter, never the question, so the entry stays in the person's words.
- **B2, "Need a nudge?":**
  - It appears once there are 5 words and dictation isn't running.
  - It shows one fixed guided question, with Add to my words (the starter goes on a new line), Another question, and Hide (for this entry only).
  - Each action is 44 points, and the actions stack and wrap at large text sizes.
  - While typing, the microphone shrinks to a small inline button and the supporting line hides, so the words stay visible above the keyboard.
- **B3:**
  - Today has one Save.
  - Journal then shows "Saved to your journal" with Reflect on it / Not now, for that entry only.
  - The reflection review now works on a saved entry (`updateReflection`) and never changes the words.
  - "Get a suggestion", "Save only my words" and the save-with-reflection path are gone from Today.
- **Unchanged:** Save stops the microphone and keeps the spoken words, there are no double saves, and drafts are kept.
- **Docs:**
  - Stories: T1.5, T6 (rewritten), T8 and T9. 86 criteria; 70 with a unit test and 15 with only a UI test.
  - 1 criterion has no test: T9.4, a layout check done on screenshots.
  - The content guideline is updated: prompt chips and dismiss controls don't count as actions.
- **Not done:** the nudge questions are fixed templates, not on-device suggestions; that is a possible follow-up. Option A (mic) and C (backdrop) wait for the art.

## Verification

- **Unit suite:** 253 passed, 0 failed, 1 skipped.
- **UI suite:** 15 passed, 1 skipped (live Dev, opt-in). New tests are `GuestTodayUITests` and `GuestTodayPromptsTests`.
- **Screenshots** were checked in the Simulator. The first nudge layout hid the words behind the keyboard; I fixed that before review.
- **Not run:** the phone check (sent to Mike); the largest Dynamic Type sizes on a device; CI (manual).

## Discussion and decisions

**Codex** ([log](2026-10-26-132000-codex-review-today-option-b.md)):
- **First pass**, 3 blockers, all fixed:
  - an older reflection cleared a newer entry's offer;
  - Delete all left the reflection open;
  - the nudge targets were under 44 points.
- **Second pass**, 2 blockers, both fixed without a third pass:
  - the Delete-all observer sat inside the reset identity;
  - the stacked labels couldn't wrap.
- The UI test failed on the earlier code and passes after the fix, which confirms the Delete-all issue.

## Handoff

- Mike's 1-minute phone check on CircleU Guest Test.
- A and C wait for the art (see the [art brief](../design/pingu-scene-art-brief.md)).
