# Codex review of guest-mode switch (step 3)

- Recorded: 2026-10-25 19:14:23 +11:00; Australia/Sydney
- Agent / role: Codex, reviewer
- Status: completed — read-only review; changes requested
- Base revision and branch: `c5124f2a6bb4173248fc8d4df8a9f6b39caa2b14` on `codex/guest-mode-switch`, compared with parent `e4984c4654afb7ea4fe17b3d580f75d9a94ced67`. Working tree clean.
- Related record / task / PR: [implementation record](2026-10-25-191257-claude-guest-mode-switch.md); [first-slice plan](../superpowers/plans/2026-10-25-first-slice-typed-capture-local-journal.md).

**Verdict: BLOCKS merge on the missing startup-isolation regression test required by the plan. Static tracing found no concrete cloud-construction leak or error-to-empty regression in this commit.**

## Request and scope

Reviewed only `git diff HEAD~1..HEAD`: `AppStartup.swift`, `CircleuApp.swift`, `GuestRootView.swift`, the `GuestJournalViewModel` change, `AppStartupTests.swift`, and the new implementation log.

Read required project/shared standards, log README/TEMPLATE, MVP decisions, first-slice plan and relevant preceding reviews. Surrounding code and build configuration were inspected only to trace dependencies and assess the changes. Local reads only; no network, builds or file writes.

## Work and outcome

### Severity-ranked findings

1. **Medium — Startup isolation is asserted as a Boolean, not tested through production composition. BLOCKS merge.**

   [CircleuTests/AppStartupTests.swift:16](</Users/tuannm3812/Documents/GitHub/3. Personal/CircleU/CircleuTests/AppStartupTests.swift:16>) checks `.guestJournal` and `configuresFirebase == false`. It never executes the startup/composition path in `CircleuApp` or opens `GuestRootView`. Moving Firebase configuration outside the guard, or adding a legacy store constructor to the guest root, would leave this test passing.

   The plan explicitly requires `testGuestStartupDoesNotConstructCloudServices`. The existing assertions meaningfully test routing policy, but do not provide that required protection.

   **Fix:** Exercise the production startup/composition boundary with observable dependency factories or equivalent instrumentation. Assert that guest startup opens its local dependency and invokes no Firebase configuration, analytics, legacy-store, backup or cloud factories. Include the switch-OFF case to verify existing initialization remains selected. Ensure the test fails if prohibited construction is introduced.

2. **Low — A test rejects the intended guest-enabled test configuration. Nonblocking.**

   [CircleuTests/AppStartupTests.swift:22](</Users/tuannm3812/Documents/GitHub/3. Personal/CircleU/CircleuTests/AppStartupTests.swift:22>) unconditionally expects the current process to select `.existingApp`. The shared scheme inherits launch arguments for tests, so enabling `-CircleUGuestMode` for development causes this assertion to fail even when routing works correctly.

   **Fix:** Remove this environment-dependent assertion or supply explicit arguments. Use a separate intentional guest-launch test for integration coverage.

### Requirement assessment

- **Default OFF / Release:** `CircleuApp` calls the resolver without overriding `isDebugBuild`. Without the argument, it selects the existing app. The compiled Release default is `false`; checked-in Release configuration does not define `DEBUG`, and Archive uses Release. No user-facing toggle or alternative activation route was found. The injected `false` unit test does not independently validate a Release binary.
- **Guest construction:** The traced path is `CircleuApp` → `GuestRootView` → guest location/shared registry → SwiftData container/context → `GuestJournalViewModel` → journal view. SwiftData explicitly uses `cloudKitDatabase: .none`. No legacy UserDefaults, analytics, backup or cloud-service construction was found along that path.
- **Other launch work:** No app delegate adaptor or separate app-owned launch hook was found. Legacy state objects, `@AppStorage`, environment objects and backend wiring belong to the unselected `ContentView`; backup callbacks belong to its `RootView`. App-owned global/static declarations revealed no eager cloud initializer reached by guest startup. This is source evidence, not verification of linked SDK runtime behavior.
- **Switch OFF:** The existing Firebase configuration and analytics assignment retain their order, followed by the unchanged `ContentView`. No source-level behavior regression was identified.
- **Errors:** Open failures select the root’s failed phase. Fetch failures remain `loadState.failed`, which the journal view renders separately from `.loaded([])`. The existing ViewModel failure test covers failed loading; the new message test checks wording only, not root rendering or retry behavior.

## Verification

- Inspected the complete latest-commit diff, dependency construction, launch hooks, configuration and relevant existing tests.
- `git diff --check HEAD~1..HEAD`: passed.
- `git status --porcelain=v1`: clean; final HEAD unchanged.
- Git returned results despite denied temporary-cache warnings.
- **Reported evidence:** Claude reports 123 tests passed, one device-only test skipped, and Simulator screenshots with and without the switch. Not independently verified.
- Not run / limitations: no build, tests, Simulator, Release binary inspection, network observation or physical-device validation. No files written.

## Discussion and decisions

None. No direct inter-agent exchange occurred. Claude’s results came from the user and implementation record.

The merge blocker is a missing explicitly required regression guard, not a demonstrated privacy leak.

## Handoff

- Remaining work: Add the production startup-isolation test, address the environment-dependent assertion, and record verification against the revised commit.
- Owner: Unassigned for implementation; Mike for merge decision.
- Risks / unresolved questions: Runtime network silence and physical-device protection remain unverified; screenshots do not establish either.

## Correction reference (if applicable)

The [implementation record’s verification claim](2026-10-25-191257-claude-guest-mode-switch.md) needs qualification: `AppStartupTests` checks routing decisions, not actual Firebase-free startup construction or an executed Release build. Historical records remain unchanged.