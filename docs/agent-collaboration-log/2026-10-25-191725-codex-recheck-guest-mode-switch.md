# Codex re-check of guest-mode switch (step 3)

- Recorded: 2026-10-25 19:17:25 +11:00; Australia/Sydney
- Agent / role: Codex, reviewer
- Status: completed — read-only review; changes requested
- Base revision and branch: `774be72049c0d73b9b820460506048b8f59fd26a` on `codex/guest-mode-switch`, compared with parent `c5124f2a6bb4173248fc8d4df8a9f6b39caa2b14`. Working tree clean.
- Related record / task / PR: [previous review](2026-10-25-191423-codex-review-guest-mode-switch.md); [first-slice plan](../superpowers/plans/2026-10-25-first-slice-typed-capture-local-journal.md).

**Verdict: Finding 1 remains partially unresolved and BLOCKS merge. Finding 2 is fixed. No new defects identified.**

## Request and scope

Re-check only `git diff HEAD~1..HEAD`, with surrounding files and required documentation for context. Local Git/file reads only; no network, builds, tests or file writes.

## Work and outcome

1. **Medium — Finding 1 partially addressed.** `CircleuApp.init` and the tests now call the same `AppBootstrap.run(for:)`. Moving either injected callback above its guard would make the guest assertion fail; adding duplicate callback invocations on the existing path would fail its exact-order assertion. This meaningfully improves the previous Boolean-only coverage.

   However, [AppStartupTests.swift:23](../../CircleuTests/AppStartupTests.swift) constructs a replacement bootstrap and observes only its two callbacks. It does not execute `AppBootstrap.live`, `CircleuApp.init`, or guest-root composition. Moving the actual Firebase setup into the `live` getter or directly into the app initializer would bypass those observations. Adding a legacy store, backup or cloud constructor to `GuestRootView` would also leave these assertions unchanged.

   The plan and previous finding require guest composition coverage, including opening its local dependency without prohibited construction. That portion remains absent. Extend the exercised production composition boundary and observable factories to cover local opening and prohibited service construction. No actual cloud leak was identified in this revision.

2. **Low — Finding 2 fixed.** The process-dependent `testThisTestRunStartsTheExistingApp` assertion is removed. Both new tests supply explicit arguments and build mode, so inherited guest launch arguments cannot alter their routing expectations.

## Verification

- Inspected the complete latest-commit diff and relevant startup/composition code.
- `git diff --check HEAD~1..HEAD`: passed.
- `git status --porcelain=v1`: clean; HEAD unchanged. Git returned results despite temporary-cache warnings.
- **Reported evidence:** Claude reports 124 tests pass locally; not independently verified.
- Not run / limitations: no builds, tests, mutation checks, Simulator or physical-device validation. Expected regression-test behavior above is static analysis. No files written.

## Discussion and decisions

None. No direct inter-agent exchange occurred; Claude’s test result was supplied by the user.

## Handoff

- Remaining work: Complete finding 1’s production composition regression coverage.
- Owner: Unassigned for implementation; Mike for merge decision.
- Risks / unresolved questions: Callback isolation is covered; guest-root construction isolation remains untested.