# MVP user-flow review — 23 October 2026

Status: review of Draft 01. Findings come from reading the live Figma screen text, navigation actions and starting points against the MVP definition. This is an expert walkthrough, not participant research or a runtime app test. No Figma layout or application code was changed for this review.

Earlier follow-up: the owner approved Today/Journal/Practice, shorter flows, and deferring circles/rewards. [Draft 02](README.md) addressed F01, F04 and F05 at the prototype level. The edit pass added reflection correction, save-without-interpretation, message editing/copy, save/discard/reopen, draft-exit choices and empty states. F02/F03 gained reviewable core paths; per-field omission and multiple wording options remain open. F06 and F09 have sample-state coverage. The latest recovery/privacy follow-up below adds F07/F08 coverage. The original observations are preserved as review history.

## Draft 02 recovery/privacy follow-up

Later follow-up, 23 October 2026: the [previous-data recovery pass](legacy-recovery-flow.md) adds 30 connected scenario states for existing device data, previous accounts, cloud-check failures, conflict-aware import, interruption/export and separate old-account deletion. Draft 02 now has 125 states. The [live inventory](../engineering/legacy-data-inventory.md) now verifies expired TestFlight 1.0 (1) and its iOS 17/iPhone+iPad compatibility; shipped Firebase/schema mapping remains unresolved because no original archive is available. The existing expired-build scenario covers this condition. This extends the historical review below without claiming implementation or participant validation.

The owner requested privacy/storage recommendations and loading, validation and error flows before coding. The [privacy/storage plan](../product/privacy-storage-plan.md) recommends a guest/local beta with no CircleU cloud AI or sync, on-device capability checks, explicit exports and honest OS-backup limits. This direction was subsequently approved by the owner on 23 October 2026; implementation and device/migration validation remain pending.

The [recovery review guide](https://www.figma.com/proto/RVLtfmIVcO8gNk5fam0Vjd?node-id=36-449&starting-point-node-id=36%3A449) links the new scenarios. Generation/transcription now show cancellable progress. Blank input has guidance instead of a result. Save/generation/voice/storage/copy/export failures preserve the relevant sample input and offer a useful next action. Updated source text invalidates the earlier interpretation and has a fresh result or note-only route. Linked deletion distinguishes keeping only the message from deleting both records, with no partial success on failure.

F07 now has progress, interruption and failed-transcription examples; actual permission prompts remain device behavior. F08 now has proposed privacy/settings and linked export/delete/error examples; full settings/all-data export and real enforcement remain open; the storage direction is now approved. The original numbered findings are retained as historical evidence, not a current missing-work checklist.

Walkthrough: choose Loading and cancel and cancel before three seconds; retry and let it complete. Choose Save failure, return to the editor, save and reopen the updated item. Choose Changed source and compare the fresh result with the updated input. Choose Linked data controls, keep the message while deleting the entry, then reopen Practice and verify that journal context is absent. Restart the guide for each scenario; they are preset branches, not globally persistent app data.

Verification: 480 live structural assertions passed across 95 reachable scenario frames, including six timed transitions, input/message preservation, history reopening and valid destinations. Eight new sections and changed core screens were visually checked. No app code, device behavior or participant outcomes were tested.

## Draft 02 edit-pass findings and changes

The main issue was that “edit” returned to the original situation/context instead of editing the generated reflection or message. Dedicated editors now distinguish those jobs. Saving shows the revised sample, while Discard returns unchanged. Original source text stays separate. The saved feeling and reflection now match the reviewed content instead of dropping the feeling or substituting a different summary.

Standalone messages remain in Practice. Linked message/reflection edits preserve the source link and each other's changes in either editing order. Each result has a matching history state for reopening. Copy can be previewed before or after Save and does not send anything. Rejecting the whole interpretation uses Save only my words; selective field removal still needs a later state.

Capture now offers keep draft, discard or continue. Discarding the draft keeps access to existing sample history. First-visit empty history is a separate scenario. Single unlinked-entry export, delete confirmation, cancellation and deletion-failure previews are available. Linked-content data control remains deliberately unrepresented until its choices are designed against M07.

Verification: 300 live connection/content/layout assertions passed across 49 scenario frames. Screenshots were reviewed for the new sections and changed core screens. This checks the prototype structure, not real persistence, clipboard operations, export, deletion, model behavior or participant usability.

## Current review exercises

1. **Correct a reflection:** [start at Reflection](https://www.figma.com/proto/RVLtfmIVcO8gNk5fam0Vjd?node-id=11-102&starting-point-node-id=11%3A102). Choose Edit reflection → Discard edits, then reopen the editor and Save reflection. Tap Journal and reopen the entry. Check that the changed feeling/reflection appear and the original words are unchanged. Also try Save only my words from the original review.
2. **Make wording yours:** [start at Wording](https://www.figma.com/proto/RVLtfmIVcO8gNk5fam0Vjd?node-id=11-110&starting-point-node-id=11%3A110). Choose Edit message → Copy message → Return to message → Save message. Tap Practice and reopen. Try Discard on a second run. Copy is a preview and does not touch your clipboard.
3. **Keep linked changes together:** [start at the linked entry](https://www.figma.com/proto/RVLtfmIVcO8gNk5fam0Vjd?node-id=11-114&starting-point-node-id=11%3A114). Edit and save the reflection, then edit and save the message. Tap Journal and reopen; scroll to see all content. Restart and perform the edits in the reverse order. Both changes should appear in the final sample.

No Figma editing knowledge is needed: use the buttons in the playable view. Editors contain preset replacement text, not free-text input. For each exercise, record: “On [screen], I expected [result], but saw [actual result].” Do not use Today as a persistence test; crossing between scenario branches can reset sample history.

## Overall assessment

The private reflection-to-communication direction is understandable. Direct practice, saving without AI, optional actions and typed fallback are worth preserving. The first draft illustrates the story but does not yet let someone evaluate important choices, retrieval or correction. Complete those interactions before visual refinement or an unassisted usability study.

## Prioritized findings

“First revision” items are needed to make the core prototype useful for review. “Before beta scope” items require further product decisions or secondary-state coverage. These priorities do not add new MVP features.

| ID | Priority | Observed behavior | Proposed improvement / acceptance check |
| --- | --- | --- | --- |
| F01 | First revision | [Journal](https://www.figma.com/design/RVLtfmIVcO8gNk5fam0Vjd?node-id=2-49) → Open saved moment navigates to Saved; Saved → View journal returns to Journal. Neither displays the saved content. | Create a real entry-detail wireframe. Saving opens that detail with a brief success message. Reopening from Journal shows the same original text, reflection and any explicitly linked practice/step. |
| F02 | First revision | [Reflection](https://www.figma.com/design/RVLtfmIVcO8gNk5fam0Vjd?node-id=2-44) asks “Does this fit?” but has no correction/rejection action. “Review my words” only returns to the input-review screen. | Provide “Change this” and “Leave this out” on suggested interpretations. Prototype a corrected state and verify the saved detail respects it. Keep original words separate from generated interpretation. |
| F03 | First revision | [Wording](https://www.figma.com/design/RVLtfmIVcO8gNk5fam0Vjd?node-id=2-48) displays two options but only the first can be selected. There is no edit or copy outcome. | Allow either option, a user edit, or rejection. Add a selected-message state and a simulated Copy confirmation; saving remains independent of copying. Nothing is automatically sent. |
| F04 | First revision | Both Today and Reflection route to the same prefilled [Practice](https://www.figma.com/design/RVLtfmIVcO8gNk5fam0Vjd?node-id=2-47) screen. The source of the context is unclear, and standalone practice saves into the generic reflection confirmation. | Model direct practice with an empty/sample input state and reflection-linked practice with a visible source and editable context. Preserve whether a saved practice is standalone or linked. |
| F05 | First revision | [Describe](https://www.figma.com/design/RVLtfmIVcO8gNk5fam0Vjd?node-id=2-42) and Review repeat the typed text on consecutive screens. A separate Next step screen adds another step after choosing wording. | Test inline review for typed input; retain transcript review for voice. Place an optional next-step section in the result/detail instead of making it another destination on the main route. This is a simplification hypothesis, not a validated usability finding. |
| F06 | First revision | “Keep draft and leave” returns to Today, which has no resume action. Prototype text says drafts survive, but no state demonstrates that. | Add Today-with-draft and resume; add a close choice that distinguishes keep draft, discard and continue. Users should know whether they have saved an entry or only retained a draft. |
| F07 | Before beta scope; required before testing voice | “Try recording” always goes to No microphone. There is no successful recording, stop, transcript or permission path. The AI failure shortcut appears as a normal Review button. | Add a successful voice route and loading/cancel state. Keep failures as separate study starting points or a facilitator-controlled branch. Remove “Preview unavailable AI” from product-facing actions. |
| F08 | Before beta scope | The welcome screen says users are in control but does not explain processing, storage or recovery. No Settings/data-control route exists. | Decide local versus cloud processing/storage first, then write accurate concise copy. Add export/delete previews and failure/confirmation states, including treatment of linked content. Do not invent a privacy promise to fill the screen. |
| F09 | Before beta scope | First-time Journal already contains a sample entry; navigation uses scattered buttons, while the plan proposes Today/Journal/Practice tabs. | Add an honest empty journal and use consistent navigation/back/close behavior. Keep research sample content visibly distinct from real user history. |

## Proposed simplified routes

First launch: brief purpose and accurate data explanation → Today. Show onboarding once; returning users start at Today with any resumable draft.

Typed reflection: Today → describe/edit text → reflection → saved entry detail. Keep “Save without suggestions” accessible from the text editor. Reading and editing the typed text happens in the editor rather than on a duplicate review screen.

Voice reflection: Today → record → stop → review/edit transcript → reflection → saved entry detail. Request microphone/speech access when needed. Denied/unavailable recording leads back to typed capture with existing text preserved.

Linked practice: Reflection → review selected context and intended outcome → choose/edit wording → save linked practice or copy. The context remains attributable to the source reflection. Optional next-step selection belongs with the result rather than blocking saving.

Direct practice: Today/Practice → supply situation and optional message → choose/edit wording → save standalone practice or copy. Do not create a journal reflection automatically.

Return visit: Today/Journal → saved entry detail → continue practice, edit, manage data or optionally record what happened next. Follow-up remains later priority; it must not block retrieval.

## Draft 01 review exercises (historical)

Use the existing sample so no private content is needed. These exercises expose missing choices; they are not intended to validate draft persistence or AI behavior in Figma.

1. **Understand a moment:** start at Welcome, choose Work through a moment and reach Reflection. Before each click, say what you expect next. At Reflection, consider what you would do if its interpretation was wrong. Current limitation: correction is not represented.
2. **Find usable wording:** start at Practice. Choose the tone/message you would actually use, then imagine editing it. Current limitation: only the first wording option has a selection action.
3. **Return later:** save and open Journal, then try to read the saved entry. Current limitation: this exposes F01's confirmation loop.

Record feedback as: “On [screen], I expected [action/result], but saw [actual result].” This gives a concrete revision without needing Figma terminology.

## Figma basics for this review

- The design canvas shows all screens together. A frame is one screen; a connection determines what a button opens.
- [Open the playable prototype](https://www.figma.com/proto/RVLtfmIVcO8gNk5fam0Vjd?node-id=2-40&starting-point-node-id=2%3A40) for a phone-like walkthrough. In the editor, Preview/Present are the corresponding play controls. See [Figma's play guide](https://help.figma.com/hc/en-us/articles/360040318013-Play-your-prototypes).
- Click the linked buttons. Text fields, recording and AI responses in Draft 01 are sample states, so they do not accept real input or run models.
- To leave feedback in presentation view, press C, click a location and write a comment; press Escape to return to interaction. Comments require signing in and visible prototype controls. See [Figma's comments guide](https://help.figma.com/hc/en-us/articles/360039824594-Comment-on-prototypes).
- Feedback can also be given in the project chat using the screen name. No Figma editing is required from the owner.

## Next iteration boundary

Recommended next revision: fix F01–F06 using the existing visual treatment, then add the voice and data-control states required for the selected study. Preserve Draft 01 as a reference, label changes Draft 02, and trace each changed route to a finding above. Review the proposed shorter typed path with the owner before making it the product specification.

Do not interpret completion of a clickable prototype as implementation readiness. Storage/model decisions, participant evidence and the broader release checks in the MVP definition remain open.
