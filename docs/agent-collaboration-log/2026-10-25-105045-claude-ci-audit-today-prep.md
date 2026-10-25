# CI repair, accessibility audit and Today review prep

- Recorded: 2026-10-25 10:50:45 +11:00; Australia/Sydney.
- Agent / role: Claude (Claude Code).
- Status: partial. Audit and Today prep done; the CI PR is awaiting an owner decision.
- Base revision and branch: main `81ed9af`; `codex/onboarding-content-trim` (PR #2) and `codex/ci-signing-fix` (PR #3).
- Related record: [main merge and copy trim](2026-10-25-090633-claude-main-merge-content-trim.md).

## Request and scope

Mike asked why VoiceOver is needed and said "ok follow u" to the suggested next steps: fix CI, run an accessibility pass and prepare the Today review. The coordinator's brief set the scope: merge the CI fix only if green, an automated audit with the full VoiceOver pass deferred to before release, and a Today walkthrough script. No production feature work.

## Work and outcome

- **CI (PR #3, not merged):** the workflow now generates the git-ignored `Config/Signing.xcconfig` from the example, builds unsigned, and picks the newest Xcode and an available iPhone simulator. The build then compiled, but the app aborted at launch: `CircleStore` called `Firestore.firestore()` without Firebase configured. A small app fix gates it on `FirebaseRuntime.canUseLiveFirebase`, matching the auth/sync/analytics pattern. Locally, 93 tests pass and 2 fail on existing assertions (a QA export `char_count` expecting 24 for a 23-character string, and the display name after account deletion, "" versus "Friend"). Those were never reached before because the app couldn't launch. PR #3 isn't merged: CI isn't green and it now includes app code.
- **Audit (PR #2):** the CircleU Preview host gained review-only fixture launch arguments. `performAccessibilityAudit()` ran on 26 states at default and largest text. Hit-area findings on quiet links were fixed; there were no contrast findings on the review host; the old 1.09:1 reading is explained as a ~5% blue tint over ice and wasn't reproduced. The fixed-size wordmark is the only remaining finding (logo exception, owner decision). Details are in the [onboarding review](../qa/native-onboarding-final-review-2026-10-25.md#automated-accessibility-audit-after-the-copy-trim-claude-25-october). The full manual VoiceOver pass is deferred to before release in the [flow checklist](../product/flow-status-checklist.md).
- **Today prep:** a [walkthrough script](../design/today-walkthrough-script-2026-10-25.md) for the five worksheet tasks, plus copy-trim suggestions for Today, Journal and Practice (proposal only, not applied).

## Verification

- `xcodebuild test` of `Circleu` with the CI config (Xcode 27.1, iPhone 17 / iOS 26.5 Simulator): app launches, 93 passed, 2 failed as above. Before the fix: `Test crashed with signal abrt`, with a crash report pointing to `+[FIRFirestore firestore]` from `CircleStore.init`.
- The audit ran via an out-of-repo XCUITest runner on the iPhone 18 Pro / iOS 27.0 Simulator; Simulator text size restored afterwards; the largest-text screenshot confirmed scaling.
- Not run: manual VoiceOver; phone check of PR #2 (phone locked at install).

## Discussion and decisions

None between agents. Owner decisions are needed on PR #3's two failing tests and on merging its app fix, the wordmark Dynamic Type exception, PR #2 copy, and the Today copy suggestions after the walkthrough.

## Handoff

- Remaining work: decide the two test expectations, then rerun CI on PR #3; Mike's phone review of PR #2; run the Today walkthrough using the script.
- Owner: Mike.
- Risks: CI on main stays red until PR #3 lands.
