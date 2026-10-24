# Pingu activities and motion recommendation

- Recorded: 2026-10-24 07:33:22 +1100; Australia/Sydney; final publication checks continued in the same session.
- Agent / role: Codex coordinator.
- Status: artwork delivered as review candidates; motion proposal documented, not implemented.
- Base revision and branch: `7c72f3cd8228b7df0192e48c5d38ed0ca90a2864`, `codex/journal-calendar-planning`.
- Related record: [first asset expansion](2026-10-24-072207-codex-pingu-asset-expansion.md).

## Request and scope

The owner wanted Pingu doing more things and asked whether the app should use animation. Created five distinct activities: writing, reading, practising a message, stretching and a quiet breath. These choices are coordinator proposals within the requested artwork expansion. Stretching/breathing are illustrations only and do not expand MVP feature scope.

## Work and outcome

Stored five transparent originals under the prototype's `Resources/BrandArtwork/Activities01/`, copied without pixel editing from the built-in image-generation tool. Existing avatar supplied the identity reference. [Activity catalog](../design/brand-demo/pingu-activities.md) links the files; [prompt manifest](../design/brand-demo/pingu-activities-01-prompts.json) retains exact instructions, relative reference, dimensions, sizes and hashes. Added a static SwiftUI activity board beside the original avatar for comparison.

[Motion proposal](../design/motion-guideline.md) recommends native transitions, finite status feedback and occasional mascot movement, with still editors and Reduced Motion alternatives. Source inspection found existing Pingu loops, whole-image blink scaling, a repeating timer not retained for invalidation, and no Reduce Motion check in `PinguMascot`; these are source findings, not app runtime observations. No production repair or animation implementation was performed. Retrieved Apple's Reduced Motion evaluation criteria and linked SwiftUI's system-setting documentation. Suggested timings and placements are project proposals, not Apple mandates or study findings.

## Verification

- Standalone `swift build --scratch-path /tmp/circleu-visual-preview-build --product render-previews` passed using command-specific Xcode toolchain and module caches.
- Renderer completed 46 exports and verified the actual Plus Jakarta Sans family. New catalog is 1672 × 1795 pixels and 934,902 bytes; coordinator visually checked all six tiles, labels, consistent identity and absence of clipping/missing art.
- Five originals decode as 1254 × 1254 RGBA with alpha range 0–255 and nontrivial content inset on every edge. Total 4,364,227 bytes. Hashes match the manifest and reference files exist.
- All 45 prior rendered PNGs are byte-identical to base. Checked 126 relative links across affected design documents, whitespace and absence of production app/project diffs. Log/staged checks precede publishing.
- Not run: app, Simulator/device, live Canvas, Figma, actual motion, Reduce Motion behavior, VoiceOver, Dynamic Type, timer lifecycle, performance or accessibility audit. A static catalog cannot verify those behaviors. Branch push does not establish CI.

## Discussion and decisions

None — no inter-agent exchanges in this task. The owner requested assets and advice, not production animation implementation. Reused the existing illustrated style and native preview helpers; no new dependencies. Separate static poses are not a frame sequence or rig, so true eyelid/flipper/pencil animation needs separately authored assets. Existing commit/push authorization covers this scoped deliverable; no merge or release.

## Handoff

- Remaining work: owner review of poses and motion recommendation. A small isolated motion demo is proposed for a future authorized task, followed by accessibility/lifecycle/device checks before adoption.
- Owner: Unassigned; no background work scheduled.
- Risks / unresolved questions: chosen screen placements and detailed motion remain unapproved. Existing production animation and cloud paths remain unchanged. Preserve quiet writing surfaces and truthful save/copy/loading states.
