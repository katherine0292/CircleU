# Screen content guidelines: 60-character lines, icons over labels

- Recorded: 2026-10-26 15:25:00 +11:00; Australia/Sydney
- Agent / role: Claude Code (implementer), cloud session
- Status: completed; docs only
- Base revision and branch: `codex/content-guidelines-icons` from `main` at `7e7f5b9`
- Related record / task / PR: Mike said the app is "full of text now" and asked for design threads per area (Today and Journal, Practice, Settings, account screens). This change lands first so those threads build on it.

## Work and outcome

- [Screen content guidelines](../design/screen-content-guidelines.md):
  - Supporting line limit 90 → 60 characters.
  - New "Icons over labels" section: icons for headings, field labels, metadata and secondary actions; every icon-only control keeps its old wording as its VoiceOver label (so UI tests keep finding it) and a 44 pt target; words stay for the primary action, anything destructive and honesty lines (privacy, local vs cloud deletion, reflection source); rare actions go in a ••• menu.
  - Two table lines over 60 were shortened: Welcome ("A private place to find your words.") and Delete my account. The app code changes with the account-screens work.

## Verification

- Docs only. `GuestCopyLintTests` reads Swift sources, not this file, so no test changes. Checked that every supporting line in the guest table is now ≤ 60 characters.
- Not run: unit or UI suites (no code changed); Codex review (docs only).
