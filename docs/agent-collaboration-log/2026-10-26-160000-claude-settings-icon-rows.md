# Settings: icon rows and a privacy sheet

- Recorded: 2026-10-26 16:00:00 +11:00; Australia/Sydney
- Agent / role: Claude Code (implementer), cloud session
- Status: code complete; build, tests and Codex review run on Mike's Mac
- Base revision and branch: `codex/settings-icon-rows` from `main` at `73b2d81`
- Related record / task / PR: Mike's "less text" request; mocked as row S on the CircleU Design canvas, approved by Mike ("go"). Log in and Delete my account screens belong to the account-screens thread and are not changed here.

## Work and outcome

- `GuestSettingsView` (GuestFindAndControl.swift): Pingu in a circle with a pencil badge (replaces "Tap to change."), an "Kept on this iPhone" chip with "Not uploaded or synced." under it, and grouped icon rows (Export my data, Delete all data, Bring in your earlier journal, Delete my account). Removed the three section summaries and the Privacy Learn more.
- New `GuestPrivacySheet`: four one-line icon rows (dictation, backups, restore, exports).
- "Export done." banner (was two sentences); the shared-copy fact moved to the privacy sheet. Delete all alert message shortened.
- Stories S1.1 and S2.3, the guidelines table, and the affected unit and UI tests updated. Accessibility labels of existing controls are unchanged.

## Verification

- See the PR for local test and Codex review results.

## Follow-up after the Codex review (same day)

- Codex (gpt-6-astra, high) found no blockers. Applied its should-fix items: the pencil badge is now inside the avatar button (`GuestAvatarButton(framed:)`); the delete-all alert again says the earlier app isn't affected ("Deletes this journal and drafts. The earlier app stays."); the privacy UI test checks all four facts; the backups line names the journal; row and sheet icons scale with Dynamic Type.
- The chip and sheet title read "Kept on this iPhone" rather than "Only on this iPhone", because backups can include the journal (Codex's honesty point).
- Mike asked for more illustrated icons with no repeats: six new Expansion03 icons replace the reused Journal and Next step icons and the privacy-sheet SF Symbols. Delete rows keep native symbols, as the branding guideline says.
- Two UI failures (reflection "Save reflection", dictation denied) also fail on unmodified main; not caused by this branch.
