**2026-10-25 23:50 +11:00 — Codex review, round 3 — `8c6482b` (`codex/guest-find-and-control`)**

**Verdict: BLOCKER #12 remains partially addressed; new BLOCKER #13.** Reviewed `git show HEAD`, surrounding recovery/navigation code and tests. No files edited.

| Round-2 finding | Status |
|---|---|
| **#2 — Finalization / rollback failures** | **Partial.** Committed deletion now clears in-memory drafts before cleanup. Rollback errors remain suppressed at [GuestFindAndControl.swift:265](<../../Circleu/Features/GuestJournal/GuestFindAndControl.swift:265>), without reporting failed draft restoration. |
| **#3 — Competing composers** | **Partial.** Different IDs are guarded, but two screens restoring the **same ID** bypass [GuestPracticeViewModels.swift:99](<../../Circleu/Features/GuestJournal/GuestPracticeViewModels.swift:99>). Open a linked draft in Journal, continue it in Practice, edit wording there, then change Goal in the original composer: its stale wording replaces the newer draft. |
| **#4 — Failed receipt lookup** | **Addressed for Practice, statically.** Lookup failure withholds the draft and disables persistence at [GuestPracticeViewModels.swift:77](<../../Circleu/Features/GuestJournal/GuestPracticeViewModels.swift:77>). Write remains unsafe; see #13. |
| **#6 — Generation after finalization failure** | **Addressed, statically.** Generation increments before throwing cleanup at [GuestPracticeViewModels.swift:127](<../../Circleu/Features/GuestJournal/GuestPracticeViewModels.swift:127>). |
| **#7 — Practice draft protection** | **Addressed, statically.** Load and write protection failures now produce visible warnings at [GuestPracticeViewModels.swift:91](<../../Circleu/Features/GuestJournal/GuestPracticeViewModels.swift:91>) and line 145. |
| **#8 — Separate export reads** | **Addressed, statically.** Both reads execute synchronously within one store actor turn at [SwiftDataGuestJournalStore.swift:352](<../../Circleu/Services/GuestJournal/SwiftDataGuestJournalStore.swift:352>). |
| **#9 — Export cleanup errors** | **Partial.** Delete all checks cleanup; share completion still suppresses errors at [GuestFindAndControl.swift:324](<../../Circleu/Features/GuestJournal/GuestFindAndControl.swift:324>), and startup ignores the result. The cleanup notice also promises next-launch removal despite possible repeated failure. |
| **#11 — Tests** | **Partial.** Added interruption, different-ID composer and export tests. [GuestFindAndControlTests.swift:310](<../../CircleuTests/GuestFindAndControlTests.swift:310>) reuses the existing database actor; the snapshot test has no competing mutation. Missing coverage includes restoration/finalization failures, receipt failures, same-ID composers and cold-store recovery. |
| **#12 — Interrupted staging / durable decision** | **Partial; still BLOCKER.** Transactional receipts cover readable drafts on the ordinary interruption path. Failure cases below remain. |

**Remaining BLOCKER #12:**

- [GuestDraftStore.swift:48](<../../Circleu/Services/GuestJournal/GuestDraftStore.swift:48>) suppresses restoration failure. If moving `.deleting` back fails, the absent normal file is treated as “no draft,” permitting new writing. A later recovery can delete the staged original because a newer file exists (line 93). Propagate recovery failure and prevent overwrite.
- [GuestDraftStore.swift:78](<../../Circleu/Services/GuestJournal/GuestDraftStore.swift:78>) permits staging without obtaining its ID. A temporarily unreadable disk draft absent from memory gets no consumption receipt; interruption after database commit can restore it once readable. Require an identity or a durable deletion decision covering that staged file.

**NEW BLOCKER #13 — Deleted Write content can return after receipt-read failure.** [GuestJournalViewModel.swift:97](<../../Circleu/Features/GuestJournal/GuestJournalViewModel.swift:97>) treats lookup failure like “not consumed.” After committed deletion interrupted before cleanup, launch restores and displays the deleted words. Editing assigns a fresh ID, allowing persistence despite the original receipt. Apply Practice’s fail-closed handling to Write.

**Verification / limits:** Whitespace check returned exit 0 with no diff findings; Git emitted sandbox cache warnings. Working tree clean. No build, XCTest execution, real process termination, Simulator/UI, accessibility, physical-device/file-protection or legacy/cloud checks. No inter-agent exchanges. Remaining fixes and regression coverage: unassigned.