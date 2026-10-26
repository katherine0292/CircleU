# Settings: icon rows and a privacy sheet

- Recorded: 2026-10-26 16:00:00 +11:00; Australia/Sydney
- Agent / role: Claude Code (implementer), cloud session
- Status: code complete; build, tests and Codex review run on Mike's Mac
- Base revision and branch: `codex/settings-icon-rows` from `main` at `73b2d81`
- Related record / task / PR: Mike's "less text" request; mocked as row S on the CircleU Design canvas, approved by Mike ("go"). Log in and Delete my account screens belong to the account-screens thread and are not changed here.

## Work and outcome

- `GuestSettingsView` (GuestFindAndControl.swift): Pingu in a circle with a pencil badge (replaces "Tap to change."), an "Only on this iPhone" chip with "Not uploaded or synced." under it, and grouped icon rows (Export my data, Delete all data, Bring in your earlier journal, Delete my account). Removed the three section summaries and the Privacy Learn more.
- New `GuestPrivacySheet`: four one-line icon rows (dictation, backups, restore, exports).
- "Export done." banner (was two sentences); the shared-copy fact moved to the privacy sheet. Delete all alert message shortened.
- Stories S1.1 and S2.3, the guidelines table, and the affected unit and UI tests updated. Accessibility labels of existing controls are unchanged.

## Verification

- See the PR for local test and Codex review results.
