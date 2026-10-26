# Visual Today: new art, logo, Mac tests and Codex review

- Recorded: 2026-10-26 17:05:00 +11:00
- Agent / role: Claude Code (on the Mac), implementer
- Status: done (pushed; not merged; phone check pending)
- Base revision and branch: 180a46d on `codex/visual-today-journal` (base 73b2d81)
- Related record / task / PR: [previous entry](2026-10-26-152758-claude-visual-today-journal.md); [asset expansion 02 prompts](../design/brand-demo/asset-expansion-02-prompts.json)

## Request and scope

The coordinator session asked for a Mac build and test of this branch, new chip icons and ice-floe scenes from Codex's built-in image_gen, and one Codex review. Mike's feedback on the D boards, received in the same request: use the new logo at the top left of Today, replace the chip icons that repeat the tab icons, and use full landscape art in place of the current images.

## Work and outcome

- Art: six assets made with image_gen through `codex exec`, two candidates each, best kept: `GuestChipWhatHappened`, `GuestChipWhoWith`, `GuestChipWishSaid` (icons) and `GuestSceneToday`, `GuestSceneListening`, `GuestSceneJournalEmpty` (1170×600 scenes). Originals in `BrandArtwork/Expansion02/`; prompts, sizes and SHA-256 in the prompts file.
- Today: the CircleU logo (`GuestIconLogo`) replaces the avatar button at the top left. The card is the ice-floe scene with the microphone on its quiet right side; while listening, the listening scene with stop and cancel below. Chips use the new icons. Scenes are left out at accessibility text sizes, as before.
- Journal: the empty state is the dusk scene. Rows and the entry title now use the day an entry was written (`createdAt`, as the calendar does) and show the year when it isn't this year (Codex findings 1 and 2).
- Your Pingu: the picker is now reached from Settings only (S4 updated). The chosen Pingu no longer shows on Today because the scene has a fixed Pingu.
- Tests: `GuestPolishUITests` and `GuestStatesUITests` open the picker through Settings; `GuestFindControlUITests` waits for the share sheet to close before Delete all (the iOS 27 sheet can ignore a Close tap during its entrance). `GuestPinguArtTests` checks the six new assets are bundled.
- Docs: `user-stories.md` (T10, J1.1, S4, partial-coverage notes and totals, Codex finding 3).

## Verification

- Unit suite (`Circleu`, CI signing config, iPhone 17 Pro iOS 27.0 Simulator): 253 passed, 0 failed.
- UI suite (`CircleuUITests`): 16 tests, 1 skipped, 1 failure: `GuestVoiceTabsUITests.testTabsPracticeAndDictationDenied` ("the denial message is shown"). It fails the same way on origin/main on a fresh simulator, so it isn't caused by this branch. `GuestFindControlUITests` failed on this branch before the share-sheet wait and passed twice after it.
- Codex review (gpt-6-astra, high, review only): no blockers; three should-fix items, all addressed above.
- Not done: phone check, VoiceOver pass.

## Discussion and decisions

Mike asked for the logo and full landscape art; moving the Pingu picker to Settings only follows from that and is easy to revert.

## Handoff

- Remaining work: phone check in CircleU Guest Test; the dictation-denied UI test on a fresh iOS 27 simulator (pre-existing).
- Owner: Claude (this thread)
- Risks / unresolved questions: on iOS 26+ the toolbar puts the logo in a glass circle, which can look tappable.
