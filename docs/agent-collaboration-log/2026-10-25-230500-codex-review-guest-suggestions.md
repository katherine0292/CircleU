**2026-10-25 — Codex review — `be8bd97`**

**Verdict: BLOCKED — reflection edits can be lost.** Static review only; no files edited.

1. **BLOCKER — Edits during saving disappear.** [GuestReflectionReview.swift:106](<../../Circleu/Features/GuestJournal/GuestReflectionReview.swift:106>): fields remain editable while saving the captured reflection. Completion unconditionally calls `onSaved()`, destroying later edits. Disable editing during save or retain subsequent changes and keep the review open. Add a suspended-save regression test.

2. **SHOULD-FIX — Draft receipts can discard newly accepted suggestions.** [GuestJournalViewModel.swift:138](<../../Circleu/Features/GuestJournal/GuestJournalViewModel.swift:138>): if receipt lookup fails during restoration, an already-saved draft can reach review. Saving its new reflection encounters `draftAlreadySaved`, yet returns success and dismisses without storing that reflection. Preserve the review and distinguish “words previously saved” from “suggestion saved.”

3. **SHOULD-FIX — Next step is accepted by default.** [GuestReflectionReview.swift:43](<../../Circleu/Features/GuestJournal/GuestReflectionReview.swift:43>): generation fills `nextStep`; “Save with reflection” persists it unless explicitly cleared. M05 requires choosing the step independently. Default to no selected step and offer an explicit keep action.

4. **SHOULD-FIX — Standalone next steps lose provenance and stale marking.** [GuestJournalScreens.swift:526](<../../Circleu/Features/GuestJournal/GuestJournalScreens.swift:526>): clearing/removing the reflection while retaining its step removes the only source label and source-word snapshot. Subsequent word edits cannot mark that suggestion stale. Store and display step provenance independently.

5. **SHOULD-FIX — Practice suggestions remain apparently current after edits.** [GuestPracticeViewModels.swift:160](<../../Circleu/Features/GuestJournal/GuestPracticeViewModels.swift:160>): no generation-input snapshot or revision is retained. Changing situation, goal or wording during/after generation leaves outdated options selectable without warning. Track inputs and mark or invalidate stale results, including late completions.

6. **SHOULD-FIX — Malformed model output can crash Practice.** [GuestSuggestionEngine.swift:120](<../../Circleu/Services/GuestJournal/GuestSuggestionEngine.swift:120>): finding both brackets does not establish `start <= end`. A response such as `] … [` traps when constructing the range; `try?` cannot recover. Validate bounds before slicing and test malformed responses.

7. **SHOULD-FIX — Original words are not saved verbatim.** [GuestJournalViewModel.swift:118](<../../Circleu/Features/GuestJournal/GuestJournalViewModel.swift:118>): leading/trailing whitespace and newlines are stripped before persistence. This is inherited behavior, also used by the new reflection-save path. Trim for empty validation only; persist the original string.

8. **SHOULD-FIX — Back silently discards reflection corrections.** [GuestReflectionReview.swift:120](<../../Circleu/Features/GuestJournal/GuestReflectionReview.swift:120>): the default navigation back action has no dirty-state protection; review edits exist only in screen-owned state. Returning to amend original words can discard those corrections. Retain the review or offer an explicit discard choice.

9. **SHOULD-FIX — Migration and failure coverage is incomplete.** [GuestSuggestionTests.swift:98](<../../CircleuTests/GuestSuggestionTests.swift:98>): V2 migration assertions omit original content, timestamps, complete Practice fields and receipts. Existing V1 coverage checks receipts, but add complete V2 preservation plus reflection-write rollback, cancellation and suspended-save tests.

**Checks:** Inspected `git show be8bd97`, dependencies, tests and required project context. No reachable cloud engine, Firebase call or legacy-key access found in the new suggestion path; the debug guest switch remains. No destructive migration step found. Diff whitespace check passed; working tree clean.

**Not checked:** Build/XCTest execution, cold-process migration/interruption, Simulator interactions, VoiceOver/Dynamic Type/touch targets, physical-device AI/protection or runtime network traffic. Inter-agent exchanges: None.