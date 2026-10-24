# Owner confirms all three physical New password checks

- Recorded: 2026-10-25 08:02:48 +1100; Australia/Sydney.
- Agent / role: Codex, reviewer/documentation follow-up after Claude handoff.
- Status: selected physical New password checks passed by explicit owner report; normal-entry confirmation pending.
- Base / branch: `d16eff66fb1dfdc7940f3d0390220d13d3764617`, `codex/journal-calendar-planning`; starting tree clean.
- Related: [Codex handoff](2026-10-25-014452-codex-to-claude-onboarding-handoff.md), [Claude checkpoint](2026-10-25-020350-claude-new-password-simulator-restore.md), [current review](../qa/native-onboarding-final-review-2026-10-25.md).

## Request and result

The owner replied **“All three work”** to the pending physical New password question, explicitly covering VoiceOver and maximum text: Next keeps confirmation visible, mismatch is spoken/correctable, and matching values reach completion, dismiss the keyboard and return to Log in with an empty Password. This supersedes the earlier handback's result-not-stated limitation. Record as owner-reported hardware/assistive-technology evidence; no automated speech or independent gesture observation.

## Review and work

Read Claude's published checkpoint and inspected current ContentView: normal `BrandOnboardingPreview(initialScreen: .logIn)` is restored and working tree was clean. Claude reports successful restored-build installation with launch blocked by a locked phone. That is reported evidence, not a fresh deployment verification by Codex. Updated current QA, host README and flow checklist to record the now-explicit physical passes. Historical handoff/Claude entries remain unchanged; no overlapping source, UI or signing changes.

## Verification and limits

Documentation-only follow-up: reviewed edited text, local Markdown targets and diff whitespace. No new app build, test, phone launch, CI, backend request or Today work. Restored normal-entry display still needs owner confirmation; prior Inspector and broader accessibility/release follow-ups remain open. No acceptance of new account providers or copy proposal is inferred.

## Discussion and handoff

Actual inter-agent exchanges: None. Claude's durable log/commit was read, not a direct exchange. Owner has clarified the physical test outcome. Remaining handoff item: confirm the installed restored host opens Log in, then close the bounded onboarding review with its accessibility limits. Codex remains available for review on the owner's request; no message to another chat was sent.
