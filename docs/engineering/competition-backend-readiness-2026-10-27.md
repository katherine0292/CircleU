# Backend readiness for a design competition

## 31 October follow-up

The original assessment below is historical. Native Practice conversation/voice work is checkpointed in `150214e`; the guest store now has V1–V6 migrations. V5 added attributed conversation history; V6 adds optional user-selected Journal context and feeling. V5 migration tests preserve entries, accepted reflections, linked conversation history, receipts and kept drafts. Guest tags share existing revision/rollback/protection behavior; no cloud data is changed. The shared reflection decoder now safely rejects reversed JSON delimiters (`e6d548f`).

Current delivery is poster and slides only, without a deadline. Standard Release still opens the legacy app, and Dev-only recovery remains separately gated. The [31 October audit](../qa/project-audit-2026-10-31/README.md) records repository Firestore ownership weaknesses, live deployment uncertainty and the retired legacy cloud model; none is resolved by the UI/storage work. Do not release or activate cloud features based on these local checks.


Assessed 27 October 2026 against `9967a1057310c84e569c8ffecc434a3c7db905c9`, branch `codex/app-upgrade-plan`. This is a source-backed assessment and proposed qualification scope, not implemented changes or permission to release. Competition requirements, deadline and submission format remain unconfirmed.

## 1. Decision

The existing guest app already supplies the data contracts needed for a polished Today → Journal → Practice demonstration. Frontend work can proceed against those contracts now. A new server, sync layer, account system or generic API rewrite would not improve the core demonstration.

Backend effort should make the existing local flow dependable on the chosen demonstration device: save and reopen the same content, retain unfinished work, and finish the task without a model, microphone or network. Start with three bounded priorities below; change source only after a failure is reproduced or a specific gap is approved.

**Confirmed delivery constraint:** [AppStartup.resolve](../../Circleu/App/AppStartup.swift) selects `.guestJournal` only when `isDebugBuild` is true and either the launch argument or guest build flag is present. A normal Release archive opens the original app, even with `GUEST_JOURNAL_BUILD`. [AppStartupTests](../../CircleuTests/AppStartupTests.swift), specifically `testReleaseBuildsIgnoreTheHiddenSwitch` and `testPhoneTestBuildOpensGuestJournalOnlyInDebug`, intentionally assert this behavior. This is a blocker if the competition requires a guest TestFlight/Release installation; it is not a newly discovered defect or a blocker to an owner-hosted Guest Test demonstration. Decide the submission format before changing startup or signing.

No new blocking save/edit defect was established by this read-only assessment. This is not a claim that every runtime scenario works.

## 2. Contracts available to the frontend

### Firebase progress clarification — 27 October follow-up

The backend agent completed this assessment, not an implementation sprint. No new backend code, deployed rules, Firebase configuration or live-data operations followed from that assignment. The coordinator rechecked the source and completed-agent status when the owner asked about progress.

There are two experiences in the same repository:

| Experience | Current source behavior | Qualification still needed |
| --- | --- | --- |
| Original app | Firebase Authentication and Firestore services; `BackendSessionStore` coordinates account-scoped stores, backup upload and restore. Firebase/analytics configure on its startup path. | Verify the exact legacy build/project and deployed access rules; do not infer successful live backup/recovery from source. |
| New guest app | Local SwiftData for entries, reflections, Practice messages and new-content drafts. Normal guest startup skips Firebase/analytics. | Device persistence/interruption, offline route and observed network isolation. This does not describe every Release build. |
| Guest optional earlier-account recovery | `GuestAccount.swift` uses a separate named Firebase app with in-memory Firestore cache and an allowlist containing only `circleu-45651` (Dev). Supports explicit backup reading/import and separate account-deletion operations. No new guest journal upload or signup. | Successful disposable-account end-to-end recovery, repeat import, reset and partial-deletion failures; correct project/build routing. Existing historical wrong-account rejection is not successful recovery qualification. |

The source comments state that Release carries Prod configuration, so the Dev-only recovery adapter is unavailable there. This is separate from—and additional to—the Debug-only guest startup constraint. Do not fix either by simply removing the allowlist or enabling recovery against an unverified project. The old TestFlight build's bundled project remains unverified in the [legacy inventory](legacy-data-inventory.md).

Recommended next backend batch: strengthen interruption/relaunch evidence (including Practice Goal), qualify save/edit/reopen and offline fallback, then perform isolated Firebase ownership/recovery tests before external beta. Keep legacy Firebase available while recovery remains unresolved. New sync or a replacement backend requires a separate product decision; it is not needed to create more artwork or polish the frontend.

The older `backend-roadmap.md`, `backend-boundaries.md` and `firebase-backend-plan.md` describe legacy architecture/plans. Their historical account, circles, rewards and cloud directions are not the current guest MVP task list.

Use the existing ViewModels and injected services. Keep SwiftData and device API calls out of SwiftUI view bodies. These are current source contracts; the historical test result in section 3 does not replace device qualification.

| Need | Existing contract and source owner | Frontend obligation |
| --- | --- | --- |
| Open a guest session | `GuestComposition.makeSession()` in [GuestRootView.swift](../../Circleu/Features/GuestJournal/GuestRootView.swift) opens one local store shared by Journal and Practice, adopts earlier draft files, and restores drafts. `AppBootstrap.run(for:)` skips Firebase/analytics for guest startup. | Show opening, ready and failed states distinctly. An unreadable/missing store must not appear as an empty journal. |
| Save original words | `GuestJournalViewModel.saveDraft()` in [GuestJournalViewModel.swift](../../Circleu/Features/GuestJournal/GuestJournalViewModel.swift); `GuestJournalStore.create(originalWords:draftID:)` in [GuestJournalStore.swift](../../Circleu/Services/GuestJournal/GuestJournalStore.swift). A saved draft receipt is recorded with the entry. | Respect `isSaving`, `saveError`, `draftWarning` and notices. A committed-but-unprotected result is a warning, not permission to retry creation. Suggestions follow saving and are optional. |
| Edit without overwriting newer work | `GuestEntryEditorViewModel.save()` in [GuestEntryEditorViewModel.swift](../../Circleu/Features/GuestJournal/GuestEntryEditorViewModel.swift) uses the opened revision and returns `saved`, `savedStay` or `failed`. Store updates reject stale revisions and missing entries. | Close only for `saved`; keep text and the warning for `savedStay`/failure. Respect `canLeave` during a write. Do not replace revisions or recreate missing entries. |
| Retain unfinished new content | [GuestDraftStore.swift](../../Circleu/Services/GuestJournal/GuestDraftStore.swift): `StoreGuestDraftStore` supplies separate `write` and `practice` slots in SwiftData. Journal changes get new draft identities; Practice serializes Situation, Goal, wording and optional source link. | Use the existing draft observers and Practice ownership rules. A corrupt or unchecked draft is preserved and warned about, not overwritten. New-content draft keeping does not establish crash recovery for unsaved edits to an already saved entry/message. |
| Save/edit/copy Practice | `GuestPracticeViewModel` and `GuestPracticeComposerViewModel` in [GuestPracticeViewModels.swift](../../Circleu/Features/GuestJournal/GuestPracticeViewModels.swift); `GuestPracticeStore` in [GuestJournalStore.swift](../../Circleu/Services/GuestJournal/GuestJournalStore.swift). New and existing messages have separate create/update paths. | Copy uses `copy(using:)` and never saves or sends. Keep a newer edit visible when a save finishes. Use existing draft cleanup after successful new-message save; do not clear another screen's draft. |
| Keep accepted reflection separate | `GuestReflectionStore.updateReflection(...expectedRevision:)`, `GuestReflection.basedOnWords`, and `GuestJournalEntry.isReflectionStale`; review state in [GuestReflectionReview.swift](../../Circleu/Features/GuestJournal/GuestReflectionReview.swift). | Accept explicitly, retain the source label, and show when original words changed. Do not automatically persist generated suggestions. |
| Offer suggestions without cloud dependency | `GuestSuggesting` / `LocalFirstSuggestionEngine` in [GuestSuggestionEngine.swift](../../Circleu/Services/GuestJournal/GuestSuggestionEngine.swift): available on-device model, otherwise built-in guided prompts. Practice exposes `suggestionsAreStale`. | Manual wording remains usable. Keep `.guided`, `.onDevice` and `.imported` labels truthful; do not imply that guided templates are a personalised analysis. |
| Optional dictation | `GuestDictationEngine` / `SpeechDictationEngine` in [GuestDictationEngine.swift](../../Circleu/Services/GuestJournal/GuestDictationEngine.swift), coordinated by [GuestDictationViewModel.swift](../../Circleu/Features/GuestJournal/GuestDictationViewModel.swift). Speech requires on-device recognition; audio is not written to a recording file by this implementation. | Handle denied/unavailable/interrupted states and preserve typing. Do not replace capability failures with remote speech. |

Persistence implementation is [SwiftDataGuestJournalStore.swift](../../Circleu/Services/GuestJournal/SwiftDataGuestJournalStore.swift): V1–V4 schema migration plan, one actor owner per store location, serial revision checks, explicit rollback on failed save, `cloudKitDatabase: .none`, and post-commit protection warnings. Cross-process writers are explicitly unsupported; the demonstration needs no extension or second persistence owner.

## 3. What is established and what remains unverified

The [27 October quality record](../agent-collaboration-log/2026-10-27-005639-codex-practice-copy-quality.md) reports **256 unit tests passed; 20 UI tests executed, 19 passed and one live-Firebase test deliberately skipped**, on iPhone 18 Pro Simulator / iOS 27.0. The [upgrade roadmap](../superpowers/plans/2026-10-27-app-upgrade-roadmap.md) records merged main `9967a10` as source-equivalent to tested fix `c1ca782`. These are historical results, not tests rerun for this assessment.

| Source/test evidence inspected | What it supports | What it does not establish |
| --- | --- | --- |
| [GuestJournalStoreTests.swift](../../CircleuTests/GuestJournalStoreTests.swift): create/reopen/edit, competing edits, saved-draft receipts, corrupt/missing store, failed create/update rollback, protection injection | Meaningful tests exist for duplicate prevention, committed content retention and explicit failure states. | Actual disk-full writes, killed-process transactions or locked-device sidecar behavior. `testRealDataProtectionOnDevice` is hardware-gated; the cited Simulator record is not its device result. |
| [GuestEntryEditorViewModelTests.swift](../../CircleuTests/GuestEntryEditorViewModelTests.swift): stale/deleted edits, writing during save, draft identity, cleanup and warning tests | ViewModel failure and race contracts are exercised. | Recovery of every last keystroke after abrupt process termination; persistent unsaved edits to an already saved entry. |
| [GuestFindAndControlTests.swift](../../CircleuTests/GuestFindAndControlTests.swift): draft adoption, coalescing, Practice draft restore, multiple-screen ownership, export snapshot | Legacy draft files are adopted once; current new-message drafts and receipts have tests. | `testPracticeDraftSurvivesRelaunchAndIsClearedBySaving` explicitly awaits `flushDraft()` and creates another session in-process. It asserts Situation and wording, but not Goal. This is an assertion/qualification gap, not proof that Goal is lost. |
| [GuestPracticeTests.swift](../../CircleuTests/GuestPracticeTests.swift) and [GuestSuggestionTests.swift](../../CircleuTests/GuestSuggestionTests.swift): V1, V2 and V3 fixtures upgraded; accepted reflections/steps/links/receipts retained | Defined old-schema fixtures and current local behavior have regression coverage. | All historic shipped data formats, interrupted upgrades, or actual legacy account ownership/recovery. |
| [AppStartupTests.swift](../../CircleuTests/AppStartupTests.swift): cloud-construction counter and injected bootstrap | Guest startup avoids the instrumented Firebase/analytics construction path. | Observed absence of outbound content traffic across a whole foreground/background/relaunch journey. |
| [GuestDictationViewModelTests.swift](../../CircleuTests/GuestDictationViewModelTests.swift) and forced-guided tests in [GuestSuggestionTests.swift](../../CircleuTests/GuestSuggestionTests.swift) | Manual fallback, denial, interruption and stale-input behaviors have deterministic tests. | Actual microphone, locale/assets, speech interruption, Foundation Models availability/latency or real model output quality on a phone. |

The historical [26 October phone handoff](../agent-collaboration-log/2026-10-26-193014-claude-to-codex-design-pass-handoff.md) identifies a Guest Test installation on iPhone 11 Pro Max from `026f416`, before the latest quality fix, and leaves the owner's walkthrough outstanding. Do not present that installation as qualification of the current source.

## 4. Three priorities supporting the competition

These are proposed bounded tasks, not commitments to implement the whole private-beta roadmap. Source/test ownership below identifies the existing files; the integrating agent owns shared project configuration and final cross-flow checks.

### 1. Qualify save → edit → reopen on the exact demonstration build

**Why first:** visible polish depends on the user's words remaining accurate after Save, editing and returning to the app. Existing storage contracts let frontend progress while this check is prepared.

**Backend source owners:** `SwiftDataGuestJournalStore.swift`, `GuestJournalStore.swift`, `GuestJournalViewModel.swift`, `GuestEntryEditorViewModel.swift`, `GuestPracticeViewModels.swift`. Coordinate ViewModel edits with the frontend owner rather than editing the same files concurrently.

**Existing test owners:** `GuestJournalStoreTests.testFailedCreateRollsBackAndRetryDoesNotDuplicate`, `testFailedUpdateKeepsCommittedContent`, `testCompetingEditsThroughSeparateOpensCannotBothWin`; `GuestEntryEditorViewModelTests.testSaveAndEditPersistAcrossRelaunch`, `testStaleAndDeletedEntriesKeepTextWithClearMessages`; `GuestPracticeViewModelTests.testTextTypedWhileSavingIsKeptAndStillUnsaved` in `GuestPracticeTests.swift`. UI journeys already live in [GuestFlowUITests.swift](../../CircleuUITests/GuestFlowUITests.swift) and [GuestPracticeUITests.swift](../../CircleuUITests/GuestPracticeUITests.swift).

**Acceptance gate:** record build commit/configuration/bundle ID/device/OS; use invented content to save an entry, edit it, accept an edited reflection, save a linked Practice message, edit it, copy it and relaunch. Confirm latest saved values and one record per intended creation. Confirm a controlled failed save retains all submitted text and prior committed data; committed protection failure must not create a duplicate. Existing tests can establish injected failures; physical checks establish only the scenarios actually performed. Repair only a reproduced failure with a targeted regression. Run both suites before merging any guest behavior change.

### 2. Close the draft interruption evidence gap

**Why next:** returning to unfinished writing is a prominent product promise, and orderly test flushing is weaker than leaving or terminating the app while writing.

**Backend source owners:** `GuestDraftStore.swift`, `SwiftDataGuestJournalStore.swift`, the draft queues in `GuestJournalViewModel.swift` and `GuestPracticeViewModels.swift`; lifecycle integration, if evidence requires a fix, belongs jointly with the frontend owner. Do not add a new draft system preemptively.

**Existing test owners:** `GuestFindAndControlTests.testABurstOfTypingIsCoalescedAndTheLatestTextIsKept`, `testPracticeDraftSurvivesRelaunchAndIsClearedBySaving`, `testSavedPracticeDraftIsNeverOfferedAgain`, `testOnlyTheNewestScreenForADraftCanWriteOrClearIt`; `GuestEntryEditorViewModelTests.testTypingDuringSaveIsKeptUnderANewIdentity` and `testEditAndRevertDuringSaveStaysVisibleAndKeptTogether`.

**Acceptance gate:** Today draft and standalone Practice draft restore after background/relaunch; Practice restores Situation, Goal and wording. Saving then relaunching does not offer the saved draft again. Check fast typing and a disposable interrupted session without calling a test-only flush first; document whether the final edit survives and the exact interruption point. A failed write/read must preserve old bytes and show the existing warning. Do not claim crash-safe retention of all unsaved edits from the current tests. If results require broader autosave or lifecycle semantics, specify that change before coding it. No deletion of the owner's journal or app is part of this gate.

### 3. Rehearse the complete manual/guided route offline

**Why third:** a venue connection or optional device capability must not block the core task. A polished typed/guided route is already possible; real model output is optional.

**Backend source owners:** `GuestSuggestionEngine.swift`, `GuestDictationEngine.swift`, `GuestDictationViewModel.swift`, `GuestReflectionReview.swift`, `GuestPracticeViewModels.swift`; guest composition/startup remain the shared integration boundary.

**Existing test owners:** `GuestDictationViewModelTests.testDeniedPermissionLeavesTypingAndOffersSettings`, `testNoOnDeviceSupportNeverListens`, `testInterruptionKeepsTheWordsSoFar`, `testLateEventsFromACancelledDictationDontReachTheNextOne`; `GuestSuggestionTests.testGuidedEngineIsLabelledAndUsesOnlyWhatWasTyped`, `testPracticeSuggestionsBecomeStaleWhenTheirInputsChange`, `testFailedPracticeSuggestionKeepsWording`. [GuestVoiceTabsUITests.swift](../../CircleuUITests/GuestVoiceTabsUITests.swift) uses scripted speech for part of its coverage; it is not a microphone test.

**Acceptance gate:** on the demonstration phone, complete type → save → guided/manual reflection → Practice → copy → relaunch with airplane mode and without account login. Confirm optional dictation denial/unavailability leaves typing usable. Observe normal guest startup/use/background/relaunch network activity before extending any privacy claim beyond source evidence. If showcasing on-device model or speech, rehearse those exact capabilities, locale and installed assets on that phone as an additional check; record fallback behavior on failure and late results after edits. Do not add cloud substitution or promise model capability based on Simulator results.

## 5. Work that can wait, and conditional gates

For a controlled owner-hosted presentation with invented content, these do not need to hold up the frontend polish:

- Full 2,000-entry performance qualification and broad device/OS coverage: before the private beta uses those supported scales/devices; first measure responsiveness on the demonstration dataset/device.
- Full schema-upgrade interruption, actual low-storage and physical file-protection matrix: before external beta data is entrusted to the build. Retain the existing failure tests and never hide encountered errors during the competition.
- Live earlier-account recovery/deletion, deployed Firebase rules and legacy source provenance: separate authorized disposable-account qualification before presenting those operations as working or distributing them to users. Keep existing recovery access; no account/cloud writes in this assessment.
- Release configuration, distribution identity, archive privacy/dependency audit and legacy continuity: may wait only if submission uses the owner-hosted development build or presentation. **If judges need an installable guest Release/TestFlight app, these move ahead of submission** because of the startup constraint in section 1.
- Portable restore/import and service retirement: require a separate release/legacy decision. A readable text export is not a restorable backup.
- New sync, cloud AI, server infrastructure, mandatory signup, circles and rewards: outside the competition core and current upgrade scope; beta/public release does not automatically approve them.

The competition's exact rules decide whether the artifact is a design/prototype, video, supervised native demo or independently installable app. Do not turn a visual submission into an unplanned public release, or defer release gates if an installable submission is required.

## 6. Assessment verification and handoff

Read the required project guidance, current stories, roadmap, transition plan, quality record and linked design handoffs; inspected the source/contracts and relevant test bodies named above. Shared coding standards were available. No app source, settings, data, project configuration or frontend files were changed. No builds, tests, installs, live Firebase, remote writes or account/deletion operations were performed.

Documentation verification: relative links/source paths and `git diff --check`. Current user stories remain unchanged because this assessment changes neither behavior nor tests. Any later behavior/test change must update its affected story and meet the project test/review gate.

Frontend handoff: retain these contracts while polishing the core screens; expose existing loading, warning, retained-edit and fallback states with the [screen-content rules](../design/screen-content-guidelines.md). Coordinator handoff: confirm competition format/deadline and identify the actual demonstration build/device, then select the smallest qualification batch from section 4. Consult the broader [upgrade roadmap](../superpowers/plans/2026-10-27-app-upgrade-roadmap.md) only for the milestone actually being delivered.
