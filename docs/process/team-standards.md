# CircleU team standards

Updated 23 October 2026 to apply the shared coding standard to this SwiftUI project. Coding and verification rules live in [project coding standards](../0_coding_standards.md); this document covers how contributors coordinate.

## Start and finish each meaningful task

Read [AGENTS.md](../../AGENTS.md), the latest relevant [agent records](../agent-collaboration-log/README.md), and the active product/implementation plan. Inspect the working tree before editing and preserve other contributors' changes.

Before handoff, record what changed, the evidence checked, decisions and remaining work in a new dated log entry. Include actual review feedback and its resolution. Never claim independent review if none occurred, and never treat an unverified handoff claim as fact.

The existing milestone is research/planning before feature coding. Follow explicit owner scope changes, recording them in the product decision tables and log. A plan, mockup or prototype does not itself authorize a release or prove implementation.

## Ownership and coordination

| Area | Responsibility |
| --- | --- |
| `Circleu/App/` | Composition, lifecycle and navigation; nominate one integration owner when work overlaps |
| `Circleu/Features/` | Feature screens and ViewModels |
| `Circleu/Components/`, `Circleu/Design/`, assets | Shared UI and visual foundations |
| `Circleu/Models/`, `Stores/`, `Engines/`, `Services/` | Data contracts, state/persistence, business logic and system/provider boundaries |
| `CircleuTests/` and QA docs | Behavior evidence and device validation |
| Project file, package resolution and CI | Shared integration changes; coordinate rather than edit concurrently |
| Product/design/process docs | Update the existing source of truth, with links from the log |

These are responsibility boundaries, not permanent assignments to named people. For authorized multi-agent work, specify owned files, dependencies and integration order. Use distinct log filenames; the integration owner reviews the combined diff and records final verification. Do not launch or message other agents merely because the process supports collaboration.

## Review and Git

Use small, coherent changes and scoped Conventional Commits. Prefer `codex/<topic>` for new agent branches. Inspect and stage only intended files/hunks; never gather unrelated work with a blanket add. See [Git workflow](git-workflow.md) for the sequence.

Reviews should state the concrete behavior/risk, affected path, evidence and proposed resolution. Record accepted, rejected and unresolved findings in the log, including failed hypotheses that could otherwise be repeated later. Append corrections; preserve historical conclusions as history.

## Documentation and evidence

- Product/user-flow decisions: `docs/product/`.
- Architecture/domain/backend contracts: `docs/engineering/`.
- Figma reference and review history: `docs/design/`.
- Device/manual checks: `docs/qa/`.
- Current implementation plans: `docs/superpowers/plans/`.
- Agent work/review handoffs: `docs/agent-collaboration-log/`.
- Superseded plans/specs: `docs/archive/`; do not treat them as current instructions.

Update affected docs with the corresponding behavior/process change. Keep code, prototype and release claims separate. Use the verification matrix in the project standards; documentation changes do not require a simulator build, while speech/AI claims need hardware evidence.
