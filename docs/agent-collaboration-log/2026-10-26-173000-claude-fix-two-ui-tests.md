# Fix the two UI tests that failed on main

- Recorded: 2026-10-26 17:30:00 +11:00; Australia/Sydney
- Agent / role: Claude Code (implementer), on Mike's Mac
- Status: fixed; local unit and UI suites run (results in the PR)
- Base revision and branch: `codex/fix-two-ui-tests` from `main` at `7f326bb`
- Related record / task / PR: the two failures noted in [2026-10-26-160000 practice visual](2026-10-26-160000-claude-practice-visual.md), [account screens review](2026-10-26-163441-codex-review-account-screens-icons.md) and [settings icon rows](2026-10-26-160000-claude-settings-icon-rows.md)

## Root causes

- `GuestSuggestionUITests.testReflectionNextStepAndPracticeSuggestions` (T6.2): after the Today option B redesign, "Add this step" sits under the pinned Save reflection button and the floating tab bar. XCTest's `isHittable` is still true there, so the test didn't scroll, and its tap landed on the tab bar's Journal tab, which popped back to the Journal list. The app was right; the test's scrolling was stale.
- `GuestVoiceTabsUITests.testTabsPracticeAndDictationDenied` (T4.1): Simulators have no on-device speech model, so `SpeechDictationEngine.requestAccess()` correctly returns "on-device dictation isn't available" before asking for permission. The prompts and the denial message never appeared. This is environmental; the app is right.

## Changes

- Reflection test: scrolls until "Add this step" is above the Save reflection button, asserts that, and asserts the review is still open after adding the step. No assertion removed.
- Dictation: `SpeechDictationEngine(assumesOnDeviceSupport:)`, set only in Debug by the `-CircleUAssumeOnDeviceSpeech YES` launch argument (same pattern as `CircleUScriptedDictation`). It skips only the on-device support check, so the test reaches the real system Speech Recognition prompt, denies it and checks the denial message and Open Settings. Release builds and real devices are unchanged. Story T4.1 notes the argument.
