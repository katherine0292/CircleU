# Guest journal asset audit

25 October 2026. Owner request: the guest journal didn't use the illustrated icons from the [asset library](brand-demo/asset-library.md), and it showed only Today and Journal. This lists the brand assets in the repo and where each is used after this change. The scope is the guest journal only, behind the hidden switch; the existing app is unchanged.

## In the guest journal (app target)

| Asset | Source | Where it's used | Accessibility |
| --- | --- | --- | --- |
| `GuestIconToday` | `BrandToday.png` | Today tab | Decorative; the tab's text names it |
| `GuestIconJournal` | `BrandJournal.png` | Journal tab, Today's "Continue your draft" button | Decorative; the label names it |
| `GuestIconPractice` | `BrandPracticeV2.png` (the version the prototype flow uses) | Practice tab | Decorative; the tab's text names it |
| `GuestBrandAvatar` | `BrandAvatar.png` (identical file) | Today hero | Hidden |
| `GuestPinguWriting` | `Activities01/PinguWritingV1.png` | Journal, when nothing is saved yet | Hidden |
| `GuestPinguPractising` | `Activities01/PinguPractisingV1.png` | Practice placeholder ("Practice is coming soon") | Hidden |
| Plus Jakarta Sans | `Resources/GuestBrandFonts` (OFL licence bundled) | All guest text | Scales with Dynamic Type |

The originals are 1254 × 1254 transparent PNGs, about 0.5–0.9 MB each. The app gets downscaled copies:
- tab icons at 28 pt, as @2x and @3x files, rendered in their original colours;
- illustrations at 600 px.

That adds about 0.5 MB in total. The originals stay in `Prototypes/CircleUVisualPrototype/.../BrandArtwork` as the masters.

Following the asset library's usage rules, the microphone, back, Edit and stop controls stay native SF Symbols. Illustrations appear only on welcome, empty and placeholder surfaces; the writing area stays calm.

## Not used in the guest journal yet

- **Prototype only:** `BrandLogo`, `BrandPractice` (v1), the Expansion 01 icons (Reflection, Feelings, Next step, Privacy), and the Pingu Welcome, Listening and Thoughtful poses. Also unused are the other Activities 01 poses (Reading, Stretching, Quiet breath) and the 12 Collection 01 poses.
  - The Privacy icon needs accurate text beside it before use.
  - Listening must not suggest that recording is active, so it isn't shown while dictating.
- **Legacy app assets (`Assets.xcassets`, unchanged):**
  - Named in code via `PinguGlassKit` and `PinguComponents`, or Tips: `PinguMascot`, `PinguCalm`, `PinguExplorer`, `PinguReading`, `PinguThumbsUp`, `PinguWatering`, `PinguLevel1–4` and `PinguLevelUp`.
  - Not referenced by a literal name: `PinguHero`, `PinguCelebrating`, `PinguThinking`, `PinguWaves` and `PinguWaving`. They may still be built from a name elsewhere, so they're kept.
- **App icon:** unchanged.

## Not checked

- Dark mode: the guest journal is light-only for now.
- Small-size legibility on a physical phone: Mike's install check covers this.
