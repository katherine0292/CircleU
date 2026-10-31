# Practice feedback review 08

30 October: approved message-first entry, with optional Help me get started. Initial load is blank; Reset example loads invented wording, and Start blank clears the specimen. Review wording is the primary action. Context/tone are collapsed and optional; manual Save and Copy remain separate secondary actions. Copy uses the browser clipboard and reports success only after it resolves; Save remains memory-only.

Guidance collects an intended outcome and optional context, then returns to the same editor without generation. Intent stays separately labelled and can be edited or cleared. With no draft, Suggest wording previews Your intent and returns an editable fixed example; it never invents original words. With a draft, confirmation shows wording and the separately supplied intent. Back preserves the existing wording. Use/Undo refresh the blank/nonblank action states.

Current evidence: [Prepare](prepare-review-08.png) · [Guidance](guidance-review-08.png) · [Selected intent](intent-preview-review-08.png) · [Larger-text guidance](guidance-large-review-08.png).

Fresh browser checks passed for blank disabled actions, empty guidance validation, guidance Continue without generation, typed-draft preservation on Back/Continue, intent-only attribution, exact selected context/tone, Use/Undo to an empty draft, separate Copy/Save statuses, new-request cancellation and service failure preserving wording, reply-intent validation and reply clarification. Larger-text guidance/Continue and intent actions were exercised. An independent static review found that Edit/Clear intent stayed 12px at larger text; reproduced in the browser, corrected to 20px and verified both controls. No other concrete regression was reported in that scoped review. One optional-summary text locator failed because its visible label includes Optional; the corrected summary locator passed.

Browser-only scope: no microphone flow added, durable conversation browser, native integration, live provider or participant evaluation. Existing native voice/history are preserved elsewhere. Fixed outputs do not react semantically to arbitrary writing. No production test suite was run. Review 07 and earlier evidence below is historical.

The selected-text/local-metadata separation remains a gate before any real network transport (R04); nothing is uploaded by this specimen.

29 October visual pass: an existing Pingu cove scene introduces the editor; original words, feedback and editable wording have distinct quiet cards. Rounded outline controls and labelled tab icons share a consistent stroke. The 390 × 844 phone, Plus Jakarta Sans, existing brand palette and anchored action footer remain. Default writing text is 17px; the larger-text control enlarges content and hides decorative header artwork.

Current images: [Editor](editor-review-07.png) · [Feedback](feedback-review-07.png) · [Larger-text clarification](clarification-large-review-07.png).

Fresh browser checks: edited rewrite → Use → exact Undo; empty-context validation; context preview and Back; larger-text clarification → confirmation; larger-text editor → reply and Back; saved-but-off style status; Today/Journal/Practice tabs. Standard editor/result and larger-text editor/clarification/style layouts were visually inspected. Artwork loaded, the bundled font resolved and the editor phone had no horizontal overflow. Browser locators automatically scrolled controls into view; this is not an iPhone swipe/keyboard/VoiceOver test. JavaScript was unchanged in this visual pass. Earlier review evidence follows.

29 October fix pass: clarification now preserves first-message versus reply intent, with editable context and a fresh sharing confirmation. New requests clear prior Undo; cancellation/failure retain wording. Style status distinguishes saved-but-off, enabled and cleared. [Clarification screen](clarification-review-06.png).

Fresh browser checks passed: empty-context validation; original-message and reply clarification; exact context preview; Back to context editing; separate clarification per task; unchecked reply/prepared/style sharing; Undo invalidation after new success/cancellation/error; saved-off/enabled/cleared preferences; unchanged original wording. Larger-text clarification and its primary action were exercised in the browser. One role-based assertion could not locate a summary element; the AX tree showed the intended text and the corrected text locator passed. No native/device/provider test is claimed. Review-05 evidence below is historical. See the [review follow-up](../../../docs/design/refine-story-review-2026-10-29.md#resolution--browser-review-06).

29 October update: optional My communication style setup and connected Today / Journal / Settings specimens. [Style setup](style-review-05.png) · [Today](today-review-05.png) · [Journal](journal-review-05.png). Use the Screen selector outside the phone or the destination tabs to explore. These companion specimens explain navigation and data boundaries; they do not replace the existing native Today or calendar-based Journal design.

## Communication style

Settings → My communication style offers optional English variety, Conversational/Formal wording and Brief/Balanced length. Save retains preferences only in this page's memory; reload clears them. Back discards unsaved preference edits. Clear preferences removes this profile without changing words or conversations. No demographic fields, inferred traits, automatic history learning or retained voice recordings are introduced.

When enabled, Practice shows the preference summary. Each review confirmation starts with Use my communication style unchecked. Checking it reveals the exact preferences; the request fixture snapshots them. Formal and brief selections can choose different canned text, labelled My style in the result. English variety is carried in the inspected selection but has no distinct spelling example in this fixture. Tone remains the conversation-specific choice. This is not real adaptive generation, training, durable preference storage or a provider integration.

Today offers routes to Practice and Journal. Journal shows the unchanged invented original and a detail route into Practice. It does not rewrite, rank or infer mood from the entry. The specimen's Practise these words starts the fixed project example; it is not a production source-link/storage implementation. Calendar, capture and editing remain in the existing app/prototype work and are not rebuilt here.

Verified in the browser: optional setup starts off; Formal save reaches Practice; sharing starts unchecked; checking reveals exact style values; formal fixture changes and source label appears; applying it does not alter the Journal example; Clear shows Not in use. Final setup, Today and Journal were visually inspected and captured. Scripts parse and local resources resolve. Real provider quality, native persistence, accessibility and device flows remain untested in this pass. Future Sounds like me feedback and approved writing examples remain proposed, not implemented.

28 October update: focus on Refine function and UI. Suggested wording uses 17px body text and is directly editable; original text is expanded above it. Soft/Balanced/Firm choices in the editor select distinct fixed wording examples and appear in confirmation/results. Blank wording cannot be saved/applied; manual edits clear the previous suggestion Undo so it cannot overwrite newer text. [Current screenshot](refine-review-04.png). Earlier screenshots below remain historical review 03 evidence.

Disposable browser design specimen, 27 October 2026. The owner accepted previewing the proposed feedback experience with existing Pingu branding and invented examples. This is not native SwiftUI implementation or cloud activation.

Open [the local review](http://127.0.0.1:55988/PracticeFeedbackReview/). If the existing prototype server is stopped, serve `Prototypes/CircleUVisualPrototype` with `python3 -m http.server 55988 --bind 127.0.0.1`.

## What to try

- Type wording (or Reset example) → optionally expand Context and tone → Review wording → inspect selected text → Send for feedback → edit Your next wording → Use this wording → Undo, Copy or Save.
- Start blank → Help me get started → enter an outcome → Continue → Suggest wording; inspect Your intent before continuing. Clear intent returns to a blank start without inventing a message.
- Select Declining another task outside the phone, then Add their reply. Clear the intent to check validation; add it back to Draft a reply.
- Prepared wording and Their reply begin unchecked in the sharing preview. Selecting them reveals exactly that context.
- The external response selector exposes feedback, clarification, service error and offline states. Larger text enlarges the phone UI and leaves the action footer separate from scrolling content.

The result is a fixed fixture for the selected example, even after editing inputs. Nothing calls a model, uploads text, records audio or accesses an account. Save sets temporary in-memory state, lost on reload/reset; there is no saved-conversation browser. The Online suggestion badge illustrates a proposed future source, qualified by the persistent prototype notice outside the phone. No actual provider has been selected. Runtime provider choice, genuine context-sensitive inference, native sheets, device keyboard and durable history are outside this specimen.

The separate entry page and scripts preserve the previous PracticeFlowReview unchanged. Fonts, tokens and Pingu PNGs reuse existing resources; no new artwork generated. Loading motion has a Reduce Motion CSS override. This prototype is design evidence, not code to copy directly into production.

## Evidence

- [Feedback screen](feedback-review.png)
- [Reply feedback review](reply-feedback-review.png)
- [Larger text](larger-text-review.png)
- [Detailed AI design](../../../docs/superpowers/specs/2026-10-27-practice-ai-feedback-design.md)

Browser checks observed confirmation, loading, applying a rewrite, exact Undo, edited suggestion insertion, temporary Save confirmation, missing-intent validation, unchecked context defaults, revealed context text, service-error draft retention, offline and clarification states, and cancellation returning to the editor. Enlarged consent content scrolled; enlarged result and pinned action were visually inspected. No native accessibility or physical-device claim. Background cancellation and every late-result timing permutation were not separately exercised.

`node --check feedback.js`, local HTML resource checks and whitespace checks passed. Screenshot evidence came from the in-app browser. The existing local server was reused; a sandboxed startup attempt failed and an elevated attempt reported the port already occupied, after which the browser confirmed the existing server served the new folder.
