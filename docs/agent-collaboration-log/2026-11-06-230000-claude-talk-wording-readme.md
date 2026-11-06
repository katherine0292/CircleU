# Talk wording, project overview, final screens and README

- Recorded: 2026-11-06 23:00:00 +11:00; Australia/Sydney
- Agent / role: Claude Code (desktop app, Katherine's Mac), copy, documentation and capture
- Status: completed
- Base revision and branch: `main` after PR #5 (`codex/otter-artwork`)
- Related record: [moments, Talk and guide](2026-11-06-210000-claude-talk-moments-guide.md)

## Request and scope

Katherine dropped the animation-video follow-up. She asked for four things:
- change the leftover "practice" wording to the new version;
- a full read of the code, with the logic of both versions written up;
- final high-fidelity screens, including motion;
- a new README that shows the project clearly to interviewers for AI product and AI experience design roles.

She also asked whether a Chinese version is worth adding. That was answered in chat; nothing was built for it.

## Work and outcome

- **Wording:** every guest-app string the person sees now says Talk or conversation instead of practice:
  - Welcome page 3;
  - the empty Talk list;
  - the unsaved-conversation notice;
  - load, draft and save errors;
  - the delete dialog (Keep conversation);
  - export and its header (CONVERSATIONS);
  - delete-all errors;
  - import and recovery skip lines;
  - one avatar name.

  Saved keys, file names, draft slots, Firestore collections, asset names and type names keep the old spelling, because renaming them would break data already on testers' phones. Version 1 (Tips / Live Coach) is unchanged.
- **Talk fix found while capturing:**
  - a reading or reply-ideas card that filled in after thinking didn't scroll up, so the hint line drew over it;
  - the thread now also follows the last card when thinking ends;
  - the composer has the shared bottom fade.
- **Overview:** [How CircleU works](../product/how-circleu-works.md) covers:
  - the launch switch;
  - version 1's features and code;
  - why version 2 exists;
  - version 2's flows, layers, data, AI decisions, privacy and quality.
- **Final screens:** [final-screens-2026-11-06](../design/final-screens-2026-11-06/README.md) has 22 screens and 5 GIFs:
  - captured by a temporary walkthrough UI test (deleted afterwards), with the Simulator recording;
  - English locale, fixed status bar, invented data, Apple Intelligence on;
  - GIFs made with AVFoundation and ImageIO, since no ffmpeg was available.

  Full-resolution PNGs and the full recording are on Katherine's Desktop (`CircleU_最终版高保真图_2026-11-06`), outside the repository. `docs/showcase/` is ignored by Git, so the images live under `docs/design/`.
- **README:** rewritten for version 2. It covers:
  - a summary and a Chinese summary;
  - the loop;
  - four feature sections with screens;
  - seven AI product principles;
  - version 1 → 2 evolution, with the old screens collapsed;
  - architecture, quality, role, run steps and credits.

  It leaves out the unconfirmed research numbers in the portfolio draft.
- **Docs:** the screen content guidelines note the Write / Journal / Talk names. The user stories P2.1 and J5.1 use the new copy, and the documentation index links the overview.

## Verification

- Build: `CircleU Guest Review`, iPhone 17 Pro Simulator, iOS 26.5.
- Capture walkthrough: Welcome, the core flow and the guide passed. The Settings capture didn't find the button, so it was dropped.
- Full suites (`xcodebuild test`, separate derived data, `CODE_SIGNING_ALLOWED=NO`):
  - unit (scheme Circleu): 311 tests, 310 passed, 0 failed, 1 skipped;
  - UI (scheme CircleuUITests): 28 tests, 24 passed, 3 failed, 1 skipped. The three failures are the known ones (no Simulator speech, and calendar labels under the Chinese Simulator locale at `GuestFindControlUITests` line 49 and `GuestStatesUITests` line 133). The new Welcome, empty Talk and Keep conversation checks passed.
- Not checked: a physical iPhone; how the README renders on GitHub was checked only after pushing.

## Handoff

- Owner: Katherine
- Remaining:
  - confirm the README's role wording, and the research numbers if she wants them added;
  - a Simplified Chinese localization, if she decides to build one;
  - a physical-iPhone check of the captured flows.
