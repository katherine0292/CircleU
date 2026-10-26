# CircleU Design canvas export

A static copy of the Claude Design canvas **CircleU Design** (https://claude.ai/artifact/Dmqgv7oiiZM8PyuRqaQCXK), exported on 26 October 2026 so Codex and Figma can use the same boards. The canvas stays the place where Mike comments; this folder is a snapshot, not the source of truth. Re-export after canvas changes.

## What's here

| Path | Use |
| --- | --- |
| `canvas.html` | Every row on one page, laid out like the canvas, with board titles and the canvas notes. |
| `rows/<ID>.html` | One page per row (Screens, A, B, C, D, JS, S, PR, AC, OB, States). These are the pages captured into Figma. |
| `boards/<Board>.html` | One 390×844 board per file, plain HTML with inline styles. |
| `png/boards/<Board>.png` | Each board rendered at 2× (780×1688) for quick visual reference. |
| `boards.json` | Board titles (story IDs first), canvas positions and notes, from the canvas's `canvas.json`. |
| `assets/` | The two canvas-only images that aren't in the app's asset catalog. |

Every other image points at the real file in `Circleu/Assets.xcassets` (Pingu poses and Guest icons), so the boards show exactly the art the app ships. Open the HTML from a checkout of the repo, or serve the repo root (`python3 -m http.server`) and open `/docs/design/circleu-design-export/canvas.html`.

Font: Plus Jakarta Sans 400/600/700 from Google Fonts. Colours: ink `#0D1421`, blue `#054FC9`, ice background `#F5FAFF`, card blue `#E3EEFF`, muted text `#4F6077`, border `#DCE6F2`.

## Limits

- Boards are mock-ups. They don't prove Dynamic Type, safe areas, VoiceOver or real behaviour; the SwiftUI app and its tests do.
- Rows A, B and C are older options; D, JS, S, PR, AC and OB are the 26 October "less text" redesign. OB still uses drawn placeholder backdrops; the app now ships the Expansion04 scenes instead.
