# Circleu Architecture

Circleu uses SwiftUI with feature-first folders and separate guest and legacy dependency graphs. Updated 31 October 2026: guest/review is implemented; standard Release still follows the legacy Firebase/account startup. The [transition plan](../superpowers/plans/2026-10-23-local-first-transition.md) governs that change.

## Dependency Flow

```text
View -> ViewModel -> Store / Engine / Service -> Model
```

## Responsibilities

- **View**: renders SwiftUI layout, owns visual-only state, and calls ViewModel actions.
- **ViewModel**: owns screen state, validation, loading/empty/error states, and coordinates stores, engines, and services.
- **Store**: owns shared app state and local persistence. Stores save, load, update, delete, reset, and export local data.
- **Engine**: runs business logic, reflection generation, transcript checks, progress calculation, and beta state derivation.
- **Service**: wraps device APIs and current or future external integrations such as identity, sync, analytics, and model providers.
- **Model**: defines `Codable` domain data and small computed properties that are universally true.

## Ownership

Screens and feature ViewModels live together under `Circleu/Features/<FeatureName>/`.

Shared reusable SwiftUI pieces live in `Circleu/Components/` only after more than one feature needs them. Visual constants live in `Circleu/Design/`. Persistence belongs in `Circleu/Stores/`, business logic in `Circleu/Engines/`, system and backend boundaries in `Circleu/Services/`, and data shapes in `Circleu/Models/`.

## Local-First Boundary

The legacy app stores reflections, tips, profile data, AI session history and circles locally, but local persistence does not establish an offline-only boundary. On the legacy startup path, [CircleuApp](../../Circleu/App/CircleuApp.swift) configures Firebase, [ContentView](../../Circleu/App/ContentView.swift) constructs/wires backend-aware stores, and [RootView](../../Circleu/App/RootView.swift) schedules restore/upload work on appearance and mutations. This is source inspection, not a fresh runtime/network test.

The guest path has a separate dependency graph with local SwiftData and no normal Firebase activation/new-content upload. Explicit legacy recovery uses a separate named Firebase app restricted to the Dev project. V6 adds optional, validated context/feeling fields and migrates V1–V5 plus the restored initial Entry-only snapshot; conversation history and kept drafts remain in the same transaction boundary. ViewModels own revision-aware writes and truthful failure states. Source isolation and simulator tests are evidence for these contracts, not complete device/network or production recovery qualification. Backend work belongs behind service protocols/payload mapping. CloudKit documentation is a historical alternative, not an approved new-MVP dependency.

## Testing Boundary

Prefer unit tests for ViewModels, Stores, Engines, data flow, backend contracts, and migration mapping. Use phone QA for microphone, speech recognition, signing, Apple Intelligence availability, and full user-flow checks.
