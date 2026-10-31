# Prototype walkthrough worksheet

Current-session pointer, 30 October: use the [Practice review 08 usability guide](practice-usability-session-2026-10-30.md) for the new message-first participant sessions. It contains neutral tasks and a blank results template; no new participant results have been collected. The owner walkthrough below is historical evidence, not a participant study.

Prepared 24 October 2026 for the [review brief](prototype-review-brief.md). **No owner walkthrough or participant session has run.** This is an empty worksheet, not research findings or validated usefulness.

Use [Demo 04](brand-demo/core-journeys.md) for appearance and the existing Figma scenario links for represented navigation. Use the [calendar specimens](brand-demo/journal-calendar.md) for visual comprehension only. Record the actual Git commit / Figma version at the time of each session. Static fields/actions cannot demonstrate typing, copying, date filtering, save/restore or cancellation.

## Tasks and observations

| Task | Specimen / version | Observed outcome | Assistance | Misunderstanding | Severity | Proposed change | Retest |
| --- | --- | --- | --- | --- | --- | --- | --- |
| Keep original words without accepting advice | Owner walkthrough 25 Oct; main `812b1ca` boards on phone (CircleU Preview `--board`) | Owner accepted all recommendation cards: start from Work through a moment; Save only my words found on Write and Suggestion screens | Moderated: recommendation cards, static boards | None reported | Low | Rename "Review a reflection" → "Get a suggestion"; Suggestion screen secondary → "Save without suggestion"; keep both full-width; reflection stays opt-in; draft card only when a draft exists (real app) | Prototype copy applied on `codex/today-task1-changes`; not retested |
| Correct an interpretation, leave, return and find the intended version | Owner walkthrough 25 Oct; Suggestion → Edit reflection → Saved entry boards on phone | Owner accepted: original words shown locked on the edit screen; Journal shows the latest saved version at the top | Moderated: recommendation cards, static boards | None reported | Low | "Edit reflection" becomes a full-width outlined button under the suggestion; Back with unsaved edits asks "Keep editing / Discard" (real app; static prompt state added); remove "This updates the reflection only." | Prototype applied on `codex/today-task1-changes`; not retested |
| Practice from a reflection, then create an independent message; distinguish Copy and Save | Owner walkthrough 25 Oct; Saved entry → Practice → Wording → Saved message boards | Owner kept Save and Copy as separate buttons and Copy as the main action on the saved message | Moderated: recommendation cards, static boards | None reported | Low | Linked vs standalone shown as a small icon tag ("From: <entry>" with link icon, "On its own" with speech bubble) instead of a grey line | Prototype applied on `codex/preview-assets-demo`; not retested |
| Find another date's entry, inspect an empty day, then use Search / All entries | Owner walkthrough 25 Oct; Journal calendar boards (21 Oct with 2 entries, empty 20 Oct) | Owner chose the recommended options for empty-day text, past-day writing and search | Moderated: recommendation cards, static boards; search and date filtering not testable here | None reported | Low | Empty day: "Nothing saved on this day."; writing from the calendar is today only ("New reflection for today"); search covers all entries and closing it returns to the selected day | Empty-day copy applied on `codex/preview-assets-demo`; search behaviour recorded for the real app |
| Explain proposed storage/recovery and inspect linked-deletion choice/failure | Owner walkthrough 25 Oct; Privacy and data screen on phone; deletion choices discussed as cards (no deletion specimen) | Owner chose the recommended deletion, failure and placement options | Moderated: recommendation cards; deletion and failure not testable in previews | None reported | Medium (data-loss risk if built differently) | Deleting an entry with a linked message asks Keep message (default) / Delete both; a failed delete keeps the entry and shows "Couldn't delete. Try again."; Privacy and data lives in Settings plus the Log in link, with no Today card | Recorded as real-app requirements |

For operations missing from a specimen, record **not testable here**. A moderator switching images or preset Figma states is not unaided completion, and a static success label does not establish a completed save. Record privacy/deletion misunderstandings individually; do not turn five outcomes into market validation.

## Walkthrough summary — 25 October

All five tasks were run with the owner on 25 October as a **moderated walkthrough**. The owner viewed static boards on the iPhone (CircleU Preview) and chose from recommendation cards, so this is design-decision evidence, not unaided usability or participant research. No misunderstandings were reported.

| Area | Decided |
| --- | --- |
| Starting a moment | Work through a moment on Today; "Continue your draft" only when a draft exists (real app) |
| Suggestions | Opt-in: "Get a suggestion" or "Save only my words"; Suggestion screen offers "Save without suggestion" and a full-width outlined "Edit reflection" |
| Editing | Original words shown locked; leaving with unsaved edits asks Keep editing / Discard (real app); no redundant helper line |
| Practice | Save and Copy separate; Copy is the main action on a saved message; linked/standalone shown as an icon tag |
| Journal and calendar | Latest saved version first; empty day "Nothing saved on this day."; today-only writing; search across all entries, returning to the selected day |
| Data and deletion | Linked-message deletion asks (keep by default); failed deletes stay visible with "Couldn't delete. Try again."; Privacy and data in Settings and on Log in |
| Screens | No sample footer or corner tags on screens; one decorative illustration per information/success screen; light mode only for now |

Still pending: the calendar default (open on today; dots mean saved entries only), All entries / Today shortcuts, month-arrow behaviour, and locale/week-start/time-zone policy. These are proposals for the first production slice (typed capture → local save → Journal → edit), which still needs its own implementation plan and owner approval.

## Walkthrough decisions — 25 October

Owner decisions from the moderated walkthrough. The owner picked from Claude's recommendation cards (relayed via the project coordinator). These are prototype/design decisions, not production approval.

- **Task 1:** "Save only my words" stays a full-width secondary button the same size as the main action. The AI reflection is opt-in: after writing, the person chooses to get a suggestion or to save, and nothing appears automatically. The Suggestion screen offers "Save without suggestion". The Write button is renamed "Get a suggestion". Today shows "Continue your draft" only when a draft exists (real app; the static first-visit board may keep it).
- **Task 2:** "Edit reflection" is a full-width outlined button under the suggestion. Leaving the editor with unsaved edits asks "Discard your changes?" with Keep editing / Discard: a requirement for the real app, shown here as a static `edit-reflection-leave` board. "This updates the reflection only." is removed. The locked original words on the edit screen and the latest saved version at the top of Journal stay.
- **Task 3:** linked vs standalone practice is a small icon tag ("From: The group deadline" with a link icon, "On its own" with a speech bubble). Save and Copy stay separate, and Copy stays the main action on a saved message.
- **Task 4:** the empty day reads only "Nothing saved on this day." Writing from the calendar is today only for now. Search covers all entries regardless of the selected day, and closing search returns to that day.
- **Task 5:** deleting a journal entry that has a linked practice message asks "Also delete the linked message?", with Keep message (default) or Delete both. A failed delete leaves the entry in place and shows "Couldn't delete. Try again." Privacy and data lives in Settings (the sliders icon on Today) plus the existing Log in link, with no card on Today.
- **Preview demo and assets (PR #7):** other email/password on Log in keep the recovery fixture flow (only the demo account opens the sample workspace); dark mode is deferred until the light screens are final; illustrations stay restrained (one per information or success screen, none on forms or editors).
- **Screens (during task 1):** remove the "BRAND DEMO · STATIC SAMPLE" footer and the Sample/Draft corner tags from every preview screen; sample status stays in captions, file names and docs.

## Open calendar decisions

Design feedback received before a formal walkthrough: the owner found the core screens text-heavy and requested some icons. [Demo 05](brand-demo/lighter-icon-journeys.md) provides a lighter comparison. This is a design request, not a completed task, usability session or approval of icon-only editing discoverability.

| Proposal from the brief | Owner decision |
| --- | --- |
| Default to Today; dots/counts represent saved Journal content only | Pending specific review |
| Search all Journal entries, temporarily suspend date filtering, restore selection on return | **Approved by owner, 25 October walkthrough** (task 4) |
| All entries escape route; Today shortcut | Pending specific review |
| Month arrows retain/clamp day number; future dates browsable without backdating new entries | No backdating approved (writing from the calendar is today only, task 4); month-arrow behaviour still pending |
| Locale/week-start/time-zone policy and production hit targets | Pending implementation/design review |

The owner approved creating the visual examples and removed the extra calendar-header icon. That does not establish tested calendar interaction or participant agreement.

## Follow-up gate

After observations exist, link each material finding to a revised specimen, an explicit scope decision or a retest. Decide whether an interactive sample extension is needed for untestable operations. First production implementation remains proposed: guest-runtime/storage feasibility, then manual typed capture → local save → Journal/detail → edit/reopen. No production work starts from a worksheet alone.
