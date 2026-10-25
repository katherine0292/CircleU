# Owner chose SwiftData for the first slice

- Recorded: 2026-10-25 18:24:53 +11:00; Australia/Sydney.
- Agent / role: Claude (Claude Code).
- Status: decision recorded.
- Base revision and branch: `codex/storage-spike` (PR #9).
- Related record: [spike results](../engineering/storage-spike-2026-10-25.md), [Codex review](2026-10-25-181218-codex-review-storage-spike.md).

## Request and scope

Mike chose SwiftData over the recommended versioned JSON files (relayed by the project coordinator).

## Work and outcome

The decision and the accepted trade-offs are recorded in the results doc. The production store will add explicit Data Protection, injected-failure tests, surfaced fetch errors, and Codex's rules: a storage error is never an empty journal, no resurrection on update after delete, and serialized saves.

## Verification

Docs only.

## Discussion and decisions

Owner decision; the agent recommendation was JSON. No inter-agent exchange.

## Handoff

- Remaining work: step 2, the SwiftData guest journal store behind a protocol (separate PR).
- Owner: Claude for implementation; Mike for merge approval.
