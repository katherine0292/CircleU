# Poster refinement 07: real screens

1 November 2026. The poster now shows exact captures of the merged guest app instead of generated phone mockups, as the 31 October audit asked. Direction B, the headline, the example quotes and the program lockup are unchanged from [refinement 06](../refinement-06/README.md).

- [Poster PNG](CircleU-Poster-v7.png): 2560 × 1440 landscape export.
- [Source page](poster.html): HTML and CSS; rendered with headless Chrome at a 2× device scale factor. Everything on it is editable text or a referenced asset in [assets](assets/).
- [Provenance](provenance.json): hashes of every asset and the capture test that produced the screens.

## What is on it

| Element | Source |
| --- | --- |
| Journal, Today and Practice screens | `GuestShowcaseCaptureUITests.testCaptureShowcaseScreens` on the iPhone 18 Pro Simulator, iOS 27.0: a seeded Journal with three tagged entries, the empty Today screen, and the Practice result for an invented group-project message with guided suggestions |
| Wordmark and Pingu | `BrandArtwork/BrandLogo.png` and `EmotionPortraits02/PinguCalmTransparentV1.png`, unchanged |
| Type | Bundled Plus Jakarta Sans; headline 44 px, intro 18.5 px, quotes 19–20 px, labels 15 px on the 1280 × 720 canvas |
| Program lockup | The same UTS Apple Foundation Program image as refinement 04–06; not a claim of endorsement |

Footer text says "Illustrative example. Kept on your iPhone; nothing is uploaded." and "Screens from the app build, 1 November 2026", so the poster no longer carries a "Design mockups" disclaimer.

## Rebuilding

```bash
cd docs/design/showcase-2026-10-30/refinement-07
"/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" --headless=new --disable-gpu --hide-scrollbars \
  --force-device-scale-factor=2 --window-size=1280,720 --screenshot="$PWD/CircleU-Poster-v7.png" "file://$PWD/poster.html"
```

To refresh the screens, run the capture test (scheme `CircleuUITests`, `-only-testing:CircleuUITests/GuestShowcaseCaptureUITests`), export its `showcase-*.png` attachments into `assets/` as `journal.png`, `today.png` and `practice.png`, and rebuild.

## Limits

No editable PowerPoint in this revision: the previous builder depended on a tool that is not available on this Mac. The HTML page is the editable master. The export is for screen review and the showcase display; large-format print suitability was not checked. The simulator screens are exact app output, but they are not physical-device captures.
