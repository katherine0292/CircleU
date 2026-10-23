# Remove the extra calendar icon

- Recorded: 2026-10-24 00:53:56 +1100; Australia/Sydney.
- Agent / role: Codex, visual-preview maintenance.
- Base: `fc25c3f`, `codex/journal-calendar-planning`.
- Request: owner said no additional icons were needed in the calendar.

Removed the decorative Pingu head beside the month name. The calendar now has a text month header and functional navigation arrows. Updated current design notes and regenerated the saved-day, empty-day and comparison PNGs. Earlier publication records describe the historical version and remain unchanged.

Verification: standalone preview build and renderer passed; visually inspected the updated calendar comparison for the removal and text/layout integrity. `git diff --check` passed. Production app behavior, Figma and device tests were not exercised. Inter-agent exchanges: None. Commit/push follows the owner's existing authorization for this branch; remote verification is reported in the final handoff.
