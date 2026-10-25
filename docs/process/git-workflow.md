# CircleU Git workflow

Follow [project coding standards](../0_coding_standards.md) and [team coordination](team-standards.md). These instructions describe the workflow; they do not automatically commit, push, merge or release work.

## Inspect before changing branches

```sh
git status --short --branch
git diff --stat
git diff
```

Read new/untracked files separately: ordinary `git diff` does not include them. Preserve unrelated edits. Reuse an appropriate feature branch/worktree; for new agent work, use `codex/<topic>`. Do not switch to main, reset, stash or merge over a dirty checkout as an automatic startup step.

When a new branch is appropriate and the starting point is verified:

```sh
git switch -c codex/short-description
```

This starts from the current commit; inspect it first. Fetch and integrate upstream when needed for the task, resolve conflicts deliberately, and rerun checks affected by integration. Do not force-push shared history.

## Verify and stage a coherent change

Use the [verification matrix](../0_coding_standards.md#4-verification-and-evidence), then inspect the final diff and record results in the [agent log](../agent-collaboration-log/README.md).

```sh
git diff --check
git status --short
```

Stage explicit files or hunks. For example, only when these changes form the intended reviewed scope:

```sh
git add AGENTS.md CLAUDE.md docs/0_coding_standards.md
git diff --cached --stat
git diff --cached
```

Include related documentation/log entries deliberately; the example is not a complete staging list. Avoid `git add .` or `git add -A` in a shared working tree. Check credentials, local configuration, generated files and unrelated work are absent from the staged diff.

## Commit and push within task scope

Use `<type>(<scope>): <imperative summary>`, for example:

- `docs(process): add agent collaboration records`
- `fix(journal): preserve draft after failed save`
- `test(storage): cover interrupted migration recovery`

One coherent change per commit. Explain material behavior, verification and limitations in the body; no invented passing checks. Do not amend another contributor's history without authorization.

When committing/pushing is part of the authorized task, confirm the target remote/branch, push without force and verify the result:

```sh
git status --short --branch
git remote -v
git push -u origin HEAD
```

A clean push is not a CI pass. Inspect actual check results before claiming validation. A draft PR may record incomplete validation clearly; do not merge or release while required checks remain unresolved.

**CI is manual (owner decision, 25 October 2026).** GitHub Actions macOS minutes on this private repository are billed at 10×, so `.github/workflows/ci.yml` runs only when started by hand (Actions tab → iOS CI → Run workflow). Before every merge, run the full test suite locally with a CI-equivalent signing configuration (`Config/Signing.xcconfig` generated from the example, `CODE_SIGNING_ALLOWED=NO`) and record the result in the PR. Trigger CI by hand before a TestFlight build, or when the owner asks.
