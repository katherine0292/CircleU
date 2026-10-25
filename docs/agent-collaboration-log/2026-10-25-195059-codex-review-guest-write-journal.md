# Codex review of guest write, journal and edit (PR #12)

- Recorded: 2026-10-25 19:50:59 +11:00; Australia/Sydney
- Agent / role: Codex, reviewer
- Status: completed — read-only review; changes requested
- Base revision and branch: `5b87da6043e539bcc6b2207726e821ebdd53aeb2` on `codex/guest-write-journal`, compared with cached `origin/main` at `99910f5d8054929c5b82a12f65ef9b1b074e1e0f`. Working tree clean.
- Related record / task / PR: PR #12; [implementation record](2026-10-25-194649-claude-guest-write-journal.md); [first-slice plan](../superpowers/plans/2026-10-25-first-slice-typed-capture-local-journal.md); [walkthrough decisions](../design/prototype-review-results.md#walkthrough-summary--25-october).

**Verdict: BLOCKS merge. Findings 1–4 require fixes. Finding 5 is an unresolved plan requirement; the implementation record’s deferral does not establish owner approval. Finding 6 is nonblocking.**

## Request and scope

Reviewed `git diff origin/main...HEAD`: the four GuestJournal files, `AppStartup.swift`, both changed test files and the new log entry. Read AGENTS.md, local/shared coding standards, log README/TEMPLATE, MVP decisions, the requested plan and walkthrough, and relevant preceding reviews. Inspected supporting store, startup and build configuration.

Local Git/file reads only. No network, builds, tests or file writes.

## Work and outcome

### Severity-ranked findings

1. **High — Saving an edit can erase text entered while the save is pending. BLOCKS merge.**

   [GuestEntryEditorViewModel.swift:35](</Users/tuannm3812/Documents/GitHub/3. Personal/CircleU/Circleu/Features/GuestJournal/GuestEntryEditorViewModel.swift:35>) awaits the update, then unconditionally assigns the saved snapshot to `text`. The TextEditor remains editable. Submit A, type B while the store is suspended, and completion replaces B with A. [GuestJournalScreens.swift:218](</Users/tuannm3812/Documents/GitHub/3. Personal/CircleU/Circleu/Features/GuestJournal/GuestJournalScreens.swift:218>) then dismisses the editor. The committed-with-protection-warning path also dismisses despite potentially newer unsaved text.

   **Fix:** Capture the submitted text or edit generation, update the saved baseline on completion, preserve newer input, and dismiss only when no unsaved changes remain. Alternatively, prevent editing for the entire pending operation. Add a suspended-update regression test, including the warning outcome. MainActor isolation does not prevent this reentrancy across `await`.

2. **Medium — Detail interprets loading/read failures as deletion, and refresh changes its editor’s navigation identity. BLOCKS merge.**

   [GuestJournalViewModel.swift:54](</Users/tuannm3812/Documents/GitHub/3. Personal/CircleU/Circleu/Features/GuestJournal/GuestJournalViewModel.swift:54>) returns `[]` during loading and after errors. [GuestJournalScreens.swift:170](</Users/tuannm3812/Documents/GitHub/3. Personal/CircleU/Circleu/Features/GuestJournal/GuestJournalScreens.swift:170>) consequently displays “This entry no longer exists.” A failed refresh after saving or leaving Edit therefore reports deletion instead of a read error, with no retry in detail.

   The editor’s `navigationDestination` also lives inside the conditional detail subtree. An unsaved Journal editor can remain open while the user switches to Today and saves another entry; that refresh removes the subtree hosting its destination. This makes draft retention depend on refresh-driven view identity and risks teardown without the discard prompt.

   **Fix:** Handle loading, failed, loaded-present and loaded-missing explicitly. Keep navigation/editor ownership stable across refreshes, preserve pending edits, and show a retryable read error. Test failed refresh after editing and the cross-tab save flow with an unsaved editor.

3. **Medium — Discard remains available while an update can still commit. BLOCKS merge.**

   [GuestJournalScreens.swift:233](</Users/tuannm3812/Documents/GitHub/3. Personal/CircleU/Circleu/Features/GuestJournal/GuestJournalScreens.swift:233>) allows Back during `isSaving`; Discard calls `onDone()` without stopping or coordinating the save task. With a delayed update, Save → Back → Discard can still commit the supposedly discarded changes. Completion can invoke `onDone()` again after navigation has changed.

   **Fix:** Prevent Back/Discard while committing, or implement an explicit cancellation/commit contract that guarantees the displayed choice. Scope completion callbacks to the active editor session. Add a delayed-save test proving Discard cannot promise unchanged saved content while a write remains pending.

4. **Medium — Post-commit protection warnings disappear through success navigation. BLOCKS merge.**

   [GuestEntryEditorViewModel.swift:39](</Users/tuannm3812/Documents/GitHub/3. Personal/CircleU/Circleu/Features/GuestJournal/GuestEntryEditorViewModel.swift:39>) sets `saveError` for `savedButUnprotected` but returns `true`, immediately dismissing its only warning display. The same problem affects new entries: [GuestJournalScreens.swift:107](</Users/tuannm3812/Documents/GitHub/3. Personal/CircleU/Circleu/Features/GuestJournal/GuestJournalScreens.swift:107>) navigates to Journal, which never renders `journal.saveError`.

   **Fix:** Carry a distinct committed-with-warning outcome to a persistent destination banner or require acknowledgment before leaving. Keep the operation classified as committed to avoid duplicate retries. Test warning visibility and exactly one write for both create and edit.

5. **Medium — Retained Write drafts do not survive relaunch. Unresolved plan requirement.**

   [GuestJournalScreens.swift:90](</Users/tuannm3812/Documents/GitHub/3. Personal/CircleU/Circleu/Features/GuestJournal/GuestJournalScreens.swift:90>) binds only to the in-memory draft initialized in [GuestJournalViewModel.swift:18](</Users/tuannm3812/Documents/GitHub/3. Personal/CircleU/Circleu/Features/GuestJournal/GuestJournalViewModel.swift:18>). Type → Back → terminate/relaunch loses the retained draft. A draft preserved after a failed save has the same limitation.

   The plan explicitly requires draft persistence and a relaunch test. The implementation log acknowledges the omission, but the reviewed records do not establish an owner-approved scope change.

   **Fix:** Persist and restore drafts separately from saved entries, with explicit failure handling and relaunch coverage; otherwise record an explicit owner decision narrowing this step before treating it as complete.

6. **Low — Startup tests reject the intended phone-test build configuration. Nonblocking.**

   [AppStartupTests.swift:19](</Users/tuannm3812/Documents/GitHub/3. Personal/CircleU/CircleuTests/AppStartupTests.swift:19>) unconditionally asserts that the compiled flag is false. Several existing-path tests also omit `isGuestJournalBuild`, so enabling the supported flag changes their routing expectations.

   **Fix:** Supply explicit flag values in routing tests and separate checks of the normal project configuration from tests intended to run under the phone-test configuration.

### Other assessment

- **Release/TestFlight:** The resolver still requires `isDebugBuild`. `GUEST_JOURNAL_BUILD` alone cannot activate guest mode in the checked-in Release configuration; Archive uses Release. `CircleuApp` uses the compiled defaults. No Release routing regression identified statically.
- **Existing app/data:** The existing app startup/composition and legacy storage paths are unchanged by this diff. Guest composition continues to use the separate local store.
- **No resurrection/latest revision:** The editor passes the opened revision to the existing serialized store, which rejects stale or deleted entries. Successful reloads select detail by stable ID and return entries by descending update time. No new resurrection path identified.
- **Double saves/concurrency:** MainActor ViewModels set `isSaving` before suspension, guarding overlapping saves. Store actors and nonisolated Sendable domain types remain consistent with the project’s isolation settings. The failures above concern async lifecycle handling, not an identified isolation compilation error.
- **StateObject:** No independent initialization defect identified. Its lifetime remains vulnerable to the conditional navigation ownership described in finding 2.
- **Accessibility:** TextEditors have labels, decorative artwork is hidden, and semantic fonts support scaling. Source order is broadly sensible. Actual VoiceOver traversal and largest Dynamic Type remain unverified, particularly the non-scrolling Edit layout with keyboard and multiline errors. The reported default-size audit does not establish these checks.

## Verification

- Inspected the complete eight-file `git diff origin/main...HEAD` and supporting source/configuration.
- `git diff --check origin/main...HEAD`: passed.
- `git status --porcelain=v1`: clean; final HEAD unchanged.
- Git returned results despite denied temporary-cache warnings.
- New tests meaningfully cover ordinary edit success, failed-save text retention, conflict/deletion messages and real-store integration. They do not cover suspended editor saves, in-flight discard, detail refresh failures or warning visibility.
- [GuestEntryEditorViewModelTests.swift:97](</Users/tuannm3812/Documents/GitHub/3. Personal/CircleU/CircleuTests/GuestEntryEditorViewModelTests.swift:97>) does not establish a fresh store after editing: `reopened` and `editor` retain the store, so the registry returns the existing instance. Release those owners before reopening. Existing store tests separately exercise edit persistence after releasing the store.
- **Reported only:** The user supplied Claude’s “132 tests pass” report. The checked-in log records **131 passed, one device-only skipped**, plus a passing out-of-repo UI flow and default-size accessibility audit. These results were not independently verified.
- Not run / limitations: no build, tests, Simulator, physical-device checks, Release binary inspection or accessibility execution. Findings are static analysis. No files written.

## Discussion and decisions

None. No direct inter-agent exchange occurred. Claude’s evidence came through the user and repository records.

The requested review does not authorize implementation, merge or release. Draft deferral remains an implementation-record statement rather than a demonstrated owner decision.

## Handoff

- Remaining work: Fix findings 1–4; resolve draft persistence/scope; add the identified regression coverage; correct test configuration assumptions and relaunch evidence. Verify largest-text and VoiceOver flows, then request re-review against the revised commit.
- Owner: Unassigned for fixes; Mike for scope and merge decisions.
- Risks / unresolved questions: Unsaved edit loss, misleading deletion/protection states, discard during pending writes, and draft loss across relaunch. Hardware protection and physical-phone behavior remain unverified.

## Correction reference (if applicable)

This review qualifies the [implementation record](2026-10-25-194649-claude-guest-write-journal.md): failure retention and latest-detail behavior are not established across the async/navigation cases above, and the new integration test’s final read is not a fresh-store relaunch. Historical records remain unchanged.