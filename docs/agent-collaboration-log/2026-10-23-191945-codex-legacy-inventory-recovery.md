# Inspect legacy Firebase and extend the recovery prototype

- Recorded: 2026-10-23 19:19:45 +11:00; Australia/Sydney.
- Agent / role: Codex, research, prototype and documentation.
- Status: partial inventory; requested Figma recovery examples updated. Actual TestFlight inspection blocked by App Store Connect sign-in.
- Base revision and branch: `2f28966`, `main`; earlier planning/process files remain uncommitted. No commit or push.
- Related record: [standards and log setup](2026-10-23-184408-codex-standards-and-log-setup.md).

## Request and scope

The owner requested checking the previous TestFlight version and Firebase setup, then updating recovery flows in Figma before coding. Scope was read-only release/backend research, editable prototype examples and supporting documentation. No Swift, Xcode configuration, backend data/rules, billing or release settings changed.

## Work and outcome

- Added the [legacy inventory](../engineering/legacy-data-inventory.md). Dev has 14 Auth accounts, Email/Password and Google enabled, and visible `users`/`circles` collections. Prod shows Auth/Firestore setup prompts. These observations do not establish the previous binary's backend or a complete data census.
- Verified current source maps Release to Prod and other configurations to Dev; CLI defaults to Dev. Current source version/build is not proof of an uploaded release. No default-location local Xcode archive was available.
- App Store Connect remained at sign-in. Asked the owner to authenticate in its browser tab without sharing credentials in chat; no response/sign-in was observed before handoff.
- Added [30 recovery sample states](../design/legacy-recovery-flow.md) in five Figma sections, connected from existing privacy/review entry points. Covered device preservation, verified-account recovery, unavailable versus empty backup, conflict/import choices, interruption/retry, export handoff and separate cloud-deletion status. Added older-device and account-help dependencies without inventing a working recovery service.
- Updated the [prototype manifest](../design/prototype-state.json), design references, privacy/transition planning and documentation indexes. Updated the [legacy QA checklist](../qa/testflight-firebase-checklist.md) to remove the assumed Dev target and obsolete blanket circle-write claim, and to protect existing installs/data during future restore tests.
- Recorded approved guest/local direction on the canvas while keeping implementation status explicit. Today/Journal/Practice remain the main navigation; circles/rewards stay deferred.

## Verification

- Live Figma audit: 1,712 structural assertions across 125 screen states; all reachable. The first target check misclassified seven component transitions; corrected action-type validation checked all 407 node-target actions (400 screen navigations, seven component transitions), with no invalid destinations. Ten sample timers exist.
- Visually inspected all five new sections and three updated entry screens. New-screen typography/bounds checks and the three entry-screen checks returned no errors. Long content uses scrollable areas above fixed actions. No browser-driven timing/cancellation test or participant study occurred.
- An initial Figma construction using wrapper frames failed destination validation; readback confirmed no new sections from that attempt. Native-section construction then succeeded; no duplicate recovery sections were created.
- Inline Python verification: nine changed/new Markdown documents, 73 relative links and the JSON manifest passed; manifest has 125 unique screen IDs and 21 sections. `git diff --check` passed. Final handoff validation also includes this entry.
- Repository status/diff inspection showed documentation changes only, including earlier work. New/untracked documentation was checked explicitly because ordinary diff omits it.
- Not run: app build, XCTest, simulator/physical-device QA, migration operations, real authentication/import/export/deletion or deployed-rules tests. Full deployed rules and private subcollection metadata remain unverified. Native Chrome inspection timed out; read-only Firebase inspection used the in-app browser instead.

## Discussion and decisions

Inter-agent exchanges: **None**. No extra agents or external messages were dispatched.

Owner direction remains planning before coding and guest-first local storage. Agent recommendations: preserve both Firebase projects until the shipped mapping is known; distinguish failed checks from empty backups; preserve accepted local edits; separate import from cloud deletion. These are prototype/implementation proposals, not completed migration behavior.

## Handoff

- Remaining work: owner signs in to App Store Connect; inspect previous builds and obtain corresponding configuration/schema evidence. Complete metadata-only data inventory, full rule comparison, retention and recovery-distribution decisions before implementation.
- Owner: account sign-in requires the user; subsequent inventory/implementation ownership is Unassigned. No other chat was messaged.
- Review the [new Figma guide](https://www.figma.com/proto/RVLtfmIVcO8gNk5fam0Vjd?node-id=65-1436&starting-point-node-id=65%3A1436). Full per-record import selectors, shared-circle ownership handling and account-support delivery remain dependencies.
- Firebase account/record counts are not tester counts or evidence of active usage. No real journal content, credentials or account IDs are included in these artifacts.
