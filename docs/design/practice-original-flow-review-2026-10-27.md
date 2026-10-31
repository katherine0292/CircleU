# Practice — preserve the original flow, refresh the brand

27 October 2026. Owner asked to inspect the original Practice because its flow felt better, and refine it with the accepted branding. This is a source-based comparison and proposed next design pass, not a completed native redesign or runtime certification.

## What the original actually does

`TipsView` switches between setup and a conversation-style coach. `TipsSetupView` presents the message first, scene choices (Workplace, Family, Friendship, Romantic, Custom), a tone slider, optional situation, and Continue. It also offers speech input and image attachment. The original-folder setup file and the worktree file have identical SHA-1 content hashes (`a98b8cb2f7538367cbf9795ba9cd97dee6ca3c4c`); both repositories are based on `9967a10`.

`TipsLiveCoachView` presents the original message, suggested phrasing, explanation, Copy and Try softer. Paste their reply and Add context are separate composer modes. A pasted reply adds a They replied turn and reply options; extra context refreshes phrasing. The coach does not send anything to the other person. Back returns to setup.

The current guest Practice instead offers an editable message, optional Situation/Goal, suggestions, explicit Save/Copy, history and journal source links. It has useful retention and failure handling, but lacks the original scene/tone setup and continuing conversation flow. Restoring these is more than swapping images.

## Recommended next screen sequence

| Screen | Preserve from original | Brand/content refinement |
| --- | --- | --- |
| Practice home | Access to previous work as a product goal | Keep current guest history, draft recovery and one Practice a message action |
| Prepare | Message → scene → tone → optional context | Heading What would you like to say?; existing margins; compact Pingu scene chips with labels; one Continue action |
| Refine | Original words and suggested phrasing, softer alternative | Heading Your message; editable wording; concise explanation behind disclosure; keep explicit Save and secondary Copy |
| Continue the conversation | Paste their reply versus Add context | Optional follow-up, not required to save; label the action Get suggestions, not Send; keep the person's reply separate from generated options |

Tone proposal: Soft / Balanced / Firm, using three labelled choices instead of a continuous slider for three discrete values. The original calls the middle value Diplomatic but labels the slider midpoint DIRECT; resolve that inconsistency. New labels and control are recommendations, not implemented decisions. Retain original scene coverage; Study could be a later addition if the owner chooses it. Work/Friends illustration candidates already exist; Family/Relationship need coherent art rather than arbitrary reuse.

Keep accepted Plus Jakarta Sans, blue/ice/ink, native back/copy/edit controls, restrained Pingu artwork and original 20–22-point content rhythm. Avoid moving the tab bar between setup screens. Editing surfaces stay quiet. Short screen titles have no full stop; one filled primary action. Keep current keyboard-safe actions, Dynamic Type and meaningful VoiceOver labels.

## Gaps to address rather than copy

- `CommunicationCoachEngine` is local template code. Many replies depend on scene/tone rather than the actual message; a polished UI must not imply a capable live conversation model. Rename Live coach / in real time for the review concept. New cloud AI remains outside the approved scope.
- Image attachment supplies a count or placeholder/display data to this engine; there is no image-text extraction in this path. Do not promise screenshot understanding. Keep text input useful; qualify any later OCR separately.
- Setup silently truncates message text to 240 characters. Preserve words and provide explicit validation if a limit is needed.
- `TipsPracticeStore.saveDraft` only updates in-memory properties. Session history is persisted separately in UserDefaults, with silent decode/encode failure handling and a 12-session cap. Reuse guest persistence boundaries rather than copying those behaviours into the beta.
- Setup receives recentSessions/reflectionHistory but does not render either in its body. A defined history component and resume method are not evidence of a reachable history route. Preserve the working guest history route.
- Original coach has small fixed text/actions/card widths. Keep the visual hierarchy, not every hard-coded dimension. Retain tested guest save/error/keyboard behaviour.

## Next work

First create a side-by-side branded Prepare → Refine → optional Reply prototype using invented text and the original composition. Keep the current guest implementation intact during review. Then specify the additional scene/tone/conversation state, draft preservation, explicit save semantics and tests before native integration. Existing local-only direction, optional recovery, journal links, deletion and user data remain intact. No circles, rewards, sync or signup restoration is implied.

Evidence: original and guest SwiftUI, ViewModels, models, store and engine inspected. No original-app launch, TestFlight archive inspection, native regression tests or physical-device validation performed in this review.
