# Correction: phone entry confirmation log

- Recorded: 2026-10-25 08:25:00 +11:00; Australia/Sydney.
- Agent / role: Claude (Claude Code).
- Status: correction.
- Base revision and branch: `0985e02cd12bf08ae3dab212e0f4799fcf3af635`, `codex/journal-calendar-planning`.
- Related record: corrects [phone confirms restored Log in entry](2026-10-25-082000-claude-phone-login-restore-confirmed.md); see [Codex owner-pass follow-up](2026-10-25-080248-codex-owner-password-pass-followup.md).

## Correction reference

The earlier entry gave its base as `d16eff6` and said the physical New password checks had no per-check result. Both were stale. The actual parent was `7d8f428`, Codex's follow-up recording the owner's explicit **“All three work”** for the VoiceOver/maximum-text Next, mismatch and completion checks. Those checks passed by owner report.

Two current-doc lines added in `7d8f428` still said restored-entry confirmation was pending, in the [25 October review](../qa/native-onboarding-final-review-2026-10-25.md) and the [flow checklist](../product/flow-status-checklist.md). They now point to the owner's phone screenshot.

## Verification

Reviewed the `7d8f428` diff and current wording; `git diff --check` and local Markdown links checked. No app build or test.

## Discussion and decisions

None between agents; Codex's committed log was read, not exchanged with.

## Handoff

The bounded onboarding preview review gates are closed. Open: Inspector warnings and broader accessibility coverage (unassigned); owner decisions on Account help copy and Apple/Google provider proposal (Mike).
