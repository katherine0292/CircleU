# Today and Journal — Figma review 11

Recorded 31 October 2026. Carries the owner's selected Refine Option A into Today and Journal for visual/flow review. This is an editable Figma prototype, not an implementation change or approval to change the native app.

- [Start Today → Journal](https://www.figma.com/proto/rfknpmLIXsOxA7fHUQQMtR/CircleU-Design--from-Claude-canvas-?node-id=60-16948&starting-point-node-id=60%3A16948)
- [Review Journal after saving](https://www.figma.com/proto/rfknpmLIXsOxA7fHUQQMtR/CircleU-Design--from-Claude-canvas-?node-id=60-17209&starting-point-node-id=60%3A17209)
- [Review calendar](https://www.figma.com/proto/rfknpmLIXsOxA7fHUQQMtR/CircleU-Design--from-Claude-canvas-?node-id=60-21516&starting-point-node-id=60%3A21516)
- [Edit Figma frames](https://www.figma.com/design/rfknpmLIXsOxA7fHUQQMtR/CircleU-Design--from-Claude-canvas-?node-id=60-16948)

## Design

Preserves the original 390 × 844 phone layout, date-led journal cards and existing Pingu assets. Uses Plus Jakarta Sans, the selected blue accent, pale background, white rounded cards and outline controls. The tab bar stays at y764 across all 59 frames. Calendar cells contain dates and entry-count dots only, with Pingu outside the calendar.

Today includes writing, a simulated listening state, saving, save failure, microphone-unavailable and draft departure states. Journal includes saved feedback, browsing, calendar filtering, preset search, entry editing, discard/error states and an optional guided reflection. Reflection is explicitly user writing; this does not introduce cloud AI interpretation.

## How to review

1. On Today, tap a prompt or the writing area to load invented text. Alternatively tap the microphone, then Stop. Save leads through a loading state to Journal.
2. Open the calendar. October 31 has two entries; October 29 and 27 have one each. Other October dates show an empty-day state. Scroll to reach the second October 31 entry; the header and tabs stay fixed.
3. Clear the calendar filter. Tap Search to show the preset query `deadline`; tap its search icon to switch to `weekend` with no results. Clear returns to all entries.
4. Open the first entry, tap the pencil and Save changes. Back returns to a list containing the revised text.
5. Separate Figma starting points expose an empty journal, save failure, unavailable dictation, unavailable journal and edit failure. These support design review without introducing faults into the main path.

## Scope and limitations

- All words and dates are invented fixed scenarios. No keyboard input, recording, storage or live search is performed by this Figma prototype.
- All 31 October dates are linked. September and November provide adjacent empty-month views; their day cells and outer boundary arrows are not fully interactive.
- Entry Back returns to the list rather than restoring a prior date/search filter. This is a prototype limitation, not a native navigation specification.
- Practice opens the approved review 10 through a URL action. It is a separate prototype, not a single continuous native app session.
- Settings, avatar selection and other existing native controls are outside this bounded visual review.
- Existing Figma pages and native code remain intact. No paid image or AI generation was submitted; connector editing does not report a credit debit.

## Evidence

- [Builder source](build-figma.js) and [structural validation](validation.json): 59 frames, 1,290 internal links, 59 Practice URL links, no invalid destinations, no detected clipped children or checked copy violations. The large link count primarily reflects calendar navigation.
- Browser walkthrough verified simulated record → Stop → writing → Save → Journal, October 31 scrolling with fixed tabs, October 30 empty filtering, clearing, both preset searches, entry editing and the updated list on return. [Walkthrough screenshot](walkthrough.jpg).
- Visual checks corrected clipped entry rows, calendar dots and horizontal control rows before final export. [Today](today.png), [Journal](journalSaved.png), [Calendar](calendar31.png).
- Date arithmetic verified October 1 is Thursday and October 31 is Saturday in 2026, using a Monday-first calendar.
- No Swift tests, simulator run, physical-device or VoiceOver verification was performed for this Figma-only change. Structural checks do not establish accessibility or arbitrary user-data behavior.

Next: owner reviews the hierarchy, writing area, calendar and edit path before deciding whether to carry this styling into SwiftUI.
