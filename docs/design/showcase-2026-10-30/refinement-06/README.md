# Poster refinement 06 and motion previews

30 October 2026. The owner accepted the new artwork for the asset library and requested animated videos and poster improvements.

- [Poster PNG](CircleU-Poster-v6.png): 2560 × 1440 landscape export.
- [Editable PowerPoint](CircleU-Poster-v6.pptx): one landscape slide; headline, introduction, example labels, quotes and disclosure are editable text. Phone UI, environment and CircleU wordmark remain a raster design mockup.
- [Review gallery](index.html): poster plus three MP4 previews with playback/download controls.
- [Motion originals and provenance](../../../../Prototypes/CircleUVisualPrototype/Sources/CircleUVisualPrototype/Resources/BrandArtwork/Motion01/README.md).

## Poster changes

Preserved direction B, “Some conversations stay with you”, the original three-phone composition and separate official program lockup. Each phone now has distinct imagery: Journal desk, Today window pause and Practice cue cards. The Journal header illustration is a proposed mockup placement, not a native app change. Generated text within phone screens is illustrative and is not a substitute for final native captures.

Left copy was recomposed using the bundled Plus Jakarta Sans font registered in both available rendering libraries. Headline: 43 px; introduction: 19 px; example text: 20–21 px; labels: 16 px on the 1280 × 720 canvas. This gives the longer headline and supporting copy more room while preserving readable examples. Native PowerPoint rendering has not been checked. The font is specified, not embedded: use the [bundled font](../../../../Prototypes/CircleUVisualPrototype/Sources/CircleUVisualPrototype/Resources/BrandFonts/PlusJakartaSans.ttf) if PowerPoint substitutes it.

No App Store badge or TestFlight QR was added: the last checked invitation was not accepting testers. Program attribution remains as supplied in the previous poster; it is not a claim of endorsement.

## Editing and provenance

The live poster Page could not reconnect: the connector returned “The Page request does not belong to an active authorized task.” This revision is local; the prior cloud poster and six-slide deck are unchanged. Keep this local revision as the latest artifact until the Page is accessible again.

[Exact image-edit prompt](artwork-prompt.txt), [file hashes](provenance.json), [builder](build-poster.mjs) and [validation receipt](validation.json) are saved. Run the builder from the repository root with the bundled Node runtime and its module path; it expects a private `.build/showcase-refinement-06` directory and regenerates its draft. Final output was checked separately through the presentation finalizer.

## Validation and limits

The rendered PNG was visually inspected for copy fit, distinct phone illustrations and logo placement. PowerPoint package, declared geometry, Plus Jakarta Sans references and first-party reimport passed with no findings. The image layer is a generated composition and is not pixel-identical to its references. The 2560 × 1440 export is for screen review; it is not evidence of large-format print suitability. No app builds or device tests were required for these asset-only changes.

Natural character animation is pending the owner linking Figma to Weave. No paid video run was started. Current MP4s animate the camera over still artwork; Pingu does not blink, write or wave.
