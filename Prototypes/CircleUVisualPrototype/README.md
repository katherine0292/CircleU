# CircleU SwiftUI visual prototype

Static Today, Journal and Practice boards based on [Figma Draft 02](https://www.figma.com/design/RVLtfmIVcO8gNk5fam0Vjd?node-id=11-100). The owner approved this preview-only work on 23 October 2026. This package has no dependency on the Circleu app, Firebase, authentication, storage or networking. All content is invented and controls are static labels.

## Open in Xcode

1. Open this folder's `Package.swift` in Xcode.
2. Open `Sources/CircleUVisualPrototype/PreviewGallery.swift` for the hubs, `EditorPreview.swift` for the editors, `IconDirectionPreview.swift` for the earlier comparison, or `BrandDemo.swift` for the new illustrated identity and Today demo.
3. Select scheme **CircleUVisualPrototype** (the library), choose **My Mac** and show **Editor → Canvas**. Resume the preview if paused. Avoid the whole-package and render-previews schemes: the executable can cause an `ENABLE_DEBUG_DYLIB` Canvas error.
4. Select a named screen or comparison gallery. The reflection editor is explicitly a proposed layout; the message editor follows verified Figma context.

The standalone package compiled with Xcode 27.1 and its renderer produced the [review images](../../docs/design/swiftui-previews/README.md). The subsequent Xcode retry succeeded: the package and Today/message-editor Canvas renders were visually verified using the library scheme. These are macOS-rendered SwiftUI boards, not iOS Simulator screenshots or physical-device evidence.

## Regenerate images

Run from this directory on macOS with Xcode installed:

```sh
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift run \
  --scratch-path /tmp/circleu-visual-preview-build render-previews \
  ../../docs/design/swiftui-previews
```

The executable currently writes thirty-three PNGs, including six core-route screens, two linked-context variants, three journey/context galleries under `brand-04-`, and the additional multiple-entry calendar specimen. The Xcode evidence screenshot is captured separately. No dependency downloads, signing account or Firebase configuration are required.

## Brand demo 01

[Demo 04 core journeys](../../docs/design/brand-demo/core-journeys.md) extends reflection and Practice in `BrandJourneyPreview.swift`, including original/updated linked context. These are sample fields/actions and have named Canvas previews; they do not implement navigation or storage.

The [Journal calendar proposal](../../docs/design/brand-demo/journal-calendar.md) adds saved-day, empty-day and multiple-entry specimens in `JournalCalendarPreview.swift`, using a fixed October 2026 month. It is a visual exploration, not real date filtering. The previous `emptyDay:` initializer remains available alongside the named sample-day initializer.

For the continuation, open `Sources/CircleUVisualPrototype/BrandFlowPreview.swift`: [Demo 02](../../docs/design/brand-demo/flow-previews.md) adds Journal, Practice, reflection/message editors and comparison galleries. It shares Demo 01 font/color/artwork helpers and retains prior assets alongside the revised Practice PNG. These fixed static specimens are not production navigation or form implementations.

[Demo notes and provenance](../../docs/design/brand-demo/README.md) document the proposed identity. Five transparent generated PNGs live in `Resources/BrandArtwork`; the real variable font and its SIL Open Font License live in `Resources/BrandFonts`. CoreText registers the font only in the preview process and verifies the resolved family. This is not a global font installation or a production app change. Fixed-size typography here is a review specimen, not a completed Dynamic Type implementation.

The brand board and Today proposal have named Canvas previews. Their macOS ImageRenderer exports are the review evidence for this pass; live Canvas was not reopened for the new brand views. Earlier Canvas verification below applies to the original hubs/editors only.

## Design boundaries

- Figma source nodes: Today `11:100`, Journal `11:104`, Practice `11:107`.
- Draft palette, copy, card radii and action hierarchy are preserved. Native rounded system typography replaces Figma's Inter fallback; fake OS time is omitted. This is a visual comparison, not a pixel-exact conversion.
- Color resources are scoped to this prototype package, not a production design-system replacement.
- Standard boards are 390 × 844 points; compact width is 320 × 844. Exports use 2× scale.
- Direct SwiftUI layout keeps text/cards visible to ImageRenderer. These fixed boards do not implement the Figma scroll behavior, navigation, editing, persistence, accessibility text scaling or error recovery. Use [Figma Play](https://www.figma.com/proto/RVLtfmIVcO8gNk5fam0Vjd?node-id=11-100&starting-point-node-id=11%3A100) to review connected flows.
- iOS 17/macOS 14 package declarations are preview-library compatibility only; they do not change CircleU's device-support plan. The render executable requires macOS.

The [hub and asset review](../../docs/design/preview-review-2026-10-23.md) records proposed refinements. Reflection and message editors are now included; full app validation and legacy-data recovery remain separate work.
