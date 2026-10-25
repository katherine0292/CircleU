# Codex re-check of guest journal store (PR #10)

- Recorded: 2026-10-25 18:39:12 +11:00; Australia/Sydney
- Agent / role: Codex, reviewer
- Status: completed — read-only re-check; changes requested
- Base revision and branch: `8744bed049ede676fe17a0617d6ff20474133cb1` on `codex/journal-store-swiftdata`, compared with parent `2a7b630e72484f4001075606bbdcaa9eaa0df09b`. Working tree clean.
- Related record / task / PR: PR #10; [original review](2026-10-25-183148-codex-review-guest-journal-store.md); [implementation record](2026-10-25-182835-claude-guest-journal-store.md).

**Verdict: Still BLOCKS merge. Findings 1, 2, 4 and 5 are addressed in the implementation. Finding 3 remains partially unresolved because callers can construct independent registries and bypass the single-owner boundary.**

## Request and scope

Re-checked findings 1–5 and regressions introduced by `git diff HEAD~1..HEAD -- Circleu CircleuTests`, reading surrounding code, required project documentation and installed SDK interfaces as needed.

Local Git/file reads only. No network, builds, tests, file writes or delegation. Claude’s reported 118 passing tests, with one device-only test skipped using the CI signing configuration, remain reported evidence.

## Work and outcome

### Severity-ranked remaining/new findings

1. **Medium — Independent registries can still create independent writers; remaining finding 3.**  
   [SwiftDataGuestJournalStore.swift:228](</Users/tuannm3812/Documents/GitHub/3. Personal/CircleU/Circleu/Services/GuestJournal/SwiftDataGuestJournalStore.swift:228>) declares an internal actor with an implicit internal initializer. Its `store(for:protection:faults:)` method is also internal. Two callers can therefore construct separate `GuestJournalStoreRegistry()` instances and acquire different store actors for the same location. Each registry checks its own dictionary and invokes `make`, restoring the independent-context revision-check problem.

   The current `SwiftDataGuestJournalStore.open` path correctly uses `.shared`; no existing caller of a separate registry was found. Nevertheless, the original requirement to constrain construction is not enforced.

   **Fix:** Add `private init() {}` to the registry and preferably make the registry type file-private. Retain the private store initializer and route acquisition through `open`. **This remains a merge blocker under finding 3.**

2. **Low — The competing-edits test lost its typed conflict assertion.**  
   [GuestJournalStoreTests.swift:115](</Users/tuannm3812/Documents/GitHub/3. Personal/CircleU/CircleuTests/GuestJournalStoreTests.swift:115>) now checks only that one operation succeeds and the revision becomes 1. The previous assertion that the loser receives `.staleRevision(current: 1, expected: 0)` was removed. An unrelated storage or protection error could satisfy the revised test.

   **Fix:** Restore the exact losing-error assertion while retaining acquisition through separate `open` calls. **Nonblocking.**

### Findings 1–5 disposition

| Original finding | Re-check |
| --- | --- |
| **1 — Missing/unreadable storage** | **Implementation addressed.** The standard marker is outside the journal directory. Established-store absence is checked before directory creation. `attributesOfItem` treats only explicit no-such-file errors as absence; other metadata failures become `storeUnavailable`. The new whole-directory-loss test asserts `storeMissing` and no replacement database. |
| **2 — Draft race** | **Addressed for the reported data-loss case.** The submitted draft is captured before suspension; completion clears only matching text. The suspended-save test edits A into different text and asserts its preservation. This is content comparison, not generation tracking. |
| **3 — Single owner** | **Partially addressed; blocking issue above.** Through `.shared`, acquisition is serialized without suspension between lookup, construction and registration. Weak references avoid retaining unused stores, and a successful lookup acquires a strong reference. Keys standardize the directory URL and resolve symlinks. Cross-process access is explicitly unsupported. |
| **4 — Protection timing/errors** | **Implementation addressed.** Folder and existing database/sidecars are protected before container creation; newly created files are checked afterward. Post-commit protection errors become `savedButUnprotected(entryID:)`, without rollback or false `saveFailed`. The ViewModel treats that outcome as committed, preserves newer draft text and displays a distinct warning. |
| **5 — Real failure paths** | **Addressed.** Hooks execute inside the production fetch/save error boundaries. Save faults occur after insert/update/delete mutations and reach the real `modelContext.rollback()`. Tests assert failed-create retry without duplication, failed-update preservation, failed-delete retention and reopening. Fetch faults verify `storeUnavailable` for load, update and delete. |

### Additional checks and evidence limits

The hand-written `ModelActor` conformance supplies the nonisolated container and executor required by the installed SwiftData interface. That interface provides `unownedExecutor` and `modelContext`; using `DefaultSerialModelExecutor` here does not establish a missing-executor defect. Store operations remain synchronous within actor isolation.

`ModelConfiguration` now explicitly specifies `cloudKitDatabase: .none`.

Some requested regression coverage remains absent: interrupted initialization, inaccessible established storage during reopening, canonical-path aliases, and concurrent update/delete through acquisition. The post-save protection test throws on the first file visited rather than specifically on a sidecar, and does not assert the error’s entry ID. These are coverage limitations, not additional demonstrated production defects.

The hooks exercise real rollback and error mapping, but do not reproduce an actual SQLite save failure, disk-full condition or process termination. Hardware protection attributes and lock/unlock behavior remain unverified.

## Verification

- Inspected `git diff HEAD~1..HEAD -- Circleu CircleuTests` and surrounding implementations/tests.
- Read project/shared coding standards, log protocol/template, MVP decisions, relevant plan and referenced local storage-spike records.
- Read installed SwiftData declarations for `ModelActor`, its default executor/context accessors and `DefaultSerialModelExecutor`.
- `git diff --check HEAD~1..HEAD -- Circleu CircleuTests`: exit zero; no whitespace findings.
- `git status --porcelain=v1`: clean. Final HEAD remained `8744bed049ede676fe17a0617d6ff20474133cb1`.
- Git emitted denied temporary-cache warnings but returned the requested data.
- **Reported evidence:** Claude reports 118 tests passed locally, with one device-only test skipped, using the CI signing configuration. Not independently rerun.
- Not run / limitations: no build, tests, network, Simulator or physical-device checks. Findings are static analysis. No files were written; this entry is supplied as Markdown only.

## Discussion and decisions

None. No direct inter-agent exchange occurred during this re-check. Claude’s fix and test report were supplied through the user and local commit.

This review does not authorize merge or release.

## Handoff

- Remaining work: Close the registry-construction bypass; restore the typed conflict assertion; run affected tests and record results for the revised commit.
- Owner: Claude for implementation follow-up; Mike for merge approval.
- Risks / unresolved questions: Single-owner enforcement remains bypassable until registry construction is restricted. Hardware protection and genuine storage-failure behavior remain separate validation work.

## Correction reference (if applicable)

This entry updates the [original review](2026-10-25-183148-codex-review-guest-journal-store.md) for commit `8744bed`: findings 1, 2, 4 and 5 are addressed at source level; finding 3 is substantially improved but remains open for the construction bypass above. Historical entries were not modified.