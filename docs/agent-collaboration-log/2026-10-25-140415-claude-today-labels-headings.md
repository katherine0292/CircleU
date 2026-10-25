# Today boards: sample labels to captions, plain hub headings

- Recorded: 2026-10-25 14:04:15 +11:00; Australia/Sydney.
- Agent / role: Claude (Claude Code).
- Status: pushed to PR #4; not merged.
- Base revision and branch: `codex/today-copy-trim` (PR #4).
- Related record: [CI merge and Today copy trim](2026-10-25-134851-claude-ci-merge-today-copy.md).

## Request and scope

The owner's choices were relayed through the project coordinator: move the blue sample/review labels out of the phone screens into captions, and use the plain tab names "Journal" and "Practice" as hub headings. Prototype only; don't merge.

## Work and outcome

- `BrandJourneyPreview` no longer draws its review label inside the screen. Comparison galleries, including the linked-context gallery, show it as a caption above each screen. Individual screens keep the Sample/Draft chip and footer as their sample marker.
- `BrandHubPreview` headings are now "Journal" and "Practice", in the row with the hub artwork; the small tab label is gone.
- Regenerated the brand-02 hub and brand-04/05 renders; updated the [walkthrough script](../design/today-walkthrough-script-2026-10-25.md#applied-on-codextoday-copy-trim).

## Verification

- iPhone 18 Pro / iOS 27.0 Simulator: Journal, Practice, Capture, Saved entry and Wording boards screenshotted via `--board`. One first-launch screenshot was blank because it was captured too early; a relaunch rendered correctly.
- `performAccessibilityAudit()` on all nine boards: only the expected Dynamic Type findings for fixed-size specimens.

## Discussion and decisions

None between agents; decisions from the owner via coordinator relay.

## Handoff

- Remaining work: owner phone check of PR #2, then review/merge of PR #2 and PR #4.
- Owner: Mike.
