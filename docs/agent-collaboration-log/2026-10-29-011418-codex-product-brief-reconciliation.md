# Product brief, stories and flow reconciliation

- Recorded: 2026-10-29T01:14:18+11:00; Australia/Sydney
- Agent / role: Codex / documentation reconciliation
- Status: completed (documentation only)
- Base revision and branch: `9967a10`, `codex/app-upgrade-plan`; extensive pre-existing uncommitted work preserved. No commit/push.
- Related record: [communication-style prototype](2026-10-29-communication-style-prototype.md), [native Practice review](../qa/native-practice-2026-10-27/README.md).

## Request and scope

Owner asked to update the product brief first, then use briefs and user stories to track work and refine UI. No app/prototype code, live AI, cloud or release work in this turn.

## Work and outcome

- Updated [product brief](../product/overview.md) first: audience, private-beta target, three destinations, Refine, optional communication style, data boundaries, deferred features and approval/evidence distinctions.
- Reconciled [MVP requirements](../product/mvp-definition.md): retained M01–M08, added proposed M09/M10, corrected save-original-before-reflection flow and obsolete claims that no guest implementation/calendar exists.
- Extended [stories](../product/user-stories.md) with proposed P7/P8/S9 criteria for feedback, explicit payload sharing and optional preferences. Existing native test references retained; proposed tests are clearly not implemented/passing tests.
- Replaced obsolete [flow status](../product/flow-status-checklist.md) with F01–F24 mappings, scoped evidence and concrete next reviews. Kept F01–F22 identities.
- Updated [documentation index](../README.md) and [project standards](../0_coding_standards.md) to require brief → requirements → stories → flow-status traceability. Corrected the standards' stale blanket unimplemented-local claim without removing Release/cloud cautions.

## Verification

- Python checks: 129 local Markdown links (including anchors) resolved across the six edited documents; 10 unique M feature IDs, 24 unique F flow IDs and 131 unique story criteria, no duplicate criteria.
- `git diff --check -- docs/README.md docs/0_coding_standards.md docs/product/overview.md docs/product/mvp-definition.md docs/product/user-stories.md docs/product/flow-status-checklist.md` passed.
- Reviewed current criteria and dated native/prototype evidence; no new native pass claimed. The 27 October unit/UI/device evidence is inherited, with partial coverage and failed-first-UI-run limitations retained in its source.
- Not run: Xcode builds, app tests, live provider evaluation, Figma updates or device checks; this is documentation-only work.

## Discussion and decisions

Inter-agent exchanges: None. Owner requested brief-first tracking. Proposed durable style/export/deletion and feedback criteria remain review targets, not implementation or cloud-activation approval. The next recommended UI review is Refine/style, followed by Today and Journal preserving existing native functionality.

## Handoff

- Remaining work: review P7/P8/S9 against the browser prototype, resolve the native slice, then implement only with task authorisation and attach scoped tests. Keep existing capture/calendar features during UI refinement.
- Owner: Unassigned.
- Open gates: research and success thresholds, supported-device matrix, legacy recovery/distribution, full guest suites before merge, physical accessibility/error paths and live-provider qualification.

## Correction reference

The previous overview/MVP/checklist described older planning snapshots as current. This reconciliation uses the linked 27 October native and 29 October prototype evidence to distinguish guest implementation from unchanged standard Release paths. Historical dated logs were not rewritten.
