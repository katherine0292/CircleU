# Lighter copy and rounded icon previews

- Recorded: 2026-10-24 01:57:17 +1100; Australia/Sydney; final checks continued in the same session.
- Agent / role: Codex coordinator; independent reviewer `icon_layout_review`.
- Status: static refinement delivered; owner review pending.
- Base revision and branch: `3df5eaf757385d502cf49002428b448f5d728285`, `codex/journal-calendar-planning`.
- Related record: [previous preview milestone](2026-10-24-013754-codex-calendar-review-preparation.md).

## Request and scope

The owner asked for fewer words and some icons. Refined the existing standalone visual prototype using native functional symbols, shorter helper copy, pencil edit affordances and compact source/date tags. Kept explicit main action labels, invented user writing and drafts, optional/words-only paths, and the calendar header without extra icons. Existing commit/push authorization covers this refinement; no merge or release.

## Work and outcome

[Demo 05](../design/brand-demo/lighter-icon-journeys.md) provides eight individual specimens and three galleries. The source has an opt-in `iconLed` presentation; Demo 04 remains the default for comparison. Shared brand colors, actual Plus Jakarta Sans and existing artwork remain in use. No production app, Figma, Firebase or storage changes. Feedback is recorded as design feedback in the walkthrough worksheet, not as a completed usability task or participant study.

## Verification

- Standalone Swift package build passed using Xcode's toolchain: `swift build --scratch-path /tmp/circleu-visual-preview-build --product render-previews`, with command-specific Xcode and module cache settings. Final correction build completed successfully.
- `render-previews docs/design/swiftui-previews` (absolute output path supplied) regenerated 44 PNGs; actual bundled font assertion passed.
- All 33 previous PNGs match Git HEAD byte-for-byte. Eleven new PNGs total 2,079,501 bytes; all eight individual specimens are 780 × 1688 pixels. No new artwork or raster icon assets.
- Coordinator inspected final saved-entry/message renders and reflection gallery; earlier inspection covered Practice gallery and updated source. No clipping observed. Source diff retains original writing, message, draft and separation of suggested/accepted content.
- Checked 124 relative links across changed/new design documents, whitespace and absence of production app/project diffs. Staged checks precede publishing.
- Not run: full app, Simulator/device, live Canvas, VoiceOver, Dynamic Type, contrast/touch-target validation, actual editing, navigation, voice, clipboard or persistence. Feature-branch push is not evidence of CI. These are static macOS ImageRenderer specimens.

## Discussion and decisions

Reviewer `icon_layout_review` inspected source, both journey galleries and updated context. Reported P2: shortening saved-message detail to “Not sent” removed explicit save confirmation. Coordinator accepted, changed it to “Saved · Not sent” and added Saved to the entry date tag, then rebuilt/rerendered and inspected both final images. Reviewer reported no other material issue and no clipping; that was source/image evidence, not runtime validation. Final correction pixels were coordinator-checked, not independently re-reviewed.

## Handoff

- Remaining work: owner review of the lighter layout and icon-only edit discoverability, followed by the existing walkthrough and calendar interaction decisions.
- Owner: Unassigned for a future task; no background work scheduled.
- Risks / unresolved questions: icons and shorter copy need interaction/accessibility validation before production. Preview approval does not authorize implementation or establish local-only behavior.
