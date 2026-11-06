# Podo, high-resolution screens and README refinements

- Recorded: 2026-11-06 23:30:00 +11:00; Australia/Sydney
- Agent / role: Claude Code (desktop app, Katherine's Mac), naming, capture and documentation
- Status: completed
- Base revision and branch: `main` after PR #6, on `codex/podo-readme-prototype`
- Related record: [Talk wording and README](2026-11-06-230000-claude-talk-wording-readme.md)

## Request and scope

Katherine asked for four changes and one review:
- remove the README's Chinese summary;
- replace the blurry screenshots and motion clips with high-resolution ones;
- rename the otter from Tuanwei to Podo in the code;
- drop the Chinese version of the app;
- compare her README with Tuan's earlier one.

She clarified that she didn't want separate prototype boards, only sharp images in place of the current ones.

## Work and outcome

- **Podo:** the otter is called Podo everywhere a person sees or hears a name:
  - the Welcome bubble now says "Hi, I’m Podo!";
  - the VoiceOver names of all 21 avatars;
  - code comments;
  - the two UI tests that pick an avatar by name;
  - the README, the final-screens gallery and user story W3, which notes the earlier name.

  Asset names (`GuestPingu…`) are unchanged. Dated log entries keep the name used at the time.
- **Images:** the screens were captured again with the new name:
  - screenshots are now full Simulator resolution (1206 px wide, JPEG quality 92), up from 1000 px at quality 82;
  - GIFs are 560 px wide at 12 fps, up from 300 px at 10 fps, so they stay sharp on Retina screens;
  - the folder is about 40 MB;
  - the Desktop set (`CircleU_最终版高保真图_2026-11-06`) was refreshed with full PNGs and the recording.
- **README:**
  - the Chinese summary was removed;
  - from Tuan's README, it borrows a tech-stack list and a copyable test command;
  - it keeps its own structure (problem, loop, features, AI principles, evolution, architecture, quality, role).

## Verification

- Capture walkthrough passed for Welcome, the core flow and the guide. The Settings shot was skipped again: its toolbar link wasn't found by label.
- Full suites (iPhone 17 Pro Simulator, iOS 26.5): unit 311 tests, 310 passed, 0 failed, 1 skipped; UI 28 tests, 24 passed, 3 failed, 1 skipped. The three failures are the known ones (Simulator dictation, two calendar tests under the Chinese locale). The two avatar tests that use the Podo names passed.

## Handoff

- Owner: Katherine
- Remaining:
  - three short "What I learned" points in her own words, if she wants them in the README;
  - the Talk thread shows the top of a scrolled card faintly behind the navigation title (visible in the readings screenshot); a top fade would fix it.
