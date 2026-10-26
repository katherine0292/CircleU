# Welcome onboarding scenes

- Recorded: 2026-10-26 17:17:34 +11:00; Australia/Sydney
- Agent / role: Claude Code (implementer); Codex for image generation and one review
- Status: completed (not merged)
- Base revision and branch: `codex/onboarding-scenes`, `origin/main` merged in at `8fd8743`
- Related record / task / PR: [Codex review](<2026-10-26-171000-codex-review-onboarding-scenes.md>); [asset-expansion-04-prompts.json](<../design/brand-demo/asset-expansion-04-prompts.json>); no PR

## Request and scope

The owner asked for portrait artwork with scene backgrounds to make onboarding more appealing. The coordinator's brief asked for five things:
1. Regenerate the hard-moment scene.
2. Build a three-page Welcome in `GuestWelcomeView` with the scenes in the asset catalog.
3. Update W1 and the UI tests.
4. Run both suites and capture screenshots.
5. Do one Codex review, with no PR or merge.

## Work and outcome

- **Art:**
  - `OnboardingHardMomentV2` (Codex `image_gen`, three candidates, c1 kept) follows the brief: Pingu looks away, thoughtful, holding nothing. V1 is kept.
  - The tool sets its own size: V2 is 858×1834, and FindWords and SayItKindly are about 1020×1540.
  - The catalog has `GuestOnboardingHardMoment`, `GuestOnboardingFindWords` and `GuestOnboardingSayItKindly` as one universal JPEG each, about 90–130 KB.
- **Welcome** ([GuestImportAndWelcome.swift](<../../Circleu/Features/GuestJournal/GuestImportAndWelcome.swift>)):
  - Three pages in a horizontal paging `ScrollView` (`scrollTargetBehavior(.paging)`, `scrollPosition`). It replaced TabView because TabView's page host offset content by the safe area, which hid the words behind the footer.
  - Pages have explicit full-screen sizes. The footer's height is measured, and each page keeps its words above it.
  - The scene takes only the height the words and footer leave, centring on Pingu when space is short, with a soft fade into ice. At accessibility sizes, or when the words don't fit, it becomes a band of up to 180 pt above scrolling text.
  - Footer: page dots ("Page N of 3"), Skip and a round Next button (labelled "Next") on pages 1–2, and Get started and Log in on page 3.
  - The art and off-screen pages are hidden from VoiceOver. Next and Skip don't animate with Reduce Motion. After a rotation the pager settles back on the current page.
  - Copy follows the guidelines; the Welcome row is updated in [screen-content-guidelines.md](<../design/screen-content-guidelines.md>).
- **Stories** ([user-stories.md](<../product/user-stories.md>)):
  - W1.1 is now three pages with Skip and Next; it is partial, because the art is checked on screenshots.
  - New W1.5: Next, swipe and Skip reach Get started and Log in, which stay reachable at the largest text size.
  - Coverage: 91 criteria, 20 UI-only, 13 partial.
- **Tests:**
  - `GuestStatesUITests.testWelcomePagesNextAndSkip` checks that titles are inside the window, the page indicator, swipes both ways, Next, and Skip.
  - `testWelcomeLastPageAtLargestText` covers the last page at the largest accessibility text size.
  - The tests that start from Welcome (`GuestStatesUITests` W1.2, `GuestImportUITests`) tap Skip first.
- **Fixes from the Codex review:**
  - Separate art, text and footer regions.
  - Stronger paging tests, with the page indicator following the real scroll position.
  - Skip's target moved inside its label.
  - W1.1 marked partial.
- **Not changed:** "this iPhone" wording on iPad (used across the guest journal; the owner's call); explicit VoiceOver focus on the new heading.

## Verification

- `xcodebuild test -scheme Circleu` (iPhone 18 Pro Max, iOS 27.0, unsigned CI config): **253 passed, 0 failed, 1 skipped**.
- `xcodebuild test -scheme CircleuUITests` (same device): **16 passed, 1 failed, 1 skipped** (live Dev, opt-in). The failure is `GuestVoiceTabsUITests.testTabsPracticeAndDictationDenied`. These simulators report on-device dictation as unavailable, so no permission prompt appears. It fails the same way on `origin/main` (see [2026-10-26-163441](<2026-10-26-163441-codex-review-account-screens-icons.md>)).
- Screenshots are in [onboarding-scenes-2026-10-26](<../qa/screenshots/onboarding-scenes-2026-10-26/>): pages 1–3, plus page 1 and page 3 at the largest accessibility text size.
- A throwaway, uncommitted layout probe on an iPhone 18 Pro Max and an iPad Pro 11-inch covered XXXL text, landscape and a rotation back to portrait. No text sat on detailed art. The rotation probe found the pager stuck between pages, which is now fixed and re-checked on iPhone.
- Not run / limitations: VoiceOver walk-through, physical device, the live Dev test.

## Discussion and decisions

The coordinator relayed the brief; the owner asked for the artwork. Codex's blockers and Claude's responses are in the [review entry](<2026-10-26-171000-codex-review-onboarding-scenes.md>).

## Handoff

- Remaining work: a phone check on CircleU Guest Test; a VoiceOver pass; decide "this iPhone" versus "this device" for iPad.
- Owner: Unassigned
- Risks / unresolved questions: the generated scenes vary in shape. A future regeneration should keep Pingu around 30–45% down and the bottom third plain.
