# Native form maximum-text walkthrough confirmation

- Recorded: 2026-10-24 21:22:46 +1100; Australia/Sydney.
- Agent / role: Codex coordinator.
- Status: documentation update complete; owner-reported manual check recorded.
- Base / branch: `fcb9969fdc21667a41a60686c0a46c82f7964fb5`, `codex/journal-calendar-planning`; starting tree clean.
- Related: [native preview implementation](2026-10-24-211448-codex-native-account-previews.md), [recovery QA](../qa/native-recovery-preview-2026-10-24.md).

## Request and scope

Owner answered the pending native Log in/reset-request maximum-text check: both forms scroll and controls work. Updated the current QA record, recovery guide, onboarding brief and flow checklist. No source, artwork, production data or Today changes.

## Work and outcome

Recorded owner-reported readability/reachability and scrolling on the selected iPhone 18 Pro/iOS 27.0 preview at accessibility5: Log in → Forgot password? → reset request → reach Send reset link → Back. This closes that specific manual check from the linked implementation handoff, without rewriting its published entry.

## Verification

Documentation-only: reviewed the complete diff, checked local Markdown link targets and ran `git diff --check`. No new build, Simulator automation, app tests or CI run. The walkthrough is owner-reported evidence, not an independently repeated automated swipe check.

## Discussion and decisions

Inter-agent exchanges: None. Owner confirmed both forms scroll and controls work; no new feature or production-integration approval inferred.

## Handoff

Software-keyboard submit/avoidance, other text sizes, VoiceOver, compact-height/landscape and physical hardware remain unverified. Real providers, reset mail/token handling and data recovery remain separate transition implementation work. Today remains unchanged. Owner: Unassigned.
