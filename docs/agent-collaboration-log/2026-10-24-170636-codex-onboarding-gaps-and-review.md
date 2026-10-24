# Focused onboarding review and missing-state completion

- Recorded: 2026-10-24 17:06:36 +1100; Australia/Sydney.
- Agent / role: Codex coordinator.
- Status: local prototype gap pass checked; owner feedback, Figma and production verification pending.
- Base revision and branch: `e8e148bdc44bfc4364b8f7a11fa47e774e6a23fc`, `codex/journal-calendar-planning`; starting tree clean.
- Related record: [flow checklist](2026-10-24-165140-codex-flow-status-checklist.md), following the [initial onboarding review](2026-10-24-164603-codex-onboarding-and-mvvm-review.md).

## Request and scope

Owner requested reviewing onboarding and completing missing steps before other screens. Extended the local design proposal only; no production implementation or broader screen refinement. Existing scoped documentation commit/push authorization applies.

## Work and outcome

[Focused QA/review](../qa/onboarding-flow-review-2026-10-24.md) records seven local states and the checked routes. Added an earlier-data choice before the old recovery handoff, Continue without importing, Opening/Locked/Read error, safe cancel/retry, nested navigation and simulated completed/incomplete re-entry. Kept the single short welcome, optional privacy and permission-free introduction. Clarified proposed cloud-AI/voice-permission copy and the later recovery entry point.

A new version of the inline conversation mockup preserves the previous one. Existing art/font are reused in display renditions; source assets and app/project files remain unchanged. Prototype controls and limitations are outside the phone. No disk/network service, import or real onboarding metadata operation was added. Reopen preview is a routing simulation, not an OS relaunch test. Current docs and F01/F02 checklist rows now distinguish this work from owner comprehension review, editable Figma and app readiness.

## Verification

- Browser exercised nested Privacy/Earlier-data returns from Welcome and Today; Continue without importing; Ready completion; incomplete/completed re-entry; pending cancel and late outcome; repeated locked/read-error failures; retry-to-ready and privacy returning to an error state.
- Found and reproduced a local defect: a previously completed user could select Read error on reopening and Back to welcome returned to Today, bypassing the failure. Changed cancel to always return Welcome. Targeted final rechecks confirmed both read-error and locked back paths stay at Welcome, Get started still gates, and readiness is required. Rechecked cancel during completed-user Opening and a late simulated Ready.
- Visual/DOM checks inspected Welcome, Earlier data, revised Privacy and error states; failure screen fit approximately 390 CSS pixels horizontally with actual bundled font loaded. Final browser error-log query returned no errors. No narrow-width, device, VoiceOver, actual storage, migration or process-death guarantee is claimed.
- Figma whoami confirmed the intended account and Starter/View metadata; a fresh known-node metadata read still returned the MCP call-limit error. No canvas edit or access/plan change. Existing recovery handoff URL was inspected, not rerun.
- Documentation links, scope and whitespace checked before publication. No Swift/Xcode test run required for the repository documentation changes. Final remote SHA/clean-tree checks accompany the scoped push; no CI pass claimed.

## Discussion and decisions

None. No other agents/chats or external communications. The added local states express existing storage/recovery requirements; detailed routing remains a proposal for owner review and later implementation. No new product features, release approval or user-study outcomes inferred.

## Handoff

- Remaining work: owner review of welcome/privacy/earlier-data wording and decisions; editable Figma completion once access permits; actual first-run metadata/storage, existing-draft re-entry, recovery handoff and accessibility/device checks in an authorized implementation task.
- Owner: Unassigned; no background work scheduled. Stay on onboarding before moving to other screens.
- Risks: current production app remains account/cloud capable. The local model contains no saved content and cannot establish preservation or recovery of real users' data.
