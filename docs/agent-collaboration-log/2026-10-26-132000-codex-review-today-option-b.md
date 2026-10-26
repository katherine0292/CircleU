# Codex reviews: Today option B

- Recorded: 2026-10-26 13:20:00 +11:00; Australia/Sydney
- Agent / role: Codex (gpt-6-astra, high, read-only reviewer), run by Claude Code
- Reviewed: `51ae4f7`, then the fix `7e359a8`, on `codex/today-option-b`

## First pass (51ae4f7)

Reviewed `51ae4f7` (`git show HEAD`). **Changes requested.** No new draft-loss or duplicate-save regression found in source review.

**Blockers**

1. **An older reflection can dismiss a newer entry’s offer.** In [GuestReflectionReview.swift:84](<Circleu/Features/GuestJournal/GuestReflectionReview.swift:84>), successful saving unconditionally clears the shared offer. Open reflection A, switch to Today, save B, then finish A: B’s offer is cleared too. Dismiss only an offer whose ID matches the reviewed entry. Add this sequence to the tests.

2. **Delete all does not explicitly clear the bound reflection route.** [GuestJournalScreens.swift:359](<Circleu/Features/GuestJournal/GuestJournalScreens.swift:359>) uses `reflectingID`, owned outside the `NavigationStack` whose identity resets. That binding can remain non-nil after deletion, while its destination becomes empty because the entry disappeared. Clear the route on successful Delete all; test opening a reflection → Today Settings → Delete all → Journal. This is a source-level lifecycle finding; runtime reproduction remains pending.

3. **The new nudge actions lack 44-point targets.** [GuestJournalScreens.swift:242](<Circleu/Features/GuestJournal/GuestJournalScreens.swift:242>) renders three footnote-sized borderless buttons without minimum dimensions or individual padding. Padding the enclosing bubble does not enlarge each button. Give each action a 44-point target and an arrangement that accommodates larger text.

**Minor notes**

- **Reduce Motion:** the new compact-microphone layout animation at [GuestJournalScreens.swift:217](<Circleu/Features/GuestJournal/GuestJournalScreens.swift:217>) ignores the preference. The offer dismissal respects it. The dictation-state animation already ignored it before this commit.

- **Committed protection-warning saves receive no reflection offer.** [GuestJournalViewModel.swift:168](<Circleu/Features/GuestJournal/GuestJournalViewModel.swift:168>) discards the `entryID` carried by `savedButUnprotected`, leaving `offer` nil despite a committed plain save. Capture that ID if these saves should also offer reflection.

- **Documentation needs corrections.** [Screen guidelines:40](<docs/design/screen-content-guidelines.md:40>) lists three outlined starter chips despite the two-secondary limit. It exempts Hide locally, although the general exceptions do not. Journal’s Primary column says none despite the filled **Reflect on it** button. The existing [T1.2 wording](<docs/product/user-stories.md:46>) also includes “Your words are still here,” which the actual error does not.

- **Coverage arithmetic is correct; coverage strength is overstated in places.** Counts match: **27 stories, 85 criteria; 70 unit, 14 UI-only, 1 untested; 17 both, 11 marked partial**. All **118 test references resolve**. However, `testThreeStarterChipsEachAddOnlyTheirStarter` tests insertion only for the third chip. The UI test does not verify the nudge returns on the next entry, and T1.5’s test does not explicitly count Save buttons. T9.4’s screenshot evidence is not linked. Existing accessibility audits swallow failures.

- **Dead remnants:** `lastSavedAt` now has no production reader; its old banner test remains. `saveDraft(reflection:nextStep:)` has no callers supplying those arguments, leaving its reflection-specific branches and `reflectionNotAddedMessage` unused. `GuestSuccessBanner` and Practice’s **Get a suggestion** remain actively used.

**Other checks**

- Save still stops dictation synchronously, preserves delivered words, rejects late callbacks, guards concurrent saves, and clears only the submitted draft version. Newer typing and its persisted draft survive. It still does not wait for pending final recognition.
- Offer eligibility checks entry existence and absence of both reflection and next step. Revision checks prevent stale reflection writes and resurrection of deleted entries.
- Using UUID in both destination modifiers is **not by itself evidence of a collision**: bound-item presentation and type-based routing are distinct mechanisms. [Apple navigation documentation](https://developer.apple.com/documentation/swiftui/understanding-the-navigation-stack).
- Prompt insertion, cycling, threshold and dictation suppression look consistent. Chip layout measures bounded widths and row heights; chips have a 44-point minimum and scaling fonts. No definite clipping defect found, but largest Dynamic Type and VoiceOver order remain unverified.
- Static copy checks found no banned-word or literal-length violations.

No files—including logs—were edited. Working tree is clean; whitespace checks passed. Builds, XCTest, simulator layout, VoiceOver and physical-device checks were not run in this read-only environment.

## Second pass (7e359a8)

Reviewed `7e359a8` against `51ae4f7`. **Two blockers remain in source review.**

**Blockers**

1. **Delete all’s observer is inside the identity being replaced.** At [GuestJournalScreens.swift:370](<Circleu/Features/GuestJournal/GuestJournalScreens.swift:370>), `onChange` sits beneath `.id(practice.dataGeneration)`. Changing that ID recreates the observer, while `reflectingID` survives outside the stack. The new observer defaults to `initial: false`, so this does not reliably clear the route. Move the observer outside `.id(...)`. This finding follows from Apple’s documented [identity reset](https://developer.apple.com/documentation/swiftui/view/id(_:)) and [onChange initialization](https://developer.apple.com/documentation/swiftui/view/onchange(of:initial:_:)-8wgw9) behavior; runtime reproduction remains pending.

2. **The vertical nudge fallback still cannot wrap.** [GuestJournalScreens.swift:266](<Circleu/Features/GuestJournal/GuestJournalScreens.swift:266>) applies `.fixedSize()` in both layouts. Stacking helps only while each individual label fits. At large accessibility sizes, “Another question” exceeds the available width; the bundled font’s estimated width at 44pt is **371pt**, versus **299pt** available on a 375pt screen. Allow horizontal wrapping in the vertical fallback while retaining the 44pt minimum target. Apple explicitly documents that [`fixedSize()` can exceed parent bounds](https://developer.apple.com/documentation/swiftui/view/fixedsize()). The measurement is a font-metric estimate, not a simulator render.

**Resolved by source inspection**

- Finishing an older reflection now clears only its own offer; the new regression test exercises the relevant sequence.
- Nudge actions now have minimum **44×44pt** hit regions, subject to the layout issue above.
- Compact microphone transitions respect Reduce Motion.
- `savedButUnprotected` preserves the committed entry’s offer.
- Removing `saveDraft`’s reflection parameters and `lastSavedAt` leaves no dangling references. No previous callers supplied those parameters; reflection updates still use the separate update path. No removal-related regression found.

**Minor notes**

- The protection-failure test still throws an unrelated UUID and never asserts `reflectionOffer`. Make the stub return the saved entry’s ID and assert the offer targets it.
- T1.5’s “nothing else to choose before saving” remains misleading with optional prompts present. The other targeted guideline/copy corrections align.
- Tests now check all three starter mappings, one Save, and Hide resetting for the next entry. Large-text layout and target dimensions remain untested.

**Documentation counts match:** 27 stories, 86 criteria; 70 unit-covered, including 17 also UI-covered; 15 UI-only; one untested; 11 partial. All 120 checked test references resolve.

Whitespace checks passed. No files changed. Builds, unit/UI suites, simulator layout and physical-device checks were not run in this read-only environment.