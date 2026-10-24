# Password fixture delivery corrected and provider options reviewed

- Recorded: 2026-10-25 01:42:34 +1100; Australia/Sydney.
- Agent / role: Codex coordinator.
- Status: partial; correct phone screen confirmed, password interaction result pending.
- Base / branch: `da83ddccfd959d8743026e36edfff7efa7d3d860`, `codex/journal-calendar-planning`; inherited uncommitted QA/log work and temporary host fixture configuration.
- Related: [prior checks](2026-10-25-013239-codex-onboarding-final-checks.md), [current review](../qa/native-onboarding-final-review-2026-10-25.md), [provider discussion](../design/account-onboarding.md).

## Request and outcome

Owner reported seeing Log in rather than the intended New password fixture and asked to open it. Also asked why Used Google? appears and whether Google, X or Facebook can be used. Stopped the prior Xcode preview run; source still contained the intended existing `.newPassword` configuration. Built that explicit project/configuration in a fresh derived-data directory, confirmed the compile log names the correct ContentView source, installed only the separate preview bundle and launched it. Owner then confirmed New password appears. Reissued the bounded invented-password/Next/mismatch/completion checks; result still pending. No root cause beyond the prior delivery mismatch is asserted.

Consulted the Firebase Authentication skill and primary Firebase/Apple documentation for provider support. Current source adapter implements email/password; prior inventory found Google enabled in Dev but did not establish shipped Google support. Used Google? is only preview help. Recommended Account help as clearer copy, Apple/Google first if optional accounts gain an approved benefit, and deferring X/Facebook. Recorded as a proposal; no social-login, provider configuration or product copy changes. Guest-first approval remains intact.

## Verification

- `xcodebuild build -project Prototypes/CircleUVisualPrototype/CircleUPreviewHost/CircleUPreviewHost.xcodeproj -scheme CircleUPreviewHost -configuration Debug -destination 'platform=iOS,id=<connected-phone>' -derivedDataPath /tmp/circleu-phone-password-review`: BUILD SUCCEEDED. Only reported warning: AppIntents metadata extraction skipped because no dependency. Compile log confirmed correct ContentView path.
- `devicectl device install app` and `device process launch` succeeded for `com.tuannm3812.circleu.preview`. Owner separately confirmed the visible New password screen. No physical speech/gesture success inferred from launch output.
- Source review and primary docs only for account providers; no production/backend calls, data access, app release, tests/CI or Today work.

## Discussion and handoff

Inter-agent exchanges: None. Corrects the inference that prior Xcode Running status was enough to establish the intended fixture on the phone; owner evidence contradicted it. Receive final password interaction result, restore/reinstall normal entry, verify current docs and publish scoped QA checkpoint. Owner: Unassigned.
