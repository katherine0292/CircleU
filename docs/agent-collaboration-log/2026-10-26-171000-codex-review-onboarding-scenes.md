# Codex review: onboarding scenes

- Recorded: 2026-10-26 17:10:00 +11:00; Australia/Sydney
- Agent / role: Codex (gpt-6-astra, high, read-only reviewer), run by Claude Code
- Status: completed
- Base revision and branch: reviewed `4cd419b` on `codex/onboarding-scenes` against `origin/main`
- Related record / task / PR: [Claude's entry](<2026-10-26-171734-claude-onboarding-scenes.md>); no PR

## Request and scope

One review-only pass over the three-page Welcome:
- [GuestImportAndWelcome.swift](<../../Circleu/Features/GuestJournal/GuestImportAndWelcome.swift>)
- the scene assets
- the UI tests
- the W1 stories, the guidelines row and the Expansion 04 prompts

Areas: correctness, accessibility, copy and tests.

## Work and outcome

**Changes requested: two blockers.**

1. **Text could overlap the artwork.** The art was sized from width only, while the words were placed from screen and footer height. On a landscape iPad, or with large text below the accessibility sizes, the heading lands on the detailed scene. Also, the fixed 180 pt banner leaves almost no text space on a short landscape screen. Codex's fix: give art, text and footer separate regions from the available height, and collapse the banner on short windows.
2. **The paging test could pass without the page changing.** Every page is built at once, so `waitForExistence` on a title doesn't prove it's shown. `go(to:)` also set the footer's page apart from the scroll position. Codex's fix: wait for the title to be on screen, assert the page indicator, swipe both ways, and check Skip on both routes.

**Non-blockers:**

- VoiceOver page changes aren't verified, and focus doesn't move to the new heading.
- Skip's 44 pt frame wrapped the Button rather than its label.
- "This iPhone" is inaccurate on iPad.
- W1.1 overstated: no test checks the artwork. Codex confirmed the coverage arithmetic: 27 stories, 91 criteria, 70 unit, 20 UI-only, 1 untested, 12 partial.

**Codex also confirmed:**

- Get started and Log in behave as before.
- The art is hidden from VoiceOver, and Reduce Motion skips the paging animation.
- Headings are 23, 24 and 15 characters; lines are 51, 44 and 49. There is one primary action per page and no banned words.
- "Not uploaded or synced" holds for the guest journal: CloudKit is off, Firebase is skipped at guest startup, and dictation needs on-device recognition.

## Verification

- Codex ran `git diff origin/main...HEAD` and `git diff --check`, and checked the asset hashes against the manifest.
- Not run / limitations: Codex didn't run builds, tests, the Simulator, VoiceOver or a device.

## Discussion and decisions

Claude's response is in [Claude's entry](<2026-10-26-171734-claude-onboarding-scenes.md>). Both blockers and the Skip and W1.1 notes were fixed. The iPad wording ("this iPhone") is left for the owner, because the whole guest journal uses it. VoiceOver focus wasn't changed.

## Handoff

- Remaining work: none from this review beyond the open non-blockers above.
- Owner: Unassigned
- Risks / unresolved questions: VoiceOver walk-through on a device.
