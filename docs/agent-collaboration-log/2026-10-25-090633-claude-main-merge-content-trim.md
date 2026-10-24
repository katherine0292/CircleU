# Main merge and concise onboarding copy

- Recorded: 2026-10-25 09:06:33 +11:00; Australia/Sydney.
- Agent / role: Claude (Claude Code).
- Status: main merge completed; copy pass proposed on a PR for owner review.
- Base revision and branch: `3f3abcc` (merged to main as `81ed9af`); new branch `codex/onboarding-content-trim`.
- Related record: [phone entry correction](2026-10-25-082500-claude-correction-phone-entry-log.md); [copy table](../design/account-onboarding.md#concise-copy-pass--25-october).

## Request and scope

The owner asked for suggestions, approved pushing to main, and asked for the onscreen content to be concise, keeping only what's necessary and referring to popular apps. The coordinator's brief turned this into a merge PR plus a separate copy-trim PR that the owner reviews before merging. Prototype copy only; no Today or production feature work.

## Work and outcome

- Opened PR #1 (`codex/journal-calendar-planning` → `main`) and merged it with a merge commit as `81ed9af`. CI `Build and Test` failed with `Unable to open base configuration reference file Config/Signing.xcconfig`. That file is a git-ignored per-developer config already referenced by main's project. Main's CI push runs had already been failing since at least June, and the PR did not touch `Circleu.xcodeproj` or `Config/`. A local Simulator build of the `Circleu` scheme succeeded (Xcode 27.1, build only, nothing installed or launched). The CI fix is not done.
- Trimmed copy in `BrandOnboardingPreview.swift` and `BrandRecoveryPreview.swift`; see the before/after table in [account onboarding](../design/account-onboarding.md#concise-copy-pass--25-october). Removed duplicated placeholders, the Used Google? and Continue locally links on Log in, duplicate "Back to…" links and multi-card explanations. Account help moved to the failed-login state. Added a matching rule to the [content standard](../design/content.md) and a pointer in the [flow checklist](../product/flow-status-checklist.md).
- Regenerated the four committed recovery boards (`brand-09-errors`, `-login-compact`, `-password`, `-recovery`). The renderer isn't pixel-deterministic, so the other unchanged boards were not replaced.

## Verification

- iPhone 18 Pro / iOS 27.0 Simulator: an out-of-repo XCUITest runner drove CircleU Preview (Log in, validation, Privacy, reset, Check your email, login → checking → Earlier data → Opening, Back → Welcome) and the existing motion Simulator host with fixture/scenario arguments: Welcome guest route, Privacy → Earlier data, New password mismatch/completion, expired/invalid link, login error → Account help, offline, backup error/retry, no backup, reset error, recovery selection validation and error. All four test cases passed. One run failed in the test itself: it typed onto the email that Log in deliberately keeps after a reset. The test was fixed to relaunch.
- Phone: trimmed host built, signed and installed on the iPhone 11 Pro Max; launch was refused while the phone was locked. No phone observation of the new copy yet.
- Not run: VoiceOver/large-text pass of the trimmed screens, Inspector re-audit, full-app tests.

## Discussion and decisions

None between agents. Owner decisions needed are listed in the handoff.

## Handoff

- Remaining work: owner review of the copy PR on phone or Simulator; CI repair (Signing.xcconfig in CI, Xcode/destination) as a separate task.
- Owner: Mike for copy approval and the decisions below; CI repair unassigned.
- Decisions: (1) Privacy card wording is shorter but still makes data claims, so check it reads accurately. (2) Account help is now only reachable after a failed login; earlier Google users get no hint up front. (3) Log in subtitle kept as "Use your earlier CircleU account." rather than "Restore data from…", because logging in alone doesn't import.
