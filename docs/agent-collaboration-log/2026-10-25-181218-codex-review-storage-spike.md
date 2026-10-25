# Codex review of storage spike

- Recorded: 2026-10-25 18:12:18 +11:00; Australia/Sydney
- Agent / role: Codex, reviewer
- Status: completed — read-only review; findings unresolved
- Base revision and branch: `codex/storage-spike` at `aad2523040194271fa198d648e7398ff1ecac191`, compared with locally cached `origin/main` at `67b26c4dc4ac6ad82a0a6738a7188c5d4813de99`, also the merge base. Working tree clean.
- Related record / task / PR: [Storage spike record](2026-10-25-175017-claude-storage-spike.md); [first-slice plan](../superpowers/plans/2026-10-25-first-slice-typed-capture-local-journal.md); [results](../engineering/storage-spike-2026-10-25.md).

**Verdict: Nothing blocks presenting versioned JSON behind a repository protocol as a provisional recommendation to Mike, provided the qualifications below accompany it. The results table overstates some evidence. The spike is not ready for production promotion.**

## Request and scope

Review only `Prototypes/StorageSpike/Package.swift`, its Sources and Tests, and `docs/engineering/storage-spike-2026-10-25.md` against `origin/main`. Assess test evidence, persistence correctness, and the recommendation.

Read `AGENTS.md`, the log README/TEMPLATE, project and shared coding standards, MVP decisions, the relevant plan, and relevant recent records. Used local Git and file reads only. No network, builds, tests, file modifications, or agent delegation.

## Work and outcome

### Severity-ranked findings

Severity describes the consequence if the approach were promoted, except where explicitly identified as a documentation issue.

1. **High — An inaccessible file can be classified as an empty journal.**  
   [FileEntryRepository.swift:74](</Users/tuannm3812/Documents/GitHub/3. Personal/CircleU/Prototypes/StorageSpike/Sources/StorageSpike/FileEntryRepository.swift:74>) returns `[]` whenever `fileExists` returns false. This Boolean does not distinguish absence from failure to determine existence, such as an inaccessible parent directory. It also treats disappearance of an established store as first launch. This contradicts the broad failed-read guarantee; the corrupt-JSON test does not exercise this path.  
   **Proposed fix:** Attempt the read directly and inspect the underlying error. Treat only a confirmed missing store in the intended initialization state as empty; surface permission, protection and I/O failures. Define the policy for a previously initialized store disappearing. Add inaccessible-parent and missing-established-store tests.

2. **High — Saving an edit after deletion resurrects the entry.**  
   [FileEntryRepository.swift:58](</Users/tuannm3812/Documents/GitHub/3. Personal/CircleU/Prototypes/StorageSpike/Sources/StorageSpike/FileEntryRepository.swift:58>) and [SwiftDataEntryRepository.swift:98](</Users/tuannm3812/Documents/GitHub/3. Personal/CircleU/Prototypes/StorageSpike/Sources/StorageSpike/SwiftDataEntryRepository.swift:98>) insert any absent ID and reset its revision to zero. An editor can load an entry, another screen can delete it, and the editor's later save recreates it. This occurs sequentially and does not require concurrent execution. Rejecting only nonzero revisions would still miss deleted revision-zero entries.  
   **Proposed fix:** Distinguish creation from updating an existing entry, such as `create` and `update(expectedRevision:)`. An update of a missing ID must fail. Add save → load editor → delete → save editor tests for both implementations, including revision zero.

3. **High — Atomic replacement does not make revision checks atomic.**  
   [FileEntryRepository.swift:49](</Users/tuannm3812/Documents/GitHub/3. Personal/CircleU/Prototypes/StorageSpike/Sources/StorageSpike/FileEntryRepository.swift:49>) reads, checks and rewrites without serialization. Two callers can read the same revision, both pass, and overwrite each other's changes. Two inserts can also lose one entry because each replaces the entire document. [SwiftDataEntryRepository.swift:82](</Users/tuannm3812/Documents/GitHub/3. Personal/CircleU/Prototypes/StorageSpike/Sources/StorageSpike/SwiftDataEntryRepository.swift:82>) similarly separates its revision check from saving in independent contexts, without an enforced isolation contract. The sequential stale-edit test does not establish concurrent conflict protection.  
   **Proposed fix:** Establish one serialized repository owner per store and execute the complete read/check/mutate/commit operation within that boundary. Enforce appropriate SwiftData context isolation if retained. Multiple instances or processes need additional coordination or must be explicitly unsupported. Test competing edits, different-ID inserts, and save/delete interleavings.

4. **Medium — SwiftData deletion hides read failures as `notFound`.**  
   [SwiftDataEntryRepository.swift:109](</Users/tuannm3812/Documents/GitHub/3. Personal/CircleU/Prototypes/StorageSpike/Sources/StorageSpike/SwiftDataEntryRepository.swift:109>) uses `try?` around fetching. Both a failed fetch and a successful fetch with no row become `notFound`. A caller cannot distinguish unavailable storage from an absent entry and might incorrectly treat the result as successful idempotent deletion.  
   **Proposed fix:** Catch fetch errors as `unreadable`; reserve `notFound` for a successful empty fetch. Add separate assertions for both outcomes and for a failed delete commit preserving the entry.

5. **Medium — SwiftData migration loses meaningful ordering timestamps.**  
   [SwiftDataEntryRepository.swift:31](</Users/tuannm3812/Documents/GitHub/3. Personal/CircleU/Prototypes/StorageSpike/Sources/StorageSpike/SwiftDataEntryRepository.swift:31>) defaults migrated `updatedAt` values to `Date.distantPast`; the lightweight migration does not backfill from `createdAt`. Since loading sorts by `updatedAt`, migrated entries all tie instead of retaining their prior chronology. JSON explicitly maps `updatedAt = createdAt`. The SwiftData migration test checks only text and ID.  
   **Proposed fix:** Backfill the timestamp through a suitable migration stage. Test multiple entries with distinct creation dates, revision defaults, ordering, and reopening after migration. Strengthen JSON migration assertions to verify timestamps and all old entries after the V2 rewrite.

6. **Medium — Some passing tests cannot establish the claimed safety outcomes.**  
   [StorageSpikeTests.swift:69](</Users/tuannm3812/Documents/GitHub/3. Personal/CircleU/Prototypes/StorageSpike/Tests/StorageSpikeTests/StorageSpikeTests.swift:69>) creates an unrelated partial file after a successful save; it never interrupts the repository's writer. [StorageSpikeTests.swift:139](</Users/tuannm3812/Documents/GitHub/3. Personal/CircleU/Prototypes/StorageSpike/Tests/StorageSpikeTests/StorageSpikeTests.swift:139>) prints the SwiftData corruption outcome without asserting failure or byte preservation. The SwiftData write-failure and protection probes likewise log observations without enforcing the advertised outcomes. Therefore “11 tests, 0 failures” is not eleven verified safety guarantees.  
   **Proposed fix:** Relabel the interruption row as “stray temporary file ignored; writer interruption untested.” Label SwiftData corruption as a reported observation until assertions and retained run evidence support it. Add assertions for expected errors and byte preservation, and inject failures at actual write/commit boundaries. Keep genuine process termination, disk-full and hardware protection as separate checks.

7. **Low — The comparison presents assumptions as established advantages.**  
   [storage-spike-2026-10-25.md:20](</Users/tuannm3812/Documents/GitHub/3. Personal/CircleU/docs/engineering/storage-spike-2026-10-25.md:20>) says every JSON failure path is easy to provoke, despite the admitted gaps. The “no framework concurrency rules” description can obscure the serialization requirement. Lines 21 and 29 imply platform and capacity confidence beyond the reported environments and fixtures.  
   **Proposed fix:** Describe JSON as easier to inspect and inject failures into, with required concurrency ownership. Label iOS 17 as declared compatibility rather than tested runtime support; remove or substantiate the vague “early versions had known issues” comparison. Treat comfortable capacity at thousands of entries as a hypothesis pending representative measurements.

### Results-table evidence audit

References below refer to `Prototypes/StorageSpike/Tests/StorageSpikeTests/StorageSpikeTests.swift`. Test execution results remain inherited reports, not independently rerun evidence.

| Results-table row | What the checked-in tests support |
| --- | --- |
| Save, relaunch, edit, reopen | Lines 24–55 assert fresh-instance loading, stable ID, revision increment, sequential stale-edit rejection, edited text reopening and deletion. “Relaunch” means reconstructing repositories within one process, not terminating the app. Multiple-entry ordering is untested. |
| Corrupt store | Lines 59–65 assert JSON load failure, save failure and unchanged corrupt bytes. SwiftData lines 139–152 only print whether opening failed and bytes survived; the test would also pass if it opened empty or changed the bytes. |
| Never an empty journal on a failed read | JSON malformed data and an unknown version are covered, plus ordinary first launch. Permission/protection failures are not; finding 1 defeats the universal claim. SwiftData corruption is observational, and a post-initialization fetch failure is not exercised. |
| Interrupted write | Lines 69–75 establish only that an unrelated partial file does not affect reading the intact journal. No repository write is interrupted. SwiftData is correctly marked untested. |
| Write failure | Lines 79–87 assert a JSON save failure under directory permissions and preservation of prior content. They do not establish disk-full behavior, delete failure, or failure during replacement. SwiftData's unsuccessful attempt to provoke failure is correctly disclosed. |
| Schema versioning / migration | JSON lines 91–104 check old text/ID, a V2 marker after saving, and rejection of version 9 on load. They do not check all migrated fields after reopening or future-version save preservation. SwiftData lines 122–135 check old text/ID only; defaults and chronology are not asserted. |
| Data Protection | JSON source requests `.completeFileProtection` on iOS writes. Its attribute assertion runs only on physical iOS devices, outside the reported runs. SwiftData prints attributes without assertions. Neither establishes locked-device behavior or protection of temporary/sidecar files. The explicit “unverified” labels are appropriate. |
| Testability | Value types and temporary directories are visible architectural properties. “Every failure path easy to provoke” exceeds the evidence. |
| iOS 17 | The package declares iOS 17/macOS 14 minimums. The report names iOS 27 Simulator and macOS runs, so iOS 17 runtime behavior is not established. |
| Complexity | Approximately 110 lines for the JSON implementation is accurate. Its smaller framework surface is a reasonable qualitative advantage, but it still requires concurrency control, migration validation and failure handling. |

### Recommendation and production requirements

Versioned JSON behind an injected protocol is a defensible choice for this bounded, local, typed-entry slice. The document format and migrations are inspectable, the dependency surface is small, and the existing assertions demonstrate useful basic behavior. The spike does **not** establish superior durability to SwiftData or measured capacity at thousands of entries.

The production slice must add:

- The error, lifecycle and serialization contracts identified above, including explicit create/update semantics and deletion conflict policy.
- A durable, separate storage namespace with explicit directory creation and failure handling. Legacy keys and bytes must remain untouched.
- Draft persistence and tests for draft-to-entry save transitions, retries and duplicate taps. Repository errors must preserve editor text and keep failed deletions visible.
- Schema validation, including unique IDs and valid revisions, complete migration round trips, future-version refusal without mutation, and preservation of original bytes when migration cannot commit.
- Failure injection around the actual writer, assertions that failed saves/deletes preserve committed data, and interrupted-write/disk-full checks. Atomic replacement alone is not evidence of durability under every termination or storage failure.
- Physical-iPhone protection checks on creation and replacement, lock/unlock reads and writes, and any temporary or recovery artifacts. If SwiftData is reconsidered, include its store and sidecars. Verify migrated files as well as newly created ones.
- Representative size, latency and memory measurements before accepting the capacity claim.
- The plan's debug-only guest composition root, no-cloud-construction test, explicit loading/empty/error states, and Simulator/phone capture → save → edit → reopen checks.

The protocol makes replacing the implementation easier; changing the persisted format later still requires a data migration.

## Verification

- `git status --short`, `git branch --show-current`, and `git rev-parse HEAD origin/main codex/storage-spike`: confirmed branch, revisions and clean checkout.
- `git merge-base origin/main codex/storage-spike`: confirmed cached `origin/main` is the comparison base.
- `git diff origin/main...codex/storage-spike -- Prototypes/StorageSpike docs/engineering/storage-spike-2026-10-25.md`: inspected the complete scoped change.
- Read the manifest, both implementations, protocol/model, all 11 test methods and results document; traced each table row to assertions or observational logging.
- `git diff --check origin/main codex/storage-spike -- Prototypes/StorageSpike docs/engineering/storage-spike-2026-10-25.md`: no whitespace findings; exit zero.
- Final `git status --porcelain=v1`: clean.
- Git emitted sandbox-denied temporary-cache warnings but returned the requested comparison data.
- Not run / limitations: no builds, tests, network, Simulator or physical-device checks, per instruction. The reported 11 passing tests on each platform were not independently verified. No files were written; this entry is supplied as Markdown only.

## Discussion and decisions

None. No inter-agent exchange occurred during this review.

Mike's storage-spike approval is supplied by the current request. The JSON recommendation remains an agent recommendation awaiting Mike's choice; this review does not authorize production implementation.

## Handoff

- Remaining work: Present the recommendation with these qualifications; narrow the results-table wording and distinguish observations from assertions. Address the production requirements before promoting either implementation.
- Owner: Mike for storage choice; implementation and documentation follow-up unassigned.
- Risks / unresolved questions: Serialized writer ownership, missing-store policy, deletion resurrection, migration chronology, hardware protection, actual interrupted-write/disk-full behavior, and representative performance remain unresolved.

## Correction reference (if applicable)

This review qualifies the evidence summarized in the [original storage-spike record](2026-10-25-175017-claude-storage-spike.md) and [results document](../engineering/storage-spike-2026-10-25.md). The reported passing test counts are not disputed; static inspection shows that some methods record observations rather than assert safety properties, and the interrupted-write fixture does not interrupt a write. Historical records were not modified.