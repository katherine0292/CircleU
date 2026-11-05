# Replace the guest app artwork with Tuanwei the otter

- Recorded: 2026-11-06 16:30:00 +11:00; Australia/Sydney
- Agent / role: Claude Code (desktop app, Katherine's Mac), implementation
- Status: completed
- Base revision and branch: `codex/otter-artwork` from `main` at `c7094c3` (Katherine's fork)
- Related record: image requirements list (Google Doc 「CircleU 图像需求清单」, 6 November); [previous entry](2026-11-05-233000-claude-ai-fallback-reason.md)

## Request and scope

Katherine made all 61 guest images with her own character, Tuanwei the otter, and asked for them to be put in the app. Files: the 61 image sets (the app icon then had its green background replaced with white) in `Circleu/Assets.xcassets` (same names), `Circleu/Features/GuestJournal/GuestPinguArt.swift` and `GuestFindAndControl.swift` (VoiceOver names and avatar wording), `CircleuUITests/GuestPolishUITests.swift`, `GuestTodayUITests.swift` and `GuestStatesUITests.swift` (the same strings), `docs/product/user-stories.md` (S4).

## Work and outcome

- Every image set keeps its name, so no screen code changed. 17 icons are resized to 56 and 84 px (@2x/@3x, 28 pt, as before), because the tab bar and some buttons draw them at their natural size. The 21 avatars are resized to 512 px. Context tags, moods, scenes, Welcome images and the app icon are copied as delivered.
- VoiceOver names follow Katherine's delivery notes, e.g. "Tuanwei the otter holding a warm mug". Two poses changed meaning: Thoughtful is now examining a pebble, ThumbsUp is holding a rolled map.
- On-screen wording: "Your Pingu" → "Your otter", "Choose your Pingu" → "Choose your otter".
- Not changed: asset names still contain "Pingu" (renaming would touch code and saved choices); the legacy app's Pingu art and text; the unused guest images and legacy `Pingu*` sets.

## Verification

- `xcodebuild build` (scheme CircleU Guest Review, iPhone 17 Pro Simulator, iOS 26.5): succeeded with no asset warnings.
- Simulator check by screenshot: Today scene, Journal empty scene, tab icons, top-bar avatar and the avatar picker show the new art.
- `xcodebuild test`, same Simulator, separate derived data: `GuestPolishUITests` and `GuestTodayUITests` 4 passed, 0 failed; `GuestPinguArtTests` and `GuestCopyLintTests` 3 passed, 0 failed. The full unit and UI suites were not run.
- Not checked: Welcome pages (the UI test mode skips them), Practice and Settings screens, dark mode, accessibility text sizes, a physical iPhone.

## Discussion and decisions

None.

## Handoff

- Remaining work: Katherine to look through the screens; full test run before merging.
- Owner: Katherine
- Risks / unresolved questions: the Welcome images are 2:3 instead of the old taller shape; check that the bottom fade still covers the edge.
