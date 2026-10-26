# Pingu scene and mic art brief

Updated 26 October 2026. This brief lists the art we need for the Today options mocked in the CircleU Design canvas (rows A, B and C). No app code has changed yet. Pick the options first, then commission or generate only the art for those options.

Follow the [branding guideline](branding-guideline.md):
- Use soft dimensional illustration: clean shapes and one restrained shadow or highlight, with no sketchy lines or texture.
- Use the blue, ice and ink palette (`#054FC9`, `#F5FAFF`, `#0D1421`), with the orange beak colour as the only warm accent.
- Use the existing Pingu face and proportions (see `GuestPinguWelcome`).

## Tension to decide

The guideline says two things that pull against these options:
- Functional controls such as the microphone can stay as native symbols.
- Illustrations stay out of the main text-editing area.

A1 and A2 make the mic a brand moment, and C1 puts a scene above the writing area. Both options keep the text box itself plain. If you choose either one, update the guideline at the same time.

## Art needed

| ID | Used by | What | Size and format | Existing stand-in |
| --- | --- | --- | --- | --- |
| ART-1 | A1 | Illustrated microphone in brand style, at rest | 240×240 pt, transparent PNG @3x, plus a simplified 64 pt version | SVG placeholder in the canvas |
| ART-2 | A1 | The same mic in a "listening" pose (lit or glowing), for the recording state | as ART-1 | none |
| ART-3 | A2 | Pingu holding a microphone, calm and attentive, with a front-facing beak | 360×360 pt, transparent PNG @3x | `GuestPinguListening` (headphones, no mic) |
| ART-4 | C1 | Wide scene header: Pingu on an ice floe, calm sea, soft sky, with empty space bottom-left for the heading | 1170×900 px (390×300 pt @3x), JPEG or PNG, with the bottom 30% fading to `#F5FAFF` | `PinguHero` (legacy aurora scene, 343×512; cropped) |
| ART-5 | C2 | Morning backdrop: warm peach sky into ice blue, with a low sun and a thin ice horizon | 1170×2532 px, PNG; plus a dark-mode variant | CSS gradient placeholder |
| ART-6 | C2 | Evening backdrop: deep blue into lavender, with a moon and the same horizon | as ART-5 | CSS gradient placeholder |

Notes for every piece:
- Text-safe areas: the heading sits over ART-4 to ART-6, so keep detail away from the top-left 60% of the heading zone.
- Dark mode: ART-4 to ART-6 need a dark variant, or a rule to switch to a plain surface.
- Motion: per the [motion guideline](motion-guideline.md), any listening pulse for ART-2 or ART-3 is a finite ring animation in code, not baked-in art, and stops with Reduce Motion.
- File naming: add each piece to `Circleu/Assets.xcassets` as `GuestMic`, `GuestMicListening`, `GuestPinguMic`, `GuestSceneIceFloe`, `GuestBackdropMorning` and `GuestBackdropEvening`, and record its source prompt in `brand-demo/asset-library.md`.

## Not art (code only)

- B1, B2 and B3 (prompt chips, the "Need a nudge?" bubble, and the reflection offered after saving) need no new art. B3 reuses `GuestPinguJournal`.
- The rings in A2 are drawn in SwiftUI.
