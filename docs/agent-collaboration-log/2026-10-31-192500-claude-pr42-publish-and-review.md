# PR 42: publish Codex's app-upgrade branch, rerun suites, one Codex review pass

- Recorded: 2026-10-31 19:25 +11:00; Australia/Sydney.
- Agent / role: Claude Code, publisher and test runner; Codex (gpt-6-astra, high, read-only reviewer) run by Claude Code.
- Status: merged under the auto-merge rule after owner picked "secure Codex's branch".
- Branch: `codex/app-upgrade-plan` on top of main `9967a10`; PR [#42](https://github.com/tuannm3812/CircleU/pull/42).

## Work

Pushed the previously local-only worktree branch, added the two 26 Oct Codex notes that were uncommitted in the main checkout, and opened the PR. Artwork masters and showcase exports (~90 MB) were kept as committed because the audit and QA reports link to them; Git LFS is a possible follow-up.

## Verification

Fresh reruns on this branch, iPhone 18 Pro Simulator / iOS 27.0, `CODE_SIGNING_ALLOWED=NO`:

- `Circleu` unit scheme: 276 passed, 1 device-only skip, 0 failures.
- `CircleuUITests`: 26 run, 25 passed, 1 live-Firebase skip, 0 failures.

Codex review (`codex exec -m gpt-6-astra`, read-only, Swift diff only): no blockers. One suggestion: widen the V5→V6 migration test in `GuestEntryTagTests.swift` to assert timestamps, all reflection fields, next-step completion and practice IDs/revisions. Not applied in this PR.

## Handoff

Remaining: message-first Practice in native, adoption of the remaining approved scenes, and the open audit gates (Firestore ownership rules, retired cloud model, release identity, legacy recovery).
