# CircleU branding guideline — demo draft 0.2

Updated 24 October 2026. The owner responded positively to [Brand demo 01](brand-demo/README.md), selecting it as the visual direction for further prototype refinement: softly shaded Pingu artwork, Plus Jakarta Sans and the demonstrated palette. Final asset specifications and production integration remain separate work.

## 1. Direction and status

The authorized [Demo 02 continuation](brand-demo/flow-previews.md) applies this direction to Journal, Practice and the reflection/message editors. It includes a softer Practice illustration, preserves original artwork and keeps editing surfaces free of mascots.

**Owner direction:** prefer Pingu-inspired illustrated artwork; modernize the logo, avatar and icons together; remove the sketchy treatment; discuss fonts and design choices. This supersedes the earlier recommendation to keep the logo unchanged or adopt outline-only brand icons. Earlier boards remain historical comparisons.

Preserve recognition, character ideas and useful existing work. Existing production assets remain intact until replacements are reviewed. Product structure remains Today / Journal / Practice; circles and rewards stay deferred.

**Proposed character:** warm, clear, composed and encouraging, suitable for university students and early-career adults. Pingu offers companionship without dominating private writing or implying that every moment needs a cheerful reaction.

## 2. Illustration approaches to discuss

| Approach | Treatment | Tradeoff |
| --- | --- | --- |
| Clean flat illustration | Smooth filled shapes, restrained palette, minimal or no outlines, no texture | Crisp at small sizes; less dimensional character |
| Soft dimensional illustration — recommended | The same clean shapes plus one restrained shadow/highlight treatment | More warmth and character; needs simplified small-size versions |

Both remove scribbles, rough edges, hatching, paper texture, wobbly strokes and unrelated emoji styles. The owner approved trying the recommended softly dimensional direction in the demo. An initially glossy avatar was refined toward a matte treatment; the retained artwork still contains gentle gradients. Final vector simplification remains a later step.

## 3. One coordinated identity

- **Logo mark:** a simplified Pingu-inspired penguin silhouette or face, recognizable in one color and at small size. Explore a circle or subtle C relationship only if it improves recognition; do not force a hidden-letter device.
- **Wordmark:** consistent public spelling `CircleU`, using the chosen typeface as a starting point. Assess spacing optically beside the mark. The final wordmark need not be identical to plain typed UI text.
- **Avatar/mascot:** treat “avatar” here as the branded Pingu character. Define one face, eye/beak shapes, body proportions and expression system. Derive a compact portrait and larger full-body illustrations from that same character.
- **Illustrated icons:** Journal/book, Practice/conversation, Today/sun and selected feeling/context motifs should share the mascot's shape language, palette and lighting. Labels remain necessary for unfamiliar meanings.
- **Functional controls:** back, close, edit, copy, microphone and delete can continue using consistent native symbols. Illustrated brand accents and functional symbols have distinct roles.
- **App icon/browser favicon:** simplified applications of the agreed logo mark, not separate identities. Test small-size recognition before final export.

The current closed-eye logo and detailed open-eye mascot are separate interpretations of Pingu. A redesign should unify them through common facial geometry, while allowing different expression and detail levels for their roles.

## 4. Typography shortlist

The descriptions below are design recommendations, not objective readability rankings. Demo 01 bundles the actual Plus Jakarta Sans variable font, registers it only within the standalone preview process, and renders the wordmark, headings and body with it. The production app and system font library are unchanged. Manrope and Nunito Sans remain unrendered alternatives.

| Candidate | Perceived character / proposed use | Tradeoff |
| --- | --- | --- |
| **Plus Jakarta Sans — first candidate** | Geometric but approachable; try for CircleU wordmark, headings and body | Distinctive shapes need checking in long paragraphs and at small sizes |
| **Manrope** | More restrained and contemporary; try if the artwork supplies most of the warmth | May feel less playful beside a very expressive mascot |
| **Nunito Sans** | Softer and familiar; try if emotional warmth is the priority | Less visual distance from the existing friendly rounded direction |

Start with one family and a small weight range: regular body, medium labels, semibold headings/buttons, bold only for emphasis. Avoid introducing separate display/body families before testing whether one works.

Proposed reading baseline: 17-point body text, comfortable line spacing, 13–14-point secondary text, and headings around 28–32 points. These are design starting points, not fixed accessibility limits. Production must respond to text-size preferences. Verify real journal paragraphs, button labels, punctuation, numerals and required language characters in actual font files. Retain native system typography as a comparison and implementation fallback.

Primary sources checked 23 October 2026:
- [Plus Jakarta Sans — designer repository](https://github.com/tokotype/PlusJakartaSans) and [Google Fonts specimen](https://fonts.google.com/specimen/Plus+Jakarta+Sans).
- [Manrope — Google Fonts source distribution](https://github.com/google/fonts/tree/main/ofl/manrope) and [specimen](https://fonts.google.com/specimen/Manrope).
- [Nunito Sans — Google Fonts source distribution](https://github.com/google/fonts/tree/main/ofl/nunitosans) and [specimen](https://fonts.google.com/specimen/Nunito+Sans).

Confirm and retain the license bundled with the exact selected font files when packaging them. Font recommendations do not establish that custom font integration or language coverage has been tested.

## 5. Color and surfaces

Use the existing blue/ice/ink identity as the comparison baseline, with a small warm beak/orange accent. Changing artwork does not automatically require changing all colors. Current source values include PinguBlue #054FC9, PinguInk #0D1421, PinguIce #F5FAFF and PinguSky #47C7FF. The earlier Draft 02 previews use a different draft palette; consolidate deliberately after selecting the brand direction.

Proposed roles: blue for primary actions/selection; ink for text; ice and neutral surfaces for reading; warm accent for limited brand details. Avoid assigning meaning only through color. Review light/dark palettes, text/control contrast and focus/disabled/error states before approval; no full contrast audit is claimed here.

Keep text-editing surfaces calm. Evaluate glass/gradient effects as supporting treatments, not mandatory decoration on every card.

## 6. Voice and usage

24 October refinement: owner requested less interface text and more icons. [Demo 05](brand-demo/lighter-icon-journeys.md) uses concise helpers, native rounded-style functional symbols, compact context tags and pencil editing affordances. Keep labels for primary actions and meaning-critical states. The earlier instruction to omit the extra decorative calendar-header icon still applies.

Use concise, supportive language with clear actions. Give people room to disagree with an interpretation and edit their own words. Avoid exaggerated praise, streak pressure, clinical claims or promises of privacy/recovery that the current app does not yet implement.

Mascot placements: welcome, empty states and occasional supportive transitions. Keep illustrations modest in busy lists and out of the main text-editing area. Expressions should fit the context; avoid celebration on error or distress states.

[Pingu activity set 01](brand-demo/pingu-activities.md) adds five action poses. Proposed motion rules are in the [motion guideline](motion-guideline.md): brief feedback/transitions, occasional finite mascot movement, still editors and reduced-motion alternatives. This is a recommendation; current app animations have not been changed or validated.

## 7. Deliverables after direction review

24 October asset expansion: [the project asset library](brand-demo/asset-library.md) now stores three additional Pingu poses and four illustrated icons, with transparent originals, exact generation prompts and a light/dark size-comparison catalog. These extend the accepted direction; individual new assets and screen placements remain candidates for review.

1. Review the first coordinated concept board showing logo mark, wordmark, avatar and three icons together, plus actual-font specimens. A second direction is optional after feedback, not an already-authorized replacement.
2. Selected artwork with a consistent grid, shape/lighting rules and a master character reference.
3. Logo: full-color and monochrome; wordmark lockups; clear-space/minimum-size examples tested against real exports.
4. Avatar: portrait and full-body versions with a small expression set; icons: individual clean assets, small-size variants and light/dark examples.
5. App icon/favicon exports and approved typography/color tokens; verify in the isolated SwiftUI prototype before production integration.

No concept board, generated lettering or raster swatch is an authoritative font/color specification. Preserve editable originals and version the approved replacements alongside the previous assets.

## 8. Open decisions

- Does the demo's softly shaded treatment strike the right balance of maturity and warmth?
- Keep Plus Jakarta Sans after reviewing the actual specimens, or compare another shortlisted family?
- Which Pingu features should remain distinctive: scarf, blue journal, beak/feet accent, face shape?
- Keep the current blue family or make a controlled palette adjustment after viewing the new character?

The demo is implemented in the isolated visual-preview package. Final production assets, font adoption, clear-space measurements and palette changes remain unapproved and unapplied. Exact swatches use source values; generated illustration pixels are not authoritative color tokens.
