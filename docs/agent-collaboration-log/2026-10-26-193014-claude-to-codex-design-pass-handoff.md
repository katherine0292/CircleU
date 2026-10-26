# Handoff to Codex: "less text" design pass (26 October)

- Recorded: 2026-10-26 19:30:14 +11:00
- Agent / role: Claude Code (cloud session for the Today and Journal thread), writing the handoff for the four design threads
- Status: handoff
- Base revision and branch: main at 026f416 (after PR #34); this entry is on `codex/log-today-journal-handoff`
- Related record / task / PR: PRs #30–#36; canvas "CircleU Design" https://claude.ai/artifact/Dmqgv7oiiZM8PyuRqaQCXK; earlier entries for this pass: [Today/Journal](2026-10-26-152758-claude-visual-today-journal.md), [Today art](2026-10-26-170500-claude-visual-today-art.md), [Welcome scenes](2026-10-26-171734-claude-onboarding-scenes.md), [UI test fixes](2026-10-26-173000-claude-fix-two-ui-tests.md), and the Codex review entries from 16:30, 16:34 and 17:10

## Request and scope

Mike said the guest app had become "full of text" and asked for separate threads to redesign the UI together with him. Each thread mocked its screens on the CircleU Design canvas (rows D, J, P, S and AC, with board titles starting with story IDs), coded them on its own `codex/` branch, ran tests on the Mac and one Codex review, then merged under Mike's standing OK (local tests pass, Codex finds no blockers). Mike asked for this entry so Codex can carry on.

## Work and outcome (all merged to main)

| PR | What changed |
| --- | --- |
| #30 | [Screen content guidelines](../design/screen-content-guidelines.md): supporting line ≤ 60 characters, plus a new "Icons over labels" section. Icon-only controls keep their old wording as `accessibilityLabel` (UI tests find them by that name), with 44 pt targets. Words stay for primary, destructive and honesty lines. Rare actions go in a ••• menu. |
| #31 | Practice: message bubbles, "+" chips for Situation and Goal, tone cards, delete in a ••• menu, and "Copied. Not sent." |
| #32 | Account screens: chips, (i) info sheets instead of Learn more, and "Will be deleted". The screens never reveal whether an account exists. Shared helpers in `GuestSignIn.swift`: `GuestChip`, `GuestChipRow`, `GuestInfoButton`, `GuestSymbolArt`, `GuestFactCard` and `.guestField()`. Reuse these rather than adding new ones. |
| #33 | Settings: six illustrated icon rows (Expansion03), a "Kept on this iPhone" chip, and a privacy sheet that replaces Learn more. Your Pingu is a framed avatar with a pencil badge. |
| #34 | Today and Journal (stories T10 and J6). Today: the logo in the top-left; an ice-floe scene (`GuestSceneToday`) holding the microphone; `GuestSceneListening` while dictating, with Stop and Cancel as icons; the chosen Pingu as a small badge on the scene (Mike's choice), which opens the picker; new chip icons (`GuestChipWhatHappened`, `GuestChipWhoWith`, `GuestChipWishSaid`); the nudge as a speech bubble from Pingu. Journal: date tiles, status icons that VoiceOver reads as words, a one-row "Saved" card, a day chip with ×, up to three calendar dots, and Go to today as an icon. The entry title is the creation date; Edit is a pencil and Delete is in the ••• menu. The empty Journal uses `GuestSceneJournalEmpty`. |
| #35 | Welcome: three portrait pages (a rainy evening, a lamp-lit desk and a sunrise), with Expansion04 art. |
| #36 | Fixed the two UI tests that were stale on main, including "dictation denied". |

Art folders under `Prototypes/CircleUVisualPrototype/Sources/CircleUVisualPrototype/Resources/BrandArtwork/`: Expansion02 (Today/Journal), Expansion03 (Settings) and Expansion04 (Welcome). Each has a matching `docs/design/brand-demo/asset-expansion-0N-prompts.json` with prompts and SHA-256 hashes, made with Codex's built-in image_gen and the `BrandAvatar.png` identity reference. **The next art set should be Expansion05.**

## Verification

- On the Mac, after merging main into #34 (iOS 27 simulator): the unit suite passed 253 tests, and the full `CircleuUITests` run had 18 tests, 1 skipped, 0 failures. That was the final state of main before this entry.
- Phone: on 26 Oct about 19:25 +11:00, CircleU Guest Test (`com.tuannm3812.circleu.guesttest`, Debug, `GUEST_JOURNAL_BUILD`) was built from main 026f416 and installed in place on Mike's iPhone 11 Pro Max, keeping its entries. The helper app CircleU Preview (`com.tuannm3812.circleu.preview`) was deleted at Mike's request. Apple's Xcode Previews entries were left. The real CircleU app isn't installed on that phone.
- Not done: Mike's own look at the new build on the phone. Every build is labelled 1.0.0 (1), so the phone can't show which commit it has.

## Discussion and decisions

- Mike chose: the logo in the top-left of Today; new chip icons that don't repeat the tab icons; landscape art instead of the earlier images; and his chosen Pingu as a small badge on the Today scene rather than in Settings only.
- Codex reviewed #34 (gpt-6-astra, high, review only) and found no blockers. Its three should-fix items were fixed: use the creation date everywhere, show the year for older entries, and accurate coverage claims in the stories doc. The other PRs' reviews are in their own entries.
- Phone installs failed earlier in the day because the phone was locked or unreachable (CoreDevice error 4016). No thread installed anything else on the phone.

## Handoff

- Remaining work:
  1. Mike's phone check of the new build. Fix anything he reports.
  2. Open UI ideas Mike hasn't chosen yet. Ask him first; don't build them unasked: a time-of-day Today scene (morning or dusk, dark mode at night); Pingu poses per state (listening, writing, waving after Save); a Save check with a haptic; a Journal week strip, or entries grouped by week; a Practice ice-floe scene so all tabs share one world; the feeling icon on the Journal date tile; "See it in Journal" after copying a backup; a different Pingu per empty state.
  3. Today art options A and C from the [art brief](../design/pingu-scene-art-brief.md) are largely covered by Expansion02. Update the brief if Mike agrees.
- Owner: Unassigned (Codex, if Mike asks it to continue).
- How to work: follow the user-story workflow ([user stories](../product/user-stories.md): update the story, mock on the canvas, code, test). Read the screen content guidelines first. Run the unit suite and the `CircleuUITests` scheme before merging, plus one Codex review. Use a separate git worktree per branch, because several agents share the Mac checkout.
- Guest Test install, unchanged from earlier entries: build with `PRODUCT_BUNDLE_IDENTIFIER=com.tuannm3812.circleu.guesttest`, `INFOPLIST_KEY_CFBundleDisplayName="CircleU Guest Test"` and `SWIFT_ACTIVE_COMPILATION_CONDITIONS=$(inherited) GUEST_JOURNAL_BUILD`, Debug, `-allowProvisioningUpdates`. Check the bundle ID, then `xcrun devicectl device install app`. Install in place and never uninstall it first (that deletes Mike's entries). Never install over the real CircleU app. A worktree needs the git-ignored `Config/Signing.xcconfig` copied from the main checkout.
- Risks / unresolved questions: the phone has to be unlocked and reachable for installs. The coverage counts in `user-stories.md` were merged by hand from two branches, so recount them if stories change again.
