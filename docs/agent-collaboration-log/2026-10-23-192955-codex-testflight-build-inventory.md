# Verify the uploaded TestFlight build

- Recorded: 2026-10-23 19:29:55 +11:00; Australia/Sydney; account-role check completed later in the same turn.
- Agent / role: Codex, read-only release inventory and planning.
- Status: build metadata and current role verified; shipped Firebase/schema evidence remains unavailable.
- Base revision and branch: `2f28966`, `main`; pre-existing documentation changes remain uncommitted. No commit/push.
- Related records: [legacy inventory/recovery pass](2026-10-23-191945-codex-legacy-inventory-recovery.md), [plugin-status follow-up](2026-10-23-192051-codex-firebase-plugin-status.md).

## Request and scope

The owner confirmed App Store Connect sign-in, enabling the previously authorized TestFlight inventory. The owner subsequently explained that the uploading Mac was returned to the Apple Foundation Program. Only browser reads and repository documentation changes were performed.

## Work and outcome

The [inventory](../engineering/legacy-data-inventory.md) now identifies one visible upload, **1.0 (1)**, uploaded **11 June 2026**, **Expired**, with a validated binary and complete upload processing. The build list shows five invites, six installs and 143 sessions; these are aggregate display values, not unique people, current installs or a verified time-window analysis. Crashes/feedback show dashes, not proven zero.

Build Metadata verifies the existing bundle ID, iOS 17.0 minimum, iPhone/iPad family and arm64. The education team is **University of Technology Sydney (Edu)**; the user's profile lists **Developer, Marketing**, not Account Holder/Admin. Current project signing team matches the uploaded entitlement. No team membership or permission was changed.

The returned Mac means no original archive/IPA is currently available. App Store metadata does not reveal the bundled Firebase plist or storage schema. Preserve Dev and Prod; do not infer the shipped project from matching dates, current Release configuration or visible cloud activity.

Updated the inventory, supported-device plan, transition checklist, QA caveats, recovery-flow reference, flow-review status and prototype manifest limitation. The existing expired-build recovery scenario already represents the verified condition; no duplicate Figma screens or working download claim were added. Figma itself was not modified in this follow-up.

## Verification

- Read signed-in App Store Connect Apps, iOS Builds, expanded Build Uploads, Test Information, Build Metadata and the current user's General profile. No individual tester list or journal content was collected.
- `rg` checked current version/signing-team settings against uploaded metadata; current source's marketing version is 1.0.0 whereas the upload reports 1.0. This is not a source/binary equivalence check.
- Inline Python checked six edited Markdown documents, 17 relative links, whitespace and the JSON manifest (125 states); passed before this log was added. Final checks include this record.
- No builds, app tests, real upgrade/recovery operations, cloud queries/mutations, releases, invitations or messages were performed. Exact expiry timestamp, tester device distribution, complete backend inventory and shipped schema remain unresolved.

## Discussion and decisions

Inter-agent exchanges: **None**. The owner's clarification about the returned program Mac is recorded as reported evidence. Keep iOS 17/iPad recovery compatibility and existing installations; proposed new-MVP support remains a separate decision. Missing archival evidence is an explicit migration dependency, not justification to wipe existing data.

## Handoff

- Resolve the education team's continuing release arrangement and any ownership decision with its authorized administrator/account holder. No outreach was sent.
- If an existing archive backup appears, inspect it. Otherwise plan a data-preserving way to establish legacy schema/provenance from available evidence before implementation; do not promise access to the returned Mac.
- Complete tester-device and backend metadata/rule/retention inventory and review recovery scenarios before coding. Owner: Unassigned.

## Correction reference

The preceding records correctly reported sign-in as a blocker at that time. It is now resolved. Actual TestFlight version/build and compatibility are verified; Firebase mapping is still unresolved. Historical log entries remain unchanged.
