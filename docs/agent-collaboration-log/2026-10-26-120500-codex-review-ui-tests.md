# Codex reviews: UI tests in the repo and test gaps

- Recorded: 2026-10-26 12:05:00 +11:00; Australia/Sydney
- Agent / role: Codex (gpt-6-astra, high, read-only reviewer), run by Claude Code
- Reviewed: `35e60d4`, then the fix `bd02610`, on `codex/ui-tests-in-repo`

## First pass (35e60d4)

Reviewed `35e60d4`. **Changes requested for test reliability and coverage claims.** I found no production regression in the reset refactor or startup guard.

**Blockers**

1. **UI tests depend on leftover simulator data.** There is no common setup/cleanup for journal data, drafts, or preferences. The Pingu test and permission-denial test leave unsaved Today drafts, while [GuestFlowUITests.swift:27](<CircleuUITests/GuestFlowUITests.swift:27>) assumes an empty editor. Running that test after either can fail despite correct app behaviour. Serial execution prevents simultaneous interference, but does not provide isolation. Establish fresh test-owned state before each test, preserving it only for that test’s relaunch checks.

2. **W2.2’s only mapped test bypasses the behaviour it claims to verify.** [GuestImportUITests.swift:47](<CircleuUITests/GuestImportUITests.swift:47>) never taps **Continue** after copying. It terminates the app and forces `welcomeSeen=YES`, so a broken Continue action passes. Its “already copied before” branch also allows skipping copying entirely. W2.1’s **Continue without logging in** control is never asserted. Exercise those paths explicitly or mark the mappings incomplete.

3. **J3.2 never starts from another month.** [GuestFindControlUITests.swift:46](<CircleuUITests/GuestFindControlUITests.swift:46>) checks that Previous month exists, but never taps it. Removing the month-reset assignment from Go to today would leave this test passing. Navigate away and assert the displayed month returns correctly.

4. **The permission-denial test does not establish denied permission.** [GuestVoiceTabsUITests.swift:30](<CircleuUITests/GuestVoiceTabsUITests.swift:30>) accepts zero permission prompts and only checks text containing “keep typing.” An unrelated unavailable-speech state can pass; previously granted permissions can make it fail. Reset/control microphone and speech authorization, and assert the denial-specific message and Settings action.

**Minor notes**

- **Other mappings overstate their UI evidence:**

  | Criterion | What the test actually establishes |
  |---|---|
  | T2.1 | `GuestFlowUITests` saves before relaunch; it never tests an unsaved draft surviving. The separate unit test remains applicable. |
  | J1.1 / P2.1 | Empty-state text is asserted; Pingu artwork is not. Screenshots are attachments, not assertions. |
  | J2.2 | Checks “No entries match,” but not the echoed search term. |
  | S4.1 | Opens the picker and selects one avatar; does not verify all 21 rendered choices and spoken names. |
  | S4.3 | Checks dictation stopped after dismissing the picker, not immediately when it opened. |
  | S8.1 | UI checks success wording, but does not inspect retained local entries or deletion-disclosure text. |
  | S5.2 | Opt-in live test makes one invalid login attempt; backoff remains unit-test evidence. |

- **New unit tests:** S5.4 now exercises the correct `GuestSignInViewModel.copy()` failure path and checks the message, sign-out, and empty journal. Its throwing store does not establish real transaction rollback. S2.3 correctly verifies the model’s sharing/cleanup decision and is appropriately marked partial. S7.2 checks error state and absence of success. S7.1 checks fake success and the extracted error policy separately; it does not test Firebase-error conversion through the service or the displayed success sentence. Broaden its partial-coverage explanation.

- **False-positive selectors:** [GuestFlowUITests.swift:57](<CircleuUITests/GuestFlowUITests.swift:57>) accepts any entry containing `(edited)`, including an earlier run’s entry. The three-entry relaunch test uses overlapping substring expectations: `Spoken words <tag>` also matches `Spoken words <tag> plus typing`. Use unique, exact expectations and verify distinct entries.

- **Date/locale/timing:** The empty-day test sensibly avoids crossing the month boundary on day one, but samples `Date()` after saving. Crossing midnight can make its chosen “empty” day contain the saved entry. Locale-sensitive date labels and English system-button labels also depend on runner/device configuration. Fixed sleeps and positional selectors add fragility.

- Accessibility audits suppress failures with `try?` and mark issues handled. They collect diagnostics; they do not enforce accessibility acceptance.

**Checks that passed**

- Parsed the project and both schemes: **48 unique objects, no unresolved IDs**, consistent UI-target references, correct UI-testing product type and app dependency, synchronized source membership, and `TEST_TARGET_NAME=Circleu`.
- Existing app/unit-target build settings are semantically unchanged; the original unit-test scheme is byte-for-byte unchanged. The UI scheme tests Debug, disables test parallelization, and excludes the UI-test bundle from archiving.
- Reset handling preserves `.couldNotLogIn → success`, offline/throttling errors, and generic remaining failures. Firebase `userNotFound` still maps to `.couldNotLogIn`; no new account-existence disclosure was introduced. The model additionally guards duplicate sends and clears stale errors.
- `-CircleUResetWelcome` is compiled only under `DEBUG` and requires guest startup. Release has no `DEBUG` definition; legacy startup cannot execute the reset.
- Coverage arithmetic matches: **25 stories, 76 criteria; 64 with unit tests, 12 UI-only, 12 unit-plus-UI, 7 marked partial**. These are mapping counts, not proof of complete coverage. All 95 fully qualified test references resolve. Whitespace checks passed.

No files were edited. Builds, XCTest, simulator interactions, and Release archive verification were not run in this read-only environment.

## Second pass (bd02610)

Reviewed `bd02610` against `35e60d4`.

**Blockers:** None found in this source review. All four previous blockers are addressed:

- Every UI test’s initial launch resets guest data; persistence checks relaunch without resetting.
- [Welcome coverage](<CircleuUITests/GuestImportUITests.swift:25>) now requires copying, taps Continue, and asserts Today opens.
- [Calendar coverage](<CircleuUITests/GuestFindControlUITests.swift:43>) now moves to the previous month before tapping Go to today.
- [Permission coverage](<CircleuUITests/GuestVoiceTabsUITests.swift:17>) resets microphone authorization and requires the exact denial message plus Open Settings. Accepting an existing speech denial without another prompt is appropriate.

The [reset](<Circleu/App/CircleuApp.swift:16>) is compiled out of Release and gated on `.guestJournal`, so the legacy startup path cannot execute it. It runs before the guest store opens and targets only:

- Application Support/GuestJournal
- Application Support/GuestJournalSetup
- `circleu.guest.welcomeSeen.v1`
- `circleu.guest.avatar.v1`

The [borderless styles](<Circleu/Features/GuestJournal/GuestFindAndControl.swift:65>) correctly override List’s contextual automatic button behavior on all three controls. This matches [Apple’s documented style mechanism](https://developer.apple.com/documentation/swiftui/primitivebuttonstyle/automatic). Existing labels, colors, arrow dimensions, actions and day-button styling remain intact. No additional regression is apparent from source inspection; visual equivalence is unverified.

**Minor notes:**

- Reset errors are silently discarded with `try?`. Reporting failures other than missing folders would prevent an unsuccessful reset from quietly retaining test data.
- The calendar test should positively assert the current month after Go to today; currently it only asserts the previous month disappeared. Next month also remains untested.

`git diff --check HEAD~1 HEAD` passed; the workspace is unchanged. Builds, unit/UI tests and simulator/device visual checks were not run in this read-only environment.