# Today and Journal — selected style applied in Figma

- Recorded: 2026-10-31 09:55:02 +11:00; Australia/Sydney
- Agent / role: Codex / prototype author and reviewer
- Status: completed for prototype review
- Base revision and branch: 9967a10, codex/app-upgrade-plan; uncommitted working-tree changes, including substantial pre-existing unrelated work
- Related record: [Refine A selected](2026-10-31-092800-codex-refine-a-selected.md)

## Request and scope

Owner approved applying the selected Refine A styling to Today and Journal and asked to see the output. Owned local path: `docs/design/figma-today-journal-review-11/`. New Figma page `60:16925` in file `rfknpmLIXsOxA7fHUQQMtR`; existing pages preserved. No native implementation, backend or paid generation.

## Work and outcome

Created [review 11](../design/figma-today-journal-review-11/README.md), with editable Today/Journal states, existing brand art, consistent typography and stable tabs. Includes simulated writing/voice/save, journal browse/search, October calendar filtering, edit/discard/error and guided reflection. Calendar remains free of decorative icons. Existing Practice review 10 is reached through a separate prototype URL.

Visual inspection found and corrected auto-layout clipping in journal cards, calendar dots and horizontal controls. Failed construction attempts were reported as uncommitted by Figma and retried; the final page was verified without duplicate pages from those attempts.

## Verification

- [Structural result](../design/figma-today-journal-review-11/validation.json): 59 frames, 1,290 valid internal links, 59 external Practice links, 31 October date states, one font family, consistent tab position; no detected invalid destinations, clipped children or checked copy violations.
- Browser walkthrough: recording fixture → writing → saving → saved Journal; calendar scroll reveals both entries with fixed tabs; empty October 30 and clear; preset matching and empty searches; entry edit/save and Back show updated text.
- Final PNG exports visually reviewed. Browser evidence saved as JPEG.
- `git diff --check` passed before documentation was added; final documentation/file verification recorded in task output.
- Not run: app build, unit/UI suites, physical-device and VoiceOver tests. No Swift changed; Figma checks do not establish native behavior.

## Discussion and decisions

No inter-agent exchanges. Owner selected A and approved this visual extension. Prototype uses invented fixtures; it does not authorize AI, sync or native implementation. All October dates are interactive; adjacent month day selection and filter restoration on entry Back remain outside this bounded review.

## Handoff

- Remaining work: owner visual review, then decide which styling changes to implement in SwiftUI. See README for bounded interactions and starting points.
- Owner: Unassigned
- Risks / unresolved questions: fixed Figma content is not free input or persistent storage; Practice is a separate prototype link. No commit or push performed.
