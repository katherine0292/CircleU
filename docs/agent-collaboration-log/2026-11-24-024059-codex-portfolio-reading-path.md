# Portfolio reading path and evidence boundaries

- Recorded: 2026-11-24 02:40:59 +1100; Australia/Sydney
- Agent / role: Codex, portfolio editing and integration
- Status: completed local revision; awaiting owner visual review
- Base revision and branch: 0359d24, codex/portfolio-case-study-v2; working-tree changes
- Related record: [Contribution evidence](2026-11-07-010000-claude-contributions-from-resume.md)

## Request and scope

The owner requested a branch-based edit of each project portfolio: shorten the reading path, add supported stage and delivery information, present previews, and merge after the result is accepted. No additional client dates, feedback or acceptance information was supplied. This change touches only the portfolio HTML, its matching research count in the README, and this log. Existing native-app changes in the original checkout were left untouched.

## Work and outcome

- Reorganised the portfolio into six primary chapters: overview, experience, research/scope, AI decisions, validation, and delivery/next steps.
- Preserved full screen flows, research synthesis, priorities, AI interaction examples, 19 acceptance cases, 37 review items, visual system and proposed metrics in six closed disclosure groups.
- Updated both languages to distinguish 20 survey responses from 3 interviews; the earlier TestFlight release from the current Simulator redesign; implemented changes from small task retests and future outcome measures.
- Kept the existing page's visual assets, language controls and interaction scripts. Added responsive reading-path styles and a complete HTML document shell.
- After the owner reviewed the preview, reduced primary headings to about 24px, body copy to 14.5–15px, chapter padding to 30px (24px on narrow screens), and tightened the content width, card padding and disclosure spacing. The same preview URL serves this revision.

## Verification

- All three inline scripts passed node --check; static media paths and unique IDs checked.
- Local preview returned HTTP 200. CUA browser inspection confirmed six primary chapters, no visible broken images or document-width overflow at the inspected narrow widths, seven generated screen groups after disclosure expansion, and functioning English/Chinese switching. No browser console errors were captured in that check.
- git diff --check passed after whitespace cleanup.
- Not run: native iOS tests, physical-device tests, or post-launch outcome measurement; no native code changed. The shared coding-standards file was unavailable; repository-local standards were used.

## Discussion and decisions

A delegated Codex reviewer checked HTML nesting, ID and script dependencies, translation keys, media and source-level mobile layout. The reviewer identified three current-screen alt texts that incorrectly described old problems; the integrating agent changed them to factual descriptions of the redesigned screens. The reviewer reported no other concrete source-level blocker. Root performed the browser checks.

## Handoff

- Remaining work: owner visual review, then commit/merge and synchronise the existing gh-pages publication branch when approved.
- Owner: Codex integrating agent and portfolio owner.
- Limitation: this local revision is not an already deployed release; GitHub Pages currently serves the separate gh-pages branch.
