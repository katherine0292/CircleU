# CI switched to manual runs only

- Recorded: 2026-10-25 20:55:26 +11:00; Australia/Sydney.
- Agent / role: Claude (Claude Code).
- Status: completed (owner-approved).
- Base revision and branch: `codex/ci-manual-only` from main.
- Related record: [Git workflow](../process/git-workflow.md).

## Request and scope

The owner asked why CI is needed and noted they don't use GitHub's automation. After the explanation (macOS Actions minutes on a private repository billed at 10×; each run about 13 minutes), the owner chose manual-only CI.

## Work and outcome

- `.github/workflows/ci.yml`: triggers changed from push/pull_request to `workflow_dispatch` only. The job is unchanged.
- `docs/process/git-workflow.md`: run the full suite locally (CI-equivalent signing config) before every merge and record it in the PR. Trigger CI by hand before TestFlight or when asked.
- From now on, PRs are merged on the local full test run plus Codex review; reports say so.

## Verification

Workflow YAML parsed; the full local suite was run before merge (see the PR). No CI run triggered.

## Discussion and decisions

Owner decision, relayed by the project coordinator. No inter-agent exchange.

## Handoff

- Remaining work: none for CI. PR #13 awaits the owner's look-and-feel answer.
- Owner: Mike.
