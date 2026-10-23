# Outline icons and logo/type comparison

- Recorded: 2026-10-23 21:18:32 +1100; Australia/Sydney.
- Agent / role: Codex, native visual comparison.
- Status: comparison completed; final typography/icon choice awaits owner feedback.
- Base: main, 2f28966; existing dirty work preserved; no commit/push.

## Request and scope

Owner requested simpler rounded-outline icons and a check of logo/font matching. Continued isolated previews and discussion; no production redesign.

## Work and findings

Inspected the current app icon, PinguFont/onboarding/glass typography, website brand markup/CSS and prior concept brief. The penguin mark and rounded system type work together visually. Recommend retaining them and using native outline symbols. Website C mark/Circleu spelling and Inter-first CSS are separate consistency gaps; no website edits.

Created IconDirectionPreview.swift with eight native symbol candidates, 24-point comparison row, unchanged existing logo and two real typography specimens: rounded throughout versus rounded headings/default-system body. Reused original icon bytes in a preview-only image set. First render had filled sparkles; changed Proud to an outline star. [Full review](../design/icon-direction/outline-review.md).

## Verification

- Swift package build with Xcode toolchain and existing temporary SwiftPM caches: exit 0, including rebuild after star substitution.
- Standalone renderer: exit 0; final 2080×1780 board visually inspected. All eight glyphs present; no visible clipping. No full app, Simulator or Firebase run.
- Original and copied logo byte-identical; PNG dimensions/header, resource JSON, 22 local documentation links and source/doc whitespace passed.
- Native fonts/SF Symbols used rather than image generation, giving a real typography comparison. No custom font or icon library installed. Device/Dynamic Type/dark-mode and interaction checks remain pending.

## Discussion and handoff

Inter-agent exchanges: None. Recommend option A to preserve rounded identity, regular reading text and semibold headings. Both font options and earlier illustrated concept retained for owner review. No final selection inferred. Owner: Unassigned.
