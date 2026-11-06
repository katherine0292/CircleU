# Contributions from the resume, versions by what changed

- Recorded: 2026-11-07 01:00:00 +11:00; Australia/Sydney
- Agent / role: Claude Code (desktop app, Katherine's Mac), documentation
- Status: completed
- Base revision and branch: `main` after PR #8, on `codex/contributions-resume`

## Request and scope

Katherine asked for four documentation changes:
- remove the contribution map;
- write her contributions as her resume describes them, with the commit and line totals from GitHub Insights;
- describe the three versions by how they differ, without names or dates;
- keep the README focused on the product and her strengths.

## Work and outcome

- **Removed:**
  - `docs/portfolio/katherine-contribution-map.md`;
  - the portfolio README draft, which the README replaces;
  - the contribution map's log entry.

  Links to them now point elsewhere or were dropped.
- **README:** *My contributions* follows the resume:
  - 130 commits and +11.7k lines (GitHub Insights);
  - concept and research with 20 participants (survey and in-depth interviews);
  - the MVP and user stories;
  - 10 usability sessions and heuristic evaluations;
  - the retest result;
  - the move to on-device Foundation Models;
  - AI experience rules, UI/UX, privacy, and delivery to TestFlight (6 installs and 143 sessions, per the legacy data inventory).
- **Versions:** the README and [How CircleU works](../product/how-circleu-works.md) compare the first MVP, the guest-first rebuild and the current redesign by structure, data, coaching, AI and look. Credits link the original team repository.

## Verification

- Documentation only. No code changed, so no tests were run.
- Links checked with `grep`; the README was checked on GitHub after merging.
