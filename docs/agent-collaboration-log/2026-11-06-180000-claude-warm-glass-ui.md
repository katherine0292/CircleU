# Warm glass look across the guest app

- Recorded: 2026-11-06 18:00:00 +11:00; Australia/Sydney
- Agent / role: Claude Code (desktop app, Katherine's Mac), implementation
- Status: completed
- Base revision and branch: `codex/otter-artwork`, after the artwork commit
- Related record: [artwork entry](2026-11-06-163000-claude-otter-artwork.md); visual proposal artifact 「CircleU 液态玻璃方案」 (6 November)

## Request and scope

Katherine reviewed the visual proposal, approved Today and the tab bar first, then asked for every guest screen including Welcome, with motion and layout in line with current iOS design guidance (Apple's Liquid Glass guidance and community SwiftUI references). Only the guest app (GuestJournal feature folder) changes; the legacy app keeps its design.

## Work and outcome

- `Circleu/Features/GuestJournal/GuestGlass.swift` (new):
  - `GuestWarm` palette from the otter;
  - `GuestFlowingBackground`: mesh gradient on iOS 18+, still with Reduce Motion, blurred blobs on iOS 17;
  - `guestGlass(in:)`: Liquid Glass on iOS 26, material before, solid with Reduce Transparency;
  - `guestCard(in:)`: near-solid cream paper for content. Following Apple's guidance, glass is kept for controls that float above content.
  - Button styles (cocoa main, glass secondary, spring press), `GuestBottomFade`, rise-in, hop and breathing-ring motion. Every motion is off with Reduce Motion.
- `GuestBrand` keeps its colour names, so every screen moved together. `blue` is now cocoa, `ice` oat, `ink` cocoa ink, `muted` warm grey and `wash` sage. Contrast ratios are noted in the code.
  - `GuestBrandButtonStyle` uses the new cocoa and glass styles.
  - Chips are glass.
  - Navigation titles and headings use the rounded system font. Body text stays Plus Jakarta Sans.
- Screens:
  - every flat ice background now flows;
  - white cards are cream paper;
  - pinned bottom actions sit on a fade;
  - capsule and circle controls are glass.
- Welcome:
  - the art fades into the background with no flat band;
  - parallax on swipe;
  - the words fade while paging;
  - spring page dots;
  - a cocoa Next button.
- Today: the scene runs across the top behind the glass bars; the writing card and microphone are restyled; Save is glass until there are words.
- Motion elsewhere:
  - Journal rows, Practice messages and the "Saved" card rise in;
  - the otter on "Saved" hops once (confirmation, not praise);
  - reflection parts arrive one after another;
  - scenes have a soft shadow.
- No wording, behaviour or data changed.

## Second round (Katherine's review)

- Welcome:
  - the art fades over the lower 45% with eased stops, and the title sits on the fade;
  - the art always fills the band from the very top, growing and cropping its sides, so no gap shows under the status bar.
- Motion (Katherine picked the three recommended ideas):
  - `GuestFlowingBackground(mood:)` cross-fades toward a pale wash for the feeling the person chose. Used in the tag picker and the entry detail. Never inferred from their words.
  - `GuestRevealText` (iOS 18 TextRenderer): the reflection suggestion arrives letter by letter from a soft blur. Then the editable field takes over.
  - `guestSquish(on:)`: tags squash and settle like clay with a selection haptic. Used in the tag picker and on Journal rows.
- Katherine asked not to run test suites during UI rounds; only build and Simulator screenshots so far.

## Third round

- The Practice Tone area showed a rounded "shell": on iOS 26 nearby glass shapes merge into one.
  - In-content chips, tone choices, the message tag and the framed avatar now use `guestPill`, a cream pill with a hairline edge.
  - Glass stays only on lone floating controls.
- The remaining motions, added for Katherine to try:
  - while writing, the scene shrinks up into the avatar, which hops;
  - Delete all data must be held (red fill). Letting go early shakes the row and says "Hold to delete". The existing confirmation still follows, and VoiceOver gets a plain action.
- A Save ripple was tried, first as a Metal shader, which needs the Metal Toolchain download, then as SwiftUI rings. Katherine removed it after trying it; Save opens Journal straight away as before.

## Verification

- `xcodebuild build` (CircleU Guest Review, iPhone 17 Pro Simulator, iOS 26.5) succeeded after each round; screens checked by Simulator screenshot and by Katherine trying them.
- Final run, once Katherine confirmed the UI (`xcodebuild test`, iPhone 17 Pro Simulator, separate derived data, `CODE_SIGNING_ALLOWED=NO`):
  - unit suite (scheme Circleu): 300 tests, 299 passed, 0 failed, 1 skipped (`testRealDataProtectionOnDevice`, physical device only);
  - UI suite (scheme CircleuUITests): 30 tests, 26 passed, 3 failed, 1 skipped.
- The three UI failures are the known ones from [5 November](2026-11-05-224500-claude-ai-input-check.md):
  - `GuestVoiceTabsUITests.testTabsPracticeAndDictationDenied` (no Simulator speech);
  - `GuestFindControlUITests.testSearchCalendarDraftExportAndDeleteAll` line 49 and `GuestStatesUITests.testEmptyJournalPracticeAndCalendarDay` line 133 (calendar labels and the Chinese Simulator locale).
- Because that find-control test stops at line 49, its new hold-to-delete steps did not run. The hold path did pass in `GuestTodayUITests` and `GuestStatesUITests`.
- Not checked: iOS 17/18 fallbacks, Reduce Transparency, a physical iPhone.

## Discussion and decisions

- Apple's guidance reserves glass for navigation and controls; content cards use near-solid paper so long text stays readable.

## Handoff

- Owner: Katherine
- Risks / unresolved questions:
  - dark mode is still deferred (the guest app forces light);
  - not checked on iOS 17/18, with Reduce Transparency, or on a physical iPhone.
