# Codex check 3 of guest write, journal and edit (PR #12)

- Recorded: 2026-10-25 20:12:48 +11:00; Australia/Sydney
- Agent / role: Codex, reviewer
- Status: completed — changes requested
- Base revision and branch: `e9c8a3c5e0cd14b12f3c448fda16b7f212da9792` on `codex/guest-write-journal`; working tree clean.
- Related record / task / PR: PR #12; [second re-check](2026-10-25-200523-codex-recheck2-guest-write-journal.md).

**Verdict: Still BLOCKS merge. The previous mechanisms are corrected, but two draft data-loss paths remain.**

## Request and scope

Reviewed only `git diff HEAD~1..HEAD -- Circleu CircleuTests`, with surrounding code and required project records for context. Local reads only; no network, builds, tests or file writes.

## Work and outcome

- **Previous findings addressed statically:** consumption uses durable IDs rather than text; entry and `SavedDraft` share one save/rollback; receipts survive entry edits/deletion; ordered operations and ID-guarded removal close the previous cleanup race; stacked notices preserve protection and cleanup warnings together.

1. **High — An inconclusive restore check can lead to discarding subsequent edits.** At [GuestJournalViewModel.swift:85](</Users/tuannm3812/Documents/GitHub/3. Personal/CircleU/Circleu/Features/GuestJournal/GuestJournalViewModel.swift:85>), a failed `isDraftSaved` lookup restores the leftover under its consumed ID. If the user edits it before saving, those changes retain that ID. Once the store recovers, `create` rejects the ID; the catch at line 120 treats rejection as success, clears the submitted text and removes its draft file. The new words were never committed. Preserve edited content and resolve uncertain consumption explicitly; rejection must not imply that the current text was saved.

2. **High — Interruption can erase newer typing already persisted during save.** At [GuestJournalViewModel.swift:128](</Users/tuannm3812/Documents/GitHub/3. Personal/CircleU/Circleu/Features/GuestJournal/GuestJournalViewModel.swift:128>), identity rotates only after `create` returns. While awaiting it, typing B after submitting A can persist B under A’s ID. If A commits and the process terminates before B is durably rewritten under the new ID, relaunch sees the consumed ID and removes B. The queue fixes operation ordering during uninterrupted execution, but not this durable-state ambiguity. Give post-submission edits a distinct durable identity before they can be mistaken for consumed content, or prevent editing during that interval.

- **Schema/concurrency:** No additional model-registration or transaction defect identified. The store’s synchronous actor-isolated check/insert/save and single-owner registry serialize duplicate-ID checks. Given V1 never shipped, changing its definition is not itself a released-data migration blocker. Compatibility with earlier development stores is unverified; old `Draft.txt` files are no longer read.

## Verification

- Inspected all seven changed files and relevant callers/tests.
- `git diff --check HEAD~1..HEAD -- Circleu CircleuTests`: passed.
- `git status --short --branch`: clean; HEAD unchanged.
- The test named `testDraftThatCantBeCheckedIsRestoredButNeverSavedTwice` never injects a lookup failure. The cleanup test uses `Task.yield()` without establishing a specific suspension point. Neither covers the blockers above.
- **Reported only:** Claude reports 145 tests and the UI flow passing.
- Not run / limitations: no independent build, tests, UI or physical-device verification. Findings are static; no files written.

## Discussion and decisions

None. No direct inter-agent exchange occurred; Claude’s results were supplied by the user.

## Handoff

- Remaining work: fix both identity-lifecycle paths and add deterministic lookup-failure and interrupted-save regression coverage.
- Owner: Unassigned for fixes; Mike for merge decisions.
- Risks / unresolved questions: newer draft text can be discarded despite never being saved as an entry.

## Correction reference (if applicable)

Updates the [second re-check](2026-10-25-200523-codex-recheck2-guest-write-journal.md): its specific matching, cleanup-ordering and notice-overwrite defects are addressed; the new data-loss paths still prevent merge approval.