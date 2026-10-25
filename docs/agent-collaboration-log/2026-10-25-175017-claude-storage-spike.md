# Storage spike for the first slice

- Recorded: 2026-10-25 17:50:17 +11:00; Australia/Sydney.
- Agent / role: Claude (Claude Code).
- Status: spike complete; recommendation awaiting owner choice; Codex review requested.
- Base revision and branch: `codex/storage-spike` from main `886a518`.
- Related record: [results](../engineering/storage-spike-2026-10-25.md), [first-slice plan](../superpowers/plans/2026-10-25-first-slice-typed-capture-local-journal.md).

## Request and scope

Mike approved the first-slice plan and chose a short storage test before picking. This compares SwiftData with versioned JSON files in an isolated package (`Prototypes/StorageSpike`). There is no app or feature code.

## Work and outcome

Both options share one repository protocol and the same tests. The results table and the recommendation (versioned JSON files behind the protocol) are in the [results doc](../engineering/storage-spike-2026-10-25.md).

## Verification

- `xcodebuild test -scheme StorageSpike` on the iPhone 18 Pro / iOS 27.0 Simulator: 11 passed.
- `swift test` on macOS: 11 passed.
- Not verified: Data Protection (Simulator doesn't report it), disk-full, real process kill, large-size performance, and SwiftData write failure (couldn't be provoked).

## Discussion and decisions

Codex review requested (read-only); its verdict will be recorded in its own entry. Owner decision pending.

## Handoff

- Remaining work: Mike picks storage; then slice step 2 (production repository and tests).
- Owner: Mike.
