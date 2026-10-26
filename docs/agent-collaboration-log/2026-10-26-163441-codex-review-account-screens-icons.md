# Codex review and checks: account screens icons

- Recorded: 2026-10-26 16:34:41 +11:00; Australia/Sydney
- Agent / role: Codex (gpt-6-astra, high, read-only reviewer), run by Claude Code; Claude Code ran the suites and applied fixes
- Status: completed
- Base revision and branch: reviewed `81baf0f` on `codex/account-screens-icons` against `origin/main`; fixes in `7d0ddd9`
- Related record / task / PR: none (no PR opened)

## Request and scope

Build and test the branch, keep the GuestImportUITests screenshots, check largest text, and run one review-only Codex pass. A follow-up from the coordinator asked for the three copy fixes below. No merge, PR or device install.

## Work and outcome

**Codex findings at `81baf0f`.** Blockers:

1. **"N already here" overstated presence.** [GuestSignIn.swift](<../../Circleu/Features/GuestJournal/GuestSignIn.swift>) counts import receipts (`isImported`), which outlive local deletes. Claude confirmed this in the store code. Fixed: "N already copied".
2. **The "Deleted" card showed before anything was deleted**, against the guideline that reserves "Deleted" for success. Fixed: "Will be deleted", with matching updates to [screen guidelines](<../design/screen-content-guidelines.md>) and [user stories](<../product/user-stories.md>) S8.1.

Non-blockers (not fixed):

- `has(app, "Signed out")` also matches "Signed out after", so it doesn't prove the completed-state chip.
- The preview's (i) "What isn't copied" sheet is only checked for existence; it is never opened.
- `audit()` swallows every issue, and no test runs at AX5.

Codex found no new account-existence disclosure and no upload or sync implication. The info button has a VoiceOver label and a 44×44 target.

**Also fixed (from screenshot review).** Inside "Left out (N)" in the backup preview and on Copied, the list no longer repeats a "Left out" heading. `GuestImportView.leftOut(_:heading:)` keeps the heading by default, so the sealed on-device import screen is unchanged. The UI test now asserts "Will be deleted".

**Screenshots** are in [account-screens-icons-2026-10-26](<../qa/screenshots/account-screens-icons-2026-10-26/>): s1 to s6 after the fixes on an iPhone 18 Pro Max, iOS 27.0, plus `ax5-*` at Accessibility XXXL. The chips fit, nothing is clipped, the info sheet opens, and the Will be deleted and Stays cards sit side by side. At AX5 the chips and cards stack, and the sheet scrolls.

## Verification

- `xcodebuild test -scheme Circleu`, `CODE_SIGNING_ALLOWED=NO`, CI-style unsigned `Config/Signing.xcconfig` (iPhone 18 Pro Max, iOS 27.0, after fixes): **253 passed, 0 failed, 1 skipped**. The same result came from `81baf0f` on an iPhone 17 Pro, iOS 26.5.
- `xcodebuild test -scheme CircleuUITests` after fixes: **14 passed, 1 failed, 1 skipped** (live Dev, opt-in). The failure is `GuestVoiceTabsUITests.testTabsPracticeAndDictationDenied`. These simulators report on-device dictation as unavailable, even with `-testLanguage en -testRegion US`, so no permission prompt appears. The same failure occurs on `origin/main` (see [2026-10-26-160000](<2026-10-26-160000-claude-practice-visual.md>)) and at `81baf0f` on both runtimes, so this branch doesn't cause it.
- AX5: I ran a temporary, uncommitted UI test with `-UIPreferredContentSizeCategoryName UICTContentSizeCategoryAccessibilityXXXL` over Log in, its info sheet and Delete my account. It passed and produced the `ax5-*` screenshots.
- Not run / limitations: VoiceOver interaction, physical device, the live Dev test.

## Discussion and decisions

Codex reviewed and Claude verified the blockers against the code. The coordinator asked for the three fixes. The owner made no decisions in this entry.

## Handoff

- Remaining work: the Codex non-blockers (exact "Signed out" assertion, open the preview info sheet in the test, an AX5 test in the suite); make the dictation-denied test independent of on-device speech availability.
- Owner: Unassigned
- Risks / unresolved questions: the dictation-denied UI test will keep failing on these simulators until it is made independent of on-device speech availability.
