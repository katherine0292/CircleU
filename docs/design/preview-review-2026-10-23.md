# Hub review and editor previews

Status: design recommendations, 23 October 2026. The owner requested this review and static editor previews; the changes below to hub navigation/visuals are proposals, not an approved redesign. [Current renders](swiftui-previews/README.md) remain the Draft 02 comparison baseline.

## Three-screen review

| Screen | Keep | Recommended refinement |
| --- | --- | --- |
| Today | Clear purpose, one primary New reflection action, visible unfinished draft | Make the draft card itself the single resume entry point; remove the separate Resume draft button. Keep Practice as a smaller shortcut, and move Privacy and data into a clearly labelled settings entry. |
| Journal | Saved moments grouped together, linked practice reachable from an entry | Make the entry row the open action and remove Open saved entry. Add a date and brief excerpt when real history is designed. Keep New reflection as the creation action; make room for the already-planned search. |
| Practice | Standalone message practice without requiring a reflection | Keep Start a new practice primary. Let recent message rows open themselves; remove Open saved practice. Show a short message excerpt and a source label only when linked. |

Repeated entry points are duplicated controls, not separate features. Today can remain an intentional shortcut into Journal or Practice. The new structure remains Today / Journal / Practice; circles and rewards remain deferred.

The current boards have substantial space between content and actions because they preserve the Figma fixed-action layout. During visual refinement, place creation actions nearer the content and use a native bottom tab bar in the eventual iOS implementation. Test with real history, long text, keyboard presentation and accessibility sizes before deciding final spacing. No user study has been run.

## Editor review

- [Reflection proposal](swiftui-previews/edit-reflection.png): preserve original words in a distinct read-only card; show the edited feeling/reflection separately; Save reflection and Discard edits. This proposal comes from the agreed flow, not a verified rendering of Figma node `27:1668`. The Figma connector reached its Starter-plan call limit before returning that frame.
- [Message editor](swiftui-previews/edit-message.png): follows verified Figma node `27:1671`; context and draft wording are separate, with Save message, Copy message and Discard edits. The copy makes standalone storage and “nothing is sent” explicit.
- Both are static labels and sample text, with no typing, keyboard, clipboard or saving. Real editors need clear field affordances, change tracking, invalid/empty input handling, save-error retention and a discard confirmation when edits exist. Existing Figma states cover representative failures; these two SwiftUI boards do not recreate every state.
- Keep decorative art out of the editing area. Text should have priority when correcting something personal.

## Reuse of the previous visual assets

**Recommendation: reuse CircleU's visual identity selectively within the new structure.** The old home screenshot has warmth and character, but includes streaks and the old five-tab navigation. Those are not part of the approved MVP.

| Existing material | Recommendation |
| --- | --- |
| `PinguMascot` | Good candidate for a small welcome or empty-state illustration; inspected PNG has a transparent surround and no catalog label. Preserve aspect ratio. |
| Rounded system typography | Continue using it; already used in the SwiftUI previews. |
| Blue/ice palette and gentle background | Carry forward as the visual starting point, then consolidate draft and production tokens after design review. |
| Glass/aurora treatments | Evaluate a restrained version after hierarchy and contrast checks; do not apply to every text-editing surface by default. |
| `PinguReading` / `PinguCalm` | Do not reuse these raster files unchanged: inspected images contain baked-in catalog markings and/or rectangular backgrounds. Find clean originals or prepare approved exports first. |
| Level-up/celebration/reward assets | Preserve in the repo for later; do not let their availability bring rewards back into the MVP. |

Only `PinguMascot`, `PinguReading`, `PinguCalm`, the previous home screenshot and design source were visually/source reviewed here. This is not a full asset-quality or rights audit. No source asset was modified, copied into the prototype, or uploaded to Figma.

## Xcode and next review

The package opens and Canvas renders with scheme **CircleUVisualPrototype** and destination **My Mac**. The default **CircleUVisualPrototype-Package** scheme included the renderer executable and caused an `ENABLE_DEBUG_DYLIB` preview error. Selecting the library scheme resolved it without changing project settings. [Xcode evidence](swiftui-previews/xcode-message-preview.jpg).

Next: review the proposed duplicate-control removals, confirm the reflection layout against Figma when connector access is available, and try a restrained Pingu treatment on Today or an empty state. Full app, migration and release validation remain deferred.
