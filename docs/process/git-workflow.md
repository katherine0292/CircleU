# Circleu Git Workflow

Use small, reviewable commits. Each commit should represent one working feature slice, fix, refactor, test addition, or documentation update.

For complete team rules, see [team-standards.md](team-standards.md).

## Daily Start

```bash
git checkout main
git fetch origin
git merge origin/main
git checkout -b feat/short-description
```

If you are already on a feature branch:

```bash
git fetch origin
git merge origin/main
```

Resolve conflicts locally before pushing.

## Commit Scope

Good commits:

- `feat: add journal circle sharing`
- `fix: handle empty transcript fallback`
- `refactor: move profile qa tools into feature folder`
- `test: cover CloudKit schema mapping`
- `docs: refine project documentation`

Avoid:

- `update files`
- `final changes`
- `fix stuff`
- `commit all`

If a commit description needs "and also," split it.

## Before Committing

Review status and diff:

```bash
git status --short
git diff
```

Stage by function:

```bash
git add docs/engineering/cloudkit-data-model.md
git add Circleu/Services/CloudKitDataModel.swift CircleuTests/CloudKitSchemaTests.swift
git commit -m "feat: add CloudKit data model foundation"
```

Avoid `git add .` unless every changed file has been reviewed.

## Verification

Run the smallest useful check:

- Docs only: review `git diff -- docs README.md` and scan for stale paths.
- ViewModel, Store, Engine, backend contract, or mapping behavior: run unit tests.
- SwiftUI or app integration: run a simulator build.
- Signing, microphone, speech recognition, Apple Intelligence, or full flow: run the phone checklist.

Useful commands:

```bash
xcodebuild build -project Circleu.xcodeproj -scheme Circleu -destination 'platform=iOS Simulator,name=iPhone 17 Pro'
xcodebuild test -project Circleu.xcodeproj -scheme Circleu -destination 'platform=iOS Simulator,name=iPhone 17 Pro'
```

## Push Rule

Push after a coherent set of commits is ready for teammate review:

```bash
git push origin HEAD
```

Do not push broken builds or unrelated cleanup mixed with feature work.
