# MVP reuse and dependency map

24 October 2026. Repository/source review for planning; no app, service or hardware execution. Preserve existing work and adapt its contracts after approval. Visual approval does not make existing data/network behavior suitable for the guest-local path.

## Reuse before rebuilding

| Existing source | Useful foundation | Boundary to establish before production reuse |
| --- | --- | --- |
| [Brand helpers](../../Prototypes/CircleUVisualPrototype/Sources/CircleUVisualPrototype/BrandDemo.swift), [flow previews](../../Prototypes/CircleUVisualPrototype/Sources/CircleUVisualPrototype/BrandFlowPreview.swift), [calendar](../../Prototypes/CircleUVisualPrototype/Sources/CircleUVisualPrototype/JournalCalendarPreview.swift) | Accepted type, palette, artwork and screen hierarchy | Prototype fixtures remain isolated; production Dynamic Type, navigation and accessibility need implementation/verification |
| [JournalViewModel](../../Circleu/Features/Journal/JournalViewModel.swift) | Existing search across title, emotion, summary, insight, quote, private note, tags, transcript and engine | Add reviewed date/search behavior around one query path; do not copy the same filtering into multiple views |
| [ReflectionJournalStore](../../Circleu/Stores/ReflectionJournalStore.swift) | Stable-ID lookup, workspace updates, accepted result replacement and readable exports | Current calls do not prove atomic/error-aware persistence; preserve raw bytes before legacy loading and retain explicit failures |
| [JournalEntryDetailViewModel](../../Circleu/Features/Journal/JournalEntryDetailViewModel.swift), [entry model](../../Circleu/Models/ReflectionEntry.swift) | Existing detail actions and record fields | Separate original words, accepted interpretation and optional steps; maintain ID/update semantics |
| [TipsPracticeStore](../../Circleu/Stores/TipsPracticeStore.swift), [practice models](../../Circleu/Models/TipsPracticeModels.swift) | Existing situation/tone/message concepts and saved sessions | Define draft recovery and explicit reflection links; current history caps/legacy shape are not the new storage contract |
| [Firebase runtime](../../Circleu/Services/FirebaseRuntime.swift), [backend session](../../Circleu/Stores/BackendSessionStore.swift), [Firestore mapper](../../Circleu/Services/FirebaseFirestoreSyncService.swift) | Legacy identity and backup-format reference | Keep out of the new guest composition root; expose only explicit, consented recovery/account management |

## Proposed dependency order

1. Complete the [bounded prototype review](../superpowers/plans/2026-10-24-prototype-review-milestone.md): typed reflection, direct/linked practice and retrieval. Resolve scope and observable behavior before production work.
2. After implementation approval, run the existing transition plan's bounded local-storage/runtime feasibility task with invented fixtures and isolated dependencies. Preserve legacy bytes before constructing loaders. Establish explicit missing/read-failed/write-failed states, stable IDs and interruption-safe activation before restyling app startup.
3. Implement the first manual vertical slice: typed original words → reliable local save → Journal/detail → edit/reopen. Verify relaunch, repeated save, failed write and changed accepted content. Calendar filtering can follow its reviewed retrieval contract rather than block proof of safe storage.
4. Add direct and explicitly linked Practice, then optional on-device model/speech capabilities with useful manual fallback. Current cloud/model/speech wiring cannot be assumed compatible with the approved no-CircleU-cloud direction.
5. Qualify old-user recovery, build/CI and the device matrix before distribution. Preserve iOS 17/iPad legacy access while deciding the new floor. Apple enrollment, release route and shipped schema remain unresolved; they need not block an isolated visual review.

## Source-confirmed concerns and limits

The coordinator directly rechecked Firebase [startup](../../Circleu/App/CircleuApp.swift), [store wiring](../../Circleu/App/ContentView.swift), [automatic backup](../../Circleu/App/RootView.swift), the cloud fallback composition in [ReflectionEngine](../../Circleu/Engines/ReflectionEngine.swift), deletion continuing after a purge failure in [BackendSessionStore](../../Circleu/Stores/BackendSessionStore.swift), and decode failure deleting stored AI-session bytes in [AIReflectionSessionStore](../../Circleu/Stores/AIReflectionSessionStore.swift). These are source findings, not newly reproduced runtime failures. The [legacy format catalog](legacy-data-format.md) and [transition plan](../superpowers/plans/2026-10-23-local-first-transition.md) contain the deeper migration/deletion requirements; do not duplicate a second migration strategy here.

The existing [CI workflow](../../.github/workflows/ci.yml) targets main pushes/PRs and selects Xcode 16.0, while prior local preview evidence uses a different toolchain. No passing full-app baseline or supported physical device is established by this map. Follow the [device proposal](../product/supported-devices.md) and record fresh evidence when that deferred work is authorized.
