# Guest journal: Practice (first batch)

- Recorded: 2026-10-25 22:42:00 +11:00; Australia/Sydney
- Agent / role: Claude Code (implementer), on Mike's Mac
- Status: completed; PR open; merge waiting for Mike's own go-ahead (the safety check refuses relayed approval)
- Base revision and branch: `codex/guest-practice`, stacked on `codex/guest-voice-and-tabs` (PR #15)
- Related record / task / PR: coordinator brief (Practice batch); [walkthrough decisions](../design/today-walkthrough-script-2026-10-25.md); [save fix log](2026-10-25-222000-claude-guest-save-while-listening.md)

## Request and scope

The coordinator relayed Mike's request to build Practice in one batch. Scope:
- direct practice, with situation, goal and wording;
- practice from a journal entry, tagged "From: …" or "On its own";
- your own wording, with no AI;
- Save and Copy as separate buttons;
- a history list;
- deleting an entry with a linked message;
- the same SwiftData store, with tests.

Guest journal only, local only, with no Firebase or legacy-data changes.

## Work and outcome

- **Store:** schema V2 adds `PracticeMessage` with a lightweight V1 → V2 migration. `GuestPracticeStore` supports create, update with expected revision, delete, and entry deletion with `keepMessages` or `deleteBoth`, all in one transaction. A message can't be linked to a missing entry.
- **Practice tab:**
  - **Practice a message** starts a message on its own.
  - A history list shows each message with its tag and date.
  - When nothing is saved yet, Pingu appears with "Nothing practised yet."
- **Message screen:** the heading is "What would you like to say?", with fields for Situation, Goal and Your wording.
  - Save and Copy are separate buttons, with the line "Copying won't save or send it."
  - A saved message shows "Saved · not sent", with Copy as the main button, plus Edit and Delete message.
  - Leaving with unsaved text asks before discarding.
- **Journal entry:**
  - Linked messages appear on the entry, with **Practice what to say**.
  - **Delete entry** asks "Keep message" (the default) or "Delete both".
  - A failed delete keeps everything and says "Couldn't delete. Try again."
- Delete buttons have a 44 pt hit area and a dark red (6.5:1 contrast on the background).

## Verification

- **Full local suite** (CI signing config, iPhone 17 / iOS 26.5 Simulator): **183 passed, 0 failed, 1 skipped** (device-only). The new tests cover:
  - Practice store behaviour, including the V1 → V2 migration keeping entries and saved-draft receipts;
  - rollback of every Practice write;
  - view models: typing during save, stale edits, the protection warning, Copy never saving, and delete choices or failure.
- **Out-of-repo XCUITests** (iPhone 18 Pro / iOS 27.0 Simulator), five tests passed:
  - Practice: direct save, Copy, history, practice from an entry with its "From:" tag, and Delete entry → Keep message, after which the message stays in Practice;
  - the three-entry voice test;
  - tabs and dictation denial;
  - two entries in a row;
  - the existing journal flow.
- **Not run:**
  - device check, which goes to Mike's phone check;
  - VoiceOver on a device;
  - CI (manual by owner decision);
  - view-level tests for route preservation and delete gating, which are covered by inspection and the UI flow only.

## Discussion and decisions

- **Codex round 1** ([log](2026-10-25-223200-codex-review-guest-practice.md)): two blockers and three should-fixes, all fixed in `12b2c35`:
  - blocker: Save overwrote text typed during the save;
  - blocker: a history refresh could replace an open editor.
- **Codex round 2** ([log](2026-10-25-223900-codex-review-guest-practice-round-2.md)): no blocker. One new should-fix (a delete error was hidden behind a save warning) was fixed in the next commit. Test gaps remain at the view level.
- The Codex logs are verbatim, except that absolute local paths became relative.

## Handoff

- Remaining work:
  - Mike's own "merge" for PR #13, then #15, then this PR;
  - his phone check, covering three entries and Practice.
- Owner: Mike
- Risks / unresolved questions:
  - Practice has no kept draft yet: an unsaved message is lost if the app is closed, though leaving the screen asks first;
  - no AI wording yet.
