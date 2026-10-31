# Accepted artwork, poster refinement and motion studies

- Recorded: 2026-10-30 23:49:34 +11:00; Australia/Sydney
- Agent / role: Codex / showcase artwork
- Status: poster and camera-motion previews complete; natural character animation needs account linking
- Base revision and branch: 9967a10, codex/app-upgrade-plan; work uncommitted, unrelated changes preserved
- Related: [Screen scenes 07](2026-10-30-212100-codex-screen-scenes-07.md), [poster direction B](2026-10-30-205835-codex-showcase-direction-b.md)

## Request and scope

Owner accepted the artwork, asked to save it in assets, requested animated videos and poster improvement. Existing PNG masters were already stored in BrandArtwork; verified their hashes and recorded acceptance without changing the pixels. App integration was not requested.

## Work and outcome

- Nine scene originals retained in ScreenScenes06/07 with prompts and hashes. Approval is for the library, not native placements.
- [Poster refinement 06](../design/showcase-2026-10-30/refinement-06/README.md) changes the three phone mockups to distinct scene illustrations and recomposes the approved direction-B text. Delivered a 2560 × 1440 PNG and one-slide PowerPoint with seven editable text boxes plus separate institutional logo. Phone UI/background/wordmark remain raster design mockups.
- [Motion01](../../Prototypes/CircleUVisualPrototype/Sources/CircleUVisualPrototype/Resources/BrandArtwork/Motion01/README.md) has three eight-second camera-motion MP4 studies, 1280 × 640/30 fps, silent. These are not natural Pingu body animations. Kept the render script and provenance.
- Opened the combined local review gallery on 127.0.0.1:55990. No app build, publication, release, cloud AI or paid video run.

## Tool limitations and recovery

- Weave reports that the connected Figma account is not linked. Asked the owner to link it through profile settings for natural image-to-video character animation; continued with local motion studies. No account settings were changed.
- The existing Spaces poster could not connect: “The Page request does not belong to an active authorized task.” Used the presentation skill's local fallback. Existing cloud poster/deck remain unchanged; do not claim they contain revision 06.
- The first local builder attempt had a position-object syntax typo, fixed before rendering. The first finalizer run lacked its runtime-module environment variable; reran with the configured path and it passed. No unresolved validation failure.

## Verification

- All nine scene source hashes match previous provenance. New poster artwork generated via imagegen and visually reviewed; exact prompt saved.
- Poster render reviewed for hierarchy, wrapping, logo bounds and distinct imagery. Bundled Plus Jakarta Sans registered in both canvas font registries; file package specifies that family. PowerPoint application rendering/font embedding were not verified; font is not embedded.
- Finalizer: package integrity, slide geometry, declared font policy and exact-file reimport pass; no findings. Receipt is stored with the poster.
- All three videos: ffprobe confirms 8 seconds, 240 frames and dimensions; complete FFmpeg decode passes. Welcome browser playback reached 0:08/0:08; other preview controls were exercised. Browser evidence is separate from app animation validation.
- Documentation and gallery links checked; native/device/accessibility tests not run for these asset-only changes.

## Discussion and handoff

Inter-agent exchanges: None.

Remaining: owner review of poster and motion studies; link Figma to Weave for natural character-animation options and a per-run credit quote. Any later paid run still requires the tool's explicit cost approval. Native placements and motion remain separate work. Owner: Unassigned.
