# Privacy, storage and recovery plan

Status: guest-first local-storage direction reaffirmed by the owner on 24 October 2026 after reconsidering required accounts. This is a plan, not verified production behavior. Previous TestFlight data may be real and must be preserved.

## Latest access decision

Welcome offers **Get started** for local use and optional **Log in** for earlier-account access/recovery. No account is required to write or save locally. The brief required-account decision is superseded; see the [onboarding brief](../design/account-onboarding.md). Signup remains deferred until a clear account benefit and data contract are reviewed.

Login does not automatically import, merge or back up entries. Preserve source ownership and explicit recovery choices. The current production app still contains Firebase/cloud paths; the isolated prototype does not prove local-only behavior.

## Approved direction and alternatives considered

The [live legacy inventory](../engineering/legacy-data-inventory.md) and [previous-data recovery prototype](../design/legacy-recovery-flow.md) now record verified Firebase observations and proposed migration/account-management routes. The previously uploaded TestFlight build and its backend mapping still need verification; existing cloud records are preserved.

Use a guest-first beta with app-managed local storage, on-device suggestions when available, and useful manual/guided fallbacks. Do not enable CircleU cloud AI, account signup or automatic CircleU backup/sync in that beta. Preserve ordinary device-backup behavior for user-created content and explain it accurately. Manual exports are user-controlled copies, not a promised restore mechanism.

| Approach | Benefit | Trade-off / recommendation |
| --- | --- | --- |
| Local storage; no CircleU cloud service | Smallest data boundary; typing and saved content work offline | No guaranteed recovery or cross-device access. Recommended for validating the core experience |
| Local storage plus optional encrypted sync | Recovery and multiple devices | Requires key recovery, conflicts, deletion propagation and independent security validation. Consider after users demonstrate a need |
| Account-backed Firebase/cloud AI now | Builds on existing integrations and supports server models | Adds account lifecycle, consent, provider retention and backend controls before core usefulness is established. Do not make this the default MVP path |

Do not describe local storage as “end-to-end encrypted,” “never leaves your phone” or guaranteed recovery. iOS backup, explicit exports, clipboard use and a recipient's storage are separate boundaries. Apple describes the backup-exclusion flag as guidance rather than a guarantee; excluding irreplaceable user documents also sacrifices recoverability. [Apple backup guidance](https://developer.apple.com/documentation/foundation/optimizing-your-app-s-data-for-icloud-backup)

## Proposed data lifecycle

| Data | Location and lifetime | User control |
| --- | --- | --- |
| Journal source, accepted reflection/feeling, optional step | Versioned local store; retained until deletion | Explicit Save, edit, export and delete |
| Standalone or linked practice | Same local store; link by stable entry ID | Edit/copy/save separately; delete independently or with entry |
| Unsaved work | Separate local draft, never overwrite accepted content until Save | Keep/discard/continue; status distinguishes saved draft from in-memory text |
| Generated suggestions | Working state until explicitly accepted | Reject or correct; source revision invalidates outdated suggestions |
| Microphone audio | Streaming buffers; no retained recording file in the proposed MVP | Stop/cancel/interruption ends capture; retain only reviewed text when saved |
| Export | Temporary protected file created on request | Preview scope, then system share sheet; clean app-owned temporary files after completion/cancel and at next launch |
| Telemetry and logs | No journal text, transcript, prompt, model response, message or export content | No third-party product analytics in initial beta; any later diagnostics need a separate minimized-data review |

Drafts should survive relaunch only after a successful durable write. Proposed behavior: autosave to a separate draft with an accurate status; explicit Save promotes it into the accepted entry. If writing fails, keep the buffer in memory, show “not saved,” offer retry, and explain that closing may lose it. Never claim a failed write is durable. Do not silently expire drafts in this beta.

Prefer a versioned local database behind a repository boundary over JSON blobs in UserDefaults. SwiftData is a candidate; verify schema migration, rollback and atomic linked deletion against the chosen deployment target before finalizing the storage implementation. UserDefaults remains for non-sensitive preferences. Use stable item IDs and source revisions so retries update one item and late generation results cannot overwrite newer edits.

Apply complete iOS file protection to sensitive storage, including any database sidecar files, and handle protected-data unavailability. Apple documents that complete protection makes files inaccessible while locked; the app must not treat that as an empty store. Hide private content in app-switcher snapshots and exclude content from notifications and logs. Do not invent a custom cryptographic scheme. Credentials, if introduced later, belong in Keychain rather than local password records. [Apple file-protection guidance](https://developer.apple.com/documentation/uikit/encrypting-your-app-s-files)

## On-device suggestions and speech

Select the on-device model explicitly; do not infer processing location from a framework name or silently swap to a remote provider. Check availability for the current OS, device, model, region and language. Unsupported/not-ready states offer writing and clearly labelled general prompts. A general template is not personalized AI. Model downloads may need internet even though generation can run on-device. [Apple model availability guidance](https://developer.apple.com/documentation/FoundationModels/generating-content-and-performing-tasks-with-foundation-models)

For speech, require on-device support before beginning recognition, then require on-device processing on the request. If unavailable, offer typing. Request microphone/speech permissions only after the user chooses voice. Stop on interruption/backgrounding/lock; never resume the microphone automatically. Preserve available text and offer review. Apple's Speech API only honors the on-device requirement when the recognizer supports it. [Apple Speech documentation](https://developer.apple.com/documentation/speech/sfspeechrecognitionrequest/requiresondevicerecognition)

Typing, existing entries, manual practice, export preparation and local deletion must remain usable without network connectivity. Do not block them on model availability or manufacture a network-error screen for a local operation. The first physical-device spike must verify these boundaries; no device eligibility list is frozen from assumptions.

## Deletion, exports and backups

Deleting an unlinked entry removes its source, accepted interpretation, associated next step and editor drafts from the active app store. Deleting a linked entry asks whether to keep the saved message independently or remove it too. Keeping it clears the entry ID and copied source/context excerpts; the intentionally retained message may still contain details the user wrote. Show the retained message before confirmation. Linked changes commit together or leave the original state intact on failure.

Deletion does not erase a file already exported, a recipient's copy, clipboard history or an older OS backup. Restoring an older device snapshot may restore older app content. A local-only app cannot enforce a deletion ledger across every historical backup; do not promise otherwise. Any future CircleU sync/restore must propagate deletions and prevent its own merge logic from resurrecting deleted records.

Export selected content as readable text, including accepted reflection/feeling and optional step, with linked practice only in the explicitly chosen scope. A full user-data export should additionally have a documented machine-readable format before beta; import/restore is a separate capability and must not be implied. Warn that exported text is readable by the chosen destination. Never automatically send it. Copy is explicit and independent of saving. Do not show successful export/delivery merely because a share sheet opened.

## Current-code migration boundary

The inspected source differs from this proposal:

- `ReflectionJournalStore` stores encoded journal data in UserDefaults. `RootView` schedules private Firebase backup/restore.
- `ReflectionEngineFactory` can fall back through `CloudReflectionEngine`, gated by cloud consent/settings. Hiding a cloud toggle does not remove that path.
- `VoiceRecorder` and `TipsSpeechRecognizer` create speech requests without requiring on-device recognition.
- Existing account deletion and merge-only backup issues are documented in the project review. The public privacy page promises cloud backup and immediate permanent deletion; it must be reconciled with verified release behavior.

Before implementing this approved beta policy: inventory installed-user data; preserve guest/account scopes; design a reversible migration; disable cloud integrations in the new experience at the service boundary; verify outbound requests; and provide explicit access/export/deletion handling for existing cloud data. Do not silently sign users out, erase cloud data, merge accounts or abandon remote copies. Local deletion must never be presented as deletion of a previous Firebase account. Existing deployed issues remain tracked until repaired or safely retired.

## Interaction contract

| Condition | Required outcome | Draft 02 evidence |
| --- | --- | --- |
| Generation/transcription in progress | Show progress, allow cancel; preserve input; ignore late results after cancel/revision change | Six timed loading snapshots, including revised source |
| Empty/whitespace input | Inline explanation; no model call or empty save; tone/outcome optional for practice | Blank reflection, context and message scenarios |
| Very short input | Allow a note; invite optional detail rather than demand disclosure or invent analysis | Spec rule; existing Save as note route; no dedicated short-text scenario |
| Oversized input | Keep complete text; explain the supported model limit and allow editing or note-only saving; never silently truncate | Spec rule; numeric limit requires model/device spike |
| Unsupported model | Manual writing/guided prompts; no silent cloud fallback | Model unavailable |
| Timeout, invalid output or generation failure | Keep input/source link; explicit retry or manual alternative; no partial accepted result | No AI and standalone/linked/corrected/updated-source error scenarios |
| Failed save, disk full or inaccessible storage | Accurate unsaved status; preserve current editor; retry same item; no duplicate or false success | Reflection, message, linked and draft save failures; locked/read-failed storage |
| Repeated save taps | Disable/ignore duplicate in-flight save; commit once; show accepted detail only after success | Required runtime behavior; static Figma cannot prove atomicity |
| Permission denied or voice interrupted | Typed fallback; preserve available text; no automatic recording restart | Voice access explanation, No microphone, interrupted and failed transcription |
| Source changed | Mark earlier suggestion stale; regenerate or save words only; preserve prior accepted entry until commit | Revised source, loading, result/note and matching history |
| Copy/export failure or share cancellation | No success claim; keep saved content and editor; explicit retry | Copy/export failures and export-handoff preview |
| Linked deletion failure | Both records remain; retry an explicit scope | Linked delete choices, confirmation, retained-message history and failure |

The three-second prototype transitions demonstrate progress; they are not product latency promises or prescribed artificial delays. Failure scenarios are reached through the review guide, not fake failure buttons in the application. Policies apply to all item variants; Figma uses representative sample states rather than every possible permutation.

## Decisions and evidence required before coding/release

The owner explicitly approved the guest/local direction and then confirmed a prior TestFlight version. The [supported-device proposal](supported-devices.md) and [local-first transition plan](../superpowers/plans/2026-10-23-local-first-transition.md) define the next gates. Existing cloud data requires a recovery/migration path; it is not disposable test data.

Before coding the MVP: review the recovery scenarios, validate the study/device scope and complete the legacy release/data inventory in the transition plan. Before selecting the AI/storage implementation, run a bounded device feasibility spike covering model availability, offline speech, protected storage and durable migration. Keep supported device/language/OS scope explicit.

Before beta: exercise process death, interrupted saves, no free storage, lock/unlock, denied permissions, late model callbacks, repeated taps, offline use, linked deletion rollback, export cancellation, and backup restoration. Verify network silence for content paths, inspect log/diagnostic payloads and reconcile the privacy notice, SDK inventory and App Store declarations. Apple distinguishes on-device-only processing from data collection; declarations must reflect actual SDK/service behavior, not this plan. [Apple privacy-details guidance](https://developer.apple.com/app-store/app-privacy-details/)

Research proposal: test the updated prototype with five target users, using invented/non-sensitive scenarios. Observe whether they can correct an interpretation, recover from failure, reopen saved wording and explain storage/recovery correctly. Treat misunderstandings as revisions, not participant mistakes. This is formative research, not evidence of therapeutic benefit. No interviews or device tests have been conducted in this planning pass.
