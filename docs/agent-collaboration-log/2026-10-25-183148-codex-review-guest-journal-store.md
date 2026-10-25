# Codex review of guest journal store (PR #10)

- Recorded: 2026-10-25 18:31:48 +11:00; Australia/Sydney
- Agent / role: Codex, reviewer
- Status: completed — read-only review; changes requested
- Base revision and branch: `codex/journal-store-swiftdata` at `2a7b630e72484f4001075606bbdcaa9eaa0df09b`, versus locally cached `origin/main` at `67b26c4dc4ac6ad82a0a6738a7188c5d4813de99`, also the merge base. Working tree clean.
- Related record / task / PR: PR #10; [implementation record](2026-10-25-182835-claude-guest-journal-store.md); [first-slice plan](../superpowers/plans/2026-10-25-first-slice-typed-capture-local-journal.md).

**Verdict: BLOCKS merge. Established-store disappearance can become an empty journal, saving can erase newer draft text, and serialization is enforced per actor rather than per store. Resolve findings 1–4 and add the failure-path evidence in finding 5 before merging.**

## Request and scope

Reviewed only `git diff origin/main...HEAD` for:

- `Circleu/Services/GuestJournal/*`
- `Circleu/Features/GuestJournal/GuestJournalViewModel.swift`
- `CircleuTests/GuestJournalStoreTests.swift`
- The new implementation log entry.

Read `AGENTS.md`, project and shared coding standards, log README/TEMPLATE, MVP decisions and the first-slice plan. The requested storage-spike document and earlier Codex review are absent from this checkout; read both using `git show codex/storage-spike:<path>` at `49b9bcd814549aa8bf4ee4da968f9010e95191f1`, including the referenced spike log.

Used local Git and file reads only. No network, builds, tests, file writes or agent delegation.

## Work and outcome

### Severity-ranked findings

1. **High — Losing the journal directory silently creates a fresh, empty journal.**  
   [SwiftDataGuestJournalStore.swift:59](</Users/tuannm3812/Documents/GitHub/3. Personal/CircleU/Circleu/Services/GuestJournal/SwiftDataGuestJournalStore.swift:59>) places the initialization marker inside the directory whose disappearance it must detect. After saving and closing, removing or losing that directory removes both database and marker. `open` recreates the directory, sees neither file, and initializes a new database. This violates rule 1. The vanished-store test deliberately preserves the marker and misses this case. Also, `fileExists` cannot distinguish confirmed absence from inaccessible metadata.

   **Fix:** Keep initialization evidence outside the replaceable journal directory in a separate guest-only metadata location. Distinguish confirmed first use, missing established storage and metadata-access failures through throwing filesystem operations. Add whole-directory-loss, inaccessible-established-store and initialization-interruption tests. Opening an established but missing store must not recreate it.

2. **High — A successful save erases text entered while the save is suspended.**  
   [GuestJournalViewModel.swift:47](</Users/tuannm3812/Documents/GitHub/3. Personal/CircleU/Circleu/Features/GuestJournal/GuestJournalViewModel.swift:47>) awaits `create`, then unconditionally clears `draft`. During that suspension, the main actor can accept another edit through the publicly writable property. The store saves the earlier snapshot, then the completion deletes the newer text. `isSaving` prevents another save invocation; it does not prevent editing.

   **Fix:** Capture a draft generation alongside the submitted text and clear only that unchanged generation after success, or enforce editing restrictions in the model contract. Add a controllably suspended store test: submit A, change the draft to B, complete A, and assert that B remains.

3. **High — Multiple actors can independently write the same store.**  
   [SwiftDataGuestJournalStore.swift:70](</Users/tuannm3812/Documents/GitHub/3. Personal/CircleU/Circleu/Services/GuestJournal/SwiftDataGuestJournalStore.swift:70>) creates a fresh container and actor on every `open(directory:)`. Two callers can open the same URL and obtain independent contexts, revision checks and executors. `@ModelActor` serializes each instance, but does not establish the required single writer for that database. The revision predicate is checked before saving, rather than enforced as a database compare-and-swap. All concurrency tests use one instance.

   **Fix:** Enforce one owner per canonical store URL: reuse an existing actor or reject a second live owner, with serialized initialization. Constrain construction so callers cannot bypass that ownership boundary. Explicitly document unsupported cross-process access. Test simultaneous opens, competing edits and update/delete interleavings through the supported acquisition path.

4. **Medium — Protection failures after saving are silently discarded.**  
   [SwiftDataGuestJournalStore.swift:142](</Users/tuannm3812/Documents/GitHub/3. Personal/CircleU/Circleu/Services/GuestJournal/SwiftDataGuestJournalStore.swift:142>) suppresses every error from applying protection after a commit. If applying the required class to a newly created sidecar fails, the operation still reports ordinary success. Initial protection also runs only after container creation, allowing opening or migration to happen before the directory and existing files receive the requested protection.

   **Fix:** Protect the directory before constructing the container and protect existing store files before opening them. Establish and verify protection for newly created sidecars. Surface a protection failure distinctly from an uncommitted save failure, preserving the committed entry identity so retry cannot duplicate it. Add failure injection specifically after opening and during sidecar protection; do not silently downgrade the protection requirement.

5. **Medium — Failure injection does not exercise the production persistence failure paths.**  
   [GuestJournalStoreTests.swift:196](</Users/tuannm3812/Documents/GitHub/3. Personal/CircleU/CircleuTests/GuestJournalStoreTests.swift:196>) injects save failure only in `StubJournalStore`, bypassing `SwiftDataGuestJournalStore.commit()` entirely. Consequently, these tests do not establish rollback after failed create/update/delete, preservation of previously committed data, or production fetch-error mapping. There is no failed-delete test. These were explicit production requirements in the spike review.

   **Fix:** Introduce a narrow injectable persistence boundary that exercises the real store’s error handling and rollback. Assert typed errors, unchanged persisted content after reopening, failed-delete retention, and successful retry without duplication. Inject fetch failure separately from a successful fetch returning no row.

### Three-rule and concurrency assessment

| Requirement | Static assessment |
| --- | --- |
| Storage failure never becomes empty | Fetch/open exceptions are mapped to errors, and the ViewModel has a failed state. Whole-directory disappearance violates the broader contract; established-store access failures after opening remain untested. |
| Update after delete cannot resurrect | Correct within one store actor: update fetches an existing row, checks its revision and never inserts. The revision-zero deletion test asserts this useful case. Multiple-owner behavior remains unresolved. |
| Serialized saves, including reentrancy | Each actor’s fetch/check/mutate/save path is synchronous with no suspension points, so actor reentrancy does not split that operation. The `await remember` occurs before the factory returns. Serialization across independently opened actors is not enforced. |

The app and test targets specify `SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor`. The value types, protocol and schema declarations explicitly opt out where declared; the ViewModel is explicitly main-actor isolated. Context access and model mutation stay inside the model actor, and callers receive `Sendable` values rather than managed objects. No additional definite isolation defect was established by this static review; macro expansion and compiler diagnostics were not checked.

The installed SDK’s `_Concurrency` interface supplies an async `Result.init(catching:)` overload. Therefore the competing-edits test’s `async let … = Result { try await … }` syntax is **not** a finding. An initial commentary concern based only on the synchronous standard-library overload was withdrawn.

### Data Protection, errors and coupling

`.completeUnlessOpen` is an intentional tradeoff: an already-open store can continue operating when the device locks. It does not promise that locking immediately revokes access to open journal handles. That distinction should replace the spike’s older `.complete` validation wording.

The implementation explicitly requests `.completeUnlessOpen` for the folder, database and existing `-wal`/`-shm` files. Finding 4 concerns when that happens and what follows failure. Neither callback observation nor unlocked attribute inspection establishes locked-device behavior.

Error mapping otherwise improves on the spike: fetch exceptions become `storeUnavailable`, successful empty fetches become `notFound`, revision mismatches remain distinct, and failed saves invoke rollback before returning `saveFailed`. These production failure paths still need assertions.

No legacy `UserDefaults` reads/writes or Firebase construction appear in the scoped implementation. The new services are not wired into the app, so this does not establish guest startup isolation. As a local-only configuration hardening step, explicitly set `cloudKitDatabase: .none`; the installed SDK shows that `ModelConfiguration(url:)` defaults to `.automatic`. No actual CloudKit activity was established.

### Test-evidence audit

| Tests | What their assertions establish, if executed successfully |
| --- | --- |
| First launch; create/reopen/edit | Empty initial storage and an initial saved entry surviving container recreation; stable ID, revision increment and edited text in the reopened context. They do not reopen again after the edit or verify timestamps and ordering. |
| Update after delete | Missing revision-zero updates and repeated deletes fail; the same actor sees an empty journal afterward. |
| Competing edits; concurrent creates | One winner and one stale-revision error for two edits through one actor; 20 distinct submitted strings remain. No multiple-owner or save/delete interleaving coverage. |
| Corruption | Explicitly asserts opening fails and corrupt database bytes remain unchanged. |
| Vanished/unreachable storage | Database disappearance with an intact marker, and an inaccessible parent during opening. Neither covers disappearance of the entire initialized directory. |
| Protection callback | Records application attempts to the folder/store and sidecars present at inspection. It does not assert actual protection attributes or post-open protection failures. |
| Device protection | Checks matching file attributes on hardware; does not check the directory attribute or lock/unlock access behavior. Skipped on Simulator. |
| ViewModel failure/success | Explicit failed-load state, draft retention after a stub save error, and ordinary successful saving. No suspended-save editing coverage or real persistence rollback coverage. |

There are 14 new test methods, including one Simulator-skipped hardware method. The implementation log’s “13 new” passing tests is numerically compatible with that skip, but its reported run was not independently verified.

## Verification

- `git status --short`, `git branch --show-current`, `git rev-parse HEAD origin/main`, and `git merge-base origin/main HEAD`: confirmed the branch, comparison revisions and clean checkout.
- `git diff origin/main...HEAD -- Circleu/Services/GuestJournal Circleu/Features/GuestJournal/GuestJournalViewModel.swift CircleuTests/GuestJournalStoreTests.swift docs/agent-collaboration-log`: inspected all scoped changes.
- Read the required documents, referenced local-branch evidence, project isolation settings, and installed Swift/SwiftData SDK interfaces.
- `git diff --check origin/main...HEAD -- Circleu/Services/GuestJournal Circleu/Features/GuestJournal/GuestJournalViewModel.swift CircleuTests/GuestJournalStoreTests.swift docs/agent-collaboration-log/2026-10-25-182835-claude-guest-journal-store.md`: exit zero; no whitespace findings.
- Final `git status --porcelain=v1`: clean.
- Git emitted denied temporary-cache warnings but returned the requested data.
- Not run / limitations: no build, tests, network, Simulator, physical-device, disk-full or process-kill checks. Cached remote references were not refreshed. Findings are static analysis, not reproduced runtime results. No files were written; this entry is supplied as Markdown only.

## Discussion and decisions

None. No inter-agent exchange occurred during this review.

Mike’s SwiftData choice is confirmed by the user’s request and the locally read spike decision. This review does not reopen that choice or authorize implementation, merge or release.

## Handoff

- Remaining work: Fix findings 1–4; add the production failure assertions in finding 5 and regression tests for each fix. Run affected tests against the revised commit and append exact verification evidence. Complete physical-device protection checks separately.
- Owner: Unassigned for implementation and verification; Mike for merge approval.
- Risks / unresolved questions: Whole-directory loss, multiple live store owners, protection failure after commit, edits during suspended saves, actual rollback behavior and hardware lock/unlock behavior.

## Correction reference (if applicable)

This review qualifies the claims in the [implementation record](2026-10-25-182835-claude-guest-journal-store.md): rule 1 is not satisfied for whole-directory disappearance; rule 3 is enforced only within one actor; injected save errors currently establish ViewModel behavior rather than production rollback. The reported test run remains inherited evidence. Historical entries were not modified.