# New password Simulator check and normal entry restore

- Recorded: 2026-10-25 02:03:50 +11:00; Australia/Sydney.
- Agent / role: Claude (Claude Code), successor named in the Codex handoff.
- Status: partial. Simulator checks and restoration done; on-phone confirmation of the restored entry and per-check physical New password results pending from the owner.
- Base revision and branch: `da83ddccfd959d8743026e36edfff7efa7d3d860`, `codex/journal-calendar-planning`, plus the uncommitted Codex work listed in the handoff.
- Related record: [Codex → Claude handoff](2026-10-25-014452-codex-to-claude-onboarding-handoff.md); [25 October review](../qa/native-onboarding-final-review-2026-10-25.md).

## Request and scope

The owner asked Claude to take over the handoff. The brief came through the owner's project coordinator and noted that the owner said “Done” about the three physical New password checks without confirming whether each passed. Scope: exercise the New password fixture in the Simulator on the separate CircleUPreviewHost scheme only, restore ContentView, rebuild/launch, update QA/README/checklist docs, then commit and push. No Today or production work.

## Work and outcome

- Physical New password checks are recorded as **completed by owner report, pass/fail not stated**. No physical pass is claimed.
- Simulator (iPhone 18 Pro / iOS 27.0): Next keeps Confirm password focused and visible above the keyboard; mismatched Done shows a correctable error with focus retained; matching Done reaches Password updated with the keyboard dismissed; Log in returns with an empty Password. No defect found and no source fix made.
- [ContentView.swift](../../Prototypes/CircleUVisualPrototype/CircleUPreviewHost/CircleUPreviewHost/ContentView.swift) restored to `BrandOnboardingPreview(initialScreen: .logIn)`; it now matches the committed base.
- Updated the [25 October review](../qa/native-onboarding-final-review-2026-10-25.md), [keyboard/accessibility QA](../qa/native-recovery-keyboard-accessibility-2026-10-24.md), [host README](../../Prototypes/CircleUVisualPrototype/CircleUPreviewHost/README.md) and [flow checklist](../product/flow-status-checklist.md).

## Verification

- `xcodebuild … -scheme CircleUPreviewHost -destination 'platform=iOS Simulator,id=<iPhone 18 Pro>' CODE_SIGNING_ALLOWED=NO build`: succeeded with the temporary fixture and again after restoration. The only warning was the known skipped AppIntents metadata extraction.
- The Simulator MCP integration needs full Xcode selected via `xcode-select` (command-line tools are selected; not changed), and the owner declined screen-control access to Device Hub. The New password checks were therefore run by a throwaway XCUITest bundle in local scratch storage that launches the installed host by bundle identifier. `xcodebuild test` returned TEST SUCCEEDED; logged frames, focus, keyboard count and field placeholders support the table in the review. The runner is not in the repository.
- After restoration: `simctl install/launch` plus screenshot showed Log in with empty fields.
- Physical iPhone 11 Pro Max / iOS 26.6.1: device build with automatic signing succeeded and `devicectl` install completed. Launch was refused because the phone was locked. The owner has been asked to open the app and confirm the screen.
- Not run: VoiceOver speech, large text or hardware keyboard for New password; full-app tests; CI; production/back-end checks.

## Discussion and decisions

Actual inter-agent exchanges: none with Codex. The owner's project coordinator relayed the scoped brief described above. Claude asked the owner to confirm the restored on-phone screen and, optionally, the per-check New password results.

## Handoff

- Remaining work: owner confirmation of Log in on the phone; optional per-check physical New password results; Accessibility Inspector Dynamic Type/contrast warnings (including the unexplained 1.09:1 `#F5FAFF`/`#E8F0FC` pair); rotation/compact-height, intermediate text sizes, hardware keyboard, Reduce Motion/lifecycle and full VoiceOver coverage.
- Owner decisions open: the **Account help** copy and any Apple/Google provider proposal in [account onboarding](../design/account-onboarding.md) remain unapproved recommendations.
- Owner: Mike for the phone confirmation and decisions; Codex for review of this checkpoint if the owner requests it.
- Risks: Simulator results do not certify on-device behavior or assistive-technology output.
