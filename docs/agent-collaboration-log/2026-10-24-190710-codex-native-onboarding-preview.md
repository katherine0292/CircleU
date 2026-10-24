# Native onboarding with original proportions and accepted identity

- Recorded: 2026-10-24 19:07:10 +1100; Australia/Sydney; verification/handoff completed later in this session.
- Agent / role: Codex coordinator; final read-only reviewer `/root/onboarding_preview_review`.
- Status: visual specimen delivered; native tap/scroll validation and production integration pending.
- Base revision / branch: `8cf757e39837790a017732f998ba6738dcce77d1`, `codex/journal-calendar-planning`; initial tree clean.
- Related: [Figma handoff](2026-10-24-184851-codex-figma-refresh-handoff.md), [execution plan](../superpowers/plans/2026-10-24-native-onboarding-brand-preview.md).

## Request and work

Owner explicitly asked to start onboarding in the existing SwiftUI prototype, retain original layout, apply accepted branding/assets and open Xcode. Reused the existing original-folder checkout and library. Added `BrandOnboardingPreview.swift`: responsive Welcome, process-memory optional panels, static opening/failure fixtures and named Canvas previews. No new dependencies or production changes. Used the existing logo/waving Pingu, palette and bundled font, with Dynamic Type for new text. Kept review labels outside depicted UI.

Added renderer exports and retained only three deliberate new PNGs. [Native review guide](../design/brand-demo/native-onboarding.md) records exact dimensions, source behavior, verification and limits. Current onboarding/design/package indexes point to the specimen. Historical artwork and PNGs remain intact.

## Evidence

- `DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift build --package-path Prototypes/CircleUVisualPrototype --scratch-path /tmp/circleu-visual-preview-build --product render-previews`: passed after allowing compiler cache access. Final build completed in 2.79 seconds.
- `/tmp/circleu-visual-preview-build/debug/render-previews /tmp/circleu-onboarding-brand-review`: passed, bundled family verification succeeded. Regular/compact-width comparison visually inspected. New PNGs are 780 × 1688, 750 × 1688 and 1698 × 2028 pixels; total roughly 662 KB.
- Original 375 × 667 ImageRenderer fixture omitted ScrollView content. Kept a 375 × 844 compact-width comparison instead; did not hide the failure or call the native scroll path verified. Removed whole-stack fixed sizing so the original flexible spacers remain effective.
- Xcode opened the existing package, library scheme, new source and iPhone 17 destination. Welcome, Privacy and accessibility1 text fixtures visibly rendered in Canvas. Standard Welcome selected for owner handoff. Canvas control attempts did not reliably verify native button/scroll interactions; no tap-journey claim.
- Scoped docs/links/whitespace reviewed before publication. No production build/tests, Simulator installation or physical-device validation in this task. Previously recorded production test failures remain unresolved. No Figma canvas changes.

## Actual review exchange

Coordinator requested read-only review of source/layout, Back history, data isolation and honest coverage. `/root/onboarding_preview_review` found no important source defects, confirmed original proportions and local origin-preserving history, and required explicit limitations for inert Retry, external Figma recovery handoff and pending native short-height/larger-text scrolling. Coordinator inspected the implementation and recorded all limitations in the review guide. No merge/release sign-off is implied.

## Handoff

Owner can review Welcome directly in Xcode and compare optional/error fixtures by preview name. Get started stops at the static Opening endpoint; no readiness success or data mutation occurs. Next: owner visual feedback, then native tap/scroll/accessibility checks before extending to Today. No further implementation or background work scheduled. Owner: Unassigned.
