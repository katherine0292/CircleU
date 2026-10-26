# Visual Today: badge fix, merge check, phone install and handoff to Codex

- Recorded: 2026-10-26 19:30:00 +11:00
- Agent / role: Claude Code (on the Mac), implementer
- Status: handoff
- Base revision and branch: `026f416` (main after PR #34); this entry on `codex/agent-log-visual-today-handoff`
- Related record / task / PR: [previous entry](2026-10-26-170500-claude-visual-today-art.md); PR #34 (`codex/visual-today-journal`, merged); [asset expansion 02 prompts](../design/brand-demo/asset-expansion-02-prompts.json)

## Request and scope

After the [previous entry](2026-10-26-170500-claude-visual-today-art.md), the coordinator session relayed three tasks on `codex/visual-today-journal`: test the owner's "small Pingu badge on Today" choice (`337b1ab`), test the merge of main into the branch (`d185846`), then check Mike's iPhone and update CircleU Guest Test. Mike asked for this entry so Codex can continue.

## Work and outcome

- **Pingu badge (`1f23130`).** `337b1ab` called `GuestAvatarButton(beforeOpening:)`, which `fc9ba1a` had removed, so it didn't build. Fixes in [GuestPinguArt.swift](../../Circleu/Features/GuestJournal/GuestPinguArt.swift) and [GuestJournalScreens.swift](../../Circleu/Features/GuestJournal/GuestJournalScreens.swift):
  - The hook is back as `onChoose`.
  - Today presents the picker from a sheet on the whole write view. A sheet inside the card was lost when stopping the microphone re-laid out the card: the picker never opened while dictating (S4.3).
  - The badge is a 44-point circle 8 points into the card's corner, clear of the scene's Pingu (it was 52 points and covered the scarf).
- **Merge check.** `d185846` (main with PRs #33, #35 and #36 merged in) needed no fixes. Its tree is identical to `026f416`, so the results below cover current main.
- **Phone (iPhone 11 Pro Max).** The CircleU and preview-related apps were CircleU Guest Test, CircleU Preview (`com.tuannm3812.circleu.preview`, the Xcode Previews host) and two Apple "Xcode Previews" entries. There were no test runner leftovers, and the real TestFlight CircleU isn't installed on this phone.
  - On Mike's "go", I uninstalled CircleU Preview. Both Xcode Previews entries are untouched.
  - I updated Guest Test in place (no uninstall, so its entries are kept), built from `026f416` in a clean worktree, then launched it once.
- **How to update Guest Test** (from a clean `origin/main` worktree, with `Config/Signing.xcconfig` copied from the main checkout):
  1. `xcodebuild -project Circleu.xcodeproj -scheme Circleu -configuration Debug -destination generic/platform=iOS -allowProvisioningUpdates PRODUCT_BUNDLE_IDENTIFIER=com.tuannm3812.circleu.guesttest "INFOPLIST_KEY_CFBundleDisplayName=CircleU Guest Test" 'SWIFT_ACTIVE_COMPILATION_CONDITIONS=$(inherited) GUEST_JOURNAL_BUILD' build`
  2. Check that the built `Info.plist` bundle ID is `com.tuannm3812.circleu.guesttest`.
  3. Run `xcrun devicectl device install app --device <phone> <Circleu.app>`. Never uninstall first: that deletes the guest journal.

## Verification

- `1f23130` on an iPhone 17 Pro iOS 27.0 Simulator (CI signing config, `CODE_SIGNING_ALLOWED=NO`):
  - Unit suite: passed.
  - Full `CircleuUITests`: S4.3 passed and the Polish and Today accessibility audits found nothing. `GuestVoiceTabsUITests.testTabsPracticeAndDictationDenied` failed as on main before #36.
  - `GuestFindControlUITests` timed out once while the Mac was heavily loaded, then passed twice on its own.
- `d185846`, same setup:
  - Unit suite: 253 passed, 0 failed.
  - `CircleuUITests`: 18 tests, 1 skipped, 0 failures.
- Phone:
  - `devicectl device info apps` shows CircleU Guest Test and Xcode Previews as the only developer-built apps.
  - `devicectl device process launch` started Guest Test.
- Not run / limitations:
  - I took no screenshots on the phone.
  - Mike hasn't yet confirmed the new Today (logo, scene, badge) or that his entries are still there.
  - No VoiceOver pass.

## Discussion and decisions

- **Owner decisions** (relayed by the coordinator session): keep the chosen Pingu as a small badge on the Today scene that opens the picker; delete CircleU Preview but keep Xcode Previews; update Guest Test in place.
- **Agent exchanges:** the coordinator session wrote `337b1ab` and the merge `d185846`. I fixed `337b1ab` in `1f23130`. None otherwise.

## Handoff

- Owner: Codex, at Mike's request.
- Remaining work:
  1. Record Mike's phone check of Guest Test `026f416`: the logo at the top left, the ice-floe scene with the badge, the listening scene, chip icons, Journal's dusk empty state, and entries kept.
  2. Make guest builds identifiable. Every build reports 1.0.0 (1), so the phone can't show which commit is installed. For example, pass `CURRENT_PROJECT_VERSION` as a date-time stamp for Guest Test builds only.
  3. Add a largest-text-size test for T10.4 (the scene is left out, and the microphone, chips and badge stay). It currently has no test ([user stories](../product/user-stories.md)).
- Agent ideas, not approved by the owner (from the [previous entry](2026-10-26-170500-claude-visual-today-art.md)'s report):
  - change the scene with the time of day;
  - a short Pingu moment for "Saved";
  - a ripple around the microphone while listening (off with Reduce Motion);
  - the feeling icon on Journal's date tiles;
  - a Practice scene;
  - remove the glass circle behind the toolbar logo.
- Risks / unresolved questions:
  - On iOS 26 and later, the toolbar puts the logo in a glass circle, which can look tappable.
  - The dictation-denied UI test depends on the simulator: it passed in the last run, after #36.

## Correction reference (if applicable)

The [previous entry](2026-10-26-170500-claude-visual-today-art.md) says the Pingu is chosen in Settings only. The owner then chose the small badge on Today (`337b1ab`, fixed in `1f23130`), so Today and Settings both open the picker. The UI results in that entry (1 failure) are superseded by the `d185846` run above (0 failures).
