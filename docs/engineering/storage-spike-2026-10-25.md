# Storage spike: SwiftData vs versioned JSON files

25 October 2026. A bounded spike for the [first slice plan](../superpowers/plans/2026-10-25-first-slice-typed-capture-local-journal.md), approved by Mike ("short storage test first, then pick"). The code is isolated in [`Prototypes/StorageSpike`](../../Prototypes/StorageSpike), a separate Swift package not linked into the Circleu app. It uses invented entries only. **No feature code; the choice is Mike's.**

Both options implement the same `EntryRepository` (load newest first, save with a stable ID and revision, delete, typed errors) and run the same relaunch → edit → stale-edit → delete test.

## Results

`xcodebuild test -scheme StorageSpike` on the iPhone 18 Pro / iOS 27.0 Simulator and `swift test` on macOS: **11 tests, 0 failures** on both. Observations:

| Criterion | Versioned JSON file (atomic write) | SwiftData (versioned schema) |
| --- | --- | --- |
| Save, relaunch, edit, reopen | ✅ stable ID; revision 0 → 1; stale edit rejected | ✅ same |
| Corrupt store | ✅ `unreadable` on load **and** save; corrupt bytes untouched | ✅ container fails with an error; bytes untouched. Core Data logs "attempting recovery" first |
| Never an empty journal on a failed read | ✅ missing file = first launch; unreadable or future schema = error | ✅ load error surfaced (in this test) |
| Interrupted write | ✅ partial temp file without rename → previous version loads | Not simulated; relies on SQLite transactions (well established, not exercised here) |
| Write failure | ✅ read-only folder → `writeFailed`, previous version intact | ⚠️ could not be provoked: open SQLite handles ignore later permission changes. Disk-full not tested for either option |
| Schema versioning / migration | ✅ schema 1 → 2 in code, IDs kept; unknown future schema refused | ✅ V1 → V2 lightweight migration (renamed field, new defaults) kept data and IDs |
| Data Protection | Set explicitly on every write (`.completeFileProtection`, one file, no sidecars). **Unverified:** the Simulator reports no protection class | Store plus `-wal`/`-shm` sidecars; `ModelConfiguration` has no file-protection option, so it would need folder-level or Core Data configuration. **Unverified** on Simulator |
| Testability | Plain value types, temp folders, every failure path easy to provoke | Works in temp folders; some failure paths hard to provoke |
| iOS 17 | ✅ Foundation only | ✅ SwiftData is iOS 17+ (early versions had known issues) |
| Complexity | ~130 lines, no framework concurrency rules | `@Model` classes, contexts, migration plan, main-actor considerations |

## Recommendation

**Use versioned JSON files behind the `EntryRepository` protocol for the first slice.**

- **Why:** every safety rule in the plan (failed reads never shown as empty, failed saves keep the text, corrupt data preserved, explicit schema, complete file protection) is simple and fully testable.
- **Size:** a personal journal of hundreds to low thousands of short entries fits comfortably in one atomically rewritten file.
- **Switching later:** the protocol keeps SwiftData (or one file per entry) open as an option if the journal grows or Practice links need queries.

Trade-offs to accept:
- The whole file is rewritten on each save.
- Migrations are hand-written code, though small and tested.
- Search and filtering run in memory, which is fine at this size.

## Limits and follow-up

- **Data Protection:** must be verified on a physical iPhone (file attribute `.complete`, locked-device read behaviour) during the slice. The Simulator can't show it.
- **Not covered:** disk-full, real process kill during write, and performance at large sizes. Add a size and timing check (e.g. 2,000 entries) in the slice's repository tests.
- **Spike scope:** the spike doesn't touch legacy `UserDefaults` keys, Firebase or the app target. The production repository will be written fresh in `Circleu/Services/` with its own tests; spike code isn't promoted as is.
