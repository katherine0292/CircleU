# Prototype walkthrough worksheet

Prepared 24 October 2026 for the [review brief](prototype-review-brief.md). **No owner walkthrough or participant session has run.** This is an empty worksheet, not research findings or validated usefulness.

Use [Demo 04](brand-demo/core-journeys.md) for appearance and the existing Figma scenario links for represented navigation. Use the [calendar specimens](brand-demo/journal-calendar.md) for visual comprehension only. Record the actual Git commit / Figma version at the time of each session. Static fields/actions cannot demonstrate typing, copying, date filtering, save/restore or cancellation.

## Tasks and observations

| Task | Specimen / version | Observed outcome | Assistance | Misunderstanding | Severity | Proposed change | Retest |
| --- | --- | --- | --- | --- | --- | --- | --- |
| Keep original words without accepting advice | Owner walkthrough 25 Oct; main `812b1ca` boards on phone (CircleU Preview `--board`) | Owner accepted all recommendation cards: start from Work through a moment; Save only my words found on Write and Suggestion screens | Moderated: recommendation cards, static boards | None reported | Low | Rename "Review a reflection" → "Get a suggestion"; Suggestion screen secondary → "Save without suggestion"; keep both full-width; reflection stays opt-in; draft card only when a draft exists (real app) | Prototype copy applied on `codex/today-task1-changes`; not retested |
| Correct an interpretation, leave, return and find the intended version | Not run | Not observed | Not observed | Not observed | Unassessed | None yet | Not run |
| Practice from a reflection, then create an independent message; distinguish Copy and Save | Not run | Not observed | Not observed | Not observed | Unassessed | None yet | Not run |
| Find another date's entry, inspect an empty day, then use Search / All entries | Not run | Not observed | Not observed | Not observed | Unassessed | None yet | Not run |
| Explain proposed storage/recovery and inspect linked-deletion choice/failure | Not run | Not observed | Not observed | Not observed | Unassessed | None yet | Not run |

For operations missing from a specimen, record **not testable here**. A moderator switching images or preset Figma states is not unaided completion, and a static success label does not establish a completed save. Record privacy/deletion misunderstandings individually; do not turn five outcomes into market validation.

## Walkthrough decisions — 25 October

Owner decisions from the moderated walkthrough. The owner picked from Claude's recommendation cards (relayed via the project coordinator). These are prototype/design decisions, not production approval.

- **Task 1:** "Save only my words" stays a full-width secondary button the same size as the main action. The AI reflection is opt-in: after writing, the person chooses to get a suggestion or to save, and nothing appears automatically. The Suggestion screen offers "Save without suggestion". The Write button is renamed "Get a suggestion". Today shows "Continue your draft" only when a draft exists (real app; the static first-visit board may keep it).
- **Screens (during task 1):** remove the "BRAND DEMO · STATIC SAMPLE" footer and the Sample/Draft corner tags from every preview screen; sample status stays in captions, file names and docs.

## Open calendar decisions

Design feedback received before a formal walkthrough: the owner found the core screens text-heavy and requested some icons. [Demo 05](brand-demo/lighter-icon-journeys.md) provides a lighter comparison. This is a design request, not a completed task, usability session or approval of icon-only editing discoverability.

| Proposal from the brief | Owner decision |
| --- | --- |
| Default to Today; dots/counts represent saved Journal content only | Pending specific review |
| Search all Journal entries, temporarily suspend date filtering, restore selection on return | Pending specific review |
| All entries escape route; Today shortcut | Pending specific review |
| Month arrows retain/clamp day number; future dates browsable without backdating new entries | Pending specific review |
| Locale/week-start/time-zone policy and production hit targets | Pending implementation/design review |

The owner approved creating the visual examples and removed the extra calendar-header icon. That does not establish tested calendar interaction or participant agreement.

## Follow-up gate

After observations exist, link each material finding to a revised specimen, an explicit scope decision or a retest. Decide whether an interactive sample extension is needed for untestable operations. First production implementation remains proposed: guest-runtime/storage feasibility, then manual typed capture → local save → Journal/detail → edit/reopen. No production work starts from a worksheet alone.
