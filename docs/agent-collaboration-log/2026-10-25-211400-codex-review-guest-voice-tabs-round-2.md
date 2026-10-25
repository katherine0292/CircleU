**2026-10-25 — Codex review, round 2 — `c721b36` against `b2342d9`**

**Verdict: PASS for static review.** All four prior findings are resolved in code; no new confirmed BLOCKER, SHOULD-FIX or NIT.

| Prior finding | Status | Evidence |
|---|---|---|
| **BLOCKER:** stale engine callbacks reach a new session | **Resolved** | `GuestDictationEngine.swift:93–100,125–127,141–144`: speech callbacks and notification handlers capture a session token; mismatched events are rejected before yielding or teardown. |
| **SHOULD-FIX:** permission alert’s `.inactive` cancels start | **Resolved** | `GuestJournalScreens.swift:190`: only `.background` interrupts; permission-related inactivity preserves the pending start. |
| **SHOULD-FIX:** media-services reset reuses invalid engine | **Resolved** | `GuestDictationEngine.swift:75,166`: each start creates a fresh `AVAudioEngine`; teardown releases the previous instance. |
| **SHOULD-FIX:** late-callback test delivers nothing | **Resolved** | `GuestDictationViewModelTests.swift:56–64,167–186`: cancellation retains the old continuation, and late events are yielded after restart while the new session remains usable. |

**Verification:** inspected `git show HEAD` and surrounding engine/ViewModel/UI/test code; `git diff --check HEAD^ HEAD` passed; working tree clean. No files edited.

**Not checked:** build, XCTest execution, Simulator or physical-device permission/interruption/reset behavior. The revised tests exercise ViewModel generation isolation, **not** the production engine’s session-token guard; that guard remains verified by inspection only.

**Inter-agent exchanges:** None.