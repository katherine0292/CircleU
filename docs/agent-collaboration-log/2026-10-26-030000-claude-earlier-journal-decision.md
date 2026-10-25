# Owner decision: the earlier journal stays sealed until sign-in

- Recorded: 2026-10-26 03:00:00 +11:00; Australia/Sydney
- Agent / role: Claude Code (implementer), on Mike's Mac
- Status: completed (docs only); standing by
- Base revision and branch: `codex/earlier-journal-decision` from `main` at `6d65876`
- Related record / task / PR: [batch C log](2026-10-26-024500-claude-guest-import-welcome.md); [legacy data format](../engineering/legacy-data-format.md)

## Request and scope

The coordinator relayed Mike's choice from the decision card at the end of batch C. Record it in the docs; don't start sign-in work.

## Work and outcome

Mike chose **option 1**:
- The earlier journal stays sealed in the guest app, which is the current default; no code change.
- Once account sign-in exists, only the signed-in account's own journal is imported.

Options 2 (a personal confirmation) and 3 (an export file from the original app) were not chosen. The decision is recorded in [legacy-data-format.md](../engineering/legacy-data-format.md).

## Verification

- Docs only. No code or tests changed. The last full local suite on `main` (`6d65876`'s branch head) was 232 passed, 0 failed, 1 skipped.

## Discussion and decisions

Owner decision as above. Sign-in work touches Firebase and accounts, so it needs Mike's explicit go-ahead.

## Handoff

- Remaining work: none until Mike asks for sign-in or other work.
- Owner: Mike
- Risks / unresolved questions: none.
