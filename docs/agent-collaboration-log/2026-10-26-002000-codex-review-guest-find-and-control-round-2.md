**2026-10-25 23:42 +11:00 — Codex review, round 2 — `c014a8e`**

**Verdict: BLOCKERS remain.** Reviewed `git show HEAD` against parent `1d21654`, surrounding persistence/navigation code, and tests. No files edited.

| Finding | Status | Evidence / remaining issue |
|---|---|---|
| **1. Pending deletions after failed fetch** | **Resolved** | All three fetches precede mutations; failed saves roll back. `SwiftDataGuestJournalStore.swift:352`. |
| **2. Delete-all atomicity across drafts** | **Partial** | Staging failures preserve saved data, but final draft removal can still fail **after** database deletion. Rollback failures are suppressed despite “Nothing was removed.” `GuestFindAndControl.swift:252,261`. |
| **3. Practice draft replaced across contexts** | **Partial** | The opening prompt helps, but existing composers bypass it. Open an empty composer in Practice, write a linked draft in Journal, then return and type in the original composer: it silently replaces the shared slot. `GuestPracticeViewModels.swift:85`; `GuestPracticeScreens.swift:119`. |
| **4. Saved Practice drafts resurrecting** | **Partial** | Transactional receipts prevent duplicate saves. However, a failed receipt lookup is treated as “not saved,” offering the leftover draft again; subsequent edits retain the already-saved ID and cannot save successfully. `GuestPracticeViewModels.swift:75,356`. |
| **5. Save clears newer typing** | **Resolved** | The whole form, including suggestion controls, disables during saving. `GuestPracticeScreens.swift:283`. Cross-composer ownership remains covered by #3. |
| **6. Open composers survive Delete all** | **Partial** | Normal completion resets navigation and rejects stale draft writes. If Practice draft finalization throws, generation never increments, screens remain valid, and old content can be written/saved again. `GuestPracticeViewModels.swift:109`. |
| **7. Silent Practice draft failures** | **Partial** | Read/write warnings now appear, but `KeptDraft.isProtected` is ignored and `protectionFailed` is swallowed. `GuestPracticeViewModels.swift:58,126`. |
| **8. Export snapshot/serialization** | **Partial** | Settings export/delete calls are serialized, and read failures reject export. Journal and Practice still load separately, allowing other-tab mutations between reads and an inconsistent export. `GuestFindAndControl.swift:201`. |
| **9. Lingering temporary exports** | **Partial** | Launch/Delete all cleanup added, but deletion errors remain suppressed; Delete all can report success while its export remains. `GuestFindAndControl.swift:190,255`. |
| **10. Backup disclosure** | **Resolved** | Explicitly explains restoration of deleted content and separately saved exports. `GuestFindAndControl.swift:281`. |
| **11. Test gaps** | **Partial** | Useful failure tests added. Missing interruption recovery, finalization/rollback failures, simultaneous composers, export interleaving/cleanup failure, and actual navigation reset coverage. `GuestFindAndControlTests.swift:223,297`. |

**New BLOCKER #12 — Interrupted staging hides drafts without recovery.**  
[GuestDraftStore.swift:71](<../../Circleu/Services/GuestJournal/GuestDraftStore.swift:71>) renames drafts to `.deleting`, but [load():44](<../../Circleu/Services/GuestJournal/GuestDraftStore.swift:44>) only reads the original filename. Termination after staging but before database deletion makes retained drafts disappear on relaunch. Recovery runs only during another Delete all; without a durable commit decision, it also cannot distinguish an aborted deletion from committed deletion awaiting cleanup. A later failed retry can restore content whose database deletion already committed.

**New SHOULD-FIX / NIT:** none beyond the outstanding findings above.

**Verification / limits:** `git diff --check HEAD^ HEAD` passed; working tree clean. Static review only: no build/XCTest execution in the read-only sandbox, Simulator/UI, physical-device, file-protection, live AI, or legacy/cloud validation. No inter-agent exchanges. Log supplied here only, as requested.