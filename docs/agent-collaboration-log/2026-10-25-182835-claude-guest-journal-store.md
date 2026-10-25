# Guest journal store (SwiftData) — first slice step 2

- Recorded: 2026-10-25 18:28:35 +11:00; Australia/Sydney.
- Agent / role: Claude (Claude Code).
- Status: PR open for Codex review and owner approval; not merged.
- Base revision and branch: `codex/journal-store-swiftdata` from main.
- Related record: [first-slice plan](../superpowers/plans/2026-10-25-first-slice-typed-capture-local-journal.md), [storage spike and owner's SwiftData choice](../engineering/storage-spike-2026-10-25.md).

## Request and scope

Step 2 of the approved plan, using SwiftData as Mike chose: a guest journal store behind a protocol, Codex's three rules with tests, explicit Data Protection, and injected-failure tests. No UI, no app wiring, no legacy data or Firebase changes; iOS 17 minimum.

## Work and outcome

- `Circleu/Services/GuestJournal/GuestJournalStore.swift`: `GuestJournalStore` protocol, value-type entry, typed errors.
- `Circleu/Services/GuestJournal/SwiftDataGuestJournalStore.swift`: `@ModelActor` store with versioned schema V1 and migration plan.
  - **Rule 1:** a corrupt, unreachable or vanished store is an error (vanished detected via a setup marker), never an empty journal.
  - **Rule 2:** separate create and update; an update with an expected revision fails with `notFound` after delete.
  - **Rule 3:** actor isolation serializes each read-check-write.
  - **Data Protection:** `.completeUnlessOpen` applied strictly on open to the folder, store and sidecars, and best-effort on sidecars after each save.
- `Circleu/Features/GuestJournal/GuestJournalViewModel.swift`: load/failed states; a failed save keeps the draft and shows "Couldn't save. Try again."
- Nothing in the app references these types yet. The hidden developer switch and guest composition root are step 3.

## Verification

- `xcodebuild test` of `Circleu` with the CI signing config (Xcode 27.1, iPhone 17 / iOS 26.5 Simulator): 109 passed (96 existing + 13 new).
- The new device-only Data Protection test is skipped on the Simulator.
- Not run: the device test (it would install a Circleu build on the owner's phone; needs his go-ahead and a separate bundle ID), disk-full, real process kill.

## Discussion and decisions

Codex review requested (read-only); its verdict will be recorded in its own entry.

## Handoff

- Remaining work: Codex review; owner merge go-ahead; device protection check; step 3 (guest root behind the developer switch).
- Owner: Mike.
