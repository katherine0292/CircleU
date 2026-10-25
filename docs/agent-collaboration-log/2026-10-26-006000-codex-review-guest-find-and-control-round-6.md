**2026-10-26 — Codex review, Round 6 — `38b7241` — guest batch B**

**Verdict: one remaining privacy BLOCKER in deletion’s failure path.** Reviewed `git show HEAD`, surrounding persistence/composition code and regression tests. No files edited.

| Round 5 finding | Status in HEAD |
|---|---|
| Legacy files survive Delete all and re-import | **Partial:** transactional adoption markers prevent resurrection; cleanup failure below remains. |
| Failed store read allows older draft overwrite | **Addressed in code:** throwing reads and an atomic existing-slot check preserve the newer draft. |
| Stale composer saves after Delete all | **Addressed in code:** generation mismatch rejects the save; regression test added. |
| Silent Practice adoption failure / inaccurate warning | **Partial:** both routes now warn, but can overwrite a more consequential storage warning. |
| DB commit per keystroke | **Partial:** queued bursts coalesce; ordinary spaced keystrokes still commit individually. |
| Migration/interruption tests | **Partial:** V3→V4 preservation coverage added; interruption and cold-reopen evidence remain incomplete. |

- **NEW BLOCKER — Delete all can report complete deletion while retaining legacy draft bytes.** At [SwiftDataGuestJournalStore.swift:462](<../../Circleu/Services/GuestJournal/SwiftDataGuestJournalStore.swift:462>), a post-commit protection error throws before legacy-file cleanup. [GuestFindAndControl.swift:243](<../../Circleu/Features/GuestJournal/GuestFindAndControl.swift:243>) catches that error as committed, leaving `leftovers = false`. With an unreadable legacy draft present and protection verification failing after the database save, its bytes remain while Settings reports “Everything … was deleted.” Markers prevent re-import, but do not erase the copy. Run cleanup after committed protection failures and report its actual outcome.

- **SHOULD-FIX — Preserve the actionable draft warning.** [GuestRootView.swift:52](<../../Circleu/Features/GuestJournal/GuestRootView.swift:52>) and `:56` replace restoration warnings whenever adoption is unsuccessful. If store reads also fail, draft keeping is disabled, but the replacement omits “new writing won’t be kept.” Preserve both warnings or prioritize that consequence.

- **SHOULD-FIX — Coalescing does not cover normal typing cadence.** [GuestJournalViewModel.swift:229](<../../Circleu/Features/GuestJournal/GuestJournalViewModel.swift:229>) and [GuestPracticeViewModels.swift:119](<../../Circleu/Features/GuestJournal/GuestPracticeViewModels.swift:119>) drain pending text immediately. Each subsequent key arriving after drainage schedules another commit. Add bounded batching with explicit flush behavior and a spaced-input test.

- **SHOULD-FIX — Exercise interruption boundaries.** [GuestFindAndControlTests.swift:225](<../../CircleuTests/GuestFindAndControlTests.swift:225>) recreates a leftover file but opens another session while the original store remains alive. Add genuine cold-reopen coverage around adoption/deletion commits, cleanup failure and the protection-error path above.

**Verification / limits:** `git diff --check HEAD^ HEAD` exited 0; working tree clean. No build, XCTest execution, process-crash injection, Simulator/UI, physical-device or live file-protection checks. Legacy account/cloud paths and unrelated UI-backlog changes were not substantively reviewed. Inter-agent exchanges: none.