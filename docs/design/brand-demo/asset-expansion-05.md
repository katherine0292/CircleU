# Expansion05 — richer scenes, poses and icon accents

27 October 2026. The owner requested additional artwork, richer backgrounds, more branded icons and penguin animation. This set extends the existing identity; it does not replace app assets or change navigation, typography or palette.

## Review

Open the [local gallery](../../../Prototypes/CircleUVisualPrototype/ArtReview05/index.html). During this session it is served at http://127.0.0.1:55985/ArtReview05/. Its Scenes, Motion studies and Icon sizes links jump to each group. The server is local and must be running for that URL to work; the HTML also uses portable relative resources.

The [master folder](../../../Prototypes/CircleUVisualPrototype/Sources/CircleUVisualPrototype/Resources/BrandArtwork/Expansion05/) holds seven separate PNG files. Exact prompts, references, dimensions, sizes and hashes are in the [provenance manifest](asset-expansion-05-prompts.json). All were made with the built-in image generation tool; originals were copied without pixel edits. Existing assets remain intact.

| Asset | Intended review placement | Detail |
| --- | --- | --- |
| SceneWritingNookV1 | Today hero | Pingu writing beneath an ice arch; layered mountains, water, notebooks and lantern; quieter right side |
| ScenePracticeCoveV1 | Practice entry card | Companion cove with cue card, journal and lantern; quieter left side |
| PinguGreetingV1 | Welcome or quiet empty state | Full-body greeting pose with transparent background |
| PinguConsideringV1 | Quiet optional reflection accent | Seated thoughtful pose; not a processing indicator |
| BrandConversationV1 | Labelled conversation context | Two speech bubbles; revised to dots because the initial dash resembled a minus |
| BrandDraftV1 | Labelled draft context | Rounded page and pencil |
| BrandListeningV1 | Labelled listening theme | Ear and sound arc; never indicates recording by itself |

Both scenes are 1774 × 887 px (2:1). The five transparent assets are 1254 × 1254 px. Total master size is approximately 6.6 MiB. These are raster masters, not editable vectors, a character rig or optimised app exports.

## Visual direction

The scenes add foreground/middle/distant depth and a few narrative objects while retaining the blue/ice world. Keep them above or outside the editable text area. Do not increase the hero height simply to show more scenery; assess the full scene at the existing native proportions first. Plus Jakarta Sans and source palette tokens remain unchanged. Illustration gradients are not new colour tokens.

Use the existing Journal scene alongside these candidates before deciding whether Journal needs another scene. The icons follow the existing rounded, softly dimensional illustrated accents. Back, Close, Copy, Edit and destructive controls retain their established native treatment and accessibility labels. No extra calendar-header icon is introduced.

## Motion study

The isolated HTML gallery implements a 560 ms greeting tilt and a 580 ms thoughtful tilt. Both move the entire illustration, play only on request and finish still. There is no autoplay, looping, scene parallax or movement while writing. A Still mode toggle and system reduced-motion preference prevent playback; visibility changes and a new playback request cancel existing motion. This extends the [motion guideline](../motion-guideline.md) within a review artifact only.

For a subsequent articulated wave or blink, prepare separate body, flipper and eyelid layers or a reviewed vector rig with a complete still fallback. These flat PNGs do not contain those layers. Do not compress the whole character to fake blinking. Native integration should reuse the existing motion policy, cancel when hidden/backgrounded and remain independent of saving/loading state.

## Verification and limits

- Inspected every generated image. Checked PNG integrity, dimensions, byte sizes, SHA-256 hashes and real alpha ranges. All five cutouts contain both transparent and opaque pixels. Very low-alpha residual pixels extend near some canvas edges; retained originals unchanged. The visible silhouette at alpha > 32 remains inside the canvas. Inspect/clean optical bounds when preparing app exports.
- Browser gallery displayed both scenes and the poses on ice/ink surfaces. Icons inspected at 32, 48 and 96 CSS pixels and on ink. The 32 px examples are recognisable but small because original transparent padding is preserved; 48 px is the stronger starting point for labelled artwork. Navy body edges are subdued on ink, so dark-mode placement still needs a surface treatment review.
- Browser interaction checked greeting and thoughtful playback, settled still status and Still mode disabling/re-enabling both controls. System reduced-motion and cancellation paths were source-reviewed; changing the actual OS preference and native VoiceOver were not tested.
- Gallery uses the bundled font and local resources. JavaScript syntax and resource paths checked. No SwiftUI build, app tests, Figma change, phone install, storage/backend change or production integration in this task.

Next review: select scenes/poses for specific screens, then compare them at native phone proportions before integrating. Art creation is complete for this seven-piece batch; app adoption remains separate.
