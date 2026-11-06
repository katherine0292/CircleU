# Three versions, folder map, edge fades and contributions

- Recorded: 2026-11-07 00:00:00 +11:00; Australia/Sydney
- Agent / role: Claude Code (desktop app, Katherine's Mac), UI fix, history review and documentation
- Status: completed
- Base revision and branch: `main` after PR #7, on `codex/talk-top-fade-role`
- Related record: [Podo and high-resolution screens](2026-11-06-233000-claude-podo-hires-readme.md)

## Request and scope

Katherine asked for five things:
- bigger screenshots in the README;
- a shorter contributions section without the title "product lead", covering every commit of hers, including the ten June commits co-written with Claude Code;
- a fix for scrolled cards showing through Talk's title;
- an explanation of the three versions: June's team app, Tuan's guest app, and her redesign;
- a recommendation on whether to regroup the code by version, whether Firebase is still used, and what each folder is.

## Work and outcome

- **Fix:** a new modifier, `guestFadesUnderTitle`, fades scroll content out under a see-through navigation bar.
  - It is used in the Talk thread and on the moment page, which had the same problem.
  - It extends past the bottom safe area, so words still fade behind a pinned bottom action instead of being cut off.
  - The fade height sits inside each page's top padding, so nothing is faded at rest.
- **History review:** the commit authors and dates show three versions:
  - version 1 (June, team of five);
  - version 2 (23–31 October, Manh Tuan Nguyen, 175 commits; `Features/GuestJournal` starts on 25 October);
  - version 3 (5–6 November, katherine0292, 94 commits, on top of version 2's files).

  The ten June commits with Claude `Co-Authored-By` trailers are among Katherine's 23 June commits. The 17 commits authored as `Claude` on 26 October are not attributed to anyone.
- **Overview:** [How CircleU works](../product/how-circleu-works.md) now has:
  - the three-version table;
  - a folder map (legacy, guest or shared, with the last real change);
  - the guest app's real dependencies on shared code (`Engines/ReflectionEngine`, `TranscriptQuality`, two old models for import, `FirebaseRuntime` for recovery);
  - why Firebase is still needed;
  - why the folders aren't regrouped;
  - which version added each guest flow.
- **README:**
  - it describes three versions, with who built each and why each changed;
  - screens are three per row (larger);
  - *My role* became a short *My contributions* section, split into version 1 and version 3, without the title;
  - credits name Tuan for version 2.
- **Screens:** captured again after the fix. Screen 07 is from the previous run, where Apple Intelligence answered; this run's reflection used the guided fallback.

## Discussion and decisions

**Regrouping by version** was not done, for three reasons:
- versions 2 and 3 share files;
- moving the legacy folders would touch hundreds of paths and make Tuan's upstream merges harder;
- AGENTS.md asks for no bulk renaming.

The clean step is deleting the legacy folders after two things happen: Release opens the guest app, and testers have had a chance to recover their data.

## Verification

- Capture walkthrough passed. The Talk and moment screens show no content under the title.
- Full suites (iPhone 17 Pro Simulator, iOS 26.5): unit 311 tests, 310 passed, 0 failed, 1 skipped; UI 28 tests, 24 passed, 3 failed, 1 skipped (the known three: Simulator dictation, two calendar tests under the Chinese locale).

## Handoff

- Owner: Katherine
- Remaining:
  - "What I learned" points in her own words;
  - the decision on when Release switches to the guest app (owner and Tuan).
