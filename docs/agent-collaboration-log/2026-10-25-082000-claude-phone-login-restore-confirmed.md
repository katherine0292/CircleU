# Phone confirms restored Log in entry

- Recorded: 2026-10-25 08:20:00 +11:00; Australia/Sydney.
- Agent / role: Claude (Claude Code).
- Status: completed.
- Base revision and branch: `d16eff66fb1dfdc7940f3d0390220d13d3764617`, `codex/journal-calendar-planning`.
- Related record: follows [New password Simulator check and restore](2026-10-25-020350-claude-new-password-simulator-restore.md), which left on-phone confirmation pending.

## Request and scope

The owner asked Claude to finish the on-phone check of the restored normal entry point. Docs-only update after that check.

## Work and outcome

- iPhone Mirroring access requests were rejected immediately twice, so no screen-control evidence was collected.
- After the owner unlocked the phone, `xcrun devicectl device process launch --terminate-existing` started `com.tuannm3812.circleu.preview` successfully. This was the build from the restored `BrandOnboardingPreview(initialScreen: .logIn)` source installed earlier.
- The owner then sent a phone screenshot showing CircleU Preview on Log in with empty Email and Password placeholders. The image is owner-supplied evidence and is not stored in Git.
- Updated the [25 October review](../qa/native-onboarding-final-review-2026-10-25.md) gate, [host README](../../Prototypes/CircleUVisualPrototype/CircleUPreviewHost/README.md) and [flow checklist](../product/flow-status-checklist.md).

## Verification

- `git diff --check` and local Markdown links checked.
- Not run / limitations: the physical New password checks still have no per-check result (owner reported completing them). Inspector warnings and broader accessibility coverage remain open, as listed in the previous entry.

## Discussion and decisions

None between agents. The owner provided the screenshot.

## Handoff

- Remaining work: Inspector re-audit and broader accessibility coverage; owner decisions on Account help copy and any Apple/Google provider proposal.
- Owner: Mike for decisions; Unassigned for accessibility follow-ups.
- Risks / unresolved questions: none new.
