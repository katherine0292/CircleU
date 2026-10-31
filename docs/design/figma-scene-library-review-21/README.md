# Approved Today layout and interchangeable scenes

31 October 2026. Owner accepted the compact composer and question-sheet direction. Page `74:2` is now **CircleU • current prototype**. Prototype approval only; no native implementation or automatic scene rotation.

[Open prototype](https://www.figma.com/proto/rfknpmLIXsOxA7fHUQQMtR/CircleU-Design--from-Claude-canvas-?node-id=74-3&starting-point-node-id=74%3A3). [Scene options in Figma](https://www.figma.com/design/rfknpmLIXsOxA7fHUQQMtR/CircleU-Design--from-Claude-canvas-?node-id=156-490).

## Refresh artwork

Family `CircleU / Scene artwork` (`156:477`) exposes **Scene** variants:

- Window pause — Today default, `ScreenScenes06/SceneWindowPauseV1.png`.
- Reflection garden — writing alternative, `ScreenScenes07/SceneReflectionGardenV1.png`.
- Voice corner — listening, `ScreenScenes07/SceneVoiceCornerV1.png`.

Originals remain unchanged under `Prototypes/CircleUVisualPrototype/Sources/CircleUVisualPrototype/Resources/BrandArtwork/`.

In Figma Design, select **Scene artwork** inside **Pingu capture scene**, then change **Scene** in the right panel. Keep the chosen writing scene consistent across empty, writing, saving, error and microphone-unavailable states; retain Voice corner during listening. To refresh every placement of one variant, replace the main component's **Artwork** image fill. Keep the 342 × 171 frame and 24pt crop radius.

## Evidence

Six capture states now use component instances. Verified variant properties/dimensions, retained picker navigation to `138:471`, and tab y=764 across all six states. Inspected [scene options](scene-options.png) and [Today](today.png). Artwork is raster; UI layers remain editable. Library search found no existing scene component; reused current approved assets for one family, with fixed existing artwork geometry.

No full player regression rerun, native changes/build/tests or device validation. Previous picker checks remain review-20 evidence. No generation, credit-spending operation, commit or push. `build-scenes.js` is a one-time mutation; `result.json` records IDs. Prior native and stale-reflection gaps remain separate follow-ups.
