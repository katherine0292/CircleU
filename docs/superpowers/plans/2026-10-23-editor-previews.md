# Editor preview extension

The owner requested a review of the three hub screens, static reflection-editing and practice-message previews, an Xcode retry and advice on reusing previous assets. Continue in the isolated preview package and preserve the dirty checkout. No production app or Firebase work.

## Design and evidence

- Reuse `DraftColor`, cards, action labels and fixed-size boards from the existing package.
- Message editor: verified Figma context and screenshot `27:1671`, including context, sample message, Save/Copy/Discard actions and no journal creation.
- Reflection editor: Figma context unavailable because of Starter-plan call limit. Create an explicitly labelled proposal based on the documented original-words/edited-reflection separation, with Save/Discard labels. Do not claim a verified translation of `27:1668`.
- Fixed sample text only; no keyboard, typing, save, copy or storage behavior. Do not add fake working buttons.
- Keep mascots out of text editors. Recommend reusing the clean existing `PinguMascot` asset on welcome/empty states; no wholesale return to old navigation or rewards. Some auxiliary illustrations have baked-in catalog markings/backgrounds.
- Record duplicated hub entry points and action hierarchy as review proposals; preserve current reference screens for comparison.

## Implementation and verification

- [x] Add `EditorPreview.swift` with `EditorPreviewKind`, `EditorPreviewView` and `EditorPreviewGallery`; expose existing draft cards/actions internally for reuse.
- [x] Add named Canvas previews and render outputs for two 390×844 editors and their comparison gallery.
- [x] Build the package, export and visually inspect both editor boards; fix any clipping.
- [x] Retry Xcode with the library scheme, not the package/executable scheme. Verify Canvas state and capture a screenshot.
- [x] Add the design review and update preview documentation/log; verify local links, PNG dimensions, no production changes and whitespace.

Low-impact static fixtures need compilation and visual checks; no implementation-mirroring unit tests or full-app run. No commit/push.
