# Guest user stories, Today options and States mocks

- Recorded: 2026-10-26 11:20:00 +11:00; Australia/Sydney
- Agent / role: Claude Code (implementer), on Mike's Mac
- Status: completed; docs only; merged under the auto-merge rule
- Base revision and branch: `codex/user-stories` from `main` at `ed468fd`
- Related record / task / PR: Mike's Today brainstorm (illustrated mic, suggestions, background) and his user-stories question; coordinator briefs for the canvas mocks and the stories doc

## Work and outcome

- **[User stories](../product/user-stories.md):**
  - 25 counted stories with 76 Given/When/Then criteria, grouped by flow. Each criterion names its test.
  - Coverage: 60 criteria have a repo unit test (5 of them partial), 6 are covered only by out-of-repo UI tests, and 10 have no test.
  - The old on-device import flow (S6) can no longer be reached. It is listed separately and not counted.
- **[Art brief](../design/pingu-scene-art-brief.md):** six art pieces (ART-1 to ART-6) for the Today options.
- **CircleU Design canvas (private artifact):** no app code changed.
  - Today options: A (illustrated mic), B (Get a suggestion redesign: chips, a "Need a nudge?" bubble, one Save, a reflection offered after saving) and C (scene header, morning and evening backdrops).
  - A States page: mic denied, empty Journal, no results, backup copy failed, export done.
  - Every board title starts with its story ID.
- Linked from `AGENTS.md`, `docs/README.md` and `docs/design/README.md`.

## Verification

- **Full local suite:** passed (`** TEST SUCCEEDED **`). The suite ran with `DEVELOPER_DIR` set to Xcode, because `xcode-select` points at the Command Line Tools.
- **Script check:** every cited test exists, and the counts match the tables.
- **Not run:** UI tests (docs only); CI (manual).

## Discussion and decisions

**Codex** ([log](2026-10-26-111000-codex-review-user-stories.md)) found 6 blockers, all overclaims in the doc. All are fixed:
- S5.4 now has no test (its cited test covered the other import path).
- P1.2 is reworded to match its test.
- T3.4 is marked partial.
- W1.3 is narrowed to opening the journal without logging in.
- S6 is moved to "Kept but not reachable".
- S8 now says what is kept after deleting the account.

The minor notes became "(partial)" marks plus a note on the warm accent in the art brief. These are text-only fixes, so there was no second review.

## Handoff

- **Next PR (coordinator brief):** move the UI tests into the repo, then close the 10 untested criteria, starting with reset password (S7) and the backup copy failure (S5.4).
- Today A/B/C coding waits for Mike's choice.
