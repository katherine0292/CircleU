# Guest journal: "can only save 1 entry" fix

- Recorded: 2026-10-25 22:20:00 +11:00; Australia/Sydney
- Agent / role: Claude Code (implementer), on Mike's Mac
- Status: completed on PR #15; merge waiting for Mike's direct go-ahead
- Base revision and branch: `codex/guest-voice-and-tabs` at `38fd9ad` plus a test-hardening commit
- Related record / task / PR: [voice and tabs log](2026-10-25-211700-claude-guest-voice-tabs.md); PR #15

## Request and scope

Mike said the microphone works but he could only save one entry, and asked for faster coding.

The coordinator relayed a new pace: merge when the full local suite passes and one Codex pass finds no blockers. The auto-mode safety check blocked a merge approved only through that relay, so the merge needs Mike's own words.

## Work and outcome

- **Diagnosis:** I counted rows in the copy of the store from Mike's phone (with `devicectl`). I didn't read any content, only counts and timestamps. It held every save: two entries today, at 22:04 and 22:05, plus an earlier test entry.
  - Saving itself worked.
  - Typed entries saved three times in a row on the Simulator.
  - The likely trap was **Save staying disabled while the microphone was still listening**.
- **Fix:** tapping Save while listening stops dictation, keeps the words so far and saves (`GuestDictationViewModel.stopForSave`). Late recogniser results are ignored.
- **Testing aid:** a Debug-only `ScriptedDictationEngine`, selected with the launch argument `-CircleUScriptedDictation "<words>"`, lets UI tests drive the voice path on the Simulator. Its `#if DEBUG` guard means it isn't in Release builds.

## Verification

- **Full local suite:** 164 passed, 0 failed, 1 skipped (the device-only test). It includes regression tests:
  - three entries in a row with and without voice, using a real kept-draft store and an ID-aware journal;
  - three distinct IDs, with no "already saved" notice;
  - Save while listening, with a late final result ignored.
- **Out-of-repo XCUITests** (iPhone 18 Pro / iOS 27.0 Simulator), passed:
  - three entries (typed; voice with Save tapped while listening; voice plus typing) all listed, and still there after a relaunch;
  - the existing write, save, relaunch and edit flow.
- **Not run:** the fix on Mike's phone, and CI (manual by owner decision).

## Discussion and decisions

- **Codex** ([log](2026-10-25-221600-codex-review-guest-save-while-listening.md)): no blocker. Two should-fixes:
  1. The multi-entry test bypassed draft identity. Fixed: real draft store, ID-aware fake, exact count and order.
  2. The Save-button regression is tested only through the view model in the repo. Covered by the out-of-repo UI test above. An in-repo UI test target is still open.

## Handoff

- Remaining work:
  - Mike's direct "merge" for PR #13 and PR #15;
  - Practice in one batch;
  - one phone check covering the three-entry fix and Practice.
- Owner: Mike (merge words); Claude (Practice)
- Risks / unresolved questions: Mike's exact third attempt wasn't observed.
