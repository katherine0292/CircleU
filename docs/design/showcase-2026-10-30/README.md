# CircleU showcase set

30 October 2026. Owner scope: poster and presentation slides only, no video and no deadline. Reuses existing Pingu artwork and actual native/browser captures with editable presentation text. No new app features or external publishing.

**Owner review, 30 October:** the owner finds poster v3 worse than the preceding landscape poster. V3 is not the selected visual direction. Side-by-side inspection shows loss of the large foreground Pingu, integrated ice setting, angled dimensional phones and illustrated feature icons, alongside weaker screenshot selection and generic-looking typography. Use [poster 02](../brand-demo/poster-02-landscape/README.md) as the visual baseline for the next refinement. Retain v3 as review history; its completed export checks do not establish design acceptance. The owner has not separately reviewed the six-slide deck.

**Latest review set:** [Direction B](refinement-05/README.md) applies the owner-selected “Some conversations stay with you” message to the poster and opening slide. [Poster PNG](refinement-05/CircleU-Poster-Direction-B.png), [cover preview](refinement-05/presentation-cover.png). Main poster copy is now editable text; phone UI/artwork remain raster. Live poster state 4; live deck state 15. This follows [illustrated refinement 04](refinement-04/README.md), which established the six-slide visual style. Student-project wording is removed. Download QR remains deferred because TestFlight is unavailable. The earlier editable v3 poster and historical image exports remain preserved.

## Deliverables

- [Landscape poster PNG](CircleU-Showcase-Poster-v3.png): 3840 × 2160, 16:9.
- [Poster PDF](CircleU-Showcase-Poster-v3.pdf): one page, 13⅓ × 7½ inches, containing the reviewed 3840 × 2160 image. Raster print copy, not editable/vector text. No bleed or print-shop specification assumed.
- Editable poster in Spaces: `page_0f7f806806cc819194448b5bea0d6bad`, artifact `artifact_external_4e0ada67-fb42-4114-b38e-bdbbb19e015c`, saved state version 3.
- Editable presentation in Spaces: `page_c3b242e82734819183c8ac8610af9a99`, artifact `artifact_external_9c6e56ad-2b65-4e7a-993f-a6fd662f11c0`, six slides, saved state version 6.

Reconnect by Page ID if an artifact session expires. The live files own editable text and composition; local PNGs are review snapshots.

## Presentation

1. [Find your words](slide-1.png): Pingu and Practice cover.
2. [Student situation](slide-2.png): an invented group-project message, not a research quote.
3. [Brand identity](slide-3.png): Pingu poses, typography direction and colour palette.
4. [Practice interactions](slide-4.png): Prepare, Refine and Continue concepts from browser prototypes.
5. [Today and Journal](slide-5.png): native guest captures.
6. [Current status and next validation](slide-6.png): working native flows, scripted feedback prototype and pending student testing.

## Sources and boundaries

- Product/story: [brief](../../product/overview.md), [brand guideline](../branding-guideline.md).
- Original landscape reference: [poster 02](../brand-demo/poster-02-landscape/README.md), retained unchanged.
- Native images: `docs/design/core-screen-review-2026-10-27/t1-chips.png` and `u5-saved.png`, with invented content and existing capture provenance.
- Practice images: `PracticeFeedbackReview/prepare-review-08.png`, `feedback-review-07.png` and `PracticeFlowReview/reply-review-v2.png` under `Prototypes/CircleUVisualPrototype/`. Cropped to the phone region without changing its UI. These illustrate related concepts from different review iterations, not one completed native session.
- Existing AI-assisted illustrations: `BrandLogo.png`, `Expansion05/ScenePracticeCoveV1.png`, `PinguGreetingV1.png`, `PinguConsideringV1.png`, `Activities01/PinguWritingV1.png`, `PinguReadingV1.png`, `PinguPractisingV1.png`, and `Collection01/PinguBackpackV1.png` in the prototype BrandArtwork folder. No new generated artwork in this pass.
- Editable text specifies Plus Jakarta Sans. The bundled font loaded successfully in the local font library, but exact font resolution in the live rendering service is not independently established. Check typography in the intended presentation environment before final export; do not treat the render as font-embedding evidence.
- Speaker notes explain scenarios and prototype/native boundaries. No live AI, impact statistics, student findings, App Store release or award claims.

## Checks and export limitations

Inspected all six individual slides and the poster. Checked element bounds against the 1280 × 720 canvas, slide counts, editable text styles, relative links and whitespace. The poster uses native Today/Journal and scripted Practice labels visibly. Verified PNG dimensions, PDF page count/dimensions and rendered the PDF for visual inspection.

Session PNG rendering succeeded. Direct session PDF export failed with an ArrayBuffer error; the printable copy therefore wraps the checked high-resolution PNG using ReportLab. An oversized snapshot-export attempt was aborted before commit; both live documents were subsequently confirmed intact. No PowerPoint, physical print, app build or device tests were performed for this artifact-only work.
