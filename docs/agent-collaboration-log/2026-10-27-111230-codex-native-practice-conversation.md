# Native Practice conversation and voice review

- Recorded: 2026-10-27 11:12:30 +11:00; Australia/Sydney
- Agent / role: Codex `/root`, implementer; `/root/native_practice_review`, static reviewer
- Status: implemented; final UI evidence and physical review noted below
- Base: `9967a10`, `codex/app-upgrade-plan`; existing unrelated working-tree changes preserved
- Previous: [reply/voice browser prototype](2026-10-27-103239-codex-reply-voice-prototype.md)

## Request and scope

Owner approved bringing the accepted Practice flow into SwiftUI with real voice input, new branding and Xcode/iPhone review, and asked how replies fit a conversation. [Plan](../superpowers/plans/2026-10-27-native-practice-conversation.md).

## Work and outcome

Implemented Prepare, Refine, Their reply, attributed conversation history and transcript review using the existing guest app architecture and speech engine. Added optional V5 conversation storage, preserved old schemas and journal links, included history in export/search, retained new-draft state, and kept explicit saves for existing-conversation edits. Suggestions use on-device model when available, otherwise clearly labelled guided prompts. No new cloud service or automatic sending.

Reused existing Pingu art, adding four unchanged scene PNGs to the native catalog. Added CircleU Guest Review configuration/scheme with a separate review bundle and guest compile flag. Standard Debug/Release configuration behaviour unchanged. Matched signing to the existing Guest Test signed build via ignored local config; no credentials committed or logged.

[QA and native screenshots](../qa/native-practice-2026-10-27/README.md) and [user stories](../product/user-stories.md) explain the exact flow, coverage and limitations.

## Verification

- Unit command: `DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer xcodebuild test -project Circleu.xcodeproj -scheme Circleu -destination 'platform=iOS Simulator,id=20743DB1-66DF-46E1-A234-9792A6606A4D' -derivedDataPath /tmp/circleu-quality-derived CODE_SIGNING_ALLOWED=NO PRODUCT_BUNDLE_PREFIX=com.circleu.quality`. Final 266 passed, 1 skipped, 0 failures. Migration/reopen/stale/corrupt data, draft compatibility, voice cancellation/denial and context-only regressions included.
- Focused UI first run: 5 passes, 1 failure. Conversation + scripted voice insertion/persistence, linked entry/delete, normal/max-text pinned Save and suggestion use/Undo passed. Copy/edit/discard fixture assumed end-of-text cursor placement after a screen transition; changed it to assert persistence of actual edited text. Final rerun result recorded when finished.
- Review scheme physical build succeeded; bundle identifier and signing team verified against earlier Guest Test build; installed in place on iPhone 11 Pro Max / iOS 26.6.1 without uninstall. Launch refused because phone locked. Owner asked for real speech check; no result yet.
- Xcode UI verified project at worktree path, GuestPracticeScreens.swift open, CircleU Guest Review scheme, physical phone selected.
- Not run: complete UI suite this turn, physical speech/VoiceOver, all devices, Release/TestFlight or live cloud paths. No deployment, commit or push.

## Actual review exchange

Reviewer reported two concrete issues: context-only additions selected reply acknowledgements; scripted voice UI test waited for Use text without stopping. Coordinator reproduced the context-only failure and fixed selection based on additions since the latest prepared wording. Added Stop to UI test; the conversation/voice test passed. Reviewer found no other concrete storage/cancellation issue in its static pass. No second review was claimed.

## Handoff

Owner: review real speech on phone after unlock, plus voice permissions, larger text and VoiceOver. Engineering: full UI suite before merge; semantic suggestion quality on a supported Apple Intelligence phone; keep cloud/legacy migration work separate. No unsent content is assumed sent, and automatic launch/install is not evidence of physical microphone or store migration success.


## Final result — 11:13 +11:00

The final focused UI rerun passed all three cases (edit/discard/reopen, data controls/draft, native screen navigation), with no failures. Combined with five distinct passing cases in the first run, eight affected UI cases passed. Full unit final result remains 266 passed / 1 skipped. `git diff --check` and `plutil -lint Circleu.xcodeproj/project.pbxproj` passed. Implementation and automated checks complete within scope; no physical speech/VoiceOver confirmation received. Phone app installed, Xcode prepared; no commit, push or merge.
