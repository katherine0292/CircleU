# Codex re-check of guest write, journal and edit (PR #12)

- Recorded: 2026-10-25 19:59:40 +11:00; Australia/Sydney
- Agent / role: Codex, reviewer
- Status: completed — read-only review; changes requested
- Base revision and branch: `9e70c47ac9a3a808d3bdf9cb375543795f65409d` on `codex/guest-write-journal`, compared with parent `5b87da6043e539bcc6b2207726e821ebdd53aeb2`. Working tree clean.
- Related record / task / PR: PR #12; [original review](2026-10-25-195059-codex-review-guest-write-journal.md); [implementation record](2026-10-25-194649-claude-guest-write-journal.md); [first-slice plan](../superpowers/plans/2026-10-25-first-slice-typed-capture-local-journal.md).

**Verdict: Still BLOCKS merge. Original findings 1, 2, 3 and 6 are addressed in code. Finding 4 is partially resolved; finding 5 now has persistence, but new failure-handling defects remain. Three medium-severity findings below require fixes.**

## Request and scope

Re-checked only original findings 1–6 and problems introduced by `git diff HEAD~1..HEAD -- Circleu CircleuTests`, reading surrounding implementation and tests. Read project/shared standards, log protocol/template, MVP decisions and the relevant plan and records.

Local Git/file reads only. No network, builds, tests or file writes. This entry is supplied as Markdown without saving it.

## Work and outcome

### Original findings

| Finding | Re-check outcome |
| --- | --- |
| 1 — Input lost during edit save | **Addressed statically.** Save captures submitted text, advances the committed baseline and preserves newer input. `.savedStay` prevents dismissal for newer changes or a protection warning. A suspended-update test covers the ordinary success path; the combined suspension/protection-warning case is not covered. |
| 2 — Detail errors and editor lifetime | **Addressed statically.** Detail distinguishes loading, failure, present and missing states, with retry. Editor ownership and navigation registration now sit outside the conditional detail content. Cross-tab refresh behavior remains unverified at runtime. |
| 3 — Discard during pending save | **Addressed statically.** Back is disabled while saving; Discard independently checks `canLeave`. The suspended-update test checks the pending-save guard. |
| 4 — Protection warning hidden by navigation | **Partially addressed.** Edit stays open with its warning. Create stores a persistent notice, but its display can still be hidden behind an existing Journal destination; see R3. |
| 5 — Draft lost across relaunch | **Persistence implemented, failure handling incomplete.** Composition restores `Draft.txt` before exposing the screens. Ordered writes and unreadable-file preservation are present, with ordinary relaunch coverage. See R1–R2. |
| 6 — Phone-test configuration rejected by tests | **Addressed statically.** Routing tests pass explicit flag values; the compiled-default assertion is conditional on the flag being absent. |

### Severity-ranked remaining/new findings

1. **R1 — Medium, new: Failed draft cleanup can restore already-saved writing as an unsaved draft. BLOCKS merge.**

   [GuestJournalViewModel.swift:107](</Users/tuannm3812/Documents/GitHub/3. Personal/CircleU/Circleu/Features/GuestJournal/GuestJournalViewModel.swift:107>) clears memory after committing the entry, which merely queues file removal. `saveDraft()` returns success without awaiting that operation. At line 122, cleanup failure becomes `draftWarning`, displayed only on Write, which success navigation closes.

   If removal fails, the old file survives. Relaunch restores it without reconciling it against the committed entry, and saving it creates a duplicate. Termination before queued cleanup finishes has the same result. Tests explicitly call `flushDraft()`; production never does.

   **Fix:** Coordinate entry commit and draft consumption. Await and inspect cleanup, retain the committed outcome, and surface cleanup failure on the visible destination without inviting another create. Use durable draft identity/commit reconciliation to handle interruption between the two writes. Add failed-removal and interrupted-cleanup relaunch coverage.

2. **R2 — Medium, new: Draft protection failures are reported as though the draft was not stored. BLOCKS merge.**

   [GuestDraftStore.swift:38](</Users/tuannm3812/Documents/GitHub/3. Personal/CircleU/Circleu/Services/GuestJournal/GuestDraftStore.swift:38>) writes the bytes before applying protection. If protection throws, the catch returns `saveFailed`, although the new text already exists on disk. The ViewModel displays “Your draft couldn’t be kept on this phone,” hiding the actual outcome: retained content whose requested protection was not confirmed. Loading the draft does not retry or verify its protection.

   **Fix:** Distinguish write failure from committed-with-protection-failure and show an accurate, persistent warning. Protect before replacement where practical and reapply/verify protection when reopening. Add an injected protection-failure test that checks both retained bytes and the displayed outcome. This finding does not assert that folder-inherited protection is absent.

3. **R3 — Medium, remaining finding 4: The create warning is invisible when Journal already has an open detail/editor. BLOCKS merge.**

   [GuestJournalScreens.swift:159](</Users/tuannm3812/Documents/GitHub/3. Personal/CircleU/Circleu/Features/GuestJournal/GuestJournalScreens.swift:159>) attaches the notice to the Journal root content. Saving from Today only changes the selected tab; it does not unwind Journal navigation.

   Open a Journal detail or editor, switch to Today, then create an entry with `savedButUnprotected`. Returning to Journal exposes the existing destination, while the warning remains on the underlying list. The new test checks `notice` state, not visibility.

   **Fix:** Present the notice outside the Journal navigation stack or through a shared presentation visible over its current destination. Preserve any open editor. Cover this cross-tab warning flow.

## Verification

- Inspected the complete eight-file scoped diff and surrounding store, composition, screen and test code.
- `git diff --check HEAD~1..HEAD -- Circleu CircleuTests`: passed.
- `git status --short --branch`: clean; final HEAD unchanged.
- Git returned results despite denied temporary-cache warnings.
- New tests cover suspended edit success, edit warning outcome, failed-refresh state, ordinary draft restoration/clearing and unreadable-draft preservation. They do not cover R1–R3.
- The edit integration test still retains `reopened` and `editor` before its final reopen, so that read does not establish a fresh SwiftData store instance.
- **Reported only:** Claude reports 137 tests passing locally and the out-of-repo write → save → relaunch → edit → discard alert → save → relaunch UI flow passing.
- Not run / limitations: no independent build, tests, Simulator, physical-device protection checks or accessibility execution. Conclusions are static review findings.

## Discussion and decisions

None. No direct inter-agent exchange occurred. Claude’s execution results were supplied by the user and remain reported evidence.

## Handoff

- Remaining work: Fix R1–R3, add focused failure/navigation coverage, then request re-check.
- Owner: Unassigned for fixes; Mike for merge decisions.
- Risks / unresolved questions: Restored duplicate drafts, inaccurate draft-protection reporting and hidden save warnings. Physical-device protection remains unverified.

## Correction reference (if applicable)

This entry updates the [original review](2026-10-25-195059-codex-review-guest-write-journal.md): findings 1–3 and 6 are addressed in the inspected code; draft persistence now exists; warning visibility and draft failure handling still prevent merge approval. Historical entries remain unchanged.