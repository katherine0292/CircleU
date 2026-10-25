# Owner decisions on audit, sign-in hint and tests

- Recorded: 2026-10-25 11:05:00 +11:00; Australia/Sydney.
- Agent / role: Claude (Claude Code).
- Status: completed.
- Base revision and branch: `codex/onboarding-content-trim` (PR #2); test changes on `codex/ci-signing-fix` (PR #3).
- Related record: [CI repair, audit and Today prep](2026-10-25-105045-claude-ci-audit-today-prep.md).

## Request and scope

After Claude's recommendation cards, the owner's choices were relayed through the project coordinator. This entry records them; no app behaviour changed on this branch.

## Decisions

| Topic | Owner decision | Where applied |
| --- | --- | --- |
| QA export test expected 24 characters | Fix the test to 23 | PR #3 |
| Display name after account deletion | Stays blank; update the test, not the app | PR #3 |
| Fixed-size "CircleU" logo text | Keep as branding; accepted audit exception | [QA review](../qa/native-onboarding-final-review-2026-10-25.md), [flow checklist](../product/flow-status-checklist.md) |
| Used Google? on Log in | Keep it off; Account help only after a failed login; Google/Apple sign-in deferred | [Account onboarding](../design/account-onboarding.md#concise-copy-pass--25-october) |
| PR #2 copy pass | Unmerged until the owner checks it on the phone | — |

## Verification

With both test updates and the CircleStore fix, `xcodebuild test` of `Circleu` passed locally (95 tests; Xcode 27.1, iPhone 17 / iOS 26.5 Simulator, CI signing config). The PR #3 CI result is reported separately. Docs: links and `git diff --check` checked.

## Discussion and decisions

None between agents; decisions came from the owner via the coordinator relay.

## Handoff

- Remaining work: owner's phone check of PR #2; Today walkthrough.
- Owner: Mike.
