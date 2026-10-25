# Guest journal: on-device dictation, Practice tab and illustrated icons

- Recorded: 2026-10-25 21:17:00 +11:00; Australia/Sydney
- Agent / role: Claude Code (implementer), on Mike's Mac
- Status: completed; waiting for Mike's phone check and merge go-ahead
- Base revision and branch: `codex/guest-voice-and-tabs`, stacked on `codex/guest-brand-polish` (PR #13, not merged yet) at `c5ef1d2`; commits `b2342d9`, `c721b36` and this log
- Related record / task / PR: coordinator brief relaying Mike's request; [brand polish log](2026-10-25-204711-claude-guest-brand-polish.md); [asset library](../design/brand-demo/asset-library.md)

## Request and scope

Mike asked:
- why the guest journal had only Today and Journal;
- why it didn't use the illustrated icons;
- for the original app's big-microphone voice-to-text to be built into the guest Write screen.

Scope:
- guest journal only, behind the hidden switch;
- on-device recognition only, no audio files, nothing to Firebase or the cloud;
- typing must always stay available.

## Work and outcome

- **Asset audit:** [guest-asset-audit-2026-10-25.md](../design/guest-asset-audit-2026-10-25.md) lists every brand asset and where it is used. Downscaled copies were added to the app:
  - tab icons at 28 pt, @2x and @3x, in original colours;
  - two Pingu illustrations at 600 px.
- **Tabs:** Today, Journal and Practice, using the illustrated icons. The tab titles are the accessible names, and the icons are hidden from VoiceOver.
- **Practice placeholder:** the Pingu practising illustration and "Practice is coming soon", with no controls. The Journal empty state shows Pingu writing.
- **Dictation engine:** [GuestDictationEngine.swift](../../Circleu/Services/GuestJournal/GuestDictationEngine.swift), adapted from the original `VoiceRecorder`, which had no on-device requirement and no interruption handling.
  - It refuses to start unless `supportsOnDeviceRecognition`, and sets `requiresOnDeviceRecognition = true`.
  - Microphone buffers go straight to the recogniser and are never written to disk.
  - Calls, media-services resets and route changes interrupt it.
  - Each dictation gets a fresh `AVAudioEngine` and a session token.
- **Dictation view model:** [GuestDictationViewModel.swift](../../Circleu/Features/GuestJournal/GuestDictationViewModel.swift).
  - Spoken words go after any typed text, and the editor is read-only while listening.
  - Stop keeps the words and waits up to 3 s for the final text.
  - Cancel removes only the spoken words.
  - Denied access shows a message and an Open Settings link; typing keeps working.
  - Going to the background or leaving the screen stops listening and keeps the words.
- **Write screen:** an 80 pt microphone above the editor. The editor no longer opens the keyboard by itself, because the keyboard covered the microphone in the first simulator run.
- **Usage strings:** now accurate for both the guest and the legacy app. They no longer mention AI analysis.

## Verification

- **Full local suite** (`xcodebuild test`, CI signing config, `CODE_SIGNING_ALLOWED=NO`, iPhone 17 / iOS 26.5 Simulator): **162 passed, 0 failed, 1 skipped**. The skipped test is the device-only Data Protection test. 13 of the passing tests are new dictation tests.
- **Out-of-repo XCUITests** (iPhone 18 Pro / iOS 27.0 Simulator), both passed:
  - the three tabs exist;
  - the Practice placeholder appears;
  - the real speech permission prompt appears and is denied, after which the message and Open Settings link show and typing and Save still work;
  - the existing write → save → relaunch → edit flow still passes.
- **Accessibility audit:**
  - new screens: no new issues, apart from the expected contrast flag on the disabled Save button;
  - existing system Edit and Back flags, and the keyboard suggestion buttons, are unchanged.
- **Phone:** CircleU Guest Test (`com.tuannm3812.circleu.guesttest`, `GUEST_JOURNAL_BUILD`) is installed on Mike's iPhone 11 Pro Max. Launch was refused while the phone was locked, so Mike opens it himself.
- **Not run:**
  - actual speech recognition with a voice (simulator and phone), and the grant-permission path;
  - real call interruptions and route changes;
  - VoiceOver on a device;
  - CI, which is manual by owner decision.
- The engine's session-token guard was checked by inspection only. The tests exercise the view model's guard with a fake recogniser.

## Discussion and decisions

- **Codex round 1** ([log](2026-10-25-210300-codex-review-guest-voice-tabs.md)): one blocker and three should-fixes. All were accepted and fixed in `c721b36`:
  - blocker: stale engine callbacks could reach a new session;
  - the permission alert's `.inactive` phase cancelled the start;
  - a media-services reset could reuse an invalid engine;
  - the late-callback test delivered nothing.
- **Codex round 2** ([log](2026-10-25-211400-codex-review-guest-voice-tabs-round-2.md)): pass, with no new findings.
- Agent choice, not an owner decision: the microphone stays a native SF Symbol, per the asset library's usage rules.

## Handoff

- Remaining work: Mike's phone check, then his merge go-ahead. PR #13 must merge first, or this PR is retargeted to main.
- Owner: Mike (check, decision); Claude (merge on go-ahead)
- Risks / unresolved questions:
  - recognition quality and the 3 s final-text wait have not been tried on a device;
  - on-device support depends on the phone's language. English is supported on the iPhone 11 Pro Max.
