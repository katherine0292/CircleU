**2026-10-25 23:59 +11:00 — Codex review, round 4 — `e197478` (`codex/guest-find-and-control`)**

**Verdict: BLOCKED.** Reviewed `git show HEAD`, recovery/save/delete callers and regression tests. No files edited.

| Finding | Status |
|---|---|
| **#2 Rollback errors** | **Partial:** failures now reach Settings, but draft writes resume after failed rollback. New typing can create a primary file that prevents the staged draft returning; “comes back next time” is not guaranteed. [GuestJournalViewModel.swift:209](<../../Circleu/Features/GuestJournal/GuestJournalViewModel.swift:209>) |
| **#3 Same-ID composers** | **Partial:** older composers cannot autosave over newer text. Save and cleanup remain unguarded; see new blocker below. |
| **#9 Export cleanup errors** | **Partial:** share-completion failures are surfaced. Startup still ignores cleanup failure, and failed export creation suppresses removal errors. [GuestRootView.swift:40](<../../Circleu/Features/GuestJournal/GuestRootView.swift:40>), [GuestFindAndControl.swift:222](<../../Circleu/Features/GuestJournal/GuestFindAndControl.swift:222>). **SHOULD-FIX remains.** |
| **#11 Tests** | **Partial:** added unknown-outcome and competing-autosave coverage. Missing rollback/cleanup failure, corrupt staged-file, repeated-delete and stale-composer Save regressions. [GuestFindAndControlTests.swift:363](<../../CircleuTests/GuestFindAndControlTests.swift:363>) |
| **#12 Staged recovery** | **Partial:** unreadable drafts now receive staging IDs; settlement errors propagate. However, directory-enumeration errors still become `[]`, falsely reporting recovery complete and allowing writes. [GuestDraftStore.swift:101](<../../Circleu/Services/GuestJournal/GuestDraftStore.swift:101>). **BLOCKER remains:** distinguish a missing directory from failed enumeration. |
| **#13 Write restored after receipt failure** | **Addressed by static inspection:** unknown receipt status leaves the draft hidden and disables persistence over it. [GuestJournalViewModel.swift:102](<../../Circleu/Features/GuestJournal/GuestJournalViewModel.swift:102>) |

**New BLOCKER #14 — Delete all misses previously staged drafts and can resurrect deleted content.**  
[GuestDraftStore.swift:82](<../../Circleu/Services/GuestJournal/GuestDraftStore.swift:82>), [SwiftDataGuestJournalStore.swift:363](<../../Circleu/Services/GuestJournal/SwiftDataGuestJournalStore.swift:363>).

After interrupted deletion, let launch receipt lookup fail: the staged file remains, with no primary file or in-memory `stagedID`. Once storage recovers, Delete all stages nothing and reports success. It also removes existing receipts without retaining that staged ID. Next launch interprets the leftover as unconsumed and restores it—even if the earlier deletion had committed. Account for every outstanding staged ID before committing another deletion; preserve receipts until corresponding copies are settled.

**New BLOCKER #15 — An older Practice composer can save stale text and erase the newer draft.**  
[GuestPracticeViewModels.swift:365](<../../Circleu/Features/GuestJournal/GuestPracticeViewModels.swift:365>), [GuestPracticeScreens.swift:269](<../../Circleu/Features/GuestJournal/GuestPracticeScreens.swift:269>).

Open two composers sharing a draft ID, edit the newer one, then Save from the older one. Save bypasses ownership validation; its cleanup removes the newer draft by shared ID. Its receipt also prevents the newer composer saving that ID. Extend ownership/version validation through Save and cleanup.

**Verification / limits:** `git diff --check HEAD^ HEAD` exited 0; working tree clean. Git emitted sandbox cache-write warnings. No build, XCTest execution, Simulator/UI, physical-device, file-protection or legacy/cloud checks. Earlier findings outside the six supplied were not re-reviewed. No inter-agent exchanges. Log returned here only; fixes and runtime verification remain unassigned.