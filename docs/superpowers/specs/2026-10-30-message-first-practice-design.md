# Message-first Practice

30 October 2026. Short design for review. Owner selected a preparation-led demonstration and message-first entry with optional guidance. The detailed choices below are proposals; no prototype/native implementation or live AI activation occurs in this task.

## Intent and approaches

Approval follow-up: owner approved this flow for the next prototype update. [Review 08](../../../Prototypes/CircleUVisualPrototype/PracticeFeedbackReview/README.md) implements the bounded typed-entry/guidance specimen; native voice and durable history are retained outside this browser slice. Live AI and native integration remain unapproved by prototype acceptance alone.

Help students and early-career adults find wording for a difficult upcoming conversation without filling in a questionnaire. Success is a message they understand, can correct and feel comfortable using.

| Approach discussed | Tradeoff | Decision |
| --- | --- | --- |
| Message first, optional guidance | Fast start; unclear drafts may need a follow-up question | Owner selected |
| Guided preparation before writing | Collects intent early; delays useful wording and can repeat information | Not the default; guidance remains available on demand |

Keep Today/Journal/Practice, guest access, existing native proportions, Pingu artwork, Plus Jakarta Sans and current brand tokens. This selects the showcase story, not a new default launch tab. No provider, backend, automatic learning or new artwork is required to review this flow.

## Proposed flow and concise copy

| Stage | Purpose and proposed controls |
| --- | --- |
| Prepare | Heading: What would you like to say? Editable wording and optional Record action. Secondary Help me get started and optional Context/Tone controls. When words exist, Review wording is the single filled action; manual Save remains secondary. No duplicate Continue screen just to repeat the draft. |
| Optional guidance | Heading: What do you want to happen? Ask for the intended outcome; optional situation detail. Continue carries this as intent into preparation without presenting it as a composed message. Back preserves any existing draft. No model request occurs merely by opening or completing guidance. |
| Refine | Review the existing wording, or deliberately request wording from the supplied intent. For an online request, show selected text/context and an explicit Send for feedback action first. Show up to two useful observations and one editable suggestion; keep original wording separately visible when supplied. |
| Apply | Use this wording updates the working draft; existing Undo rules apply. Copy and Save remain separate deliberate actions. Copy does not imply Save or that a message was sent. Returning without applying keeps the draft unchanged. |
| Continue later | Reopen a saved conversation, add Their reply and/or More context as separately attributed information, then write the next message or supply its intended outcome. No simulated received reply or automatic sending. |

Refine is the feedback task, not a second required form. Tone/context controls start with no additional input required. If intent is already clear in the draft, do not ask for it again by default. If only intent is supplied, distinguish it from original wording in the confirmation and result; do not invent an original quote. Exact control placement and the blank-start branch still need prototype review.

## States and boundaries

- Blank wording and no intent: offer optional guidance; do not generate or save an empty message.
- Voice: explicit recording, Stop, editable transcript and deliberate insertion; typing stays available. Existing P6 rules apply.
- Missing context: one relevant question, preserving the current first-message/reply task and entered text.
- Loading, cancellation, failure and offline: retain the draft; manual editing and saving remain possible. Suggestions have truthful source labels.
- Changes during review: invalidate stale results; never overwrite newer words. A newer request invalidates earlier Undo.
- Unsaved departure: retain existing keep/discard safeguards. Saved conversation turns retain attribution and source links.
- Online requests: existing P8 selected-payload consent, unchecked optional sharing and provider gates remain. Opening guidance is not consent. R04 outbound-payload separation stays open.
- Normal/larger text, keyboard, VoiceOver and reduced motion require review for the changed controls. Existing browser evidence does not verify this new route.

## Demonstration and validation

Use an invented group-project scenario: ask a teammate to agree on the remaining tasks. Show direct entry, a suggestion that can be edited, explicit application, save/reopen and an actual pasted reply. Demonstrate the optional blank-start branch separately so the main walkthrough stays short.

Observe a small group of target users attempting the direct and blank-start tasks without coaching. Record where they hesitate, whether suggestions preserve intent, whether they understand Use/Copy/Save, whether they can reopen the conversation, and what they think is shared. Recruitment, participant results and success thresholds remain pending. Fixed browser responses test flow comprehension, not AI usefulness.

## Traceability and next step

Requirements: M04/M09. Flows: F10/F23. Existing stories: P3–P8. New proposed entry criteria: [P9](../../product/user-stories.md#proposed-message-first-entry--m04m09--f10f23). Detailed flow review comes before an implementation plan. Reuse the existing Practice prototype for the next authorised iteration; do not rebuild Today, Journal, storage or recovery.
