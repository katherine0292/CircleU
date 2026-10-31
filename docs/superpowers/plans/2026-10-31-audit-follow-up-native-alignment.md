# Audit follow up and native alignment implementation plan

> **For agentic workers:** Use superpowers:executing-plans for this approved sequence. Preserve the checkpoint commits and existing worktree.

**Goal:** Repair reflection decoding, reconcile project status and implement the accepted Today composer and Journal tags in the guest review app.

**Architecture:** Keep existing ViewModels, local SwiftData store, TabView and navigation. Extract one shared reflection decoder. Add optional user-selected tags with V5→V6 migration, using the existing revision/transaction/protection boundary. Today questions are temporary guidance, never inserted into original words.

**Tech Stack:** SwiftUI, SwiftData, XCTest; existing Plus Jakarta Sans and Codex artwork.

**Spec:** [31 October audit](../../qa/project-audit-2026-10-31/README.md), [Today review 20](../../design/figma-today-prompts-review-20/README.md), [scene review 21](../../design/figma-scene-library-review-21/README.md), [Journal review 14](../../design/figma-journal-emotions-review-14/README.md), [transparent art](../../design/figma-transparent-artwork-review-15/README.md). Owner approved the audit's proposed sequence with “ok do that”; no repeated design approval is needed.

## Global constraints

- Preserve existing entries, drafts, conversation history, IDs, revisions and legacy recovery; no cloud, signing, Release or deployment changes.
- iOS 17 deployment target and iPhone/iPad family remain; native TabView, Settings and existing calendar/search stay functional.
- One primary Save action; Plus Jakarta Sans, blue/ice/ink tokens, Dynamic Type and 44pt controls; artwork is decorative.
- Questions: What happened? / How did it make you feel? / What would you like to say next? Select/change/remove never edits the draft. Reset after successful save/discard, retain on failure.
- Optional context: Study, Work, Friends, Family. Optional feeling: Calm, Worried, Overloaded, Happy, Sad, Frustrated. Independent select/deselect, explicit Done, cancel without mutation, no inference.
- Local checkpoint commits only; no push, merge, cloud activation or release in this task.

## Review focus

- Reversed/missing JSON delimiters and JSON strings containing braces must fail safely or decode valid content without trapping.
- V5 data with existing reflection/conversation/drafts must survive migration with nil tags; edits must retain tags.
- Late/stale/deleted tag saves must not overwrite words or recreate entries; failed saves retain picker choices.
- Question changes must preserve punctuation, empty drafts, dictation and text typed during save.
- Long entries, largest text and the keyboard must keep navigation, tag choices and Save/Done reachable.

## Task 1: Preserve current state

- [x] Review pending source/config/asset groups, credential filename/content patterns and prior fresh suite evidence.
- [x] Commit native baseline as `150214e` and design/document baseline as `019368c`. Binary presentation formats marked binary; three source trailing-empty-line fixes.

## Task 2: Safe reflection decoding

Files: create `Circleu/Engines/ReflectionResponseDecoder.swift`, `CircleuTests/ReflectionResponseDecoderTests.swift`; update both reflection engines.

Interface: `ReflectionResponseDecoder.decode(_ response: String) throws -> AIReflectionResult`, throwing `ReflectionEngineError.invalidModelResponse`.

- [ ] RED: valid raw/fenced/prefixed JSON, braces in quoted values, reversed/missing braces, malformed/schema-invalid JSON. Run the new XCTest class and observe missing decoder failure.
- [ ] GREEN: decode complete trimmed JSON first, then ordered first/last-object bounds; reuse in both engines without changing provider/fallback behavior.
- [ ] Run decoder, engine behavior, cloud fallback and guest suggestion tests; commit the scoped fix.

## Task 3: Durable Journal tags

Files: `GuestJournalStore.swift`, new `GuestEntryTags.swift`, `SwiftDataGuestJournalStore.swift`, `GuestFindAndControl.swift`, new `GuestEntryTagTests.swift`.

Interface: optional `context: GuestEntryContext?`, `feeling: GuestEntryFeeling?` on `GuestJournalEntry`; `GuestEntryTagStore.updateTags(id:context:feeling:expectedRevision:) async throws -> GuestJournalEntry`.

- [ ] RED: nil defaults, save/reopen/deselect, original/reflection preservation, stale/deleted rejection, rollback, V5 migration, export/search and delete-all scope.
- [ ] GREEN: V6 optional string fields with validated enum mapping, versioned migration, serial revision checks/rollback/protection using existing helpers; export user tags distinctly.
- [ ] Run tag/store/conversation/export tests; commit once this layer passes.

## Task 4: Approved native layouts and interactions

Files: `GuestJournalScreens.swift`, `GuestTodayPrompts.swift`, new `GuestEntryTagPicker.swift`, `Assets.xcassets`, affected Today/Journal UI tests.

Interface: question selection local to the current draft; picker receives entry snapshot + tag store, refreshes journal after a successful save. Existing storage APIs remain authoritative.

- [ ] Update product brief and story criteria before behavior changes. Record native implementation authorization and retained release boundaries.
- [ ] RED: question selection/change/remove preserve typed words and Save stays disabled for an empty draft; tag Done/cancel/deselect/relaunch and large-text controls.
- [ ] Implement 2:1 window/voice scenes, 24pt heading, compact editor footer with question/mic, optional question sheet and pinned Save. Preserve permission/cancel/save-error paths and Settings/Pingu access.
- [ ] Implement date-grouped Journal cards with time, words and separate context/feeling controls; retain search/calendar/detail/reflection/linked Practice. Use current transparent Pingu assets; no decorative calendar icon additions.
- [ ] Run full unit/UI suites, inspect native captures at standard/large text; fix regressions and commit. Native system chrome and accessibility reflow may differ from fixed Figma geometry.

## Task 5: Reconcile and hand off

Files: `AGENTS.md`, coding standards, architecture, backend assessment, overview/MVP/flow/user stories, content rules, QA evidence and new dated log.

- [ ] Correct guest versus Release status, schema version, actual CI behavior, current Figma evidence and poster/slides-only deliverables. Keep historical logs unchanged.
- [ ] Preserve unresolved security, release, recovery and hardware gates; update audit resolution evidence without implying all findings fixed.
- [ ] Validate links/JSON/whitespace; perform independent code review under executing-plans; record real exchanges and fixes.
- [ ] Open this worktree's Xcode project and leave the guest review build available with screenshots and test results. No physical-phone installation without checking its current availability.
