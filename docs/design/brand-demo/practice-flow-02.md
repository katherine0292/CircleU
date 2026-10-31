# Practice continuation and voice — review 02

27 October 2026. Owner approved extending the branded prototype with pasted replies, extra context and voice input. Implementation is confined to the existing browser specimen. The microphone remains off; no inference, native code, data model or cloud settings changed.

Open http://127.0.0.1:55988/PracticeFlowReview/ and choose Try the flow. From Refine, choose Continue the conversation. Compare screens also exposes the third screen directly. The earlier [two-screen review](practice-flow-01.md) and review.png remain historical evidence.

[Reply screen capture](../../../Prototypes/CircleUVisualPrototype/PracticeFlowReview/reply-review-v2.png) · [Voice transcript review](../../../Prototypes/CircleUVisualPrototype/PracticeFlowReview/voice-review-v2.png)

## Reply and context

- Separate Their reply / More context drafts survive switching tabs and Back. The person's pasted text is never presented as a generated reply.
- Get reply options and Update wording show a short pending state. Request revisions discard pending results after input changes, mode changes, leaving the reply screen or wording changes.
- Suggestions are explicitly guided prompts. Reply options offer generic clarification and boundary wording; context options retain existing wording or add a generic invitation. These fixtures do not interpret the context or infer the other person's feelings.
- Use wording returns to editable Refine. It does not save, copy or send. Undo restores the previous wording. Existing Save remains temporary browser state only.
- The review's Suggestions selector can simulate failure. Inputs remain intact; the action can be retried. Empty input disables generation.

## Voice recommendation and preview

Use voice-to-text for the person's message/context, with optional dictation of a reply they already received. Do not turn this into background recording of a conversation. Proposed native sequence: request required access when tapped → record → stop → review/edit transcript → insert text. Keep typing available throughout. Prefer reusing the existing guest on-device dictation boundary; this prototype does not wire it into Practice.

Microphone controls on Prepare/message, Prepare/context and the continuation field open a labelled VOICE PREVIEW · MICROPHONE OFF dialog. Start preview → Listening preview → Stop → Check your words → Use text. The transcript is an invented fixture; Use text appends it after existing text. Cancel/Keep typing discards only the unaccepted transcript.

Voice scenario controls outside the phone expose Ready, Permission denied, Unavailable and Interrupted. Denied/unavailable retain typing; interrupted exposes a partial fixture for review. No getUserMedia, browser speech recognition, MediaRecorder, audio files, live permissions or network calls are used. This is a design for voice input, not functioning recording.

The same Plus Jakarta Sans, blue/ice/ink tokens and existing Pingu Listening/Friends artwork are reused. No additional image generation was necessary. Functional microphone controls are labelled SVG controls with 44-pixel targets; the character artwork remains raster PNG.

## Which AI is in the code now?

| Path | Source evidence | What it establishes |
| --- | --- | --- |
| Browser Practice review | `PracticeFlowReview/prototype.js`, `reply.js` | Scripted wording; no AI model |
| Native guest suggestions | `Circleu/Services/GuestJournal/GuestSuggestionEngine.swift`, `GuestRootView.swift` | `LocalFirstSuggestionEngine` tries Apple's default Foundation Models model on supported/available iOS 26+ configurations; falls back to guided prompts. Debug can force guided-only. No explicit model weights/version identifier is selected by the code. Runtime availability was not checked this turn |
| Original Practice | `Circleu/Features/Tips/TipsPracticeViewModel.swift`, `Circleu/Engines/CommunicationCoachEngine.swift` | Local template coach, not a remote LLM |
| Legacy reflection cloud fallback | `Circleu/Services/CloudReflectionEngine.swift`, `Circleu/Engines/ReflectionEngine.swift` | Hard-coded `gemini-1.5-flash` URL behind consent/enabled/API-key checks, with local fallback on failure. Source presence is not proof of active service, current provider availability, credentials, or a successful request. Guest suggestion code does not call this path |
| Guest dictation | `Circleu/Services/GuestJournal/GuestDictationEngine.swift` | Apple's Speech framework; requires on-device recognition, passes audio buffers to recogniser and does not write audio files in this service. This does not certify every original-app speech/cloud path |

No new cloud provider or sync decision is made here. Firebase is the legacy backend service, not the name of the wording model. Live model selection and complete Release networking remain separate verification tasks.

## Verification and limits

Browser checks and screenshot evidence are recorded in the dated agent log. Source syntax, local resource links and whitespace were checked. No Xcode, Simulator, device microphone, actual speech accuracy, live model or native VoiceOver verification performed. Browser enlarged-text checks are not iOS Dynamic Type certification. Native transcription failures, cancellation/race handling, draft retention and data boundaries need integration tests when this design is implemented.
