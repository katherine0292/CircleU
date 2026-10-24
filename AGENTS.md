# CircleU

CircleU is a SwiftUI iPhone app for reflecting on difficult conversations and practising what to say. Preserve the existing project, user data and Git history.

## Read first

Read these files explicitly; do not assume a tool automatically expands references:
- [Project coding standards](docs/0_coding_standards.md).
- [Agent log protocol](docs/agent-collaboration-log/README.md), then the latest relevant dated entries and any handoff they reference.
- [MVP decisions](docs/product/mvp-definition.md) and the plan relevant to the task.

Shared baseline: `~/Documents/GitHub/coding-standards/coding_standards.md`. The project standards record deliberate Swift/iOS overrides; if the shared file is unavailable, use the local rules and report that limitation.

## Current direction — 24 October 2026

- Research/planning before feature coding; do not infer implementation approval from a prototype or plan.
- Approved: Today / Journal / Practice; circles and rewards deferred. The owner reaffirmed guest-first local use on 24 October after reviewing the account tradeoff. Welcome: Get started and optional Log in for existing-account recovery. See [onboarding](docs/design/account-onboarding.md). No new sync, cloud AI or automatic recovery approval.
- Existing code still contains Firebase, accounts, cloud AI and automatic backup paths. Local-only behavior is not implemented or verified.
- Previous TestFlight releases exist. Follow the [transition plan](docs/superpowers/plans/2026-10-23-local-first-transition.md); do not erase legacy data or remove recovery access.
- Proposed new device scope is separate from existing iOS 17/iPhone+iPad settings. See [device validation](docs/product/supported-devices.md).

## Working rules

- Keep SwiftUI feature folders and existing documentation paths; no notebook structure or bulk renaming.
- Inspect status/diff first and preserve unrelated work. Use `codex/` for new agent branches; never blindly stage all files.
- Run verification proportional to the change and state what was not run. Do not equate Figma inspection, simulator results and physical-device validation.
- Summarize meaningful work, decisions, review feedback and handoffs in a new dated log entry. Never rewrite published historical entries; append corrections with references.
- Record only actual agent exchanges. Keep credentials, personal journal content and raw chat/tool dumps out of logs.
- A collaboration log does not authorize extra agents, messages to other chats or external communications. Follow the active task's authorization and tool rules.

## Evidence

- [Documentation index](docs/README.md): product, design, architecture, QA and plans.
- [Agent collaboration log](docs/agent-collaboration-log/README.md): work history and unresolved handoffs.
- [Team process](docs/process/team-standards.md) and [Git workflow](docs/process/git-workflow.md).
