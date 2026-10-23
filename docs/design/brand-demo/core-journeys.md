# Brand demo 04 — core journeys

24 October 2026. Owner approved continuing the [prototype milestone plan](../../superpowers/plans/2026-10-24-prototype-review-milestone.md). These are immutable SwiftUI sample screens, extending the accepted brand with the existing font/colors/helpers. Actions and fields are static. No actual user content is included.

## Reflection route

![Capture, reflection review and saved detail](../swiftui-previews/brand-04-reflection-journey.png)

[Capture](../swiftui-previews/brand-04-capture.png) · [Reflection review](../swiftui-previews/brand-04-reflection.png) · [Saved detail](../swiftui-previews/brand-04-entry.png)

Capture keeps the user's words central and offers Review a reflection or Save only my words. Review separates original words from a tentative interpretation, with distinct editing affordances and the same words-only exit. Saved detail shows an accepted sample interpretation, keeps the original words and makes both a next step and linked practice optional. Saving is represented by this detail, without a separate success screen.

Copy/hierarchy are proposals derived from the documented Draft 02 Capture `11:101`, Reflection `11:102` and Entry `11:103`, not a fresh Figma translation. The saved example represents acceptance/correction rather than an automatic verbatim transfer of the tentative suggestion. The existing [reflection editor](../swiftui-previews/brand-02-edit-reflection.png) remains the editing specimen. No global state transition is simulated by these images.

## Verification boundaries

The standalone package builds and renders with the bundled real font. Individual screens are 390 × 844 points at 2×; phone exports and the comparison gallery were visually inspected for text/action/footer clipping. The initial ungrouped content/action layout compressed some affordances; explicit vertical groups resolved this in the final renders. Current evidence is macOS ImageRenderer only. Typing, keyboard, scrolling, save/edit/navigation, storage, model generation and voice are not implemented/tested here.

[SwiftUI source](../../../Prototypes/CircleUVisualPrototype/Sources/CircleUVisualPrototype/BrandJourneyPreview.swift) · [Package guide](../../../Prototypes/CircleUVisualPrototype/README.md)
