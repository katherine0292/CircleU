**2026-10-26 — Codex review — HEAD `020e0fe`**

**Verdict: SHOULD-FIX.** No confirmed BLOCKER. Review only; no files edited or inter-agent exchanges.

- **SHOULD-FIX — Avatar picker can leave dictation running behind the sheet.** [GuestJournalScreens.swift:84](<../../Circleu/Features/GuestJournal/GuestJournalScreens.swift:84>) now exposes the avatar while recording. [GuestPinguArt.swift:128](<../../Circleu/Features/GuestJournal/GuestPinguArt.swift:128>) only opens its sheet; it neither stops dictation nor disables presentation. Sheet presentation need not trigger the underlying Write view’s `onDisappear`, leaving recording active with Stop inaccessible. Explicitly interrupt before presentation, or disable the picker during dictation. Static finding; runtime reproduction pending.

**Other checks:**

- Tab/Settings disappearance and `.background` invoke cancellation, preserve delivered text, invalidate late callbacks and return the microphone state to idle. `.inactive` correctly leaves permission requests intact. **Pending final words can be dropped**, including when leaving during “Finishing…”; this is existing behavior.
- Save cancels dictation before persistence. Main-actor `isSaving`, draft-ID deduplication and stale-event guards protect against duplicate saves and late transcripts refilling the cleared draft.
- Draft ownership remains outside the tab. Changes queue persistent writes; startup restores the draft before showing Today. No new tab-switch draft-clearing path found.
- The nested autoclosures defer engine creation inside `StateObject`: once per retained Write identity, consistent with [Apple’s documented behavior](https://developer.apple.com/documentation/swiftui/stateobject).
- Avatar retains its accessible name/hint; Settings is labelled. Changed heading/supporting copy meets the guideline limits and style. Today’s “Continue your draft” route is removed; Practice’s separate route remains.

**Verification:** inspected `git show HEAD`, surrounding implementations/tests, required guidance and committed screenshot; whitespace check passed; working tree clean.

**Not checked:** build/XCTest execution, live tab/navigation/sheet lifecycle, physical microphone/permission interruptions, VoiceOver, toolbar hit targets, large Dynamic Type, or termination before queued draft writes finish. Existing tests call model methods directly and do not establish the new tab-root lifecycle.