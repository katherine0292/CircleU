# Physical preview setup and handoff

- Recorded: 2026-10-24 22:24:38 +1100; Australia/Sydney.
- Agent / role: Codex coordinator.
- Status: partial; normal-Run host setup awaits Mac unlock.
- Base / branch: `b77a3fba7f5437720559f58618ccfa0b840fa657`, `codex/journal-calendar-planning`; starting tree clean. New host/current QA changes are uncommitted.
- Related: [keyboard/accessibility work](2026-10-24-215902-codex-recovery-keyboard-accessibility.md), [current QA](../qa/native-recovery-keyboard-accessibility-2026-10-24.md), [host setup](../../Prototypes/CircleUVisualPrototype/CircleUPreviewHost/README.md).

## Request and scope

Owner asked why Device Hub was needed, then confirmed the phone reconnected for the already requested VoiceOver check. Explained Canvas versus running-app testing; attempted only the isolated package's physical preview. No production CircleU launch, data access or backend action.

## Work and evidence

CLI confirmed paired/wired iPhone 11 Pro Max/iOS 26.6.1 with Developer Mode enabled. Xcode copied/extracted symbols. Filtered app inventory found Xcode Previews installed. A direct preview-agent launch command succeeded; Canvas retries reported Connection interrupted, BSActionErrorDomain 1, generic possible-agent-crash and then launch failure. Details named inability to add nullable symbols for weak DeveloperToolsSupport. Aligning Xcode's main run destination with the phone did not resolve the error. No fresh matching crash log was found in the inspected host diagnostic directories; agent processes were listed, so no definitive crash or toolchain root cause is asserted. VoiceOver was disabled when queried.

Created CircleUPreviewHost through Xcode's App template and Save Project inside the original prototype folder, with nested Git creation disabled. Prepared ContentView using the existing library's onboarding/login view and a separate preview-bundle xcconfig. UI stopped when the Mac locked. Local package linking, effective configuration, team selection and host build/run remain pending. No .pbxproj text edits, dependency installation or copied screen/artwork source. User was asked to unlock the Mac; no passcode requested.

## Verification and limitations

Reviewed generated paths/source/config; local Markdown link targets and diff whitespace checked. No new app build/test/CI, physical prototype display or VoiceOver walkthrough completed in this follow-up. Prepared xcconfig is not assigned; generated project defaults still apply until reconciled. Do not claim this host is runnable or that signing is configured.

## Discussion and handoff

Inter-agent exchanges: None. Owner confirmed connection; Mac unlock is pending. Resume Xcode UI setup following the host README, verify effective separate bundle and compatible deployment target, build/run only the isolated host, then perform the physical VoiceOver walkthrough. Keep original production project/data intact. Owner: Unassigned.
