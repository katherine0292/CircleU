# Owner confirms selected phone keyboard checks

- Recorded: 2026-10-25 01:20:24 +1100; Australia/Sydney.
- Agent / role: Codex coordinator.
- Status: partial; selected phone keyboard checks passed by owner report, VoiceOver pending.
- Base / branch: `da83ddccfd959d8743026e36edfff7efa7d3d860`, `codex/journal-calendar-planning`; inherited uncommitted phone-display QA/README/log work.
- Related: [phone display](2026-10-25-011639-codex-preview-phone-display.md), [QA record](../qa/native-recovery-keyboard-accessibility-2026-10-24.md).

## Request and outcome

Owner answered “All three work” for the requested physical-phone keyboard checks: Email Next reaches visible Password, invented login Done opens Earlier data and dismisses the keyboard, and reset Email Done opens Check your email. Updated current QA and host instructions with this explicitly owner-reported evidence. These flows remain fixtures with no real credentials, network authentication or reset email.

Requested a bounded physical VoiceOver check of names/order, Forgot password → empty Send reset link error speech/discovery, and Back focus. Explained swipe navigation, double-tap activation and three-finger scrolling. Result pending; Today remains deferred.

## Verification and limits

No source changes or new build/test/CI run; documentation-only update. Prior Simulator and Inspector results remain separate from these three manual phone observations. No full accessibility clearance, all-device coverage, password-token flow or production behavior claim.

## Discussion and handoff

Inter-agent exchanges: None. Await owner VoiceOver observations, then investigate any reported issue and cover remaining new-password/larger-text/privacy checks. Owner: Unassigned.
