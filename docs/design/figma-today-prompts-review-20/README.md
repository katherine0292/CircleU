# Today question picker — review 20

31 October 2026. Owner approved trying a small optional question sheet after accepting review 19's single-row controls. Product brief updated first. Figma only; no native/cloud implementation.

[Try Today](https://www.figma.com/proto/rfknpmLIXsOxA7fHUQQMtR/CircleU-Design--from-Claude-canvas-?node-id=74-3&starting-point-node-id=74%3A3&scaling=scale-down&content-scaling=fixed). Page `74:2` is connected review 20.

## Interaction

Tap “What stayed with you?” or its chevron. The bottom sheet offers three curated questions: What happened? / How did it make you feel? / What would you like to say next? Selecting one closes the sheet and shows that question above the writing. “Change question” reopens it. The selected question's close control removes only the prompt. The sheet's close control or dimmed area dismisses without selecting. Empty hint is “Write your words…” so it fits each question.

Three session variables keep selection separate from writing. Selected-question rows exist on all six capture states; the picker is available in empty/writing and disabled during saving. Error/listening rows retain their status text. Successful save or explicit draft discard resets selection; failed save does not. No AI generation, automatic answer, or inserted question text.

## Verification

- Player: all three choices; switching questions with a filled fixture; removal preserves words; closing the sheet; save → Journal → empty Today; selection on empty Today leaves Save disabled.
- Selected question/longest option fits the existing layout. Dismiss icon was centred and overlay corners clipped to the phone shape. [Picker](picker-player.png), [selected question with existing writing](selected-question-player.png).
- Structural: sheet uses editable frames, text and component instances, no raster UI; Plus Jakarta Sans confirmed. All three actions only set question variables and close the overlay. Save-reset actions and selected-row visibility bindings inspected.
- No native tests/build, actual arbitrary typing, device/VoiceOver or persistent-storage validation. Underlying entry/dictation remain predefined fixtures. The picker does not implement AI or replace the current native chips (T1.5).

## Artifacts

`build-picker.js` is a historical one-time mutation; `result.json` records its IDs. `polish-picker.js` creates centred close component `140:471` and rounds the full overlay. A final copy/style mutation sets all selected-question text to the existing primary blue and empty hints `125:469` / `125:503` to “Write your words…”. Do not blindly rerun these scripts.

No credit-spending operation, generation, commit or push. Prior stale-reflection and native integration gaps remain separate.
