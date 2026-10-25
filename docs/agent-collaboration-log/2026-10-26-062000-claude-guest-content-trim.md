# Content batch: one enforced guideline, shorter account and privacy screens

- Recorded: 2026-10-26 06:20:00 +11:00; Australia/Sydney
- Agent / role: Claude Code (implementer), on Mike's Mac
- Status: completed; merged under the auto-merge rule; phone check pending
- Base revision and branch: `codex/guest-content-trim` from `main` at `1e5cc04`
- Related record / task / PR: Mike's feedback, relayed by the coordinator; [guideline](../design/screen-content-guidelines.md); [before and after](../qa/screenshots/content-trim-2026-10-26)

## Request and scope

Mike's feedback:
- The Log in, preview, reset and delete screens have too much text.
- Privacy and data should show a one-line summary per section, with the detail collapsed.
- One content guideline should be the single enforced source, referenced in AGENTS.md, with a lint if practical.
- All guest screens should be audited.

## Work and outcome

- **Guideline:** [screen-content-guidelines.md](../design/screen-content-guidelines.md) replaces `content.md`, which is now a pointer, and keeps its voice, terms and truthful-state rules.
  - Limits: heading ≤ 40 characters; one supporting line ≤ 90; at most one filled primary action; ≤ 2 secondary actions; detail behind Learn more; errors ≤ 100.
  - Banned wording and the privacy summary pattern.
  - A table covering every guest screen.
  - AGENTS.md requires it for every agent.
- **Lint:** `GuestCopyLintTests` reads every guest feature and service file recursively. It enforces string length and banned wording (whole words). What it can't check is listed in the guideline.
- **Screens:**
  - Log in, backup preview, copied, reset, Delete my account, Welcome and Settings now have one heading and one short `GuestSummary` line.
  - Honesty details (sealed on-phone data, what isn't copied, deletion scope, backups and restores) moved behind `GuestLearnMore`.
  - Long warnings shortened, keeping their consequences.

## Verification

- **Full local suite:** 244 passed, 0 failed, 1 skipped. The lint test runs and passes.
- **Out-of-repo XCUITests:** ten passed on a clean install.
- **Not run:** VoiceOver on a device; CI (manual by owner decision).

## Discussion and decisions

**Codex** ([log](2026-10-26-061000-codex-review-guest-content-trim.md)):
- Two blockers, where my trimming lost honesty: the unreadable Practice draft warning dropped "new writing isn't kept", and a retry was presented as certain. Both fixed.
- Should-fixes:
  - delete-all scope restored ("this journal"; the earlier app isn't affected);
  - account deletion qualified;
  - lint made recursive and whole-word, skipping off-host;
  - guideline and screens reconciled (destructive primary, privacy detail ≤ 4 sentences, Welcome summary style, Your data order).
- Merged without another round, since the fixes were small.

## Handoff

- Remaining work: Mike's phone check.
- Owner: Mike
- Risks / unresolved questions: the heading and supporting-line limits are checked in review, not by the lint.
