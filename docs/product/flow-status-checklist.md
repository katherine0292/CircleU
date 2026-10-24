# CircleU flow and delivery checklist

Updated 24 October 2026, Australia/Sydney. Core-flow snapshot through `e8e148b`, subsequent native-onboarding evidence through `84476ba`, and the required-account planning revision. This tracks the agreed MVP and its supporting work; it does not approve production implementation.

**Prepared** means the named plan, wireframe or preview exists. **Partial** means some design or verification is still missing. **Pending** means the stated outcome has not been established. No percentage-complete estimate is used: a screen image, connected Figma state and working app feature are different deliverables.

## Current position

**Latest access decision:** required accounts replace guest entry. See [account onboarding](../design/account-onboarding.md) and [content rules](../design/content.md). Existing guest-entry specimens remain historical evidence; the new Welcome/account routes are planned, not implemented. Cloud content sync/AI/backup is not newly approved.

- [x] Agree Today / Journal / Practice and deferring circles/rewards; replace guest entry with required accounts (24 October).
- [ ] Reconcile authentication, account-scoped local content, offline sessions and recovery before implementation.
- [x] Prepare connected core and recovery wireframes in Draft 02; the earlier audit documents 125 reachable screen states. This is historical prototype evidence, not real authentication, storage or deletion.
- [x] Prepare branded SwiftUI hubs, editors, reflection/direct-practice journeys and Journal calendar specimens.
- [x] Store the accepted Pingu direction, logo/font references, illustrated icons and 21-avatar collection.
- [x] Build an isolated native motion comparison and check selected Mac interactions; capture initial layouts on two iPhone Simulators.
- [x] Prepare a clean local onboarding proposal and its copy/flow handoff.
- [x] Extend local onboarding with earlier-data choices, simulated opening/locked/read-error states and checked nested return/re-entry routes; correct the failed-read back-route bypass.
- [ ] Apply that onboarding and accepted branding to an editable Figma prototype; remove review-only text from the depicted screens.
- [ ] Complete owner walkthroughs and record observations. The existing worksheet contains no completed sessions.
- [ ] Approve the detailed implementation scope and validate authentication, local-content and recovery boundaries before production coding.

The existing Swift app has MVVM and account/Firebase/cloud paths. Neither the prior guest-local proposal nor the revised required-account experience is implemented or verified by these specimens.

## Main journeys

These are intended routes, not a claim that every transition runs in the production app:

1. **First use:** Welcome → Sign up / Log in → authenticated workspace readiness → Today. No guest route. Privacy and earlier-data recovery remain accessible before entry; forms and session policy are pending.
2. **Reflection:** Today → type a situation → review/edit reflection → save → Journal entry detail. Save only my words is an alternative; Practice and a next step are optional.
3. **Voice:** explicit recording action → permission/capability check → record → review/edit transcript → reflection or words-only save. Typing remains available.
4. **Direct Practice:** Today / Practice → situation, goal and optional draft → wording → edit → Copy and/or Save → Practice detail/history.
5. **Linked Practice:** saved reflection → review selected context → wording/edit → Copy and/or Save → linked result. A changed source requires review of earlier wording.
6. **Retrieval:** Journal list/calendar/search → saved detail → edit/save/reopen; standalone messages stay in Practice history.
7. **Data control:** Settings or entry options → review scope → export/delete → confirmed outcome or recoverable failure.
8. **Earlier data:** explicit recovery route → verify source/ownership → preview → preserve/export/import → verify outcome; old-account deletion is a separate choice.

## Flow-by-flow status

“Next” describes work still required for the prototype/review milestone. All production acceptance criteria remain subject to the implementation and validation gates below.

| ID | Flow | Prepared / checked so far | Next / pending |
| --- | --- | --- | --- |
| F01 | Welcome and required account | Previous guest-entry specimens/checks retained; new account/artwork/copy brief prepared, not implemented | Review and build account Welcome/forms, reset/error/session/recovery routes; verify readiness and large-text gestures. Production still has signup/signin/Skip |
| F02 | Privacy before/after starting | Draft 02 states; local optional details and nested return paths checked, including earlier-data choice and storage failures | Review understanding of device backups, data-loss limits and earlier-account separation; reconcile release copy with actual behavior |
| F03 | Today and main navigation | Three-tab structure approved; wireframes, branded hub and empty-Today proposal | Consolidate branded Figma; distinguish first visit, retained draft and returning saved history |
| F04 | Typed situation capture | Wireframe and branded capture, including words-only exit | Walk through input clarity, validation and route choices; real capture is not implemented in static boards |
| F05 | Voice, permissions and transcript | Wireframe recording/transcript/denied/interruption scenarios | Review optional entry and interruption recovery; verify actual microphone, on-device recognition and text fallback on devices later |
| F06 | Reflection review and correction | Tentative interpretation separated from original words; branded review/editor | Review edit discoverability and ability to reject suggestions; complete consistent branded Figma |
| F07 | Save only original words | Wireframe branch and branded action/detail specimens | Walk through note-only save and reopening without an accepted interpretation |
| F08 | Saved reflection edit/discard/reopen | Connected preset Figma states; native isolated editor has real text input and simulated Save feedback | Owner walkthrough of Save/Discard/Keep draft meanings; actual persistence, stable identity and relaunch verification later |
| F09 | Unsaved draft, leave and return | Keep/discard/continue wireframe scenarios; native samples retain in-process drafts | Review copy and destinations; app relaunch/process-death restoration is unverified |
| F10 | Direct Practice | Context/goal, wording and saved-detail wireframes plus branded specimens | Review usefulness, tone/goal selection and standalone history; rebrand connected Figma |
| F11 | Practice from a reflection | Selected-context and changed-source specimens; linked-result wireframes | Walk through explicit context choice and edit ordering without changing the other saved item |
| F12 | Message editing, Copy and Save | Preset edit/copy/save/reopen wireframes; native text input, validation and independent feedback checked | Review Copy versus Save comprehension; real clipboard, saving and latest-version reopening remain unverified |
| F13 | Optional next step | Optional placement in entry/result; chosen/none wireframe variants | Review skip/edit/postpone/reverse behavior; avoid introducing a separate mandatory quest journey |
| F14 | Journal list, details and search | List/detail/reopen wireframes; branded hub/detail specimens | Walk through finding the intended latest version; first-use empty Journal and real search need validation |
| F15 | Calendar and date retrieval | Saved-day, empty-day and multiple-entry static views; decorative header icon removed | Decide date selection, month changes, Today, All entries, search return, locale/time-zone and adequate hit areas; interactive calendar not built |
| F16 | Standalone Practice history | Wireframe matching saved/edited messages and branded Practice hub/detail | Review history retrieval and source distinction; keep standalone messages out of Journal date counts |
| F17 | Changed original words / stale suggestions | Source-changed, regenerate and revised words-only wireframes; branded linked-context comparison | Review warning, retained draft and regeneration choices; runtime cancellation/revision behavior later |
| F18 | Loading, invalid input and failures | Cancellable loading, empty input, failed generation/save/copy and preserved-edit scenarios in Draft 02 | Walk through each representative recovery path; native demo does not simulate real I/O failures |
| F19 | Offline, model unavailable and protected storage | Manual-fallback, unavailable-model, read-failure and locked-storage wireframes/plans | Validate useful manual flow and distinguish unavailable/failed/empty; verify actual capability and network boundaries later |
| F20 | Export, deletion and linked content | Scope choices, cancellation/retry, linked-data choices and failure wireframes | Review exact scope and confirmation; real exports, atomic deletion and no resurrection require implementation tests |
| F21 | Previous device/account/cloud data | Legacy recovery wireframes; TestFlight/Firebase and format research recorded | Add unresolved ownership and portable-archive gaps; establish shipped Firebase mapping, preserved sources and authorized recovery distribution |
| F22 | Old-account deletion and management | Separate reauthentication/pending/failure/completion wireframe route | Resolve shared-content scope and provider/backup limits; verify ownership, partial failures and actual completion later |

## Cross-cutting checklist

### Prototype finish

- [x] Complete publisher-based [onboarding/content research and font audit](../design/onboarding-patterns-research-2026-10-24.md); shorter copy and finite motion are in the local onboarding review. Other-screen copy, owner comprehension and native accessibility remain pending.
- [ ] Review artwork-led Welcome, Sign up / Log in forms, reset/validation/error states, privacy access and earlier-data recovery under the new required-account brief.
- [x] Complete the coordinator's [focused onboarding checks](../qa/onboarding-flow-review-2026-10-24.md); owner comprehension review and production verification remain pending.
- [ ] Resolve Figma MCP access before attempting canvas work. The focused onboarding pass rechecked a known node and still received the Starter-plan tool-call limit.
- [ ] Bring accepted Pingu artwork, Plus Jakarta Sans and brand colors into the connected editable Figma screens, preserving the existing recovery coverage.
- [ ] Move Sample / Draft / Brand demo / preset-state instructions outside depicted phone screens. Keep genuine validation, capability, storage and error messages. Existing Figma/SwiftUI boards have not received this file-wide cleanup.
- [ ] Settle F15 calendar behavior and connect the approved cases; static tiles are not interaction evidence.
- [ ] Complete the five tasks in the walkthrough worksheet and add the onboarding check. Record actual assistance, misunderstandings, changes and retests.
- [ ] Check icon-only editing discoverability, readable type, contrast and motion comfort; resolve critical findings before freezing the prototype.

### Swift and production readiness

- [x] Identify the existing MVVM structure and feature folders; a wholesale architecture conversion is unnecessary.
- [ ] Approve the detailed first production slice. Proposed order remains manual typed capture → reliable local save → Journal/detail → edit/reopen, after the revised authentication/local-storage feasibility work.
- [ ] Validate versioned/protected storage, draft retention, interrupted writes, disk-full/read errors, stable IDs and linked operations.
- [ ] Revise the dependency graph for required authentication and account-scoped local content, without automatically activating legacy sync/cloud AI/backup. Define offline/session behavior; verify launch, background/resume and late callbacks. Keep explicit legacy management separate.
- [ ] Verify on-device model and speech availability, cancellation and useful manual fallbacks; do not infer availability from a Simulator or mock.
- [ ] Test original versus accepted edits, stale suggestions, retries, duplicate saves, Copy independent of Save, deletion and relaunch recovery.
- [ ] Keep small Views, screen-level ViewModels and injected Store/Engine/Service boundaries; refactor the authorized slice rather than migrating every observable type at once.

### Device, accessibility and release gates

- [x] Check isolated motion-demo launch/layout on iPhone 18 Pro/iOS 27.0 and iPhone 17e/iOS 26.5; these are not full-app qualification.
- [ ] Finish live iOS keyboard/Done, scrolling, rotation, motion/lifecycle and focus checks. The last task could not resolve a Simulator GUI despite working CLI runtimes.
- [ ] Validate physical-device voice/model/offline behavior, Dynamic Type, VoiceOver, real system Reduce Motion, dark mode and compact layouts.
- [ ] Resolve new-MVP supported OS/device scope separately from the legacy iOS 17/iPad recovery requirement.
- [ ] Establish a passing main-app build/test baseline and appropriate CI toolchain; prototype builds and a Git push are not CI/release passes.
- [ ] Resolve the personal Apple distribution route and necessary UTS involvement; the last recorded account status is UTS team access only, with no separate paid personal enrollment confirmed.
- [ ] Complete legacy source/ownership inventory, safe export/import/recovery and explicit old-account controls before narrowing access or retiring cloud dependencies. The exact shipped Firebase mapping remains unresolved in the recorded research.
- [ ] Qualify all P0 criteria, observed privacy/network behavior and release declarations before beta distribution. No merge, upload, enrollment, transfer or release is authorized by this checklist.

## Recommended next order

1. Review F01–F03 now using the local onboarding and agreed main navigation.
2. Finish editable branded Figma onboarding and review-label cleanup when MCP access is available.
3. Walk through F04–F12: one reflection, original-words save, edits, direct/linked Practice, Copy and Save.
4. Decide F14–F16 retrieval/calendar behavior and inspect F17–F22 recovery/data-control cases.
5. Record owner walkthrough findings and run the planned research sessions; none have been recorded as complete. No outreach is authorized by this checklist.
6. Agree the implementation specification and first slice while resolving local-runtime feasibility and legacy/release prerequisites. Then code and validate in the appropriate order.

These are priorities, not scheduled background jobs, dates or agent assignments. Circles, rewards, streaks/badges, community, cross-device sync, screenshot understanding and multi-turn roleplay remain deferred. Gentle follow-up is optional P1 and remains outside the first core pass.

## Evidence and maintenance

- [MVP and P0 acceptance criteria](mvp-definition.md); [research plan](research-findings.md).
- [Draft 02 reference and earlier structural checks](../design/README.md); [legacy recovery coverage and gaps](../design/legacy-recovery-flow.md).
- [Clean onboarding proposal / Figma continuation](../design/brand-demo/onboarding-review.md).
- [Branded core routes](../design/brand-demo/core-journeys.md); [lighter icon variant](../design/brand-demo/lighter-icon-journeys.md); [calendar](../design/brand-demo/journal-calendar.md).
- [Motion evidence and limitations](../design/brand-demo/motion-demo.md); [walkthrough worksheet — no completed sessions](../design/prototype-review-results.md).
- [Architecture](../engineering/architecture.md); [local-first transition tasks](../superpowers/plans/2026-10-23-local-first-transition.md); [legacy inventory](../engineering/legacy-data-inventory.md).
- [Device matrix](supported-devices.md); [personal-account release research](personal-account-release-plan.md); [privacy/storage](privacy-storage-plan.md).

Update this checklist after a meaningful completed task or new evidence; do not mark a prototype row production-complete because a screenshot looks finished. Link an observed walkthrough result or runtime check before changing a validation status. This document organizes existing decisions and work; source plans retain the detailed contracts.
