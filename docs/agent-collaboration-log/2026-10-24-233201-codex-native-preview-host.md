# Native preview host linked and Simulator verified

- Recorded: 2026-10-24 23:32:01 +1100; Australia/Sydney.
- Agent / role: Codex coordinator.
- Status: partial; physical signing prompt and VoiceOver await owner action.
- Base revision / branch: `b77a3fba7f5437720559f58618ccfa0b840fa657`, `codex/journal-calendar-planning`; inherited uncommitted host/QA/partial-log work.
- Related: [prior setup handoff](2026-10-24-222438-codex-physical-preview-setup.md), [current QA](../qa/native-recovery-keyboard-accessibility-2026-10-24.md), [host instructions](../../Prototypes/CircleUVisualPrototype/CircleUPreviewHost/README.md).

## Request and scope

Owner confirmed Mac unlocked to resume the isolated native recovery preview setup and previously requested physical VoiceOver checks. Preserve production CircleU, Firebase and legacy data; do not move to Today.

## Work and outcome

Closed only the standalone package window, which enabled the previously disabled Add Package control. Linked the existing local library through Xcode UI, with executable products unselected. Set preview target identity, iPhone family, deployment and Swift language through Xcode UI; selected the intended Personal Team and actual phone. Removed the unused unassigned draft xcconfig so settings have one effective source. No project-file text edits, copied artwork/source library, external dependency or production modification.

Xcode Run reached 196/209 tasks and a codesign/SecurityAgent process. The protected macOS signing dialog is inaccessible to UI automation; asked the owner to complete it directly, without sharing the password. Physical app display remains unverified. Device Hub reports this iOS 26.6.1 phone cannot screen share with the current Mac tooling until iOS 27; use the phone itself for the walkthrough, without requiring an upgrade.

## Verification

- `xcodebuild -showBuildSettings -project Prototypes/CircleUVisualPrototype/CircleUPreviewHost/CircleUPreviewHost.xcodeproj -scheme CircleUPreviewHost -sdk iphoneos`: passed using normal developer caches after sandbox cache access failed. Effective bundle `com.tuannm3812.circleu.preview`, display CircleU Preview, iOS 17, family 1, iOS/Simulator platforms, Swift 6 and Personal Team.
- `xcodebuild build -project Prototypes/CircleUVisualPrototype/CircleUPreviewHost/CircleUPreviewHost.xcodeproj -scheme CircleUPreviewHost -destination 'generic/platform=iOS Simulator' -derivedDataPath /tmp/circleu-native-preview-host-simulator CODE_SIGNING_ALLOWED=NO`: BUILD SUCCEEDED. Only reported warning: AppIntents metadata skipped because no dependency.
- Built Info.plist confirmed separate identity/minimum/device family; package resource bundle contains existing fonts and Pingu artwork. `simctl install` and `simctl launch` succeeded for iPhone 18 Pro/iOS 27.0. Device Hub AX showed login heading, Email, secure Password and named actions; Forgot password → Reset password → Back to Log in succeeded.
- Not run: completed physical signing/install/launch, VoiceOver speech/gestures, new full keyboard regression, production tests/CI, release. Prior keyboard/Inspector findings remain in current QA and are not reclassified as new host/hardware evidence.

## Discussion and decisions

Inter-agent exchanges: None. Owner confirmed Mac unlock. System keychain prompt requires direct owner input; no password requested in chat. Normal Run remains the fallback for the unresolved on-device Canvas DeveloperToolsSupport failure.

## Handoff

- Remaining: complete protected keychain prompt, verify physical launch, then owner VoiceOver walkthrough and record results before Today.
- Owner: Unassigned.
- Risks / unresolved: physical launch may expose additional tooling/signing issues; automated Dynamic Type/contrast findings and spoken-focus behavior remain open. Simulator success is not hardware accessibility clearance.
