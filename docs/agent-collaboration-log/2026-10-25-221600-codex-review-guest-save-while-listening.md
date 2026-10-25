**2026-10-25 — Codex review — HEAD `38fd9ad`**

**Verdict: no confirmed runtime BLOCKER; regression coverage should improve.** Read-only review; no files edited.

1. **SHOULD-FIX — Multi-entry regression bypasses draft identity.** `CircleuTests/GuestDictationViewModelTests.swift:295` uses a journal without a draft store (`:78`), so saves submit `nil` draft IDs; its fake also ignores IDs (`:10`). It cannot catch accidental `draftAlreadySaved` handling that reports success without creating another entry. Inject draft persistence and an ID-aware store; assert three entries, distinct IDs and no already-saved notice. The current `Set` assertion also hides duplicates.

2. **SHOULD-FIX — The original button regression is untested.** `CircleuTests/GuestDictationViewModelTests.swift:279` calls `stopForSave()` directly. It would pass if `Circleu/Features/GuestJournal/GuestJournalScreens.swift:180` again disabled Save while listening. Add a committed UI test using the scripted engine: start dictation, tap enabled Save while listening, verify the entry, then repeat.

**Checks:** Both the UserDefaults lookup (`GuestRootView.swift:10`) and scripted class (`GuestDictationEngine.swift:211`) are inside `#if DEBUG`; inspected Release settings do not define DEBUG. Neither enters an ordinary Release build. No stale-event or draft-ID race found by inspection: generation increments before cancellation, stream consumers reject old generations, and production callbacks validate session identity. `saveDraft()` snapshots words/ID before suspension, rejects overlapping saves, and preserves newer draft versions. The next text mutation assigns a fresh ID after quiet clearing.

**Not checked:** No build, XCTest/UI-test execution, Release binary inspection, Simulator or physical-device speech testing. Save during pending permission, finishing, failed persistence/retry, and a suspended save with late events lack combined dictation regression coverage. Inspected `git show HEAD`, surrounding code/settings and existing identity tests; diff check passed; working tree clean.

**Inter-agent exchanges:** None.