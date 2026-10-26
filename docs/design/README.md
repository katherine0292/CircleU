# CircleU Figma design reference

Status: Draft 02, updated 23 October 2026. The owner approved Today/Journal/Practice navigation, removing duplicated steps and deferring circles/rewards. This is a research prototype, not an approved visual specification or a working app. Draft 01 remains on its original page as a reference.

24 October: the owner authorized a Figma refresh using the original native proportions and accepted new branding/content. The [refresh handoff](figma-brand-refresh-brief.md) defines the ordered screens and review checks. Fresh metadata and canvas-tool checks hit the Starter-plan MCP call limit; no canvas update was made. The links below still open Draft 02, not the newer local brand review.

The owner then authorized the [native onboarding brand specimen](brand-demo/native-onboarding.md) while connector access is limited. It is available in the existing SwiftUI package and was visually displayed in Xcode's iPhone Canvas. This does not update Draft 02 or the production app.

## File and ownership

- [CircleU — MVP Research & Prototype](https://www.figma.com/design/RVLtfmIVcO8gNk5fam0Vjd)
- [Open Draft 02 on Today](https://www.figma.com/design/RVLtfmIVcO8gNk5fam0Vjd?node-id=11-100)
- [Play Draft 02](https://www.figma.com/proto/RVLtfmIVcO8gNk5fam0Vjd?node-id=11-100&starting-point-node-id=11%3A100)
- Created through the verified `tuannm3812@gmail.com` connection using Tuan Nguyen's team. Default destination: the authenticated user's drafts. Sharing permissions were not changed.
- Current page: **MVP — Draft 02**, first in the page list. Approved direction and remaining proposals are recorded in the [MVP definition](../product/mvp-definition.md).

## Canvas structure

| Area | Screens / purpose |
| --- | --- |
| 01 / Today and Journal | Today, Capture, Reflection, entry detail, Journal, note detail and Journal sample states |
| 02 / Practice | Practice hub, new/linked context, wording states and standalone practice detail |
| 03 / Linked entry and voice states | Entry with linked practice, recording, transcript review and AI/microphone recovery |
| 04 / Reflection and message editors | Save/discard editors for standalone and linked content, including editing in either order |
| 05 / Saved edits | Corrected reflection, revised message and combined linked results |
| 06 / Reopen and continue | Matching history states and practice from a corrected reflection |
| 07 / Copy, draft and empty states | Copy preview, keep/discard/continue draft, empty Today/Journal/Practice and entry options |
| 08 / Entry data-control previews | Single unlinked-entry export, delete confirmation/failure and Today after discarding a draft |
| 09–11 / Loading, validation and failures | Cancellable generation/transcription, empty input, voice interruption and preserved-edit retries |
| 12 / Privacy and storage | Approved guest/local direction, proposed onboarding/settings, copy/export errors and protected-storage availability |
| 13 / Changed-source review | Invalidate an earlier suggestion, regenerate or save updated words only, then reopen |
| 14–16 / Linked controls and recovery | Explicit delete scope, export handoff, retained standalone message, storage errors and a review guide |
| 17–19 / Previous data and imports | Existing device data, account verification, backup checks, conflict review and interruption-safe import examples |
| 20–21 / Previous cloud management | Export handoff, separate account deletion, pending status, older-device help and previous-data review guide |
| Draft 02 controls | Reusable tab items and inline optional next-step variants; buttons/cards and styles reuse Draft 01 foundations |

Use Present/Play on Today, or open the [recovery review guide](https://www.figma.com/proto/RVLtfmIVcO8gNk5fam0Vjd?node-id=36-449&starting-point-node-id=36%3A449) and scroll to a scenario. The [previous-data review guide](https://www.figma.com/proto/RVLtfmIVcO8gNk5fam0Vjd?node-id=65-1436&starting-point-node-id=65%3A1436) covers the legacy transition. Additional starting points cover Journal, Practice, editing, empty states and privacy introduction. There are 125 screen/state frames across 21 numbered sections, including guides and alternate representations of the same content. These are scenario snapshots, not 125 required steps or distinct features. The [prototype state manifest](prototype-state.json) records the current node IDs.

The typed route is Today → Capture → Reflection → Entry. Voice retains transcript review. Saving opens content directly, and Journal reopens it; there is no separate save-confirmation destination. Next-step add/remove is an inline component interaction. Tabs return from details to Today, Journal or Practice. Circles and rewards have no destinations.

## Scope and limitations

The screens use an invented group-project deadline scenario. Navigation is connected; actual typing, transcription, AI generation, clipboard actions and persistence are simulated. Editors display a visibly different preset replacement. Save applies that sample to the resulting detail; Discard returns to the originating screen unchanged. Entry detail retains the original words separately from the feeling and reflection. Standalone practice saves into Practice without creating a reflection.

Reflection review now offers Edit reflection, Edit my words and Save only my words. Saved reflections can also be edited. Messages can be edited from either the suggested wording or the saved detail. Copy has a separate simulated outcome, including before saving an edited message. Linked reflection/message edits work in either order and preserve the other content. Matching Journal/Practice history states reopen the changed content.

Draft exit distinguishes keep, discard and continue. Discarding a draft removes its resume action without directing the user into an empty Journal. Separate first-visit states show empty Journal and Practice. Entry options preview export and deletion for an unlinked reflection; cancellation keeps it, simulated deletion opens an empty Journal, and a separate failure starting point retains the entry.

The recovery pass adds six three-second loading transitions with cancel paths; empty reflection/context/message validation; generation, save, draft, copy, export and storage errors; model unavailability; voice-access explanation and interruption/transcription failures. Original-source changes now have a stale-suggestion warning, fresh result or note-only save and matching history. Failures are accessed from the review guide, not application-facing test buttons.

Linked-data controls are demonstrated from the entry with both edits: export both; delete the entry and keep only its message; or delete both. Kept practice has no source link or copied journal context. A deletion failure leaves both records intact. Privacy screens reference the [privacy/storage plan](../product/privacy-storage-plan.md) and distinguish approved direction from unimplemented behavior.

Still outside this pass: real permission dialogs, typing, clipboard/file operations, dynamic validation, runtime cancellation/persistence, individual interpretation-field omission, multiple wording options, search and full settings/all-data export. Very-short/oversized-input behavior is specified in the plan; numerical model limits require device/model verification. Recovery patterns cover representative scenarios, not every item-state permutation. No participant testing has taken place.

The current Figma plan rejected multiple actions in a single reaction, preventing the attempted variable-driven save simulation. Draft 02 uses single-action navigation, Back actions and explicit sample states instead. Note, linked and edited details return to their matching history states. Returning through Today or switching to another area can reset to a default sample route rather than simulating global saved-data state. Next-step component interactions are not persisted across all snapshots. The app must eventually preserve actual state; the prototype does not prove persistence, idempotent saves or real deletion.

The prototype labels the approved guest/local, no-CircleU-cloud direction and explicitly acknowledges device backups and exported copies. The legacy recovery pass updated the earlier proposal labels to say the direction is approved but not implemented. Privacy settings and introduction now link to previous-data recovery. The [legacy flow reference](legacy-recovery-flow.md) records import, conflict, export, deletion and older-device routes and their unresolved dependencies. No real private journal content should be entered into this sample.

## Visual starting point

**26 October Today options:** the CircleU Design canvas (a private Claude artifact) holds options for the illustrated mic (A), the Get a suggestion redesign (B) and the background (C), plus a States page. The art they need is in the [Pingu scene and mic art brief](pingu-scene-art-brief.md).

**Journal calendar:** the owner requested cute date browsing inside Journal. [Demo 03](brand-demo/journal-calendar.md) adds a rounded month grid, selected-day entries and a calm empty-day example to the isolated previews. The owner subsequently requested removing the extra calendar-header icon. Interaction, time-zone grouping and accessibility remain implementation/review work.

**Brand demo 02:** the accepted identity now appears across [Today, Journal, Practice and both editors](brand-demo/flow-previews.md), with a softer Practice icon. This isolated visual pass preserves earlier references; it is not a Figma update or application implementation.

**Brand demo 01:** the owner approved applying softly shaded illustration and Plus Jakarta Sans to an isolated demo. Review the [brand board, Today sample and asset notes](brand-demo/README.md). Original production assets remain intact; this does not imply approval to replace them or change Draft 02 flows.

**Latest owner direction:** modernize the logo, Pingu avatar and illustrated icons together, with a clean non-sketchy treatment. The [branding guideline discussion draft](branding-guideline.md) records this preference, font candidates and unresolved choices. It supersedes earlier recommendations to retain the logo unchanged or use outline-only brand icons; no production replacements have been applied.

The owner subsequently approved static SwiftUI previews of Today, Journal and Practice while deferring full-app checks. The [preview gallery and Xcode instructions](swiftui-previews/README.md) show native rounded typography alongside Draft 02 copy and colors. This isolated package is visual-only; it does not implement the application or change these Figma frames.

The [hub/editor and asset review](preview-review-2026-10-23.md) records proposed duplicate-control removals, selective reuse of Pingu assets, and the two added static editor previews. Message editing follows verified Figma context; reflection editing is a labelled proposal pending access. Xcode Canvas was subsequently verified with the library scheme.

Pale blue surfaces, dark text, blue actions, rounded cards and calm language carry forward the existing direction. The palette and larger body type are draft proposals, not an exact export of production tokens. Pingu illustration, aurora/glass treatments and final navigation are deferred until the core journey is reviewed.

The app uses Apple's rounded system font. The Figma bridge listed SF Pro Rounded but reported it missing and rejected component text updates. The draft therefore uses **Inter** throughout; this substitution is annotated on the canvas. Revisit native typography before a high-fidelity design is approved.

Draft 02 reuses the 20 draft variables, five text styles, three-variant button and content-card component. It adds selected/default tab items and chosen/none next-step variants. This is not a completed production design system or Code Connect mapping.

## Verification and next review

The [24 October onboarding review](brand-demo/onboarding-review.md) identifies the gap between these Inter wireframes and the accepted Pingu/Plus Jakarta Sans branding. A clean local first-use proposal is available in the conversation; Figma edits and removal of existing in-screen review labels remain pending because the Starter-plan MCP limit blocked further calls. The proposal does not change the app's existing account/cloud onboarding.

The [24 October review brief](prototype-review-brief.md) and [milestone plan](../superpowers/plans/2026-10-24-prototype-review-milestone.md) now select a bounded next pass: reflection, direct/linked practice and Journal retrieval. Reuse existing Figma recovery states; complete missing branded core-route specimens before multiplying visual variants. The new plan is for review, not started implementation.

The [user-flow review](flow-review-2026-10-23.md) records the original gaps, Draft 02 follow-up and beginner-friendly exercises. The core correction/message-edit/save/discard/reopen paths are now represented, alongside the earlier simplifications.

The earlier edit pass passed 300 structural assertions across 49 states. The recovery pass visually reviewed all eight new sections and changed core screens, then passed 480 live structural assertions across all 95 states. Checks cover connections, six timers, corrected-source preservation, retained-message scope, failure recovery, history reopening, screen/scroll bounds and reachability from starting points. No missing fonts, text extending outside its parent, dangling destinations or unreachable state frames were found. Long content scrolls above fixed actions/tabs. This is connection and screenshot inspection, not browser-driven timing/cancellation testing, a usability study or accessibility certification. No application code or runtime tests were changed/run.

The subsequent legacy pass added 30 states, passed a 1,712-assertion structural audit with a corrected action-type recheck of all 407 node-target actions, and found all 125 states reachable. Seven component transitions initially flagged as screen destinations were confirmed valid. Five new sections and three updated entry screens were visually checked; new text/font/bounds checks found no errors. Ten sample timers now exist. See the [legacy verification and limitations](legacy-recovery-flow.md#verification-and-limitations); no real data operations or browser-driven interactions were tested.

Next: review the recovery exercises, finish the [TestFlight/backend inventory](../engineering/legacy-data-inventory.md) and [device/migration scope](../product/supported-devices.md), then test comprehension with the intended audience. Actual storage/model migration and device validation remain prerequisites for a trustworthy beta.
