# Guest UI tests in the repo; every story criterion has a test

- Recorded: 2026-10-26 12:10:00 +11:00; Australia/Sydney
- Agent / role: Claude Code (implementer), on Mike's Mac
- Status: completed; merged under the auto-merge rule
- Base revision and branch: `codex/ui-tests-in-repo` from `main` at `c641f91`
- Related record / task / PR: coordinator brief: "move the out-of-repo UI tests into the repo and close the 9 untested criteria, starting with reset password"

## Work and outcome

- **`CircleuUITests` target and scheme:**
  - The 7 guest UI test files moved from my local runner into the repo, plus new `GuestStatesUITests`.
  - Screenshots and audit findings are kept as test attachments.
  - The live Firebase Dev test only runs when `TEST_RUNNER_CIRCLEU_LIVE_DEV=1` is set.
- **Each UI test starts empty:** the Debug-only `-CircleUResetGuestData` removes the guest journal folders, the Welcome flag and the chosen Pingu before the store opens. It is guest mode only, and Release never has it.
- **New tests for the gaps:**
  - UI: Welcome only once; the empty Journal, Practice and calendar day; the privacy summary and Learn more; your Pingu kept across launches; the picker stopping dictation.
  - Unit: reset password (the same answer whether or not an account exists, and nothing shown as sent when offline), a failed backup copy, and Export done.
- **Small refactor:** the reset-password logic moved out of the view into `GuestPasswordResetModel`, and `LiveGuestAccountService.passwordResetError` holds the "no such account looks like success" rule. Behaviour is unchanged (Codex checked).
- **Bug found by the new month test and fixed:** inside the Journal list, one tap on Previous month, Next month or Go to today fired all three, so the month never changed. They now use `.borderless`.
- **[User stories](../product/user-stories.md):** 76 criteria; 64 with a unit test and 12 with only a UI test; none untested; 11 marked partial.

## Verification

- **Unit suite:** 248 passed, 0 failed, 1 skipped.
- **UI suite (`CircleuUITests`):** 13 passed, 1 skipped (live Dev, opt-in).
- **Not run:** a phone check (no on-screen change except the calendar arrows now working); CI (manual).

## Discussion and decisions

**Codex** ([log](2026-10-26-120500-codex-review-ui-tests.md)):
- **First pass**, 4 blockers, all in the tests, all fixed:
  - shared simulator state;
  - Welcome Continue never tapped;
  - month navigation never exercised;
  - the denial state not established.
- **Second pass:** no blockers.
- **Not done (minor):** reporting reset failures, and a positive current-month check (the journal list also shows the month name).
- Speech-recognition access can't be reset from XCUITest, so the denial test accepts an earlier denial without a new prompt. It still requires the denial-only message and Open Settings.

## Handoff

- Next: Today option B (Mike picked "B now, A and C after the art").
