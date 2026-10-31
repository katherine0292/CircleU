# Journal tags — review 12

31 October 2026. Owner requested a visual demonstration of smaller type and illustrated activity/feeling tags beneath journal entries. This is a Figma-only review, not a change to the native app.

- [Open the clickable prototype](https://www.figma.com/proto/rfknpmLIXsOxA7fHUQQMtR/CircleU-Design--from-Claude-canvas-?node-id=68-394&starting-point-node-id=68%3A394)
- [Start with no tags](https://www.figma.com/proto/rfknpmLIXsOxA7fHUQQMtR/CircleU-Design--from-Claude-canvas-?node-id=68-23&starting-point-node-id=68%3A23)
- [Edit Figma frames](https://www.figma.com/design/rfknpmLIXsOxA7fHUQQMtR/CircleU-Design--from-Claude-canvas-?node-id=68-394)

## Review design

Uses existing Pingu Study, Work, Friends, Family and Overloaded artwork; existing Quiet Breath and Thoughtful illustrate Calm and Worried. Short labels disambiguate the artwork. No new images or paid generation were used. Imports are sourced from `JournalTags01/` and `PracticeFlow01/` within the prototype's existing BrandArtwork folder; existing masters are preserved.

Heading reduced from 28 to 24; journal writing remains 16 with 130% line height instead of 140%. Dates and time are now a compact row above full-width writing rather than a competing large date tile. Tags use 13px labels with 40px artwork in 44px controls. This allows shorter cards without shrinking the user's writing. Plus Jakarta Sans and the blue/ice brand remain unchanged.

One optional activity and one optional feeling are independent. In this review, tap either tag on the **first entry**, choose a value, then Done. Tap a selected value again to remove it. When both are unset, Add tag returns. All 20 combinations of four activities plus unset and three feelings plus unset are wired.

## Boundaries

- Only the first entry supports the tag editing walkthrough; the other two entries demonstrate the layout with invented, preselected tags.
- Words are fixed invented examples. Figma navigation simulates choices; it does not save a real record, classify text or call a model.
- No Cancel route in this bounded picker: Done returns with the current selections. Native cancellation/draft handling needs design before implementation.
- Calendar, search, Today and Practice open previous prototype flows by URL; choices do not persist across those separate flows. Calendar cells are unchanged.
- Native migration, persistence, export, stale-write/error handling and accessibility remain future work. This fixed 390 × 844 review is not Dynamic Type or VoiceOver evidence.

## Evidence and traceability

- Product intent updated in [overview](../../product/overview.md#journal-tag-review--31-october); proposed J7.1–J7.5 added in [user stories](../../product/user-stories.md).
- [Journal export](journal.png), [tag picker export](picker.png), [browser walkthrough](walkthrough.jpg), [builder](build-figma.js), [validation](validation.json).
- 40 frames, 20 activity/feeling combinations, 199 internal links; valid destinations and one font family. Journal tabs remain at y764. Visual review corrected the Overloaded choice wrapping by moving checkmarks to the upper corner.
- Browser verified opening the picker, deselecting both tags, Done returning to Add tag, reopening, choosing Work and Calm, and Done updating the first entry without changing its words. Restored the selected Study/Overloaded review start afterward.
- No Swift code changed; no app build, native unit/UI suites or physical-device checks run.

Next: owner reviews the visual weight and usefulness of the tags before a native implementation plan is approved.
