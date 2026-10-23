# CircleU Local-First Transition Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking. This is a planning deliverable; implementation has not started.

**Goal:** Deliver the approved guest-first Today/Journal/Practice MVP without stranding previous TestFlight users or misrepresenting the handling of their Firebase data.

**Architecture:** App-managed local persistence behind a repository boundary; explicit on-device generation with manual fallback. A proposed same-bundle UTS transition build preserves legacy access through a separate, user-invoked recovery flow. A personal-account release may instead use a new app identity plus explicit portable import; an official transfer is conditional on eligibility. See the [release-route research](../../product/personal-account-release-plan.md) before selecting implementation tasks. Retire cloud dependencies only after recovery/deletion obligations have an established continuing path.

**Tech Stack:** Existing SwiftUI/XCTest app; versioned local storage (SwiftData candidate, pending spike); legacy Firebase Authentication/Firestore adapter; Apple Foundation Models and Speech. Xcode 27.1 verified locally; CI alignment pending.

**Spec:** [MVP scope](../../product/mvp-definition.md), [approved privacy direction](../../product/privacy-storage-plan.md), [recommended supported devices](../../product/supported-devices.md). Owner confirmed a previous TestFlight release on 23 October 2026. Treat its data as potentially real; no reset or remote deletion is authorized by this plan.

## Global constraints

Inventory progress, 23 October 2026: [read-only console/source findings](../../engineering/legacy-data-inventory.md) confirm Dev has 14 Auth accounts, enabled Email/Password and Google providers, and `users`/`circles` collections. Prod shows Authentication/Firestore setup prompts; current Release selects Prod, while non-Release and the CLI default select Dev. App Store Connect now verifies **1.0 (1)**, uploaded 11 June 2026, expired, with six reported installs and iOS 17/iPhone+iPad compatibility under the education team. The original upload Mac was returned to the Apple Foundation Program; no archive is currently available, so shipped Firebase/schema mapping remains unresolved. Full deployed rules, private-data metadata, tester devices, release permissions and retention/distribution evidence remain outstanding; Task 1 stays incomplete. [Thirty Figma recovery states](../../design/legacy-recovery-flow.md) illustrate the proposed handling; no migration implementation has begun.

- Planning before coding. All implementation steps below remain unchecked. Preserve source, bundle identity, signing, Git history and cloud records during planning.
- Guest/local and no CircleU cloud AI/backup are approved for the new experience. Ordinary device backups and explicit user exports remain distinct boundaries.
- No forced sign-out, silent scope merge, automatic cloud deletion or destructive legacy cleanup. A local delete must not claim to delete a previous cloud copy.
- Do not activate legacy Firebase at guest startup. A temporary recovery mode must explicitly explain its network use and never upload new local-first content.
- Keep the existing iOS 17 and iPhone/iPad coverage for the transition build until actual prior installs and distribution constraints are known. The recommended new-MVP floor is iOS 26.
- No deployment, participant messages, tester invitations, key rotation or backend retirement occurs as part of producing this plan.

## Review focus

New evidence: the [format catalog](../../engineering/legacy-data-format.md) identifies pre-scoping device keys, newer UID buckets, local-only practice attachments and silent decoder omissions. An unsuffixed key is not automatically guest data. The existing TestFlight-only app has no observed App Store release, so Apple's standard transfer criterion is unmet. The owner only has UTS team access. A compatible bridge and portable content import are proposed; the final route/security design is not selected.

1. Startup/observers can transmit content even when UI features are hidden.
2. Guest storage, local-account UUID and Firebase UID are different scopes. A remembered UID is not proof of account ownership.
3. Merge-only backup can reintroduce deleted entries; automatic import is unsafe when deletion history is missing.
4. A successful-looking delete can leave cloud records behind. A no-op backend returning an empty snapshot is not verification.
5. Corrupt-data fallback must not erase original bytes, and a migration retry must never duplicate or overwrite newer edits.
6. Previous builds may keep writing; cloud retirement needs service-side controls and a continuing recovery route.

## Existing integration disposition

| Integration / evidence | Transition treatment | New-MVP destination |
| --- | --- | --- |
| `CircleuApp.swift` initializes Firebase; `ContentView.swift` wires backend stores; `RootView.swift` schedules restore/upload | Split legacy startup from guest composition; stop automatic upload, listeners and pending backup tasks in the new path | No Firebase startup or private-content network calls |
| `FirebaseAuthService.swift`, `BackendSessionStore.swift`, `AuthStore.swift` | Existing-account authentication only inside explicit recovery/account management; preserve access and reauthentication | No signup/login requirement; no local password database |
| `FirebaseFirestoreSyncService.swift` | Authenticated read/export and verified deletion adapter; no bidirectional syncing with the new store | Remove after continuing legacy management is established |
| `ReflectionEngine.swift`, `CloudReflectionEngine.swift` | Remove Gemini fallback from new experience, including stored consent/key-driven paths | On-device model → manual/guided fallback |
| `VoiceRecorder.swift`, `TipsSpeechRecognizer.swift` | Gate recognizer capability and require on-device processing; no automatic remote fallback | Optional voice with typed fallback |
| `FirebaseCircleService.swift`, `CircleStore.swift`, `firestore.rules` | Inventory actual deployed use; audit rules and preserve owners' management paths | Circles deferred; no feed, listeners or posting in new MVP |
| `QuestStore.swift`, `RewardsStore.swift`, `AIReflectionSessionStore.swift` | Preserve/export legacy data; map only explicitly selected next steps into entries | No rewards, points or separate quest dashboard |
| `FirebaseAnalyticsTracker.swift` | Current tracker uses logging; audit event properties and diagnostics rather than assuming remote Analytics SDK | No private content in logs; no third-party product analytics |
| `CloudKitDataModel.swift` and roadmap | Planning/schema artifacts found; empty app entitlements do not establish active CloudKit sync | No new CloudKit implementation; inventory before any deletion claim |

The present cloud purge uses suppressed failures and account deletion can continue after purge failure. Current scope changes do not repair this. Review the [source-backed project inventory](../../project-review-2026-10-23.md) alongside these tasks.

## Task 1 — Establish release and data inventory

**Files:** update `docs/qa/testflight-firebase-checklist.md`, `docs/product/supported-devices.md`; create `docs/engineering/legacy-data-inventory.md` with metadata only.

- [x] Inspect the visible App Store Connect build/upload history and metadata: 1.0 (1), expired, uploaded 11 June 2026, matching bundle ID, iOS 17 and iPhone+iPad; aggregate metrics recorded in the inventory. Exact expiry timestamp and actual tester devices were not exposed by these views.
- [x] Read the current user's Apple team roles: Developer and Marketing under University of Technology Sydney (Edu); Account Holder/Admin is not listed.
- [ ] Resolve continuing education-team distribution and any required administrator/account-holder involvement, plus actual tester device/OS coverage. Repository ownership alone does not establish Firebase or Apple account ownership.
- [ ] Inventory authorized Firebase projects, deployed rules, Auth providers, collections, retention settings and approximate record counts. Do not copy real journal text into docs or logs. Record unknowns explicitly.
- [ ] Identify guest-only, signed-in, signed-out, cloud-only/reinstalled and older-device users; establish a recovery contact/process without sending messages in this planning task.
- [ ] Check whether actual deployed circles exist and whether archived builds differ from the current source. Use the shipped schema/build as the migration source of truth.
- [ ] Decide bridge distribution and ongoing access for older devices. Apple TestFlight builds are available for up to 90 days, so an old binary alone is not a lasting recovery plan. [Apple TestFlight overview](https://developer.apple.com/help/app-store-connect/test-a-beta-version/testflight-overview/)

**Gate:** inventory determines release scope. Do not assume previous data is disposable or that all testers use the latest phone.

## Task 2 — Validate storage and isolate the local runtime

**Existing files:** `Circleu/App/{CircleuApp,ContentView,RootView}.swift`, `Circleu/Services/FirebaseRuntime.swift`, `Circleu/Engines/ReflectionEngine.swift`, both speech services. **Proposed files:** `Circleu/Services/LocalContentRepository.swift`, `Circleu/Services/LocalRuntime.swift`, `CircleuTests/LocalRuntimeTests.swift`, `CircleuTests/LocalContentRepositoryTests.swift`.

- [ ] Run a bounded storage spike for schema upgrades, complete file protection including sidecars, atomic linked writes/deletes, disk-full failure and recovery. Select SwiftData or another versioned store from evidence; do not finalize persistence solely from framework preference.
- [ ] Define `LocalContentRepository` operations for loading, draft persistence, saving by stable ID/revision, linked deletion and export. Return explicit protected-data/read/write/conflict errors; never turn failed reads into an empty successful store.
- [ ] Introduce a local composition root with no cloud constructors, observers or listeners. Audit background/scene changes and late callbacks as well as initial launch. Stop all old backup work before transitioning modes.
- [ ] Make model selection on-device → manual; remove the cloud engine from that dependency graph even when old cloud consent or a valid configuration exists. Apply speech capability checks before capture.
- [ ] Verify guest fresh install, legacy install and foreground/background paths with a valid Firebase configuration still present. Capture outbound activity and inspect content-free logs; distinguish OS-managed downloads/backups from CircleU content transmission.

**Tests:** `testGuestStartupDoesNotConstructCloudServices`, `testLegacyBackupTaskCannotUploadAfterModeChange`, `testUnavailableModelUsesManualFallback`, `testSpeechWithoutOnDeviceSupportOffersTyping`, `testProtectedDataUnavailableIsNotEmptyStore`, `testLinkedDeleteFailurePreservesBothRecords`. Physical tests remain necessary; mocks cannot establish network silence or microphone behavior.

## Task 3 — Preserve and migrate local data

**Existing files:** `Circleu/Stores/{ReflectionJournalStore,TipsPracticeStore,AIReflectionSessionStore,QuestStore,RewardsStore,UserProfileStore,AuthStore}.swift`; corresponding models. **Proposed files:** `Circleu/Services/LegacyLocalDataImporter.swift`, `CircleuTests/LegacyLocalDataImporterTests.swift`.

- [ ] Snapshot relevant raw legacy values into a protected, versioned recovery archive before running constructors/reset paths that may discard undecodable data. Record keys, schema, scope and checksums without recording content in logs.
- [ ] Inventory guest base keys and `.user.<uid>` variants, including `circleu.saved.reflections.v1`, `circleu.tipsPractice.sessions.v1`, `circleu.aiReflectionSessions.v1`, `circleu.quests.v1` and `circleu.rewards.v1`; enumerate profile/auth keys from shipped versions. Do not treat the current key list as exhaustive.
- [ ] Default to the current verified scope; keep other scopes sealed. Require account ownership verification for account-specific import. Historical unsuffixed keys may contain signed-in or mixed-account data: resolve provenance instead of labelling them guest-owned. Allow starting a separate guest workspace while offline/unverified without modifying those archives.
- [ ] Copy into staging, validate IDs/counts/relationships, then atomically activate the destination and durable migration receipt. Key receipts by source scope/schema/checksum; an interrupted retry must resume or report completion without reimporting deleted items.
- [ ] Preserve original words, accepted edits, titles/tags and timestamps; retain standalone/linked practice correctly. Never overwrite a newer local edit with an older import. Keep both conflicting versions for user choice where provenance cannot resolve them.
- [ ] Preserve available practice-image bytes and all recovered records without the old 12-session cap. The inspected practice model has no journal link; never invent one. Report missing cloud attachments, malformed records and unsupported categories explicitly. Do not use the existing `compactMap` restore or destructive AI-session loader as the migration decoder.
- [ ] If the new-app route is selected, design and validate a versioned, protected portable archive and atomic importer. The old readable text export is not a round-trip format. Exclude credential material; require preview, conflict handling, durable import receipts and source preservation. See release-route research for unresolved encryption/packaging choices.
- [ ] Keep source recovery copies until validation, with explicit export/delete controls. Local “delete all” must cover app-owned archives and receipts according to a documented reset policy; prevent a fresh startup from importing deleted content again. Historical OS backups remain outside this guarantee.

| Legacy category | Mapping |
| --- | --- |
| Journal and practice | Preserve stable IDs and available edits/source links; broken links become clearly labelled standalone content |
| Quests | Keep in archive/export; offer explicit selection of one next step per entry, never silently activate all old quests |
| AI session history | Preserve privately in archive/export; do not treat intermediate suggestions as accepted reflection |
| Rewards, point entries and activity events | Preserve in legacy export; no new reward UI or telemetry |
| Profile | Carry only chosen display preferences; do not copy credentials, hashes or tokens into the new guest store |
| Circles/posts/membership | Separate ownership-aware management/export; never import other members' content into a private journal or bulk-delete a shared circle |

**Tests:** process interruption before/after activation; repeated import; corrupt source bytes retained; guest/account isolation; unknown schema; ID collision; missing link; deletion after import then relaunch; low-storage failure preserves source and previously accepted data. Rollback must use a compatible recovery build/export path, not launch an old cloud-writing binary against a new schema.

## Task 4 — Provide explicit legacy recovery and cloud management

**Existing files:** `Circleu/Stores/BackendSessionStore.swift`, `Circleu/Services/{FirebaseAuthService,FirebaseFirestoreSyncService,FirebaseRuntime}.swift`, `firestore.rules`. **Proposed files:** `Circleu/Features/LegacyRecovery/LegacyRecoveryView.swift`, `Circleu/Services/LegacyRecoveryService.swift`, `CircleuTests/LegacyRecoveryTests.swift`. Server deletion implementation location is selected after the deployed-backend inventory; no admin credential belongs in the app.

- [ ] Offer “Retrieve or manage previous data” to legacy users, with clear network disclosure. Separate this from the guest core and disable all new-content upload. Sign-in failure preserves archives and permits retry; signing in must not automatically restore or merge.
- [ ] Retrieve authenticated private backup scopes: user/profile, journal entries, quests, practice sessions, reward state, point entries, activity events and AI sessions. Preview counts/categories, conflicts and cloud-only items before import or export. Cloud-only records may have been deleted locally; absence of tombstones is not permission to resurrect them.
- [ ] Keep import/export and cloud deletion separate choices. Successful local import does not imply remote deletion. Explain offline, expired session, no-backup, partial retrieval and cancellation states accurately; no-op adapters must not report a verified empty cloud account.
- [ ] Implement an idempotent, ownership-checked deletion process with explicit per-scope errors/retry. Block new writes for a deleting account, delete all owned nested records according to the circle-content policy, verify cleanup, then delete Auth. Keep minimal job status so an interrupted operation can resume without retaining content.
- [ ] Handle recent-login requirements and deletion failure without wiping the user's only recovery copy or announcing success. Firebase documents [reauthentication for account deletion](https://firebase.google.com/docs/auth/ios/manage-users) and that [parent deletion does not remove subcollections](https://firebase.google.com/docs/firestore/data-model).
- [ ] Audit deployed circle rules with owner/member/stranger emulator tests. Repair access controls or restrict obsolete writes through an explicitly planned backend change while retaining authorized export/deletion. A hidden tab is not an access-control fix.
- [ ] Audit prior Gemini/provider retention and any backups separately; do not promise that deleting Firestore erases historical provider requests or OS backups.

**Required flows:** existing local guest → migrate; authenticated legacy user → choose local data and optionally retrieve cloud; signed-out user → verify account; cloud-only reinstall → recover after sign-in; offline/failed import → preserve local work and retry; unsupported older OS/iPad → maintained recovery path; expired TestFlight build → accessible replacement route.

**Tests:** partial restore never reports complete; denied account scope never imports; purge failure never proceeds to false success; nested records removed; recent-login error retry; old-client writes rejected during deletion; repeated deletion request safe; public/shared content respects ownership. Extend `BackendSessionStoreTests.swift` and `FirebaseFirestoreSyncServiceTests.swift` to cover actual failure propagation, not only happy paths.

## Task 5 — Qualify releases and retire dependencies

**Files:** `Circleu.xcodeproj/project.pbxproj`, `.github/workflows/ci.yml`, `docs/qa/{phone-test-checklist,testflight-firebase-checklist}.md`, `docs/privacy.html`, `README.md`, product/engineering docs. The public privacy page exists at `docs/privacy.html`; revise it only against verified release behavior.

- [ ] Establish a passing baseline and align CI to an available Xcode/runtime combination. Record toolchain and destination rather than relying on a simulator name from an old workflow.
- [ ] Test the same-bundle migration build on previous release schemas and representative devices, including older OS/iPad if the inventory shows users. Release only after recovery, isolation and failure tests pass.
- [ ] Qualify the new Today/Journal/Practice beta against the supported-device matrix and all P0 criteria; update the OS floor/device declarations only after legacy access and distribution implications are resolved.
- [ ] Define an owner-reviewed retirement policy with notice/access process, retention decisions and verifiable recovery/deletion coverage. Do not invent a cutoff date or assume every tester upgraded. Maintain a bridge or authenticated alternative while previous data remains.
- [ ] After that gate, remove Firebase/Gemini SDK/configuration dependencies from the new app and close obsolete backend writes without removing remaining authorized management paths. Removing a client SDK does not authorize deleting the Firebase project.
- [ ] Reconcile public privacy text, App Store declarations and dependency inventory with observed release behavior. Record any continuing legacy service separately from the local-first guest experience.

Future baseline commands (not executed as part of this plan):

```sh
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer xcodebuild -version
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer xcrun simctl list runtimes
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer xcodebuild -showdestinations -project Circleu.xcodeproj -scheme Circleu
```

Choose an available simulator UUID from the output, then run:

```sh
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer xcodebuild test \
  -project Circleu.xcodeproj -scheme Circleu \
  -destination "platform=iOS Simulator,id=$CIRCLEU_TEST_SIMULATOR_ID"
```

Set `CIRCLEU_TEST_SIMULATOR_ID` explicitly from the verified inventory. Add Firestore emulator tests with a dedicated non-production project/configuration when the rules harness exists. Neither unit tests nor a simulator replace hardware AI/speech tests, deployed-rule verification or real upgrade evidence.

## Completion evidence

The transition is ready only when data counts/relationships and retries are verified; all supported paths preserve edits; guest runtime sends no private content; legacy cloud access/deletion remains truthful; the device matrix passes; and release/privacy records match the build. Until then, report planning or partial validation, not a completed local-only migration.
