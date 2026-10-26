# Visual Today and Journal (icons over labels)

- Recorded: 2026-10-26 15:27:58 +11:00
- Agent / role: Claude Code (cloud session), implementer
- Status: partial (code written; build, tests and Codex review run on the Mac before merge)
- Base revision and branch: 73b2d81 (main after PR #30) + branch `codex/visual-today-journal`
- Related record / task / PR: canvas https://claude.ai/artifact/Dmqgv7oiiZM8PyuRqaQCXK rows "D · Visual Today" and "J · Simpler Journal"; [screen content guidelines](../design/screen-content-guidelines.md) (PR #30)

## Request and scope

Mike felt the app had become too text-heavy and asked for design threads to improve the UI together. This thread owns Today and Journal (`GuestJournalScreens.swift`, the calendar in `GuestFindAndControl.swift`). The new mic and scene art (ART-1 to ART-6, [art brief](../design/pingu-scene-art-brief.md)) isn't ready, so this pass uses Pingu art already in the app.

## Work and outcome

- Today (story T10): Pingu and the microphone share one soft blue card. While listening, Pingu listens inside rings, with stop and cancel as icons. The chips show the sun, heart and chat icons. The nudge is a speech bubble from thinking Pingu with Add and two icon buttons. Removed on screen: "Type, or tap the microphone and talk.", "Tap to talk", "Not sure where to start?", "Need a nudge?", "Another question" and "Hide" (the last two stay as VoiceOver names). Waiting states ("Checking access…", "Finishing…") are now the microphone's VoiceOver value. Pingu art is left out at accessibility text sizes.
- Journal (story J6): rows get a date tile, status icons (reflection, next step or tick, practice) read in words by VoiceOver, and the time. The "Saved" card is one row. A chosen day is a chip with × (VoiceOver "Show all"). The calendar shows up to three dots per day and Go to today is an icon. The entry's title is its date, Edit is a pencil, Delete entry is in a ••• menu ("More"), and the reflection, feeling and next step use icons with spoken names.
- Docs: `user-stories.md` (T10, J6, T6.1 wording, coverage), the Today, Journal and Entry rows of the screen content guidelines. UI tests updated for the new names.

## Verification

- Not run in the cloud session (no Xcode). To run on the Mac before merge: the unit suite and the `CircleuUITests` scheme, then one Codex review.

## Discussion and decisions

The coordinator session assigned Today and Journal to this thread and pointed it at PR #30's text rules. Mike hasn't commented on the D boards yet; his comments will be folded in before merge.

## Handoff

- Remaining work: Mac build and tests, Codex review, phone check in CircleU Guest Test.
- Owner: Claude (this thread)
- Risks / unresolved questions: accessibility audits in the UI tests may flag the new card or icon buttons; the art in T10's card is a stand-in until ART-1 to ART-6 arrive.
