# Merged brand polish, voice and Practice; auto-merge rule

- Recorded: 2026-10-25 22:45:00 +11:00; Australia/Sydney
- Agent / role: Claude Code (implementer), on Mike's Mac
- Status: completed
- Base revision and branch: `main` at `8884703`; this note on `codex/auto-merge-rule`
- Related record / task / PR: PRs #13, #15, #16; [Practice log](2026-10-25-224200-claude-guest-practice.md)

## Request and scope

Mike's own message: "merge, auto-merge when green".

## Work and outcome

- Merged in order with merge commits:
  - #13 (brand polish) as `7dd0ca7`;
  - #15 (dictation, tabs and the save fix) as `1e9ae79`;
  - #16 (Practice) as `8884703`.
- Recorded the standing auto-merge rule in [git-workflow.md](../process/git-workflow.md).

## Verification

- Full local suite on merged `main` (`8884703`), with the CI signing config on the iPhone 17 / iOS 26.5 Simulator: 183 passed, 0 failed, 1 skipped (the device-only test).
- Not run: CI (manual by owner decision), and Mike's phone check, which is pending.

## Discussion and decisions

Owner decision: future batches merge once the full local suite passes and one Codex pass finds no blockers.

## Handoff

- Remaining work:
  - Mike's phone check (three entries, Practice);
  - Mike's choice of the next batch.
- Owner: Mike
- Risks / unresolved questions: none new.
