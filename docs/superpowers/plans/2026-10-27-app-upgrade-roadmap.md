# CircleU App Upgrade Plan

> **For agentic workers:** Planning draft, not authorization to implement every task. After the owner approves a bounded batch, use `superpowers:executing-plans`; use subagents only when separately authorized or required by the applicable review workflow. Steps use checkboxes. Keep release and legacy-recovery decisions explicit.

**Goal:** Turn the existing guest app into a coherent, dependable private beta, then qualify a safe public-release route without losing earlier users' data.

**Architecture:** Retain SwiftUI and the existing View → ViewModel → Store/Engine/Service → Model boundaries. Keep the SwiftData guest store, explicit account-recovery boundary and useful manual/guided paths. Improve the existing flows in small, independently reviewable batches; no rewrite or blanket MVVM migration.

**Tech stack:** SwiftUI, SwiftData, XCTest/XCUITest, on-device Speech and optional Foundation Models; existing Firebase adapters only for explicit earlier-account operations. Figma is the design review reference; native code is the runtime source of truth.

**Spec and evidence:** [MVP decisions](../../product/mvp-definition.md), [current guest stories](../../product/user-stories.md), [screen-content rules](../../design/screen-content-guidelines.md), [transition plan](2026-10-23-local-first-transition.md), [latest quality pass](../../agent-collaboration-log/2026-10-27-005639-codex-practice-copy-quality.md), [design handoff](../../agent-collaboration-log/2026-10-26-193014-claude-to-codex-design-pass-handoff.md).

**Status:** Proposed 27 October 2026. The owner selected a polished private beta as the first milestone, then asked to prioritize UI sooner for a design competition and authorized two agents (frontend and backend). Detailed work-package scope and new design/release decisions remain proposed. This document authorizes no new runtime, cloud, distribution or design changes. It schedules no background work.

## 1. Where we are now

Baseline: merged [PR #41](https://github.com/tuannm3812/CircleU/pull/41), main `9967a10`; its source tree matches tested fix `c1ca782`.

| Area | Existing evidence | Remaining gap |
| --- | --- | --- |
| Core app | Today, Journal, Practice; capture, drafts, reflection review, editing, search/calendar, standalone/linked messages, export and deletion exist | Whole current-build walkthrough on the owner's phone; completeness is not inferred from screenshots |
| Branding | Soft dimensional Pingu art, 21 avatars, illustrated icons and Plus Jakarta Sans are already used in the guest UI | Cross-screen consistency, small-size readability, accessibility and approved motion choices |
| Storage | Versioned SwiftData with draft adoption, revision checks, linked operations and failure tests | Physical file protection, genuine process interruption, representative size/performance and upgrade qualification |
| Recovery | Optional earlier-account login, preview/copy, reset request and deletion paths exist | Deployed behavior, ownership, account scope, partial failures and release identity still need qualification |
| Automated tests | Latest pass: 256 unit tests; 20 UI tests executed, 19 passed, 1 live-Firebase test deliberately skipped, no failures | Hardware, VoiceOver, software-keyboard visibility, real model availability and actual backend evidence remain separate |
| Story inventory | 29 stories / 101 criteria; 2 without automated checks and 20 marked partial | Prioritize important missing assertions, not increasing counts for their own sake |
| Figma | UTS file accessible; Screens and options / States; copied from the 26 October canvas | Snapshot includes alternatives and older placeholder art; it is not an automatically synchronized design system |
| Shipping | Debug guest build exists; earlier TestFlight app exists under UTS | `AppStartup.resolve` still selects the original app in Release. A routine archive does not ship this new guest experience |

Old descriptions of “local-first not implemented” in AGENTS, architecture and planning docs are stale for the Debug guest app, but removing them must not imply the legacy Release app has become local-only. The older `release-readiness.md` includes circles, rewards and automatic backup checks; it cannot serve as the guest-beta checklist unchanged.

## 2. Direction and constraints

- Preserve Today / Journal / Practice and guest-first use. Optional Log in is for existing-account recovery, not a signup requirement.
- Preserve the original native proportions, accepted palette, Plus Jakarta Sans and existing Pingu identity. Discuss significant visual changes before implementation.
- Reuse artwork, icons and view helpers. No new font, illustration collection or token system just for variety.
- Every flow must remain useful without a model, microphone permission or an account. No silent cloud fallback.
- Keep original words separate from suggestions and accepted edits. Copy, Save, local deletion and account deletion must stay distinct.
- Keep concise sentence-case content, accessible names, at least 44-point interactive targets and one primary filled action per screen, following the content rules and documented exceptions.
- Preserve the existing iOS 17/iPhone+iPad project configuration until the supported-device and legacy route decisions are made. Proposed new-beta scope is not a deployment-setting change.
- Guest Test identity remains `com.tuannm3812.circleu.guesttest` for in-place development updates. Never uninstall to refresh or install over the real CircleU identity.
- Do not collect journal text in analytics, screenshots, logs or study records. Use invented scenarios for automated tests and review artifacts.
- Circles, rewards/streaks, mandatory accounts, new Google/X/Facebook sign-in, sync, cloud AI, live roleplay, Android/web and dark-mode redesign remain outside this upgrade's first milestone.

## 3. Approach and priority

| Approach | Benefit | Cost / limitation | Recommendation |
| --- | --- | --- | --- |
| Polish and qualify the existing guest app | Fastest route to learning whether the core task works; reuses substantial implementation | Requires discipline about hardware checks and the Debug/Release split | Recommended first milestone |
| Redesign every screen in Figma first | Useful if the owner rejects the current interaction direction | Delays testing, duplicates accepted work and cannot prove keyboard/storage behavior | Use only for a specific unresolved flow |
| Start with public distribution and recovery | Addresses ownership and legacy users early | Depends on account/UTS access and source-data evidence; does not establish product usefulness | Research in parallel; make it a release gate |

Priority meanings: **P0** = data, privacy, blocked task or release correctness; **P1** = usability/accessibility needed for beta; **P2** = optional polish chosen after the core passes. These are priorities, not invented deadlines.

Dependency order: **A → B/C → D → E → F → G**. Release-route research in G can begin while B–E run. D's reliability evidence is required before an external install; E's preliminary usability research can use a controlled owner-hosted prototype before distribution is available.

## Competition priority — owner update, 27 October

**Submission clarification:** the owner identifies UTS UI Showcase / UTS Tech Fest 2026 and needs a poster, video and presentation. The first [poster concept](../../design/brand-demo/poster-01/README.md) and [artwork/motion review](../../design/brand-demo/asset-expansion-05.md) now exist; the video and slide deck have not been produced. These materials are the immediate deliverables. A guest TestFlight build is a conditional requirement, not inferred from this submission list.

**Date/brief unresolved:** the [official UTS festival page](https://www.uts.edu.au/events/uts-tech-festival) lists 22–26 June 2026 and says the event concluded. An organiser invitation located in the owner's connected account identifies the Interaction Design Showcase and a table/screen format, also in June. Confirm the owner's present deadline or later showcase brief before treating historical dates as an upcoming submission schedule. Poster dimensions, video length, presentation duration and judging criteria are not yet verified. Do not substitute another UTS showcase's requirements.

This sequencing update takes precedence over the original linear order below. The private-beta goal remains, but visible UI improvements come sooner. The competition name, deadline, judging criteria and submission format are still being clarified; no claim of submission readiness is made.

| Role | Current assignment | Boundaries |
| --- | --- | --- |
| Frontend agent | Inspect current native screens and real screenshots; propose a small competition-focused UI batch across the core journey | Own the visual review and later assigned Views/artwork; preserve accepted branding; present significant design changes before coding |
| Backend agent | Assess local persistence, drafts, suggestions and recovery contracts needed by that journey | Own reliability review and later assigned services/tests; no cloud expansion, live backend mutation or release identity changes |
| Codex coordinator | Resolve scope, review proposals, agree interfaces, integrate and verify each accepted batch | Own shared roadmap/stories/index/project files and final build scheduling |

**Fast-track order:**

1. Parallel frontend visual review and backend demo-readiness assessment, with source evidence and separate files.
2. Choose one concrete UI batch from the visual review. Reuse the approved font, palette and artwork; fix hierarchy, consistency and discoverability before commissioning more art.
3. Build and review the selected native/Figma experience in the format the competition actually requires. Label proposal/mock states and genuine runtime behavior accurately.
4. In parallel, implement only reproduced reliability issues or missing behavior that blocks that chosen journey. Existing working backend contracts stay stable.
5. Capture the coherent end-to-end journey and assemble only the required submission artifacts after checking the competition rules. Verify asset/font licenses and any AI-assistance disclosure requirements; do not assume eligibility.
6. Return to the wider private-beta qualification and legacy/release gates. They are not removed by a successful design demonstration.

**Coordination contract:** No overlapping runtime files without an explicit handoff. The backend agent must report any model/service signature change before the frontend uses it. The coordinator owns Xcode project/scheme changes and runs shared Simulator/device jobs sequentially. Review logs record actual exchanges, not manufactured approvals. Two agents are assigned within this chat; they do not run indefinitely after a turn ends.

**Current deliverables:** [frontend review](../../design/competition-frontend-review-2026-10-27.md) and [backend readiness](../../engineering/competition-backend-readiness-2026-10-27.md). These are bounded assessments before unapproved visual changes, not proof that the competition UI has been implemented.

## Showcase focus — owner update, 30 October

Owner priority: concentrate now on brand presentation and the showcase; other features can follow later. Pause further Circles discovery and feature expansion. The private-beta roadmap below remains subsequent work, not the immediate deliverable list. No new agent delegation, backend work, release or publishing is implied.

Latest owner clarification: **poster and presentation slides only; no video and no deadline**. This supersedes the earlier 27 October deliverable list and the initial video proposal. The [first matching set](../../design/showcase-2026-10-30/README.md) now contains a six-slide live presentation and a separately editable landscape poster with PNG/PDF copies.

### Existing material and review

- [Brand guideline](../../design/branding-guideline.md): accepted softly dimensional Pingu, Plus Jakarta Sans, navy/ice/blue palette. Reuse these rather than reopening the identity.
- [Portrait poster](../../design/brand-demo/poster-01/README.md) and [landscape poster](../../design/brand-demo/poster-02-landscape/README.md): existing concepts. The landscape was visually inspected on 30 October. Its large headline, ice landscape and scarf Pingu give it a recognisable identity. Today is the central phone; this predates the preparation-led demonstration choice.
- Existing poster phone screens and lettering are generated approximations. For final showcase work, propose actual selected native/prototype captures with editable text using the bundled font. Explicitly identify prototype-only behaviour; no live-model claim based on fixed responses.
- Six slides and the landscape poster are now available for review. Video is removed from scope. The owner confirms no deadline; print dimensions and talk duration remain flexible.

### Proposed editorial direction for review

One story across the poster and slides: **Find your words before a difficult conversation.** Show a student preparing a group-project message using invented content. Lead with Practice; Today and Journal provide the supporting reflection/revisit context. Circles remains outside the current materials.

| Deliverable | Proposed draft | Content |
| --- | --- | --- |
| Brand/project presentation | Six-slide, 16:9 draft; duration flexible | 1. CircleU and promise; 2. Student situation and design hypothesis; 3. Pingu, typography, palette and icon roles; 4. Prepare → Refine → continue with an actual reply; 5. Today/Journal and private-writing boundaries; 6. Current prototype status and next validation |
| Showcase poster | Refine existing landscape concept; print size pending | Short promise, central Practice capture, supporting Today/Journal captures, concise feature captions and existing Pingu artwork |

Assembly order: narrative and hero screen, selected consistent captures, then presentation and poster using those assets. Preserve original screen proportions. Label browser feedback as a prototype. Do not mix browser and native captures in a way that implies one shipped end-to-end implementation.

No participant results, impact statistics, live AI, App Store availability or event awards may be invented. A scenario is a design hypothesis, not a research finding. No social post, submission or live release has been performed. The current artifacts are presentation drafts, not an approved app redesign or verified release.

## 4. Detailed work packages

### A. Establish one current baseline — P0

**Files:** `AGENTS.md`, `docs/README.md`, `docs/engineering/architecture.md`, `docs/product/{mvp-definition,flow-status-checklist,supported-devices,release-readiness}.md`, `docs/design/README.md`.

- [ ] Reconcile current status against `AppStartup`, `GuestComposition`, guest stories and merged PRs. Label each claim as implemented, tested in Simulator, tested on a phone, or proposed.
- [ ] Add a clearly separate guest-beta release checklist; preserve legacy instructions as labelled reference. Do not silently make old upload/restore checks apply to guest mode.
- [ ] Record a build manifest: commit, configuration, bundle ID, version/build, device/OS, date, test results and known gaps. Keep private content and signing credentials out.
- [ ] Update Guest Test in place only after confirming the intended device and existing identity. Check the app can launch and the owner can still find an existing entry; do not export/read personal content for this check.
- [ ] Make the review build identifiable: show version and build in the existing Settings footer and assign a unique build number to Guest Test build commands. Keep technical labels outside the main user journey.

**Interfaces:** existing `AppStartup.resolve(arguments:isDebugBuild:isGuestJournalBuild:)`, `AppBootstrap.run(for:)`, `GuestComposition.makeSession()`, and the Settings version footer in `GuestFindAndControl.swift`; no new architecture layer required.

**Done when:** the owner and any coding agent can identify the installed build and its runtime; current docs no longer confuse prototype, guest Debug and legacy Release; prior phone entries remain available after the update.

### B. Finish the core user journey — P0/P1

**Files:** `Circleu/Features/GuestJournal/{GuestJournalScreens,GuestEntryEditorViewModel,GuestReflectionReview,GuestPracticeScreens,GuestPracticeViewModels,GuestFindAndControl}.swift`; corresponding guest unit tests and `CircleuUITests/`.

- [ ] Run one phone scenario: Get started → write or dictate → Save → Journal → reopen → edit original words/reflection → practise a linked message → edit → Copy → relaunch → find the latest saved versions.
- [ ] Run a standalone Practice draft scenario, including Situation and Goal, leaving/reopening, both tone-card directions, Use this and Undo, and Save independent of Copy.
- [ ] Test cancel/back/keep-editing/discard for every editor. Include empty or whitespace-only inputs, multiline text, emoji and a long entry. A failed save must keep all entered text.
- [ ] Complete an actual export through a system share destination with invented data, then cancel a second export. Only completed sharing should report Export done; temporary copies must be cleaned up.
- [ ] Verify searching and calendar filtering together, older-year dates, midnight/time-zone boundaries, leap-day/month transitions and returning to all entries. Preserve the owner's clean calendar without extra decorative icons.
- [ ] Reproduce each finding before fixing it; add the smallest regression that proves the failure and the fix. Update the corresponding story in the same change.

**Tests to strengthen:** P2.5 restored Situation/Goal fields; P4.2 horizontal tone choices; S2.3 completed versus cancelled sharing; calendar date grouping; J4.2 actual discard dialog. Inspect existing assertions first—some story coverage labels are stale, so do not duplicate already sufficient tests.

**Done when:** the owner completes the core journey without instructions, no edit is lost, no unintended duplicate is created, and each failure leaves an obvious safe next action.

### C. Keyboard, VoiceOver and accessible layout — P1, P0 for blocked controls

**Files:** `GuestImportAndWelcome.swift`, `GuestJournalScreens.swift`, `GuestPracticeScreens.swift`, `GuestSignIn.swift`, `GuestBrand.swift`; `GuestStatesUITests`, `GuestTodayUITests`, `GuestPracticeUITests`; `docs/qa/`.

- [ ] Check the software keyboard visibly open on the current native build. Cover first/last fields, Next/Done, scroll-to-focus, Save, keyboard dismissal and returning after a sheet. PR #41's screenshots did not show the software keyboard.
- [ ] Inspect Today T9.4: a nudge appearing must not make the current writing/caret unreachable. Check normal, intermediate and largest text sizes, not just one extreme.
- [ ] Check the current Welcome pager with physical VoiceOver: page change is announced, focus reaches the new heading, hidden-page content is skipped, Skip/Next/Get started remain usable. Add explicit focus handling only if the observed behavior needs it.
- [ ] Check Journal J6.1: date, reflection/step/message indicators and completion status are spoken meaningfully; do not depend on color or artwork alone.
- [ ] Complete VoiceOver order, errors, dismissals and three-finger scrolling through editors, privacy, account recovery and the avatar picker. Reuse the owner's earlier preview evidence only for the exact build/screens it covered.
- [ ] Check compact width/height and supported orientations, reduced motion, increased contrast and bold text. Decide orientation/device scope explicitly before changing project settings.

**Done when:** a person using large text and VoiceOver can complete B without unreachable controls, clipped essential information or focus traps. Record automated accessibility findings separately from actual speech/gesture observations.

### D. Make the app and Figma consistent — P1; optional motion P2

**Files/reference:** [UTS Figma file](https://www.figma.com/design/rfknpmLIXsOxA7fHUQQMtR), `docs/design/{README,branding-guideline,screen-content-guidelines,motion-guideline}.md`, `docs/design/brand-demo/asset-library.md`, `GuestBrand.swift`, `GuestPinguArt.swift`, `Circleu/Assets.xcassets` and the existing `BrandArtwork/` master folder.

- [ ] Designate the UTS file as the review location if the owner agrees; label existing alternatives as proposals. Keep the old Draft 02 recovery reference and source art library intact.
- [ ] Compare each accepted screen against a current native screenshot. Prioritize Welcome, Today, Journal/detail, Practice/editing and Settings/recovery. Mark fixed-size boards as references, not proof of native layout.
- [ ] Add missing visible states: loading, disabled/empty Save, save failure with retained writing, stale suggestion, permission denial, copy reset, discard confirmation, offline recovery and failed export. Link primary/Back/cancel routes into a reviewable prototype.
- [ ] Establish a small reusable Figma library from the existing UI: typography, colors, spacing, buttons, chips, fields, cards, toolbar and tab items. Use auto layout and explicit states; avoid building a huge speculative component system.
- [ ] Audit native font weights, Dynamic Type scaling, line wrapping, icon sizes and artwork crops. Keep approved Plus Jakarta Sans unless real reading tests justify a change the owner accepts.
- [ ] Present optional polish separately: one Practice scene using existing art; subtle success feedback/haptic; a short listening indicator. Ship only selected items, respect Reduce Motion, and never delay Save or obscure text.

**Done when:** approved boards are distinguishable from alternatives, important flows can be reviewed in Figma, native screens match accepted decisions, and every new asset has a source/provenance record. Do not count prototype links as executable recovery behavior.

### E. Qualify storage, offline use and privacy — P0

**Files:** `Circleu/Services/GuestJournal/{SwiftDataGuestJournalStore,GuestJournalStore,GuestDraftStore,GuestDictationEngine,GuestSuggestionEngine}.swift`, `Circleu/App/{AppStartup,CircleuApp}.swift`, `GuestRootView.swift`; existing guest store/draft/dictation/suggestion tests.

- [ ] Exercise supported schema upgrades with invented fixtures: stable IDs, original and edited text, dates, reflection source, optional step, linked messages and kept drafts must survive. Repeated adoption/import must not duplicate or resurrect deleted content.
- [ ] Test an interrupted save, low-storage/write denial, unreadable store, protection failure, rapid double actions and relaunch. Preserve old bytes and drafts; never present a read failure as an empty journal. Use disposable fixtures, not the owner's journal or disk.
- [ ] Check real file-protection behavior on a physical iPhone, including store/sidecar files and locked-device behavior; injected unit results are not hardware proof.
- [ ] Measure open/search/month navigation/save with 2,000 invented entries and representative linked messages on the oldest intended device. Record actual timings and responsiveness first; then agree budgets and optimize the measured bottleneck.
- [ ] Verify ordinary guest launch/use/background/relaunch with airplane mode and observed network activity. Explicit recovery is a separate network path; model asset setup is distinct from offline inference.
- [ ] Qualify dictation and suggestions on one phone without model capability and one eligible phone with a ready model. Cover denied permission, missing assets, unavailable locale, interrupted/cancelled generation and late results after edits.
- [ ] Keep guided prompts honestly labelled and editable. Check that optional suggestions never diagnose the person or automatically become accepted reflections.

**Done when:** data failure and upgrade tests pass, hardware limitations are documented, guest network behavior supports the privacy wording, and both capable and fallback devices retain a complete manual core flow.

### F. Validate usefulness and decide what to polish next — P1

**Files:** `docs/design/prototype-review-results.md`, `docs/product/{research-findings,user-stories}.md`; optionally create a dated study-results file in the existing product folder.

- [ ] Draft a small study with approximately five consenting target users (university students / early-career adults); recruitment and messages require separate owner authorization.
- [ ] Use neutral scenarios and five tasks: begin without an account; write/save/reopen; correct a reflection; prepare/copy a message; find/export an entry and explain where data lives.
- [ ] Record completion, assistance, confusion, failed attempts and privacy comprehension. Do not record personal journal content or infer population-wide success from a small study.
- [ ] Proposed gate: no participant loses work or mistakes a suggestion for a diagnosis; at least four of five complete the core task without coaching. Any misunderstanding of upload, saving or sending triggers correction and a focused retest. The owner must accept these pilot criteria before the study.
- [ ] Rank findings by harm/frequency and fix the blocking ones before adding features. Keep optional visual preferences separate from task failures.

**Done when:** actual findings support the next iteration, critical problems have been retested, and the owner accepts the beta scope. Positive reactions alone do not establish usefulness.

### G. Release configuration and legacy continuity — P0, explicit release decision

**Files:** `AppStartup.swift`, `Circleu.xcodeproj/project.pbxproj`, project schemes/build configuration, `Config/Signing.xcconfig.example`, `docs/product/{supported-devices,personal-account-release-plan,release-readiness}.md`, `docs/engineering/legacy-data-{inventory,format}.md`, `docs/privacy.html`, `.github/workflows/ci.yml`.

- [ ] Recheck the owner's Apple enrollment and authorized UTS route. The last recorded position was UTS access only; do not assume that is still current or that a personal-account app inherits legacy data.
- [ ] Select the guest beta identity and distribution route before changing Release startup. Write a separate bounded specification for an explicit guest Release configuration while retaining a usable legacy/recovery route. No accidental legacy launch and no test reset/fixture controls in distributed builds.
- [ ] Verify the exact Release archive's runtime, dependency graph, bundle identity and privacy behavior; do not qualify a Debug build and ship a different path.
- [ ] Revalidate current Apple requirements and SDK/privacy declarations against primary documentation when preparing distribution. Existing research is historical, not a current transfer or review-eligibility guarantee.
- [ ] Verify earlier-account recovery and account deletion against authorized disposable backend fixtures, including wrong account, malformed records, expired session, partial failure and cancellation. Keep live tests opt-in. Do not bulk-delete or migrate actual accounts as a test.
- [ ] Resolve legacy data provenance and the old-build mapping. If a new app identity is chosen, specify and test a portable archive/import or another explicit recovery route. The current readable text export is not a restorable backup and must not be advertised as one.
- [ ] Approve the supported device/OS matrix and continuing access for older/iPad users before narrowing support. Resolve cases with no verified recovery path individually; do not claim all data can be recovered.
- [ ] Run release-appropriate CI once when preparing TestFlight, following the manual-only policy. Audit final archive contents, public privacy/support text, screenshots, release notes and known limitations.
- [ ] Agree an update/rollback plan that does not downgrade an incompatible store, erase data, re-enable silent sync or resurrect deleted content. Separately authorize upload, tester invitations and rollout.

**Done when:** the actual archive opens the intended guest experience, the owner has a valid distribution route, old users retain a truthful recovery/management path, and all release-critical checks have evidence. Development installation, a merged PR or a Figma demo is not this gate.

## 5. Review focus and proof ownership

| Risk / input | Expected behavior | Owning package / proof |
| --- | --- | --- |
| Software keyboard + nudge + very large text | Current writing and required actions remain reachable | C: visible software-keyboard walkthrough and targeted UI assertions |
| Interrupted write or locked/unreadable store | No blank-success state, lost accepted edit or overwritten source | E: isolated failure/upgrade tests plus physical protection evidence |
| Edit/back/copy/late suggestion | Saved and copied versions stay truthful; no duplicate or stale overwrite | B: ViewModel regressions and UI save/discard/reopen tests |
| Wrong account, partial backend deletion or unknown legacy ownership | No cross-account reveal; no false success or automatic import | G: opt-in disposable-account tests and legacy recovery decision |
| Release build differs from Debug | Intended startup, privacy and data path match the qualified archive | G: Release/archive check, not a launch-argument-only test |

## 6. Delivery process and next batch

Recommended implementation style: one agent implements a coherent batch, then a fresh reviewer checks it under the existing Git workflow. Avoid multiple agents editing the same screens or project file. Separate research/review can be delegated when authorized. Keep batch boundaries independently testable and do not open a new feature branch for each tiny UI tweak.

For each approved behavior change:

1. Update the affected story/acceptance criteria; identify the concrete bug or chosen design.
2. Reproduce it and write a regression where behavior warrants one; observe the failure before the fix.
3. Implement the smallest coherent change using existing helpers and dependencies.
4. Run affected tests, then both full suites before merging guest changes; inspect screenshots where layout matters.
5. Record actual reviewer findings, exact build/device, passing checks and limitations in a new dated log. Stage explicit files and use scoped Conventional Commits.
6. Update the corresponding accepted Figma board when user-visible behavior changes. Keep technical review notes outside the phone screen.
7. Install reviewed phone builds in place, and collect one consolidated owner walkthrough per batch.

Verification commands (choose a currently available Simulator; never copy an obsolete UUID blindly):

```sh
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer xcrun simctl list devices available
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer xcodebuild test \
  -project Circleu.xcodeproj -scheme Circleu \
  -destination "platform=iOS Simulator,id=$CIRCLEU_TEST_SIMULATOR_ID" CODE_SIGNING_ALLOWED=NO
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer xcodebuild test \
  -project Circleu.xcodeproj -scheme CircleuUITests \
  -destination "platform=iOS Simulator,id=$CIRCLEU_TEST_SIMULATOR_ID" CODE_SIGNING_ALLOWED=NO
```

The ignored signing configuration must be prepared from the example for the chosen environment. Tests must use their own invented data. Do not pass the Debug reset argument to the owner's installed app. Documentation-only work needs link/status review and `git diff --check`, not a redundant full app run.

**Original beta-first batch (superseded in order by the competition fast track above):** A plus the phone walkthrough in B. Outcome: an identifiable current Guest Test build, retained existing entries, a current status checklist and a short ranked list of real problems. Follow with C and only the fixes B reproduces. Review D's optional visuals together before coding them.

Do not promise calendar dates until device access, findings and release-route dependencies are known. Use the completion gates above to decide progress rather than treating every proposed task as an immediate implementation commitment.

## 7. Decisions for the owner

| Decision | Recommendation | When needed |
| --- | --- | --- |
| First milestone | **Owner-selected: polished private beta** | Confirmed 27 October; detailed batch approval still separate |
| Main design review location | UTS Figma file, with dated native screenshots and accepted/proposed labels | Confirm before restructuring boards or adding a design library |
| Optional polish | Choose at most one Practice scene and restrained feedback after core usability passes | After B/C |
| Research participation and success gate | Small consent-based pilot; review the proposed tasks/criteria first | Before recruitment or outreach |
| Supported devices and release identity | Decide from hardware and legacy evidence; retain current project compatibility meanwhile | Before G changes configuration |
| Legacy migration/portable backup | Separate security/data-contract design if required by the chosen release route | Before any migration implementation |

This plan keeps the user's accepted design and product direction. It does not replace the historical transition plan or claim its unresolved obligations are complete.
