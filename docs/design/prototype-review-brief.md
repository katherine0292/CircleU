# Core-journey prototype review brief

24 October 2026. The owner approved the bounded static-preview milestone after reviewing the planning handoff. The [branded core specimens](brand-demo/core-journeys.md) and [multiple-entry calendar example](brand-demo/journal-calendar.md) are prepared. Detailed calendar interactions and the owner walkthrough remain pending; see the [worksheet](prototype-review-results.md). This approval does not cover production implementation or reopen circles, rewards or cloud backup scope.

## Outcome

Review one complete typed-reflection journey, one direct-practice journey and retrieval through Journal. Determine whether the flow helps someone keep their own account, correct an interpretation and find usable wording. The next deliverable is a bounded set of branded sample screens and an owner walkthrough, followed by participant research only when recruitment/outreach is authorized.

Use existing Figma scenarios for navigation/recovery review and existing SwiftUI artwork/components for visual review. The sources serve different purposes: [Draft 02](README.md) documents 125 connected scenario frames; [brand demo 02](brand-demo/flow-previews.md) and the [calendar](brand-demo/journal-calendar.md) provide static visual specimens. These are documented historical counts, not a fresh live Figma audit. Neither proves application behavior.

## Coverage to complete

| Route | Already available | Next bounded addition |
| --- | --- | --- |
| Today → typed capture → reflection → saved entry | Figma Capture `11:101`, Reflection `11:102`, Entry `11:103`; branded Today and reflection editor | Branded capture, reflection review and saved-entry detail |
| Practice → context/goal → wording → saved standalone message | Figma New context `11:108`, Wording `11:110`, Practice detail `11:112`; branded Practice and message editor | Branded context, wording result and standalone detail |
| Saved reflection → linked practice | Figma Linked context `11:109`, Linked wording `11:111`, Linked entry `11:114` | Reuse those flow snapshots to review the explicit source handoff; avoid a second independent reflection |
| Journal retrieval | Branded saved/empty calendar dates and list view; Figma history/detail states | Specify date/search/all-entry behavior and show one multiple-entry date |
| Corrections, drafts and failures | Figma edit/discard/changed-source, loading, manual fallback and save-error states | Select representative states for review; do not restyle every recovery permutation |
| Privacy and previous data | Figma privacy/recovery guides; approved storage plan | Test comprehension using the proposal and its limits; do not describe the existing app as already local-only |

## Fixed rules for this review

- Today / Journal / Practice remain the three destinations. Preserve accepted Pingu artwork, Plus Jakarta Sans and palette. Calendar header contains the month and functional arrows, with no extra decorative icon.
- Use invented examples only. Capture and saved detail distinguish original words from the reflection. Saving words alone remains useful. Suggested next steps and practice are optional.
- A saved item card opens that same item; do not add a second open button or a separate save-success screen. Edit/Save/Discard must refer to one existing sample item.
- Practice works independently of Journal. One editable wording option is enough for this review and fits the current “up to three” proposal. Evaluate alternatives later if observations justify them. Copy and Save are independent; copying sends nothing and does not imply saving.
- An interpretation that no longer matches changed original words is visibly stale. A failed save retains the edited words; no snapshot should imply confirmed storage merely because an action label was pressed.
- Reuse existing privacy/recovery scenarios, with the planned guest-local policy clearly distinguished from current app behavior. No extra backend/account/release work is part of this milestone.

## Calendar interaction proposal to review

These are proposals for a later interactive prototype/implementation, not behaviors of the current static grid:

1. Default to today's month and selected date. Dots mean at least one saved Journal reflection/note; one dot may represent multiple items. Standalone practice does not contribute to Journal dots/counts.
2. Selecting a day shows its true count and entries below. Empty day, empty whole journal, read failure and loading are separate states. Do not silently convert a read failure to no entries.
3. Provide an All entries route. Search spans the whole Journal and temporarily suspends the date filter; clearing/closing Search returns to the previous date selection. Calendar filtering never deletes or moves content.
4. Proposed month-arrow behavior: retain the selected day number where valid, otherwise clamp it to the destination month's last day. Label the resulting selected date explicitly. Include a Today shortcut; review it before adding another decorative symbol.
5. New reflection starts for today regardless of the browsed date. Future dates may be browsed as empty; no backdating or future-dated writing is introduced by calendar selection.
6. Keep the fixed English Monday-first October 2026 fixture for visual comparison. Production locale, week-start and time-zone grouping remain to be agreed and tested. The UI must distinguish today from selection without relying on color alone.

## Walkthrough tasks and evidence

Use the owner's walkthrough first. The existing proposal for five adult research participants remains in [research findings](../product/research-findings.md); no recruitment or messages are authorized by this brief. Participants may use equivalent invented situations.

| Task prompt | Observe |
| --- | --- |
| Write privately about a difficult moment and keep it without accepting advice. | Finds words-only save; understands original versus suggested content and the saved destination |
| Correct an interpretation, leave partway, return and find the version intended to keep. | Save/Discard/Keep draft meanings; changed-source warning; no duplicate-entry expectation |
| Prepare a deadline-update request from a reflection, then a separate boundary-setting message. | Linked context understood; direct practice needs no Journal entry; Copy and Save distinguished |
| Find an entry on another date, inspect an empty day, then find the same item through Search or All entries. | Dot/count/today/selection meanings; no mistaken backdating or lost-history expectation |
| Explain where the proposed app keeps information and what happens after losing the phone; remove a reflection while keeping its message, then inspect a deletion failure. | Guest/local limits, device backups, linked-deletion scope, and failure recognized as failure |

Record task/source version, observed action, assistance needed, hesitation, interpretation/correction, useful wording and counterevidence. Use “not testable in this specimen” where typing, calendar/search, clipboard or persistence is absent. A moderator switching static boards is not unaided interaction completion. Figma branch resets are a prototype limitation, not evidence that saved data persists or disappears in the future app.

No outcomes have been collected. Before execution, create an empty results table with columns: task, specimen/version, observed outcome, assistance, misunderstanding, severity, proposed change and retest status. Keep raw private research material outside Git. Summaries require consent and anonymization.

## Milestone exit and following work

Finish when the missing branded route specimens are reviewed, date/search decisions are resolved or explicitly deferred, and the walkthrough records actual findings and critical misunderstandings. Visual comfort/contrast/larger-text review should identify problems; fixed macOS renders do not certify accessibility.

Then decide whether an interactive sample harness is necessary to test decisions the existing Figma prototype cannot represent. Do not build a second application merely to simulate persistence. After scope/implementation approval, the first production slice should be manual typed capture → reliable local save → Journal/detail → edit/reopen, preceded by a guest-runtime/storage feasibility check. Add Practice, voice and model generation in dependency order; legacy release recovery stays a separate prerequisite for distribution.
