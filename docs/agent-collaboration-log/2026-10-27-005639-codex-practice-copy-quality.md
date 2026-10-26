# Practice copy status and guest interaction checks

- Recorded: 2026-10-27 00:56:39 +1100; Australia/Sydney
- Agent / role: Codex, implementer
- Status: completed — source fix and Simulator verification
- Base revision and branch: `50377aa`, `codex/guest-quality-fixes`; this entry accompanies the fix commit
- Related: [design handoff](2026-10-26-193014-claude-to-codex-design-pass-handoff.md), [Figma copy handoff](2026-10-26-210850-claude-to-codex-figma-copy-handoff.md)

## Request and scope

The owner asked to update, fix bugs and improve the app after connecting the UTS Figma file. Preserve the approved layout, branding, guest-first direction and existing data. This batch fixes a reproducible Practice confirmation bug and covers previously incomplete interaction checks. No Firebase, migration, identity, asset or design changes.

## Work and outcome

- Verified Figma access to [CircleU Design](https://www.figma.com/design/rfknpmLIXsOxA7fHUQQMtR); inspected the Screens and options metadata. The file contains implemented screens and proposals; no design was edited or treated as approval for new features.
- Refreshed remote references and created an isolated worktree from current main. The original checkout and its two untracked Codex logs are preserved.
- Practice kept showing Copied after typing, clearing wording or Undo. The clipboard still held the previous wording. A wording observer now clears the confirmation whenever its text changes; Copy remains explicit and never saves or sends.
- Added three unit regressions and a UI journey covering Copy, manual edits, Keep editing, Discard, Save and reopening without a duplicate.
- Added a largest-Dynamic-Type Today journey through the Pingu picker, starter prompt, writing and saving. This is not a hardware keyboard or VoiceOver certification.
- Updated [user stories](../product/user-stories.md) and recounted the criteria. No new feature or visual direction was introduced.

## Verification

Simulator: iPhone 18 Pro, iOS 27.0, UUID `C7B63706-4D1C-4B7F-A161-8A2339D14E2B`; Xcode at `/Applications/Xcode.app/Contents/Developer`.

Command base: `DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer xcodebuild test -project Circleu.xcodeproj -destination 'platform=iOS Simulator,id=C7B63706-4D1C-4B7F-A161-8A2339D14E2B' -derivedDataPath /tmp/circleu-quality-derived CODE_SIGNING_ALLOWED=NO PRODUCT_BUNDLE_PREFIX=com.circleu.quality`, with the scheme/options below. Ignored signing configuration copied from the example; no personal signing material used.

- Baseline, `-scheme Circleu`: 253 unit tests passed.
- Regression reproduction, `-scheme Circleu -only-testing:CircleuTests/GuestPracticeViewModelTests`: all three new cases failed against the unchanged implementation; existing cases passed.
- After fix, `-scheme Circleu`: 256 unit tests passed.
- First focused UI run: copy state and discard worked, Today passed. Practice's final assertion failed because the test assumed tapping the text editor placed the cursor at the end. The recorded accessibility tree showed the new text saved at the beginning instead. The test now captures and asserts the actual entered text before saving, then compares the reopened value; no product workaround.
- Inspected Today screenshots: large-text layout omits decorative scene and keeps the avatar/microphone. Refined the prompt test to check its full lower bound above Save, rather than relying only on isHittable. Software keyboard was not visible in these screenshots; no software-keyboard layout pass is claimed.
- Full `-scheme CircleuUITests`: 20 tests executed, 19 passed, 1 deliberately skipped (live Firebase), 0 failures; exit 0. Final result: `/tmp/circleu-quality-derived/Logs/Test/Test-CircleuUITests-2026.10.27_00-54-56-+1100.xcresult`. Inspected the final Today prompt and writing screenshots; the complete selected prompt is above Save and readable after scrolling.
- `git diff --check`: passed. Remote main still matched the tested base `50377aa` before publishing.
- Not run: physical-device checks, real VoiceOver speech/gestures, live Firebase, migration/upgrade testing, CI or TestFlight. No phone app was uninstalled or updated.

## Discussion and decisions

Actual review: Codex requested a read-only `gpt-6-astra` high-effort review through subagent `quality_fix_review`, as specified by the project workflow. The reviewer inspected the four changed Swift files and reported no blockers; it did not run tests. It noted that scene visibility needs screenshot evidence. The UI-only cursor assertion and prompt-bound check were refined after that review; production code is unchanged since review.

## Handoff

- Remaining work: the owner’s phone walkthrough of the latest guest build, then any separate design improvements chosen from the handoff. Hardware keyboard/VoiceOver qualification remains separate.
- Owner: Codex for this batch.
- Limits: the guest experience remains behind its existing Debug switch; this is not a production local-only rollout. The latest phone build still needs its owner walkthrough. Figma and exported boards are design snapshots.
