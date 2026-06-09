# Circleu Team Standards

These rules keep the repo understandable for teammates and future contributors.

## Branch Rules

Use `main` as the stable branch. Do feature work on a personal or feature branch.

```bash
git checkout main
git fetch origin
git merge origin/main
git checkout -b feat/journal-circle-sharing
```

Before pushing a feature branch, merge the latest `main` and resolve conflicts locally:

```bash
git fetch origin
git merge origin/main
```

## Commit By Function

Commit one working function, fix, refactor, test addition, or doc update at a time.

Good messages:

```text
feat: add journal circle sharing
fix: handle empty transcript fallback
refactor: move profile qa tools into feature folder
test: add tips practice flow coverage
docs: reorganize project documentation
```

Bad messages:

```text
update files
final changes
fix stuff
commit all
```

## Professional Commit Commands

Review before staging:

```bash
git status --short
git diff
```

Stage only the files for the function:

```bash
git add Circleu/Features/Journal
git add Circleu/Stores/ReflectionJournalStore.swift
git commit -m "feat: add journal circle sharing"
```

Docs-only example:

```bash
git diff -- docs README.md
git add docs README.md
git commit -m "docs: refine project documentation"
```

Bug-fix example:

```bash
git diff -- Circleu/Features/Recording Circleu/Engines/TranscriptQuality.swift
git add Circleu/Features/Recording Circleu/Engines/TranscriptQuality.swift
git commit -m "fix: handle short transcript validation"
```

Avoid `git add .` unless every changed file has been reviewed.

## Verification Before Commit

Run the smallest useful check:

- Docs only: review `git diff -- docs README.md` and scan for stale links or placeholders.
- ViewModel, Store, Engine, backend contract, or CloudKit mapping behavior: run unit tests.
- SwiftUI or app integration: run an iPhone simulator build.
- Microphone, speech, signing, Apple Intelligence, or full user flow: run the phone checklist.

Useful commands:

```bash
xcodebuild build -project Circleu.xcodeproj -scheme Circleu -destination 'platform=iOS Simulator,name=iPhone 17 Pro'
xcodebuild test -project Circleu.xcodeproj -scheme Circleu -destination 'platform=iOS Simulator,name=iPhone 17 Pro'
```

## File Ownership

- `Circleu/Features/`: user-facing screens and feature-specific ViewModels.
- `Circleu/Components/`: reusable UI shared by multiple features.
- `Circleu/Design/`: colors, spacing, typography, and layout constants.
- `Circleu/Models/`: Codable domain models and value types.
- `Circleu/Stores/`: shared app state and local persistence.
- `Circleu/Engines/`: business logic and AI/reflection logic.
- `Circleu/Services/`: device APIs and future backend/provider boundaries.
- `CircleuTests/`: behavior tests for ViewModels, Stores, Engines, backend contracts, and data flow.
- `docs/`: living project knowledge and archived planning history.

## Ownership Split

Backend/engine owner:

- `Circleu/Engines/`
- `Circleu/Stores/`
- `Circleu/Services/`
- `Circleu/Models/`
- `CircleuTests/`
- `docs/engineering/`

UI owners:

- `Circleu/Features/`
- `Circleu/Components/`
- `Circleu/Design/`
- `Circleu/Assets.xcassets/`

Coordinate before changing another person's ownership area.

## Documentation Rules

Update docs in the same commit as the behavior or process change when the docs would otherwise become misleading.

Use these locations:

- Product/user-flow docs: `docs/product/`
- Architecture/domain/backend docs: `docs/engineering/`
- Manual QA docs: `docs/qa/`
- Team process docs: `docs/process/`
- Historical plans/specs: `docs/archive/`

Keep archived docs unchanged unless fixing links for readability. Current rules belong in active docs.

## Pull And Push Rules

Check status before pushing:

```bash
git status --short --branch
```

Push the current branch:

```bash
git push origin HEAD
```

Do not push broken builds or unrelated cleanup mixed with feature work. If a commit includes app code, be ready to say what verification you ran.
