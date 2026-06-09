# Circleu Project Structure

Circleu uses a feature-first structure with clear homes for shared UI, state, models, engines, services, and tests.

```text
Circleu/
  App/                 App entry, dependency injection, root navigation
  Assets.xcassets/     Colors and image assets
  Components/          Shared reusable SwiftUI components and button styles
  Design/              Design tokens such as colors, spacing, and layout constants
  Engines/             Business logic and AI/reflection logic
  Features/            User-facing screens grouped by product workflow
  Models/              Codable domain models and value types
  Services/            Device APIs and future backend/provider boundaries
  Stores/              ObservableObject state and local persistence
CircleuTests/          Unit tests for ViewModels, stores, engines, backend contracts, and data flow
docs/                  Current project knowledge and archived planning history
```

## Feature Folders

Use `Features/<FeatureName>/` for screens and UI that belong to one workflow: Home, Journal, Tips, Circle, Recording, Reflection, Profile, and Onboarding.

Keep feature-specific cards, rows, sheets, and ViewModels inside the feature folder until another feature truly needs them.

The app follows:

```text
View -> ViewModel -> Store / Engine / Service -> Model
```

Views render layout and call ViewModel actions. ViewModels own screen state, validation, sheet flags, copy/export state, and calls into stores, engines, or services. Stores remain the source of truth for local persistence.

## Shared UI

Use `Components/` only for reusable UI used by multiple features. Do not put domain-specific screens in `Components/`.

Examples:

- app background,
- top bar,
- tab bar,
- reusable form controls,
- shared button styles.

## Design

Use `Design/` for visual tokens and constants only. `PinguDesign` owns colors, spacing, and fixed layout constants. SwiftUI views should live in `Components/` or `Features/`.

## Backend And Engine Ownership

- `Models/` defines app data types.
- `Stores/` owns local state and persistence.
- `Engines/` transforms data or runs analysis.
- `Services/` wraps system APIs and backend/provider boundaries.
- `Services/BackendPreparation.swift` defines identity, sync, analytics, and provider contracts.
- `Services/CloudKitDataModel.swift` defines CloudKit record schema metadata.

This separation lets UI, business logic, and system integrations evolve independently.

## Reproducible Phone Testing

Use `Profile > QA tools` on a device to seed deterministic local demo data, reset first-run state, and export a QA summary. These controls are local-only and do not require a production backend.
