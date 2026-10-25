**2026-10-25 — Codex review — `22a0582`**

**Verdict: BLOCKED — two text-loss paths need fixing.** Static, review-only assessment; no files edited.

1. **BLOCKER — Save overwrites text entered while saving.** [GuestPracticeViewModels.swift:177](<../../Circleu/Features/GuestJournal/GuestPracticeViewModels.swift:177>) replaces all three fields with the snapshot captured before `await`, then exits editing. The inputs remain enabled during saving. Newer typing therefore disappears without being persisted. Preserve newer field values and remain in editing mode; test with a suspended save.

2. **BLOCKER — History refresh can destroy an unsaved editor.** [GuestPracticeScreens.swift:105](<../../Circleu/Features/GuestJournal/GuestPracticeScreens.swift:105>) owns the composer inside a conditional lookup. A failed reload makes `practice.messages` empty, removes that subtree and displays “This message no longer exists.” An editor left open in the other tab can consequently lose its text when another operation refreshes history. Actual deletion through the other tab has the same effect. Retain the composer independently of history state, preserving text for copying and distinguishing unreadable from deleted.

3. **SHOULD-FIX — Protection failures become unqualified success.** [GuestPracticeViewModels.swift:160](<../../Circleu/Features/GuestJournal/GuestPracticeViewModels.swift:160>) correctly records a committed save after `savedButUnprotected`, but then clears the error and shows ordinary saved UI. Delete handlers also suppress this warning. Preserve the committed outcome while displaying a lasting protection warning, as Journal already does.

4. **SHOULD-FIX — Failed Practice reads hide linked-message choices.** [GuestJournalScreens.swift:299](<../../Circleu/Features/GuestJournal/GuestJournalScreens.swift:299>) treats `linkedMessages == []` as authoritative even when Practice loading failed. Existing links disappear from entry detail, and deletion silently uses Keep rather than offering the requested choices. Show the unavailable state and retry before deciding which deletion confirmation applies.

5. **SHOULD-FIX — Failure and conflict coverage misses these boundaries.** [GuestPracticeTests.swift:201](<../../CircleuTests/GuestPracticeTests.swift:201>) ignores `expectedRevision`; its load method cannot fail. Add composer conflict tests, suspended-save edits, failed-refresh navigation, and real-store rollback tests for **Keep message**, Practice create/update and message deletion. Current real-store rollback coverage exercises only entry deletion with Delete both.

**Checks:** Inspected `git show 22a0582`, surrounding implementation, tests and required project context. Copy only writes the clipboard; Save has no send path. Linked entry deletion uses one save with rollback; updates reject missing IDs and stale revisions. No Firebase or legacy-data changes found in this commit. Diff whitespace check passed; working tree clean.

**Migration:** No confirmed same-name schema defect. Namespaced models follow [Apple’s versioned-schema example](https://developer.apple.com/videos/play/wwdc2023/10195/). The added test checks V1 entry identity/content/revision and receipt presence, but I did not execute it or verify a cold-process upgrade.

**Not checked:** Build/XCTest execution, Simulator navigation, VoiceOver/Dynamic Type, physical-device protection, genuine disk-full/interruption recovery or runtime network traffic. Inter-agent exchanges: None.