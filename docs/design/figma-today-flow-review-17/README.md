# Today flow review 17

31 October 2026. Figma prototype repair and verification, following [Journal review 16](../figma-journal-flow-review-16/README.md). No native implementation or live AI.

[Start Today](https://www.figma.com/proto/rfknpmLIXsOxA7fHUQQMtR/CircleU-Design--from-Claude-canvas-?node-id=74-3&starting-point-node-id=74%3A3&scaling=scale-down&content-scaling=fixed). Current page `74:2`: **CircleU • connected review 17**.

## What changed

- Restored the missing Today logo and journal Pingu images using existing Codex assets: `BrandLogo.png` and `Activities01/PinguReadingV1.png`. Replaced the corresponding missing references across this connected page. Original source assets are unchanged.
- Journal now shows **Continue your draft** while a Today draft exists. The close control opens draft management, where keeping or discarding is explicit.
- Cancelling dictation returns to existing typed words. Stopping dictation, or leaving its fixture through a tab, retains the spoken-word fixture as a draft.
- The brief simulated save disables conflicting navigation until success. A directly opened save-error fixture retains its draft for retry.
- Reflection begins empty. Save is disabled until the writing area is tapped. The populated fixture supports a predefined revision and clearing the field.
- Added reflection saving, failure/retry and discard-confirmation states. Written reflection text is protected on Back, Not now and tab exits.
- A saved reflection appears separately below the original words on the canonical entry, stays there when reopened, and has its own edit control. Discarding a later edit leaves the saved reflection unchanged.

No Figma AI generation or Weave operation was needed. No claim of a refreshed credit balance.

## Try it

1. Tap a Today prompt or writing area. Switch to Journal, then tap **Continue your draft**. Its close control opens keep/discard choices.
2. From filled Today, tap the microphone and **Cancel dictation**. The typed words remain. Tap **Save** to reach Journal; returning to Today shows an empty capture form.
3. After saving, tap **Reflect**. Save is disabled while blank. Tap the field to populate the invented answer; tap it again to show a predefined revision.
4. Tap another tab to see discard confirmation. **Keep editing** returns to the reflection; **Save reflection** saves it separately from the original words.
5. Return to Journal and reopen the entry. The reflection remains. Use its pencil to edit; clearing and discarding edits must not erase the saved version.

Failure entry points:

- [Today save failure](https://www.figma.com/proto/rfknpmLIXsOxA7fHUQQMtR/CircleU-Design--from-Claude-canvas-?node-id=74-119&starting-point-node-id=74%3A119&scaling=scale-down&content-scaling=fixed)
- [Reflection save failure](https://www.figma.com/proto/rfknpmLIXsOxA7fHUQQMtR/CircleU-Design--from-Claude-canvas-?node-id=113-648&starting-point-node-id=113%3A648&scaling=scale-down&content-scaling=fixed)
- [Microphone unavailable](https://www.figma.com/proto/rfknpmLIXsOxA7fHUQQMtR/CircleU-Design--from-Claude-canvas-?node-id=74-150&starting-point-node-id=74%3A150&scaling=scale-down&content-scaling=fixed)

## Evidence and limits

Player checks performed: draft card and management; keep draft and resume; typed draft retained after cancelling dictation; capture saving and retry success; cleared Today after save; reflection empty Save disabled; writing/revision; tab exit confirmation and Keep editing; saving; reopening; editing and discarding without changing the saved reflection.

Final checks: reflection failure → Try again → saved entry passed ([evidence](reflection-retry.jpg)); microphone-unavailable → typing passed; Discard draft → Journal → Today returned to an empty form. The unavailable-microphone screen is a standalone fixture: its permission state is not carried across subsequent generic capture frames.

Structural audit: 129 screen/state frames; no missing navigation destinations; no checked tab-position mismatches (y764, height60); inspected Today/reflection text uses Plus Jakarta Sans. Editable text, frames and component instances remain; full-screen screenshots were not imported as UI.

Screenshots: [Today](today.png), [draft](draft.jpg), [capture failure](save-error.jpg), [reflection failure](reflection-error.jpg), [reopened reflection](reflection-reopened.jpg).

This is a bounded single-entry scenario: taps insert predefined writing; voice, saving and failures are simulated; variables last for the Figma session only. It does not establish real keyboard input, dictation, persistence, arbitrary multiple-entry creation, model output, stale-source conflict handling or accessibility. The writing nudge is illustrative, not a complete prompt interaction. No Xcode build, unit/UI suite or physical-device check this turn. Native behavior and previous test evidence are unchanged.

Implementation records: [repair script](repair-today.js), [applied IDs](result.json), [final adjustments](finish-today.js). These are one-time mutations, not idempotent utilities; do not rerun blindly.

Next: owner reviews the Today → Journal → reflection journey; then run the connected Practice journey before selecting final showcase screenshots. Native integration is separately scoped.
