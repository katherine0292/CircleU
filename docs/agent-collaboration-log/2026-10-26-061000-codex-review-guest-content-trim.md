**2026-10-26 — Codex review — HEAD `a5bc15a`**

**Verdict: changes required.** Review only; no files edited or inter-agent exchanges.

- **BLOCKER — unsaved-work warning lost.** [GuestPracticeViewModels.swift:57](<../../Circleu/Features/GuestJournal/GuestPracticeViewModels.swift:57>): unreadable drafts disable persistence (`canKeepDraft = false`), but the shortened warning no longer says new writing will be lost when closing. Restore that consequence and the instruction to save.

- **BLOCKER — deletion retry presented as guaranteed success.** [GuestFindAndControl.swift:181](<../../Circleu/Features/GuestJournal/GuestFindAndControl.swift:181>): “will be removed next time” is unsupported; cleanup can fail again. State that a copy remains and removal will be retried.

- **SHOULD-FIX — deletion scope is less honest.** [GuestFindAndControl.swift:354](<../../Circleu/Features/GuestJournal/GuestFindAndControl.swift:354>) removes the explicit exclusion of earlier-app data while claiming “all entries … on this iPhone.” Restore “this journal” and the legacy-data exclusion. [GuestSignIn.swift:493](<../../Circleu/Features/GuestJournal/GuestSignIn.swift:493>) similarly promises deletion of “its cloud data” while surviving replies/likes are now disclosed only after expansion. Qualify the visible promise.

- **SHOULD-FIX — lint has substantial blind spots.** [GuestCopyLintTests.swift:22](<../../CircleuTests/GuestCopyLintTests.swift:22>): line-based regex misses multiline contents; the space filter skips `Text("Demo")`; concatenation/interpolation does not measure displayed length. Existing combined sign-out errors can exceed 100 characters unnoticed. Heading/supporting limits of 40/90 are never checked. Substring matching can also flag innocent wording such as “demonstrate.” Use syntax-aware extraction plus focused rendered-message checks.

- **SHOULD-FIX — source coverage and location are fragile.** [GuestCopyLintTests.swift:12](<../../CircleuTests/GuestCopyLintTests.swift:12>): scanning covers current top-level feature files and one service, excluding other guest services and future subdirectories. `#filePath` requires the build machine’s checkout at runtime, so device or relocated test runs cannot reliably execute it. Prefer a host-side lint with explicit, recursive coverage.

- **SHOULD-FIX — rules and screens disagree.** [screen-content-guidelines.md:11](<../../docs/design/screen-content-guidelines.md:11>) requires exactly one filled action, but its table permits none. The listed Delete-account primary is actually plain ([GuestSignIn.swift:509](<../../Circleu/Features/GuestJournal/GuestSignIn.swift:509>)). Privacy detail contains five sentences, exceeding four; Welcome does not use the required supporting style; Settings places its export action before its summary. Document exceptions and reconcile implementation before calling the guideline enforced.

**Retained:** not-uploaded wording and sign-out failure remain visible; sealed-data reasoning, backup resurrection and external-export caveats remain accessible behind disclosure. `GuestLearnMore` uses native `DisclosureGroup` and scalable fonts; source inspection establishes no definite accessibility defect.

**Checked:** HEAD diff, surrounding failure paths, standards/handoffs, three committed after-screenshots, whitespace check, and a Python reproduction demonstrating lint misses.

**Not checked:** build/XCTest, live VoiceOver expansion/focus, touch targets, larger Dynamic Type, Simulator/device interactions, live Firebase or actual deletion/network behavior.