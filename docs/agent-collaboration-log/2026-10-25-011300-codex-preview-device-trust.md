# Physical preview installed; device trust pending

- Recorded: 2026-10-25 01:13:00 +1100; Australia/Sydney.
- Agent / role: Codex coordinator.
- Status: partial; owner device trust and VoiceOver pending.
- Base / branch: `82b4ec76b8eab77775e52699d0f3b6c51cc32890`, `codex/journal-calendar-planning`; starting tree clean.
- Related: [host setup](2026-10-24-233201-codex-native-preview-host.md), [current QA](../qa/native-recovery-keyboard-accessibility-2026-10-24.md).

## Request and outcome

Owner reported completing the protected Mac keychain prompt. Xcode showed Finished running, but that alone was insufficient evidence of screen display. Filtered `devicectl device info apps` confirmed the separate `com.tuannm3812.circleu.preview` app installed as CircleU Preview 1.0/build 1. A `devicectl device process launch` attempt was denied with a signature/entitlement/trust security message. Repeating Run through Xcode produced the specific Developer App Certificate is not trusted alert and phone Settings instructions. Asked owner to trust only their own signing certificate on the phone and report whether Log in appears. Dismissed the Xcode error alert; no production app/data/backend action.

## Verification and limits

Installed-app inventory and Xcode trust alert are verified; physical display, keyboard interaction and VoiceOver speech/gestures remain unverified. No source changes, new build checks, production tests/CI or Today work. Current QA and host instructions updated; historical setup records preserved. A host-side codesign verify also reported CSSMERR_TP_NOT_TRUSTED; no unsupported root-cause or signing-repair claim beyond Xcode's explicit device-trust finding.

## Discussion and handoff

Inter-agent exchanges: None. Owner completed keychain step; next owner action is device certificate trust and reporting actual preview display. Continue with keyboard/VoiceOver walkthrough after launch. Owner: Unassigned.
