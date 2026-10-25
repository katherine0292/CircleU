# Today review: walkthrough script

Prepared 25 October 2026 for Mike's next review (about 15 minutes). It uses the existing static boards and the [walkthrough worksheet](prototype-review-results.md); nothing here is implemented or approved. Record answers in the worksheet, not here.

**Before starting:** open the images below on a Mac or iPad. They are static, so typing, saving, copying and navigation can't be tested; mark those as *not testable here*.

## The five tasks

| # | Ask Mike | Look at | Note |
| --- | --- | --- | --- |
| 1 | "Something happened today. Keep just your own words, without the suggestions." | [Today](swiftui-previews/brand-today.png) → [Capture](swiftui-previews/brand-04-capture.png) → [Reflection](swiftui-previews/brand-04-reflection.png) | Does he find **Save only my words** without help? Does he think the reflection is required? |
| 2 | "The reflection isn't quite right. Fix it, leave, and find your fixed version later." | [Reflection](swiftui-previews/brand-04-reflection.png) → [Edit reflection](swiftui-previews/brand-02-edit-reflection.png) → [Saved entry](swiftui-previews/brand-04-entry.png) | Is **Edit reflection** discoverable? Is it clear his original words don't change? |
| 3 | "Practise what to say to your groupmate. Then make a separate message. Which one is saved?" | [Saved entry](swiftui-previews/brand-04-entry.png) → [Practice context](swiftui-previews/brand-04-practice-context.png) → [Wording](swiftui-previews/brand-04-wording.png) → [Saved message](swiftui-previews/brand-04-practice-detail.png); [linked vs changed source](swiftui-previews/brand-04-linked-contexts.png) | Does he understand Copy doesn't save or send? Can he tell a linked message from a standalone one? |
| 4 | "Find what you wrote on 21 October. Now look at an empty day. Then find everything." | [Journal calendar](swiftui-previews/brand-03-calendar.png), [multiple entries](swiftui-previews/brand-03-journal-multiple.png), [empty day](swiftui-previews/brand-03-journal-empty.png) | Does an empty day look like missing data? Does he look for Search or All entries? |
| 5 | "Where are your entries kept? What happens if you delete one?" | [Privacy and data](../qa/native-onboarding-final-review-2026-10-25.md) (preview app) | Any misunderstanding about cloud, backups or deletion is high severity |

Then ask three quick questions: *What would you remove? What felt unclear? Would you use Today daily, or only when something happens?*

Afterwards, decide on the [open calendar proposals](prototype-review-results.md#open-calendar-decisions), and whether a tappable prototype is needed before the first production slice (typed capture → local save → Journal → edit).

## Copy trim suggestions (proposal)

The same standard as the onboarding pass: one heading, at most one short line, one primary action. **Applied to the preview boards on `codex/today-copy-trim` for review, not merged.** See [what was applied](#applied-on-codextoday-copy-trim).

| Screen | Now | Suggested |
| --- | --- | --- |
| Today | "What's on your mind?" + "Make sense of a moment. Find words that feel like you." + "Or find your words in Practice." | "What's on your mind?" + one card **Work through a moment**; drop the two supporting lines (the Practice tab already exists) |
| Today eyebrow | "TODAY" above the heading | Remove; the tab bar already says Today |
| Capture | "What happened, and what matters to you?" + "You can keep just your words. A reflection and next step are optional." | "What happened?" Keep **Save only my words** visible as the second button instead of the sentence |
| Capture voice | "Prefer to speak? Record your words." | Mic icon button labelled **Record** |
| Reflection | Heading "Does this feel right?" + "Your words stay separate from this interpretation." | Keep the heading; drop the sentence (the separate "My words" card shows it) |
| Saved entry | "Next step · optional" / "No step chosen" / "Add a next step" | One link **Add a next step** |
| Practice context | "No journal entry needed. What would you like to say?" | "What would you like to say?" |
| Wording | "One option to work with. Change it until it sounds like you." + "Copying doesn't save or send the message." | One line: "Copying won't save or send it." |
| Saved message | "Saved here for you to revisit. Nothing is sent for you." | "Saved · not sent" |
| Journal hub | "Your moments, ready to revisit." + "Your words, reflections and next steps, together." | "Journal" + Search field only |
| Practice hub | "Find words that fit you." + "Try a message on its own, or build on a reflection." + "Copy a message when you're ready. Nothing is sent for you." | "Practice" + **Practice a message**; keep "Nothing is sent for you" only on Wording |
| All screens | Uppercase eyebrows ("DESCRIBE A MOMENT", "SAMPLE SAVED ENTRY") | Remove from the product screens; sample labels belong in the review frame |

Keep: the "Save only my words" path, "Copy won't save or send" (once), linked/standalone labels and the empty-day wording. These protect against the data-loss and authority risks listed in the [milestone plan](../superpowers/plans/2026-10-24-prototype-review-milestone.md#review-focus).

## Applied on `codex/today-copy-trim`

Prototype boards only (`BrandDemo.swift`, `BrandFlowPreview.swift`, `BrandJourneyPreview.swift`); the renders in `swiftui-previews/` were regenerated. Differences from the table above:

- **Hub headings (owner decision, 25 October):** the plain tab names "Journal" and "Practice", replacing the small JOURNAL / PRACTICE label and the longer headline. The Journal Search field and the section labels stay.
- **Sample/review labels (owner decision, 25 October):** "DESCRIBE A MOMENT", "SAMPLE SAVED ENTRY" and the others moved out of the phone screens. They are now captions above each screen in the comparison boards, so the screens read like the app. Individual screens stay marked as samples by the "Sample"/"Draft" chip and the "Brand demo · Static sample" footer, which satisfies the milestone's sample-label rule.
- **Also removed:** "Back to Journal" / "Back to Practice" under the main action, because they duplicate the Back control (the onboarding rule).
- **Reflection:** "A suggestion to consider. Change anything that doesn't fit." is kept, because the content standard requires suggestions to read as tentative.
- **Demo 05 (icon-led) variant:** only the shared changes apply (Back links, capture prompt).

Verification: the CircleU Preview host opens each board with `--board <today|journal|practice|capture|reflection|entry|practice-context|wording|practice-detail>`. All nine were checked in the iPhone 18 Pro / iOS 27.0 Simulator, and `performAccessibilityAudit()` ran on each. The only findings are "Dynamic Type font sizes are unsupported": these fixed-size specimens use fixed fonts on purpose, and production screens must use scalable text. There were no contrast or hit-area findings.
