# Native onboarding brand preview implementation plan

> Execute inline with `superpowers:executing-plans`. The owner explicitly approved this isolated SwiftUI prototype on 24 October. Keep the existing original-folder checkout and prototype library; no production integration or extra worktree is needed.

**Goal:** Review the original Welcome composition with accepted branding in Xcode at actual phone size.

**Architecture:** Add one responsive onboarding specimen to the existing preview library. Reuse its font/color/artwork helpers. Optional privacy and earlier-data panels use in-memory navigation only; Get started opens a static opening state with cancellation. No readiness success, persistence, authentication or import is simulated automatically.

**Tech stack:** Existing SwiftUI/SwiftPM, ImageRenderer and Xcode Canvas. No dependencies.

**Spec:** [Original layout](../../design/original-layout-reuse.md), [latest onboarding copy](../../design/brand-demo/onboarding-review.md) and [refresh handoff](../../design/figma-brand-refresh-brief.md). The owner's latest request authorizes this native prototype instead of waiting for Figma.

## Constraints and review focus

- Keep the 172pt art slot, 32pt title/gap and lower 54pt primary action; use flexible space and scroll fallback, not a fixed 390 × 844 view.
- Use bundled Plus Jakarta Sans with Dynamic Type, accepted ice/blue/ink and existing transparent welcome Pingu/logo. No regenerated artwork.
- Preserve privacy warning and earlier-data access; nested Back must return to its origin. No signup, permissions, cloud or data mutation.
- No Sample/Demo labels inside the depicted UI; limitations belong in Xcode preview names and docs.
- Check regular and compact phone layouts, larger text, full action visibility and optional panels. Opening is an intentionally static visual endpoint, not a working storage check.

## Task 1 — Specimen, review artifacts and Xcode handoff

Files: new `Sources/CircleUVisualPrototype/BrandOnboardingPreview.swift` within the existing package; renderer `Sources/RenderPreviews/main.swift`; package README; onboarding review documentation; new dated agent log. Keep production files and historical PNGs unchanged.

- [x] Add `BrandOnboardingPreview(initialScreen:)` with Welcome, optional Privacy/Earlier data, Opening, Locked and Read-error fixtures. Back/cancel uses local state only; no timer or success transition. Keep legacy recovery beyond its explanation explicitly pending.
- [x] Add named phone-size and larger-text Canvas previews plus normal/compact PNG exports and a comparison board with notes outside screens.
- [x] Build `render-previews` using `/tmp/circleu-visual-preview-build`, render to a temporary directory, visually inspect new outputs and retain only deliberate new onboarding artifacts. Expected: successful build/render, actual Plus Jakarta Sans and visible complete content.
- [x] Open the existing package and new source in Xcode, choose the library scheme and an iPhone destination, and enable Canvas. Expected: actual preview displayed, or record the specific Canvas limitation and show the verified render.
- [x] Review scoped diff/links/whitespace and obtain one independent final review. Commit/push only these authorized prototype/doc files; verify remote SHA.

This is a reversible visual specimen. Compilation, rendered visual checks and native interaction inspection are appropriate; implementation-mirroring unit tests and full production app tests are not required by the project standards. Physical-device, real storage and production privacy claims remain out of scope.

## Execution evidence

Delivered and reviewed; see the [dated record](../../agent-collaboration-log/2026-10-24-190710-codex-native-onboarding-preview.md). The static compact export uses 375 × 844 because ImageRenderer omitted the scroll branch at 375 × 667. Xcode visually displayed phone fixtures; live tap/scroll, hardware and real readiness checks remain pending. No production integration.
