# Private-beta upgrade plan

- Recorded: 2026-10-27 01:28:37 +1100; Australia/Sydney
- Agent / role: Codex, planning
- Status: completed planning draft; implementation not started
- Base revision and branch: `9967a10`, `codex/app-upgrade-plan`; uncommitted documentation only
- Related: [quality pass](2026-10-27-005639-codex-practice-copy-quality.md), [design handoff](2026-10-26-193014-claude-to-codex-design-pass-handoff.md), [upgrade plan](../superpowers/plans/2026-10-27-app-upgrade-roadmap.md)

## Request and scope

The owner requested a detailed app upgrade plan and explicitly selected a polished private beta as the first milestone. This authorizes planning, not the entire proposed implementation or any release operation.

## Work and outcome

- Prepared seven packages: current baseline, core journey, accessibility, Figma/native consistency, storage/privacy qualification, user study, and release/legacy continuity.
- Mapped exact current code/docs/test locations, dependencies, priorities, acceptance gates, owner decisions and the recommended first batch.
- Confirmed from `AppStartup.resolve` that Release currently opens the legacy app; a routine archive does not ship the guest experience.
- Distinguished implemented Debug guest behavior from stale planning descriptions and legacy runtime; reconciliation is a proposed package, not a completed global documentation audit.
- Retained existing MVVM boundaries, SwiftData, Pingu/Plus Jakarta Sans direction, guest-first Today/Journal/Practice and deferred features.
- Added the plan to the documentation index. No source, project configuration, Figma, backend or installed app changes.

## Verification

- Reviewed against current guest stories, source startup/store boundaries, release/device/transition plans and dated handoffs.
- Carried forward the prior task's 256 passing unit tests and 19 passing UI tests / 1 skipped as dated baseline evidence; no app tests rerun for this documentation-only task.
- Relative-link/path validation and `git diff --check` performed before handoff.
- Self-reviewed scope, dependency order, proof ownership and release boundaries. No claim of completed hardware, study, backend or archive qualification.

## Discussion and decisions

Owner: “Polished private beta first (recommended).” Recorded as the selected milestone only. Other design/release choices remain proposed. No inter-agent exchanges in this planning task.

## Handoff

- Recommended next batch: approve package A plus B's consolidated phone walkthrough; then fix observed issues and complete accessibility checks.
- Owner: user for plan/batch review; implementation unassigned until selected.
- Release gating: separate valid distribution identity, tested guest Release configuration and legacy-recovery continuity are required before external distribution. No recruitment, invitations, uploads or purchases are authorized by this plan.
