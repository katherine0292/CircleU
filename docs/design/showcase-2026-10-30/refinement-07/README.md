# Poster refinement 07: real screens

1 November 2026. The poster now shows exact captures of the merged guest app instead of generated phone mockups, as the 31 October audit asked. Direction B, the headline, the example quotes and the program lockup are unchanged from [refinement 06](../refinement-06/README.md).

- [Poster PNG](CircleU-Poster-v7.png): 2560 × 1440 landscape export.
- [Source page](poster.html): HTML and CSS; rendered with headless Chrome at a 2× device scale factor. Everything on it is editable text or a referenced asset in [assets](assets/).
- [Provenance](provenance.json): hashes of every asset and the capture test that produced the screens.

## What is on it

| Element | Source |
| --- | --- |
| Journal, Today and Practice screens | `GuestShowcaseCaptureUITests.testCaptureShowcaseScreens` on the iPhone 18 Pro Simulator, iOS 27.0: a seeded Journal with three tagged entries, the empty Today screen, and the Practice result for an invented group-project message with guided suggestions |
| Background, wordmark and Pingu | `refinement-04/assets/arctic-background.png`, the sitting Pingu from `refinement-06/poster-artwork.png`, `BrandArtwork/BrandLogo.png` and `EmotionPortraits02/PinguCalmTransparentV1.png`, all unchanged files |
| Type | Bundled Plus Jakarta Sans; headline 44 px, intro 18.5 px, steps 24 px, trust line 16 px on the 1280 × 720 canvas |
| Program lockup | The same UTS Apple Foundation Program image as refinement 04–06; not a claim of endorsement |

Owner review, 1 November: background is the existing empty arctic scene (refinement 04) with the sitting journal Pingu from the v6 poster artwork laid over its bottom-right corner (clipped to Pingu and the ice under him, scaled to 78%, edges faded), the screen captions and the two footer notes are removed, Pingu sits beside the program lockup, the example quotes are replaced by three steps (Write it down. Tag how it felt. Find your words.) with the line "Private by design. Kept on your iPhone.", and the phones are back at full size between the copy and Pingu. The poster carries no "Design mockups" disclaimer because the screens are real.

## Rebuilding

```bash
cd docs/design/showcase-2026-10-30/refinement-07
"/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" --headless=new --disable-gpu --hide-scrollbars \
  --force-device-scale-factor=2 --window-size=1280,720 --screenshot="$PWD/CircleU-Poster-v7.png" "file://$PWD/poster.html"
```

To refresh the screens, run the capture test (scheme `CircleuUITests`, `-only-testing:CircleuUITests/GuestShowcaseCaptureUITests`), export its `showcase-*.png` attachments into `assets/` as `journal.png`, `today.png` and `practice.png`, and rebuild.

## Limits

No editable PowerPoint in this revision: the previous builder depended on a tool that is not available on this Mac. The HTML page is the editable master. The export is for screen review and the showcase display; large-format print suitability was not checked. The simulator screens are exact app output, but they are not physical-device captures.
