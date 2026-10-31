# Illustrated showcase refinement 04

30 October 2026. Owner approved finishing the poster and presentation while TestFlight is unavailable. No video, new application features, external posting or release upload.

**Latest review update:** owner requested removing visible “Student project” wording. [Poster v4b](CircleU-Showcase-Poster-v4b.png) removes that label; the live poster is state 3. Presentation cover now says “UTS UI showcase,” and closing says “CircleU · In development”; live deck state 14. Earlier previews below retain the pre-edit state. Typography, copy direction and more varied screen artwork are being discussed, not yet redesigned. Main poster lettering remains baked into the image; an editable text-layer rebuild is recommended before further font-size work. Existing alternative scenes include daytime listening and twilight Journal reading; current writing-nook and practice-cove art remain visually similar.

## Review files

- [Landscape poster](CircleU-Showcase-Poster-v4.png), 2560 × 1440 PNG. Retains the earlier dimensional phones, arctic scene, large Pingu and before/after conversation example. Adds the original UTS / Apple Foundation Program artwork with “Student project.” No download badge or QR.
- [Six-slide overview](presentation-montage.png) and individual [1](slide-1.png), [2](slide-2.png), [3](slide-3.png), [4](slide-4.png), [5](slide-5.png), [6](slide-6.png).
- Live presentation: Page `page_c3b242e82734819183c8ac8610af9a99`, saved state 13. Text, artwork and screenshot placement remain editable.
- Separate poster document: Page `page_1a13d69444348191b37bf5447364091f`, saved state 2. Main poster is a raster image; the program lockup and attribution are separate objects. The earlier editable poster Page remains unchanged, state 3.

## Presentation story

1. **Find your words** — large Pingu, concise purpose and student-project attribution.
2. **A difficult group conversation** — invented original message and a possible rewrite; not research findings or a real model result.
3. **Meet Pingu** — existing writing, reading and practising poses, typography direction and palette.
4. **Practice a difficult conversation** — Prepare / Refine / Continue from existing browser review captures; visibly labelled scripted prototypes.
5. **Keep a moment in your own words** — native Today and Journal captures with invented content.
6. **Would you say it this way?** — current native capability, prototype boundary and invitation to review wording with students.

Sources and prototype/native distinctions are recorded in each slide's speaker notes. No live AI, measured student outcomes, awards or public release claim.

## Artwork and provenance

- [Arctic background](assets/arctic-background.png): built-in imagegen edit derived from Story V3; [exact prompt](assets/background-prompt.txt). Saved unchanged from generated output. Reused as a background across the deck.
- [Original program artwork](assets/uts-apple-foundation-program-original.png): downloaded unchanged from the official [UTS Apple Foundation Program page](https://www.uts.edu.au/for-students/experience-uts/career-planning/uts-innovation-hub-for-apple-technologies/apple-foundation-program). Source image URL: https://www.uts.edu.au/AdaptiveImages/optimizely/f6c7b428-4266-48e4-826d-ce9be7bdb9dc/feit-tile-apple-foundation-7-880px.png?cropbottom=626&croptop=131&stamp=89f810e36cee4aa5206b11c3ad3282abb6eae31f . Native placement crops only surrounding white space; marks are not redrawn. Attribution denotes student-program context, not endorsement. No independent institutional publication approval is claimed.
- Poster base: [Story V3](../../brand-demo/poster-02-landscape/CircleU-LinkedIn-StoryV3-draft.png), built-in imagegen; [base prompt](../../brand-demo/poster-02-landscape/story-v3-prompt.txt).
- Existing Pingu assets, native captures and browser screenshots are unchanged; paths are in the parent showcase README and [bounded edit callback](refine-deck.mjs).
- [Hashes and checks](provenance.json).

## Checks and limits

Visually inspected all six rendered slides individually, the montage and poster. No off-canvas elements in the six layout exports. Verified six slides, one poster, saved state versions and PNG dimensions. The poster's 2560 × 1440 export enlarges the 1672 × 941 base; it is suitable for screen review, not a claim of new illustration detail or large-format print readiness. No PDF or PPTX exported in this pass; live deck is the editable deliverable.

Slide text specifies Plus Jakarta Sans. Exact font resolution in the live renderer remains unverified; main poster lettering is raster and only approximates that font. Review in the intended presentation environment before final submission. Browser feedback screens come from different review iterations, not one continuous implemented session.

The original TestFlight invitation exists but is not accepting new testers, and the old build is expired. Download CTA remains deferred. Artwork completion is not release readiness.

## Tool recovery

Automatic review rejected replacing all objects in the earlier cloud poster with a flattened image. The original was verified unchanged, and this version was created as a separate document. Large deck-save calls timed out; a later state check showed the cover had committed despite a timeout. Remaining edits were saved in small batches without duplicating the cover. No local PowerPoint fallback was needed.
