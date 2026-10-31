# Artwork review 05

Open `index.html` locally to review the Expansion05 candidates. The page uses local relative image paths and the bundled Plus Jakarta Sans font; it has no remote resources or dependencies.

The seven PNG files are stored under `../Sources/CircleUVisualPrototype/Resources/BrandArtwork/Expansion05/`. Missing images show an explicit unavailable state. Exact prompts, metadata and review notes are linked in [Expansion05](../../../docs/design/brand-demo/asset-expansion-05.md).

- Scenes are shown in full, without cropping.
- Both transparent character poses appear on ice and ink surfaces.
- Icons are shown at 32, 48 and 96 CSS pixels, plus a 48-pixel ink comparison.
- Play greeting runs one 560 ms whole-illustration tilt. Play thoughtful tilt runs one 580 ms tilt. These are motion studies, not articulated flipper/eyelid animation.
- System reduced motion and the Still mode checkbox prevent playback. Changing either, hiding the document, leaving the page or starting a different study cancels existing playback. Nothing autoplays or loops.

Validation: inline JavaScript passed `node --check`; bundled font and all seven image paths exist. Parent inspected scenes, transparent poses and icon sizes in the in-app browser, exercised both playback buttons and checked that Still mode disables/re-enables them. System reduced-motion and background cancellation were source-reviewed, not independently exercised. Native accessibility and phone layout remain separate. No production SwiftUI changes or app tests are part of this gallery. [Scene review screenshot](scenes-review.png).
