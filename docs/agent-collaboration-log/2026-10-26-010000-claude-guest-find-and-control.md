# Batch B: search, calendar, Settings, export, delete all, Practice drafts

- Recorded: 2026-10-26 01:00:00 +11:00; Australia/Sydney
- Agent / role: Claude Code (implementer), on Mike's Mac
- Status: completed; merged under Mike's auto-merge-when-green rule
- Base revision and branch: `codex/guest-find-and-control` from `main` at `85cabfe`
- Related record / task / PR: [gap analysis](../product/original-vs-mvp-gap-2026-10-25.md); MVP M06/M07; flows F14–F16, F20; [QA record](../qa/guest-batches-2026-10-25.md); [UI feedback backlog](../design/ui-feedback-backlog.md)

## Request and scope

Batch B of the gap analysis. Guest journal only; nothing leaves the phone; the earlier app's data is never touched.

## Work and outcome

- **Search:** Journal search covers words, reflection and next step, ignoring case and accents. Practice history also has search.
- **Calendar:** a month view in Journal with marked days.
  - Choosing a day filters the list; **Go to today** and **Show all** are available.
  - Accessible labels give each day's entry count.
  - The button is named "Go to today" so it doesn't clash with the Today tab.
- **Settings** (gear on Today):
  - **Privacy and data:** says everything stays on the phone, and that device backups may include it, restoring an older backup can bring back deleted things, and saved exports aren't deleted.
  - **Export my data:** a readable text file through the share sheet. It reads one consistent snapshot, never produces a partial export, and its temporary folder is emptied after sharing, at launch and by Delete all.
  - **Delete all data:** explicit scope. Everything goes in **one store transaction**: entries, reflections, steps, practice, receipts and drafts. A failure removes nothing.
- **Drafts in the store:** drafts now live in the SwiftData store (schema V4, `KeptDraftRecord`, one row per slot). Draft files from earlier builds are adopted once, in a transaction that marks them adopted, so they're never re-imported. Unreadable files are left with a warning and removed by Delete all.
- **Practice drafts:**
  - kept across relaunches, with **Continue your draft**;
  - saved-draft receipts stop a saved draft coming back;
  - a draft from somewhere else is never replaced silently;
  - only the newest screen writes a draft;
  - a screen closed by Delete all can't save;
  - bursts of typing are coalesced into one write.
- **Write draft:** restore fails closed if the store can't say whether the draft was saved or deleted. This deliberately changes the first slice's restore-on-unknown rule.

## Verification

- **Full local suite** (CI signing config, iPhone 17 / iOS 26.5 Simulator): **221 passed, 0 failed, 1 skipped** (device-only).
- **Out-of-repo XCUITests** (iPhone 18 Pro / iOS 27.0), seven passed:
  - search;
  - calendar day filter;
  - Practice draft across a relaunch;
  - export share sheet;
  - Delete all, with nothing back after a relaunch;
  - all earlier guest flows.
- **Not run:**
  - real crash injection and cold-reopen tests;
  - batching of spaced typing (each spaced keystroke is a small store write, as the file write was before);
  - device check (Mike's phone check);
  - CI (manual by owner decision).

## Discussion and decisions

Codex ran six rounds ([1](2026-10-26-001000-codex-review-guest-find-and-control-round-1.md), [2](2026-10-26-002000-codex-review-guest-find-and-control-round-2.md), [3](2026-10-26-003000-codex-review-guest-find-and-control-round-3.md), [4](2026-10-26-004000-codex-review-guest-find-and-control-round-4.md), [5](2026-10-26-005000-codex-review-guest-find-and-control-round-5.md), [6](2026-10-26-006000-codex-review-guest-find-and-control-round-6.md)).

- **Rounds 1–4:** they kept finding crash-recovery edge cases in the file-staging approach to an atomic Delete all.
- **After round 4:** I replaced that design with store-kept drafts, which removes those classes of bug.
- **Round 6:** one narrow blocker (a protection error skipped the old-file cleanup) and one warning-priority item, both fixed in the final commit without re-review, since the fixes were trivial.
- **Follow-ups:**
  - batching of spaced typing;
  - cold-reopen and interruption tests.
- **Owner decision recorded:** Mike's request for more Pingu art and icons supersedes the earlier "restrained illustrations" choice. It is planned as the UI polish batch.

## Handoff

- Remaining work:
  - Mike's phone check for batch B;
  - the UI polish batch (backlog item 1);
  - batch C, which needs Mike's OK for importing old-app data.
- Owner: Claude (polish); Mike (phone check, batch C decision)
- Risks / unresolved questions: no real crash-injection testing.
