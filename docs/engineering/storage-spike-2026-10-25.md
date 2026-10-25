# Storage spike: SwiftData vs versioned JSON files

25 October 2026. A bounded spike for the [first slice plan](../superpowers/plans/2026-10-25-first-slice-typed-capture-local-journal.md), approved by Mike ("short storage test first, then pick"). The code is isolated in [`Prototypes/StorageSpike`](../../Prototypes/StorageSpike), a separate Swift package not linked into the Circleu app. It uses invented entries only. **No feature code; the choice is Mike's.**

Both options implement the same `EntryRepository` (load newest first, save with a stable ID and revision, delete, typed errors) and run the same relaunch → edit → stale-edit → delete test.

## Results

`xcodebuild test -scheme StorageSpike` on the iPhone 18 Pro / iOS 27.0 Simulator and `swift test` on macOS: **11 tests, 0 failures** on both. Observations:

| Criterion | Versioned JSON file (atomic write) | SwiftData (versioned schema) |
| --- | --- | --- |
| Save, relaunch, edit, reopen | ✅ stable ID; revision 0 → 1; stale edit rejected | ✅ same |
| Corrupt store | ✅ asserted: `unreadable` on load **and** save; corrupt bytes untouched | Observed (logged, not asserted): container failed with an error; bytes untouched. Core Data logs "attempting recovery" first |
| Never an empty journal on a failed read | Partly: malformed data and an unknown schema give errors. **Gap:** an inaccessible folder or a vanished established store currently reads as empty (Codex finding 1) | Observed for corruption only; a fetch failure after opening wasn't exercised |
| Interrupted write | Only that a stray temp file is ignored; a real write was **not** interrupted | Not simulated; relies on SQLite transactions |
| Write failure | ✅ read-only folder → `writeFailed`, previous version intact | ⚠️ could not be provoked: open SQLite handles ignore later permission changes. Disk-full not tested for either option |
| Schema versioning / migration | ✅ schema 1 → 2 in code, IDs kept; unknown future schema refused | ✅ V1 → V2 lightweight migration (renamed field, new defaults) kept data and IDs |
| Data Protection | Set explicitly on every write (`.completeFileProtection`, one file, no sidecars). **Unverified:** the Simulator reports no protection class | Store plus `-wal`/`-shm` sidecars; `ModelConfiguration` has no file-protection option, so it would need folder-level or Core Data configuration. **Unverified** on Simulator |
| Testability | Plain value types and temp folders; easier to inspect and inject failures into | Works in temp folders; some failure paths hard to provoke |
| iOS 17 | Declared minimum (Foundation only); runs observed on iOS 27 Simulator and macOS only | Declared minimum (SwiftData is iOS 17+); same runs |
| Complexity | ~110 lines; still needs one serialized writer (Codex finding 3) | `@Model` classes, contexts, migration plan, context isolation |

## Recommendation

**Use versioned JSON files behind the `EntryRepository` protocol for the first slice.**

- **Why:** the plan's safety rules (failed reads never shown as empty, failed saves keep the text, corrupt data preserved, explicit schema, complete file protection) are straightforward to implement and test on a plain file format, with a small dependency surface. The spike does **not** show JSON is more durable than SwiftData.
- **Size (hypothesis):** a personal journal of hundreds to low thousands of short entries should fit in one atomically rewritten file. This needs a measurement in the slice.
- **Switching later:** the protocol keeps SwiftData (or one file per entry) open as an option if the journal grows or Practice links need queries.

Trade-offs to accept:
- The whole file is rewritten on each save.
- Migrations are hand-written code, though small and tested.
- Search and filtering run in memory, which is fine at this size.

## Owner decision — 25 October

**Mike chose SwiftData** for the first slice, rather than the recommended JSON files. The trade-offs noted above are accepted and must be handled in the production store:
- explicit Data Protection on the store and its `-wal`/`-shm` sidecars;
- failure paths tested through injected failures, since SwiftData's own write failures are hard to provoke;
- fetch errors surfaced rather than turned into "not found";
- `updatedAt` backfilled in future migrations;
- the Codex rules below.

## Codex review: production requirements

[Codex reviewed the spike](../agent-collaboration-log/2026-10-25-181218-codex-review-storage-spike.md) (read-only). Its verdict: nothing blocks presenting this recommendation, but the spike isn't production-ready. The production repository must add:

1. Only a confirmed missing, never-initialised store counts as empty; permission, protection and I/O failures, and a vanished established store, are errors.
2. Separate **create** and **update(expectedRevision:)**: updating a deleted entry must fail, not resurrect it.
3. **One serialized writer** per store, so concurrent edits or inserts can't overwrite each other.
4. Failure injection at the real write, plus delete-failure tests.
5. Migration tests covering all fields and ordering.
6. A size/timing measurement.
7. Physical-iPhone Data Protection checks.

(For SwiftData, if reconsidered: surface fetch errors on delete, and backfill `updatedAt` during migration.)

## Limits and follow-up

- **Data Protection:** must be verified on a physical iPhone (file attribute `.complete`, locked-device read behaviour) during the slice. The Simulator can't show it.
- **Not covered:** disk-full, real process kill during write, and performance at large sizes. Add a size and timing check (e.g. 2,000 entries) in the slice's repository tests.
- **Spike scope:** the spike doesn't touch legacy `UserDefaults` keys, Firebase or the app target. The production repository will be written fresh in `Circleu/Services/` with its own tests; spike code isn't promoted as is.
