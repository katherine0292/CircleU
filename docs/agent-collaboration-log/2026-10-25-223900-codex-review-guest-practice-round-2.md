**2026-10-25 — Codex review, round 2 — `12b2c35`**

**Verdict: no confirmed BLOCKER in static review; SHOULD-FIX items remain.** Reviewed `git show HEAD` and surrounding code. No files edited.

| Prior finding | Status | Evidence |
|---|---|---|
| 1. Save overwrites newer typing | **Resolved** | Save snapshots submitted fields and preserves later edits, leaving the composer editable. |
| 2. History refresh destroys unsaved editor | **Resolved** | `GuestPracticeRouteView` retains its composer in route-owned state, independently of history loading/failure. |
| 3. `savedButUnprotected` appears as plain success | **Resolved** | Saves display a warning; committed deletes add a notice displayed across tabs. See new finding below. |
| 4. Failed Practice load hides deletion choices | **Resolved** | Entry detail shows the failure; deletion confirmation waits for a successful Practice load. |
| 5. Test gaps | **Not resolved — improved** | Added save-interleaving, stale-edit, warning and real-store rollback coverage. Missing regression coverage for route preservation across failed refreshes, failed-load deletion gating, and deletion protection notices. |

**New SHOULD-FIX — protection warning masks subsequent deletion failure.**  
[GuestPracticeScreens.swift:154](<../../Circleu/Features/GuestJournal/GuestPracticeScreens.swift:154>): after a `savedButUnprotected` save, `composer.saveError` remains populated. If the user then deletes the message and deletion fails, `deleteError` is set but hidden by `composer.saveError ?? deleteError`. The screen continues showing only the earlier “Saved…” warning. Display both messages, or give the current deletion failure precedence while retaining the protection notice.

**Verification / limits:** `git diff --check HEAD^ HEAD` passed; working tree clean. No build, XCTest execution, Simulator interaction, accessibility or physical-device/file-protection validation in this read-only pass. Legacy/cloud paths were outside scope. No inter-agent exchanges.