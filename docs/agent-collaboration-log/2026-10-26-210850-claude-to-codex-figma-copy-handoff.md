# CircleU Design canvas copied into Figma

- Recorded: 2026-10-26 21:08:50 +11:00; Australia/Sydney.
- Agent / role: Claude (project thread "Move CircleU Design canvas to Figma").
- Status: completed.
- Base revision and branch: `ee7f476` (main), branch `codex/figma-design-copy`.
- Related: correction to [design export handoff](2026-10-26-195218-claude-to-codex-design-export-handoff.md) ("Figma skipped for now"), [canvas export](../design/circleu-design-export/README.md).

## Request and scope

Mike moved to the Figma Education plan on his UTS account and asked Claude to build the Figma copy after all, so Codex can work from Figma as well as from the repo export. No repo code changed. This entry only records the file.

## Work and outcome

- Figma file: https://www.figma.com/design/rfknpmLIXsOxA7fHUQQMtR (owned by Mike's UTS Figma account).
- Page "Screens and options": 36 boards in the same rows and positions as the canvas (Today/Journal/Practice/Settings, A, B, C, D, J, S, P, AC, OB), plus row titles and the coloured note cards.
- Page "States": the five non-happy-state boards (T4.1, J1.1, J2.2, S5.4, S2.3) and their note.
- Board names keep their story IDs. Text uses Plus Jakarta Sans and the app colours. Icons are vector SVG. Pingu poses and Guest icons use the real art from `Circleu/Assets.xcassets`, plus the two canvas-only images from the export's `assets/` folder.
- Frame "Art library (source images, do not delete)" (x −3000 on Screens) holds one copy of each image. Keep it so the art can be reused in new boards.
- Boards are plain frames with absolute positions, not components or auto layout. They copy the canvas; they are not a design system.
- An empty file from the earlier attempt on Mike's Gmail Figma account (Wq2cwQCBEx8Ak332OMYvY8) can be deleted; it holds nothing.

## Verification

- Board count checked in the file: 36 on Screens and options, 5 on States, 21 titles and notes, no unfilled image placeholders.
- Figma screenshots checked by eye for D1 (Visual Today), OB1 (onboarding scene) and C1 (hero art): they match the canvas.
- Not checked: a side-by-side review of every board. Not run: app build or tests (docs-only change).

## Discussion and decisions

None between agents. Owner decision (26 Oct): build the Figma copy now that the UTS account has edit access. This replaces the "skip Figma" decision in the 19:52 entry.

## Handoff

- Remaining work: none required. Codex can read boards from Figma (sign in its Figma plugin with the UTS account) or keep using `docs/design/circleu-design-export/`.
- Owner: Unassigned.
- Risks: the Claude canvas is still where Mike comments. Figma and the repo export are snapshots of 26 Oct, so copy any later canvas changes into both or note which one is current.
