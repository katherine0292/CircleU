# Refine and communication-style story review

29 October 2026. Reviewed the running PracticeFeedbackReview 05 browser specimen and its source against M09/M10, F23/F24 and P7/P8/S9. Working tree on `codex/app-upgrade-plan`, base `9967a10`. No app/prototype code changes, new provider, or native verification.

## Keep

- Original wording and editable rewrite remain distinct, with two short feedback points and explicit Use. Browser Use inserted the rewrite without automatically saving.
- Current compact body text, restrained Pingu artwork, blue action and clear original-wording panel are suitable to retain. This is a visual judgement at the observed browser viewport, not a contrast or native accessibility pass.
- Optional style and per-request inclusion are separate. The prototype starts with style off; earlier recorded checked-sharing behaviour remains inherited evidence, not a fresh rerun here.

## Findings and acceptance

| Priority / ID | Evidence | Required refinement / retest |
| --- | --- | --- |
| High — R01 · P7.8 / F23 | Browser: first-message Review → Needs more context → Add context opens “What happened next?” with a prefilled Their reply and “Draft a reply”. Source: `feedback.js` routes clarification to `openReply()` unconditionally. | Keep first-message clarification in review mode. Collect the missing intent/context, preserve the original draft and re-preview selected text before retry. Test first-message and reply clarification separately. The brief was clarified before adding P7.8. |
| Medium — R02 · P7.2 / F23 | Browser: Use a rewrite → start another review → result → Close leaves Undo visible; tapping it restores the wording from before the first rewrite. `invalidate()` cancels timers but does not clear `prior`. | Match the proposed rule that a newer request invalidates prior Undo, while preserving current wording. Test new request success, cancellation and failure; manual-edit invalidation already exists. This is a mismatch with the new acceptance rule, not proof of lost saved data. |
| Medium — R03 · S9.1–S9.3 / F24 | Browser: leave Use these preferences unchecked, change Wording to Formal, Save → Settings displays both “Preferences saved” and “Not in use”. The fields remain editable while off. | Clarify saved-but-off versus active preferences. Keep optionality and separate per-request consent. Suggested concise status: “Saved · not in use”; verify the user can enable, disable, clear and decide whether to share without confusing those actions. This is a usability recommendation, not a broken persistence claim. |
| Before integration — R04 · P8.2 / F23 | Source inspection: `submit()` mixes local revision-comparison fields (`original`, `intent`, unconditional `reply`) with checkbox-selected `prepared` / `received` in one `snapshot`. There is no network call. | Define an explicit allowlisted outbound payload separately from local revision metadata before adding transport. Test unchecked context/style exclusion. Do not serialize the whole snapshot. No data leak was observed or alleged in this fixture. |

## Deliberate prototype limits

Fixed output can still mention “Never” after that word has been removed: the outer prototype notice discloses fixed responses. It is not real model feedback and cannot validate semantic quality. Do not port fixtures as a real suggestion engine.

There is no durable style storage, completed export/delete integration, true provider payload, complete saved-conversation browser or native accessibility qualification here. S9.2/S9.5/S9.6 remain proposed; these omissions are not newly discovered production bugs. Today/Journal companion specimens still must not replace native capture/calendar functionality.

## Verification performed

- Fresh browser walkthrough: editor → selected-text confirmation → loading → feedback → Use; a second request → Close → Undo; first-message clarification → Add context; disabled-style change → Save.
- Visually inspected the result at the existing browser viewport. Clarification route captured in [evidence](refine-story-review-2026-10-29/clarification-route.png).
- Read `feedback.js`, `style-profile.js`, relevant HTML/CSS and the prior prototype evidence. No JavaScript mutation via browser evaluation, real uploads, account actions or generated user data.
- Not checked this turn: full error/offline matrix, reload persistence, largest-text layout, screen-reader speech, keyboard on iPhone, network transport or model quality. Existing dated evidence is not a new pass.

## Next bounded slice

Resolve R01/R02 and clarify R03 in the browser prototype, then rerun the listed cases against P7/S9. R04 is a mandatory transport design/test boundary before any online implementation. Keep the current visual composition; move to Today/Journal after these review gaps are resolved. No whole-flow completion or implementation approval is inferred from this review.


## Resolution — browser review 06

Owner requested implementation of the reviewed refinements. R01–R03 are now fixed in the browser specimen; the original findings above remain as the reproduction record. No native SwiftUI/provider behaviour changed.

- **R01:** Add context preserves review/reply mode, shows the original wording or existing intent and accepts separate task-specific context. Empty text is validated; retry displays the exact additional context before an explicit Send. Back from confirmation returns to the context editor. Browser checks passed for both original-message and reply routes, including unchecked context sharing and separation of the two context drafts.
- **R02:** Starting a request clears prior Undo without changing current wording. Fresh browser checks passed after a new successful response, cancellation and service failure. Use of a new result can still create a new Undo.
- **R03:** Save while disabled now says Saved · not in use; enabling says Preferences enabled; clearing restores Not in use. Browser checks passed for all three, per-request style sharing still starting unchecked, and original wording remaining unchanged.
- **R04 remains open before transport:** local comparison metadata and selected outbound fields must be separated before an actual provider request. No transport was added in this pass.

Evidence: [updated clarification](../../Prototypes/CircleUVisualPrototype/PracticeFeedbackReview/clarification-review-06.png). Standard and larger-text browser layouts inspected; larger-text Review again reached confirmation. The first reply-attribution assertion used a role-button locator that did not match the HTML summary despite its AX button representation; inspection and a corrected visible-text assertion passed. This was a test-locator mismatch, not an app regression.

JavaScript syntax, resource/link targets and whitespace checked. No full native unit/UI suite, iPhone keyboard/VoiceOver or real-provider evaluation was run: this is a disposable browser prototype. Native P7/P8/S9 criteria remain proposed, not complete.


## Visual pass — review 07 direction

Owner requested UI improvements after the functional fixes. Scope: browser Practice editor, clarification, feedback and optional style presentation. Reuse accepted Pingu art, Plus Jakarta Sans, blue/ice tokens and the existing phone proportions. Keep interactions and copy boundaries from review 06.

Chosen implementation direction within the established branding: shallow illustrated editor header; quiet source cards; a larger usable writing surface instead of vacant space; consistent rounded outline controls and tab icons; aligned margins and clearer focus states. Keep default body text modest and let larger-text review scale; hide decorative art at larger sizes. The main action/footer stays anchored. No new screens, provider, fonts, native implementation or generated art.

Alternative full-screen artwork is unsuitable behind editable text; a typography-only change would leave the empty-space and control-consistency issues. This is a reversible visual prototype iteration for owner review. Verify existing review/clarification/style routes after markup changes, standard/larger text and screenshots before claiming completion.

Implemented and inspected in browser review 07. [Editor, result and larger-text context evidence](../../Prototypes/CircleUVisualPrototype/PracticeFeedbackReview/README.md). Edited Use/Undo, context validation/preview/Back, larger-text actions, saved-off style and destination tabs worked after markup changes. The editor's artwork and bundled font loaded and its phone had no horizontal overflow. Browser auto-scrolling located the lower controls; physical swipes/keyboard/VoiceOver remain untested. Review 06 JavaScript and the existing brand resources are unchanged. No native implementation or live AI was added.
